//! Macro translation — minimal stub.
//! daScript has no macro system; macros are either expanded or skipped.
use super::*;

impl<'c> Translation<'c> {
    pub fn convert_macro(
        &self,
        _ctx: ExprContext,
        _decl_id: CDeclId,
        name: &str,
    ) -> TranslationResult<DaDecl> {
        // Skip macros in daScript — emit as comment if possible
        Err(TranslationError::generic("macro not supported in daScript"))
    }

    pub fn convert_const_macro_expansion(
        &self,
        _ctx: ExprContext,
        _expr_id: CExprId,
        _override_ty: Option<CQualTypeId>,
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        Ok(None)
    }

    pub fn convert_fn_macro_invocation(
        &self,
        _ctx: ExprContext,
        _text: &str,
    ) -> Option<WithStmts<DaExpr>> {
        None
    }

    pub fn expr_is_expanded_macro(
        &self,
        _ctx: ExprContext,
        _expr_id: CExprId,
        _override_ty: Option<CQualTypeId>,
    ) -> bool {
        false
    }
}
