//! Folding of daScript numeric conversions whose result is a known constant.
//!
//! A numeric `Cast` is daScript's function-style conversion `T(x)`: for the
//! integer types it is C++ `static_cast`, i.e. the value reduced modulo
//! 2^width(T) into T's range; an integer that a real type represents exactly
//! converts to that real.  When `x` is a constant, the conversion's result is
//! therefore a constant of `T` that can be written directly, and a conversion
//! of a value that already has type `T` is no conversion at all.
//!
//! This module decides those two cases on the AST.  It never rewrites text and
//! never applies C semantics: whatever conversion the translator built is
//! kept, only with its constant result computed.  A conversion that is not a
//! provable identity or a constant — a narrowing of a variable, a real to
//! integer truncation, a cast whose target is an alias or carries `&` —
//! is left exactly as it was.
//!
//! The canonical *typed integer literal* is `Cast { Cast, ConstInt|ConstUInt(v),
//! T }` with `v` inside T's range: it keeps the shape every consumer of a
//! translated literal already recognises, and the printer spells it as the
//! literal of `T` (`2`, `8u`, `8l`, `8ul`, `8u8`, `0xffu`) where daScript has
//! one.
//!
//! # Conversions of values whose type is known
//!
//! Over a whole module ([`fold_module_conversions`]) the pass also knows the
//! daScript type of many non-constant operands, read off the AST it walks —
//! never off the C source, whose types differ (a C comparison is `int`, a
//! daScript one `bool`).  [`Folder::type_of`] is the rule, and it answers only
//! what daScript's own typing makes certain:
//!
//! - a name → the declared type of the innermost local, parameter or module
//!   global it names (a `for` variable, or a name declared twice at module
//!   level, has none);
//! - `T(x)` and `reinterpret<T>(x)` → `T`; a literal → the type it lexes as;
//! - `p[i]` / `*p` of a `T?`, and `a[i]` of a `T[n]` or `array<T>` → `T`;
//!   `addr(x)` → a pointer to `x`'s type; `s.f` of a structure of this module,
//!   or of a pointer to one → the field's declared type;
//! - `-a`, `+a` of an `int`/`uint`/`int64`/`uint64`/`float`/`double` → that
//!   type, `~a` of one of the four integers → that type;
//! - `a op b` with both operands of the same such type → that type, for the
//!   arithmetic operators, and for the bitwise and shift operators on the four
//!   integers (daScript requires both sides of every one of them, shifts
//!   included, to be of one type, and defines none of them on the storage
//!   types `int8`, `uint8`, `int16`, `uint16`) — unless the module declares an
//!   operator of its own;
//! - `c ? a : b` with both arms of one type → that type;
//! - `f(args)` of a function this module declares once, with exactly as many
//!   arguments as parameters and each argument of its parameter's type (an
//!   exact match, which a same-named builtin could only make ambiguous) → the
//!   declared result type.
//!
//! Anything else has no known type.  With that rule a numeric conversion is
//! dropped when its operand's type is the target (`int(i)` of an `int i`,
//! `uint(f(x))` of a `uint` `f`; a `const` or `&` on the operand's type is not
//! a difference, the conversion only reads the value); `T(U(x))` of an integer
//! `x` whose type `U` represents entirely is `T(x)` (the inner conversion keeps
//! the value, and an integer conversion depends only on the value); and
//! `c ? T(a) : T(b)` with `a` and `b` of one type is `T(c ? a : b)` (the one
//! arm evaluated goes through the same conversion either way).  A typed
//! integer literal is never unwrapped: its `Cast` is its spelling.
//!
//! The call-shaped `unsafe(x)` marks only the root node of `x`, so an
//! `unsafe(unsafe(x))` that a removed conversion leaves behind is one
//! `unsafe(x)`.

use std::collections::HashMap;

use crate::{CastKind, DaBlock, DaDecl, DaExpr, DaFunction, DaStmt, DaType, DaTypeKind};

/// Width and signedness of a builtin daScript integer type.
pub(crate) fn integer_kind(kind: &DaTypeKind) -> Option<(u32, bool)> {
    match kind {
        DaTypeKind::Int8 => Some((8, true)),
        DaTypeKind::Int16 => Some((16, true)),
        DaTypeKind::Int => Some((32, true)),
        DaTypeKind::Int64 => Some((64, true)),
        DaTypeKind::UInt8 => Some((8, false)),
        DaTypeKind::UInt16 => Some((16, false)),
        DaTypeKind::UInt => Some((32, false)),
        DaTypeKind::UInt64 => Some((64, false)),
        _ => None,
    }
}

/// Whether `value` is a value of the integer type `(bits, signed)`.
fn in_range(value: i128, (bits, signed): (u32, bool)) -> bool {
    if signed {
        let half = 1i128 << (bits - 1);
        (-half..half).contains(&value)
    } else {
        (0..(1i128 << bits)).contains(&value)
    }
}

/// `static_cast` of an integer value into `(bits, signed)`: the value reduced
/// modulo 2^bits into the target's range.
fn wrap(value: i128, (bits, signed): (u32, bool)) -> i128 {
    let modulus = 1i128 << bits;
    let reduced = value.rem_euclid(modulus);
    if signed && reduced >= modulus / 2 {
        reduced - modulus
    } else {
        reduced
    }
}

/// A type with no qualifier: the only kind of target a conversion's result
/// can be spelled as a literal of.
fn is_plain(ty: &DaType) -> bool {
    !ty.is_const && !ty.is_ref && !ty.is_temporary
}

