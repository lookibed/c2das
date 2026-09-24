//! Address-backed C object access.
//!
//! C layout is owned by `layout.rs`; this module only turns a known raw C
//! address plus that layout into daScript lvalues.

use super::*;

#[derive(Clone)]
pub(crate) struct CObjectAddress {
    pub raw: WithStmts<DaExpr>,
    /// `raw` is already a uint64 C address (local union storage), rather
    /// than a typed daScript pointer (ordinary pointer-backed object).
    pub raw_is_address: bool,
    pub ctype: CQualTypeId,
    /// Byte displacement from `raw`, always a fact supplied by `layout.rs`.
    pub byte_offset: u64,
    /// Field storage width exported by Clang. This preserves the layout
    /// contract through typedef wrappers which do not own a CTypeId layout.
    pub storage_size_bytes: Option<u64>,
}

impl<'c> Translation<'c> {
    /// Recover an address-backed aggregate place from a member expression.
    ///
    /// A nested C access such as `outer->inner.count` must never materialize
    /// `outer->inner` as an aggregate daScript rvalue.  It is only an address
    /// carrier on the way to the scalar leaf.  Returning `None` means the
    /// expression is an ordinary local daScript value and should retain the
    /// existing high-level member lowering.
    pub(crate) fn member_place_address(
        &self,
        ctx: ExprContext,
        member_expr: CExprId,
    ) -> TranslationResult<Option<CObjectAddress>> {
        let CExprKind::Member(_, base_expr, field, member_kind, _) =
            self.ast_context[member_expr].kind.clone()
        else {
            return Ok(None);
        };

        let base_address = self.member_place_address(ctx, base_expr)?;
        match (member_kind, base_address) {
            (_, Some(base_address)) => self.field_address(base_address, field).map(Some),
            (MemberKind::Arrow, None) => {
                let base_ctype = self.ast_context[base_expr]
                    .kind
                    .get_qual_type()
                    .ok_or_else(|| TranslationError::generic("member pointer has no C type"))?;
                let base = self.convert_expr(ctx, base_expr, Some(base_ctype))?;
                self.pointer_member_address(base, base_ctype, field)
                    .map(Some)
            }
            (MemberKind::Dot, None) => {
                // A storage-backed record is not a daScript record: its fields
                // live in raw `c2da_storage` bytes.  So `s.field` is an
                // address-backed place even when the object itself is an
                // ordinary daScript value, and an aggregate field (`u.bytes`,
                // `u.halves`) must stay a place rather than become an rvalue.
                let parent = *self
                    .ast_context
                    .parents
                    .get(&field)
                    .ok_or_else(|| TranslationError::generic("field has no parent record"))?;
                if !self.is_storage_backed_record(parent) {
                    return Ok(None);
                }
                // The base may be an object named directly (a wrapper value) or
                // one reached through a pointer (raw bytes at an address);
                // only `storage_object_address` knows which, and reading
                // `c2da_storage` out of the latter would dereference garbage.
                let base_address =
                    self.storage_object_address(ctx, base_expr)?
                        .ok_or_else(|| {
                            TranslationError::generic(
                                "member base is not a storage-backed C record",
                            )
                        })?;
                self.field_address(base_address, field).map(Some)
            }
        }
    }

