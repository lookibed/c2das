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

/// Where a C bitfield is loaded from and stored to: the object of the field's
/// declared type (`size_bytes` wide) at `byte_offset` in the record, and the
/// field's first bit inside that object.
#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub(crate) struct CBitfieldUnit {
    pub byte_offset: u64,
    pub bit_offset: u64,
    pub size_bytes: u64,
}

/// One daScript field of a natural record: a C field of its own, or the
/// storage unit a run of bitfields shares.
///
/// A bitfield has no daScript field; the unit its declared type allocates it
/// in (`bitfield_unit`) does.  A natural record spells the unit as one
/// unsigned integer of the unit's size (`c2da_bits_<n>`), and every bitfield
/// of the unit is a shift and a mask on that field
/// (`object_memory.rs bitfield_load` / `bitfield_store`).
#[derive(Debug, Clone, PartialEq, Eq)]
pub(crate) enum NaturalMember {
    Field(CFieldId),
    BitfieldUnit {
        /// The unit's ordinal among the record's units, which names it.
        index: usize,
        byte_offset: u64,
        size_bytes: u64,
        fields: Vec<CFieldId>,
    },
}

impl NaturalMember {
    /// The daScript field name of a bitfield storage unit.
    pub(crate) fn unit_name(index: usize) -> String {
        format!("c2da_bits_{index}")
    }

    /// The unsigned daScript integer of a storage unit's size.
    pub(crate) fn unit_type(size_bytes: u64) -> Option<DaType> {
        Some(match size_bytes {
            1 => DaType::uint8(),
            2 => DaType::uint16(),
            4 => DaType::uint(),
            8 => DaType::uint64(),
            _ => return None,
        })
    }
}

