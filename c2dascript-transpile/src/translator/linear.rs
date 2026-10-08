//! `--memory-model linear`: C memory as one module-global `array<uint8>`.
//!
//! An address is an `int` offset into `c2da_mem`; NULL is 0 and the first 16
//! bytes are never handed out.  A data pointer's daScript type is `int`; in
//! memory it occupies Clang's 8 bytes, the offset in the low 4 (little
//! endian) and zero in the high 4.  Every load and store through a pointer is
//! written in place: a byte is `c2da_mem[a]`, a wider integer is assembled
//! from bytes with shifts, `float`/`double` go through `daslib/math_bits`.
//! Pointer arithmetic is integer arithmetic scaled by Clang's pointee size;
//! a field through a pointer is the base plus Clang's field offset.
//!
//! String literals whose address is taken live in a static block written into
//! the heap by an `[init]` function; their offsets are translation-time
//! constants.  `malloc`/`calloc`/`realloc`/`free` and the byte functions
//! (`memcpy`, `memmove`, `memset`, `memcmp`, `strlen`) are the `c2da_lin_*`
//! runtime appended to the module ([`runtime_source`]).
//!
//! What this file does not lower is refused with a located
//! "not supported under --memory-model linear yet" error, and module assembly
//! refuses any `unsafe` construct left in a linear module
//! (`target_check.rs check_linear`), so no raw-pointer form can slip through.
use super::*;
use crate::target::MemoryModel;
use crate::translator::layout::NaturalMember;
use std::collections::HashMap as StdHashMap;

/// The heap: one module global.
pub(crate) const MEM: &str = "c2da_mem";
/// Bytes at the bottom of the heap that no object occupies, so 0 is NULL.
const RESERVED: usize = 16;

thread_local! {
    /// The static block: string-literal bytes, deduplicated, from offset 16.
    static STATIC: RefCell<(Vec<u8>, StdHashMap<Vec<u8>, i64>)> =
        RefCell::new((vec![0; RESERVED], StdHashMap::new()));
}

/// Clears the static block at the start of a translation unit.
pub fn reset() {
    STATIC.with(|s| *s.borrow_mut() = (vec![0; RESERVED], StdHashMap::new()));
}

/// The offset of a string literal's bytes (with its NUL) in the static block.
fn intern(bytes: Vec<u8>) -> i64 {
    STATIC.with(|s| {
        let mut s = s.borrow_mut();
        if let Some(&at) = s.1.get(&bytes) {
            return at;
        }
        let at = s.0.len() as i64;
        s.0.extend_from_slice(&bytes);
        s.1.insert(bytes, at);
        at
    })
}

/// A scalar as it sits in linear memory.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Scalar {
    Bool,
    I8,
    U8,
    I16,
    U16,
    I32,
    U32,
    I64,
    U64,
    F32,
    F64,
    /// A data pointer: `int` offset, 8 bytes in memory.
    Ptr,
}

impl Scalar {
    fn da_type(self) -> DaType {
        match self {
            Scalar::Bool => DaType::bool(),
            Scalar::I8 => DaType::int8(),
            Scalar::U8 => DaType::uint8(),
            Scalar::I16 => DaType::int16(),
            Scalar::U16 => DaType::uint16(),
            Scalar::I32 | Scalar::Ptr => DaType::int(),
            Scalar::U32 => DaType::uint(),
            Scalar::I64 => DaType::int64(),
            Scalar::U64 => DaType::uint64(),
            Scalar::F32 => DaType::float(),
            Scalar::F64 => DaType::double(),
        }
    }
}

fn cast(to: DaType, expr: DaExpr) -> DaExpr {
    DaExpr::Cast {
        kind: das_ast::CastKind::Cast,
        expr: Box::new(expr),
        to,
    }
}

fn op2(op: &'static str, left: DaExpr, right: DaExpr) -> DaExpr {
    DaExpr::Op2 {
        op,
        left: Box::new(left),
        right: Box::new(right),
    }
}

/// `a + k` for a constant `k`, folded when `a` is a constant.
fn plus(a: &DaExpr, k: i64) -> DaExpr {
    if k == 0 {
        return a.clone();
    }
    match a {
        DaExpr::ConstInt(base) => DaExpr::ConstInt(base + k),
        DaExpr::Op2 { op: "+", left, right } => match &**right {
            DaExpr::ConstInt(c) => op2("+", (**left).clone(), DaExpr::ConstInt(c + k)),
            _ => op2("+", a.clone(), DaExpr::ConstInt(k)),
        },
        _ => op2("+", a.clone(), DaExpr::ConstInt(k)),
    }
}

fn byte_at(a: &DaExpr, k: i64) -> DaExpr {
    DaExpr::Index(Box::new(DaExpr::Var(MEM.into())), Box::new(plus(a, k)))
}

/// Little-endian assembly of `n` bytes at `a` into `uint` (n <= 4).
fn assemble32(a: &DaExpr, base: i64, n: i64) -> DaExpr {
    let mut acc = cast(DaType::uint(), byte_at(a, base));
    for k in 1..n {
        let b = op2(
            "<<",
            cast(DaType::uint(), byte_at(a, base + k)),
            DaExpr::ConstUInt((8 * k) as u64),
        );
        acc = op2("|", acc, b);
    }
    acc
}

/// The value of a scalar of kind `s` at the stable address `a`.
fn load(s: Scalar, a: &DaExpr) -> DaExpr {
    match s {
        Scalar::U8 => byte_at(a, 0),
        Scalar::I8 => cast(DaType::int8(), byte_at(a, 0)),
        Scalar::Bool => op2("!=", byte_at(a, 0), cast(DaType::uint8(), DaExpr::ConstInt(0))),
        Scalar::U16 => cast(DaType::uint16(), assemble32(a, 0, 2)),
        Scalar::I16 => cast(DaType::int16(), assemble32(a, 0, 2)),
        Scalar::U32 => assemble32(a, 0, 4),
        Scalar::I32 | Scalar::Ptr => cast(DaType::int(), assemble32(a, 0, 4)),
        Scalar::F32 => DaExpr::Call(
            Box::new(DaExpr::Var("uint_bits_to_float".into())),
            vec![assemble32(a, 0, 4)],
        ),
        Scalar::U64 | Scalar::I64 | Scalar::F64 => {
            let bits = op2(
                "|",
                cast(DaType::uint64(), assemble32(a, 0, 4)),
                op2(
                    "<<",
                    cast(DaType::uint64(), assemble32(a, 4, 4)),
                    DaExpr::ConstUInt(32),
                ),
            );
            match s {
                Scalar::U64 => bits,
                Scalar::I64 => cast(DaType::int64(), bits),
                _ => DaExpr::Call(
                    Box::new(DaExpr::Var("uint64_bits_to_double".into())),
                    vec![bits],
                ),
            }
        }
    }
}