    /// The raw byte address of the storage-backed C record object an lvalue
    /// names.
    ///
    /// Such a record has two representations in the translation, and which one
    /// an expression carries is a property of how the object was reached rather
    /// than of its C type.  An object *named directly* — a local, a global, a
    /// struct field, an element of a fixed array — is a wrapper struct whose
    /// `c2da_storage` holds the address of its bytes.  An object *reached
    /// through a pointer* already **is** those bytes: the pointer's numeric
    /// value is the object's address, and there is no wrapper to read.
    ///
    /// Returns `None` when the expression is not of storage-backed record type.
    pub(crate) fn storage_object_address(
        &self,
        ctx: ExprContext,
        expr: CExprId,
    ) -> TranslationResult<Option<CObjectAddress>> {
        let expr = self.strip_lvalue_wrappers(expr);
        let Some(ctype) = self.ast_context[expr].kind.get_qual_type() else {
            return Ok(None);
        };
        let Some(record_id) = self.storage_backed_record_of(ctype.ctype) else {
            return Ok(None);
        };
        match self.ast_context[expr].kind.clone() {
            // `*p`: the pointer's value already is the object's byte address.
            CExprKind::Unary(_, CUnOp::Deref, ptr, _) => {
                let ptr_ctype = self.ast_context[ptr].kind.get_qual_type().ok_or_else(|| {
                    TranslationError::generic("dereferenced record pointer has no C type")
                })?;
                let pointer = self.convert_expr(ctx.used(), ptr, Some(ptr_ctype))?;
                Ok(Some(CObjectAddress {
                    raw: pointer,
                    raw_is_address: false,
                    ctype,
                    byte_offset: 0,
                    storage_size_bytes: None,
                }))
            }
            // `p[i]` on a record pointer is `*(p + i)`, and C scales it by the
            // record's own size — not by the wrapper's.  A decayed fixed array
            // really is a daScript array of wrappers and keeps that lowering.
            CExprKind::ArraySubscript(_, arr, idx, _) if !self.is_array_decay(arr) => {
                let raw = self.record_element_raw_address(ctx, arr, idx, record_id)?;
                Ok(Some(CObjectAddress {
                    raw,
                    raw_is_address: true,
                    ctype,
                    byte_offset: 0,
                    storage_size_bytes: None,
                }))
            }
            // `q->u` and longer chains are already address-backed places.  A
            // record field of a *local* struct is not, and
            // `member_place_address` says so by returning `None`.
            CExprKind::Member(..) => match self.member_place_address(ctx, expr)? {
                Some(address) => Ok(Some(address)),
                None => self.wrapper_storage_address(ctx, expr, ctype),
            },
            _ => self.wrapper_storage_address(ctx, expr, ctype),
        }
    }

    /// The storage address carried by a storage-backed wrapper value.
    fn wrapper_storage_address(
        &self,
        ctx: ExprContext,
        expr: CExprId,
        ctype: CQualTypeId,
    ) -> TranslationResult<Option<CObjectAddress>> {
        let wrapper = self.convert_expr(ctx.used(), expr, Some(ctype))?;
        Ok(Some(CObjectAddress {
            raw: wrapper.map(|wrapper| DaExpr::Field(Box::new(wrapper), "c2da_storage".into())),
            raw_is_address: true,
            ctype,
            byte_offset: 0,
            storage_size_bytes: None,
        }))
    }

    /// Whether a subscript's left operand is a fixed C array that decayed,
    /// rather than a C pointer value.
    pub(crate) fn is_array_decay(&self, expr: CExprId) -> bool {
        matches!(
            self.ast_context[self.strip_lvalue_wrappers(expr)].kind,
            CExprKind::ImplicitCast(_, _, CastKind::ArrayToPointerDecay, _, _)
                | CExprKind::ExplicitCast(_, _, CastKind::ArrayToPointerDecay, _, _)
        )
    }

    /// `(uint64)p + i * sizeof(record)` — the address of `p[i]` for a C pointer
    /// to a storage-backed record, computed in C's own element size.
    fn record_element_raw_address(
        &self,
        ctx: ExprContext,
        arr: CExprId,
        idx: CExprId,
        record_id: CRecordId,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let size = self.record_object_size(record_id)?;
        let pointer = self.convert_expr(ctx.used(), arr, None)?;
        let index = self.convert_expr(ctx.used(), idx, None)?;
        let address = pointer.zip(index).map(|(pointer, index)| DaExpr::Op2 {
            op: "+",
            left: Box::new(self.pointer_to_raw_address(pointer)),
            right: Box::new(DaExpr::Op2 {
                op: "*",
                // A C subscript index is signed, and `p[-1]` is a legal read
                // of the element before `p`; the widening happens in the
                // signed type so that the wrap into `uint64` is the right one.
                left: Box::new(DaExpr::Cast {
                    kind: das_ast::CastKind::Cast,
                    expr: Box::new(DaExpr::Cast {
                        kind: das_ast::CastKind::Cast,
                        expr: Box::new(index),
                        to: DaType::int64(),
                    }),
                    to: DaType::uint64(),
                }),
                right: Box::new(
                    self.integer_literal_for_type(DaExpr::ConstInt(size), DaType::uint64()),
                ),
            }),
        });
        // daScript refuses to write through a pointer built inline from
        // address arithmetic (its dead-write policy), so the element's
        // address becomes a named value that both reads and writes can use.
        let tmp = self.renamer.borrow_mut().fresh();
        let is_unsafe = address.is_unsafe;
        let mut stmts = address.stmts;
        stmts.push(DaStmt::Var {
            name: tmp.clone(),
            var_type: DaType::uint64(),
            init: Some(address.val),
        });
        Ok(WithStmts::new(stmts, DaExpr::Var(tmp)).merge_unsafe(is_unsafe))
    }

