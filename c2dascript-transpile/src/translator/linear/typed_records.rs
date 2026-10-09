//! `--records typed` (docs/eden-flags.md flag 12) under `--memory-model
//! linear`: a struct type whose objects never meet byte memory is a daslang
//! struct allocated with `new T`, and a `T *` is a daslang `T?`.
//!
//! [`Translation::typed_plan`] decides, once per translation unit, which
//! struct types qualify.  The rule is a whitelist over every expression and
//! declaration of the unit; anything it does not list disqualifies the type,
//! which then keeps the byte-heap form of `linear.rs`.  A struct `T`
//! qualifies only when
//!
//! - every value of type `T *` is only read, assigned, compared with `==` /
//!   `!=`, tested for truth, passed to or returned from a function this unit
//!   defines (fixed parameters only), or used as the base of `p->f`;
//! - every conversion to `T *` is NULL, a qualifier change of a `T *`, or
//!   `malloc(sizeof(T))` / `calloc(1, sizeof(T))`, and the only conversion
//!   from `T *` is the argument of `free`;
//! - no `T **`, array of `T *` or `T`, `T` by value inside another record,
//!   `T *` field of a record that does not qualify, address of a `T` object
//!   or of one of its fields (`&p->f`, `&s.f`, a decayed array field), and no
//!   `*p` / `p[i]` / arithmetic on a `T *`;
//! - `T` has no bitfield.
//!
//! The record of a library call (other than `free`) or of `va_arg` never
//! qualifies.  Under `--module-layout source` the decision is the whole
//! program's: `lib.rs` collects every unit's [`TypedVerdict`] before any unit
//! is translated, and a struct qualifies only when it qualifies in every unit
//! ([`typed_records_program`]); a function another unit defines counts as
//! one "this unit defines".
//!
//! Lowering: `malloc`/`calloc` of the pattern is `new T()` (daslang
//! zero-initialises every field, which is `calloc`'s contract and a valid
//! choice for `malloc`'s indeterminate bytes); `free(p)` evaluates `p` and
//! releases nothing (`delete` needs `unsafe`, which the sandbox refuses; the
//! object is reclaimed by the garbage collector); NULL is `null`; `p->f` is
//! daslang `p.f`.
use super::*;
use std::collections::HashSet;

thread_local! {
    /// The struct types of this unit that are typed `new T` objects.
    static TYPED: RefCell<HashSet<CRecordId>> = RefCell::new(HashSet::new());
    /// Casts the rule allows that are not plain: the `T *` of an allocation
    /// pattern and the `void *` argument of `free`.
    static ALLOC_CASTS: RefCell<HashSet<CExprId>> = RefCell::new(HashSet::new());
    static FREE_CASTS: RefCell<HashSet<CExprId>> = RefCell::new(HashSet::new());
    /// The daslang `T?` types of the typed records, computed on first use.
    static TYPED_DA: RefCell<Option<Vec<String>>> = RefCell::new(None);
}

pub(super) fn reset() {
    TYPED_DA.with(|t| *t.borrow_mut() = None);
    TYPED.with(|t| t.borrow_mut().clear());
    ALLOC_CASTS.with(|t| t.borrow_mut().clear());
    FREE_CASTS.with(|t| t.borrow_mut().clear());
}

/// One unit's part of the whole-program `--records typed` decision under
/// `--module-layout source` (`lib.rs typed_records_program`).  Records are
/// named by `Translation::record_key`.
#[derive(Clone, Debug, Default)]
pub struct TypedVerdict {
    /// Every complete struct of the unit.
    pub candidates: std::collections::BTreeSet<String>,
    /// The structs the unit's own rule disqualifies.
    pub out: std::collections::BTreeSet<String>,
    /// A `T *` field of record `U`, as (`U`, `T`): `T` needs `U` typed.
    pub edges: Vec<(String, String)>,
    /// Struct names the unit sees only as an incomplete `struct S;`.
    pub opaque_names: std::collections::BTreeSet<String>,
}

