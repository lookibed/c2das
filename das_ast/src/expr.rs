use std::fmt;
use crate::DaType;
use crate::DaStmt;

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
    Op1 { op: &'static str, expr: Box<DaExpr> },

    // -- binary operators --
    /// Maps to [`ExprOp2`](ast_expressions.h:453)
    /// op in {"+", "-", "*", "/", "%", "==", "!=", "<", ">", "<=", ">=",
    /// "&&", "||", "&", "|", "^", "<<", ">>", "++", "--"}
    Op2 { op: &'static str, left: Box<DaExpr>, right: Box<DaExpr> },

    // -- ternary (да, это if-then-else как выражение) --
    /// Maps to [`ExprOp3`](ast_expressions.h:530) — daScript не имеет ?: синтаксиса
    Op3 { cond: Box<DaExpr>, then: Box<DaExpr>, else_: Box<DaExpr> },

    // -- assignment --
    /// `left = right` — maps to [`ExprCopy`](ast_expressions.h:470)
    Assign(Box<DaExpr>, Box<DaExpr>),

    // -- compound assignment --
    /// `left op= right`, op in {"+=", "-=", "*=", "/=", ...}
    AssignOp { op: &'static str, left: Box<DaExpr>, right: Box<DaExpr> },

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
    Cast { kind: CastKind, expr: Box<DaExpr>, to: DaType },

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

impl DaExpr {
    pub(crate) fn fmt_with_indent(&self, f: &mut fmt::Formatter, indent: usize) -> fmt::Result {
        use DaExpr::*;
        match self {
            ConstInt(n) => write!(f, "{}", n),
            ConstUInt(n) => write!(f, "{}u", n),
            ConstFloat(n) => write!(f, "{}", n),
            ConstDouble(n) => write!(f, "{}", n),
            ConstBool(b) => write!(f, "{}", b),
            ConstString(s) => write!(f, "\"{}\"", s),
            ConstNull => write!(f, "null"),

            Var(name) => write!(f, "{}", name),

            Field(obj, name) => write!(f, "{}.{}", obj, name),
            SafeField(obj, name) => write!(f, "{}?.{}", obj, name),

            Index(arr, idx) => write!(f, "{}[{}]", arr, idx),
            SafeIndex(arr, idx) => write!(f, "{}?[{}]", arr, idx),

            Op1 { op, expr } => write!(f, "{}{}", op, expr),

            Op2 { op, left, right } => write!(f, "{} {} {}", left, op, right),

            Op3 { cond, then, else_ } => {
                write!(f, "if ({}) {} else {}", cond, then, else_)
            }

            Assign(left, right) => write!(f, "{} = {}", left, right),

            AssignOp { op, left, right } => write!(f, "{} {} {}", left, op, right),

            Pipe(left, right) => write!(f, "{} |> {}", left, right),

            Call(func, args) => {
                let args_str: Vec<String> = args.iter().map(|a| format!("{}", a)).collect();
                write!(f, "{}({})", func, args_str.join(", "))
            }

            Block(block) => write_block(f, block, indent),

            IfThenElse { cond, then, elifs, else_ } => {
                write!(f, "if ({}) ", cond)?;
                then.fmt_with_indent(f, indent)?;
                for (elif_cond, elif_body) in elifs {
                    write!(f, " elif ({}) ", elif_cond)?;
                    elif_body.fmt_with_indent(f, indent)?;
                }
                if let Some(else_body) = else_ {
                    write!(f, " else ")?;
                    else_body.fmt_with_indent(f, indent)?;
                }
                Ok(())
            }

            While(cond, body) => {
                write!(f, "while ({}) ", cond)?;
                body.fmt_with_indent(f, indent)
            }

            For { vars, sources, body } => {
                let vars_str = vars.join(", ");
                let srcs_str: Vec<String> = sources.iter().map(|s| format!("{}", s)).collect();
                write!(f, "for ({v} in {s}) ", v = vars_str, s = srcs_str.join(", "))?;
                body.fmt_with_indent(f, indent)
            }

            Return(None) => write!(f, "return"),
            Return(Some(val)) => write!(f, "return {}", val),

            Break => write!(f, "break"),
            Continue => write!(f, "continue"),
            Goto(label) => write!(f, "goto {}", label),
            Label(label) => write!(f, "{}:", label),

            Cast { kind, expr, to } => {
                let kw = match kind {
                    CastKind::Cast => "cast",
                    CastKind::Reinterpret => "reinterpret",
                    CastKind::Upcast => "upcast",
                };
                write!(f, "{}<{}>({})", kw, to, expr)
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
            },

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

            TypeInfo { trait_name, type_arg } => {
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
