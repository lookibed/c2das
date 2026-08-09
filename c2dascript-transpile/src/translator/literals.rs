use crate::c_ast::*;
use crate::diagnostics::TranslationResult;
use crate::translator::Translation;
use das_ast::*;

// type_kind_to_datype is defined in super::mod.rs
use super::type_kind_to_datype;

impl Translation<'_> {
    pub fn convert_literal(&self, ty: CQualTypeId, lit: &CLiteral) -> TranslationResult<DaExpr> {
        let target_is_unsigned = self
            .ast_context
            .resolve_type(ty.ctype)
            .kind
            .is_unsigned_integral_type();
        // If target type maps to uint64 in daScript, wrap literal in explicit uint64() cast.
        // This ensures hex literals used in uint64 context have `uL` suffix via the Cast Display.
        let target_type = self.ast_context.resolve_type(ty.ctype).kind.clone();
        match lit {
            CLiteral::Integer(0, _) if self.is_pointer_type(ty.ctype) => self.null_for_type(ty),
            CLiteral::Integer(val, _base) => {
                let base = if target_is_unsigned || *val > 0x7FFFFFFF {
                    DaExpr::ConstUInt(*val)
                } else {
                    DaExpr::ConstInt(*val as i64)
                };
                // C integer literals acquire their type from their C use-site.
                // Preserve that contract explicitly in daScript AST instead of
                // relying on the printer's default int/uint literal spelling.
                let target_da = type_kind_to_datype(&target_type);
                if target_da.is_numeric() && !matches!(target_da.kind, DaTypeKind::Bool) {
                    Ok(DaExpr::Cast {
                        kind: das_ast::CastKind::Cast,
                        expr: Box::new(base),
                        to: target_da,
                    })
                } else {
                    Ok(base)
                }
            }
            CLiteral::Character(val) => Ok(DaExpr::ConstInt(*val as i64)),
            CLiteral::Floating(val, _) => Ok(DaExpr::ConstDouble(*val)),
            CLiteral::String(val, _width) => {
                let s = String::from_utf8_lossy(val).to_string();
                Ok(DaExpr::ConstString(s))
            }
        }
    }
}