/// The whole-program decision: a struct qualifies only when every unit's
/// rule lets it, no unit sees it opaque, no other C struct shares its name,
/// and every record holding a `T *` field of it qualifies too.
pub fn typed_records_program(verdicts: &[TypedVerdict]) -> std::collections::BTreeSet<String> {
    use std::collections::BTreeSet;
    let name_of = |k: &str| k.split('@').next().unwrap_or("").to_owned();
    let mut candidates: BTreeSet<String> = BTreeSet::new();
    let mut out: BTreeSet<String> = BTreeSet::new();
    let mut opaque: BTreeSet<String> = BTreeSet::new();
    for v in verdicts {
        candidates.extend(v.candidates.iter().cloned());
        out.extend(v.out.iter().cloned());
        opaque.extend(v.opaque_names.iter().cloned());
    }
    let mut sites: std::collections::HashMap<String, usize> = std::collections::HashMap::new();
    for k in &candidates {
        *sites.entry(name_of(k)).or_default() += 1;
    }
    for k in &candidates {
        let name = name_of(k);
        if !name.is_empty() && (opaque.contains(&name) || sites[&name] > 1) {
            out.insert(k.clone());
        }
    }
    loop {
        let before = out.len();
        for v in verdicts {
            for (u, t) in &v.edges {
                if out.contains(u) || !candidates.contains(u) {
                    out.insert(t.clone());
                }
            }
        }
        if out.len() == before {
            break;
        }
    }
    candidates.difference(&out).cloned().collect()
}

fn is_typed(r: CRecordId) -> bool {
    TYPED.with(|t| t.borrow().contains(&r))
}

impl<'c> Translation<'c> {
    fn records_typed(&self) -> bool {
        self.tcfg.target.records == crate::target::RecordsModel::Typed
    }

    /// The struct a `T *` type points to (typedefs, qualifiers resolved).
    fn struct_pointee(&self, ty: CTypeId) -> Option<CRecordId> {
        match self.ast_context.resolve_type(ty).kind {
            CTypeKind::Pointer(inner) => match self.ast_context.resolve_type(inner.ctype).kind {
                CTypeKind::Struct(r) => Some(r),
                _ => None,
            },
            _ => None,
        }
    }

    /// The record `ty` points to when it is a typed record.
    pub(super) fn typed_pointee(&self, ty: CTypeId) -> Option<CRecordId> {
        self.struct_pointee(ty).filter(|r| is_typed(*r))
    }

    /// Whether struct `r` is a typed record of this unit.
    pub(crate) fn is_typed_record(&self, r: CRecordId) -> bool {
        self.is_linear() && is_typed(r)
    }

    /// Whether daslang type `t` is the `T?` of a typed record.  Every value
    /// of that type is one (no conversion to or from it qualifies), so a
    /// pointer conversion to it is the identity.
    pub(crate) fn is_typed_da_pointer(&self, t: &DaType) -> bool {
        if !self.is_linear() || !matches!(t.kind, DaTypeKind::Pointer(_)) {
            return false;
        }
        if TYPED_DA.with(|c| c.borrow().is_none()) {
            let records: HashSet<CRecordId> = TYPED.with(|s| s.borrow().clone());
            let mut types = Vec::new();
            for (&id, ty) in self.ast_context.iter_types() {
                if matches!(ty.kind, CTypeKind::Struct(s) if records.contains(&s)) {
                    if let Ok(inner) = self.convert_type(CQualTypeId::new(id)) {
                        types.push(DaType::pointer(inner).to_string());
                    }
                }
            }
            TYPED_DA.with(|c| *c.borrow_mut() = Some(types));
        }
        // Compared as spelled: the flags a use site sets (`is_ref`,
        // `is_temporary`) do not make another type.
        let spelled = t.to_string();
        TYPED_DA.with(|c| c.borrow().as_ref().map_or(false, |v| v.contains(&spelled)))
    }

    /// Whether the C pointer type `ty` is a daslang `T?` of a typed record.
    pub(crate) fn is_typed_record_pointer(&self, ty: CTypeId) -> bool {
        self.is_linear() && self.typed_pointee(ty).is_some()
    }