/// The value and daScript type of an integer constant expression: a bare
/// literal (whose daScript type is the one its printed spelling lexes as), or
/// a canonical typed integer literal.
pub(crate) fn integer_constant(expr: &DaExpr) -> Option<(i128, DaTypeKind)> {
    match expr {
        DaExpr::ConstInt(v) => {
            let kind = if in_range(*v as i128, (32, true)) {
                DaTypeKind::Int
            } else {
                DaTypeKind::Int64
            };
            Some((*v as i128, kind))
        }
        DaExpr::ConstUInt(v) => {
            let kind = if *v <= u32::MAX as u64 {
                DaTypeKind::UInt
            } else {
                DaTypeKind::UInt64
            };
            Some((*v as i128, kind))
        }
        _ => typed_integer_literal(expr).map(|(value, kind, _)| (value, kind.clone())),
    }
}

/// A canonical typed integer literal: a numeric conversion of an integer
/// constant whose value is already in the target's range, so the conversion
/// changes nothing but the type.
///
/// Returns the value, the type, and whether an unsigned literal is spelled in
/// hexadecimal: the inner constant carries that choice, `ConstUInt` for hex
/// (the spelling a bare `ConstUInt` always had) and `ConstInt` for decimal.
/// daScript has no hexadecimal literal of a signed type, so a signed literal
/// is always decimal.
pub(crate) fn typed_integer_literal(expr: &DaExpr) -> Option<(i128, &DaTypeKind, bool)> {
    let DaExpr::Cast {
        kind: CastKind::Cast,
        expr,
        to,
    } = expr
    else {
        return None;
    };
    let (value, hex) = match **expr {
        DaExpr::ConstInt(v) => (v as i128, false),
        DaExpr::ConstUInt(v) => (v as i128, true),
        _ => return None,
    };
    let range = integer_kind(&to.kind)?;
    (is_plain(to) && in_range(value, range)).then_some((value, &to.kind, hex && !range.1))
}

/// Whether an integer constant is spelled in hexadecimal (see
/// [`typed_integer_literal`]).
fn is_hex_spelled(expr: &DaExpr) -> bool {
    match expr {
        DaExpr::ConstUInt(_) => true,
        DaExpr::Cast { expr, .. } => matches!(**expr, DaExpr::ConstUInt(_)),
        _ => false,
    }
}

impl DaExpr {
    /// The integer constant `value` as a value of the integer type `ty`,
    /// spelled in hexadecimal when `hex` is set and `ty` is unsigned.
    ///
    /// A signed literal prints in decimal, but a non-negative one still keeps
    /// `hex` in its constant, so a C hex constant converted on to an unsigned
    /// type (`0xab` stored to an `unsigned char`) is spelled `0xabu8`.
    ///
    /// `value` must be a value of `ty`; the caller reduces it first
    /// ([`DaExpr::numeric_conversion`] does).
    pub fn integer_literal(value: i128, ty: DaTypeKind, hex: bool) -> DaExpr {
        let range = integer_kind(&ty).expect("integer literal of a non-integer type");
        assert!(in_range(value, range), "{value} is not a value of {ty:?}");
        // A decimal unsigned value above `i64::MAX` has no `ConstInt`; it is
        // spelled in hexadecimal.
        let constant = if value < 0 || (!hex && value <= i64::MAX as i128) {
            DaExpr::ConstInt(value as i64)
        } else {
            DaExpr::ConstUInt(value as u64)
        };
        DaExpr::Cast {
            kind: CastKind::Cast,
            expr: Box::new(constant),
            to: DaType::new(ty),
        }
    }

    /// The numeric conversion `to(expr)`, folded where its result is provable:
    /// an integer constant becomes the constant of `to` that daScript's
    /// conversion produces, a real constant that `to` represents exactly
    /// becomes that constant, and a conversion of a value already of type
    /// `to` is dropped.  Anything else is the conversion itself.
    pub fn numeric_conversion(expr: DaExpr, to: DaType) -> DaExpr {
        let unfolded = |expr: DaExpr, to: DaType| DaExpr::Cast {
            kind: CastKind::Cast,
            expr: Box::new(expr),
            to,
        };
        if !is_plain(&to) {
            return unfolded(expr, to);
        }
        if let Some(range) = integer_kind(&to.kind) {
            if let Some((value, _)) = integer_constant(&expr) {
                return DaExpr::integer_literal(wrap(value, range), to.kind, is_hex_spelled(&expr));
            }
        }
        match (&to.kind, &expr) {
            (DaTypeKind::Float, DaExpr::ConstFloat(_)) => return expr,
            (DaTypeKind::Double, DaExpr::ConstDouble(_)) => return expr,
            // `float` → `double` is exact; the stored value is the one the
            // `float` literal prints as.
            (DaTypeKind::Double, DaExpr::ConstFloat(x)) if x.is_finite() => {
                return DaExpr::ConstDouble(*x as f32 as f64);
            }
            (DaTypeKind::Float, DaExpr::ConstDouble(x))
                if x.is_finite() && (*x as f32) as f64 == *x =>
            {
                return DaExpr::ConstFloat(*x);
            }
            (DaTypeKind::Float | DaTypeKind::Double, _) => {
                if let Some((value, _)) = integer_constant(&expr) {
                    let real = value as f64;
                    let exact = real as i128 == value;
                    if matches!(to.kind, DaTypeKind::Double) && exact {
                        return DaExpr::ConstDouble(real);
                    }
                    if exact && (real as f32) as f64 == real {
                        return DaExpr::ConstFloat(real);
                    }
                }
            }
            _ => {}
        }
        // `T(T(x))`: the inner conversion already produced a `T`.
        if let DaExpr::Cast {
            kind: CastKind::Cast,
            to: inner,
            ..
        } = &expr
        {
            if is_plain(inner) && inner.kind == to.kind && is_builtin_number(&to.kind) {
                return expr;
            }
        }
        unfolded(expr, to)
    }

