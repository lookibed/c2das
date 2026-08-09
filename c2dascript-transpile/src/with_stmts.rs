use das_ast::{DaBlock, DaExpr, DaStmt};
use std::iter::FromIterator;
use std::mem;

#[derive(Clone, Debug)]
pub struct WithStmts<T> {
    pub stmts: Vec<DaStmt>,
    pub val: T,
    pub is_unsafe: bool,
}

impl<T> WithStmts<T> {
    pub fn new(stmts: Vec<DaStmt>, val: T) -> Self {
        WithStmts {
            stmts,
            val,
            is_unsafe: false,
        }
    }

    pub fn new_val(val: T) -> Self {
        WithStmts {
            stmts: vec![],
            val,
            is_unsafe: false,
        }
    }

    pub fn and_then<U, F>(self, f: F) -> WithStmts<U>
    where
        F: FnOnce(T) -> WithStmts<U>,
    {
        let mut next = f(self.val);
        let mut stmts = self.stmts;
        stmts.append(&mut next.stmts);
        WithStmts {
            val: next.val,
            stmts,
            is_unsafe: self.is_unsafe || next.is_unsafe,
        }
    }

    pub fn and_then_try<U, E, F>(self, f: F) -> Result<WithStmts<U>, E>
    where
        F: FnOnce(T) -> Result<WithStmts<U>, E>,
    {
        let mut next = f(self.val)?;
        let mut stmts = self.stmts;
        stmts.append(&mut next.stmts);
        Ok(WithStmts {
            val: next.val,
            stmts,
            is_unsafe: self.is_unsafe || next.is_unsafe,
        })
    }

    pub fn map<U, F>(self, f: F) -> WithStmts<U>
    where
        F: FnOnce(T) -> U,
    {
        WithStmts {
            val: f(self.val),
            stmts: self.stmts,
            is_unsafe: self.is_unsafe,
        }
    }

    pub fn try_map<U, E, F>(self, f: F) -> Result<WithStmts<U>, E>
    where
        F: FnOnce(T) -> Result<U, E>,
    {
        Ok(WithStmts {
            val: f(self.val)?,
            stmts: self.stmts,
            is_unsafe: self.is_unsafe,
        })
    }

    pub fn zip<U>(self, mut next: WithStmts<U>) -> WithStmts<(T, U)> {
        let mut stmts = self.stmts;
        stmts.append(&mut next.stmts);
        WithStmts {
            val: (self.val, next.val),
            stmts,
            is_unsafe: self.is_unsafe || next.is_unsafe,
        }
    }

    pub fn set_unsafe(mut self) -> Self {
        self.is_unsafe = true;
        self
    }

    pub fn merge_unsafe(mut self, is_unsafe: bool) -> Self {
        self.is_unsafe = self.is_unsafe || is_unsafe;
        self
    }

    pub fn into_stmts(self) -> Vec<DaStmt> {
        self.stmts
    }

    pub fn into_value(self) -> T {
        self.val
    }

    pub fn discard_unsafe(mut self) -> Self {
        self.is_unsafe = false;
        self
    }

    pub fn into_stmts_and_val(self) -> (Vec<DaStmt>, T) {
        (self.stmts, self.val)
    }

    pub fn stmts(&self) -> &[DaStmt] {
        &self.stmts
    }

    pub fn stmts_mut(&mut self) -> &mut Vec<DaStmt> {
        &mut self.stmts
    }

    pub fn is_unsafe(&self) -> bool {
        self.is_unsafe
    }

    pub fn add_stmt(mut self, stmt: DaStmt) -> Self {
        self.stmts.push(stmt);
        self
    }

    pub fn prepend_stmts(mut self, mut stmts: Vec<DaStmt>) -> Self {
        stmts.append(&mut self.stmts);
        self.stmts = stmts;
        self
    }

    pub fn is_pure(&self) -> bool {
        self.stmts.is_empty()
    }

    pub fn with_stmts_opt<U>(opt: Option<WithStmts<U>>) -> WithStmts<Option<U>> {
        match opt {
            None => WithStmts::new_val(None),
            Some(x) => WithStmts {
                val: Some(x.val),
                stmts: x.stmts,
                is_unsafe: x.is_unsafe,
            },
        }
    }
}

impl WithStmts<DaExpr> {
    /// Package statements and expression into one block expression
    pub fn to_expr(self) -> DaExpr {
        if self.stmts.is_empty() {
            self.val
        } else {
            DaExpr::Block(self.to_block())
        }
    }

    /// Package statements and expression into a block
    pub fn to_block(mut self) -> DaBlock {
        self.stmts.push(DaStmt::Expr(self.val));
        DaBlock { stmts: self.stmts }
    }

    /// If `is_unsafe` is true, wraps `val` in an `unsafe` block and unsets `is_unsafe`.
    pub fn wrap_unsafe(mut self) -> Self {
        if mem::take(&mut self.is_unsafe) {
            self.val = DaExpr::Unsafe(Box::new(DaExpr::Block(DaBlock {
                stmts: vec![DaStmt::Expr(self.val)],
            })));
        }
        self
    }

    pub fn to_pure_expr(self) -> Option<DaExpr> {
        if self.stmts.is_empty() {
            Some(self.val)
        } else {
            None
        }
    }
}

impl<T> FromIterator<WithStmts<T>> for WithStmts<Vec<T>> {
    fn from_iter<I: IntoIterator<Item = WithStmts<T>>>(value: I) -> Self {
        let mut stmts = vec![];
        let mut res = vec![];
        let mut is_unsafe = false;
        for val in value.into_iter() {
            is_unsafe |= val.is_unsafe;
            let mut s = val.stmts;
            stmts.append(&mut s);
            res.push(val.val);
        }
        WithStmts::new(stmts, res).merge_unsafe(is_unsafe)
    }
}