/// The statements that store the stable value `v` of kind `s` at the
/// stable address `a`.
fn store(s: Scalar, a: &DaExpr, v: &DaExpr, fresh: &mut dyn FnMut() -> String) -> Vec<DaStmt> {
    let set = |k: i64, byte: DaExpr| {
        DaStmt::Expr(DaExpr::Assign(Box::new(byte_at(a, k)), Box::new(byte)))
    };
    let u8_of = |e: DaExpr| cast(DaType::uint8(), e);
    match s {
        Scalar::U8 => vec![set(0, v.clone())],
        Scalar::I8 => vec![set(0, u8_of(v.clone()))],
        Scalar::Bool => vec![set(
            0,
            DaExpr::Op3 {
                cond: Box::new(v.clone()),
                then: Box::new(u8_of(DaExpr::ConstInt(1))),
                else_: Box::new(u8_of(DaExpr::ConstInt(0))),
            },
        )],
        _ => {
            let (bits_ty, bits, n) = match s {
                Scalar::U16 | Scalar::I16 => (DaType::uint(), cast(DaType::uint(), v.clone()), 2),
                Scalar::U32 => (DaType::uint(), v.clone(), 4),
                Scalar::I32 | Scalar::Ptr => (DaType::uint(), cast(DaType::uint(), v.clone()), 4),
                Scalar::F32 => (
                    DaType::uint(),
                    DaExpr::Call(Box::new(DaExpr::Var("float_bits_to_uint".into())), vec![v.clone()]),
                    4,
                ),
                Scalar::U64 => (DaType::uint64(), v.clone(), 8),
                Scalar::I64 => (DaType::uint64(), cast(DaType::uint64(), v.clone()), 8),
                Scalar::F64 => (
                    DaType::uint64(),
                    DaExpr::Call(
                        Box::new(DaExpr::Var("double_bits_to_uint64".into())),
                        vec![v.clone()],
                    ),
                    8,
                ),
                _ => unreachable!(),
            };
            let name = fresh();
            let mut out = vec![DaStmt::Let {
                name: name.clone(),
                var_type: Some(bits_ty),
                init: Some(bits),
            }];
            for k in 0..n {
                let shifted = if k == 0 {
                    DaExpr::Var(name.clone())
                } else {
                    op2(">>", DaExpr::Var(name.clone()), DaExpr::ConstUInt((8 * k) as u64))
                };
                out.push(set(k, u8_of(shifted)));
            }
            if s == Scalar::Ptr {
                for k in 4..8 {
                    out.push(set(k, u8_of(DaExpr::ConstInt(0))));
                }
            }
            out
        }
    }
}

/// An address expression that may be written more than once.
fn is_stable(e: &DaExpr) -> bool {
    match e {
        DaExpr::Var(_) | DaExpr::ConstInt(_) => true,
        DaExpr::Op2 { op: "+" | "-" | "*", left, right } => is_stable(left) && is_stable(right),
        DaExpr::Cast { expr, .. } => is_stable(expr),
        _ => false,
    }
}

impl<'c> Translation<'c> {
    pub(crate) fn is_linear(&self) -> bool {
        self.tcfg.target.memory_model == MemoryModel::Linear
    }

    fn linear_refuse(&self, expr_id: CExprId, what: &str) -> TranslationError {
        format_translation_err!(
            self.ast_context.display_loc(&self.ast_context[expr_id].loc),
            "not supported under --memory-model linear yet: {what}"
        )
    }

    fn qual_of(&self, expr_id: CExprId) -> TranslationResult<CQualTypeId> {
        self.ast_context[expr_id]
            .kind
            .get_qual_type()
            .ok_or_else(|| TranslationError::generic("C expression has no type"))
    }

    /// The pointee of a data pointer type; `None` for anything else,
    /// including a pointer to a function.
    pub(crate) fn linear_pointee(&self, ty: CTypeId) -> Option<CQualTypeId> {
        match self.ast_context.resolve_type(ty).kind {
            CTypeKind::Pointer(inner) => {
                if matches!(
                    self.ast_context.resolve_type(inner.ctype).kind,
                    CTypeKind::Function(..)
                ) {
                    None
                } else {
                    Some(inner)
                }
            }
            _ => None,
        }
    }

    fn is_data_pointer(&self, ty: CTypeId) -> bool {
        self.linear_pointee(ty).is_some()
    }

    /// Clang's step for pointer arithmetic over `pointee` (`void *` steps by 1).
    fn step_size(&self, pointee: CQualTypeId) -> TranslationResult<i64> {
        if matches!(self.ast_context.resolve_type(pointee.ctype).kind, CTypeKind::Void) {
            return Ok(1);
        }
        self.sizeof_type(pointee.ctype)
    }

    fn scalar_of(&self, ty: CTypeId) -> Option<Scalar> {
        use CTypeKind::*;
        if self.is_data_pointer(ty) {
            return Some(Scalar::Ptr);
        }
        Some(match self.ast_context.resolve_type(ty).kind {
            Bool => Scalar::Bool,
            Int | Int32 => Scalar::I32,
            SChar | Char | Int8 => Scalar::I8,
            Short | Int16 => Scalar::I16,
            Int64 | Long | LongLong | IntPtr | SSize | PtrDiff | IntMax => Scalar::I64,
            UChar | UInt8 => Scalar::U8,
            UShort | UInt16 => Scalar::U16,
            UInt | UInt32 => Scalar::U32,
            UInt64 | ULong | ULongLong | UIntPtr | Size | WChar | UIntMax => Scalar::U64,
            Float => Scalar::F32,
            Double => Scalar::F64,
            _ => return None,
        })
    }

    /// A struct or array whose whole value is copied to or from the heap.
    fn is_aggregate(&self, ty: CTypeId) -> bool {
        matches!(
            self.ast_context.resolve_type(ty).kind,
            CTypeKind::Struct(_) | CTypeKind::Union(_) | CTypeKind::ConstantArray(..)
        )
    }

    /// The scalar leaves of an aggregate value: for each, its kind, its
    /// daScript place below `place`, and its byte offset from the start of
    /// the value (Clang's field offsets).  A union, a storage-backed record
    /// or a leaf with no heap form is refused at `at`.
    fn aggregate_leaves(
        &self,
        at: CExprId,
        ty: CTypeId,
        place: DaExpr,
        offset: i64,
        out: &mut Vec<(Scalar, DaExpr, i64)>,
    ) -> TranslationResult<()> {
        /// More leaves than this are refused rather than unrolled.
        const MAX_LEAVES: usize = 4096;
        if out.len() > MAX_LEAVES {
            return Err(self.linear_refuse(at, "a record or array value of more than 4096 scalars through a pointer"));
        }
        if let Some(s) = self.scalar_of(ty) {
            out.push((s, place, offset));
            return Ok(());
        }
        match self.ast_context.resolve_type(ty).kind {
            CTypeKind::Struct(record) if !self.is_storage_backed_record(record) => {
                let Some(members) = self.natural_members(record) else {
                    return Err(self.linear_refuse(at, "a record value with no natural layout through a pointer"));
                };
                for member in members {
                    match member {
                        NaturalMember::Field(fid) => {
                            let CDeclKind::Field { typ, .. } = &self.ast_context[fid].kind else {
                                return Err(TranslationError::generic("C record member is not a field"));
                            };
                            let name = self.natural_field_name(record, fid).ok_or_else(|| {
                                TranslationError::generic("record field name not declared yet")
                            })?;
                            let field = DaExpr::Field(Box::new(place.clone()), name);
                            self.aggregate_leaves(at, typ.ctype, field, offset + self.field_offset(fid)?, out)?;
                        }
                        // A bitfield of a daScript record value is itself
                        // still raw-memory lowered under the model.
                        NaturalMember::BitfieldUnit { .. } => {
                            return Err(self.linear_refuse(at, "a record value with bitfields through a pointer"));
                        }
                    }
                }
                Ok(())
            }
            CTypeKind::ConstantArray(elem, n) => {
                let size = self.sizeof_type(elem)?;
                for i in 0..n {
                    let item = DaExpr::Index(Box::new(place.clone()), Box::new(DaExpr::ConstInt(i as i64)));
                    self.aggregate_leaves(at, elem, item, offset + i as i64 * size, out)?;
                }
                Ok(())
            }
            _ => Err(self.linear_refuse(
                at,
                "a value of this type through a pointer (unions, enumerations and function pointers in the heap are read field by field only)",
            )),
        }
    }