    fn raw_byte_address(&self, address: &CObjectAddress) -> WithStmts<DaExpr> {
        address.raw.clone().map(|raw| {
            let raw = if address.raw_is_address {
                raw
            } else {
                self.pointer_to_raw_address(raw)
            };
            if address.byte_offset == 0 {
                raw
            } else {
                DaExpr::Op2 {
                    op: "+",
                    left: Box::new(raw),
                    right: Box::new(self.integer_literal_for_type(
                        DaExpr::ConstInt(address.byte_offset as i64),
                        DaType::uint64(),
                    )),
                }
            }
        })
    }

    /// Expose the canonical raw address of an aggregate place for array decay
    /// and aggregate-copy owners.  Callers must still choose the destination
    /// pointer type through the ABI layer; this method never invents one.
    pub(crate) fn raw_address_of_place(&self, address: &CObjectAddress) -> WithStmts<DaExpr> {
        self.raw_byte_address(address)
    }

    fn raw_storage_size(&self, address: &CObjectAddress) -> TranslationResult<u64> {
        match address.storage_size_bytes {
            Some(size) => Ok(size),
            None => Ok(self.layout_of(address.ctype.ctype)?.size_bytes),
        }
    }

    fn address_is_typed_aligned(&self, address: &CObjectAddress) -> TranslationResult<bool> {
        let size = self.raw_storage_size(address)?;
        Ok(size != 0 && address.byte_offset % size == 0)
    }
    pub(crate) fn field_address(
        &self,
        base: CObjectAddress,
        field: CFieldId,
    ) -> TranslationResult<CObjectAddress> {
        let offset = match self.ast_context[field].kind {
            CDeclKind::Field {
                bitfield_width: Some(_),
                platform_bit_offset,
                ..
            } => i64::try_from(platform_bit_offset / 8).map_err(|_| {
                TranslationError::generic("bitfield byte offset exceeds daScript range")
            })?,
            _ => self.field_offset(field)?,
        };
        let (field_ty, platform_type_bitwidth, bitfield_width) = match self.ast_context[field].kind
        {
            CDeclKind::Field {
                typ,
                platform_type_bitwidth,
                bitfield_width,
                ..
            } => (typ, platform_type_bitwidth, bitfield_width),
            _ => {
                return Err(TranslationError::generic(
                    "field address requested for non-field",
                ))
            }
        };
        let _ = bitfield_width;
        let offset = u64::try_from(offset)
            .map_err(|_| TranslationError::generic("negative C field offset from Clang"))?;
        let byte_offset = base
            .byte_offset
            .checked_add(offset)
            .ok_or_else(|| TranslationError::generic("C field address offset overflow"))?;
        Ok(CObjectAddress {
            raw: base.raw,
            raw_is_address: base.raw_is_address,
            ctype: field_ty,
            byte_offset,
            storage_size_bytes: (platform_type_bitwidth % 8 == 0)
                .then_some(platform_type_bitwidth / 8),
        })
    }