    /// Folds every numeric conversion in this expression, innermost first,
    /// knowing no declaration: only the types the expression itself spells
    /// (literals, conversions, `reinterpret`s) are known.
    pub fn fold_numeric_conversions(&mut self) {
        Folder::new(&ModuleTypes::default()).walk_expr(self);
    }
}

/// A builtin numeric type whose conversion function is its own name.
fn is_builtin_number(kind: &DaTypeKind) -> bool {
    integer_kind(kind).is_some() || matches!(kind, DaTypeKind::Float | DaTypeKind::Double)
}

impl DaDecl {
    /// Folds every numeric conversion in this declaration, knowing no other
    /// declaration (see [`fold_module_conversions`] for the module-wide pass).
    pub fn fold_numeric_conversions(&mut self) {
        Folder::new(&ModuleTypes::default()).walk_decl(self);
    }
}

/// Folds every numeric conversion in a module's declarations, with the types
/// of the module's globals, functions, structures and aliases known (see the
/// module documentation).
pub fn fold_module_conversions(decls: &mut [DaDecl]) {
    let module = ModuleTypes::of(decls);
    let mut folder = Folder::new(&module);
    for decl in decls.iter_mut() {
        folder.walk_decl(decl);
    }
}

/// A name's declaration at module level: `None` once the name is declared
/// twice, so an overload set or a redeclaration has no single type.
fn declare_once<T>(map: &mut HashMap<String, Option<T>>, name: &str, value: T) {
    map.entry(name.to_string())
        .and_modify(|slot| *slot = None)
        .or_insert(Some(value));
}

/// The module-level declarations the typing rule reads.
#[derive(Default)]
struct ModuleTypes {
    globals: HashMap<String, Option<DaType>>,
    /// Parameter types and result type.
    functions: HashMap<String, Option<(Vec<DaType>, DaType)>>,
    /// Field types by field name.
    structures: HashMap<String, Option<HashMap<String, DaType>>>,
    aliases: HashMap<String, Option<DaType>>,
    /// The module declares an `operator …` function, which could give an
    /// operator on builtin types another result: no operator is typed then.
    declares_operators: bool,
}

impl ModuleTypes {
    fn of(decls: &[DaDecl]) -> Self {
        let mut module = ModuleTypes::default();
        for decl in decls {
            match decl {
                DaDecl::Variable(variable) => declare_once(
                    &mut module.globals,
                    &variable.name,
                    variable.var_type.clone(),
                ),
                DaDecl::Function(function) => {
                    if function.name.starts_with("operator") {
                        module.declares_operators = true;
                    }
                    if let Some(signature) = signature(function) {
                        declare_once(&mut module.functions, &function.name, signature);
                    } else {
                        // Declared, but with no signature the rule can read.
                        module.functions.insert(function.name.clone(), None);
                    }
                }
                DaDecl::Structure(structure) => {
                    let fields = structure
                        .fields
                        .iter()
                        .map(|field| (field.name.clone(), field.field_type.clone()))
                        .collect();
                    declare_once(&mut module.structures, &structure.name, fields);
                }
                DaDecl::Alias(alias) => {
                    declare_once(&mut module.aliases, &alias.name, alias.aliased_type.clone())
                }
                DaDecl::Enumeration(_) => {}
            }
        }
        module
    }

    /// `ty` with every module alias at its top level replaced by the type it
    /// names.  daScript's `typedef` is transparent.
    fn resolve(&self, ty: DaType) -> Option<DaType> {
        let mut ty = ty;
        // An alias chain longer than the module's alias count is a cycle.
        for _ in 0..=self.aliases.len() {
            let DaTypeKind::Named(name) = &ty.kind else {
                return Some(ty);
            };
            match self.aliases.get(name) {
                None => return Some(ty),
                Some(None) => return None,
                Some(Some(aliased)) => {
                    let (is_const, is_ref) = (ty.is_const, ty.is_ref);
                    ty = aliased.clone();
                    ty.is_const |= is_const;
                    ty.is_ref |= is_ref;
                }
            }
        }
        None
    }

    /// Whether a value of type `a` has exactly the daScript type `b`, up to
    /// the qualifiers of the value itself (`const`, `&`, temporary), which a
    /// read of it drops.  Everything below the top level is compared exactly.
    fn same_value_type(&self, a: &DaType, b: &DaType) -> bool {
        match (self.resolve(a.clone()), self.resolve(b.clone())) {
            (Some(a), Some(b)) => a.kind == b.kind && !matches!(a.kind, DaTypeKind::Auto),
            _ => false,
        }
    }
}

/// A function's parameter and result types, when every parameter is a plain
/// declared parameter.
fn signature(function: &DaFunction) -> Option<(Vec<DaType>, DaType)> {
    let params = function
        .params
        .iter()
        .map(|param| match param {
            DaStmt::Param { param_type, .. } => Some(param_type.clone()),
            _ => None,
        })
        .collect::<Option<Vec<_>>>()?;
    Some((params, function.ret_type.clone()))
}

/// `ty` without the qualifiers of the value itself.
fn value_of(mut ty: DaType) -> DaType {
    ty.is_const = false;
    ty.is_ref = false;
    ty.is_temporary = false;
    ty
}

/// A type daScript defines `+ - * / %` and unary `-`/`+` on.
fn is_arithmetic(kind: &DaTypeKind) -> bool {
    is_wide_integer(kind) || matches!(kind, DaTypeKind::Float | DaTypeKind::Double)
}

