use crate::c_ast::*;
use crate::diagnostics::{TranslationError, TranslationResult};
use crate::with_stmts::WithStmts;
use das_ast::{DaExpr, DaStmt};
use std::ops::Index;

use super::{ExprContext, Translation};

fn is_lvalue(e: &DaExpr) -> bool {
    matches!(
        e,
        DaExpr::Deref(_)
            | DaExpr::Var(_)
            | DaExpr::Field(..)
            | DaExpr::SafeField(..)
            | DaExpr::Index(..)
            | DaExpr::SafeIndex(..)
            | DaExpr::Addr(_)
    )
}

fn is_simple_lvalue(e: &DaExpr) -> bool {
    match e {
        DaExpr::Var(_) => true,
        DaExpr::Deref(expr)
        | DaExpr::Field(expr, _)
        | DaExpr::SafeField(expr, _)
        | DaExpr::Index(expr, _)
        | DaExpr::SafeIndex(expr, _) => is_simple_lvalue(expr),
        _ => false,
    }
}

pub struct NamedReference<R> {
    pub lvalue: DaExpr,
    pub rvalue: R,
}

impl<R> NamedReference<R> {
    pub fn map_rvalue<S, F: Fn(R) -> S>(self, f: F) -> NamedReference<S> {
        let NamedReference { lvalue, rvalue } = self;
        NamedReference {
            lvalue,
            rvalue: f(rvalue),
        }
    }
}

impl<'c> Translation<'c> {
    pub fn name_reference_write(
        &self,
        ctx: ExprContext,
        reference: CExprId,
    ) -> TranslationResult<WithStmts<NamedReference<()>>> {
        self.name_reference(ctx, reference, false)
            .map(|ws| ws.map(|named_ref| named_ref.map_rvalue(|_| ())))
    }

    pub fn name_reference_write_read(
        &self,
        ctx: ExprContext,
        reference: CExprId,
    ) -> TranslationResult<WithStmts<NamedReference<DaExpr>>> {
        self.name_reference(ctx, reference, true).map(|ws| {
            ws.map(|named_ref| {
                named_ref.map_rvalue(|rvalue| {
                    rvalue.expect(
                "When called with uses_read=true, name_reference should always return an rvalue"
            )
                })
            })
        })
    }

    fn read(&self, _reference_ty: CQualTypeId, write: DaExpr) -> TranslationResult<DaExpr> {
        Ok(write)
    }

    fn name_reference(
        &self,
        ctx: ExprContext,
        reference: CExprId,
        uses_read: bool,
    ) -> TranslationResult<WithStmts<NamedReference<Option<DaExpr>>>> {
        let reference_ty = self
            .ast_context
            .index(reference)
            .kind
            .get_qual_type()
            .ok_or_else(|| TranslationError::generic("bad reference type"))?;

        let reference = self.convert_expr(ctx.used(), reference, Some(reference_ty))?;
        reference.and_then_try(|reference| {
            if !uses_read && is_lvalue(&reference) {
                Ok(WithStmts::new_val(NamedReference {
                    lvalue: reference,
                    rvalue: None,
                }))
            } else if is_simple_lvalue(&reference) {
                Ok(WithStmts::new_val(NamedReference {
                    lvalue: reference.clone(),
                    rvalue: Some(self.read(reference_ty, reference)?),
                }))
            } else {
                let ptr_name = self.renamer.borrow_mut().fresh();
                let compute_ref = DaStmt::Let {
                    name: ptr_name.clone(),
                    init: Some(reference),
                };
                let write = DaExpr::Deref(Box::new(DaExpr::Var(ptr_name)));
                Ok(WithStmts::new(
                    vec![compute_ref],
                    NamedReference {
                        lvalue: write.clone(),
                        rvalue: Some(self.read(reference_ty, write)?),
                    },
                ))
            }
        })
    }
}
