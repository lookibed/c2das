//! SIMD/vector lowering boundary for the daScript backend.
//!
//! Vector AST nodes must be owned here rather than leaking through generic
//! casts/operators.  Until a lane-preserving daScript target contract exists,
//! each node is rejected with its C source location; no scalar approximation
//! is semantically valid for arbitrary shuffle/convert operations.
use super::*;
use crate::format_translation_err;

impl<'c> Translation<'c> {
    pub fn reject_vector_type(&self, type_id: CTypeId) -> TranslationResult<DaType> {
        Err(format_translation_err!(
            self.ast_context.display_loc(&self.ast_context[type_id].loc),
            "unsupported SIMD vector type",
        ))
    }

    pub fn convert_shuffle_vector(
        &self,
        expr_id: CExprId,
        _result_ty: CQualTypeId,
        operands: &[CExprId],
    ) -> TranslationResult<WithStmts<DaExpr>> {
        Err(format_translation_err!(
            self.ast_context.display_loc(&self.ast_context[expr_id].loc),
            "unsupported SIMD shuffle vector with {} operands",
            operands.len(),
        ))
    }

    pub fn convert_vector_conversion(
        &self,
        expr_id: CExprId,
        _result_ty: CQualTypeId,
        operands: &[CExprId],
    ) -> TranslationResult<WithStmts<DaExpr>> {
        Err(format_translation_err!(
            self.ast_context.display_loc(&self.ast_context[expr_id].loc),
            "unsupported SIMD convert vector with {} operands",
            operands.len(),
        ))
    }
}
