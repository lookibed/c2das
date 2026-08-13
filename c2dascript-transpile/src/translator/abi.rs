//! Canonical daScript ABI conversions shared by translator lowering paths.
//!
//! C pointers remain typed `T?` in translated program expressions.  Raw
//! `uint64` addresses are an implementation detail used only at explicit ABI
//! boundaries such as the raw-memory runtime and pointer comparisons.

use super::*;

pub(crate) fn null_pointer(pointer: &DaType) -> DaExpr {
    debug_assert!(matches!(pointer.kind, DaTypeKind::Pointer(_)));
    DaExpr::ConstNull
}

impl<'c> Translation<'c> {
    /// Canonical storage boundary: daScript uint8 is a byte container, while
    /// C arithmetic consumes a numeric value.
    pub(crate) fn storage_byte_to_numeric(&self, expr: DaExpr, target: DaType) -> DaExpr {
        debug_assert!(target.is_numeric());
        DaExpr::Cast {
            kind: das_ast::CastKind::Cast,
            expr: Box::new(strip_numeric_casts(expr)),
            to: target,
        }
    }

    /// Canonical typed integer literal boundary for runtime parameters.
    pub(crate) fn integer_literal_for_type(&self, expr: DaExpr, target: DaType) -> DaExpr {
        DaExpr::Cast {
            kind: das_ast::CastKind::Cast,
            expr: Box::new(strip_numeric_literal_casts(expr)),
            to: target,
        }
    }

    /// daScript has no scalar bool-to-number conversion. Materialize C's 0/1
    /// value in statements before another expression consumes it.
    pub(crate) fn bool_to_integer_cast(
        &self,
        expr: DaExpr,
    ) -> Option<(Vec<DaStmt>, DaExpr)> {
        let DaExpr::Cast { kind, expr, to } = expr else { return None; };
        let bool_expr = unwrap_numeric_casts(expr);
        if kind != das_ast::CastKind::Cast
            || !to.is_numeric()
            || matches!(to.kind, DaTypeKind::Bool)
            || !Self::infer_type(&bool_expr).map_or(false, |ty| matches!(ty.kind, DaTypeKind::Bool))
        { return None; }
        let tmp = self.renamer.borrow_mut().fresh();
        let one = self.integer_literal_for_type(DaExpr::ConstInt(1), to.clone());
        let zero = self.integer_literal_for_type(DaExpr::ConstInt(0), to.clone());
        Some((vec![
            DaStmt::Var { name: tmp.clone(), var_type: to, init: Some(zero) },
            mk().expr_stmt(DaExpr::IfThenElse {
                cond: Box::new(bool_expr),
                then: Box::new(DaExpr::Block(DaBlock { stmts: vec![DaStmt::Expr(DaExpr::Assign(Box::new(DaExpr::Var(tmp.clone())), Box::new(one)))] })),
                elifs: vec![], else_: None,
            }),
        ], DaExpr::Var(tmp)))
    }

    pub(crate) fn bool_to_integer(&self, value: WithStmts<DaExpr>) -> WithStmts<DaExpr> {
        let is_unsafe = value.is_unsafe;
        let mut stmts = value.stmts;
        let expr = value.val;
        if let Some((lowered_stmts, lowered_val)) = self.bool_to_integer_cast(expr.clone()) {
            stmts.extend(lowered_stmts);
            WithStmts::new(stmts, lowered_val).merge_unsafe(is_unsafe)
        } else {
            WithStmts::new(stmts, expr).merge_unsafe(is_unsafe)
        }
    }
    pub(crate) fn raw_address_to_pointer(&self, raw_address: DaExpr, pointer: DaType) -> DaExpr {
        debug_assert!(matches!(pointer.kind, DaTypeKind::Pointer(_)));
        DaExpr::Unsafe(Box::new(DaExpr::Cast {
            kind: das_ast::CastKind::Reinterpret,
            expr: Box::new(raw_address),
            to: pointer,
        }))
    }

    pub(crate) fn pointer_to_raw_address(&self, pointer: DaExpr) -> DaExpr {
        DaExpr::Unsafe(Box::new(DaExpr::Cast {
            kind: das_ast::CastKind::Reinterpret,
            expr: Box::new(pointer),
            to: DaType::uint64(),
        }))
    }

    /// Reinterpret a value already represented as a daScript pointer (or an
    /// array-decay value) to another typed C pointer.  Null stays null rather
    /// than becoming an invalid numeric pointer cast.
    pub(crate) fn abi_pointer_cast(&self, pointer: DaExpr, target: DaType) -> DaExpr {
        debug_assert!(matches!(target.kind, DaTypeKind::Pointer(_)));
        if matches!(pointer, DaExpr::ConstNull) {
            return self.null_pointer(&target);
        }
        DaExpr::Unsafe(Box::new(DaExpr::Cast {
            kind: das_ast::CastKind::Reinterpret,
            expr: Box::new(pointer),
            to: target,
        }))
    }

    pub(crate) fn null_pointer(&self, pointer: &DaType) -> DaExpr {
        null_pointer(pointer)
    }

    pub(crate) fn abi_pointer_comparison_operand(&self, expr: DaExpr, is_pointer: bool) -> DaExpr {
        if matches!(expr, DaExpr::ConstNull) {
            return DaExpr::Cast {
                kind: das_ast::CastKind::Cast,
                expr: Box::new(DaExpr::ConstInt(0)),
                to: DaType::uint64(),
            };
        }
        if is_pointer {
            self.pointer_to_raw_address(expr)
        } else {
            DaExpr::Cast {
                kind: das_ast::CastKind::Cast,
                expr: Box::new(expr),
                to: DaType::uint64(),
            }
        }
    }
}

fn strip_numeric_casts(expr: DaExpr) -> DaExpr {
    match expr {
        DaExpr::Cast { kind: das_ast::CastKind::Cast, expr, to }
            if to.is_numeric() && !matches!(to.kind, DaTypeKind::Bool) => strip_numeric_casts(*expr),
        expr => expr,
    }
}

fn strip_numeric_literal_casts(expr: DaExpr) -> DaExpr {
    match expr {
        DaExpr::Cast { kind: das_ast::CastKind::Cast, expr, to } if to.is_numeric() => {
            let inner = strip_numeric_literal_casts(*expr);
            if matches!(inner, DaExpr::ConstInt(_) | DaExpr::ConstUInt(_)) { inner }
            else { DaExpr::Cast { kind: das_ast::CastKind::Cast, expr: Box::new(inner), to } }
        }
        expr => expr,
    }
}

fn unwrap_numeric_casts(mut expr: Box<DaExpr>) -> DaExpr {
    loop {
        match *expr {
            DaExpr::Cast { kind: das_ast::CastKind::Cast, expr: inner, to }
                if to.is_numeric() && !matches!(to.kind, DaTypeKind::Bool) => expr = inner,
            other => return other,
        }
    }
}