    fn strip(&self, mut e: CExprId) -> CExprId {
        loop {
            match self.ast_context[e].kind {
                CExprKind::Paren(_, i) | CExprKind::ImplicitCast(_, i, _, _, _) => e = i,
                _ => return e,
            }
        }
    }

    /// `sizeof(T)` with `T` the struct `r` (the type form).
    fn is_sizeof_record(&self, e: CExprId, r: CRecordId) -> bool {
        match self.ast_context[self.strip(e)].kind {
            CExprKind::UnaryType(_, CUnTypeOp::SizeOf, None, qt) => {
                matches!(self.ast_context.resolve_type(qt.ctype).kind, CTypeKind::Struct(s) if s == r)
            }
            _ => false,
        }
    }

    /// `malloc(sizeof(T))` or `calloc(1, sizeof(T))`: one object of struct `r`.
    fn is_alloc_of(&self, call: CExprId, r: CRecordId) -> bool {
        let CExprKind::Call(_, func, ref args) = self.ast_context[self.strip(call)].kind else {
            return false;
        };
        match self.callee_name(func) {
            Some((name, false)) if name == "malloc" && args.len() == 1 => self.is_sizeof_record(args[0], r),
            Some((name, false)) if name == "calloc" && args.len() == 2 => {
                matches!(
                    self.ast_context[self.strip(args[0])].kind,
                    CExprKind::Literal(_, CLiteral::Integer(1, _))
                ) && self.is_sizeof_record(args[1], r)
            }
            _ => false,
        }
    }

    /// The program-wide identity of struct `r` under the source layout: its
    /// name and the place of its definition, the way `lib.rs link_units`
    /// tells two C types of one name apart.  `None` for a record with no
    /// place, which never qualifies across units.
    fn record_key(&self, r: CRecordId) -> Option<String> {
        let decl = &self.ast_context[r];
        let CDeclKind::Struct { name, .. } = &decl.kind else { return None };
        let site = self.ast_context.display_loc(&decl.loc)?;
        Some(format!("{}@{site}", name.as_deref().unwrap_or("")))
    }

    /// This unit's verdict for the whole-program rule (`--module-layout
    /// source`): the rule of [`Self::typed_plan`] applied to this unit alone,
    /// with records named by [`Self::record_key`].
    pub(crate) fn typed_verdict(&self) -> TranslationResult<TypedVerdict> {
        let (candidates, out, edges) = self.typed_local()?;
        let key = |r: &CRecordId| self.record_key(*r);
        let mut verdict = TypedVerdict::default();
        for r in &candidates {
            match key(r) {
                Some(k) if !out.contains(r) => {
                    verdict.candidates.insert(k);
                }
                Some(k) => {
                    verdict.candidates.insert(k.clone());
                    verdict.out.insert(k);
                }
                None => {}
            }
        }
        for r in &out {
            verdict.out.extend(key(r));
        }
        for (u, t) in &edges {
            if let (Some(u), Some(t)) = (key(u), key(t)) {
                verdict.edges.push((u, t));
            } else {
                verdict.out.extend(key(t));
            }
        }
        // A record this unit sees only as `struct S;` is a different C
        // declaration here: it never qualifies, wherever it is complete.
        let mut complete = HashSet::new();
        let mut opaque = HashSet::new();
        for (_, d) in self.ast_context.iter_decls() {
            if let CDeclKind::Struct { name: Some(name), fields, .. } = &d.kind {
                if fields.is_some() {
                    complete.insert(name.clone());
                } else {
                    opaque.insert(name.clone());
                }
            }
        }
        verdict.opaque_names = opaque.difference(&complete).cloned().collect();
        Ok(verdict)
    }

    /// Decides the typed records of this unit (see the module comment).
    /// Under the source layout the decision is the program's
    /// (`UnitLink::typed_records`, made by `lib.rs` from every unit's
    /// [`Self::typed_verdict`]); this unit's rule still has to hold.
    pub(crate) fn typed_plan(&self) -> TranslationResult<()> {
        reset();
        if !self.records_typed() {
            return Ok(());
        }
        let (candidates, out, _) = self.typed_local()?;
        let mut typed: HashSet<CRecordId> = candidates.difference(&out).copied().collect();
        if let Some(link) = &self.link {
            typed.retain(|r| self.record_key(*r).map_or(false, |k| link.typed_records.contains(&k)));
        }
        TYPED.with(|t| *t.borrow_mut() = typed);
        Ok(())
    }