    /// Take an address-backed place's statements out of the address itself.
    ///
    /// A `CObjectAddress` is a recipe, not a value: its `raw` may carry
    /// statements — a nested aggregate reached through a pointer binds the
    /// intermediate pointer to a `var`, and `p[i]` on a raw record binds the
    /// element address.  Every use of the address re-emits them, so an
    /// operation that uses one address twice declares the same `var` name
    /// twice.  Hand those statements back to the caller, which emits them once
    /// ahead of the operation, and leave an address whose `raw` is
    /// statement-free.
    ///
    /// The address expression itself is untouched, so a place used exactly
    /// once (an ordinary store) is emitted exactly as before.
    pub(crate) fn hoist_address_stmts(
        &self,
        address: CObjectAddress,
    ) -> (Vec<DaStmt>, CObjectAddress) {
        let CObjectAddress {
            raw,
            raw_is_address,
            ctype,
            byte_offset,
            storage_size_bytes,
        } = address;
        let WithStmts {
            stmts,
            val,
            is_unsafe,
        } = raw;
        (
            stmts,
            CObjectAddress {
                raw: WithStmts::new_val(val).merge_unsafe(is_unsafe),
                raw_is_address,
                ctype,
                byte_offset,
                storage_size_bytes,
            },
        )
    }

    /// Evaluate an address-backed place's address exactly once, for an
    /// operation that reads and writes it.
    ///
    /// `p->f += x`, `p->f++` and every bitfield store are read-modify-writes:
    /// the load and the store are the *same* C lvalue, which C evaluates once.
    /// Beyond hoisting the address's statements, the address expression is
    /// bound to a temporary unless spelling it again is free of effects — a
    /// call must not run twice, and a dereference must not be re-read across
    /// the very store it serves.
    ///
    /// An address that already had no statements and names its place through
    /// a variable is returned untouched, so the emitted code is unchanged for
    /// it.
    pub(crate) fn materialize_address(
        &self,
        address: CObjectAddress,
    ) -> (Vec<DaStmt>, CObjectAddress) {
        let (mut stmts, address) = self.hoist_address_stmts(address);
        if raw_address_is_reevaluable(&address.raw.val) {
            return (stmts, address);
        }
        // The place is kept in its raw byte form: that type is known here
        // without consulting the C type of whatever produced the address.
        let CObjectAddress {
            raw,
            raw_is_address,
            ctype,
            byte_offset,
            storage_size_bytes,
        } = address;
        let tmp = self.renamer.borrow_mut().fresh();
        let is_unsafe = raw.is_unsafe;
        let byte_address = if raw_is_address {
            raw.val
        } else {
            self.pointer_to_raw_address(raw.val)
        };
        stmts.push(DaStmt::Var {
            name: tmp.clone(),
            var_type: DaType::uint64(),
            init: Some(byte_address),
        });
        (
            stmts,
            CObjectAddress {
                raw: WithStmts::new_val(DaExpr::Var(tmp)).merge_unsafe(is_unsafe),
                raw_is_address: true,
                ctype,
                byte_offset,
                storage_size_bytes,
            },
        )
    }

    /// Return an assignable daScript lvalue for an aligned scalar/pointer C
    /// field. Packed, bitfield and aggregate access deliberately fail until
    /// their respective object-memory lowerings exist.
    pub(crate) fn raw_load(&self, address: CObjectAddress) -> TranslationResult<WithStmts<DaExpr>> {
        let ty = self.ast_context.resolve_type(address.ctype.ctype);
        if address.ctype.qualifiers.is_volatile {
            return Err(TranslationError::generic(
                "volatile raw C object access is not implemented",
            ));
        }
        // A whole storage-backed record read out of raw storage is a C
        // by-value copy: the result owns its own bytes, exactly as
        // `union u v = *p` requires.
        if let Some(record_id) = self.storage_backed_record_of(address.ctype.ctype) {
            let raw = self.raw_byte_address(&address);
            return self.load_storage_object(record_id, raw);
        }
        if matches!(ty.kind, CTypeKind::ConstantArray(..) | CTypeKind::Struct(_)) {
            // A record or fixed array whose daScript layout matches Clang's is
            // a daScript value, and the bytes at the address are exactly that
            // value's representation: it is read out through a typed temporary
            // rather than by dereferencing the address as a record.
            return self.load_natural_aggregate(address);
        }
        let target = self.convert_type(address.ctype)?;
        let pointer = DaType::pointer(target.clone());
        let storage_size = self.raw_storage_size(&address)?;
        if storage_size == 0 {
            return Err(TranslationError::generic(
                "zero-sized raw C field is invalid",
            ));
        }
        if !self.address_is_typed_aligned(&address)? {
            let tmp = self.renamer.borrow_mut().fresh();
            let byte_address = self.raw_byte_address(&address);
            let tmp_address = self.pointer_to_raw_address(DaExpr::Unsafe(Box::new(DaExpr::Addr(
                Box::new(DaExpr::Var(tmp.clone())),
            ))));
            let mut stmts = byte_address.stmts;
            stmts.push(DaStmt::Var {
                name: tmp.clone(),
                var_type: target,
                init: None,
            });
            stmts.push(DaStmt::Expr(DaExpr::Call(
                Box::new(DaExpr::Var("c2da_rt_memcpy".into())),
                vec![
                    tmp_address,
                    byte_address.val,
                    self.integer_literal_for_type(
                        DaExpr::ConstInt(storage_size as i64),
                        DaType::uint64(),
                    ),
                ],
            )));
            return Ok(WithStmts::new(stmts, DaExpr::Var(tmp)).merge_unsafe(address.raw.is_unsafe));
        }
        let element_index = i64::try_from(address.byte_offset / storage_size).map_err(|_| {
            TranslationError::generic("C field index exceeds daScript integer range")
        })?;
        // daScript's raw-memory runtime writes through pointer indexing; it
        // preserves an assignable location whereas a cast/deref expression is
        // rejected by its dead-write policy.
        Ok(address.raw.map(|raw| {
            DaExpr::Unsafe(Box::new(DaExpr::Index(
                Box::new(self.raw_address_to_pointer(
                    if address.raw_is_address {
                        raw
                    } else {
                        self.pointer_to_raw_address(raw)
                    },
                    pointer,
                )),
                Box::new(DaExpr::ConstInt(element_index)),
            )))
        }))
    }

