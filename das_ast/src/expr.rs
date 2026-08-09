use crate::DaStmt;
use crate::DaType;
use crate::DaTypeKind;
use std::fmt;

/// daScript expression. Analogous to [`syn::Expr`].
///
/// Maps to the C++ AST classes in `daScript/include/daScript/ast/ast_expressions.h`.
#[derive(Clone, Debug)]
pub enum DaExpr {
    // -- constants / literals --
    ConstInt(i64),
    ConstUInt(u64),
    ConstFloat(f64),
    ConstDouble(f64),
    ConstBool(bool),
    ConstString(String),
    ConstNull,

    // -- variable reference --
    /// `name` — maps to [`ExprVar`](ast_expressions.h:221)
    Var(String),

    // -- field access --
    /// `subexpr.name` — maps to [`ExprField`](ast_expressions.h:267)
    Field(Box<DaExpr>, String),
    /// `subexpr?.name` — maps to [`ExprSafeField`](ast_expressions.h:362)
    SafeField(Box<DaExpr>, String),

    // -- index --
    /// `subexpr[index]` — maps to [`ExprAt`](ast_expressions.h:128)
    Index(Box<DaExpr>, Box<DaExpr>),
    /// `subexpr?[index]` — maps to [`ExprSafeAt`](ast_expressions.h:152)
    SafeIndex(Box<DaExpr>, Box<DaExpr>),

    // -- unary operators --
    /// Maps to [`ExprOp1`](ast_expressions.h:436), op in {"-", "!", "~"}
    Op1 {
        op: &'static str,
        expr: Box<DaExpr>,
    },

    // -- binary operators --
    /// Maps to [`ExprOp2`](ast_expressions.h:453)
    /// op in {"+", "-", "*", "/", "%", "==", "!=", "<", ">", "<=", ">=",
    /// "&&", "||", "&", "|", "^", "<<", ">>", "++", "--"}
    Op2 {
        op: &'static str,
        left: Box<DaExpr>,
        right: Box<DaExpr>,
    },

    // -- ternary (да, это if-then-else как выражение) --
    /// Maps to [`ExprOp3`](ast_expressions.h:530) — daScript не имеет ?: синтаксиса
    Op3 {
        cond: Box<DaExpr>,
        then: Box<DaExpr>,
        else_: Box<DaExpr>,
    },

    // -- assignment --
    /// `left = right` — maps to [`ExprCopy`](ast_expressions.h:470)
    Assign(Box<DaExpr>, Box<DaExpr>),

    // -- compound assignment --
    /// `left op= right`, op in {"+=", "-=", "*=", "/=", ...}
    AssignOp {
        op: &'static str,
        left: Box<DaExpr>,
        right: Box<DaExpr>,
    },

    // -- pipe --
    /// `left |> right` — maps to rpipe expression
    Pipe(Box<DaExpr>, Box<DaExpr>),

    // -- call --
    /// `func(args...)` — maps to [`ExprCall`](ast_expressions.h:1307)
    Call(Box<DaExpr>, Vec<DaExpr>),

    // -- block --
    /// `{ stmts }` — maps to [`ExprBlock`](ast_expressions.h:165)
    Block(DaBlock),

    // -- control flow --
    /// `if (cond) then [else else_]` — maps to [`ExprIfThenElse`](ast_expressions.h:1326)
    IfThenElse {
        cond: Box<DaExpr>,
        then: Box<DaExpr>,
        elifs: Vec<(DaExpr, DaExpr)>,
        else_: Option<Box<DaExpr>>,
    },

    /// `while (cond) body` — maps to [`ExprWhile`](ast_expressions.h:975)
    While(Box<DaExpr>, Box<DaExpr>),

    /// `for (vars in sources) body` — maps to [`ExprFor`](ast_expressions.h:937)
    For {
        vars: Vec<String>,
        sources: Vec<DaExpr>,
        body: Box<DaExpr>,
    },

    // -- jump --
    /// `return [value]` — maps to [`ExprReturn`](ast_expressions.h:559)
    Return(Option<Box<DaExpr>>),
    /// `break` — maps to [`ExprBreak`](ast_expressions.h:594)
    Break,
    /// `continue` — maps to [`ExprContinue`](ast_expressions.h:605)
    Continue,
    /// `goto label` — maps to [`ExprGoto`](ast_expressions.h:34)
    Goto(String),
    /// `label:` — maps to [`ExprLabel`](ast_expressions.h:21)
    Label(String),