/// The storage unit of a bitfield of a natural record: the daScript field
/// that holds it and the field's bits inside it.
#[derive(Debug, Clone, PartialEq)]
pub(crate) struct NaturalBitfieldUnit {
    pub name: String,
    pub unit_type: DaType,
    pub size_bytes: u64,
    pub bit_offset: u64,
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
        let members = self.natural_members(record).ok_or_else(|| {
            TranslationError::generic("layout proof requested for a storage-backed record")
        })?;
        if members.len() != das_fields.len() {
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
        // One assertion per daScript field: a C field's own Clang offset, or
        // the storage unit's, asserted once for every bitfield it holds.
        for (member, field) in members.iter().zip(das_fields) {
            let offset = match member {
                NaturalMember::Field(id) => {
                    let bits = layout
                        .field_offsets_bits
                        .iter()
                        .find_map(|(candidate, bits)| (candidate == id).then_some(*bits))
                        .ok_or_else(|| {
                            TranslationError::generic("C field missing from record layout")
                        })?;
                    if bits % 8 != 0 {
                        return Err(TranslationError::generic(
                            "natural record field is not byte-addressable",
                        ));
                    }
                    bits / 8
                }
                NaturalMember::BitfieldUnit { byte_offset, .. } => *byte_offset,
            };
            stmts.push(assert("offsetof", Some(&field.name), offset)?);
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
        // `--memory-model linear`: a daScript struct is only ever a C record
        // held by value, never memory a pointer reaches (that is the heap,
        // read at Clang's offsets), so its daScript layout need not be
        // Clang's: a pointer field is a 4-byte `int` offset there.  A field
        // named on such a value (a bitfield unit of a local or global record)
        // needs no proof; a typed daScript pointer to one could only come
        // from `addr`/`reinterpret`, which `check_linear` refuses.
        if self.is_linear() {
            return Ok(None);
        }
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
    /// * a bitfield has no daScript field; its storage unit does, when the
    ///   record's bitfields group into units that lie exactly where Clang
    ///   puts them (`natural_members`): a unit is one unsigned integer of
    ///   its size.  A bitfield that straddles its unit, two units of
    ///   different sizes that overlap, a unit an ordinary field overlaps, an
    ///   unnamed or zero-width bitfield, or a width daScript's shifts cannot
    ///   serve keep the record storage-backed;
    /// * a field that is itself storage-backed is inline integer storage of
    ///   its own size and alignment (`inline_record_storage`); one with no
    ///   such storage (aligned beyond eight bytes), or an array of them,
    ///   would occupy eight bytes of address rather than its C bytes;
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
        // An incomplete struct has no layout to diverge from; it is never
        // accessed as an object either.
        if matches!(
            self.ast_context[record].kind,
            CDeclKind::Struct { fields: None, .. }
        ) {
            return false;
        }
        let members = self.compute_natural_members(record);
        let storage_backed = members.is_none();
        self.natural_members_cache
            .borrow_mut()
            .insert(record, members);
        storage_backed
    }

    /// The daScript fields of a natural record, in declaration order: the
    /// C fields, with every run of bitfields that shares a storage unit
    /// folded into that unit.  `None` for a storage-backed record and for
    /// an incomplete one.
    pub(crate) fn natural_members(&self, record: CRecordId) -> Option<Vec<NaturalMember>> {
        if let Some(members) = self.natural_members_cache.borrow().get(&record) {
            return members.clone();
        }
        if self.is_storage_backed_record(record) {
            return None;
        }
        self.natural_members_cache
            .borrow()
            .get(&record)
            .cloned()
            .flatten()
    }

    /// The storage unit of a bitfield of a natural record, or `None` when
    /// the field is not a bitfield or its record is storage-backed.
    pub(crate) fn natural_bitfield_unit(&self, field: CFieldId) -> Option<NaturalBitfieldUnit> {
        let CDeclKind::Field {
            bitfield_width: Some(_),
            platform_bit_offset,
            ..
        } = self.ast_context[field].kind
        else {
            return None;
        };
        let parent = *self.ast_context.parents.get(&field)?;
        let members = self.natural_members(parent)?;
        members.iter().find_map(|member| match member {
            NaturalMember::BitfieldUnit {
                index,
                byte_offset,
                size_bytes,
                fields,
            } if fields.contains(&field) => Some(NaturalBitfieldUnit {
                name: NaturalMember::unit_name(*index),
                unit_type: NaturalMember::unit_type(*size_bytes)?,
                size_bytes: *size_bytes,
                bit_offset: platform_bit_offset - byte_offset * 8,
            }),
            _ => None,
        })
    }

    /// [`Self::natural_members`] computed from Clang's facts, with the
    /// natural daScript layout of those members recomputed and compared
    /// against Clang's offsets, size and alignment.
    fn compute_natural_members(&self, record: CRecordId) -> Option<Vec<NaturalMember>> {
        let fields = match &self.ast_context[record].kind {
            CDeclKind::Union { .. } => return None,
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
            } => return None,
            CDeclKind::Struct {
                fields: Some(fields),
                ..
            } => fields.clone(),
            _ => return None,
        };
        let layout = self.record_layout(record).ok()?;
        let mut members = vec![];
        let mut offset: u64 = 0;
        let mut max_align: u64 = 1;
        // The unit the previous bitfield lies in, until a field outside it.
        let mut unit: Option<(u64, u64, Vec<CFieldId>)> = None;
        let mut unit_count = 0usize;
        let mut flush = |unit: &mut Option<(u64, u64, Vec<CFieldId>)>,
                         members: &mut Vec<NaturalMember>| {
            if let Some((byte_offset, size_bytes, fields)) = unit.take() {
                members.push(NaturalMember::BitfieldUnit {
                    index: unit_count,
                    byte_offset,
                    size_bytes,
                    fields,
                });
                unit_count += 1;
            }
        };
        for &field in &fields {
            let CDeclKind::Field {
                ref name,
                typ,
                bitfield_width,
                platform_bit_offset,
                platform_type_bitwidth,
            } = self.ast_context[field].kind
            else {
                return None;
            };
            if let Some(width) = bitfield_width {
                // An unnamed bitfield (zero-width ones included) takes no
                // initializer and names no member; it is left to the
                // storage-backed form rather than modelled here.
                if name.is_empty() || width == 0 || width > 63 {
                    return None;
                }
                if platform_type_bitwidth == 0 || platform_type_bitwidth % 8 != 0 {
                    return None;
                }
                let size_bytes = platform_type_bitwidth / 8;
                NaturalMember::unit_type(size_bytes)?;
                // The unit the System V ABI allocates the field in: its
                // declared type, aligned to its size, holding the field
                // whole (`bitfield_unit`).
                let bit_in_unit = platform_bit_offset % platform_type_bitwidth;
                let byte_offset = (platform_bit_offset / platform_type_bitwidth) * size_bytes;
                if bit_in_unit + width > platform_type_bitwidth
                    || byte_offset + size_bytes > layout.object.size_bytes
                {
                    return None;
                }
                match &mut unit {
                    Some((unit_offset, unit_size, unit_fields))
                        if *unit_offset == byte_offset && *unit_size == size_bytes =>
                    {
                        unit_fields.push(field);
                        continue;
                    }
                    // A unit of another size at the same bytes overlaps.
                    Some((unit_offset, unit_size, _)) if byte_offset < *unit_offset + *unit_size => {
                        return None;
                    }
                    _ => {}
                }
                flush(&mut unit, &mut members);
                offset = align_up(offset, size_bytes);
                if offset != byte_offset {
                    return None;
                }
                offset += size_bytes;
                max_align = max_align.max(size_bytes);
                unit = Some((byte_offset, size_bytes, vec![field]));
                continue;
            }
            flush(&mut unit, &mut members);
            let natural = self.natural_layout_of(typ.ctype)?;
            if natural.align_bytes == 0 || natural.size_bytes == 0 {
                return None;
            }
            offset = align_up(offset, natural.align_bytes);
            let clang_offset = layout
                .field_offsets_bits
                .iter()
                .find_map(|(candidate, bits)| (*candidate == field).then_some(*bits));
            match clang_offset {
                Some(bits) if bits % 8 == 0 && bits / 8 == offset => {}
                _ => return None,
            }
            offset += natural.size_bytes;
            max_align = max_align.max(natural.align_bytes);
            members.push(NaturalMember::Field(field));
        }
        flush(&mut unit, &mut members);
        let natural_size = align_up(offset, max_align);
        (natural_size == layout.object.size_bytes && max_align == layout.object.align_bytes)
            .then_some(members)
    }