    /// Store a scalar/pointer C value through an address-backed object. For a
    /// packed field this deliberately materializes a typed temporary and uses
    /// the canonical runtime memcpy boundary instead of an unaligned typed
    /// dereference.
    pub(crate) fn raw_store(
        &self,
        address: CObjectAddress,
        value: WithStmts<DaExpr>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        // A whole storage-backed record written into raw storage overwrites
        // the object's bytes.  Storing the wrapper would put the eight bytes
        // of a storage address there instead.
        if let Some(record_id) = self.storage_backed_record_of(address.ctype.ctype) {
            let raw = self.raw_byte_address(&address);
            return self.store_storage_object(record_id, raw, value);
        }
        let target = self.convert_type(address.ctype)?;
        if matches!(
            self.ast_context.resolve_type(address.ctype.ctype).kind,
            CTypeKind::ConstantArray(..) | CTypeKind::Struct(_)
        ) {
            return self.store_natural_aggregate(address, value);
        }
        let storage_size = self.raw_storage_size(&address)?;
        if self.address_is_typed_aligned(&address)? {
            let lvalue = self.raw_load(address)?;
            let mut stmts = lvalue.stmts;
            stmts.extend(value.stmts);
            let result = value.val.clone();
            stmts.push(DaStmt::Expr(DaExpr::Assign(
                Box::new(lvalue.val),
                Box::new(value.val),
            )));
            return Ok(
                WithStmts::new(stmts, result).merge_unsafe(lvalue.is_unsafe || value.is_unsafe)
            );
        }
        let tmp = self.renamer.borrow_mut().fresh();
        let byte_address = self.raw_byte_address(&address);
        let tmp_address = self.pointer_to_raw_address(DaExpr::Unsafe(Box::new(DaExpr::Addr(
            Box::new(DaExpr::Var(tmp.clone())),
        ))));
        let mut stmts = value.stmts;
        stmts.push(DaStmt::Var {
            name: tmp.clone(),
            var_type: target,
            init: Some(value.val),
        });
        stmts.extend(byte_address.stmts);
        stmts.push(DaStmt::Expr(DaExpr::Call(
            Box::new(DaExpr::Var("c2da_rt_memcpy".into())),
            vec![
                byte_address.val,
                tmp_address,
                self.integer_literal_for_type(
                    DaExpr::ConstInt(storage_size as i64),
                    DaType::uint64(),
                ),
            ],
        )));
        Ok(WithStmts::new(stmts, DaExpr::Var(tmp))
            .merge_unsafe(address.raw.is_unsafe || value.is_unsafe))
    }

