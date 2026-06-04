//! Struct/union translation — ported from c2rust.
use super::*;

impl<'c> Translation<'c> {
    /// Convert struct literal (designated initializer).
    pub fn convert_struct_literal(
        &self,
        ctx: ExprContext,
        struct_id: CRecordId,
        field_expr_ids: &[CExprId],
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let name = match self.ast_context.index(struct_id).kind {
            CDeclKind::Struct { name: Some(ref n), .. } => n.clone(),
            _ => return Err(TranslationError::generic("struct literal requires named struct")),
        };

        let (field_decl_ids, _platform_byte_size) = match self.ast_context.index(struct_id).kind {
            CDeclKind::Struct { fields: Some(ref f), platform_byte_size, .. } => (f, platform_byte_size),
            _ => return Err(TranslationError::generic("forward-declared struct literal")),
        };

        let mut is_unsafe = false;
        let mut values = vec![];

        for (i, &expr_id) in field_expr_ids.iter().enumerate() {
            if i < field_decl_ids.len() {
                let field_id = field_decl_ids[i];
                if let CDeclKind::Field { typ, .. } = self.ast_context[field_id].kind {
                    let val = self.convert_expr(ctx.used(), expr_id, Some(typ))?;
                    is_unsafe |= val.is_unsafe;
                    values.push(val.val);
                }
            }
        }

        // daScript uses MakeStruct for struct literals
        Ok(WithStmts::new_val(DaExpr::MakeStruct {
            name: name.clone(),
            fields: values,
        }).merge_unsafe(is_unsafe))
    }

    pub fn convert_union(
        &self,
        decl_id: CDeclId,
        name: &Option<String>,
        fields: &Option<Vec<CFieldId>>,
    ) -> TranslationResult<DaDecl> {
        // daScript has no union → map to struct
        self.convert_struct(decl_id, name, fields)
    }

    pub fn convert_union_literal(
        &self,
        ctx: ExprContext,
        union_id: CRecordId,
        ids: &[CExprId],
        override_ty: Option<CQualTypeId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        // Map union literal to struct literal
        let val = if !ids.is_empty() {
            self.convert_expr(ctx.used(), ids[0], None)?
        } else {
            WithStmts::new_val(DaExpr::ConstInt(0))
        };
        Ok(val)
    }

    pub fn convert_struct_zero_initializer(
        &self,
        _ctx: ExprContext,
        _decl_id: CRecordId,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        Ok(WithStmts::new_val(DaExpr::ConstNull))
    }

    pub fn convert_member_expr(
        &self,
        ctx: ExprContext,
        qual_ty: CQualTypeId,
        expr: CExprId,
        decl: CDeclId,
        kind: MemberKind,
        override_ty: Option<CQualTypeId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let obj = self.convert_expr(ctx, expr, Some(qual_ty))?;
        let field_name = match &self.ast_context[decl].kind {
            CDeclKind::Field { name, .. } => name.clone(),
            _ => return Err(TranslationError::generic("Member access to non-field")),
        };
        let das_expr = DaExpr::Field(Box::new(obj.val), field_name);
        if let Some(expected_ty) = override_ty {
            let ty = self.convert_type(expected_ty.ctype)?;
            Ok(WithStmts::new_val(DaExpr::Cast {
                kind: das_ast::CastKind::Cast,
                expr: Box::new(das_expr),
                to: ty,
            }).merge_unsafe(obj.is_unsafe))
        } else {
            Ok(WithStmts::new_val(das_expr).merge_unsafe(obj.is_unsafe))
        }
    }
}