    /// The rule over this unit: the candidate structs, the disqualified
    /// ones (after the field fixpoint) and the `T *` field edges (`U`, `T`).
    #[allow(clippy::type_complexity)]
    fn typed_local(
        &self,
    ) -> TranslationResult<(HashSet<CRecordId>, HashSet<CRecordId>, Vec<(CRecordId, CRecordId)>)> {
        let mut candidates: HashSet<CRecordId> = HashSet::new();
        let mut out: HashSet<CRecordId> = HashSet::new();
        // A `T *` field of record `U`: `T` needs `U` typed.
        let mut edges: Vec<(CRecordId, CRecordId)> = Vec::new();
        let mut roots = Vec::new();
        let mut decl_types = Vec::new();
        for (&id, d) in self.ast_context.iter_decls() {
            match &d.kind {
                CDeclKind::Struct { fields: Some(fields), .. } => {
                    candidates.insert(id);
                    for &f in fields {
                        if let CDeclKind::Field { typ, bitfield_width, .. } = self.ast_context[f].kind {
                            if bitfield_width.is_some() {
                                out.insert(id);
                            }
                            match self.ast_context.resolve_type(typ.ctype).kind {
                                // An aggregate field is read as a place
                                // through the raw path: neither record
                                // qualifies.
                                CTypeKind::Struct(t) => {
                                    out.insert(t);
                                    out.insert(id);
                                }
                                CTypeKind::Union(_)
                                | CTypeKind::ConstantArray(..)
                                | CTypeKind::IncompleteArray(..)
                                | CTypeKind::VariableArray(..) => {
                                    out.insert(id);
                                    decl_types.push(typ.ctype);
                                }
                                _ => match self.struct_pointee(typ.ctype) {
                                    Some(t) => edges.push((id, t)),
                                    None => decl_types.push(typ.ctype),
                                },
                            }
                        }
                    }
                }
                CDeclKind::Union { fields: Some(fields), .. } => {
                    for &f in fields {
                        if let CDeclKind::Field { typ, .. } = self.ast_context[f].kind {
                            match self.ast_context.resolve_type(typ.ctype).kind {
                                CTypeKind::Struct(t) => {
                                    out.insert(t);
                                }
                                _ => match self.struct_pointee(typ.ctype) {
                                    Some(t) => {
                                        out.insert(t);
                                    }
                                    None => decl_types.push(typ.ctype),
                                },
                            }
                        }
                    }
                }
                CDeclKind::Variable { typ, initializer, .. } => {
                    decl_types.push(typ.ctype);
                    if let Some(i) = initializer {
                        roots.push(SomeId::Expr(*i));
                    }
                }
                CDeclKind::Function { typ, body, .. } => {
                    decl_types.push(*typ);
                    if let Some(b) = body {
                        roots.push(SomeId::Stmt(*b));
                    }
                }
                _ => {}
            }
        }
        for ty in decl_types {
            self.typed_scan_top(ty, &mut out);
        }
        let exprs: Vec<CExprId> = roots
            .into_iter()
            .flat_map(|root| {
                DFExpr::new(&self.ast_context, root)
                    .filter_map(|n| match n {
                        SomeId::Expr(e) => Some(e),
                        _ => None,
                    })
                    .collect::<Vec<_>>()
            })
            .collect();
        // The casts the allocation and `free` patterns own.
        let mut alloc_casts = HashSet::new();
        let mut free_casts = HashSet::new();
        for &e in &exprs {
            match self.ast_context[e].kind {
                CExprKind::ImplicitCast(ty, inner, CastKind::BitCast, _, _)
                | CExprKind::ExplicitCast(ty, inner, CastKind::BitCast, _, _) => {
                    if let Some(r) = self.struct_pointee(ty.ctype) {
                        if self.is_alloc_of(inner, r) {
                            alloc_casts.insert(e);
                        }
                    }
                }
                CExprKind::Call(_, func, ref args) => {
                    if let (Some((name, false)), [arg]) = (self.callee_name(func), args.as_slice()) {
                        if name == "free" {
                            let mut a = *arg;
                            while let CExprKind::Paren(_, i) = self.ast_context[a].kind {
                                a = i;
                            }
                            free_casts.insert(a);
                        }
                    }
                }
                _ => {}
            }
        }
        for &e in &exprs {
            self.typed_scan_expr(e, &alloc_casts, &free_casts, &mut out)?;
        }
        // Fixpoint: a `T *` field of a record that is not typed is in byte
        // memory.
        loop {
            let before = out.len();
            for &(u, t) in &edges {
                if out.contains(&u) || !candidates.contains(&u) {
                    out.insert(t);
                }
            }
            if out.len() == before {
                break;
            }
        }
        ALLOC_CASTS.with(|t| *t.borrow_mut() = alloc_casts);
        FREE_CASTS.with(|t| *t.borrow_mut() = free_casts);
        Ok((candidates, out, edges))
    }

