/// Wraps a daScript expression with possible preceding statements.
#[derive(Clone, Debug)]
pub struct WithStmts<T> {
    pub stmts: Vec<das_ast::DaStmt>,
    pub val: T,
    pub is_unsafe: bool,
}

impl<T> WithStmts<T> {
    pub fn new(stmts: Vec<das_ast::DaStmt>, val: T) -> Self {
        WithStmts { stmts, val, is_unsafe: false }
    }

    pub fn new_val(val: T) -> Self {
        WithStmts { stmts: vec![], val, is_unsafe: false }
    }

    pub fn map<U, F: FnOnce(T) -> U>(self, f: F) -> WithStmts<U> {
        WithStmts {
            stmts: self.stmts,
            val: f(self.val),
            is_unsafe: self.is_unsafe,
        }
    }

    pub fn and_then_try<U, E, F: FnOnce(T) -> Result<WithStmts<U>, E>>(
        self,
        f: F,
    ) -> Result<WithStmts<U>, E> {
        let val = f(self.val)?;
        Ok(WithStmts {
            stmts: self.stmts,
            ..val
        })
    }

    pub fn to_expr(&self) -> das_ast::DaExpr
    where T: Clone + Into<das_ast::DaExpr>
    {
        self.val.clone().into()
    }
}
