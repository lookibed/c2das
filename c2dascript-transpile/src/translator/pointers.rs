//! Pointer operation translation — ported from c2rust.
use super::*;

impl<'c> Translation<'c> {
    /// Convert address-of operator.
    pub fn convert_address_of(
        &self,
        ctx: ExprContext,
        cqual_type: CQualTypeId,
        arg: CExprId,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        // &*x → x
        if let CExprKind::Unary(_, CUnOp::Deref, target, _) = &self.ast_context[arg].kind {
            return self.convert_expr(ctx, *target, Some(cqual_type));
        }
        let inner = self.convert_expr(ctx.used(), arg, None)?;
        Ok(WithStmts::new_val(DaExpr::Unsafe(Box::new(DaExpr::Addr(Box::new(inner.val))))))
    }

    /// Convert dereference operator.
    pub fn convert_deref(
        &self,
        ctx: ExprContext,
        cqual_type: CQualTypeId,
        arg: CExprId,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        // *&x → x
        if let CExprKind::Unary(_, CUnOp::AddressOf, target, _) = &self.ast_context[arg].kind {
            return self.convert_expr(ctx.used(), *target, Some(cqual_type));
        }
        let inner = self.convert_expr(ctx.used(), arg, None)?;
        Ok(WithStmts::new_val(DaExpr::Deref(Box::new(inner.val))))
    }

    /// Convert array subscript expression.
    pub fn convert_array_subscript(
        &self,
        ctx: ExprContext,
        lhs: CExprId,
        rhs: CExprId,
        qual_ty: CQualTypeId,
        override_ty: Option<CQualTypeId>,
        _deref: bool,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let lhs_val = self.convert_expr(ctx, lhs, Some(qual_ty))?;
        let rhs_val = self.convert_expr(ctx, rhs, None)?;
        let is_ptr = self.is_pointer_type(qual_ty.ctype);
        let expr = DaExpr::Index(Box::new(lhs_val.val), Box::new(rhs_val.val));
        if let Some(expected_ty) = override_ty {
            let ty = self.convert_type(expected_ty.ctype)?;
            Ok(WithStmts::new_val(DaExpr::Cast {
                kind: das_ast::CastKind::Cast,
                expr: Box::new(expr),
                to: ty,
            }).merge_unsafe(lhs_val.is_unsafe || rhs_val.is_unsafe || is_ptr))
        } else {
            Ok(WithStmts::new_val(expr).merge_unsafe(lhs_val.is_unsafe || rhs_val.is_unsafe || is_ptr))
        }
    }

    /// Generate null pointer expression.
    pub fn null_ptr(&self, _type_id: CTypeId) -> TranslationResult<DaExpr> {
        Ok(DaExpr::ConstNull)
    }

    /// Check if a pointer is null.
    pub fn convert_pointer_is_null(
        &self,
        val: DaExpr,
        is_null: bool,
    ) -> TranslationResult<DaExpr> {
        if is_null {
            Ok(DaExpr::Op2 {
                op: "==",
                left: Box::new(val),
                right: Box::new(DaExpr::ConstNull),
            })
        } else {
            Ok(DaExpr::Op2 {
                op: "!=",
                left: Box::new(val),
                right: Box::new(DaExpr::ConstNull),
            })
        }
    }
}