    /// A type a declaration or expression has: `T *` itself is allowed; a
    /// `T` or `T *` stored in byte memory (behind another pointer, in an
    /// array) disqualifies `T`.
    fn typed_scan_top(&self, ty: CTypeId, out: &mut HashSet<CRecordId>) {
        match self.ast_context.resolve_type(ty).kind {
            CTypeKind::Pointer(inner) => match self.ast_context.resolve_type(inner.ctype).kind {
                CTypeKind::Struct(_) => {}
                CTypeKind::Function(ret, ref params, ..) => {
                    let params = params.clone();
                    self.typed_scan_top(ret.ctype, out);
                    for p in params {
                        self.typed_scan_top(p.ctype, out);
                    }
                }
                _ => self.typed_scan_mem(inner.ctype, out),
            },
            CTypeKind::Function(ret, ref params, ..) => {
                let params = params.clone();
                self.typed_scan_top(ret.ctype, out);
                for p in params {
                    self.typed_scan_top(p.ctype, out);
                }
            }
            CTypeKind::ConstantArray(elem, _)
            | CTypeKind::IncompleteArray(elem)
            | CTypeKind::VariableArray(elem, _) => self.typed_scan_mem(elem, out),
            _ => {}
        }
    }

    /// A type stored in byte memory.
    fn typed_scan_mem(&self, ty: CTypeId, out: &mut HashSet<CRecordId>) {
        match self.ast_context.resolve_type(ty).kind {
            CTypeKind::Struct(r) => {
                out.insert(r);
            }
            CTypeKind::Pointer(_) => match self.struct_pointee(ty) {
                Some(r) => {
                    out.insert(r);
                }
                None => self.typed_scan_top(ty, out),
            },
            CTypeKind::ConstantArray(elem, _)
            | CTypeKind::IncompleteArray(elem)
            | CTypeKind::VariableArray(elem, _) => self.typed_scan_mem(elem, out),
            _ => {}
        }
    }

    /// Every record whose field an lvalue path names (`&p->f`, `&s.a.b`, a
    /// decayed array field), and the lvalue's own struct type.
    fn typed_scan_lvalue(&self, e: CExprId, out: &mut HashSet<CRecordId>) {
        if let Some(q) = self.ast_context[e].kind.get_qual_type() {
            if let CTypeKind::Struct(r) = self.ast_context.resolve_type(q.ctype).kind {
                out.insert(r);
            }
        }
        match self.ast_context[e].kind {
            CExprKind::Paren(_, i) => self.typed_scan_lvalue(i, out),
            CExprKind::Member(_, base, field, kind, _) => {
                if let Some(&r) = self.ast_context.parents.get(&field) {
                    out.insert(r);
                }
                if matches!(kind, MemberKind::Dot) {
                    self.typed_scan_lvalue(base, out);
                }
            }
            CExprKind::ArraySubscript(_, lhs, rhs, _) => {
                if let Some(a) = self.decayed_array(lhs).or_else(|| self.decayed_array(rhs)) {
                    self.typed_scan_lvalue(a, out);
                }
            }
            _ => {}
        }
    }

