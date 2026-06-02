use crate::c_ast::*;
use crate::translator::Translation;
use crate::diagnostics::TranslationResult;
use das_ast::*;

impl Translation<'_> {
    pub fn convert_literal(&self, ty: CQualTypeId, lit: &CLiteral) -> TranslationResult<DaExpr> {
        match lit {
            CLiteral::Integer(0, _) if self.is_pointer_type(ty.ctype) => {
                // C int* p = 0 → daScript var p : int? = null
                Ok(DaExpr::ConstNull)
            }
            CLiteral::Integer(val, _base) => Ok(DaExpr::ConstInt(*val as i64)),
            CLiteral::Character(val) => Ok(DaExpr::ConstInt(*val as i64)),
            CLiteral::Floating(val, _) => Ok(DaExpr::ConstDouble(*val)),
            CLiteral::String(val, _width) => {
                let s = String::from_utf8_lossy(val).to_string();
                Ok(DaExpr::ConstString(s))
            }
        }
    }
}