    /// Read a C record or fixed array whose daScript layout matches Clang's
    /// out of raw storage.
    ///
    /// The bytes at the address *are* the daScript value's representation, so
    /// the copy goes through a typed temporary and the canonical runtime
    /// memcpy — the address itself can never be dereferenced as a daScript
    /// record, and C's by-value rule wants a copy here anyway.
    fn load_natural_aggregate(
        &self,
        address: CObjectAddress,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let target = writable_type(self.convert_type(address.ctype)?);
        let size = self.raw_storage_size(&address)?;
        let tmp = self.renamer.borrow_mut().fresh();
        let byte_address = self.raw_byte_address(&address);
        let tmp_address = self.pointer_to_raw_address(DaExpr::Unsafe(Box::new(DaExpr::Addr(
            Box::new(DaExpr::Var(tmp.clone())),
        ))));
        let is_unsafe = byte_address.is_unsafe;
        let mut stmts = byte_address.stmts;
        stmts.push(DaStmt::Var {
            name: tmp.clone(),
            var_type: target,
            init: Some(self.default_initializer_for_ctype(address.ctype.ctype)?),
        });
        stmts.push(DaStmt::Expr(DaExpr::Call(
            Box::new(DaExpr::Var("c2da_rt_memcpy".into())),
            vec![
                tmp_address,
                byte_address.val,
                self.integer_literal_for_type(DaExpr::ConstInt(size as i64), DaType::uint64()),
            ],
        )));
        Ok(WithStmts::new(stmts, DaExpr::Var(tmp)).merge_unsafe(is_unsafe))
    }

    /// Write a C record or fixed array whose daScript layout matches Clang's
    /// into raw storage, through the same typed-temporary boundary.
    fn store_natural_aggregate(
        &self,
        address: CObjectAddress,
        value: WithStmts<DaExpr>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let target = writable_type(self.convert_type(address.ctype)?);
        let size = self.raw_storage_size(&address)?;
        let tmp = self.renamer.borrow_mut().fresh();
        let byte_address = self.raw_byte_address(&address);
        let tmp_address = self.pointer_to_raw_address(DaExpr::Unsafe(Box::new(DaExpr::Addr(
            Box::new(DaExpr::Var(tmp.clone())),
        ))));
        let is_unsafe = byte_address.is_unsafe || value.is_unsafe;
        let mut stmts = value.stmts;
        stmts.push(DaStmt::Var {
            name: tmp.clone(),
            var_type: target,
            init: Some(value.val),
        });
        stmts.extend(byte_address.stmts);
        stmts.push(DaStmt::Expr(DaExpr::Call(
            Box::new(DaExpr::Var("c2da_rt_memcpy".into())),
            vec![
                byte_address.val,
                tmp_address,
                self.integer_literal_for_type(DaExpr::ConstInt(size as i64), DaType::uint64()),
            ],
        )));
        Ok(WithStmts::new(stmts, DaExpr::Var(tmp)).merge_unsafe(is_unsafe))
    }

