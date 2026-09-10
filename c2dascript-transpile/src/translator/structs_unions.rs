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
                    // A field type that has no daScript representation is a
                    // gap in the translation, not something to approximate:
                    // substituting `int64`/`auto` would silently change the
                    // record's layout and the meaning of every access to it.
                    let ft = self
                        .convert_type(typ.clone())
                        .and_then(|ft| {
                            // A typedef does not make an unrepresentable C
                            // type representable. A record field needs a type
                            // daScript can actually lay out, so the whole
                            // typedef chain is resolved before the field is
                            // accepted.
                            let mut underlying = typ.clone();
                            underlying.ctype = self.ast_context.resolve_type_id(typ.ctype);
                            self.convert_type(underlying)?;
                            Ok(ft)
                        })
                        .map_err(|error| {
                            let kind = self
                                .ast_context
                                .resolve_type(self.ast_context.resolve_type_id(typ.ctype))
                                .kind
                                .clone();
                            format_translation_err!(
                                self.ast_context.display_loc(&self.ast_context[fid].loc),
                                "unsupported {} field type {:?} in field {}: {}",
                                unrepresentable_field_kind(&kind),
                                kind,
                                name,
                                error
                            )
                        })?;
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
                    // A union member is raw storage the containing object
                    // owns, so every instance of this record has to allocate
                    // its own.  The field default is what daScript evaluates
                    // per construction, which is exactly the C lifetime; it
                    // also satisfies daScript's rule that a record field of
                    // record type be initialized.
                    let default = self.union_field_default(typ)?;
                    das_fields.push(DaField {
                        name: field_name,
                        field_type: ft,
                        default,
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
        // Default-constructing the wrapper must yield a usable C union
        // object, because that is what a declaration without an initializer
        // produces — including every element of a `union u a[3]`.  A zero
        // address would be a null object every field access writes through,
        // so the wrapper allocates its own storage instead.
        Ok(DaDecl::Structure(DaStructure {
            name,
            fields: vec![DaField {
                name: "c2da_storage".into(),
                field_type: DaType::uint64(),
                default: Some(self.union_zero_storage(decl_id)?),
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
            let address = self.local_union_field_address(
                WithStmts::new_val(DaExpr::Var(tmp.clone())),
                union_id,
                field,
            )?;
            let stored = self.raw_store(address, value)?;
            out.stmts.extend(stored.stmts);
            out.val = DaExpr::Var(tmp);
        }
        Ok(out)
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

    /// The per-instance initializer for a record field of union type, or
    /// `None` when the field is not a union.
    fn union_field_default(&self, field_ty: CQualTypeId) -> TranslationResult<Option<DaExpr>> {
        let CTypeKind::Union(union_id) = self.ast_context.resolve_type(field_ty.ctype).kind else {
            return Ok(None);
        };
        Ok(Some(DaExpr::MakeStruct {
            type_name: self.union_wrapper_name(union_id)?,
            fields: vec![("c2da_storage".into(), self.union_zero_storage(union_id)?)],
        }))
    }

    pub(crate) fn union_zero_storage(&self, union_id: CRecordId) -> TranslationResult<DaExpr> {
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

    /// Give a C union consumed by value its own storage.
    ///
    /// The wrapper struct holds nothing but the address of the union's bytes,
    /// so copying the wrapper — which is what daScript assignment does — would
    /// leave source and destination sharing one object.  C copies a union by
    /// value, so the destination gets a fresh allocation and the whole union
    /// object is copied into it.
    ///
    /// A value that already *is* a fresh union temporary (a union literal, a
    /// cast to union, a default initializer) owns storage nobody else can name
    /// yet, so it is handed through untouched rather than allocated twice.
    pub(crate) fn copy_union_by_value(
        &self,
        value: WithStmts<DaExpr>,
        source: Option<CQualTypeId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let Some(source) = source else {
            return Ok(value);
        };
        let CTypeKind::Union(union_id) = self.ast_context.resolve_type(source.ctype).kind else {
            return Ok(value);
        };
        if union_value_owns_fresh_storage(&value) {
            return Ok(value);
        }
        if matches!(value.val, DaExpr::Assign(..)) {
            // A chained `a = b = u` still has its inner assignment as an
            // expression here; binding it to a temporary is not daScript.
            // Chain assignment of unions therefore still aliases.
            return Ok(value);
        }
        let name = self.union_wrapper_name(union_id)?;
        let size = i64::try_from(self.record_layout(union_id)?.object.size_bytes)
            .map_err(|_| TranslationError::generic("union size exceeds daScript integer range"))?;
        let storage = self.union_zero_storage(union_id)?;
        let (source_tmp, copy_tmp) = {
            let mut renamer = self.renamer.borrow_mut();
            (renamer.fresh(), renamer.fresh())
        };
        let is_unsafe = value.is_unsafe;
        let mut stmts = value.stmts;
        // The source is bound first so that a union produced by an expression
        // with side effects is evaluated exactly once, as C requires.
        stmts.push(DaStmt::Var {
            name: source_tmp.clone(),
            var_type: DaType::named(&name),
            init: Some(value.val),
        });
        stmts.push(DaStmt::Var {
            name: copy_tmp.clone(),
            var_type: DaType::named(&name),
            init: Some(DaExpr::MakeStruct {
                type_name: name,
                fields: vec![("c2da_storage".into(), storage)],
            }),
        });
        stmts.push(DaStmt::Expr(DaExpr::Call(
            Box::new(DaExpr::Var("c2da_rt_memcpy".into())),
            vec![
                DaExpr::Field(
                    Box::new(DaExpr::Var(copy_tmp.clone())),
                    "c2da_storage".into(),
                ),
                DaExpr::Field(Box::new(DaExpr::Var(source_tmp)), "c2da_storage".into()),
                self.integer_literal_for_type(DaExpr::ConstInt(size), DaType::uint64()),
            ],
        )));
        Ok(WithStmts::new(stmts, DaExpr::Var(copy_tmp)).merge_unsafe(is_unsafe))
    }

    /// Give a C aggregate consumed by value its own copy of every union object
    /// it owns.
    ///
    /// This is the whole of C's by-value rule for records: a plain daScript
    /// struct copy already duplicates scalars and inline fixed arrays, so the
    /// only part that still aliases is a union field, whose wrapper carries
    /// nothing but the address of the union's bytes.  A union value is copied
    /// by [`copy_union_by_value`]; a struct that transitively owns one is
    /// bound to a temporary and every union object inside it re-allocated.
    /// A record with no union anywhere needs nothing and is handed through.
    pub(crate) fn copy_aggregate_by_value(
        &self,
        value: WithStmts<DaExpr>,
        source: Option<CQualTypeId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let Some(source_ty) = source else {
            return Ok(value);
        };
        match self.ast_context.resolve_type(source_ty.ctype).kind {
            CTypeKind::Union(_) => self.copy_union_by_value(value, source),
            CTypeKind::Struct(_) if self.ctype_owns_union(source_ty.ctype) => {
                self.copy_record_with_unions(value, source_ty)
            }
            _ => Ok(value),
        }
    }

    /// Bind a struct value to a temporary and re-allocate the union storage
    /// every union field inside it still shares with the source.
    fn copy_record_with_unions(
        &self,
        value: WithStmts<DaExpr>,
        source: CQualTypeId,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        if matches!(value.val, DaExpr::Assign(..)) {
            // As for a union: a chained `a = b = s` still has its inner
            // assignment as an expression here, and binding that to a
            // temporary is not daScript.
            return Ok(value);
        }
        let var_type = writable_type(self.convert_type(source)?);
        let tmp = self.renamer.borrow_mut().fresh();
        let is_unsafe = value.is_unsafe;
        let mut stmts = value.stmts;
        // The shallow copy comes first, so an expression with side effects is
        // evaluated exactly once; the union objects it still shares with the
        // source are replaced afterwards, in place.
        stmts.push(DaStmt::Var {
            name: tmp.clone(),
            var_type,
            init: Some(value.val),
        });
        stmts.extend(self.duplicate_owned_unions(DaExpr::Var(tmp.clone()), source.ctype)?);
        Ok(WithStmts::new(stmts, DaExpr::Var(tmp)).merge_unsafe(is_unsafe))
    }

    /// The statements that turn every union object reachable from an already
    /// shallow-copied place into an object of its own.
    ///
    /// This is the second half of a C record copy for callers that have made
    /// the shallow copy themselves — a by-value parameter, say, whose local is
    /// declared straight from the incoming reference.
    pub(crate) fn duplicate_owned_unions(
        &self,
        place: DaExpr,
        ctype: CTypeId,
    ) -> TranslationResult<Vec<DaStmt>> {
        let mut stmts = vec![];
        let mut budget = UNION_COPY_BUDGET;
        self.reallocate_union_storage(place, ctype, &mut stmts, &mut budget)?;
        Ok(stmts)
    }

    /// Whether a C type owns a union object anywhere inside it.
    ///
    /// Only what the object itself contains counts: a pointer to a union is a
    /// reference to somebody else's object, and copying the pointer is exactly
    /// what C does.
    pub(crate) fn ctype_owns_union(&self, ctype: CTypeId) -> bool {
        let mut visiting = vec![];
        self.ctype_owns_union_inner(ctype, &mut visiting)
    }

    fn ctype_owns_union_inner(&self, ctype: CTypeId, visiting: &mut Vec<CRecordId>) -> bool {
        match self.ast_context.resolve_type(ctype).kind {
            CTypeKind::Union(_) => true,
            CTypeKind::Struct(record) => {
                // A C record cannot contain itself by value, but a broken or
                // still-incomplete AST must not turn that into a hang.
                if visiting.contains(&record) {
                    return false;
                }
                let fields = match &self.ast_context[record].kind {
                    CDeclKind::Struct {
                        fields: Some(fields),
                        ..
                    } => fields.clone(),
                    _ => return false,
                };
                visiting.push(record);
                let owns = fields.into_iter().any(|field| {
                    match self.ast_context[field].kind {
                        CDeclKind::Field { typ, .. } => {
                            self.ctype_owns_union_inner(typ.ctype, visiting)
                        }
                        _ => false,
                    }
                });
                visiting.pop();
                owns
            }
            CTypeKind::ConstantArray(element, _) => {
                self.ctype_owns_union_inner(element, visiting)
            }
            _ => false,
        }
    }

    /// Replace, in place, the storage address of every union object reachable
    /// from `place` with a fresh allocation holding a copy of its bytes.
    ///
    /// The new address is built in a temporary before it is stored, because
    /// the copy reads the old address out of the very field it overwrites.
    fn reallocate_union_storage(
        &self,
        place: DaExpr,
        ctype: CTypeId,
        stmts: &mut Vec<DaStmt>,
        budget: &mut u32,
    ) -> TranslationResult<()> {
        match self.ast_context.resolve_type(ctype).kind {
            CTypeKind::Union(union_id) => {
                if *budget == 0 {
                    return Err(TranslationError::generic(
                        "aggregate copy owns too many union objects to duplicate",
                    ));
                }
                *budget -= 1;
                let size = i64::try_from(self.record_layout(union_id)?.object.size_bytes).map_err(
                    |_| TranslationError::generic("union size exceeds daScript integer range"),
                )?;
                let storage = DaExpr::Field(Box::new(place), "c2da_storage".into());
                let fresh = self.renamer.borrow_mut().fresh();
                stmts.push(DaStmt::Var {
                    name: fresh.clone(),
                    var_type: DaType::uint64(),
                    init: Some(self.union_zero_storage(union_id)?),
                });
                stmts.push(DaStmt::Expr(DaExpr::Call(
                    Box::new(DaExpr::Var("c2da_rt_memcpy".into())),
                    vec![
                        DaExpr::Var(fresh.clone()),
                        storage.clone(),
                        self.integer_literal_for_type(DaExpr::ConstInt(size), DaType::uint64()),
                    ],
                )));
                stmts.push(DaStmt::Expr(DaExpr::Assign(
                    Box::new(storage),
                    Box::new(DaExpr::Var(fresh)),
                )));
            }
            CTypeKind::Struct(record) => {
                let fields = match &self.ast_context[record].kind {
                    CDeclKind::Struct {
                        fields: Some(fields),
                        ..
                    } => fields.clone(),
                    _ => return Ok(()),
                };
                for field in fields {
                    let CDeclKind::Field { typ, ref name, .. } = self.ast_context[field].kind else {
                        continue;
                    };
                    if !self.ctype_owns_union(typ.ctype) {
                        continue;
                    }
                    let field_name = self
                        .type_converter
                        .borrow()
                        .resolve_field_name(Some(record), field)
                        .unwrap_or_else(|| {
                            if name.is_empty() {
                                "_unnamed".into()
                            } else {
                                name.clone()
                            }
                        });
                    self.reallocate_union_storage(
                        DaExpr::Field(Box::new(place.clone()), field_name),
                        typ.ctype,
                        stmts,
                        budget,
                    )?;
                }
            }
            CTypeKind::ConstantArray(element, count) => {
                if !self.ctype_owns_union(element) {
                    return Ok(());
                }
                // A fixed C array lives inline in the object, so each element
                // is its own union owner and is duplicated separately.
                for index in 0..count {
                    self.reallocate_union_storage(
                        DaExpr::Index(
                            Box::new(place.clone()),
                            Box::new(DaExpr::ConstInt(i64::try_from(index).map_err(|_| {
                                TranslationError::generic(
                                    "array extent exceeds daScript integer range",
                                )
                            })?)),
                        ),
                        element,
                        stmts,
                        budget,
                    )?;
                }
            }
            _ => {}
        }
        Ok(())
    }

    /// Address of a field inside a union wrapper value.
    ///
    /// The wrapper may carry statements (it can be any C lvalue expression,
    /// not just a local variable), so the base is taken as a `WithStmts` and
    /// those statements travel with the resulting address.  Dropping them
    /// would silently discard the side effects that produced the union.
    pub(crate) fn local_union_field_address(
        &self,
        union: WithStmts<DaExpr>,
        union_id: CRecordId,
        field: CFieldId,
    ) -> TranslationResult<CObjectAddress> {
        let _ = self.union_wrapper_name(union_id)?;
        self.field_address(
            CObjectAddress {
                raw: union.map(|union| DaExpr::Field(Box::new(union), "c2da_storage".into())),
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
            let address = self.local_union_field_address(union, parent, decl)?;
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
        let _ = override_ty;
        // A member access is an assignment target. Wrapping it in a cast to
        // the use-site's type would turn the lvalue into a value, so any
        // numeric conversion is left to the consuming value-site lowering.
        let das = DaExpr::Field(Box::new(obj.val), fn_);
        Ok(WithStmts::new_val(das)
            .prepend_stmts(obj.stmts)
            .merge_unsafe(obj.is_unsafe))
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
        let address = self.local_union_field_address(
            WithStmts::new_val(DaExpr::Var(tmp.clone())),
            union_id,
            field,
        )?;
        let stored = self.raw_store(address, WithStmts::new_val(val.val))?;
        stmts.extend(stored.stmts);
        Ok(WithStmts::new(stmts, DaExpr::Var(tmp)).merge_unsafe(val.is_unsafe || stored.is_unsafe))
    }

}

/// How many union objects one aggregate copy may duplicate.  A C record can
/// nest arrays of unions arbitrarily deep, and each element is unrolled into
/// its own copy; the cap turns a pathological type into a translation error
/// instead of a megabyte of generated daScript.
const UNION_COPY_BUDGET: u32 = 4096;

/// Whether a union wrapper value already owns storage no other C object can
/// reach.  A `MakeStruct` allocates in place; the union literal and the cast
/// to union both bind that `MakeStruct` to a temporary first and then hand
/// back the temporary, so the declaring statement is what identifies them.
fn union_value_owns_fresh_storage(value: &WithStmts<DaExpr>) -> bool {
    match &value.val {
        DaExpr::MakeStruct { .. } => true,
        DaExpr::Var(name) => value.stmts().iter().any(|stmt| {
            matches!(
                stmt,
                DaStmt::Var {
                    name: declared,
                    init: Some(DaExpr::MakeStruct { .. }),
                    ..
                } if declared == name
            )
        }),
        _ => false,
    }
}

/// Names the family a record field's C type belongs to, so a failed field
/// lowering reports which C surface has no daScript representation rather than
/// only that one exists.
fn unrepresentable_field_kind(kind: &CTypeKind) -> &'static str {
    match kind {
        CTypeKind::Vector(_, _) | CTypeKind::UnhandledSveType => "vector",
        CTypeKind::Atomic(_) => "atomic",
        CTypeKind::Complex(_) => "complex",
        CTypeKind::Function(..) => "function",
        _ => "record",
    }
}
