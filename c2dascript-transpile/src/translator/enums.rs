use super::*;
use das_ast::{DaExpr, DaType};

impl<'c> Translation<'c> {
    /// The daScript integer type a C enumeration is laid out in.
    ///
    /// Clang reports the compatible integer type it picked; anything that is
    /// not one of daScript's integer kinds (or a missing report, for a forward
    /// declaration) falls back to `int`, which is what C guarantees for an
    /// enumeration whose values all fit in `int`.
    pub fn enum_integral_type(
        &self,
        integral_type: Option<CQualTypeId>,
    ) -> TranslationResult<DaType> {
        Ok(match integral_type {
            Some(qt) => {
                let dt = self.convert_type(qt)?;
                match dt.kind {
                    DaTypeKind::Int
                    | DaTypeKind::UInt
                    | DaTypeKind::Int8
                    | DaTypeKind::UInt8
                    | DaTypeKind::Int16
                    | DaTypeKind::UInt16
                    | DaTypeKind::Int64
                    | DaTypeKind::UInt64 => dt,
                    _ => DaType::int(),
                }
            }
            None => DaType::int(),
        })
    }

    /// The daScript integer a value of this C enumeration is read as.
    ///
    /// A daScript `enum` is a distinct type with neither truthiness nor an
    /// implicit numeric value, so every C context that treats an enumerator as
    /// a number — a condition, `!`, a comparison against a plain integer — has
    /// to spell the conversion, and the enumeration's own compatible integer
    /// type is the only one that preserves each enumerator's value.
    pub(crate) fn enum_underlying_type(&self, enum_id: CEnumId) -> TranslationResult<DaType> {
        let integral_type = match self.ast_context[enum_id].kind {
            CDeclKind::Enum { integral_type, .. } => integral_type,
            _ => None,
        };
        self.enum_integral_type(integral_type)
    }

    /// A C value converted to an enumeration type that is a daScript `enum`,
    /// or `None` when `target` is not one (an anonymous C enumeration is its
    /// integer type).
    ///
    /// C converts the value to the enumeration's compatible integer type
    /// (C11 6.7.2.2p4, 6.3.1.3); a daScript `enum` has no numeric
    /// conversion, so the integer is then re-read as the `enum`.  The
    /// re-read has to start from a value of exactly that integer type: a
    /// `reinterpret<E>` of a `uint8` reads four bytes of which C defined one
    /// (`skill = *demo_p++` in Doom's `G_DoPlayDemo`).
    pub(crate) fn value_to_enum(
        &self,
        value: DaExpr,
        source: Option<CQualTypeId>,
        target: CQualTypeId,
    ) -> TranslationResult<Option<DaExpr>> {
        let CTypeKind::Enum(enum_id) = self.ast_context.resolve_type(target.ctype).kind else {
            return Ok(None);
        };
        let target_da = writable_type(self.convert_type(target)?);
        if !matches!(target_da.kind, DaTypeKind::Named(_)) || target_da.is_numeric() {
            return Ok(None);
        }
        if let Some(source) = source {
            if let CTypeKind::Enum(source_enum) = self.ast_context.resolve_type(source.ctype).kind {
                if source_enum == enum_id {
                    return Ok(Some(value));
                }
            }
        }
        let underlying = self.enum_underlying_type(enum_id)?;
        let source_da = source
            .map(|source| self.convert_type(source).map(writable_type))
            .transpose()?;
        let integer = if source_da.as_ref() == Some(&underlying) {
            value
        } else {
            self.cast_to_type(value, underlying)
        };
        Ok(Some(DaExpr::reinterpret(integer, target_da)))
    }

    pub fn convert_enum(
        &self,
        enum_id: CEnumId,
        name: &Option<String>,
        variants: &[CEnumConstantId],
        integral_type: Option<CQualTypeId>,
    ) -> TranslationResult<DaDecl> {
        let raw_ename = name
            .as_ref()
            .ok_or_else(|| TranslationError::generic("anonymous enum"))?
            .clone();
        let ename = self
            .type_converter
            .borrow_mut()
            .ensure_decl_name(enum_id, &raw_ename);
        let base = self.enum_integral_type(integral_type)?;
        let mut das_variants = vec![];
        for &vid in variants {
            if let CDeclKind::EnumConstant { ref name, value } = self.ast_context[vid].kind {
                let das_val = match value {
                    ConstIntExpr::U(v) => Some(DaExpr::ConstUInt(v)),
                    ConstIntExpr::I(v) => Some(DaExpr::ConstInt(v)),
                };
                // A C enumerator can be spelled with a daScript reserved word.
                // It must go through the same renamer as the global alias that
                // Pass 3 exports, or the two names drift apart.
                das_variants.push(DaEnumVariant {
                    name: self.declare_value_name(vid, name),
                    value: das_val,
                });
            }
        }
        Ok(DaDecl::Enumeration(DaEnumeration {
            name: ename,
            base_type: base,
            variants: das_variants,
        }))
    }

    /// The current value of an object of C type `kind`, raised to the C
    /// arithmetic type `to` a compound assignment or `++`/`--` computes in.
    ///
    /// C11 6.5.16.2 makes `E1 op= E2` the operation `E1 op (E2)` after the
    /// usual arithmetic conversions, and 6.5.2.4 / 6.5.3.1 do the same for
    /// `++`/`--`: an operand of enumeration type takes part as its value in
    /// the enumeration's compatible integer type.  The daScript object holds a
    /// daScript `enum`, which no arithmetic operator accepts, so that value is
    /// spelled as a numeric conversion.  Any other operand type is the
    /// ordinary promotion.
    pub(crate) fn object_value_as_arith(
        &self,
        value: DaExpr,
        kind: &CTypeKind,
        to: abi::CArith,
    ) -> DaExpr {
        if matches!(kind, CTypeKind::Enum(_)) {
            return DaExpr::Cast {
                kind: das_ast::CastKind::Cast,
                expr: Box::new(value),
                to: to.da_type(),
            };
        }
        self.promote_operand(value, kind, to)
    }

    /// The result of a compound assignment or `++`/`--` computed in `arith`,
    /// converted back to the object of C type `kind` whose daScript storage
    /// type is `storage` (C11 6.5.16.1: the value is converted to the type of
    /// the assignment expression).
    ///
    /// For an enumeration the value is first narrowed to the enumeration's
    /// compatible integer type (C6.3.1.3, modular for the unsigned types) and
    /// then re-read as the daScript `enum` of that same width; any other type
    /// is the ordinary narrowing to its storage.
    pub(crate) fn arith_result_to_object(
        &self,
        value: DaExpr,
        arith: abi::CArith,
        kind: &CTypeKind,
        storage: &DaType,
    ) -> TranslationResult<DaExpr> {
        if let CTypeKind::Enum(enum_id) = kind {
            let underlying = self.enum_underlying_type(*enum_id)?;
            let integer = self.narrow_arith_to_storage(value, arith, &underlying);
            return Ok(DaExpr::reinterpret(integer, writable_type(storage.clone())));
        }
        Ok(self.narrow_arith_to_storage(value, arith, storage))
    }

    pub fn convert_cast_from_enum(
        &self,
        target_cty: CTypeId,
        val: DaExpr,
    ) -> TranslationResult<DaExpr> {
        let ty = self.convert_type(CQualTypeId::new(target_cty))?;
        Ok(DaExpr::Cast {
            kind: das_ast::CastKind::Cast,
            expr: Box::new(val),
            to: ty,
        })
    }
}