    pub(crate) fn bitfield_load(
        &self,
        address: CObjectAddress,
        field: CFieldId,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let (width, bit_offset) = match self.ast_context[field].kind {
            CDeclKind::Field {
                bitfield_width: Some(width),
                platform_bit_offset,
                ..
            } => (width, platform_bit_offset % 8),
            _ => {
                return Err(TranslationError::generic(
                    "bitfield load requested for non-bitfield",
                ))
            }
        };
        if width == 0 || width > 63 {
            return Err(TranslationError::generic("unsupported C bitfield width"));
        }
        let storage = self.raw_load(address)?;
        let field_ty = match self.ast_context[field].kind {
            CDeclKind::Field { typ, .. } => typ,
            _ => unreachable!(),
        };
        let target = writable_type(self.convert_type(field_ty)?);
        let mask = (1u64 << width) - 1;
        let extracted = storage.map(|storage| DaExpr::Cast {
            kind: das_ast::CastKind::Cast,
            expr: Box::new(DaExpr::Op2 {
                op: "&",
                left: Box::new(DaExpr::Op2 {
                    op: ">>",
                    left: Box::new(storage),
                    right: Box::new(DaExpr::ConstInt(bit_offset as i64)),
                }),
                right: Box::new(DaExpr::ConstUInt(mask)),
            }),
            to: target.clone(),
        });
        if !self
            .ast_context
            .resolve_type(field_ty.ctype)
            .kind
            .is_signed_integral_type()
        {
            return Ok(extracted);
        }
        // A signed C bitfield holds a two's-complement number `width` bits
        // wide.  Masking it out leaves the value zero-extended, so the sign
        // bit is put back explicitly; the whole computation stays in the
        // field's own daScript type, which has no implicit conversions.
        let type_bits = self.layout_of(field_ty.ctype)?.size_bytes * 8;
        let type_mask = if type_bits >= 64 {
            u64::MAX
        } else {
            (1u64 << type_bits) - 1
        };
        let typed = |bits: u64| DaExpr::Cast {
            kind: das_ast::CastKind::Cast,
            expr: Box::new(DaExpr::ConstUInt(bits & type_mask)),
            to: target.clone(),
        };
        let tmp = self.renamer.borrow_mut().fresh();
        let is_unsafe = extracted.is_unsafe;
        let mut stmts = extracted.stmts;
        stmts.push(DaStmt::Var {
            name: tmp.clone(),
            var_type: target.clone(),
            init: Some(extracted.val),
        });
        stmts.push(DaStmt::Expr(DaExpr::IfThenElse {
            cond: Box::new(DaExpr::Op2 {
                op: "!=",
                left: Box::new(DaExpr::Op2 {
                    op: "&",
                    left: Box::new(DaExpr::Var(tmp.clone())),
                    right: Box::new(typed(1u64 << (width - 1))),
                }),
                right: Box::new(typed(0)),
            }),
            then: Box::new(DaExpr::Block(DaBlock {
                stmts: vec![DaStmt::Expr(DaExpr::Assign(
                    Box::new(DaExpr::Var(tmp.clone())),
                    Box::new(DaExpr::Op2 {
                        op: "|",
                        left: Box::new(DaExpr::Var(tmp.clone())),
                        right: Box::new(typed(!mask)),
                    }),
                ))],
            })),
            elifs: vec![],
            else_: None,
        }));
        Ok(WithStmts::new(stmts, DaExpr::Var(tmp)).merge_unsafe(is_unsafe))
    }

    pub(crate) fn bitfield_store(
        &self,
        address: CObjectAddress,
        field: CFieldId,
        value: WithStmts<DaExpr>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let (width, bit_offset) = match self.ast_context[field].kind {
            CDeclKind::Field {
                bitfield_width: Some(width),
                platform_bit_offset,
                ..
            } => (width, platform_bit_offset % 8),
            _ => {
                return Err(TranslationError::generic(
                    "bitfield store requested for non-bitfield",
                ))
            }
        };
        if width == 0 || width > 63 {
            return Err(TranslationError::generic("unsupported C bitfield width"));
        }
        // A bitfield store is a read-modify-write, so the address serves both
        // halves and must be evaluated once for them.
        let (address_stmts, address) = self.materialize_address(address);
        let storage = self.raw_load(address.clone())?;
        // The read-modify-write is performed in the field's own storage type.
        // Every constant is built in that type too: daScript has no implicit
        // numeric conversion, so a 64-bit mask against a 32-bit storage word
        // is a type error rather than a wider computation.
        let storage_type = writable_type(self.convert_type(address.ctype)?);
        let storage_bits = self.raw_storage_size(&address)? * 8;
        let storage_mask = if storage_bits >= 64 {
            u64::MAX
        } else {
            (1u64 << storage_bits) - 1
        };
        let field_mask = (1u64 << width) - 1;
        let shifted_mask = field_mask << bit_offset;
        let in_storage_type = |expr: DaExpr| {
            if Self::infer_type(&expr).as_ref() == Some(&storage_type) {
                return expr;
            }
            DaExpr::Cast {
                kind: das_ast::CastKind::Cast,
                expr: Box::new(expr),
                to: storage_type.clone(),
            }
        };
        // Masks are bit patterns, the shift distance is a count; each keeps
        // its natural literal spelling and is always given the storage type
        // explicitly, because a bare literal's type comes from its spelling
        // rather than from the word it is applied to.
        let typed_const = |literal: DaExpr| DaExpr::Cast {
            kind: das_ast::CastKind::Cast,
            expr: Box::new(literal),
            to: storage_type.clone(),
        };
        let storage_mask_const = |bits: u64| typed_const(DaExpr::ConstUInt(bits & storage_mask));
        let storage_count_const = |count: u64| typed_const(DaExpr::ConstInt(count as i64));
        let value_expr = value.val.clone();
        let new_storage = storage.zip(value).map(|(old, value)| DaExpr::Op2 {
            op: "|",
            left: Box::new(DaExpr::Op2 {
                op: "&",
                left: Box::new(old),
                right: Box::new(storage_mask_const(!shifted_mask)),
            }),
            right: Box::new(DaExpr::Op2 {
                op: "<<",
                left: Box::new(DaExpr::Op2 {
                    op: "&",
                    left: Box::new(in_storage_type(value)),
                    right: Box::new(storage_mask_const(field_mask)),
                }),
                right: Box::new(storage_count_const(bit_offset as u64)),
            }),
        });
        self.raw_store(address, new_storage)
            .map(|stored| stored.map(|_| value_expr).prepend_stmts(address_stmts))
    }

