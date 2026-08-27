//! Canonical C object-layout queries backed by the Clang AST exporter.
use super::*;

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

impl<'c> Translation<'c> {
    pub(crate) fn layout_of(&self, typ: CTypeId) -> TranslationResult<CLayout> {
        let typ = self.ast_context.resolve_type_id(typ);
        if let Some(layout) = self.layout_cache.borrow().get(&typ).copied() {
            return Ok(layout);
        }
        let facts = self
            .ast_context
            .type_layout(typ)
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
