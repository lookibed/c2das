use das_ast::*;

pub fn mk() -> DaBuilder {
    DaBuilder
}

pub struct DaBuilder;

pub trait Make<T> {
    fn make(self, mk: &DaBuilder) -> T;
}

impl Make<String> for &str {
    fn make(self, _mk: &DaBuilder) -> String {
        self.to_string()
    }
}

impl Make<String> for String {
    fn make(self, _mk: &DaBuilder) -> String {
        self
    }
}

impl DaBuilder {
    // ── literals ──
    pub fn int_lit(self, n: i64) -> DaExpr {
        DaExpr::ConstInt(n)
    }

    pub fn uint_lit(self, n: u64) -> DaExpr {
        DaExpr::ConstUInt(n)
    }

    pub fn float_lit(self, n: f64) -> DaExpr {
        DaExpr::ConstFloat(n)
    }

    pub fn bool_lit(self, b: bool) -> DaExpr {
        DaExpr::ConstBool(b)
    }

    pub fn string_lit(self, s: &str) -> DaExpr {
        DaExpr::ConstString(s.to_string())
    }

    pub fn null_lit(self) -> DaExpr {
        DaExpr::ConstNull
    }

    // ── variables ──
    pub fn ident<N: Make<String>>(self, name: N) -> DaExpr {
        DaExpr::Var(name.make(&self))
    }

    // ── operators ──
    pub fn unary_op(self, op: &'static str, expr: DaExpr) -> DaExpr {
        DaExpr::Op1 { op, expr: Box::new(expr) }
    }

    pub fn binary_op(self, op: &'static str, left: DaExpr, right: DaExpr) -> DaExpr {
        DaExpr::Op2 { op, left: Box::new(left), right: Box::new(right) }
    }

    // ── call ──
    pub fn call_expr(self, func: DaExpr, args: Vec<DaExpr>) -> DaExpr {
        DaExpr::Call(Box::new(func), args)
    }

    // ── block ──
    pub fn block(self, stmts: Vec<DaStmt>) -> DaExpr {
        DaExpr::Block(DaBlock { stmts })
    }

    // ── control flow ──
    pub fn return_expr(self, val: Option<DaExpr>) -> DaExpr {
        DaExpr::Return(val.map(Box::new))
    }

    pub fn return_(self, val: DaExpr) -> DaExpr {
        DaExpr::Return(Some(Box::new(val)))
    }

    pub fn if_then_else(self, cond: DaExpr, then: DaExpr, else_: Option<DaExpr>) -> DaExpr {
        DaExpr::IfThenElse {
            cond: Box::new(cond),
            then: Box::new(then),
            elifs: vec![],
            else_: else_.map(Box::new),
        }
    }

    pub fn while_expr(self, cond: DaExpr, body: DaExpr) -> DaExpr {
        DaExpr::While(Box::new(cond), Box::new(body))
    }

    pub fn break_expr(self) -> DaExpr {
        DaExpr::Break
    }

    pub fn continue_expr(self) -> DaExpr {
        DaExpr::Continue
    }

    // ── statements ──
    pub fn var_stmt<N: Make<String>>(self, name: N, ty: DaType, init: Option<DaExpr>) -> DaStmt {
        DaStmt::Var { name: name.make(&self), var_type: ty, init }
    }

    pub fn let_stmt<N: Make<String>>(self, name: N, init: Option<DaExpr>) -> DaStmt {
        DaStmt::Let { name: name.make(&self), init }
    }

    pub fn expr_stmt(self, expr: DaExpr) -> DaStmt {
        DaStmt::Expr(expr)
    }

    // ── declarations ──
    pub fn fn_decl<N: Make<String>>(self, name: N, params: Vec<DaStmt>, ret_type: DaType, body: Option<DaExpr>) -> DaDecl {
        DaDecl::Function(DaFunction {
            name: name.make(&self),
            params,
            ret_type,
            body,
            annotations: vec![],
            is_public: false,
            is_unsafe: false,
        })
    }

    pub fn struct_decl<N: Make<String>>(self, name: N, fields: Vec<DaField>) -> DaDecl {
        DaDecl::Structure(DaStructure {
            name: name.make(&self),
            fields,
            annotations: vec![],
        })
    }

    pub fn enum_decl<N: Make<String>>(self, name: N, base: DaType, variants: Vec<DaEnumVariant>) -> DaDecl {
        DaDecl::Enumeration(DaEnumeration {
            name: name.make(&self),
            base_type: base,
            variants,
        })
    }

    pub fn field<N: Make<String>>(self, name: N, ty: DaType, default: Option<DaExpr>) -> DaField {
        DaField {
            name: name.make(&self),
            field_type: ty,
            default,
        }
    }

    pub fn enum_variant<N: Make<String>>(self, name: N, value: Option<DaExpr>) -> DaEnumVariant {
        DaEnumVariant {
            name: name.make(&self),
            value,
        }
    }

    pub fn param<N: Make<String>>(self, name: N, ty: DaType, default: Option<DaExpr>) -> DaStmt {
        DaStmt::Param { name: name.make(&self), param_type: ty, default, is_mutable: false }
    }

    pub fn param_mut<N: Make<String>>(self, name: N, ty: DaType, default: Option<DaExpr>) -> DaStmt {
        DaStmt::Param { name: name.make(&self), param_type: ty, default, is_mutable: true }
    }

    // ── module ──
    pub fn module(self, decls: Vec<DaDecl>) -> DaModule {
        DaModule { decls, ..DaModule::new() }
    }

    // ── types ──
    pub fn ty_int(self) -> DaType { DaType::Int }
    pub fn ty_uint(self) -> DaType { DaType::UInt }
    pub fn ty_float(self) -> DaType { DaType::Float }
    pub fn ty_double(self) -> DaType { DaType::Double }
    pub fn ty_bool(self) -> DaType { DaType::Bool }
    pub fn ty_void(self) -> DaType { DaType::Void }
    pub fn ty_string(self) -> DaType { DaType::String_ }
    pub fn ty_named<N: Make<String>>(self, name: N) -> DaType { DaType::Named(name.make(&self)) }
    pub fn ty_pointer(self, inner: DaType) -> DaType { DaType::Pointer(Box::new(inner)) }
    pub fn ty_array(self, inner: DaType) -> DaType { DaType::Array(Box::new(inner)) }
}
