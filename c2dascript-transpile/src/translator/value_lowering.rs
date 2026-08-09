//! Canonical lowering from a translated daScript expression to a C value use-site.

use super::*;

#[derive(Clone, Copy, Debug)]
pub(crate) enum ValueSite {
    Return,
    Assignment,
    CallArg,
    BinaryOperand,
    BinaryResult,
}

impl<'c> Translation<'c> {
    /// Materialize semantics which C assigns to a value at a typed use-site,
    /// but daScript does not perform implicitly.
    pub(crate) fn lower_to_c_value(
        &self,
        value: WithStmts<DaExpr>,
        source: Option<CQualTypeId>,
        target: DaType,
        _site: ValueSite,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let actual = Self::infer_type(&value.val);
        if actual.as_ref().map_or(false, |ty| matches!(ty.kind, DaTypeKind::Bool))
            && target.is_numeric()
            && !matches!(target.kind, DaTypeKind::Bool)
        {
            let cast = DaExpr::Cast {
                kind: das_ast::CastKind::Cast,
                expr: Box::new(value.val),
                to: target,
            };
            let is_unsafe = value.is_unsafe;
            let mut stmts = value.stmts;
            let (lowered_stmts, lowered_value) = self
                .lower_bool_numeric_cast_arg(cast)
                .expect("bool-to-numeric cast must lower to statements");
            stmts.extend(lowered_stmts);
            return Ok(WithStmts::new(stmts, lowered_value).merge_unsafe(is_unsafe));
        }

        let source_is_storage_byte = source.map_or(false, |ty| {
            matches!(
                self.ast_context.resolve_type(ty.ctype).kind,
                CTypeKind::UInt8 | CTypeKind::UChar
            )
        });
        if source_is_storage_byte && target.is_numeric() {
            return Ok(value.map(|expr| DaExpr::Cast {
                kind: das_ast::CastKind::Cast,
                expr: Box::new(strip_numeric_casts(expr)),
                to: target,
            }));
        }

        Ok(value)
    }
}

fn strip_numeric_casts(expr: DaExpr) -> DaExpr {
    match expr {
        DaExpr::Cast {
            kind: das_ast::CastKind::Cast,
            expr,
            to,
        } if to.is_numeric() && !matches!(to.kind, DaTypeKind::Bool) => strip_numeric_casts(*expr),
        expr => expr,
    }
}