    /// The size and alignment a C type occupies inside a daScript record, or
    /// `None` when the type has no inline daScript representation at all.
    fn natural_layout_of(&self, ctype: CTypeId) -> Option<CLayout> {
        match self.ast_context.resolve_type(ctype).kind {
            // A storage-backed record field (a union, a packed or bitfield
            // struct) is its bytes inline, as an unsigned integer (or a
            // fixed array of them) of the record's own size and alignment,
            // when it has such a representation; a wrapper would be an
            // eight-byte address instead of the record's bytes.
            CTypeKind::Struct(record) | CTypeKind::Union(record) => {
                if self.is_storage_backed_record(record) {
                    self.inline_record_storage(record)?;
                }
                self.layout_of(ctype).ok()
            }
            CTypeKind::ConstantArray(element, count) => {
                // An array of storage-backed records keeps the whole record
                // storage-backed: its subscripts are not inline places yet.
                match self.ast_context.resolve_type(element).kind {
                    CTypeKind::Union(_) => return None,
                    CTypeKind::Struct(record) if self.is_storage_backed_record(record) => {
                        return None
                    }
                    _ => {}
                }
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

    /// The daScript storage a storage-backed C record (a union, a packed or
    /// bitfield struct) occupies *inline*, as a field of a natural record:
    /// the unsigned integer of the record's alignment (`uint8`, `uint16`,
    /// `uint`, `uint64`), or a fixed array of it when the record is wider
    /// than its alignment.  `None` for a natural record (a daScript field
    /// of its own type), and when the record has no such representation (an
    /// incomplete one, one aligned beyond eight bytes, or a zero-sized one),
    /// in which case the record that holds it is storage-backed too.
    ///
    /// The record keeps its wrapper for every object named on its own (a
    /// local, a global, a parameter): only its place inside a natural record
    /// is these bytes, exactly as an object reached through a pointer is.
    /// A member is read and written at the field's address, through the
    /// member's own type; a member whose daScript type is this storage type
    /// is the field itself (`object_memory.rs field_address`).
    pub(crate) fn inline_record_storage(&self, record: CRecordId) -> Option<DaType> {
        if !matches!(
            self.ast_context[record].kind,
            CDeclKind::Union {
                fields: Some(_),
                ..
            } | CDeclKind::Struct {
                fields: Some(_),
                ..
            }
        ) || !self.is_storage_backed_record(record)
        {
            return None;
        }
        let layout = self.record_layout(record).ok()?.object;
        let unit = match layout.align_bytes {
            1 => DaType::uint8(),
            2 => DaType::uint16(),
            4 => DaType::uint(),
            8 => DaType::uint64(),
            _ => return None,
        };
        if layout.size_bytes == 0 || layout.size_bytes % layout.align_bytes != 0 {
            return None;
        }
        let count = usize::try_from(layout.size_bytes / layout.align_bytes).ok()?;
        Some(if count == 1 {
            unit
        } else {
            DaType::fixed_array(unit, count)
        })
    }

    /// [`Self::inline_record_storage`] for the record a C type names, if any.
    pub(crate) fn inline_record_storage_of(&self, ctype: CTypeId) -> Option<(CRecordId, DaType)> {
        match self.ast_context.resolve_type(ctype).kind {
            CTypeKind::Union(record) | CTypeKind::Struct(record) => {
                Some((record, self.inline_record_storage(record)?))
            }
            _ => None,
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

    /// The object a C bitfield's loads and stores go through.
    ///
    /// The field's declared type, aligned to its own size, when the field
    /// lies wholly inside that object and the object wholly inside the
    /// record: the storage unit the System V ABI allocates a bitfield of a
    /// non-packed record in, which an aligned typed load reads at once.
    /// Otherwise (a packed record whose field straddles that object, or a
    /// unit that would reach past the record's end) the object of the same
    /// type starting at the byte that holds the field's first bit, which the
    /// misaligned path reads byte-wise; that object may reach past the
    /// record's last byte.
    pub(crate) fn bitfield_unit(&self, field: CFieldId) -> TranslationResult<CBitfieldUnit> {
        let CDeclKind::Field {
            bitfield_width: Some(width),
            platform_bit_offset,
            platform_type_bitwidth,
            ..
        } = self.ast_context[field].kind
        else {
            return Err(TranslationError::generic(
                "bitfield unit requested for a non-bitfield",
            ));
        };
        if platform_type_bitwidth == 0 || platform_type_bitwidth % 8 != 0 {
            return Err(TranslationError::generic(
                "bitfield declared type has no whole-byte width",
            ));
        }
        let size_bytes = platform_type_bitwidth / 8;
        let parent = *self
            .ast_context
            .parents
            .get(&field)
            .ok_or_else(|| TranslationError::generic("C field has no record parent"))?;
        let record_size = self.record_layout(parent)?.object.size_bytes;
        let unit_index = platform_bit_offset / platform_type_bitwidth;
        let bit_offset = platform_bit_offset % platform_type_bitwidth;
        let byte_offset = unit_index * size_bytes;
        if bit_offset + width <= platform_type_bitwidth && byte_offset + size_bytes <= record_size {
            return Ok(CBitfieldUnit {
                byte_offset,
                bit_offset,
                size_bytes,
            });
        }
        Ok(CBitfieldUnit {
            byte_offset: platform_bit_offset / 8,
            bit_offset: platform_bit_offset % 8,
            size_bytes,
        })
    }
}
