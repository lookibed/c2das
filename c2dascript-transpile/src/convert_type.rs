use crate::c_ast::*;
use crate::diagnostics::TranslationResult;
use crate::renamer::Renamer;
use crate::TranspilerConfig;
use crate::{CrateSet, ExternCrate};
use das_ast::{DaType, DaTypeKind};
use indexmap::IndexSet;
use std::collections::{HashMap, HashSet};

#[derive(Debug, Hash, PartialEq, Eq, Clone)]
enum FieldKey {
    Field(CFieldId),
    Padding(usize),
}

pub struct TypeConverter {
    pub translate_valist: bool,
    renamer: Renamer<CDeclId>,
    fields: HashMap<CDeclId, Renamer<FieldKey>>,
    suffix_names: HashMap<(CDeclId, &'static str), String>,
    features: HashSet<&'static str>,
    pub extern_crates: CrateSet,
}

impl TypeConverter {
    pub fn new(tcfg: &TranspilerConfig) -> TypeConverter {
        TypeConverter {
            translate_valist: tcfg.translate_valist,
            renamer: Renamer::type_namespace(),
            fields: HashMap::new(),
            suffix_names: HashMap::new(),
            features: HashSet::new(),
            extern_crates: IndexSet::new(),
        }
    }

    fn use_crate(&mut self, extern_crate: ExternCrate) {
        self.extern_crates.insert(extern_crate);
    }

    pub fn features_used(&self) -> &HashSet<&'static str> {
        &self.features
    }

    pub fn extern_crates_used(&self) -> &CrateSet {
        &self.extern_crates
    }

    pub fn declare_decl_name(&mut self, decl_id: CDeclId, name: &str) -> String {
        self.renamer
            .insert(decl_id, name)
            .expect("Name already assigned")
    }

    pub fn alias_decl_name(&mut self, new_decl_id: CDeclId, old_decl_id: CDeclId) {
        self.renamer.alias(new_decl_id, &old_decl_id)
    }

    pub fn resolve_decl_name(&self, decl_id: CDeclId) -> Option<String> {
        self.renamer.get(&decl_id)
    }

    pub fn resolve_decl_suffix_name(&mut self, decl_id: CDeclId, suffix: &'static str) -> &str {
        let key = (decl_id, suffix);
        self.suffix_names.entry(key).or_insert_with(|| {
            let name = self.renamer.get(&decl_id);
            let name = name.as_deref().unwrap_or("Unnamed");
            self.renamer.pick_name(&format!("C2Da_{name}_{suffix}"))
        })
    }

    pub fn declare_field_name(
        &mut self,
        record_id: CRecordId,
        field_id: CFieldId,
        name: &str,
    ) -> String {
        let name = if name.is_empty() {
            "c2da_unnamed"
        } else {
            name
        };
        self.fields
            .entry(record_id)
            .or_insert_with(|| Renamer::keywords())
            .insert(FieldKey::Field(field_id), name)
            .expect("Field already declared")
    }

    pub fn declare_padding(&mut self, record_id: CRecordId, padding_idx: usize) -> String {
        let field = self
            .fields
            .entry(record_id)
            .or_insert_with(|| Renamer::keywords());
        let key = FieldKey::Padding(padding_idx);
        if let Some(name) = field.get(&key) {
            name
        } else {
            field.insert(key, "c2da_padding").unwrap()
        }
    }

    pub fn resolve_field_name(
        &self,
        record_id: Option<CRecordId>,
        field_id: CFieldId,
    ) -> Option<String> {
        let key = FieldKey::Field(field_id);
        match record_id {
            Some(record_id) => self.fields.get(&record_id).and_then(|x| x.get(&key)),
            None => self.fields.values().flat_map(|x| x.get(&key)).next(),
        }
    }

    /// Convert an unqualified C type ID to a daScript type
    pub fn convert(
        &mut self,
        ctxt: &TypedAstContext,
        ctype: CTypeId,
    ) -> TranslationResult<DaType> {
        if self.translate_valist && ctxt.is_va_list(ctype) {
            return Ok(DaType::uint64());
        }
        self.convert_inner(ctxt, ctype)
    }

