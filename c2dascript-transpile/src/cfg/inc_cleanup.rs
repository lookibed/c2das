use super::*;
use das_ast::{DaExpr, DaStmt};

pub struct IncCleanup {
    in_tail: Option<ImplicitReturnType>,
    brk_lbl: Label,
}

impl IncCleanup {
    pub fn new(in_tail: Option<ImplicitReturnType>, brk_lbl: Label) -> Self {
        IncCleanup { in_tail, brk_lbl }
    }

    pub fn remove_tail_expr(&self, stmts: &mut Vec<DaStmt>) -> bool {
        let mut stmt = if let Some(stmt) = stmts.pop() {
            stmt
        } else {
            return false;
        };
        if self.is_idempotent_tail_expr(&stmt) {
            return true;
        }

        let mut removed_tail_expr = false;

        if let DaStmt::Expr(expr) = &stmt {
            if let DaExpr::IfThenElse { then, else_, .. } = expr {
                // Recurse into if-then-else
                if let DaExpr::Block(ref block) = **then {
                    removed_tail_expr = removed_tail_expr || self.remove_tail_expr_in_block(&block.stmts);
                }
                if let Some(el) = else_ {
                    if let DaExpr::Block(ref block) = **el {
                        removed_tail_expr = removed_tail_expr || self.remove_tail_expr_in_block(&block.stmts);
                    }
                }
            }
        }

        stmts.push(stmt);
        removed_tail_expr
    }

    fn remove_tail_expr_in_block(&self, stmts: &[DaStmt]) -> bool {
        if let Some(last) = stmts.last() {
            self.is_idempotent_tail_expr(last)
        } else {
            false
        }
    }

    fn is_idempotent_tail_expr(&self, stmt: &DaStmt) -> bool {
        if let DaStmt::Expr(expr) = stmt {
            match self.in_tail {
                Some(ImplicitReturnType::Main) => {
                    if let DaExpr::Return(Some(val)) = expr {
                        if let DaExpr::ConstInt(0) = **val {
                            return true;
                        }
                    }
                    false
                }
                Some(ImplicitReturnType::Void) => {
                    if let DaExpr::Return(None) = expr {
                        return true;
                    }
                    false
                }
                _ => {
                    if let DaExpr::Break = expr {
                        return true;
                    }
                    false
                }
            }
        } else {
            false
        }
    }
}