/// An integer type daScript defines operators on: the storage types `int8`,
/// `uint8`, `int16` and `uint16` have none.
fn is_wide_integer(kind: &DaTypeKind) -> bool {
    matches!(
        kind,
        DaTypeKind::Int | DaTypeKind::UInt | DaTypeKind::Int64 | DaTypeKind::UInt64
    )
}

/// A conversion target the identity rule applies to: a builtin number or
/// `bool`, with no qualifier.
fn is_identity_target(to: &DaType) -> bool {
    is_plain(to) && (is_builtin_number(&to.kind) || matches!(to.kind, DaTypeKind::Bool))
}

/// Whether every value of the integer type `inner` is a value of `outer`.
fn integer_range_contains(outer: &DaTypeKind, inner: &DaTypeKind) -> bool {
    match (integer_kind(outer), integer_kind(inner)) {
        (Some((outer_bits, outer_signed)), Some((inner_bits, inner_signed))) => {
            match (outer_signed, inner_signed) {
                (true, true) | (false, false) => outer_bits >= inner_bits,
                (true, false) => outer_bits > inner_bits,
                (false, true) => false,
            }
        }
        _ => false,
    }
}

/// The walk: folds conversions innermost first while tracking which local
/// declarations are in scope.
struct Folder<'m> {
    module: &'m ModuleTypes,
    /// Innermost last; `None` for a name whose type is not known.
    scopes: Vec<HashMap<String, Option<DaType>>>,
}

impl<'m> Folder<'m> {
    fn new(module: &'m ModuleTypes) -> Self {
        Folder {
            module,
            scopes: Vec::new(),
        }
    }

    fn bind(&mut self, name: &str, ty: Option<DaType>) {
        if let Some(scope) = self.scopes.last_mut() {
            scope.insert(name.to_string(), ty);
        }
    }

    fn walk_decl(&mut self, decl: &mut DaDecl) {
        // A declaration sees module-level names only.
        let outer = std::mem::take(&mut self.scopes);
        match decl {
            DaDecl::Function(function) => {
                self.scopes.push(HashMap::new());
                for param in &mut function.params {
                    self.walk_stmt(param);
                }
                if let Some(body) = &mut function.body {
                    self.walk_expr(body);
                }
                self.scopes.pop();
            }
            DaDecl::Variable(variable) => {
                if let Some(init) = &mut variable.init {
                    self.walk_expr(init);
                }
            }
            DaDecl::Structure(structure) => {
                for field in &mut structure.fields {
                    if let Some(default) = &mut field.default {
                        self.walk_expr(default);
                    }
                }
            }
            DaDecl::Enumeration(enumeration) => {
                for variant in &mut enumeration.variants {
                    if let Some(value) = &mut variant.value {
                        self.walk_expr(value);
                    }
                }
            }
            DaDecl::Alias(_) => {}
        }
        self.scopes = outer;
    }

    fn walk_block(&mut self, block: &mut DaBlock) {
        self.scopes.push(HashMap::new());
        for stmt in &mut block.stmts {
            self.walk_stmt(stmt);
        }
        self.scopes.pop();
    }

    fn walk_stmt(&mut self, stmt: &mut DaStmt) {
        match stmt {
            DaStmt::Var {
                name,
                var_type,
                init,
            } => {
                if let Some(init) = init {
                    self.walk_expr(init);
                }
                let ty = if matches!(var_type.kind, DaTypeKind::Auto) {
                    init.as_ref()
                        .and_then(|init| self.type_of(init))
                        .map(value_of)
                } else {
                    Some(var_type.clone())
                };
                self.bind(name, ty);
            }
            DaStmt::Let { name, init } => {
                if let Some(init) = init {
                    self.walk_expr(init);
                }
                let ty = init
                    .as_ref()
                    .and_then(|init| self.type_of(init))
                    .map(|ty| value_of(ty).const_());
                self.bind(name, ty);
            }
            DaStmt::Param {
                name,
                param_type,
                default,
                is_mutable,
            } => {
                if let Some(default) = default {
                    self.walk_expr(default);
                }
                let mut ty = param_type.clone();
                ty.is_const |= !*is_mutable;
                self.bind(name, Some(ty));
            }
            DaStmt::Expr(expr) => self.walk_expr(expr),
            DaStmt::Decl(decl) => self.walk_decl(decl),
        }
    }

    fn lookup(&self, name: &str) -> Option<DaType> {
        for scope in self.scopes.iter().rev() {
            if let Some(ty) = scope.get(name) {
                return ty.clone();
            }
        }
        self.module.globals.get(name).cloned().flatten()
    }