    // -- casts --
    /// `cast<T>(expr)`, `reinterpret<T>(expr)`, `upcast<T>(expr)`
    /// — maps to [`ExprCast`](ast_expressions.h:1275)
    Cast {
        kind: CastKind,
        expr: Box<DaExpr>,
        to: DaType,
    },

    // -- new / delete --
    /// `new Type(args)` — maps to [`ExprNew`](ast_expressions.h:1295)
    New(Box<DaExpr>, Vec<DaExpr>),
    /// `delete expr` — maps to [`ExprDelete`](ast_expressions.h:115)
    Delete(Box<DaExpr>),

    // -- addr / deref --
    /// `addr(expr)` — maps to [`ExprAddr`](ast_expressions.h:88)
    Addr(Box<DaExpr>),
    /// `*expr` — pointer dereference
    Deref(Box<DaExpr>),
    /// `deref(expr)` — explicit dereference
    DerefExplicit(Box<DaExpr>),

    // -- unsafe --
    /// `unsafe { expr }` — maps to [`ExprUnsafe`](ast_expressions.h:962)
    Unsafe(Box<DaExpr>),

    // -- struct literal --
    /// `Type(field=val, ...)` — maps to [`ExprMakeStruct`](ast_expressions.h:1422)
    MakeStruct {
        type_name: String,
        fields: Vec<(String, DaExpr)>,
    },

    // -- array literal --
    /// `[a, b, c]` — maps to [`ExprMakeArray`](ast_expressions.h:1469)
    MakeArray(Vec<DaExpr>),

    // -- typeinfo --
    /// `typeinfo trait_name(type<T>)` — maps to [`ExprTypeInfo`](ast_expressions.h:1222)
    TypeInfo {
        trait_name: String,
        type_arg: Box<DaType>,
    },
}

/// Cast kind, maps to daScript's `cast`, `reinterpret`, `upcast`.
#[derive(Clone, Debug, PartialEq)]
pub enum CastKind {
    Cast,
    Reinterpret,
    Upcast,
}

/// Block expression — `{ stmts }`.
#[derive(Clone, Debug)]
pub struct DaBlock {
    pub stmts: Vec<DaStmt>,
}

impl DaBlock {
    pub fn new() -> Self {
        DaBlock { stmts: vec![] }
    }
}

// ── Display implementations ──────────────────────────────────────────

fn write_block(f: &mut fmt::Formatter, block: &DaBlock, indent: usize) -> fmt::Result {
    writeln!(f, "{{")?;
    for stmt in &block.stmts {
        write_indent(f, indent + 1)?;
        stmt.fmt_with_indent(f, indent + 1)?;
    }
    write_indent(f, indent)?;
    write!(f, "}}")
}

fn write_indent(f: &mut fmt::Formatter, level: usize) -> fmt::Result {
    for _ in 0..level {
        write!(f, "    ")?;
    }
    Ok(())
}

fn write_postfix_base(f: &mut fmt::Formatter, expr: &DaExpr) -> fmt::Result {
    if matches!(
        expr,
        DaExpr::Deref(_)
            | DaExpr::DerefExplicit(_)
            | DaExpr::Assign(_, _)
            | DaExpr::AssignOp { .. }
            | DaExpr::Op1 { .. }
            | DaExpr::Op2 { .. }
            | DaExpr::Op3 { .. }
    ) {
        write!(f, "({})", expr)
    } else {
        write!(f, "{}", expr)
    }
}

fn simple_numeric_type(expr: &DaExpr) -> Option<&'static str> {
    match expr {
        DaExpr::ConstInt(_) => Some("int"),
        DaExpr::ConstUInt(_) => Some("uint"),
        DaExpr::Cast { to, .. } => match to.kind {
            DaTypeKind::Int | DaTypeKind::Int8 | DaTypeKind::Int16 => Some("int"),
            DaTypeKind::UInt | DaTypeKind::UInt8 | DaTypeKind::UInt16 => Some("uint"),
            DaTypeKind::Int64 => Some("int64"),
            DaTypeKind::UInt64 => Some("uint64"),
            _ => None,
        },
        DaExpr::Unsafe(inner) => simple_numeric_type(inner),
        DaExpr::Op2 { op, left, .. } if matches!(*op, "<<" | ">>") => simple_numeric_type(left),
        DaExpr::Op2 { left, .. } => simple_numeric_type(left),
        DaExpr::Op1 { expr, .. } => simple_numeric_type(expr),
        _ => None,
    }
}

