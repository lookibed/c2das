//! Function translation — ported from c2rust.
use super::*;

impl<'c> Translation<'c> {
    /// Convert a function call expression (pointer calls, variadic, etc.)
    pub fn convert_function_call(
        &self,
        mut ctx: ExprContext,
        func: CExprId,
        args: &[CExprId],
        _call_expr_ty: CQualTypeId,
        override_ty: Option<CQualTypeId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        // Check for builtin calls
        if let CExprKind::ImplicitCast(_, fexp, CastKind::BuiltinFnToFnPtr, _, _) = &self.ast_context[func].kind {
            return self.convert_builtin_call(ctx, *fexp, args);
        }

        let func_expr = self.convert_expr(ctx.used(), func, None)?;
        let mut is_unsafe = func_expr.is_unsafe;
        let mut das_args = vec![];
        for &arg in args {
            let a = self.convert_expr(ctx, arg, None)?;
            is_unsafe |= a.is_unsafe;
            das_args.push(a.val);
        }
        let call = mk().call_expr(func_expr.val, das_args);

        // Apply override type cast if needed
        let result = if let Some(expected_ty) = override_ty {
            let ret_ty = self.convert_type(expected_ty.ctype)?;
            DaExpr::Cast {
                kind: das_ast::CastKind::Cast,
                expr: Box::new(call),
                to: ret_ty,
            }
        } else {
            call
        };

        Ok(WithStmts::new_val(result).merge_unsafe(is_unsafe))
    }

    /// Convert function parameter type
    pub fn convert_function_param(
        &self,
        _ctx: ExprContext,
        typ: CQualTypeId,
    ) -> TranslationResult<DaType> {
        if self.ast_context.is_va_list(typ.ctype) {
            return Ok(DaType::uint64());
        }
        self.convert_type(typ)
    }

    /// Convert call arguments
    pub fn convert_call_args(
        &self,
        ctx: ExprContext,
        exprs: &[CExprId],
        arg_tys: Option<&[CQualTypeId]>,
        _is_variadic: bool,
    ) -> TranslationResult<WithStmts<Vec<DaExpr>>> {
        let arg_tys = arg_tys.unwrap_or(&[]);
        exprs
            .iter()
            .enumerate()
            .map(|(n, arg)| self.convert_call_arg(ctx, *arg, arg_tys.get(n).copied()))
            .collect()
    }

    /// Convert a single call argument
    fn convert_call_arg(
        &self,
        ctx: ExprContext,
        expr_id: CExprId,
        override_ty: Option<CQualTypeId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        self.convert_expr(ctx, expr_id, override_ty)
    }
}