    /// The whole aggregate at the stable heap address `a`, read into a
    /// fresh daScript value field by field.
    fn load_aggregate(&self, at: CExprId, ty: CQualTypeId, a: &DaExpr) -> TranslationResult<WithStmts<DaExpr>> {
        let name = self.fresh_name();
        let mut leaves = vec![];
        self.aggregate_leaves(at, ty.ctype, DaExpr::Var(name.clone()), 0, &mut leaves)?;
        let mut stmts = vec![DaStmt::Var {
            name: name.clone(),
            var_type: self.convert_type(ty)?,
            init: None,
        }];
        for (s, place, off) in leaves {
            stmts.push(DaStmt::Expr(DaExpr::Assign(Box::new(place), Box::new(load(s, &plus(a, off))))));
        }
        Ok(WithStmts::new(stmts, DaExpr::Var(name)))
    }

    /// Stores the aggregate `value` (a daScript value) at the stable heap
    /// address `a` field by field; the expression is the stored value.
    fn store_aggregate(
        &self,
        at: CExprId,
        ty: CQualTypeId,
        a: &DaExpr,
        value: WithStmts<DaExpr>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let (mut stmts, v) = value.into_stmts_and_val();
        let v = match v {
            DaExpr::Var(_) => v,
            other => {
                let name = self.fresh_name();
                stmts.push(DaStmt::Var {
                    name: name.clone(),
                    var_type: self.convert_type(ty)?,
                    init: Some(other),
                });
                DaExpr::Var(name)
            }
        };
        let mut leaves = vec![];
        self.aggregate_leaves(at, ty.ctype, v.clone(), 0, &mut leaves)?;
        let mut fresh = || self.fresh_name();
        for (s, place, off) in leaves {
            stmts.extend(store(s, &plus(a, off), &place, &mut fresh));
        }
        Ok(WithStmts::new(stmts, v))
    }

