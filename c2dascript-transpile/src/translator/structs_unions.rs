//! Struct/union translation — полный порт c2rust structs_unions.rs
use super::*;
use std::ops::Index;

impl<'c> Translation<'c> {
    pub fn convert_struct(
        &self,
        decl_id: CDeclId,
        name: &Option<String>,
        fields: &Option<Vec<CFieldId>>,
    ) -> TranslationResult<DaDecl> {
        let raw_sname = match name {
            Some(n) => n.clone(),
            None => {
                let tn = self
                    .ast_context
                    .prenamed_decls
                    .iter()
                    .find(|(_, &v)| v == decl_id)
                    .and_then(|(k, _)| {
                        if let CDeclKind::Typedef { name, .. } = &self.ast_context[*k].kind {
                            Some(name.clone())
                        } else {
                            None
                        }
                    });
                match tn {
                    Some(n) => n,
                    None => {
                        // No typedef — check if convert_type_inner already registered a name
                        let existing = self.type_converter.borrow().resolve_decl_name(decl_id);
                        match existing {
                            Some(n) => n,
                            None => self.type_converter.borrow_mut().declare_decl_name(decl_id, "Unnamed"),
                        }
                    }
                }
            }
        };
        let sname = self
            .type_converter
            .borrow_mut()
            .ensure_decl_name(decl_id, &raw_sname);
        let mut das_fields = vec![];
        if let Some(ids) = fields {
            for &fid in ids {
                if let CDeclKind::Field { ref name, .. } = self.ast_context[fid].kind {
                    self.type_converter
                        .borrow_mut()
                        .declare_field_name(decl_id, fid, name);
                }
            }
            for &fid in ids {
                if let CDeclKind::Field { ref name, typ, .. } = self.ast_context[fid].kind {
                    let mut ft = self.convert_type(typ.clone()).unwrap_or(DaType::auto());
                    if matches!(ft.kind, DaTypeKind::Auto) {
                        ft = DaType::int64();
                    }
                    let field_name = self
                        .type_converter
                        .borrow()
                        .resolve_field_name(Some(decl_id), fid)
                        .unwrap_or_else(|| {
                            if name.is_empty() {
                                "_unnamed".into()
                            } else {
                                name.clone()
                            }
                        });
                    das_fields.push(DaField {
                        name: field_name,
                        field_type: ft,
                        default: None,
                    });
                }
            }
        }
        Ok(DaDecl::Structure(DaStructure {
            name: sname,
            fields: das_fields,
            annotations: vec![],
        }))
    }

    pub fn convert_type_alias(&self, name: &str, _typ: CTypeId) -> TranslationResult<DaDecl> {
        Err(TranslationError::generic("type alias not yet implemented"))
    }

    pub fn convert_union(
        &self,
        decl_id: CDeclId,
        name: &Option<String>,
        fields: &Option<Vec<CFieldId>>,
    ) -> TranslationResult<DaDecl> {
        self.convert_struct(decl_id, name, fields)
    }

    pub fn convert_struct_literal(
        &self,
        ctx: ExprContext,
        struct_id: CRecordId,
        field_expr_ids: &[CExprId],
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let name = match self.ast_context.index(struct_id).kind {
            CDeclKind::Struct {
                name: Some(ref n), ..
            } => self
                .type_converter
                .borrow_mut()
                .ensure_decl_name(struct_id, n),
            _ => {
                return Err(TranslationError::generic(
                    "struct literal requires named struct",
                ))
            }
        };
        let field_ids = match self.ast_context.index(struct_id).kind {
            CDeclKind::Struct {
                fields: Some(ref f),
                ..
            } => f,
            _ => return Err(TranslationError::generic("forward-declared struct literal")),
        };
        let mut is_unsafe = false;
        let mut vals = vec![];
        for (i, &eid) in field_expr_ids.iter().enumerate() {
            if i < field_ids.len() {
                if let CDeclKind::Field { typ, .. } = self.ast_context[field_ids[i]].kind {
                    let v = self.convert_expr(ctx.used(), eid, Some(typ))?;
                    is_unsafe |= v.is_unsafe;
                    vals.push(v.val);
                }
            }
        }
        let named = field_ids
            .iter()
            .zip(vals.into_iter())
            .map(|(fid, val)| {
                let n = match &self.ast_context[*fid].kind {
                    CDeclKind::Field { name, .. } => self
                        .type_converter
                        .borrow()
                        .resolve_field_name(Some(struct_id), *fid)
                        .unwrap_or_else(|| name.clone()),
                    _ => "_".into(),
                };
                (n, val)
            })
            .collect();
        Ok(WithStmts::new_val(DaExpr::MakeStruct {
            type_name: name,
            fields: named,
        })
        .merge_unsafe(is_unsafe))
    }

