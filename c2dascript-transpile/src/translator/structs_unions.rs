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
            // A struct whose Clang layout diverges from daScript's natural one
            // owns its bytes instead of being a daScript record: its fields
            // exist only as Clang offsets into that storage.
            if self.is_storage_backed_record(decl_id) {
                return self.storage_backed_record_decl(decl_id, sname);
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
                    // A storage-backed member is raw storage the containing
                    // object owns, so every instance of this record has to
                    // allocate its own.  The field default is what daScript
                    // evaluates per construction, which is exactly the C
                    // lifetime; it also satisfies daScript's rule that a
                    // record field of record type be initialized.
                    let default = self.storage_field_default(typ)?;
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
        fields: &Option<Vec<CFieldId>>,
    ) -> TranslationResult<DaDecl> {
        if let Some(ids) = fields {
            for &fid in ids {
                if let CDeclKind::Field { ref name, .. } = self.ast_context[fid].kind {
                    self.type_converter
                        .borrow_mut()
                        .declare_field_name(decl_id, fid, name);
                }
            }
        }
        let raw_name = name.clone().unwrap_or_else(|| "Unnamed".into());
        let name = self
            .type_converter
            .borrow_mut()
            .ensure_decl_name(decl_id, &raw_name);
        self.storage_backed_record_decl(decl_id, name)
    }

    /// The daScript declaration of a storage-backed C record: a wrapper whose
    /// only field is the address of the record's own bytes.
    ///
    /// Default-constructing the wrapper must yield a usable C object, because
    /// that is what a declaration without an initializer produces — including
    /// every element of a `struct s a[3]`.  A zero address would be a null
    /// object every field access writes through, so the wrapper allocates its
    /// own storage instead.
    pub(crate) fn storage_backed_record_decl(
        &self,
        decl_id: CDeclId,
        name: String,
    ) -> TranslationResult<DaDecl> {
        Ok(DaDecl::Structure(DaStructure {
            name,
            fields: vec![DaField {
                name: "c2da_storage".into(),
                field_type: DaType::uint64(),
                default: Some(self.record_zero_storage(decl_id)?),
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

    /// Build a storage-backed C record object from a braced initializer.
    ///
    /// The object's bytes are allocated first and every initializer element is
    /// then written at its own Clang offset, so a packed or otherwise
    /// layout-divergent record is filled exactly as C fills it.  Elements C
    /// leaves implicit need no work at all: the allocation is already zeroed.
    pub fn convert_storage_record_literal(
        &self,
        ctx: ExprContext,
        record_id: CRecordId,
        ids: &[CExprId],
        _override_ty: Option<CQualTypeId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let name = self.storage_record_name(record_id)?;
        let storage = self.record_zero_storage(record_id)?;
        let mut out = WithStmts::new_val(DaExpr::MakeStruct {
            type_name: name.clone(),
            fields: vec![("c2da_storage".into(), storage)],
        });
        if ids.is_empty() {
            return Ok(out);
        }
        let fields = self.record_fields(record_id)?;
        // C initializes exactly one member of a union — Clang always reports
        // it first — while a struct takes its initializers in field order.
        let is_union = matches!(self.ast_context[record_id].kind, CDeclKind::Union { .. });
        let pairs: Vec<(CFieldId, CExprId)> = if is_union {
            match (fields.first(), ids.first()) {
                (Some(&field), Some(&init)) => vec![(field, init)],
                _ => vec![],
            }
        } else {
            fields.iter().copied().zip(ids.iter().copied()).collect()
        };
        let tmp = self.renamer.borrow_mut().fresh();
        out.stmts.push(DaStmt::Var {
            name: tmp.clone(),
            var_type: DaType::named(&name),
            init: Some(out.val),
        });
        let base = self.wrapper_storage_place(DaExpr::Var(tmp.clone()), record_id)?;
        let mut is_unsafe = false;
        for (field, init) in pairs {
            let address = self.field_address(base.clone(), field)?;
            let stored = self.store_initializer(ctx, address, init, Some(field))?;
            is_unsafe |= stored.is_unsafe;
            out.stmts.extend(stored.stmts);
        }
        out.val = DaExpr::Var(tmp);
        Ok(out.merge_unsafe(is_unsafe))
    }

    /// The C fields of a record, or a diagnostic for an incomplete one.
    pub(crate) fn record_fields(&self, record_id: CRecordId) -> TranslationResult<Vec<CFieldId>> {
        match &self.ast_context[record_id].kind {
            CDeclKind::Struct {
                fields: Some(fields),
                ..
            }
            | CDeclKind::Union {
                fields: Some(fields),
                ..
            } => Ok(fields.clone()),
            _ => Err(TranslationError::generic(
                "C record object has no field layout",
            )),
        }
    }

    /// The whole-object place a storage-backed wrapper value names.
    pub(crate) fn wrapper_storage_place(
        &self,
        wrapper: DaExpr,
        record_id: CRecordId,
    ) -> TranslationResult<CObjectAddress> {
        Ok(CObjectAddress {
            raw: WithStmts::new_val(DaExpr::Field(Box::new(wrapper), "c2da_storage".into())),
            raw_is_address: true,
            ctype: CQualTypeId::new(self.record_ctype(record_id)?),
            byte_offset: 0,
            storage_size_bytes: None,
        })
    }

    /// Write one C initializer element into the place it initializes.
    ///
    /// A braced element initializes a sub-object in place rather than
    /// producing a value: recursing keeps every scalar leaf a `raw_store` at
    /// its own Clang offset, which is the only way a packed sub-object gets
    /// the bytes C gives it.
    fn store_initializer(
        &self,
        ctx: ExprContext,
        address: CObjectAddress,
        init: CExprId,
        field: Option<CFieldId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let init = self.strip_lvalue_wrappers(init);
        // C zero-fills what an initializer leaves out, and the object's bytes
        // were allocated zeroed; writing the zeros again would only be slower.
        if matches!(self.ast_context[init].kind, CExprKind::ImplicitValueInit(_)) {
            return Ok(WithStmts::new_val(DaExpr::ConstInt(0)));
        }
        // A bitfield initializer sets its own bits inside a storage word the
        // neighbouring fields share, so it is a read-modify-write like every
        // other bitfield assignment, not a store of the whole word.
        if let Some(field) = field {
            if matches!(
                self.ast_context[field].kind,
                CDeclKind::Field {
                    bitfield_width: Some(_),
                    ..
                }
            ) {
                let value = self.convert_expr(ctx.used(), init, Some(address.ctype))?;
                return self.bitfield_store(address, field, value);
            }
        }
        if let CExprKind::InitList(_, ref elements, _, _) = self.ast_context[init].kind {
            let elements = elements.clone();
            match self.ast_context.resolve_type(address.ctype.ctype).kind {
                CTypeKind::Struct(record) | CTypeKind::Union(record) => {
                    let fields = self.record_fields(record)?;
                    let is_union =
                        matches!(self.ast_context[record].kind, CDeclKind::Union { .. });
                    let pairs: Vec<(CFieldId, CExprId)> = if is_union {
                        match (fields.first(), elements.first()) {
                            (Some(&field), Some(&element)) => vec![(field, element)],
                            _ => vec![],
                        }
                    } else {
                        fields.into_iter().zip(elements.into_iter()).collect()
                    };
                    let mut out = WithStmts::new_val(DaExpr::ConstInt(0));
                    for (field, element) in pairs {
                        let field_address = self.field_address(address.clone(), field)?;
                        let stored =
                            self.store_initializer(ctx, field_address, element, Some(field))?;
                        let is_unsafe = stored.is_unsafe;
                        out.stmts.extend(stored.stmts);
                        out = out.merge_unsafe(is_unsafe);
                    }
                    return Ok(out);
                }
                CTypeKind::ConstantArray(element_ty, count) => {
                    let element_size = self.layout_of(element_ty)?.size_bytes;
                    let mut out = WithStmts::new_val(DaExpr::ConstInt(0));
                    for (index, &element) in elements.iter().enumerate() {
                        if index as u64 >= count as u64 {
                            break;
                        }
                        let mut element_address = address.clone();
                        element_address.ctype = CQualTypeId::new(element_ty);
                        element_address.storage_size_bytes = None;
                        element_address.byte_offset = address
                            .byte_offset
                            .checked_add(index as u64 * element_size)
                            .ok_or_else(|| {
                                TranslationError::generic("C array element offset overflow")
                            })?;
                        let stored =
                            self.store_initializer(ctx, element_address, element, None)?;
                        let is_unsafe = stored.is_unsafe;
                        out.stmts.extend(stored.stmts);
                        out = out.merge_unsafe(is_unsafe);
                    }
                    return Ok(out);
                }
                _ => {}
            }
        }
        let value = self.convert_expr(ctx.used(), init, Some(address.ctype))?;
        self.raw_store(address, value)
    }

    /// The daScript wrapper type name of a storage-backed C record.
    pub(crate) fn storage_record_name(&self, record_id: CRecordId) -> TranslationResult<String> {
        let raw = match &self.ast_context[record_id].kind {
            CDeclKind::Union {
                name: Some(name), ..
            }
            | CDeclKind::Struct {
                name: Some(name), ..
            } => name.clone(),
            CDeclKind::Union { .. } | CDeclKind::Struct { .. } => self
                .type_converter
                .borrow()
                .resolve_decl_name(record_id)
                .ok_or_else(|| {
                    TranslationError::generic("anonymous C record has no wrapper name")
                })?,
            _ => {
                return Err(TranslationError::generic(
                    "record wrapper requested for non-record",
                ))
            }
        };
        Ok(self
            .type_converter
            .borrow_mut()
            .ensure_decl_name(record_id, &raw))
    }

    /// The C type id of a record declaration.
    pub(crate) fn record_ctype(&self, record_id: CRecordId) -> TranslationResult<CTypeId> {
        let kind = match self.ast_context[record_id].kind {
            CDeclKind::Union { .. } => CTypeKind::Union(record_id),
            CDeclKind::Struct { .. } => CTypeKind::Struct(record_id),
            _ => {
                return Err(TranslationError::generic(
                    "C type requested for non-record declaration",
                ))
            }
        };
        self.ast_context
            .type_for_kind(&kind)
            .ok_or_else(|| TranslationError::generic("C record declaration has no C type"))
    }

    /// The per-instance initializer for a record field that is itself a
    /// storage-backed record, or `None` when it is not.
    fn storage_field_default(&self, field_ty: CQualTypeId) -> TranslationResult<Option<DaExpr>> {
        let Some(record_id) = self.storage_backed_record_of(field_ty.ctype) else {
            return Ok(None);
        };
        Ok(Some(DaExpr::MakeStruct {
            type_name: self.storage_record_name(record_id)?,
            fields: vec![("c2da_storage".into(), self.record_zero_storage(record_id)?)],
        }))
    }

    /// The size in bytes Clang gives the record object, as a daScript literal
    /// operand for the raw-memory runtime.
    pub(crate) fn record_object_size(&self, record_id: CRecordId) -> TranslationResult<i64> {
        i64::try_from(self.record_layout(record_id)?.object.size_bytes)
            .map_err(|_| TranslationError::generic("record size exceeds daScript integer range"))
    }

    /// A fresh wrapper holding a copy of the storage-backed record object that
    /// lives at `raw_address`.
    ///
    /// This is the read half of the pointer-side model: bytes at an address are
    /// not a wrapper struct and cannot be dereferenced as one, so an rvalue use
    /// of `*p` (or of `q->u`) allocates its own storage and copies the object
    /// into it — which is also exactly C's by-value rule.
    pub(crate) fn load_storage_object(
        &self,
        record_id: CRecordId,
        raw_address: WithStmts<DaExpr>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let name = self.storage_record_name(record_id)?;
        let size = self.record_object_size(record_id)?;
        let storage = self.record_zero_storage(record_id)?;
        let tmp = self.renamer.borrow_mut().fresh();
        let is_unsafe = raw_address.is_unsafe;
        let mut stmts = raw_address.stmts;
        stmts.push(DaStmt::Var {
            name: tmp.clone(),
            var_type: DaType::named(&name),
            init: Some(DaExpr::MakeStruct {
                type_name: name,
                fields: vec![("c2da_storage".into(), storage)],
            }),
        });
        stmts.push(DaStmt::Expr(DaExpr::Call(
            Box::new(DaExpr::Var("c2da_rt_memcpy".into())),
            vec![
                DaExpr::Field(Box::new(DaExpr::Var(tmp.clone())), "c2da_storage".into()),
                raw_address.val,
                self.integer_literal_for_type(DaExpr::ConstInt(size), DaType::uint64()),
            ],
        )));
        Ok(WithStmts::new(stmts, DaExpr::Var(tmp)).merge_unsafe(is_unsafe))
    }

    /// Copy a whole storage-backed record object into the raw storage at
    /// `raw_address`.
    ///
    /// The write half of the same model: `*p = u` and `q->u = u` overwrite the
    /// object's bytes in place.  Assigning the wrapper instead would store the
    /// eight bytes of a storage address over the object.
    pub(crate) fn store_storage_object(
        &self,
        record_id: CRecordId,
        raw_address: WithStmts<DaExpr>,
        value: WithStmts<DaExpr>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let name = self.storage_record_name(record_id)?;
        let size = self.record_object_size(record_id)?;
        let is_unsafe = raw_address.is_unsafe || value.is_unsafe;
        let mut stmts = value.stmts;
        // The source's storage address is read out of the wrapper, so the
        // wrapper has to be a place; an expression is bound to a temporary
        // first, which also evaluates it exactly once as C requires.
        let source = match value.val {
            place @ (DaExpr::Var(_) | DaExpr::Field(..)) => place,
            other => {
                let tmp = self.renamer.borrow_mut().fresh();
                stmts.push(DaStmt::Var {
                    name: tmp.clone(),
                    var_type: DaType::named(&name),
                    init: Some(other),
                });
                DaExpr::Var(tmp)
            }
        };
        stmts.extend(raw_address.stmts);
        stmts.push(DaStmt::Expr(DaExpr::Call(
            Box::new(DaExpr::Var("c2da_rt_memcpy".into())),
            vec![
                raw_address.val,
                DaExpr::Field(Box::new(source.clone()), "c2da_storage".into()),
                self.integer_literal_for_type(DaExpr::ConstInt(size), DaType::uint64()),
            ],
        )));
        Ok(WithStmts::new(stmts, source).merge_unsafe(is_unsafe))
    }

    /// A zeroed allocation the size Clang gives the record object.
    pub(crate) fn record_zero_storage(&self, record_id: CRecordId) -> TranslationResult<DaExpr> {
        let size = self.record_object_size(record_id)?;
        Ok(DaExpr::Call(
            Box::new(DaExpr::Var("c2da_rt_calloc".into())),
            vec![
                self.integer_literal_for_type(DaExpr::ConstInt(1), DaType::uint64()),
                self.integer_literal_for_type(DaExpr::ConstInt(size), DaType::uint64()),
            ],
        ))
    }

    /// Give a storage-backed C record consumed by value its own storage.
    ///
    /// The wrapper struct holds nothing but the address of the record's bytes,
    /// so copying the wrapper — which is what daScript assignment does — would
    /// leave source and destination sharing one object.  C copies a record by
    /// value, so the destination gets a fresh allocation and the whole object
    /// is copied into it.
    ///
    /// A value that already *is* a fresh temporary (a braced initializer, a
    /// cast to union, a default initializer) owns storage nobody else can name
    /// yet, so it is handed through untouched rather than allocated twice.
    pub(crate) fn copy_storage_record_by_value(
        &self,
        value: WithStmts<DaExpr>,
        source: Option<CQualTypeId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let Some(source) = source else {
            return Ok(value);
        };
        let Some(record_id) = self.storage_backed_record_of(source.ctype) else {
            return Ok(value);
        };
        if storage_value_owns_fresh_storage(&value) {
            return Ok(value);
        }
        if matches!(value.val, DaExpr::Assign(..)) {
            // A chained `a = b = u` still has its inner assignment as an
            // expression here; binding it to a temporary is not daScript.
            // Chain assignment of records therefore still aliases.
            return Ok(value);
        }
        let name = self.storage_record_name(record_id)?;
        let size = self.record_object_size(record_id)?;
        let storage = self.record_zero_storage(record_id)?;
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

    /// Give a C aggregate consumed by value its own object.
    ///
    /// This is the whole of C's by-value rule for records.  A record whose
    /// daScript layout matches Clang's is a plain daScript struct, and
    /// daScript's own copy already duplicates its scalars and inline fixed
    /// arrays; it also cannot contain a storage-backed record, because a field
    /// that is one makes the containing record storage-backed in turn.  A
    /// storage-backed record carries nothing but the address of its bytes and
    /// is copied by [`Translation::copy_storage_record_by_value`].
    pub(crate) fn copy_aggregate_by_value(
        &self,
        value: WithStmts<DaExpr>,
        source: Option<CQualTypeId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        self.copy_storage_record_by_value(value, source)
    }

    /// Address of a field inside a storage-backed wrapper value.
    ///
    /// The wrapper may carry statements (it can be any C lvalue expression,
    /// not just a local variable), so the base is taken as a `WithStmts` and
    /// those statements travel with the resulting address.  Dropping them
    /// would silently discard the side effects that produced the object.
    pub(crate) fn wrapper_field_address(
        &self,
        wrapper: WithStmts<DaExpr>,
        record_id: CRecordId,
        field: CFieldId,
    ) -> TranslationResult<CObjectAddress> {
        let _ = self.storage_record_name(record_id)?;
        self.field_address(
            CObjectAddress {
                raw: wrapper
                    .map(|wrapper| DaExpr::Field(Box::new(wrapper), "c2da_storage".into())),
                raw_is_address: true,
                ctype: match self.ast_context[field].kind {
                    CDeclKind::Field { typ, .. } => typ,
                    _ => return Err(TranslationError::generic("C record field is invalid")),
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
        if self.is_storage_backed_record(parent) {
            // The base may be a wrapper value or an object reached through a
            // pointer, in which case it is raw bytes with no wrapper to read.
            let base_address = self.storage_object_address(ctx, expr)?.ok_or_else(|| {
                TranslationError::generic("member base is not a storage-backed C record")
            })?;
            // A bitfield has no byte-addressable place of its own, so the read
            // goes through the same shift-and-mask lowering as every other
            // address-backed field access.
            return self.member_place_lvalue(base_address, decl);
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
        let name = self.storage_record_name(union_id)?;
        let storage = self.record_zero_storage(union_id)?;
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
        let address = self.wrapper_field_address(
            WithStmts::new_val(DaExpr::Var(tmp.clone())),
            union_id,
            field,
        )?;
        let stored = self.raw_store(address, WithStmts::new_val(val.val))?;
        stmts.extend(stored.stmts);
        Ok(WithStmts::new(stmts, DaExpr::Var(tmp)).merge_unsafe(val.is_unsafe || stored.is_unsafe))
    }

}

/// Whether a wrapper value already owns storage no other C object can reach.
/// A `MakeStruct` allocates in place; the braced initializer and the cast to
/// union both bind that `MakeStruct` to a temporary first and then hand back
/// the temporary, so the declaring statement is what identifies them.
fn storage_value_owns_fresh_storage(value: &WithStmts<DaExpr>) -> bool {
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