    fn typed_scan_expr(
        &self,
        e: CExprId,
        alloc_casts: &HashSet<CExprId>,
        free_casts: &HashSet<CExprId>,
        out: &mut HashSet<CRecordId>,
    ) -> TranslationResult<()> {
        let ty_of = |x: CExprId| self.ast_context[x].kind.get_qual_type().map(|q| q.ctype);
        let ptr_of = |x: CExprId| ty_of(x).and_then(|t| self.struct_pointee(t));
        if let Some(t) = ty_of(e) {
            self.typed_scan_top(t, out);
        }
        match self.ast_context[e].kind {
            CExprKind::Unary(_, op, arg, _) => match op {
                CUnOp::AddressOf => self.typed_scan_lvalue(arg, out),
                CUnOp::Deref
                | CUnOp::PreIncrement
                | CUnOp::PreDecrement
                | CUnOp::PostIncrement
                | CUnOp::PostDecrement => out.extend(ptr_of(arg)),
                _ => {}
            },
            CExprKind::ImplicitCast(ty, inner, ck, _, _) | CExprKind::ExplicitCast(ty, inner, ck, _, _) => {
                if matches!(ck, CastKind::ArrayToPointerDecay) {
                    self.typed_scan_lvalue(inner, out);
                }
                let to = self.struct_pointee(ty.ctype);
                let from = ptr_of(inner);
                if to.is_some() || from.is_some() {
                    let allowed = match ck {
                        CastKind::LValueToRValue | CastKind::NoOp | CastKind::ConstCast => to == from,
                        CastKind::NullToPointer => from.is_none(),
                        CastKind::PointerToBoolean | CastKind::ToVoid => to.is_none(),
                        // `NULL` is `(void *)0`: a bit cast of a null constant.
                        CastKind::BitCast => {
                            alloc_casts.contains(&e)
                                || (to.is_none() && free_casts.contains(&e))
                                || (from.is_none() && self.ast_context.is_null_expr(inner))
                        }
                        _ => false,
                    };
                    if !allowed {
                        out.extend(to);
                        out.extend(from);
                    }
                }
            }
            CExprKind::ArraySubscript(_, lhs, rhs, _) => {
                out.extend(ptr_of(lhs));
                out.extend(ptr_of(rhs));
            }
            CExprKind::Binary(_, op, lhs, rhs, _, _) => {
                if !matches!(op, CBinOp::Assign | CBinOp::EqualEqual | CBinOp::NotEqual | CBinOp::Comma) {
                    out.extend(ptr_of(lhs));
                    out.extend(ptr_of(rhs));
                }
            }
            CExprKind::VAArg(..) => out.extend(ptr_of(e)),
            CExprKind::Call(_, func, ref args) => {
                // A library function (no body here) sees none of it; a
                // variadic argument is written into the heap's C stack.
                let callee = self.strip(func);
                let (library, fixed) = match self.ast_context[callee].kind {
                    CExprKind::DeclRef(_, d, _) => match &self.ast_context[d].kind {
                        CDeclKind::Function { body, parameters, typ, name, .. } => {
                            let (variadic, prototyped) = match self.ast_context.resolve_type(*typ).kind {
                                CTypeKind::Function(_, _, v, _, p) => (v, p),
                                _ => (false, false),
                            };
                            // Source layout: a prototyped function another
                            // unit defines is translated under the same
                            // program-wide decision.
                            let elsewhere = prototyped && self.link_owner(name).is_some();
                            (
                                body.is_none() && !elsewhere,
                                if variadic { parameters.len() } else { usize::MAX },
                            )
                        }
                        _ => (false, usize::MAX),
                    },
                    _ => (false, usize::MAX),
                };
                if library {
                    out.extend(ptr_of(e));
                }
                for (i, &a) in args.iter().enumerate() {
                    if library || i >= fixed {
                        out.extend(ptr_of(a));
                    }
                }
            }
            _ => {}
        }
        Ok(())
    }

