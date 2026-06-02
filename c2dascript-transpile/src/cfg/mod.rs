/// Minimal CFG module — passes through to translator for simple statements.
/// Full CFG (goto handling, relooper) will be ported later.

use crate::c_ast::*;
use crate::translator::Translation;
use crate::diagnostics::TranslationResult;

pub enum Label {
    FromC(CLabelId, Option<String>),
    Synthetic(u64),
}

/// Convert C statement body into daScript statements.
/// This is a simplified version that delegates to translator directly.
pub fn convert_function_body(
    translator: &Translation,
    body_id: CStmtId,
) -> TranslationResult<Vec<StmtOrDecl>> {
    // For now, just convert the compound statement directly
    let stmts = translator.convert_stmt(body_id)?;
    Ok(stmts.into_iter().map(StmtOrDecl::Stmt).collect())
}

/// Simple representation: either a statement or a declaration
#[derive(Clone)]
pub enum StmtOrDecl {
    Stmt(das_ast::DaStmt),
    Decl(das_ast::DaDecl),
}