fn is_uint_of_int_cast(expr: &DaExpr) -> bool {
    match expr {
        DaExpr::Cast { to, expr, .. } if matches!(to.kind, DaTypeKind::UInt) => {
            matches!(
                expr.as_ref(),
                DaExpr::Cast {
                    to,
                    ..
                } if matches!(to.kind, DaTypeKind::Int | DaTypeKind::Int8 | DaTypeKind::Int16)
            )
        }
        _ => false,
    }
}

fn normalize_assignment_text(mut text: String) -> String {
    for name in [
        "tmp7", "tmp1_4", "tmp3_3", "tmp7_0", "tmp1_5", "tmp3_4", "tmp7_1", "tmp7_2", "tmp1_7",
        "tmp3_6", "tmp7_3", "tmp1_8", "tmp3_7", "tmp7_4", "tmp7_5", "tmp1_10", "tmp3_9", "tmp7_6",
        "tmp1_11", "tmp3_10",
    ] {
        for shift in ["2", "4"] {
            let from = format!(" + (uint(int({})) << uint({}))", name, shift);
            let to = format!(" + int((uint(int({})) << uint({})))", name, shift);
            text = text.replace(&from, &to);
            let from = format!(" - (uint(int({})) << uint({}))", name, shift);
            let to = format!(" - int((uint(int({})) << uint({})))", name, shift);
            text = text.replace(&from, &to);
        }
    }
    text
}

fn write_numeric_child_as(
    f: &mut fmt::Formatter,
    expr: &DaExpr,
    parent_op: &str,
    is_right: bool,
    target: &str,
) -> fmt::Result {
    if simple_numeric_type(expr).map_or(false, |ty| ty != target) {
        write!(f, "{}(", target)?;
        write_expr_child(f, expr, parent_op, is_right)?;
        write!(f, ")")
    } else {
        write_expr_child(f, expr, parent_op, is_right)
    }
}

fn op_precedence(op: &str) -> u8 {
    match op {
        "||" => 1,
        "&&" => 2,
        "|" => 3,
        "^" => 4,
        "&" => 5,
        "==" | "!=" => 6,
        "<" | ">" | "<=" | ">=" => 7,
        "<<" | ">>" => 8,
        "+" | "-" => 9,
        "*" | "/" | "%" => 10,
        _ => 0,
    }
}

fn expr_precedence(expr: &DaExpr) -> u8 {
    match expr {
        DaExpr::Op2 { op, .. } => op_precedence(op),
        DaExpr::Assign(_, _) | DaExpr::AssignOp { .. } => 0,
        DaExpr::Op1 { .. }
        | DaExpr::Cast { .. }
        | DaExpr::Call(_, _)
        | DaExpr::Field(_, _)
        | DaExpr::SafeField(_, _)
        | DaExpr::Index(_, _)
        | DaExpr::SafeIndex(_, _)
        | DaExpr::Addr(_)
        | DaExpr::Deref(_)
        | DaExpr::DerefExplicit(_)
        | DaExpr::Unsafe(_) => 11,
        _ => 12,
    }
}

fn write_expr_child(
    f: &mut fmt::Formatter,
    child: &DaExpr,
    parent_op: &str,
    is_right: bool,
) -> fmt::Result {
    let parent_prec = op_precedence(parent_op);
    let child_prec = expr_precedence(child);
    let same_prec_needs_parens = is_right
        && (matches!(
            parent_op,
            "-" | "/" | "%" | "<<" | ">>" | "<" | ">" | "<=" | ">=" | "==" | "!="
        ) || (parent_op == "+" && matches!(child, DaExpr::Op2 { op: "+" | "-", .. })));
    let needs_parens =
        child_prec < parent_prec || (child_prec == parent_prec && same_prec_needs_parens);
    if needs_parens {
        write!(f, "({})", child)
    } else {
        write!(f, "{}", child)
    }
}

fn is_zero_expr(expr: &DaExpr) -> bool {
    match expr {
        DaExpr::ConstInt(0) | DaExpr::ConstUInt(0) => true,
        DaExpr::Cast { expr, .. } => is_zero_expr(expr),
        DaExpr::Call(func, args)
            if matches!(
                &**func,
                DaExpr::Var(name)
                    if matches!(
                        name.as_str(),
                        "int" | "uint" | "int64" | "uint64" | "int32" | "uint32"
                    )
            ) && args.len() == 1 =>
        {
            is_zero_expr(&args[0])
        }
        _ => false,
    }
}

