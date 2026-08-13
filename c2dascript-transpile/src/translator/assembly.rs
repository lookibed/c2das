//! Inline assembly boundary for the daScript backend.
//!
//! daScript has no portable representation for GCC/Clang constraint strings,
//! clobbers or target-specific instruction templates.  The only correct
//! fallback is a source-located diagnostic; this module deliberately never
//! substitutes a value, a no-op, or printer-time text repair.
use super::*;
use crate::format_translation_err;

impl<'c> Translation<'c> {
    pub fn convert_inline_assembly(
        &self,
        stmt_id: CStmtId,
        asm: &str,
        inputs: &[AsmOperand],
        outputs: &[AsmOperand],
        clobbers: &[String],
        is_volatile: bool,
    ) -> TranslationResult<WithStmts<Vec<DaStmt>>> {
        Err(format_translation_err!(
            self.ast_context.display_loc(&self.ast_context[stmt_id].loc),
            "unsupported inline asm: template={:?}, inputs={}, outputs={}, clobbers={:?}, volatile={}",
            asm, inputs.len(), outputs.len(), clobbers, is_volatile,
        ))
    }
}