    /// The daScript type of `expr`, when the rule in the module documentation
    /// makes it certain.
    fn type_of(&self, expr: &DaExpr) -> Option<DaType> {
        use DaExpr::*;
        let known = |ty: Option<DaType>| ty.and_then(|ty| self.module.resolve(ty));
        match expr {
            ConstInt(_) | ConstUInt(_) => integer_constant(expr).map(|(_, kind)| DaType::new(kind)),
            ConstFloat(_) => Some(DaType::float()),
            ConstDouble(_) => Some(DaType::double()),
            ConstBool(_) => Some(DaType::bool()),
            Var(name) => known(self.lookup(name)),
            Cast {
                kind: CastKind::Cast | CastKind::Reinterpret,
                to,
                ..
            } => known(Some(to.clone())),
            Unsafe(inner) if !matches!(**inner, Block(_)) => self.type_of(inner),
            Deref(inner) | DerefExplicit(inner) => match known(self.type_of(inner))?.kind {
                DaTypeKind::Pointer(pointee) => known(Some(*pointee)),
                _ => None,
            },
            Index(base, _) => {
                let base = known(self.type_of(base))?;
                match base.kind {
                    DaTypeKind::Pointer(element) => known(Some(*element)),
                    DaTypeKind::FixedArray(element, _) | DaTypeKind::Array(element) => {
                        let mut element = known(Some(*element))?;
                        element.is_const |= base.is_const;
                        Some(element)
                    }
                    _ => None,
                }
            }
            Addr(inner) => Some(DaType::pointer(self.type_of(inner)?)),
            Field(base, field) => {
                let base = known(self.type_of(base))?;
                let (structure, is_const) = match base.kind {
                    DaTypeKind::Named(name) => (name, base.is_const),
                    DaTypeKind::Pointer(pointee) => {
                        let pointee = known(Some(*pointee))?;
                        match pointee.kind {
                            DaTypeKind::Named(name) => (name, pointee.is_const),
                            _ => return None,
                        }
                    }
                    _ => return None,
                };
                let fields = self.module.structures.get(&structure)?.as_ref()?;
                let mut ty = known(fields.get(field).cloned())?;
                ty.is_const |= is_const;
                Some(ty)
            }
            Op1 { op, expr: operand } => {
                if self.module.declares_operators {
                    return None;
                }
                let ty = value_of(known(self.type_of(operand))?);
                let typed = match *op {
                    "-" | "+" => is_arithmetic(&ty.kind),
                    "~" => is_wide_integer(&ty.kind),
                    _ => false,
                };
                typed.then_some(ty)
            }
            Op2 { op, left, right } => {
                if self.module.declares_operators {
                    return None;
                }
                let left = value_of(known(self.type_of(left))?);
                let right = value_of(known(self.type_of(right))?);
                if left.kind != right.kind {
                    return None;
                }
                let typed = match *op {
                    "+" | "-" | "*" | "/" | "%" => is_arithmetic(&left.kind),
                    "&" | "|" | "^" | "<<" | ">>" | "<<<" | ">>>" => is_wide_integer(&left.kind),
                    _ => false,
                };
                typed.then_some(left)
            }
            Op3 { then, else_, .. } => {
                let then = value_of(known(self.type_of(then))?);
                let else_ = known(self.type_of(else_))?;
                self.module.same_value_type(&then, &else_).then_some(then)
            }
            Call(callee, args) => {
                let Var(name) = &**callee else {
                    return None;
                };
                // A local of that name would be a function value, called
                // through `invoke`, never like this; still, it hides nothing.
                let (params, result) = self.module.functions.get(name)?.as_ref()?;
                if params.len() != args.len() {
                    return None;
                }
                for (param, arg) in params.iter().zip(args) {
                    if !self.module.same_value_type(&self.type_of(arg)?, param) {
                        return None;
                    }
                }
                known(Some(result.clone()))
            }
            _ => None,
        }
    }

    /// Whether `expr` provably has the value type `to`.
    fn has_value_type(&self, expr: &DaExpr, to: &DaType) -> bool {
        self.type_of(expr)
            .map_or(false, |ty| self.module.same_value_type(&ty, to))
    }

    /// The numeric conversion `to(operand)` with what the operand's known
    /// type proves on top of [`DaExpr::numeric_conversion`].
    fn conversion(&self, operand: DaExpr, to: DaType) -> DaExpr {
        let operand = self.skip_widening(operand, &to);
        let folded = DaExpr::numeric_conversion(operand, to);
        match folded {
            DaExpr::Cast {
                kind: CastKind::Cast,
                expr,
                to,
            } if is_identity_target(&to)
                && integer_constant(&expr).is_none()
                && self.has_value_type(&expr, &to) =>
            {
                *expr
            }
            folded => folded,
        }
    }

    /// `U(x)` as an operand of an integer conversion to `to`, with `x` of an
    /// integer type that `U` represents entirely, is just `x`: `U(x)` has
    /// `x`'s value, and an integer conversion depends only on the value.
    /// Constants stay with the constant folding, which keeps their spelling.
    fn skip_widening(&self, operand: DaExpr, to: &DaType) -> DaExpr {
        if !is_plain(to) || integer_kind(&to.kind).is_none() {
            return operand;
        }
        match operand {
            DaExpr::Cast {
                kind: CastKind::Cast,
                expr,
                to: widened,
            } if is_plain(&widened)
                && integer_constant(&expr).is_none()
                && self.type_of(&expr).map_or(false, |ty| {
                    integer_range_contains(&widened.kind, &value_of(ty).kind)
                }) =>
            {
                *expr
            }
            operand => operand,
        }
    }

    /// `c ? T(a) : T(b)` with `a` and `b` of one type, as `T(c ? a : b)`.
    fn hoist_arm_conversions(&self, expr: &mut DaExpr) {
        let DaExpr::Op3 { then, else_, .. } = expr else {
            return;
        };
        let (
            DaExpr::Cast {
                kind: CastKind::Cast,
                expr: then_operand,
                to: then_to,
            },
            DaExpr::Cast {
                kind: CastKind::Cast,
                expr: else_operand,
                to: else_to,
            },
        ) = (&**then, &**else_)
        else {
            return;
        };
        if then_to != else_to
            || !is_identity_target(then_to)
            || integer_constant(then_operand).is_some()
            || integer_constant(else_operand).is_some()
        {
            return;
        }
        let Some(arm_type) = self.type_of(then_operand) else {
            return;
        };
        let arm_kind = value_of(arm_type.clone()).kind;
        if !(is_builtin_number(&arm_kind) || matches!(arm_kind, DaTypeKind::Bool))
            || !self.has_value_type(else_operand, &arm_type)
        {
            return;
        }
        let to = then_to.clone();
        let DaExpr::Op3 { cond, then, else_ } = std::mem::replace(expr, DaExpr::ConstNull) else {
            unreachable!("matched as a conditional above");
        };
        let unwrap = |arm: Box<DaExpr>| match *arm {
            DaExpr::Cast { expr, .. } => expr,
            _ => unreachable!("matched as a conversion above"),
        };
        let hoisted = DaExpr::Op3 {
            cond,
            then: unwrap(then),
            else_: unwrap(else_),
        };
        *expr = self.conversion(hoisted, to);
    }