    /// The lowering of a cast that involves a typed record pointer, or
    /// `None` when the ordinary daslang lowering is the typed one (a read, a
    /// qualifier change, NULL).
    pub(super) fn typed_cast(
        &self,
        ctx: ExprContext,
        expr_id: CExprId,
        ty: CQualTypeId,
        inner: CExprId,
        ck: CastKind,
    ) -> TranslationResult<Option<Option<WithStmts<DaExpr>>>> {
        let to = self.typed_pointee(ty.ctype);
        let from = self.qual_of(inner).ok().and_then(|q| self.typed_pointee(q.ctype));
        if to.is_none() && from.is_none() {
            return Ok(None);
        }
        let lowered = match ck {
            CastKind::LValueToRValue | CastKind::NoOp | CastKind::ConstCast if to == from => None,
            CastKind::NullToPointer if from.is_none() => {
                Some(WithStmts::new_val(DaExpr::ConstNull))
            }
            CastKind::BitCast if from.is_none() && self.ast_context.is_null_expr(inner) => {
                Some(WithStmts::new_val(DaExpr::ConstNull))
            }
            CastKind::PointerToBoolean if to.is_none() => Some(
                self.convert_expr(ctx.used(), inner, None)?
                    .map(|v| op2("!=", v, DaExpr::ConstNull)),
            ),
            CastKind::ToVoid => None,
            CastKind::BitCast if ALLOC_CASTS.with(|a| a.borrow().contains(&expr_id)) => {
                let CTypeKind::Pointer(pointee) = self.ast_context.resolve_type(ty.ctype).kind else {
                    return Err(self.linear_refuse(expr_id, "a typed record allocation"));
                };
                let t = self.convert_type(pointee)?;
                Some(WithStmts::new_val(DaExpr::New(Box::new(DaExpr::Var(t.to_string())), vec![])))
            }
            _ => return Err(self.linear_refuse(expr_id, &format!("cast {ck:?} of a --records typed pointer"))),
        };
        Ok(Some(lowered))
    }

    /// `p->f` of a typed record: daslang `p.f` (a scalar or pointer field;
    /// a record with an aggregate field never qualifies).
    pub(super) fn typed_member(
        &self,
        ctx: ExprContext,
        expr_id: CExprId,
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        let CExprKind::Member(_, base, field, MemberKind::Arrow, _) = self.ast_context[expr_id].kind else {
            return Ok(None);
        };
        if self.typed_pointee(self.qual_of(base)?.ctype).is_none() {
            return Ok(None);
        }
        let name = match &self.ast_context[field].kind {
            CDeclKind::Field { name, .. } => self
                .type_converter
                .borrow()
                .resolve_field_name(None, field)
                .unwrap_or_else(|| name.clone()),
            _ => return Err(self.linear_refuse(expr_id, "a member that is not a field")),
        };
        let obj = self.convert_expr(ctx.used(), base, None)?;
        Ok(Some(obj.map(|o| DaExpr::Field(Box::new(o), name))))
    }

    /// `free(p)` of a typed record: `p` is evaluated, nothing is released
    /// (the garbage collector reclaims the object).
    pub(super) fn typed_free(
        &self,
        ctx: ExprContext,
        args: &[CExprId],
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        let [arg] = args else { return Ok(None) };
        let mut a = *arg;
        while let CExprKind::Paren(_, i) = self.ast_context[a].kind {
            a = i;
        }
        if !FREE_CASTS.with(|f| f.borrow().contains(&a)) {
            return Ok(None);
        }
        let (CExprKind::ImplicitCast(_, inner, CastKind::BitCast, _, _)
        | CExprKind::ExplicitCast(_, inner, CastKind::BitCast, _, _)) = self.ast_context[a].kind
        else {
            return Ok(None);
        };
        if !self.qual_of(inner).map_or(false, |q| self.typed_pointee(q.ctype).is_some()) {
            return Ok(None);
        }
        Ok(Some(self.convert_expr(ctx.unused(), inner, None)?))
    }
}