    /// The heap address of `expr_id` when it is an lvalue-to-rvalue read of
    /// a heap place (parentheses stripped).
    fn heap_read_source(&self, ctx: ExprContext, expr_id: CExprId) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        let mut e = expr_id;
        loop {
            match &self.ast_context[e].kind {
                CExprKind::Paren(_, inner) => e = *inner,
                CExprKind::ImplicitCast(_, inner, CastKind::LValueToRValue, _, _) => {
                    return self.heap_place(ctx, *inner);
                }
                _ => return Ok(None),
            }
        }
    }

    fn scalar_or_refuse(&self, expr_id: CExprId, ty: CTypeId) -> TranslationResult<Scalar> {
        self.scalar_of(ty).ok_or_else(|| {
            self.linear_refuse(
                expr_id,
                "a value of this type through a pointer (records, arrays, enumerations and function pointers in the heap are read field by field only)",
            )
        })
    }

    /// Binds `value` to a fresh `let` unless it may be repeated.
    fn stable(&self, value: WithStmts<DaExpr>, ty: DaType) -> WithStmts<DaExpr> {
        if is_stable(&value.val) {
            return value;
        }
        let name = self.renamer.borrow_mut().fresh();
        let (mut stmts, val) = value.into_stmts_and_val();
        stmts.push(DaStmt::Let {
            name: name.clone(),
            var_type: Some(ty),
            init: Some(val),
        });
        WithStmts::new(stmts, DaExpr::Var(name))
    }

    fn fresh_name(&self) -> String {
        self.renamer.borrow_mut().fresh()
    }

    /// `int(e)` unless `e` already is an `int`.
    fn as_int(e: DaExpr) -> DaExpr {
        match &e {
            DaExpr::ConstInt(v) if *v >= i32::MIN as i64 && *v <= i32::MAX as i64 => e,
            _ => match Self::infer_type(&e) {
                Some(t) if matches!(t.kind, DaTypeKind::Int) => e,
                _ => cast(DaType::int(), e),
            },
        }
    }

    /// `base + index * size` with constant folding.
    fn offset_by(base: DaExpr, index: DaExpr, size: i64, negate: bool) -> DaExpr {
        let index = Self::as_int(index);
        let scaled = match index {
            DaExpr::ConstInt(i) => DaExpr::ConstInt(i * size),
            other if size == 1 => other,
            other => op2("*", other, DaExpr::ConstInt(size)),
        };
        match (scaled, negate) {
            (DaExpr::ConstInt(k), false) => plus(&base, k),
            (DaExpr::ConstInt(k), true) => plus(&base, -k),
            (s, false) => op2("+", base, s),
            (s, true) => op2("-", base, s),
        }
    }

    /// The address of a C lvalue that lives in linear memory, or `None` for
    /// an lvalue that is a daScript variable (a local, a global, a field of
    /// one).
    fn heap_place(
        &self,
        ctx: ExprContext,
        expr_id: CExprId,
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        use CExprKind::*;
        match &self.ast_context[expr_id].kind {
            Paren(_, inner) => self.heap_place(ctx, *inner),
            Unary(_, CUnOp::Deref, ptr, _) => {
                let ptr_ty = self.qual_of(*ptr)?;
                if !self.is_data_pointer(ptr_ty.ctype) {
                    return Ok(None);
                }
                Ok(Some(self.convert_expr(ctx.used(), *ptr, None)?))
            }
            ArraySubscript(_, lhs, rhs, _) => {
                let (lhs, rhs) = (*lhs, *rhs);
                let (ptr, idx) = if self.is_data_pointer(self.qual_of(lhs)?.ctype) {
                    (lhs, rhs)
                } else if self.is_data_pointer(self.qual_of(rhs)?.ctype) {
                    (rhs, lhs)
                } else {
                    return Ok(None);
                };
                let pointee = self.linear_pointee(self.qual_of(ptr)?.ctype).unwrap();
                let size = self.step_size(pointee)?;
                // A declared array decays to its address: it is in the heap
                // only when the array itself is (a field array through a
                // pointer, a string literal).
                let base = match self.decayed_array(ptr) {
                    Some(array) => match self.array_address(ctx, array)? {
                        Some(address) => address,
                        None => return Ok(None),
                    },
                    None => self.convert_expr(ctx.used(), ptr, None)?,
                };
                let index = self.convert_expr(ctx.used(), idx, None)?;
                Ok(Some(base.zip(index).map(|(b, i)| Self::offset_by(b, i, size, false))))
            }
            Member(_, base, field, kind, _) => {
                let base_address = match kind {
                    MemberKind::Arrow => self.convert_expr(ctx.used(), *base, None)?,
                    MemberKind::Dot => match self.heap_place(ctx, *base)? {
                        Some(address) => address,
                        None => return Ok(None),
                    },
                };
                if let CDeclKind::Field {
                    bitfield_width: Some(_),
                    ..
                } = self.ast_context[*field].kind
                {
                    return Err(self.linear_refuse(expr_id, "a bitfield through a pointer"));
                }
                let offset = self.field_offset(*field)?;
                Ok(Some(base_address.map(|b| plus(&b, offset))))
            }
            _ => Ok(None),
        }
    }

    /// `a[i]` over a declared array that is a daScript value (a local, a
    /// global, a field of one): plain daScript indexing, the decay never
    /// becomes an address.  `None` for anything else.
    fn linear_daslang_index(
        &self,
        ctx: ExprContext,
        expr_id: CExprId,
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        let CExprKind::ArraySubscript(_, lhs, rhs, _) = self.ast_context[expr_id].kind else {
            return Ok(None);
        };
        let (array, idx) = match (self.decayed_array(lhs), self.decayed_array(rhs)) {
            (Some(array), _) => (array, rhs),
            (None, Some(array)) => (array, lhs),
            _ => return Ok(None),
        };
        if matches!(self.ast_context[array].kind, CExprKind::Literal(..)) {
            return Ok(None);
        }
        let base = self.convert_expr(ctx.used(), array, None)?;
        let index = self.convert_expr(ctx.used(), idx, None)?;
        Ok(Some(base.zip(index).map(|(b, i)| {
            DaExpr::Index(Box::new(b), Box::new(Self::as_int(i)))
        })))
    }

    /// The array operand of an array-to-pointer decay, parentheses stripped.
    fn decayed_array(&self, expr_id: CExprId) -> Option<CExprId> {
        let mut e = expr_id;
        loop {
            match &self.ast_context[e].kind {
                CExprKind::Paren(_, inner) => e = *inner,
                CExprKind::ImplicitCast(_, inner, CastKind::ArrayToPointerDecay, _, _) => {
                    let mut a = *inner;
                    while let CExprKind::Paren(_, i) = &self.ast_context[a].kind {
                        a = *i;
                    }
                    return Some(a);
                }
                _ => return None,
            }
        }
    }

    /// The heap address of an array object: a string literal's static
    /// offset, or an array that is itself a heap place.
    fn array_address(
        &self,
        ctx: ExprContext,
        array: CExprId,
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        if let CExprKind::Literal(_, CLiteral::String(bytes, width)) = &self.ast_context[array].kind {
            if *width != 1 {
                return Err(self.linear_refuse(array, "a wide string literal"));
            }
            let mut bytes = bytes.clone();
            // Clang's literal may carry its array extent; C adds the NUL.
            let ty = self.qual_of(array)?;
            let size = match self.ast_context.resolve_type(ty.ctype).kind {
                CTypeKind::ConstantArray(_, n) => n,
                _ => bytes.len() + 1,
            };
            bytes.resize(size.max(bytes.len() + 1), 0);
            return Ok(Some(WithStmts::new_val(DaExpr::ConstInt(intern(bytes)))));
        }
        self.heap_place(ctx, array)
    }

    /// The `--memory-model linear` form of `expr_id`, or `None` when the
    /// ordinary lowering is the linear one too (no pointer involved).
    pub(crate) fn linear_expr(
        &self,
        ctx: ExprContext,
        expr_id: CExprId,
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        use CExprKind::*;
        let kind = self.ast_context[expr_id].kind.clone();
        match kind {
            Unary(ty, CUnOp::Deref, ..) | ArraySubscript(ty, ..) | Member(ty, ..) => {
                let Some(address) = self.heap_place(ctx, expr_id)? else {
                    return self.linear_daslang_index(ctx, expr_id);
                };
                if self.is_aggregate(ty.ctype) {
                    let (mut stmts, a) = self.stable(address, DaType::int()).into_stmts_and_val();
                    let value = self.load_aggregate(expr_id, ty, &a)?;
                    let (vstmts, v) = value.into_stmts_and_val();
                    stmts.extend(vstmts);
                    return Ok(Some(WithStmts::new(stmts, v)));
                }
                let s = self.scalar_or_refuse(expr_id, ty.ctype)?;
                let address = self.stable(address, DaType::int());
                Ok(Some(address.map(|a| load(s, &a))))
            }
            ImplicitCast(ty, inner, ck, _, _) | ExplicitCast(ty, inner, ck, _, _) => {
                self.linear_cast(ctx, expr_id, ty, inner, ck)
            }
            Unary(_, CUnOp::AddressOf, arg, _) => {
                let arg_ty = self.qual_of(arg)?;
                if matches!(
                    self.ast_context.resolve_type(arg_ty.ctype).kind,
                    CTypeKind::Function(..)
                ) {
                    return Ok(None);
                }
                match self.heap_place(ctx, arg)? {
                    Some(address) => Ok(Some(address)),
                    None => match self.array_address(ctx, arg)? {
                        Some(address) => Ok(Some(address)),
                        None => Err(self.linear_refuse(
                            expr_id,
                            "the address of a local or global object (step 4, --locals-in-heap)",
                        )),
                    },
                }
            }
            // `++`/`--` and binary operators: `operators.rs` calls
            // `linear_incdec` / `linear_binary` itself, so a condition or a
            // `for` step that converts them directly is covered too.
            Call(_, func, args) => self.linear_call(ctx, expr_id, func, &args),
            Literal(_, CLiteral::String(..)) => Ok(None),
            _ => Ok(None),
        }
    }

    fn linear_cast(
        &self,
        ctx: ExprContext,
        expr_id: CExprId,
        ty: CQualTypeId,
        inner: CExprId,
        ck: CastKind,
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        let to_ptr = self.is_data_pointer(ty.ctype);
        let inner_ty = self.qual_of(inner)?;
        let from_ptr = self.is_data_pointer(inner_ty.ctype);
        match ck {
            CastKind::NullToPointer if to_ptr => {
                // Side effects of a null pointer constant are impossible.
                Ok(Some(WithStmts::new_val(DaExpr::ConstInt(0))))
            }
            CastKind::LValueToRValue => {
                let Some(address) = self.heap_place(ctx, inner)? else {
                    return Ok(None);
                };
                if self.is_aggregate(ty.ctype) {
                    let (mut stmts, a) = self.stable(address, DaType::int()).into_stmts_and_val();
                    let (vstmts, v) = self.load_aggregate(expr_id, ty, &a)?.into_stmts_and_val();
                    stmts.extend(vstmts);
                    return Ok(Some(WithStmts::new(stmts, v)));
                }
                let s = self.scalar_or_refuse(expr_id, ty.ctype)?;
                let address = self.stable(address, DaType::int());
                Ok(Some(address.map(|a| load(s, &a))))
            }
            CastKind::ArrayToPointerDecay => {
                let mut array = inner;
                while let CExprKind::Paren(_, i) = &self.ast_context[array].kind {
                    array = *i;
                }
                match self.array_address(ctx, array)? {
                    Some(address) => Ok(Some(address)),
                    None => Err(self.linear_refuse(
                        expr_id,
                        "a declared array used as a pointer (step 4, --locals-in-heap)",
                    )),
                }
            }
            CastKind::BitCast | CastKind::NoOp | CastKind::ConstCast if to_ptr || from_ptr => {
                if to_ptr && from_ptr {
                    Ok(Some(self.convert_expr(ctx.used(), inner, None)?))
                } else if matches!(ck, CastKind::NoOp | CastKind::ConstCast) {
                    Ok(None)
                } else {
                    Err(self.linear_refuse(expr_id, "a cast between a data pointer and a function pointer"))
                }
            }
            CastKind::PointerToIntegral if from_ptr => {
                let to = self.convert_type(ty)?;
                Ok(Some(self.convert_expr(ctx.used(), inner, None)?.map(|v| cast(to, v))))
            }
            CastKind::IntegralToPointer if to_ptr => {
                Ok(Some(self.convert_expr(ctx.used(), inner, None)?.map(|v| cast(DaType::int(), v))))
            }
            CastKind::PointerToBoolean if from_ptr => Ok(Some(
                self.convert_expr(ctx.used(), inner, None)?
                    .map(|v| op2("!=", v, DaExpr::ConstInt(0))),
            )),
            _ if to_ptr || from_ptr => {
                if matches!(ck, CastKind::FunctionToPointerDecay | CastKind::BuiltinFnToFnPtr) {
                    return Ok(None);
                }
                Err(self.linear_refuse(expr_id, &format!("pointer cast {ck:?}")))
            }
            _ => Ok(None),
        }
    }

    /// The new value of `old` after C's `op` with the converted right operand.
    fn arith(
        &self,
        op: CBinOp,
        old: DaExpr,
        rhs: DaExpr,
        result: DaType,
        compute: DaType,
    ) -> TranslationResult<DaExpr> {
        let das_op: &'static str = match op {
            CBinOp::AssignAdd | CBinOp::Add => "+",
            CBinOp::AssignSubtract | CBinOp::Subtract => "-",
            CBinOp::AssignMultiply => "*",
            CBinOp::AssignDivide => "/",
            CBinOp::AssignModulus => "%",
            CBinOp::AssignBitXor => "^",
            CBinOp::AssignBitOr => "|",
            CBinOp::AssignBitAnd => "&",
            CBinOp::AssignShiftLeft => "<<",
            CBinOp::AssignShiftRight => ">>",
            _ => return Err(TranslationError::generic("not an arithmetic compound operator")),
        };
        let same = result == compute;
        let left = if same { old } else { cast(compute.clone(), old) };
        let value = op2(das_op, left, cast(compute.clone(), rhs));
        Ok(if same { value } else { cast(result, value) })
    }

    #[allow(clippy::too_many_arguments)]
    pub(crate) fn linear_binary(
        &self,
        ctx: ExprContext,
        expr_id: CExprId,
        ty: CQualTypeId,
        op: CBinOp,
        lhs: CExprId,
        rhs: CExprId,
        lty: Option<CQualTypeId>,
        _rty: Option<CQualTypeId>,
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        let lhs_ty = self.qual_of(lhs)?;
        let rhs_ty = self.qual_of(rhs)?;
        let lp = self.is_data_pointer(lhs_ty.ctype);
        let rp = self.is_data_pointer(rhs_ty.ctype);
        match op {
            CBinOp::Assign => {
                let Some(address) = self.heap_place(ctx, lhs)? else {
                    return Ok(None);
                };
                if self.is_aggregate(lhs_ty.ctype) {
                    let (mut stmts, a) = self.stable(address, DaType::int()).into_stmts_and_val();
                    // Heap to heap: one byte copy (memmove: C allows the
                    // exact overlap of `*p = *p`).
                    if let Some(source) = self.heap_read_source(ctx, rhs)? {
                        let (sstmts, src) = source.into_stmts_and_val();
                        stmts.extend(sstmts);
                        let size = self.sizeof_type(lhs_ty.ctype)?;
                        let copy = DaExpr::Call(
                            Box::new(DaExpr::Var("c2da_lin_memmove".into())),
                            vec![a.clone(), src, cast(DaType::uint64(), DaExpr::ConstInt(size))],
                        );
                        if !ctx.is_used() {
                            return Ok(Some(WithStmts::new(stmts, copy)));
                        }
                        stmts.push(DaStmt::Expr(copy));
                        let (vstmts, v) = self.load_aggregate(expr_id, lhs_ty, &a)?.into_stmts_and_val();
                        stmts.extend(vstmts);
                        return Ok(Some(WithStmts::new(stmts, v)));
                    }
                    let value = self.convert_expr(ctx.used(), rhs, Some(lhs_ty))?;
                    let (vstmts, v) = self.store_aggregate(expr_id, lhs_ty, &a, value)?.into_stmts_and_val();
                    stmts.extend(vstmts);
                    return Ok(Some(WithStmts::new(stmts, v)));
                }
                let s = self.scalar_or_refuse(lhs, lhs_ty.ctype)?;
                let address = self.stable(address, DaType::int());
                let value = self.convert_expr(ctx.used(), rhs, Some(lhs_ty))?;
                let value = self.force_temp(value, s.da_type());
                Ok(Some(self.emit_store(s, address, value)))
            }
            CBinOp::AssignAdd | CBinOp::AssignSubtract if lp => {
                let pointee = self.linear_pointee(lhs_ty.ctype).unwrap();
                let size = self.step_size(pointee)?;
                let negate = op == CBinOp::AssignSubtract;
                if let Some(address) = self.heap_place(ctx, lhs)? {
                    let address = self.stable(address, DaType::int());
                    let n = self.convert_expr(ctx.used(), rhs, None)?;
                    let new = address
                        .zip(n)
                        .map(|(a, n)| (Self::offset_by(load(Scalar::Ptr, &a), n, size, negate), a));
                    let (stmts, (new, a)) = new.into_stmts_and_val();
                    let value = self.force_temp(WithStmts::new(stmts, new), DaType::int());
                    return Ok(Some(self.emit_store(Scalar::Ptr, WithStmts::new_val(a), value)));
                }
                let place = self.convert_expr(ctx.used(), lhs, None)?;
                let n = self.convert_expr(ctx.used(), rhs, None)?;
                Ok(Some(place.zip(n).map(|(p, n)| {
                    let new = Self::offset_by(p.clone(), n, size, negate);
                    DaExpr::Assign(Box::new(p), Box::new(new))
                })))
            }
            CBinOp::AssignAdd
            | CBinOp::AssignSubtract
            | CBinOp::AssignMultiply
            | CBinOp::AssignDivide
            | CBinOp::AssignModulus
            | CBinOp::AssignBitXor
            | CBinOp::AssignBitOr
            | CBinOp::AssignBitAnd
            | CBinOp::AssignShiftLeft
            | CBinOp::AssignShiftRight => {
                let Some(address) = self.heap_place(ctx, lhs)? else {
                    return Ok(None);
                };
                let s = self.scalar_or_refuse(lhs, lhs_ty.ctype)?;
                if matches!(s, Scalar::Bool) {
                    return Err(self.linear_refuse(expr_id, "compound assignment to a `_Bool` in the heap"));
                }
                let compute = match lty {
                    Some(t) => self.convert_type(t)?,
                    None => s.da_type(),
                };
                let address = self.stable(address, DaType::int());
                let n = self.convert_expr(ctx.used(), rhs, None)?;
                let combined = address.zip(n);
                let (stmts, (a, n)) = combined.into_stmts_and_val();
                let new = self.arith(op, load(s, &a), n, s.da_type(), compute)?;
                let value = self.force_temp(WithStmts::new(stmts, new), s.da_type());
                Ok(Some(self.emit_store(s, WithStmts::new_val(a), value)))
            }
            CBinOp::Add | CBinOp::Subtract if lp || rp => {
                if lp && rp {
                    // Pointer difference: element count, `ptrdiff_t`.
                    let pointee = self.linear_pointee(lhs_ty.ctype).unwrap();
                    let size = self.step_size(pointee)?;
                    let l = self.convert_expr(ctx.used(), lhs, None)?;
                    let r = self.convert_expr(ctx.used(), rhs, None)?;
                    let to = self.convert_type(ty)?;
                    return Ok(Some(l.zip(r).map(|(l, r)| {
                        let diff = op2("-", l, r);
                        let diff = if size == 1 { diff } else { op2("/", diff, DaExpr::ConstInt(size)) };
                        cast(to, diff)
                    })));
                }
                let (ptr, idx, ptr_ty) = if lp { (lhs, rhs, lhs_ty) } else { (rhs, lhs, rhs_ty) };
                let pointee = self.linear_pointee(ptr_ty.ctype).unwrap();
                let size = self.step_size(pointee)?;
                let p = self.convert_expr(ctx.used(), ptr, None)?;
                let i = self.convert_expr(ctx.used(), idx, None)?;
                let negate = op == CBinOp::Subtract;
                Ok(Some(p.zip(i).map(|(p, i)| Self::offset_by(p, i, size, negate))))
            }
            CBinOp::Less
            | CBinOp::Greater
            | CBinOp::LessEqual
            | CBinOp::GreaterEqual
            | CBinOp::EqualEqual
            | CBinOp::NotEqual
                if lp || rp =>
            {
                let das_op: &'static str = match op {
                    CBinOp::Less => "<",
                    CBinOp::Greater => ">",
                    CBinOp::LessEqual => "<=",
                    CBinOp::GreaterEqual => ">=",
                    CBinOp::EqualEqual => "==",
                    _ => "!=",
                };
                let l = self.convert_expr(ctx.used(), lhs, None)?;
                let r = self.convert_expr(ctx.used(), rhs, None)?;
                // A `bool`, as `convert_binary_expr` answers any comparison;
                // its callers lower it to C's `int` where one is needed.
                let _ = ty;
                Ok(Some(l.zip(r).map(|(l, r)| op2(das_op, l, r))))
            }
            _ => Ok(None),
        }
    }

    /// Binds a value to a fresh `let` (always: the store and the C value of
    /// the assignment both read it).
    fn force_temp(&self, value: WithStmts<DaExpr>, ty: DaType) -> WithStmts<DaExpr> {
        if matches!(value.val, DaExpr::Var(_) | DaExpr::ConstInt(_)) {
            return value;
        }
        let name = self.fresh_name();
        let (mut stmts, val) = value.into_stmts_and_val();
        stmts.push(DaStmt::Let {
            name: name.clone(),
            var_type: Some(ty),
            init: Some(val),
        });
        WithStmts::new(stmts, DaExpr::Var(name))
    }

    /// The stores of `value` at `address`; the expression is the stored value.
    fn emit_store(
        &self,
        s: Scalar,
        address: WithStmts<DaExpr>,
        value: WithStmts<DaExpr>,
    ) -> WithStmts<DaExpr> {
        let (mut stmts, a) = address.into_stmts_and_val();
        let (vstmts, v) = value.into_stmts_and_val();
        stmts.extend(vstmts);
        let mut fresh = || self.fresh_name();
        stmts.extend(store(s, &a, &v, &mut fresh));
        WithStmts::new(stmts, v)
    }

    pub(crate) fn linear_incdec(
        &self,
        ctx: ExprContext,
        expr_id: CExprId,
        _ty: CQualTypeId,
        op: CUnOp,
        arg: CExprId,
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        let arg_ty = self.qual_of(arg)?;
        let is_ptr = self.is_data_pointer(arg_ty.ctype);
        let inc = matches!(op, CUnOp::PreIncrement | CUnOp::PostIncrement);
        let pre = matches!(op, CUnOp::PreIncrement | CUnOp::PreDecrement);
        let das_op: &'static str = if inc { "+" } else { "-" };
        let heap = self.heap_place(ctx, arg)?;
        if heap.is_none() && !is_ptr {
            return Ok(None);
        }
        let s = self.scalar_or_refuse(arg, arg_ty.ctype)?;
        let ty = s.da_type();
        let step = |old: DaExpr| -> TranslationResult<DaExpr> {
            Ok(match s {
                Scalar::Ptr => {
                    let size = self.step_size(self.linear_pointee(arg_ty.ctype).unwrap())?;
                    op2(das_op, old, DaExpr::ConstInt(size))
                }
                Scalar::I8 | Scalar::U8 | Scalar::I16 | Scalar::U16 => cast(
                    ty.clone(),
                    op2(das_op, cast(DaType::int(), old), DaExpr::ConstInt(1)),
                ),
                Scalar::I32 => op2(das_op, old, DaExpr::ConstInt(1)),
                Scalar::Bool => return Err(self.linear_refuse(expr_id, "`++`/`--` on a `_Bool`")),
                _ => op2(das_op, old, cast(ty.clone(), DaExpr::ConstInt(1))),
            })
        };
        match heap {
            Some(address) => {
                let address = self.stable(address, DaType::int());
                let (stmts, a) = address.into_stmts_and_val();
                let old = self.force_temp(WithStmts::new(stmts, load(s, &a)), ty.clone());
                let (stmts, old) = old.into_stmts_and_val();
                let new = self.force_temp(WithStmts::new(stmts, step(old.clone())?), ty.clone());
                let stored = self.emit_store(s, WithStmts::new_val(a), new);
                Ok(Some(if pre { stored } else { stored.map(|_| old) }))
            }
            None => {
                // A pointer variable: integer arithmetic on its offset.
                let place = self.convert_expr(ctx.used(), arg, None)?;
                let (mut stmts, p) = place.into_stmts_and_val();
                if !matches!(p, DaExpr::Var(_)) {
                    return Err(self.linear_refuse(expr_id, "`++`/`--` on this pointer lvalue"));
                }
                if pre {
                    stmts.push(DaStmt::Expr(DaExpr::Assign(Box::new(p.clone()), Box::new(step(p.clone())?))));
                    return Ok(Some(WithStmts::new(stmts, p)));
                }
                let old = self.fresh_name();
                stmts.push(DaStmt::Let {
                    name: old.clone(),
                    var_type: Some(DaType::int()),
                    init: Some(p.clone()),
                });
                stmts.push(DaStmt::Expr(DaExpr::Assign(Box::new(p.clone()), Box::new(step(p)?))));
                Ok(Some(WithStmts::new(stmts, DaExpr::Var(old))))
            }
        }
    }

    fn callee_name(&self, func: CExprId) -> Option<(String, bool)> {
        let mut e = func;
        loop {
            match &self.ast_context[e].kind {
                CExprKind::Paren(_, i) | CExprKind::ImplicitCast(_, i, _, _, _) => e = *i,
                CExprKind::DeclRef(_, decl, _) => {
                    return match &self.ast_context[*decl].kind {
                        CDeclKind::Function { name, body, .. } => Some((name.clone(), body.is_some())),
                        _ => None,
                    };
                }
                _ => return None,
            }
        }
    }

    fn is_string_literal_arg(&self, arg: CExprId) -> bool {
        matches!(
            self.decayed_array(arg).map(|a| &self.ast_context[a].kind),
            Some(CExprKind::Literal(_, CLiteral::String(..)))
        )
    }

    fn linear_call(
        &self,
        ctx: ExprContext,
        expr_id: CExprId,
        func: CExprId,
        args: &[CExprId],
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        let Some((name, has_body)) = self.callee_name(func) else {
            return Ok(None);
        };
        if has_body {
            return Ok(None);
        }
        let base = name.strip_prefix("__builtin_").unwrap_or(&name);
        // (runtime function, argument types: `I` int, `U` uint64)
        let sig: Option<(&str, &str)> = match base {
            "malloc" => Some(("c2da_lin_malloc", "U")),
            "calloc" => Some(("c2da_lin_calloc", "UU")),
            "realloc" => Some(("c2da_lin_realloc", "IU")),
            "free" => Some(("c2da_lin_free", "I")),
            "memcpy" => Some(("c2da_lin_memcpy", "IIU")),
            "memmove" => Some(("c2da_lin_memmove", "IIU")),
            "memset" => Some(("c2da_lin_memset", "IIU")),
            "memcmp" => Some(("c2da_lin_memcmp", "IIU")),
            "strlen" => Some(("c2da_lin_strlen", "I")),
            "strchr" => Some(("c2da_lin_strchr", "II")),
            "strrchr" => Some(("c2da_lin_strrchr", "II")),
            "strcmp" => Some(("c2da_lin_strcmp", "II")),
            "strncmp" => Some(("c2da_lin_strncmp", "IIU")),
            "strcpy" => Some(("c2da_lin_strcpy", "II")),
            "strncpy" => Some(("c2da_lin_strncpy", "IIU")),
            "strcat" => Some(("c2da_lin_strcat", "II")),
            "strstr" => Some(("c2da_lin_strstr", "II")),
            _ => None,
        };
        if let Some((runtime, types)) = sig {
            if args.len() != types.len() {
                return Err(self.linear_refuse(expr_id, &format!("`{name}` with {} arguments", args.len())));
            }
            let mut out = WithStmts::new_val(Vec::new());
            for (arg, t) in args.iter().zip(types.chars()) {
                let v = self.convert_expr(ctx.used(), *arg, None)?;
                let t = if t == 'I' { DaType::int() } else { DaType::uint64() };
                out = out.zip(v).map(|(mut list, v)| {
                    list.push(if Self::infer_type(&v).as_ref() == Some(&t) { v } else { cast(t, v) });
                    list
                });
            }
            return Ok(Some(out.map(|list| {
                DaExpr::Call(Box::new(DaExpr::Var(runtime.into())), list)
            })));
        }
        // Any other library function that takes or returns C memory would
        // read it through the raw-pointer prelude.  A string literal passed
        // as a format or a text stays the libc lowering's own business.
        let ret_ptr = self
            .qual_of(expr_id)
            .map(|t| self.is_data_pointer(t.ctype))
            .unwrap_or(false);
        let ptr_arg = args.iter().any(|a| {
            self.qual_of(*a)
                .map(|t| self.is_data_pointer(t.ctype))
                .unwrap_or(false)
                && !self.is_string_literal_arg(*a)
        });
        if ret_ptr || ptr_arg {
            return Err(self.linear_refuse(
                expr_id,
                &format!("library function `{name}` over C memory"),
            ));
        }
        Ok(None)
    }
}