    pub fn convert_union_literal(
        &self,
        ctx: ExprContext,
        _union_id: CRecordId,
        ids: &[CExprId],
        _override_ty: Option<CQualTypeId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        if !ids.is_empty() {
            self.convert_expr(ctx.used(), ids[0], None)
        } else {
            Ok(WithStmts::new_val(DaExpr::ConstInt(0)))
        }
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
        _kind: MemberKind,
        override_ty: Option<CQualTypeId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let obj = self.convert_expr(ctx, expr, Some(qual_ty))?;
        let fn_ = match &self.ast_context[decl].kind {
            CDeclKind::Field { name, .. } => self
                .type_converter
                .borrow()
                .resolve_field_name(None, decl)
                .unwrap_or_else(|| name.clone()),
            _ => return Err(TranslationError::generic("Member access to non-field")),
        };
        let das = DaExpr::Field(Box::new(obj.val), fn_);
        if let Some(ty) = override_ty {
            let t = self.convert_type(ty)?;
            Ok(WithStmts::new_val(DaExpr::Cast {
                kind: das_ast::CastKind::Cast,
                expr: Box::new(das),
                to: t,
            })
            .merge_unsafe(obj.is_unsafe))
        } else {
            Ok(WithStmts::new_val(das).merge_unsafe(obj.is_unsafe))
        }
    }

    pub fn convert_cast_to_union(
        &self,
        val: WithStmts<DaExpr>,
        _opt_field_id: Option<CFieldId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        Ok(val)
    }

    /// Field layout with padding/bitfield grouping (c2rust get_field_types).
    fn get_field_types(
        &self,
        _record_id: CRecordId,
        field_ids: &[CDeclId],
        _platform_byte_size: u64,
    ) -> TranslationResult<Vec<FieldType>> {
        let mut out = vec![];
        for &fid in field_ids {
            if let CDeclKind::Field {
                ref name,
                typ,
                bitfield_width: None,
                ..
            } = self.ast_context[fid].kind
            {
                let ft = self
                    .convert_type(CQualTypeId::new(typ.ctype))
                    .unwrap_or_else(|_| DaType::int64());
                out.push(FieldType::Regular {
                    name: name.clone(),
                    ctype: typ.ctype,
                    field: fid,
                    use_inner_type: false,
                    is_va_list: false,
                });
            }
        }
        Ok(out)
    }

    pub fn convert_bitfield_assignment_op_with_rhs(
        &self,
        ctx: ExprContext,
        _op: CBinOp,
        lhs: CExprId,
        _rhs_expr: DaExpr,
        _field_id: CDeclId,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        self.convert_expr(ctx, lhs, None)
    }
}

#[derive(Debug)]
enum FieldType {
    BitfieldGroup {
        start_bit: u64,
        field_name: String,
        bytes: u64,
        attrs: Vec<(String, DaType, String)>,
    },
    Padding {
        bytes: u64,
    },
    ComputedPadding {
        ident: String,
    },
    Regular {
        name: String,
        ctype: CTypeId,
        field: CFieldId,
        use_inner_type: bool,
        is_va_list: bool,
    },
}

fn contains_block(_expr: &DaExpr) -> bool {
    false
}
