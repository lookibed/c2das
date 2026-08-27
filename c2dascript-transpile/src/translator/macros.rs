//! Macro provenance lowering.
//!
//! Clang expands C macros before they reach `CExprKind`; the C AST retains
//! provenance in `macro_invocations`/`macro_expansion_text`.  Thus this module
//! deliberately lowers the expansion AST once, never reconstructs or rewrites
//! macro text in the printer. Builtins and predefined expressions are separate
//! C AST forms handled by their dedicated lowering paths.
use super::*;
use crate::format_translation_err;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum MacroOrigin {
    None,
    ExpandedObject,
    ExpandedFunction,
}

impl<'c> Translation<'c> {
    pub fn macro_origin(&self, expr_id: CExprId) -> MacroOrigin {
        let Some(stack) = self.ast_context.macro_invocations.get(&expr_id) else {
            return MacroOrigin::None;
        };
        match stack.last().map(|id| &self.ast_context[*id].kind) {
            Some(CDeclKind::MacroObject { .. }) => MacroOrigin::ExpandedObject,
            Some(CDeclKind::MacroFunction { .. }) => MacroOrigin::ExpandedFunction,
            _ => MacroOrigin::None,
        }
    }

    /// Macro declarations carry provenance only. Their executable semantics
    /// are represented by the already-expanded expression nodes.
    pub fn convert_macro(
        &self,
        _ctx: ExprContext,
        decl_id: CDeclId,
        name: &str,
    ) -> TranslationResult<DaDecl> {
        Err(format_translation_err!(
            self.ast_context.display_loc(&self.ast_context[decl_id].loc),
            "macro declaration `{}` has no standalone C AST value; its expanded AST is lowered at use sites",
            name,
        ))
    }

    /// A const macro expansion is already a normal C expression. Returning
    /// `None` deliberately delegates it to the normal AST lowering, retaining
    /// C evaluation order and side effects exactly once.
    pub fn convert_const_macro_expansion(
        &self,
        _ctx: ExprContext,
        _expr_id: CExprId,
        _override_ty: Option<CQualTypeId>,
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        Ok(None)
    }

    /// Function-like macros are also pre-expanded by Clang. Text is metadata,
    /// never an input to daScript generation.
    pub fn convert_fn_macro_invocation(
        &self,
        _ctx: ExprContext,
        _text: &str,
    ) -> Option<WithStmts<DaExpr>> {
        None
    }

    /// Clang's predefined expression node has already supplied the semantic
    /// expression (for example `__LINE__`/`__FILE__` forms). It is distinct
    /// from macro text and must follow ordinary expression lowering once.
    pub fn convert_predefined_expression(
        &self,
        ctx: ExprContext,
        expr_id: CExprId,
        override_ty: Option<CQualTypeId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        self.convert_expr(ctx, expr_id, override_ty)
    }

    /// GNU `({ statements; value; })` is a real C AST form, not macro text.
    /// Preserve prefix side effects and return the final expression value.
    pub fn convert_gnu_statement_expression(
        &self,
        ctx: ExprContext,
        stmt_id: CStmtId,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let CStmtKind::Compound(children) = &self.ast_context[stmt_id].kind else {
            return Err(format_translation_err!(
                self.ast_context.display_loc(&self.ast_context[stmt_id].loc),
                "unsupported statement expression body",
            ));
        };
        let Some((&last, prefix)) = children.split_last() else {
            return Err(format_translation_err!(
                self.ast_context.display_loc(&self.ast_context[stmt_id].loc),
                "empty statement expression",
            ));
        };
        let CStmtKind::Expr(value_id) = self.ast_context[last].kind else {
            return Err(format_translation_err!(
                self.ast_context.display_loc(&self.ast_context[last].loc),
                "statement expression has no final value",
            ));
        };
        let mut stmts = vec![];
        let mut is_unsafe = false;
        for &child in prefix {
            if matches!(self.ast_context[child].kind, CStmtKind::Decls(_)) {
                return Err(format_translation_err!(
                    self.ast_context.display_loc(&self.ast_context[child].loc),
                    "unsupported statement expression declaration boundary",
                ));
            }
            let lowered = self.convert_stmt(child)?;
            is_unsafe |= lowered.is_unsafe;
            stmts.extend(lowered.val);
        }
        let value = self.convert_expr(ctx.used(), value_id, None)?;
        is_unsafe |= value.is_unsafe;
        stmts.extend(value.stmts);
        Ok(WithStmts {
            stmts,
            val: value.val,
            is_unsafe,
        })
    }

    pub fn expr_is_expanded_macro(
        &self,
        _ctx: ExprContext,
        expr_id: CExprId,
        _override_ty: Option<CQualTypeId>,
    ) -> bool {
        self.macro_origin(expr_id) != MacroOrigin::None
    }
}
