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

use crate::{CastKind, DaBlock, DaDecl, DaExpr, DaStmt, DaType, DaTypeKind};

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

    /// Folds every numeric conversion in this expression, innermost first.
    pub fn fold_numeric_conversions(&mut self) {
        walk_expr(self);
    }
}

/// A builtin numeric type whose conversion function is its own name.
fn is_builtin_number(kind: &DaTypeKind) -> bool {
    integer_kind(kind).is_some() || matches!(kind, DaTypeKind::Float | DaTypeKind::Double)
}

impl DaDecl {
    /// Folds every numeric conversion in this declaration.
    pub fn fold_numeric_conversions(&mut self) {
        match self {
            DaDecl::Function(function) => {
                function.params.iter_mut().for_each(walk_stmt);
                if let Some(body) = &mut function.body {
                    walk_expr(body);
                }
            }
            DaDecl::Variable(variable) => {
                if let Some(init) = &mut variable.init {
                    walk_expr(init);
                }
            }
            DaDecl::Structure(structure) => {
                for field in &mut structure.fields {
                    if let Some(default) = &mut field.default {
                        walk_expr(default);
                    }
                }
            }
            DaDecl::Enumeration(enumeration) => {
                for variant in &mut enumeration.variants {
                    if let Some(value) = &mut variant.value {
                        walk_expr(value);
                    }
                }
            }
            DaDecl::Alias(_) => {}
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

fn walk_block(block: &mut DaBlock) {
    block.stmts.iter_mut().for_each(walk_stmt);
}

fn walk_stmt(stmt: &mut DaStmt) {
    match stmt {
        DaStmt::Var { init, .. } | DaStmt::Let { init, .. } => {
            if let Some(init) = init {
                walk_expr(init);
            }
        }
        DaStmt::Param { default, .. } => {
            if let Some(default) = default {
                walk_expr(default);
            }
        }
        DaStmt::Expr(expr) => walk_expr(expr),
        DaStmt::Decl(decl) => decl.fold_numeric_conversions(),
    }
}

fn walk_expr(expr: &mut DaExpr) {
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
            walk_expr(inner);
            if *op == "-" {
                if let Some(negated) = negated_signed_constant(inner) {
                    *expr = negated;
                }
            }
        }
        Field(inner, _)
        | SafeField(inner, _)
        | Delete(inner)
        | Addr(inner)
        | Deref(inner)
        | DerefExplicit(inner)
        | Unsafe(inner) => walk_expr(inner),
        Index(left, right)
        | SafeIndex(left, right)
        | Op2 { left, right, .. }
        | Assign(left, right)
        | AssignOp { left, right, .. }
        | Pipe(left, right)
        | While(left, right) => {
            walk_expr(left);
            walk_expr(right);
        }
        Op3 { cond, then, else_ } => {
            walk_expr(cond);
            walk_expr(then);
            walk_expr(else_);
        }
        Call(callee, args) | New(callee, args) => {
            walk_expr(callee);
            args.iter_mut().for_each(walk_expr);
        }
        Block(block) => walk_block(block),
        IfThenElse {
            cond,
            then,
            elifs,
            else_,
        } => {
            walk_expr(cond);
            walk_expr(then);
            for (elif_cond, elif_body) in elifs {
                walk_expr(elif_cond);
                walk_expr(elif_body);
            }
            if let Some(else_) = else_ {
                walk_expr(else_);
            }
        }
        For { sources, body, .. } => {
            sources.iter_mut().for_each(walk_expr);
            walk_expr(body);
        }
        Return(value) => {
            if let Some(value) = value {
                walk_expr(value);
            }
        }
        MakeStruct { fields, .. } => {
            for (_, value) in fields {
                walk_expr(value);
            }
        }
        MakeArray(items) | MakeFixedArray { items, .. } => items.iter_mut().for_each(walk_expr),
        Cast {
            kind,
            expr: inner,
            to,
        } => {
            walk_expr(inner);
            if *kind == CastKind::Cast && to.is_numeric() {
                let operand = std::mem::replace(&mut **inner, DaExpr::ConstNull);
                *expr = DaExpr::numeric_conversion(operand, to.clone());
            }
        }
    }
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
}
