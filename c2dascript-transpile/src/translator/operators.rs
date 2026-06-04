//! Operator translation — ported from c2rust.
use super::*;

impl<'c> Translation<'c> {
    /// Translate a binary expression.
    pub fn convert_binary_expr(
        &self,
        ctx: ExprContext,
        expr_type_id: CQualTypeId,
        op: CBinOp,
        lhs: CExprId,
        rhs: CExprId,
        _opt_lhs_type_id: Option<CQualTypeId>,
        _opt_res_type_id: Option<CQualTypeId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        use CBinOp::*;

        let lhs_val = self.convert_expr(ctx, lhs, Some(expr_type_id))?;
        let rhs_val = self.convert_expr(ctx, rhs, Some(expr_type_id))?;
        let is_ptr_arith = self.is_pointer_type(expr_type_id.ctype);

        match op {
            Assign => Ok(WithStmts::new_val(DaExpr::Assign(
                Box::new(lhs_val.val), Box::new(rhs_val.val),
            )).merge_unsafe(lhs_val.is_unsafe || rhs_val.is_unsafe || is_ptr_arith)),

            op if op.is_assignment() => {
                let das_op = convert_binop(op).map_err(TranslationError::generic)?;
                Ok(WithStmts::new_val(mk().binary_op(das_op, lhs_val.val, rhs_val.val))
                    .merge_unsafe(lhs_val.is_unsafe || rhs_val.is_unsafe || is_ptr_arith))
            }

            Comma => {
                // LHS is discarded, RHS is the result
                Ok(rhs_val)
            }

            _ => {
                let das_op = convert_binop(op).map_err(TranslationError::generic)?;
                Ok(WithStmts::new_val(mk().binary_op(das_op, lhs_val.val, rhs_val.val))
                    .merge_unsafe(lhs_val.is_unsafe || rhs_val.is_unsafe || is_ptr_arith))
            }
        }
    }

    /// Translate a unary operator.
    pub fn convert_unary_operator(
        &self,
        ctx: ExprContext,
        name: CUnOp,
        cqual_type: CQualTypeId,
        arg: CExprId,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        use CUnOp::*;
        match name {
            AddressOf => {
                let inner = self.convert_expr(ctx, arg, Some(cqual_type))?;
                Ok(WithStmts::new_val(DaExpr::Unsafe(Box::new(DaExpr::Addr(Box::new(inner.val))))))
            }
            Deref => {
                let inner = self.convert_expr(ctx, arg, Some(cqual_type))?;
                Ok(WithStmts::new_val(DaExpr::Deref(Box::new(inner.val))))
            }
            Negate => {
                let inner = self.convert_expr(ctx.used(), arg, Some(cqual_type))?;
                Ok(WithStmts::new_val(mk().unary_op("-", inner.val)))
            }
            Plus => self.convert_expr(ctx.used(), arg, Some(cqual_type)),
            Not => {
                let inner = self.convert_expr(ctx, arg, Some(cqual_type))?;
                Ok(WithStmts::new_val(mk().unary_op("!", inner.val)))
            }
            Complement => {
                let inner = self.convert_expr(ctx, arg, Some(cqual_type))?;
                Ok(WithStmts::new_val(mk().unary_op("~", inner.val)))
            }
            Extension => self.convert_expr(ctx, arg, Some(cqual_type)),
            PreIncrement | PreDecrement | PostIncrement | PostDecrement => {
                Err(TranslationError::generic("inc/dec not yet implemented in daScript"))
            }
            Real | Imag | Coawait => {
                Err(TranslationError::generic("unsupported unary operator"))
            }
        }
    }

    /// Translate a pre-increment expression.
    pub fn convert_pre_increment(
        &self,
        ctx: ExprContext,
        ty: CQualTypeId,
        op: CBinOp,
        arg: CExprId,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let inner = self.convert_expr(ctx.used(), arg, Some(ty))?;
        let one = DaExpr::ConstInt(1);
        let das_op = match op {
            CBinOp::AssignAdd => "+",
            CBinOp::AssignSubtract => "-",
            _ => return Err(TranslationError::generic("invalid pre-increment op")),
        };
        Ok(WithStmts::new_val(mk().binary_op(das_op, inner.val, one)))
    }

    /// Translate a post-increment expression.
    pub fn convert_post_increment(
        &self,
        ctx: ExprContext,
        ty: CQualTypeId,
        op: CBinOp,
        arg: CExprId,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        self.convert_pre_increment(ctx, ty, op, arg)
    }
}