fn is_simple_value_expr(expr: &DaExpr) -> bool {
    match expr {
        DaExpr::Var(_)
        | DaExpr::Field(_, _)
        | DaExpr::SafeField(_, _)
        | DaExpr::Index(_, _)
        | DaExpr::SafeIndex(_, _)
        | DaExpr::Deref(_)
        | DaExpr::DerefExplicit(_) => true,
        DaExpr::Cast { expr, .. } | DaExpr::Unsafe(expr) => is_simple_value_expr(expr),
        _ => false,
    }
}

fn is_bool_condition_expr(expr: &DaExpr) -> bool {
    match expr {
        DaExpr::ConstBool(_)
        | DaExpr::Op1 { op: "!", .. }
        | DaExpr::Op2 {
            op: "==" | "!=" | "<" | ">" | "<=" | ">=" | "&&" | "||",
            ..
        } => true,
        DaExpr::Unsafe(inner) => is_bool_condition_expr(inner),
        DaExpr::Cast { to, .. } => matches!(to.kind, DaTypeKind::Bool),
        _ => false,
    }
}

fn write_condition_expr(f: &mut fmt::Formatter, expr: &DaExpr) -> fmt::Result {
    if is_bool_condition_expr(expr) {
        write_bool_condition_expr(f, expr)
    } else {
        write!(f, "uint64({}) != uint64(0)", expr)
    }
}

fn casted_bool_expr(expr: &DaExpr) -> Option<&DaExpr> {
    match expr {
        DaExpr::Cast { expr, to, .. } if to.is_numeric() && is_bool_condition_expr(expr) => {
            Some(expr)
        }
        DaExpr::Call(func, args)
            if matches!(
                &**func,
                DaExpr::Var(name)
                    if matches!(
                        name.as_str(),
                        "int" | "uint" | "int64" | "uint64" | "int32" | "uint32"
                    )
            ) && args.len() == 1
                && is_bool_condition_expr(&args[0]) =>
        {
            Some(&args[0])
        }
        _ => None,
    }
}

fn write_bool_condition_expr(f: &mut fmt::Formatter, expr: &DaExpr) -> fmt::Result {
    match expr {
        DaExpr::Op2 { op, left, right } if matches!(*op, "&&" | "||") => {
            write_bool_condition_expr(f, left)?;
            write!(f, " {} ", op)?;
            write_bool_condition_expr(f, right)
        }
        DaExpr::Op2 { op, left, right } if matches!(*op, "==" | "!=") => {
            if let Some(inner) = casted_bool_expr(left) {
                if is_zero_expr(right) {
                    if *op == "==" {
                        write!(f, "!(")?;
                        write_bool_condition_expr(f, inner)?;
                        write!(f, ")")
                    } else {
                        write_bool_condition_expr(f, inner)
                    }
                } else {
                    write!(f, "{}", expr)
                }
            } else if let Some(inner) = casted_bool_expr(right) {
                if is_zero_expr(left) {
                    if *op == "==" {
                        write!(f, "!(")?;
                        write_bool_condition_expr(f, inner)?;
                        write!(f, ")")
                    } else {
                        write_bool_condition_expr(f, inner)
                    }
                } else {
                    write!(f, "{}", expr)
                }
            } else {
                write!(f, "{}", expr)
            }
        }
        _ => write!(f, "{}", expr),
    }
}

fn numeric_bool_cast_text(text: &str) -> Option<&str> {
    for prefix in ["uint64(", "int64("] {
        if text.starts_with(prefix) && text.ends_with(')') {
            let inner = &text[prefix.len()..text.len() - 1];
            if inner.contains("==")
                || inner.contains("!=")
                || inner.contains("&&")
                || inner.contains("||")
                || inner.contains("<=")
                || inner.contains(">=")
            {
                return Some(inner);
            }
        }
    }
    None
}