    fn convert_inner(
        &mut self,
        ctxt: &TypedAstContext,
        ctype: CTypeId,
    ) -> TranslationResult<DaType> {
        match ctxt.index(ctype).kind {
            CTypeKind::Void => Ok(DaType::void()),
            CTypeKind::Bool => Ok(DaType::bool()),
            CTypeKind::Short | CTypeKind::Int => Ok(DaType::int()),
            CTypeKind::Long | CTypeKind::LongLong => Ok(DaType::int64()),
            CTypeKind::UShort | CTypeKind::UInt => Ok(DaType::uint()),
            CTypeKind::ULong | CTypeKind::ULongLong => Ok(DaType::uint64()),
            CTypeKind::SChar | CTypeKind::Char => Ok(DaType::int8()),
            CTypeKind::UChar => Ok(DaType::uint8()),
            CTypeKind::Double | CTypeKind::LongDouble | CTypeKind::Float128 => {
                Ok(DaType::double())
            }
            CTypeKind::Float => Ok(DaType::float()),
            CTypeKind::Int8 => Ok(DaType::int8()),
            CTypeKind::Int16 => Ok(DaType::int16()),
            CTypeKind::Int32 => Ok(DaType::int()),
            CTypeKind::Int64 => Ok(DaType::int64()),
            CTypeKind::IntPtr | CTypeKind::SSize | CTypeKind::PtrDiff => Ok(DaType::int64()),
            CTypeKind::UInt8 => Ok(DaType::uint8()),
            CTypeKind::UInt16 => Ok(DaType::uint16()),
            CTypeKind::UInt32 => Ok(DaType::uint()),
            CTypeKind::UInt64 => Ok(DaType::uint64()),
            CTypeKind::UIntPtr | CTypeKind::Size => Ok(DaType::uint64()),
            CTypeKind::Int128 => Ok(DaType::int64()),
            CTypeKind::UInt128 => Ok(DaType::uint64()),
            CTypeKind::IntMax => Ok(DaType::int64()),
            CTypeKind::UIntMax => Ok(DaType::uint64()),
            CTypeKind::WChar => Ok(DaType::int()),
            CTypeKind::BFloat16 => Ok(DaType::float()),
            CTypeKind::Pointer(qtype) => {
                let pointee = self.convert_pointee(ctxt, qtype.ctype)?;
                Ok(DaType::pointer(pointee))
            }
            CTypeKind::Elaborated(inner)
            | CTypeKind::Decayed(inner)
            | CTypeKind::Paren(inner) => self.convert_inner(ctxt, inner),
            CTypeKind::Struct(decl_id)
            | CTypeKind::Union(decl_id)
            | CTypeKind::Enum(decl_id) => {
                let name = self
                    .resolve_decl_name(decl_id)
                    .or_else(|| {
                        // Check prenamed typedef for anonymous struct/enum/union
                        ctxt.prenamed_decls
                            .iter()
                            .find(|(_, &v)| v == decl_id)
                            .and_then(|(k, _)| {
                                if let CDeclKind::Typedef { name, .. } = &ctxt[*k].kind {
                                    Some(name.clone())
                                } else {
                                    None
                                }
                            })
                    })
                    .unwrap_or_else(|| "Unnamed".to_string());
                Ok(DaType::named(&name))
            }
            CTypeKind::Typedef(decl_id) => {
                let name = self
                    .resolve_decl_name(decl_id)
                    .or_else(|| {
                        if let CDeclKind::Typedef { name, .. } = &ctxt[decl_id].kind {
                            Some(name.clone())
                        } else {
                            None
                        }
                    })
                    .unwrap_or_else(|| "Unnamed".to_string());
                Ok(DaType::named(&name))
            }
            CTypeKind::ConstantArray(inner, _)
            | CTypeKind::IncompleteArray(inner)
            | CTypeKind::VariableArray(inner, _) => {
                let elt = self.convert(ctxt, inner)?;
                Ok(DaType::array(elt))
            }
            CTypeKind::Attributed(ty, _) | CTypeKind::Atomic(ty) => self.convert(ctxt, ty.ctype),
            CTypeKind::Function(_, _, _, _, _) => Ok(DaType::named("function")),
            CTypeKind::TypeOf(ty) | CTypeKind::Auto(ty) => self.convert(ctxt, ty),
            ref t => {
                log::warn!("Unsupported C type kind {:?}, using auto", t);
                Ok(DaType::auto())
            }
        }
    }

    /// Convert a pointer's pointee type
    pub fn convert_pointee(
        &mut self,
        ctxt: &TypedAstContext,
        ctype: CTypeId,
    ) -> TranslationResult<DaType> {
        match ctxt.resolve_type(ctype).kind {
            CTypeKind::Void => {
                // void* → uint64 in daScript (opaque pointer)
                Ok(DaType::uint64())
            }
            CTypeKind::VariableArray(mut elt, _) => {
                while let CTypeKind::VariableArray(elt_, _) = ctxt.resolve_type(elt).kind {
                    elt = elt_
                }
                self.convert(ctxt, elt)
            }
            _ => self.convert(ctxt, ctype),
        }
    }

    /// Convert a function type
    pub fn convert_function(
        &mut self,
        ctxt: &TypedAstContext,
        ret: Option<CQualTypeId>,
        _params: &[CQualTypeId],
        _is_variadic: bool,
    ) -> TranslationResult<DaType> {
        let _ret_type = match ret {
            None => DaType::void(),
            Some(ret) => self.convert(ctxt, ret.ctype)?,
        };
        // daScript has no function pointer type; use `function`
        Ok(DaType::named("function"))
    }

    /// Convert a type as it appears in a function parameter position
    pub fn convert_function_param(
        &mut self,
        ctxt: &TypedAstContext,
        ctype: CTypeId,
    ) -> TranslationResult<DaType> {
        if ctxt.is_va_list(ctype) {
            return Ok(DaType::uint64());
        }
        self.convert(ctxt, ctype)
    }
}