    fn walk_expr(&mut self, expr: &mut DaExpr) {
        use DaExpr::*;
        match expr {
            ConstInt(_)
            | ConstUInt(_)
            | ConstFloat(_)
            | ConstDouble(_)
            | ConstBool(_)
            | ConstString(_)
            | ConstNull
            | Var(_)
            | Break
            | Continue
            | Goto(_)
            | Label(_)
            | FuncRef(_)
            | DefaultValue(_)
            | TypeInfo { .. } => {}
            Op1 { op, expr: inner } => {
                self.walk_expr(inner);
                if *op == "-" {
                    if let Some(negated) = negated_signed_constant(inner) {
                        *expr = negated;
                    }
                }
            }
            Unsafe(inner) => {
                self.walk_expr(inner);
                // A removed conversion can leave `unsafe(unsafe(x))`, which
                // marks the same node as `unsafe(x)`.
                if matches!(&**inner, Unsafe(nested) if !matches!(**nested, Block(_))) {
                    *expr = std::mem::replace(&mut **inner, ConstNull);
                }
            }
            Field(inner, _)
            | SafeField(inner, _)
            | Delete(inner)
            | Addr(inner)
            | Deref(inner)
            | DerefExplicit(inner) => self.walk_expr(inner),
            Index(left, right)
            | SafeIndex(left, right)
            | Op2 { left, right, .. }
            | Assign(left, right)
            | AssignOp { left, right, .. }
            | Pipe(left, right)
            | While(left, right) => {
                self.walk_expr(left);
                self.walk_expr(right);
            }
            Op3 { cond, then, else_ } => {
                self.walk_expr(cond);
                self.walk_expr(then);
                self.walk_expr(else_);
                self.hoist_arm_conversions(expr);
            }
            Call(callee, args) | New(callee, args) => {
                self.walk_expr(callee);
                for arg in args {
                    self.walk_expr(arg);
                }
            }
            Block(block) => self.walk_block(block),
            IfThenElse {
                cond,
                then,
                elifs,
                else_,
            } => {
                self.walk_expr(cond);
                self.walk_expr(then);
                for (elif_cond, elif_body) in elifs {
                    self.walk_expr(elif_cond);
                    self.walk_expr(elif_body);
                }
                if let Some(else_) = else_ {
                    self.walk_expr(else_);
                }
            }
            For {
                vars,
                sources,
                body,
            } => {
                for source in sources {
                    self.walk_expr(source);
                }
                // The iteration variables' types are the sources' element
                // types, which the rule does not derive.
                self.scopes.push(HashMap::new());
                for var in vars.iter() {
                    self.bind(var, None);
                }
                self.walk_expr(body);
                self.scopes.pop();
            }
            Return(value) => {
                if let Some(value) = value {
                    self.walk_expr(value);
                }
            }
            MakeStruct { fields, .. } => {
                for (_, value) in fields {
                    self.walk_expr(value);
                }
            }
            MakeArray(items) | MakeFixedArray { items, .. } => {
                for item in items {
                    self.walk_expr(item);
                }
            }
            Cast {
                kind,
                expr: inner,
                to,
            } => {
                self.walk_expr(inner);
                if *kind == CastKind::Cast && to.is_numeric() {
                    let operand = std::mem::replace(&mut **inner, ConstNull);
                    *expr = self.conversion(operand, to.clone());
                }
            }
        }
    }
}