/// Drops the raw-memory runtime prelude (`c2da_rt_*`, which every module
/// carries) unless a declaration of the module still names it; a helper that
/// stays is then refused by `target_check.rs check_linear` if it is raw.
pub fn prune_raw_runtime(decls: &mut Vec<DaDecl>) {
    fn name(decl: &DaDecl) -> Option<&str> {
        match decl {
            DaDecl::Function(f) => Some(&f.name),
            DaDecl::Variable(v) => Some(&v.name),
            DaDecl::Private(inner) => name(inner),
            _ => None,
        }
    }
    let is_raw = |d: &DaDecl| name(d).map_or(false, |n| n.starts_with("c2da_rt_"));
    let mut keep: Vec<bool> = decls.iter().map(|d| !is_raw(d)).collect();
    let mut text: String = decls
        .iter()
        .zip(&keep)
        .filter(|(_, k)| **k)
        .map(|(d, _)| d.to_string())
        .collect();
    loop {
        let mut changed = false;
        for (i, decl) in decls.iter().enumerate() {
            if keep[i] {
                continue;
            }
            let n = name(decl).unwrap();
            let used = text.match_indices(n).any(|(at, _)| {
                !text[at + n.len()..]
                    .chars()
                    .next()
                    .map_or(false, |c| c.is_alphanumeric() || c == '_')
            });
            if used {
                keep[i] = true;
                text.push_str(&decl.to_string());
                changed = true;
            }
        }
        if !changed {
            break;
        }
    }
    let mut i = 0;
    decls.retain(|_| {
        i += 1;
        keep[i - 1]
    });
}

