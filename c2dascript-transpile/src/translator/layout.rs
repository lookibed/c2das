//! Canonical C object-layout queries backed by the Clang AST exporter.
use super::*;

/// Round `offset` up to the next multiple of `align`.
fn align_up(offset: u64, align: u64) -> u64 {
    if align <= 1 {
        return offset;
    }
    let remainder = offset % align;
    if remainder == 0 {
        offset
    } else {
        offset + (align - remainder)
    }
}

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub(crate) struct CLayout {
    pub size_bytes: u64,
    pub align_bytes: u64,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub(crate) struct CRecordLayout {
    pub object: CLayout,
    /// Kept in bits so bitfield positions do not lose information.
    pub field_offsets_bits: Vec<(CFieldId, u64)>,
}

/// The module's compile-time layout proofs and the records whose fields the
/// module spells by name.
///
/// A natural record is emitted as a daScript struct on the strength of
/// `is_storage_backed_record`'s model of daScript's layout.  The proof makes
/// daslang check that model: for every natural record the module declares,
/// `static_assert`s that daslang's `sizeof`, `alignof` and every field's
/// `offsetof` equal Clang's.  A pointer field access spelled `p.field`
/// (`object_memory.rs`) is only sound under that proof, so every record it
/// names is noted here, and `take_layout_proof_declaration` refuses a module
/// in which one of them has no proof.
#[derive(Default)]
pub(crate) struct LayoutProofs {
    /// The assertions per emitted daScript struct name, in emission order.
    proofs: indexmap::IndexMap<String, (CRecordId, Vec<DaStmt>)>,
    /// The records whose fields are accessed by name.
    named: IndexSet<CRecordId>,
}

impl<'c> Translation<'c> {
    /// Whether the fields of a C record may be accessed by daScript field
    /// name through a typed record pointer: a complete struct emitted with
    /// its own fields (not storage-backed).  The layout equality this relies
    /// on is proven by daslang at compile time (`register_layout_proof`).
    pub(crate) fn record_has_proven_layout(&self, record: CRecordId) -> bool {
        matches!(
            self.ast_context[record].kind,
            CDeclKind::Struct {
                fields: Some(_),
                ..
            }
        ) && !self.is_storage_backed_record(record)
    }

    /// Record the compile-time proof that the daScript struct `sname`, built
    /// from `das_fields` for the natural C record `record`, has Clang's
    /// size, alignment and field offsets.
    pub(crate) fn register_layout_proof(
        &self,
        record: CRecordId,
        sname: &str,
        das_fields: &[DaField],
    ) -> TranslationResult<()> {
        if self.layout_proofs.borrow().proofs.contains_key(sname) {
            return Ok(());
        }
        let layout = self.record_layout(record)?;
        if layout.field_offsets_bits.len() != das_fields.len() {
            return Err(TranslationError::generic(
                "natural record fields do not match the Clang record layout",
            ));
        }
        let ty = DaType::named(sname);
        let assert = |trait_name: &str,
                      subtrait: Option<&str>,
                      expected: u64|
         -> TranslationResult<DaStmt> {
            let expected = i64::try_from(expected)
                .ok()
                .filter(|value| *value <= i64::from(i32::MAX))
                .ok_or_else(|| {
                    TranslationError::generic("C record layout exceeds daScript typeinfo range")
                })?;
            let what = match subtrait {
                Some(field) => format!("{trait_name} {field}"),
                None => trait_name.to_owned(),
            };
            Ok(DaStmt::Expr(DaExpr::Call(
                Box::new(DaExpr::Var("static_assert".into())),
                vec![
                    DaExpr::Op2 {
                        op: "==",
                        left: Box::new(DaExpr::TypeInfo {
                            trait_name: trait_name.to_owned(),
                            subtrait: subtrait.map(str::to_owned),
                            type_arg: Box::new(ty.clone()),
                        }),
                        right: Box::new(DaExpr::ConstInt(expected)),
                    },
                    DaExpr::ConstString(format!("C layout of {sname}: {what}")),
                ],
            )))
        };
        let mut stmts = vec![
            assert("sizeof", None, layout.object.size_bytes)?,
            assert("alignof", None, layout.object.align_bytes)?,
        ];
        for ((_, bits), field) in layout.field_offsets_bits.iter().zip(das_fields) {
            if bits % 8 != 0 {
                return Err(TranslationError::generic(
                    "natural record field is not byte-addressable",
                ));
            }
            stmts.push(assert("offsetof", Some(&field.name), bits / 8)?);
        }
        self.layout_proofs
            .borrow_mut()
            .proofs
            .insert(sname.to_owned(), (record, stmts));
        Ok(())
    }

    /// Note that the module accesses a field of `record` by name.
    pub(crate) fn note_named_field_record(&self, record: CRecordId) {
        self.layout_proofs.borrow_mut().named.insert(record);
    }

    /// The module's one layout-proof function, `None` when it declares no
    /// natural record.
    ///
    /// daslang has no module-scope `static_assert`, but it infers every
    /// function, an uncalled private one included, and a failing
    /// `static_assert` stops the compilation in every run mode (interpreter,
    /// `-jit`, `-exe`, `-aot`) before anything runs; the assertions compile
    /// to nothing.  A record accessed by name without a proof is refused.
    pub(crate) fn take_layout_proof_declaration(&self) -> TranslationResult<Option<DaDecl>> {
        let LayoutProofs { proofs, named } = std::mem::take(&mut *self.layout_proofs.borrow_mut());
        for record in &named {
            if !proofs.values().any(|(proven, _)| proven == record) {
                return Err(TranslationError::generic(
                    "C record fields are accessed by name without a layout proof",
                ));
            }
        }
        if proofs.is_empty() {
            return Ok(None);
        }
        let name = self
            .renamer
            .borrow_mut()
            .pick_name_root("c2da_layout_proofs");
        Ok(Some(DaDecl::Function(DaFunction {
            name,
            params: vec![],
            ret_type: DaType::void(),
            body: Some(DaExpr::Block(DaBlock {
                stmts: proofs.into_values().flat_map(|(_, stmts)| stmts).collect(),
            })),
            annotations: vec![],
            is_public: false,
            is_unsafe: false,
        })))
    }

    pub(crate) fn layout_of(&self, typ: CTypeId) -> TranslationResult<CLayout> {
        if let Some(layout) = self.layout_cache.borrow().get(&typ).copied() {
            return Ok(layout);
        }
        // Clang's layout facts ride on the type node the C source actually
        // names.  A typedef carries them; the builtin it resolves to may never
        // have been exported on its own, so the alias is consulted first and
        // the canonical type only as a fallback.
        let resolved = self.ast_context.resolve_type_id(typ);
        let facts = self
            .ast_context
            .type_layout(typ)
            .or_else(|| self.ast_context.type_layout(resolved))
            .ok_or_else(|| TranslationError::generic("missing Clang target layout for C type"))?;
        if facts.size_bits % 8 != 0 || facts.align_bits == 0 || facts.align_bits % 8 != 0 {
            return Err(TranslationError::generic(
                "invalid Clang target layout for C type",
            ));
        }
        let layout = CLayout {
            size_bytes: facts.size_bits / 8,
            align_bytes: facts.align_bits / 8,
        };
        self.layout_cache.borrow_mut().insert(typ, layout);
        Ok(layout)
    }

    pub(crate) fn sizeof_type(&self, typ: CTypeId) -> TranslationResult<i64> {
        i64::try_from(self.layout_of(typ)?.size_bytes)
            .map_err(|_| TranslationError::generic("C sizeof does not fit daScript integer"))
    }

    pub(crate) fn alignof_type(&self, typ: CTypeId) -> TranslationResult<i64> {
        i64::try_from(self.layout_of(typ)?.align_bytes)
            .map_err(|_| TranslationError::generic("C alignof does not fit daScript integer"))
    }

    pub(crate) fn record_layout(&self, record: CRecordId) -> TranslationResult<CRecordLayout> {
        let (fields, size_bytes, align_bytes) = match &self.ast_context[record].kind {
            CDeclKind::Struct {
                fields,
                platform_byte_size,
                platform_alignment,
                ..
            }
            | CDeclKind::Union {
                fields,
                platform_byte_size,
                platform_alignment,
                ..
            } => (fields, *platform_byte_size, *platform_alignment),
            _ => {
                return Err(TranslationError::generic(
                    "C record layout requested for non-record",
                ))
            }
        };
        let fields = fields
            .as_ref()
            .ok_or_else(|| TranslationError::generic("incomplete C record has no layout"))?;
        if align_bytes == 0 {
            return Err(TranslationError::generic("invalid Clang record alignment"));
        }
        let field_offsets_bits = fields
            .iter()
            .map(|field| match self.ast_context[*field].kind {
                CDeclKind::Field {
                    platform_bit_offset,
                    ..
                } => Ok((*field, platform_bit_offset)),
                _ => Err(TranslationError::generic(
                    "C record contains non-field declaration",
                )),
            })
            .collect::<TranslationResult<Vec<_>>>()?;
        Ok(CRecordLayout {
            object: CLayout {
                size_bytes,
                align_bytes,
            },
            field_offsets_bits,
        })
    }

    /// Whether a C record has to be represented as raw storage — a wrapper
    /// `Name { c2da_storage : uint64 }` holding the address of the object's
    /// bytes — instead of as a daScript record with the same fields.
    ///
    /// The plain record representation is only sound while daScript's natural
    /// layout coincides with Clang's, because every pointer-side access reads
    /// and writes at Clang offsets.  A record whose layout diverges therefore
    /// has to own its bytes, which is exactly the model a C union already
    /// uses.  Divergence is decided from Clang's own facts:
    ///
    /// * a union always overlaps its members and has no record representation;
    /// * `__attribute__((packed))`, `#pragma pack` and an explicit alignment
    ///   are declarations that the layout is not the natural one;
    /// * a bitfield has no daScript field at all;
    /// * a field that is itself storage-backed occupies eight bytes of address
    ///   in daScript rather than its C bytes inline;
    /// * a zero-sized field (a GNU empty struct, a zero-length array, or an
    ///   array of either) takes no bytes in Clang's layout, while daScript
    ///   gives every record field at least one byte, so every later offset
    ///   and the record's size would diverge;
    /// * otherwise the natural layout is recomputed field by field and
    ///   compared against Clang's offsets, size and alignment.
    pub(crate) fn is_storage_backed_record(&self, record: CRecordId) -> bool {
        if let Some(known) = self.storage_backed_cache.borrow().get(&record).copied() {
            return known;
        }
        // A record cannot contain itself by value, but a broken or still
        // incomplete AST must not turn that into an infinite recursion.  The
        // in-progress record is provisionally natural; the real answer
        // replaces it as soon as the walk finishes.
        self.storage_backed_cache.borrow_mut().insert(record, false);
        let verdict = self.compute_storage_backed(record);
        self.storage_backed_cache
            .borrow_mut()
            .insert(record, verdict);
        verdict
    }

    /// The storage-backed record a C type names, if it names one at all.
    pub(crate) fn storage_backed_record_of(&self, ctype: CTypeId) -> Option<CRecordId> {
        match self.ast_context.resolve_type(ctype).kind {
            CTypeKind::Struct(record) | CTypeKind::Union(record) => {
                self.is_storage_backed_record(record).then_some(record)
            }
            _ => None,
        }
    }

    fn compute_storage_backed(&self, record: CRecordId) -> bool {
        let fields = match &self.ast_context[record].kind {
            CDeclKind::Union { .. } => return true,
            CDeclKind::Struct {
                is_packed: true, ..
            }
            | CDeclKind::Struct {
                manual_alignment: Some(_),
                ..
            }
            | CDeclKind::Struct {
                max_field_alignment: Some(_),
                ..
            } => return true,
            CDeclKind::Struct {
                fields: Some(fields),
                ..
            } => fields.clone(),
            // An incomplete struct has no layout to diverge from; it is never
            // accessed as an object either.
            _ => return false,
        };
        let Ok(layout) = self.record_layout(record) else {
            return false;
        };
        let mut offset: u64 = 0;
        let mut max_align: u64 = 1;
        for &field in &fields {
            let (typ, bitfield_width) = match self.ast_context[field].kind {
                CDeclKind::Field {
                    typ,
                    bitfield_width,
                    ..
                } => (typ, bitfield_width),
                _ => return true,
            };
            if bitfield_width.is_some() {
                return true;
            }
            let Some(natural) = self.natural_layout_of(typ.ctype) else {
                return true;
            };
            if natural.align_bytes == 0 || natural.size_bytes == 0 {
                return true;
            }
            offset = align_up(offset, natural.align_bytes);
            let clang_offset = layout
                .field_offsets_bits
                .iter()
                .find_map(|(candidate, bits)| (*candidate == field).then_some(*bits));
            match clang_offset {
                Some(bits) if bits % 8 == 0 && bits / 8 == offset => {}
                _ => return true,
            }
            offset += natural.size_bytes;
            max_align = max_align.max(natural.align_bytes);
        }
        let natural_size = align_up(offset, max_align);
        natural_size != layout.object.size_bytes || max_align != layout.object.align_bytes
    }

    /// The size and alignment a C type occupies inside a daScript record, or
    /// `None` when the type has no inline daScript representation at all.
    fn natural_layout_of(&self, ctype: CTypeId) -> Option<CLayout> {
        match self.ast_context.resolve_type(ctype).kind {
            CTypeKind::Struct(record) => {
                // A storage-backed field is an eight-byte address in daScript,
                // not the record's bytes, so the containing record's layout
                // can never match Clang's.
                if self.is_storage_backed_record(record) {
                    return None;
                }
                self.layout_of(ctype).ok()
            }
            CTypeKind::Union(_) => None,
            CTypeKind::ConstantArray(element, count) => {
                let element = self.natural_layout_of(element)?;
                Some(CLayout {
                    size_bytes: element.size_bytes.checked_mul(count as u64)?,
                    align_bytes: element.align_bytes,
                })
            }
            CTypeKind::IncompleteArray(_) | CTypeKind::VariableArray(..) => None,
            _ => self.layout_of(ctype).ok(),
        }
    }

    pub(crate) fn field_offset(&self, field: CFieldId) -> TranslationResult<i64> {
        let parent = *self
            .ast_context
            .parents
            .get(&field)
            .ok_or_else(|| TranslationError::generic("C field has no record parent"))?;
        let bits = self
            .record_layout(parent)?
            .field_offsets_bits
            .into_iter()
            .find_map(|(candidate, bits)| (candidate == field).then_some(bits))
            .ok_or_else(|| TranslationError::generic("C field missing from record layout"))?;
        if bits % 8 != 0 {
            return Err(TranslationError::generic(
                "offsetof bitfield is not byte-addressable",
            ));
        }
        i64::try_from(bits / 8)
            .map_err(|_| TranslationError::generic("C field offset does not fit daScript integer"))
    }
}
