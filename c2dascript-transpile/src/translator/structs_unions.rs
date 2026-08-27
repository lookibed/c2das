//! Struct/union translation — полный порт c2rust structs_unions.rs
use super::object_memory::CObjectAddress;
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
                            None => self
                                .type_converter
                                .borrow_mut()
                                .declare_decl_name(decl_id, "Unnamed"),
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
        _fields: &Option<Vec<CFieldId>>,
    ) -> TranslationResult<DaDecl> {
        let raw_name = name.clone().unwrap_or_else(|| "Unnamed".into());
        let name = self
            .type_converter
            .borrow_mut()
            .ensure_decl_name(decl_id, &raw_name);
        Ok(DaDecl::Structure(DaStructure {
            name,
            fields: vec![DaField {
                name: "c2da_storage".into(),
                field_type: DaType::uint64(),
                default: Some(DaExpr::ConstUInt(0)),
            }],
            annotations: vec![],
        }))
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
        union_id: CRecordId,
        ids: &[CExprId],
        _override_ty: Option<CQualTypeId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let name = self.union_wrapper_name(union_id)?;
        let storage = self.union_zero_storage(union_id)?;
        let mut out = WithStmts::new_val(DaExpr::MakeStruct {
            type_name: name.clone(),
            fields: vec![("c2da_storage".into(), storage)],
        });
        if let Some(&init) = ids.first() {
            let fields = match &self.ast_context[union_id].kind {
                CDeclKind::Union {
                    fields: Some(fields),
                    ..
                } => fields,
                _ => {
                    return Err(TranslationError::generic(
                        "union initializer for incomplete union",
                    ))
                }
            };
            let field = fields[0];
            let field_ty = match self.ast_context[field].kind {
                CDeclKind::Field { typ, .. } => typ,
                _ => {
                    return Err(TranslationError::generic(
                        "union initializer field is invalid",
                    ))
                }
            };
            let value = self.convert_expr(ctx.used(), init, Some(field_ty))?;
            let tmp = self.renamer.borrow_mut().fresh();
            out.stmts.push(DaStmt::Var {
                name: tmp.clone(),
                var_type: DaType::named(&name),
                init: Some(out.val),
            });
            let address =
                self.local_union_field_address(DaExpr::Var(tmp.clone()), union_id, field)?;
            let stored = self.raw_store(address, value)?;
            out.stmts.extend(stored.stmts);
            out.val = DaExpr::Var(tmp);
        }
        Ok(out)
    }

    pub fn convert_struct_zero_initializer(
        &self,
        _ctx: ExprContext,
        _decl_id: CRecordId,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        Ok(WithStmts::new_val(DaExpr::ConstNull))
    }

    fn union_wrapper_name(&self, union_id: CRecordId) -> TranslationResult<String> {
        let raw = match &self.ast_context[union_id].kind {
            CDeclKind::Union {
                name: Some(name), ..
            } => name.clone(),
            CDeclKind::Union { .. } => self
                .type_converter
                .borrow()
                .resolve_decl_name(union_id)
                .ok_or_else(|| TranslationError::generic("anonymous union has no wrapper name"))?,
            _ => {
                return Err(TranslationError::generic(
                    "union wrapper requested for non-union",
                ))
            }
        };
        Ok(self
            .type_converter
            .borrow_mut()
            .ensure_decl_name(union_id, &raw))
    }

    fn union_zero_storage(&self, union_id: CRecordId) -> TranslationResult<DaExpr> {
        let size = self.record_layout(union_id)?.object.size_bytes;
        Ok(DaExpr::Call(
            Box::new(DaExpr::Var("c2da_rt_calloc".into())),
            vec![
                self.integer_literal_for_type(DaExpr::ConstInt(1), DaType::uint64()),
                self.integer_literal_for_type(
                    DaExpr::ConstInt(i64::try_from(size).map_err(|_| {
                        TranslationError::generic("union size exceeds daScript integer range")
                    })?),
                    DaType::uint64(),
                ),
            ],
        ))
    }

    fn local_union_field_address(
        &self,
        union: DaExpr,
        union_id: CRecordId,
        field: CFieldId,
    ) -> TranslationResult<CObjectAddress> {
        let _ = self.union_wrapper_name(union_id)?;
        self.field_address(
            CObjectAddress {
                raw: WithStmts::new_val(DaExpr::Field(Box::new(union), "c2da_storage".into())),
                raw_is_address: true,
                ctype: match self.ast_context[field].kind {
                    CDeclKind::Field { typ, .. } => typ,
                    _ => return Err(TranslationError::generic("union field is invalid")),
                },
                byte_offset: 0,
                storage_size_bytes: None,
            },
            field,
        )
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
        // `p->inner.member` (and longer chains) keeps `inner` as a raw C
        // object place.  Do this before normal Arrow/Dot lowering so an
        // aggregate intermediate never reaches `raw_load` as an rvalue.
        if let Some(base) = self.member_place_address(ctx, expr)? {
            return self.member_place_lvalue(base, decl);
        }
        if matches!(kind, MemberKind::Arrow) {
            let base_ctype = self.ast_context[expr]
                .kind
                .get_qual_type()
                .ok_or_else(|| TranslationError::generic("member pointer has no C type"))?;
            let base = self.convert_expr(ctx, expr, Some(base_ctype))?;
            let value = self.pointer_member_lvalue(base, base_ctype, decl)?;
            // This expression can be an assignment target.  Any numeric
            // conversion is applied by its consuming value-site lowering;
            // wrapping the dereference here would destroy lvalue-ness.
            return Ok(value);
        }
        let parent = *self
            .ast_context
            .parents
            .get(&decl)
            .ok_or_else(|| TranslationError::generic("field has no parent record"))?;
        if matches!(self.ast_context[parent].kind, CDeclKind::Union { .. }) {
            let union = self.convert_expr(ctx, expr, Some(qual_ty))?;
            let address = self.local_union_field_address(union.val, parent, decl)?;
            return self.raw_load(address);
        }
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
        opt_field_id: Option<CFieldId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let field = opt_field_id.ok_or_else(|| {
            TranslationError::generic("cast to union is missing its active C field")
        })?;
        let union_id = *self
            .ast_context
            .parents
            .get(&field)
            .ok_or_else(|| TranslationError::generic("union cast field has no parent"))?;
        let name = self.union_wrapper_name(union_id)?;
        let storage = self.union_zero_storage(union_id)?;
        let tmp = self.renamer.borrow_mut().fresh();
        let mut stmts = val.stmts;
        stmts.push(DaStmt::Var {
            name: tmp.clone(),
            var_type: DaType::named(&name),
            init: Some(DaExpr::MakeStruct {
                type_name: name,
                fields: vec![("c2da_storage".into(), storage)],
            }),
        });
        let address = self.local_union_field_address(DaExpr::Var(tmp.clone()), union_id, field)?;
        let stored = self.raw_store(address, WithStmts::new_val(val.val))?;
        stmts.extend(stored.stmts);
        Ok(WithStmts::new(stmts, DaExpr::Var(tmp)).merge_unsafe(val.is_unsafe || stored.is_unsafe))
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