/// The `c2da_lin_*` runtime and the static block, appended to a linear
/// module's text.  `reserve` is the heap capacity in bytes: the heap is
/// reserved at that size before any `resize`, so daslang's
/// `max_unreserved_size` panic cannot trigger, and an allocation past it
/// answers C NULL.
pub fn runtime_source(reserve: u64) -> String {
    let bytes = STATIC.with(|s| s.borrow().0.clone());
    let mut init = String::new();
    let n = bytes.len();
    if n > RESERVED {
        let list: Vec<String> = bytes[RESERVED..].iter().map(|b| format!("0x{b:x}")).collect();
        init.push_str(&format!(
            "let private c2da_lin_static = fixed_array<uint8>({})\n",
            list.join(", ")
        ));
    }
    let copy = if n > RESERVED {
        format!(
            "    for (i in range({})) {{\n        c2da_mem[{RESERVED} + i] = c2da_lin_static[i]\n    }}\n",
            n - RESERVED
        )
    } else {
        String::new()
    };
    let brk = (n + 15) & !15;
    format!(
        r#"
// --memory-model linear runtime: C memory is c2da_mem, an address is an int offset.
var c2da_mem : array<uint8>
var private c2da_lin_brk : int = 0
var private c2da_lin_free_list : int = 0
let private c2da_lin_limit : int64 = {reserve}l
{init}
[init]
def private c2da_lin_init() {{
    reserve(c2da_mem, c2da_lin_limit)
    resize(c2da_mem, {brk})
{copy}    c2da_lin_brk = {brk}
}}

def private c2da_lin_ld32(a : int) : int {{
    return int(uint(c2da_mem[a]) | (uint(c2da_mem[a + 1]) << 0x8) | (uint(c2da_mem[a + 2]) << 0x10) | (uint(c2da_mem[a + 3]) << 0x18))
}}

def private c2da_lin_st32(a : int; v : int) {{
    let u = uint(v)
    c2da_mem[a] = uint8(u)
    c2da_mem[a + 1] = uint8(u >> 0x8)
    c2da_mem[a + 2] = uint8(u >> 0x10)
    c2da_mem[a + 3] = uint8(u >> 0x18)
}}

// A block is a 16-byte header (capacity at -16) and a 16-byte aligned payload.
// A freed block's next link is its first 4 payload bytes; reuse is first fit.
def c2da_lin_malloc(n : uint64) : int {{
    if (n > uint64(0x7ffffff0)) {{
        return 0
    }}
    var cap = (int(n) + 15) & ~15
    if (cap == 0) {{
        cap = 16
    }}
    var prev = 0
    var cur = c2da_lin_free_list
    while (cur != 0) {{
        let next = c2da_lin_ld32(cur)
        if (c2da_lin_ld32(cur - 16) >= cap) {{
            if (prev == 0) {{
                c2da_lin_free_list = next
            }} else {{
                c2da_lin_st32(prev, next)
            }}
            return cur
        }}
        prev = cur
        cur = next
    }}
    let at = c2da_lin_brk
    let end = int64(at) + 16l + int64(cap)
    if (end > c2da_lin_limit) {{
        return 0
    }}
    resize(c2da_mem, int(end))
    c2da_lin_brk = int(end)
    c2da_lin_st32(at, cap)
    return at + 16
}}

def c2da_lin_free(p : int) {{
    if (p == 0) {{
        return
    }}
    c2da_lin_st32(p, c2da_lin_free_list)
    c2da_lin_free_list = p
}}

def c2da_lin_memset(d : int; c : int; n : uint64) : int {{
    let b = uint8(c)
    for (i in range(int(n))) {{
        c2da_mem[d + i] = b
    }}
    return d
}}

def c2da_lin_calloc(count : uint64; size : uint64) : int {{
    if (size != 0ul && count > uint64(0x7ffffff0) / size) {{
        return 0
    }}
    let n = count * size
    let p = c2da_lin_malloc(n)
    if (p != 0) {{
        c2da_lin_memset(p, 0, n)
    }}
    return p
}}

def c2da_lin_memcpy(d : int; s : int; n : uint64) : int {{
    for (i in range(int(n))) {{
        c2da_mem[d + i] = c2da_mem[s + i]
    }}
    return d
}}

def c2da_lin_memmove(d : int; s : int; n : uint64) : int {{
    let len = int(n)
    if (d <= s) {{
        for (i in range(len)) {{
            c2da_mem[d + i] = c2da_mem[s + i]
        }}
    }} else {{
        var i = len - 1
        while (i >= 0) {{
            c2da_mem[d + i] = c2da_mem[s + i]
            i--
        }}
    }}
    return d
}}

def c2da_lin_realloc(p : int; n : uint64) : int {{
    if (p == 0) {{
        return c2da_lin_malloc(n)
    }}
    if (n == 0ul) {{
        c2da_lin_free(p)
        return 0
    }}
    let cap = c2da_lin_ld32(p - 16)
    if (n <= uint64(cap)) {{
        return p
    }}
    let q = c2da_lin_malloc(n)
    if (q == 0) {{
        return 0
    }}
    c2da_lin_memcpy(q, p, uint64(cap))
    c2da_lin_free(p)
    return q
}}

def c2da_lin_memcmp(a : int; b : int; n : uint64) : int {{
    for (i in range(int(n))) {{
        let x = int(c2da_mem[a + i])
        let y = int(c2da_mem[b + i])
        if (x != y) {{
            return x - y
        }}
    }}
    return 0
}}

def c2da_lin_strlen(s : int) : uint64 {{
    var i = s
    while (c2da_mem[i] != uint8(0)) {{
        i++
    }}
    return uint64(i - s)
}}

// The C string functions over the heap; a character compares as unsigned char.
def c2da_lin_strchr(s : int; c : int) : int {{
    let b = uint8(c & 0xff)
    var i = s
    while (c2da_mem[i] != b) {{
        if (c2da_mem[i] == uint8(0)) {{
            return 0
        }}
        i++
    }}
    return i
}}

def c2da_lin_strrchr(s : int; c : int) : int {{
    let b = uint8(c & 0xff)
    var found = 0
    var i = s
    while (c2da_mem[i] != uint8(0)) {{
        if (c2da_mem[i] == b) {{
            found = i
        }}
        i++
    }}
    if (b == uint8(0)) {{
        return i
    }}
    return found
}}

def c2da_lin_strncmp(a : int; b : int; n : uint64) : int {{
    for (i in range(int(n))) {{
        let x = int(c2da_mem[a + i])
        let y = int(c2da_mem[b + i])
        if (x != y || x == 0) {{
            return x - y
        }}
    }}
    return 0
}}

def c2da_lin_strcmp(a : int; b : int) : int {{
    var i = 0
    var x = int(c2da_mem[a])
    var y = int(c2da_mem[b])
    while (x == y && x != 0) {{
        i++
        x = int(c2da_mem[a + i])
        y = int(c2da_mem[b + i])
    }}
    return x - y
}}

def c2da_lin_strcpy(d : int; s : int) : int {{
    var i = 0
    while (c2da_mem[s + i] != uint8(0)) {{
        c2da_mem[d + i] = c2da_mem[s + i]
        i++
    }}
    c2da_mem[d + i] = uint8(0)
    return d
}}

def c2da_lin_strncpy(d : int; s : int; n : uint64) : int {{
    let len = int(n)
    var i = 0
    while (i < len && c2da_mem[s + i] != uint8(0)) {{
        c2da_mem[d + i] = c2da_mem[s + i]
        i++
    }}
    while (i < len) {{
        c2da_mem[d + i] = uint8(0)
        i++
    }}
    return d
}}

def c2da_lin_strcat(d : int; s : int) : int {{
    c2da_lin_strcpy(d + int(c2da_lin_strlen(d)), s)
    return d
}}

def c2da_lin_strstr(h : int; n : int) : int {{
    var i = h
    while (true) {{
        var k = 0
        while (c2da_mem[n + k] != uint8(0) && c2da_mem[i + k] == c2da_mem[n + k]) {{
            k++
        }}
        if (c2da_mem[n + k] == uint8(0)) {{
            return i
        }}
        if (c2da_mem[i] == uint8(0)) {{
            return 0
        }}
        i++
    }}
    return 0
}}
"#
    )
}