    pub(crate) fn pointer_member_address(
        &self,
        base: WithStmts<DaExpr>,
        base_ctype: CQualTypeId,
        field: CFieldId,
    ) -> TranslationResult<CObjectAddress> {
        let pointee = match self.ast_context.resolve_type(base_ctype.ctype).kind {
            CTypeKind::Pointer(inner) => inner,
            _ => {
                return Err(TranslationError::generic(
                    "address-backed member requires C record pointer",
                ))
            }
        };
        match self.ast_context.resolve_type(pointee.ctype).kind {
            // A pointer to a union points at the union's bytes, exactly like a
            // pointer to a struct: `&u` yields the wrapper's storage address,
            // never the wrapper itself.
            CTypeKind::Struct(_) | CTypeKind::Union(_) => {}
            _ => {
                return Err(TranslationError::generic(
                    "member pointer does not point to a C record",
                ))
            }
        };
        self.field_address(
            CObjectAddress {
                raw: base,
                raw_is_address: false,
                ctype: base_ctype,
                byte_offset: 0,
                storage_size_bytes: None,
            },
            field,
        )
    }

    pub(crate) fn pointer_member_lvalue(
        &self,
        base: WithStmts<DaExpr>,
        base_ctype: CQualTypeId,
        field: CFieldId,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let address = self.pointer_member_address(base, base_ctype, field)?;
        if matches!(
            self.ast_context[field].kind,
            CDeclKind::Field {
                bitfield_width: Some(_),
                ..
            }
        ) {
            self.bitfield_load(address, field)
        } else {
            self.raw_load(address)
        }
    }

    /// Load a field below an address-backed aggregate place.  The field itself
    /// may be scalar/pointer (supported) or aggregate (a precise diagnostic
    /// until the aggregate-copy layer owns it).
    pub(crate) fn member_place_lvalue(
        &self,
        base: CObjectAddress,
        field: CFieldId,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let address = self.field_address(base, field)?;
        if matches!(
            self.ast_context[field].kind,
            CDeclKind::Field {
                bitfield_width: Some(_),
                ..
            }
        ) {
            self.bitfield_load(address, field)
        } else {
            self.raw_load(address)
        }
    }
}

/// Whether an address expression can be spelled a second time without
/// changing what the program does.
///
/// A name and pure reinterpretations of it are the whole of it: a call has
/// effects, and a dereference or a subscript reads memory the very store this
/// address serves may overwrite.  Anything else is bound to a temporary by
/// `materialize_address` rather than repeated.
fn raw_address_is_reevaluable(expr: &DaExpr) -> bool {
    match expr {
        DaExpr::Var(_) | DaExpr::ConstNull | DaExpr::ConstInt(_) | DaExpr::ConstUInt(_) => true,
        DaExpr::Field(base, _) | DaExpr::SafeField(base, _) => raw_address_is_reevaluable(base),
        DaExpr::Unsafe(inner) => raw_address_is_reevaluable(inner),
        DaExpr::Cast { expr, .. } => raw_address_is_reevaluable(expr),
        _ => false,
    }
}