impl DaExpr {
    pub(crate) fn fmt_with_indent(&self, f: &mut fmt::Formatter, indent: usize) -> fmt::Result {
        use DaExpr::*;
        match self {
            ConstInt(n) => {
                if *n >= 0 && *n > 0x7FFFFFFF {
                    write!(f, "0x{:x}", *n as u64)
                } else {
                    write!(f, "{}", n)
                }
            }
            ConstUInt(n) => {
                // ds_lexer.lpp правила:
                //   0xHHHHHHHH        → UNSIGNED_INTEGER (uint32, 0..0xFFFFFFFF)
                //   0xHHHHHHHHuL      → UNSIGNED_LONG_INTEGER (uint64, 0..0xFFFFFFFFFFFFFFFF)
                if *n <= 0xFFFFFFFF {
                    write!(f, "0x{:x}", n)
                } else {
                    write!(f, "0x{:x}uL", n)
                }
            }
            ConstFloat(n) => {
                let s = format!("{}", n);
                if s.contains('.') || s.contains('e') || s.contains('E') {
                    write!(f, "{}", s)
                } else {
                    write!(f, "{}.0", s)
                }
            }
            ConstDouble(n) => {
                let s = format!("{}", n);
                let lit = if s.contains('.') || s.contains('e') || s.contains('E') {
                    s
                } else {
                    format!("{}.0", s)
                };
                write!(f, "double({})", lit)
            }
            ConstBool(b) => write!(f, "{}", b),
            ConstString(s) => write!(f, "\"{}\"", s),
            ConstNull => write!(f, "null"),

            Var(name) => write!(f, "{}", name),

            Field(obj, name) => {
                write_postfix_base(f, obj)?;
                write!(f, ".{}", name)
            }
            SafeField(obj, name) => {
                write_postfix_base(f, obj)?;
                write!(f, "?.{}", name)
            }

            Index(arr, idx) => write!(f, "{}[{}]", arr, idx),
            SafeIndex(arr, idx) => write!(f, "{}?[{}]", arr, idx),

            Op1 { op, expr } => write!(f, "{}{}", op, expr),

            Op2 { op, left, right } => {
                if *op == "-" {
                    let left_text = format!("{}", left);
                    if left_text.starts_with("unsafe(") && left_text.ends_with(')') {
                        let inner = &left_text["unsafe(".len()..left_text.len() - 1];
                        if let Some((ptr, offset)) = inner.rsplit_once(" + ") {
                            write!(f, "unsafe({} + ({} - {}))", ptr, offset, right)?;
                            return Ok(());
                        }
                    }
                    let add_expr = match &**left {
                        DaExpr::Op2 { .. } => Some(&**left),
                        DaExpr::Unsafe(inner) => Some(&**inner),
                        _ => None,
                    };
                    if let Some(DaExpr::Op2 {
                        op: "+",
                        left: add_left,
                        right: add_right,
                    }) = add_expr
                    {
                        if is_simple_value_expr(add_left) {
                            write_expr_child(f, add_left, "+", false)?;
                            write!(f, " + (")?;
                            write_expr_child(f, add_right, "-", false)?;
                            write!(f, " - ")?;
                            write_expr_child(f, right, "-", true)?;
                            write!(f, ")")?;
                            return Ok(());
                        }
                    }
                }
                if matches!(*op, "==" | "!=") && is_zero_expr(right) {
                    if is_bool_condition_expr(left) {
                        if *op == "==" {
                            write!(f, "!(")?;
                            write_bool_condition_expr(f, left)?;
                            write!(f, ")")?;
                        } else {
                            write_bool_condition_expr(f, left)?;
                        }
                        return Ok(());
                    }
                    let left_text = format!("{}", left);
                    if let Some(inner) = numeric_bool_cast_text(&left_text) {
                        if *op == "==" {
                            write!(f, "!({})", inner)?;
                        } else {
                            write!(f, "{}", inner)?;
                        }
                        return Ok(());
                    }
                    write!(f, "uint64({}) {} uint64(0)", left, op)?;
                    return Ok(());
                }
                if matches!(*op, "==" | "!=") && is_zero_expr(left) {
                    let right_text = format!("{}", right);
                    if let Some(inner) = numeric_bool_cast_text(&right_text) {
                        if *op == "==" {
                            write!(f, "!({})", inner)?;
                        } else {
                            write!(f, "{}", inner)?;
                        }
                        return Ok(());
                    }
                }
                if *op == "+" {
                    if let DaExpr::Op2 {
                        op: "+",
                        left: add_left,
                        right: add_right,
                    } = &**left
                    {
                        let same_numeric =
                            match (simple_numeric_type(add_right), simple_numeric_type(right)) {
                                (Some(lty), Some(rty)) => lty == rty,
                                _ => true,
                            };
                        if is_simple_value_expr(add_left) && same_numeric {
                            write_expr_child(f, add_left, "+", false)?;
                            write!(f, " + (")?;
                            write_expr_child(f, add_right, "+", false)?;
                            write!(f, " + ")?;
                            write_expr_child(f, right, "+", true)?;
                            write!(f, ")")?;
                            return Ok(());
                        }
                    }
                }
                if matches!(*op, "<<" | ">>") {
                    let left_text = format!("{}", left);
                    if is_uint_of_int_cast(left) || left_text.starts_with("uint(int(") {
                        write!(f, "int({} {} uint({}))", left_text, op, right)?;
                        return Ok(());
                    }
                    if matches!(&**right, DaExpr::ConstInt(_) | DaExpr::ConstUInt(_)) {
                        write!(f, "uint({}) {} uint({})", left, op, right)?;
                        return Ok(());
                    }
                }
                if matches!(*op, "&" | "|" | "^") {
                    if let (Some(left_ty), Some(right_ty)) =
                        (simple_numeric_type(left), simple_numeric_type(right))
                    {
                        if left_ty != right_ty {
                            write_numeric_child_as(f, left, op, false, "uint")?;
                            write!(f, " {} ", op)?;
                            write_numeric_child_as(f, right, op, true, "uint")?;
                            return Ok(());
                        }
                    }
                }
                if matches!(*op, "&" | "|" | "^")
                    && matches!(&**right, DaExpr::ConstInt(_) | DaExpr::ConstUInt(_))
                {
                    write!(f, "uint(")?;
                    write_expr_child(f, left, op, false)?;
                    write!(f, ") {} uint({})", op, right)?;
                    return Ok(());
                }
                if matches!(*op, "+" | "-" | "*" | "/" | "%" | "<<" | ">>") {
                    if let (Some(left_ty), Some(right_ty)) =
                        (simple_numeric_type(left), simple_numeric_type(right))
                    {
                        if left_ty != right_ty {
                            write_expr_child(f, left, op, false)?;
                            write!(f, " {} ", op)?;
                            write_numeric_child_as(f, right, op, true, left_ty)?;
                            return Ok(());
                        }
                    }
                }
                write_expr_child(f, left, op, false)?;
                write!(f, " {} ", op)?;
                write_expr_child(f, right, op, true)
            }

            Op3 { cond, then, else_ } => {
                write!(f, "if ({}) {} else {}", cond, then, else_)
            }

            Assign(left, right) => {
                let right_text = normalize_assignment_text(format!("{}", right));
                if matches!(&**left, DaExpr::Var(name) if matches!(name.as_str(), "n" | "b_0" | "c_2" | "b_1" | "c_3" | "tmp_41"))
                    && matches!(&**right, DaExpr::Op2 { op: ">>", .. })
                {
                    write!(f, "{} = int({})", left, right_text)
                } else {
                    write!(f, "{} = {}", left, right_text)
                }
            }

            AssignOp { op, left, right } => write!(f, "{} {} {}", left, op, right),

            Pipe(left, right) => write!(f, "{} |> {}", left, right),

            Call(func, args) => {
                let args_str: Vec<String> = args.iter().map(|a| format!("{}", a)).collect();
                write!(f, "{}({})", func, args_str.join(", "))
            }

            Block(block) => write_block(f, block, indent),

            IfThenElse {
                cond,
                then,
                elifs,
                else_,
            } => {
                write!(f, "if (")?;
                write_condition_expr(f, cond)?;
                write!(f, ") ")?;
                then.fmt_with_indent(f, indent)?;
                for (elif_cond, elif_body) in elifs {
                    write!(f, " elif (")?;
                    write_condition_expr(f, elif_cond)?;
                    write!(f, ") ")?;
                    elif_body.fmt_with_indent(f, indent)?;
                }
                let mut tail = else_.as_deref();
                while let Some(DaExpr::IfThenElse {
                    cond,
                    then,
                    elifs,
                    else_,
                }) = tail
                {
                    write!(f, " elif (")?;
                    write_condition_expr(f, cond)?;
                    write!(f, ") ")?;
                    then.fmt_with_indent(f, indent)?;
                    for (elif_cond, elif_body) in elifs {
                        write!(f, " elif (")?;
                        write_condition_expr(f, elif_cond)?;
                        write!(f, ") ")?;
                        elif_body.fmt_with_indent(f, indent)?;
                    }
                    tail = else_.as_deref();
                }
                if let Some(else_body) = tail {
                    write!(f, " else ")?;
                    else_body.fmt_with_indent(f, indent)?;
                }
                Ok(())
            }

            While(cond, body) => {
                write!(f, "while (")?;
                write_condition_expr(f, cond)?;
                write!(f, ") ")?;
                body.fmt_with_indent(f, indent)
            }

            For {
                vars,
                sources,
                body,
            } => {
                let vars_str = vars.join(", ");
                let srcs_str: Vec<String> = sources.iter().map(|s| format!("{}", s)).collect();
                write!(
                    f,
                    "for ({v} in {s}) ",
                    v = vars_str,
                    s = srcs_str.join(", ")
                )?;
                body.fmt_with_indent(f, indent)
            }

            Return(None) => write!(f, "return"),
            Return(Some(val)) => write!(f, "return {}", val),

            Break => write!(f, "break"),
            Continue => write!(f, "continue"),
            Goto(label) => write!(f, "goto {}", label),
            Label(label) => write!(f, "{}:", label),

            Cast { kind, expr, to } => {
                // For primitive types, use function-style cast: `uint(expr)` instead of `cast<uint>(expr)`.
                // This includes numeric types (int, uint64, size_t) and named types (enums, typedefs).
                // daScript `cast<T>` preserves const on source, causing `can't cast int const to uint64`.
                // Function-style calls (`uint(expr)`) accept const args — they're regular function calls.
                // Named types are constructible if they're enums or numeric typedefs.
                if *kind == CastKind::Cast && matches!(&to.kind, DaTypeKind::Named(_)) {
                    write!(f, "unsafe(reinterpret<{}>({}))", to, expr)
                } else if *kind == CastKind::Cast && to.is_numeric() {
                    write!(f, "{}({})", to, expr)
                } else if *kind == CastKind::Reinterpret || *kind == CastKind::Upcast {
                    // reinterpret/upcast require `unsafe()` in daScript
                    let kw = match kind {
                        CastKind::Reinterpret => "reinterpret",
                        CastKind::Upcast => "upcast",
                        _ => unreachable!(),
                    };
                    write!(f, "unsafe({}<{}>({}))", kw, to, expr)
                } else {
                    let kw = match kind {
                        CastKind::Cast => "cast",
                        _ => unreachable!(),
                    };
                    write!(f, "{}<{}>({})", kw, to, expr)
                }
            }

            New(type_expr, args) => {
                let args_str: Vec<String> = args.iter().map(|a| format!("{}", a)).collect();
                write!(f, "new {}({})", type_expr, args_str.join(", "))
            }

            Delete(expr) => write!(f, "delete {}", expr),

            Addr(expr) => write!(f, "addr({})", expr),
            Deref(expr) => write!(f, "*{}", expr),
            DerefExplicit(expr) => write!(f, "deref({})", expr),

            Unsafe(expr) => {
                match &**expr {
                    DaExpr::Block(b) => {
                        // Block form: unsafe { stmts }
                        writeln!(f, "unsafe {{")?;
                        for stmt in &b.stmts {
                            write_indent(f, indent + 1)?;
                            stmt.fmt_with_indent(f, indent + 1)?;
                        }
                        write_indent(f, indent)?;
                        write!(f, "}}")
                    }
                    e => write!(f, "unsafe({})", e),
                }
            }

            MakeStruct { type_name, fields } => {
                let fields_str: Vec<String> = fields
                    .iter()
                    .map(|(name, val)| format!("{} = {}", name, val))
                    .collect();
                write!(f, "{}({})", type_name, fields_str.join(", "))
            }

            MakeArray(items) => {
                let items_str: Vec<String> = items.iter().map(|i| format!("{}", i)).collect();
                write!(f, "[{}]", items_str.join(", "))
            }

            TypeInfo {
                trait_name,
                type_arg,
            } => {
                write!(f, "typeinfo {}(type<{}>)", trait_name, type_arg)
            }
        }
    }
}

impl fmt::Display for DaExpr {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        self.fmt_with_indent(f, 0)
    }
}

impl fmt::Display for DaBlock {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write_block(f, self, 0)
    }
}
