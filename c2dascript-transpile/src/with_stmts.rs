/// Wraps a daScript expression with possible preceding statements.
/// Mirrors c2rust's WithStmts pattern for unsafe tracking.
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

    /// Mark this expression/statement as containing unsafe operations.
    pub fn set_unsafe(mut self) -> Self {
        self.is_unsafe = true;
        self
    }

    /// OR-combine the unsafe flag from another source.
    pub fn merge_unsafe(mut self, is_unsafe: bool) -> Self {
        self.is_unsafe = self.is_unsafe || is_unsafe;
        self
    }

    /// Discard the unsafe flag (used when parent context is already unsafe).
    pub fn discard_unsafe(mut self) -> Self {
        self.is_unsafe = false;
        self
    }

    /// Query whether this expression/statement contains unsafe operations.
    pub fn is_unsafe(&self) -> bool {
        self.is_unsafe
    }
}