/// `-c` for an `int` or `int64` constant `c` whose negation is still a value
/// of its type, as a typed literal of that type.  The one overflowing case
/// (`-INT_MIN`), unsigned negation and the narrow types are left to daScript.
fn negated_signed_constant(operand: &DaExpr) -> Option<DaExpr> {
    let (value, kind) = integer_constant(operand)?;
    if !matches!(kind, DaTypeKind::Int | DaTypeKind::Int64) {
        return None;
    }
    let range = integer_kind(&kind)?;
    in_range(-value, range).then(|| DaExpr::integer_literal(-value, kind, false))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn cast(expr: DaExpr, kind: DaTypeKind) -> DaExpr {
        DaExpr::Cast {
            kind: CastKind::Cast,
            expr: Box::new(expr),
            to: DaType::new(kind),
        }
    }

    fn folded(mut expr: DaExpr) -> String {
        expr.fold_numeric_conversions();
        expr.to_string()
    }

    #[test]
    fn integer_constants_become_literals_of_the_target_type() {
        use DaTypeKind::*;
        let int = |v| cast(DaExpr::ConstInt(v), Int);
        assert_eq!(folded(int(2)), "2");
        assert_eq!(folded(cast(int(8), UInt64)), "8ul");
        assert_eq!(folded(cast(int(256), UInt)), "256u");
        assert_eq!(folded(cast(int(3), Int64)), "3l");
        assert_eq!(folded(cast(int(179), UInt8)), "179u8");
        assert_eq!(folded(cast(DaExpr::ConstUInt(0xff), UInt)), "0xffu");
        assert_eq!(
            folded(cast(cast(DaExpr::ConstUInt(0xab), Int), UInt8)),
            "0xabu8"
        );
        assert_eq!(folded(cast(int(1), Int16)), "int16(1)");
    }

    #[test]
    fn narrowing_sign_change_and_wrap_keep_the_exact_result() {
        use DaTypeKind::*;
        let int = |v| cast(DaExpr::ConstInt(v), Int);
        assert_eq!(folded(cast(int(300), UInt8)), "44u8");
        assert_eq!(folded(cast(int(255), Int8)), "int8(-1)");
        assert_eq!(folded(cast(int(-1), UInt)), "4294967295u");
        assert_eq!(folded(cast(int(-1), UInt64)), "0xfffffffffffffffful");
        assert_eq!(
            folded(cast(DaExpr::ConstUInt(0x8000_0000), Int)),
            "(-2147483647 - 1)"
        );
        assert_eq!(
            folded(cast(DaExpr::ConstUInt(1 << 63), Int64)),
            "(-9223372036854775807l - 1l)"
        );
        assert_eq!(folded(cast(int(70000), Int16)), "int16(4464)");
    }

    #[test]
    fn negative_literals_keep_their_operator_precedence() {
        use DaTypeKind::*;
        let negative = cast(DaExpr::ConstInt(-5), Int64);
        let op1 = DaExpr::Op1 {
            op: "-",
            expr: Box::new(negative.clone()),
        };
        // `- -5l` would lex as a decrement.
        assert_eq!(op1.to_string(), "-(-5l)");
        let negated = DaExpr::Op1 {
            op: "-",
            expr: Box::new(cast(DaExpr::ConstInt(5), Int64)),
        };
        assert_eq!(folded(negated), "-5l");
        let int_min = DaExpr::Op1 {
            op: "-",
            expr: Box::new(cast(DaExpr::ConstUInt(0x8000_0000), Int)),
        };
        // `-INT_MIN` overflows `int`; it stays an operation.
        assert_eq!(folded(int_min), "-(-2147483647 - 1)");
    }

    #[test]
    fn reals_fold_only_when_exact_and_other_casts_stay() {
        use DaTypeKind::*;
        assert_eq!(folded(cast(DaExpr::ConstInt(3), Double)), "3.0lf");
        assert_eq!(
            folded(cast(DaExpr::ConstInt(16_777_217), Float)),
            "float(16777217)"
        );
        assert_eq!(
            folded(cast(DaExpr::ConstDouble(0.1), Float)),
            "float(0.1lf)"
        );
        assert_eq!(folded(cast(DaExpr::ConstFloat(0.5), Double)), "0.5lf");
        // A real to integer conversion truncates; it is never folded.
        assert_eq!(folded(cast(DaExpr::ConstDouble(2.5), Int)), "int(2.5lf)");
        // A same-type conversion of a converted value is dropped; a narrowing
        // of a variable is kept.
        let x = || DaExpr::Var("x".into());
        assert_eq!(folded(cast(cast(x(), UInt), UInt)), "uint(x)");
        assert_eq!(folded(cast(cast(x(), UInt), UInt8)), "uint8(uint(x))");
        assert_eq!(folded(cast(x(), Named("size_t".into()))), "size_t(x)");
    }

    fn var(name: &str) -> DaExpr {
        DaExpr::Var(name.into())
    }

    fn op2(op: &'static str, left: DaExpr, right: DaExpr) -> DaExpr {
        DaExpr::Op2 {
            op,
            left: Box::new(left),
            right: Box::new(right),
        }
    }

    fn param(name: &str, ty: DaType) -> DaStmt {
        DaStmt::Param {
            name: name.into(),
            param_type: ty,
            default: None,
            is_mutable: false,
        }
    }

    /// Folds `body` as the result of `def probe(params) : int` in a module
    /// that also declares `decls`, and prints the folded result.
    fn folded_in(
        decls: Vec<DaDecl>,
        params: Vec<DaStmt>,
        locals: Vec<DaStmt>,
        body: DaExpr,
    ) -> String {
        let mut stmts = locals;
        stmts.push(DaStmt::Expr(DaExpr::Return(Some(Box::new(body)))));
        let mut module = decls;
        module.push(DaDecl::Function(DaFunction {
            name: "probe".into(),
            params,
            ret_type: DaType::int(),
            body: Some(DaExpr::Block(DaBlock { stmts })),
            annotations: vec![],
            is_public: false,
            is_unsafe: false,
        }));
        fold_module_conversions(&mut module);
        let DaDecl::Function(probe) = module.pop().unwrap() else {
            unreachable!()
        };
        let DaExpr::Block(block) = probe.body.unwrap() else {
            unreachable!()
        };
        let DaStmt::Expr(DaExpr::Return(Some(value))) = block.stmts.last().unwrap() else {
            unreachable!()
        };
        value.to_string()
    }

    fn local(name: &str, ty: DaType) -> DaStmt {
        DaStmt::Var {
            name: name.into(),
            var_type: ty,
            init: None,
        }
    }

    fn function(name: &str, params: Vec<DaStmt>, ret_type: DaType) -> DaDecl {
        DaDecl::Function(DaFunction {
            name: name.into(),
            params,
            ret_type,
            body: None,
            annotations: vec![],
            is_public: false,
            is_unsafe: false,
        })
    }

    #[test]
    fn conversions_of_values_of_the_target_type_are_dropped() {
        use DaTypeKind::*;
        let i = || local("i", DaType::int());
        // A local, a const parameter, arithmetic of two operands of the type.
        assert_eq!(
            folded_in(vec![], vec![], vec![i()], cast(var("i"), Int)),
            "i"
        );
        assert_eq!(
            folded_in(
                vec![],
                vec![param("n", DaType::int())],
                vec![],
                cast(var("n"), Int)
            ),
            "n"
        );
        assert_eq!(
            folded_in(
                vec![],
                vec![],
                vec![i()],
                cast(op2("*", var("i"), cast(DaExpr::ConstInt(4), Int)), Int)
            ),
            "i * 4"
        );
        // A load through a `reinterpret` pointer, a const one included.
        let load = DaExpr::Index(
            Box::new(DaExpr::reinterpret(
                var("p"),
                DaType::pointer(DaType::uint8().const_()),
            )),
            Box::new(cast(var("i"), Int)),
        );
        assert_eq!(
            folded_in(
                vec![],
                vec![param("p", DaType::uint64())],
                vec![i()],
                cast(DaExpr::unsafe_of(load), UInt8)
            ),
            "unsafe(unsafe(reinterpret<uint8 const?>(p))[i])"
        );
        // A module function called with arguments of its parameter types.
        let get = function("get", vec![param("n", DaType::uint())], DaType::uint());
        let call = |arg| DaExpr::Call(Box::new(var("get")), vec![arg]);
        assert_eq!(
            folded_in(
                vec![get.clone()],
                vec![],
                vec![],
                cast(call(cast(DaExpr::ConstInt(8), UInt)), UInt)
            ),
            "get(8u)"
        );
        // A module global and a structure field through a pointer.
        let global = DaDecl::Variable(crate::DaVariable {
            name: "g".into(),
            var_type: DaType::int64(),
            init: None,
            annotations: vec![],
        });
        let structure = DaDecl::Structure(crate::DaStructure {
            name: "S".into(),
            fields: vec![crate::DaField {
                name: "f".into(),
                field_type: DaType::uint(),
                default: None,
            }],
            annotations: vec![],
        });
        assert_eq!(
            folded_in(vec![global], vec![], vec![], cast(var("g"), Int64)),
            "g"
        );
        assert_eq!(
            folded_in(
                vec![structure],
                vec![param("s", DaType::pointer(DaType::named("S")))],
                vec![],
                cast(DaExpr::Field(Box::new(var("s")), "f".into()), UInt)
            ),
            "s.f"
        );
    }

    #[test]
    fn conversions_that_change_the_type_or_have_no_known_type_stay() {
        use DaTypeKind::*;
        let locals = || {
            vec![
                local("i", DaType::int()),
                local("b", DaType::uint8()),
                local("l", DaType::int64()),
            ]
        };
        let keep = |expr: DaExpr, to| folded_in(vec![], vec![], locals(), cast(expr, to));
        assert_eq!(keep(var("i"), UInt), "uint(i)");
        assert_eq!(keep(var("b"), Int), "int(b)");
        assert_eq!(keep(var("l"), Int), "int(l)");
        // An unknown name, and a call to a function this module does not
        // declare, have no known type.
        assert_eq!(keep(var("unknown"), Int), "int(unknown)");
        let external = DaExpr::Call(Box::new(var("abs")), vec![var("i")]);
        assert_eq!(keep(external, Int), "int(abs(i))");
        // Operands of different types, and an operator on a storage type.
        assert_eq!(keep(op2("+", var("i"), var("l")), Int), "int(i + l)");
        assert_eq!(keep(op2("+", var("b"), var("b")), UInt8), "uint8(b + b)");
        // A comparison is `bool`, never the integer it is in C.
        assert_eq!(keep(op2("<", var("i"), var("i")), Int), "int(i < i)");
        // A call whose argument is not of the parameter's type.
        let get = function("get", vec![param("n", DaType::uint())], DaType::int());
        assert_eq!(
            folded_in(
                vec![get],
                vec![],
                locals(),
                cast(DaExpr::Call(Box::new(var("get")), vec![var("i")]), Int)
            ),
            "int(get(i))"
        );
        // A `for` variable hides a local of the same name.
        let in_loop = DaExpr::For {
            vars: vec!["i".into()],
            sources: vec![var("r")],
            body: Box::new(DaExpr::Block(DaBlock {
                stmts: vec![DaStmt::Expr(cast(var("i"), Int))],
            })),
        };
        let mut body = DaExpr::Block(DaBlock {
            stmts: vec![local("i", DaType::int()), DaStmt::Expr(in_loop)],
        });
        Folder::new(&ModuleTypes::default()).walk_expr(&mut body);
        assert!(body.to_string().contains("int(i)"));
    }

    #[test]
    fn widenings_and_conditional_arms_collapse_exactly() {
        use DaTypeKind::*;
        let locals = || {
            vec![
                local("t1", DaType::uint8()),
                local("t2", DaType::uint8()),
                local("i", DaType::int()),
            ]
        };
        let cond = || op2("==", cast(var("t2"), Int), cast(DaExpr::ConstInt(255), Int));
        let conditional = |then, else_| DaExpr::Op3 {
            cond: Box::new(cond()),
            then: Box::new(then),
            else_: Box::new(else_),
        };
        // `uint8(c ? int(t1) : int(t2))` of two `uint8`s is the conditional.
        assert_eq!(
            folded_in(
                vec![],
                vec![],
                locals(),
                cast(
                    conditional(cast(var("t1"), Int), cast(var("t2"), Int)),
                    UInt8
                )
            ),
            "int(t2) == 255 ? t1 : t2"
        );
        // One arm of another type: nothing to hoist.
        assert_eq!(
            folded_in(
                vec![],
                vec![],
                locals(),
                conditional(cast(var("t1"), Int), cast(var("i"), UInt))
            ),
            "int(t2) == 255 ? int(t1) : uint(i)"
        );
        // `uint(int(t1))`: `int` holds every `uint8`.  `uint8(int8(i))` is a
        // narrowing that stays.
        assert_eq!(
            folded_in(vec![], vec![], locals(), cast(cast(var("t1"), Int), UInt)),
            "uint(t1)"
        );
        assert_eq!(
            folded_in(vec![], vec![], locals(), cast(cast(var("i"), Int8), UInt8)),
            "uint8(int8(i))"
        );
    }
}
