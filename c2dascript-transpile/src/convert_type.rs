use crate::c_ast::*;
use crate::diagnostics::{TranslationError, TranslationResult};
use crate::renamer::Renamer;
use crate::translator::Translation;
use crate::TranspilerConfig;
use crate::{CrateSet, ExternCrate};
use das_ast::{DaType, DaTypeKind};
use indexmap::IndexSet;
use std::collections::{HashMap, HashSet};

/// Placeholder for a C function type that has no daScript function value:
/// today only the variadic ones, whose ABI boundary is rejected at the call
/// site with its own diagnostic.
pub(crate) const UNTYPED_FUNCTION: &str = "function";

/// The daScript builtin that spells a C scalar arithmetic type, when there is
/// one.  This is the single source of truth for "this C type is a number
/// daScript already has a name for": both the typedef-resolution rule below
/// and the type conversion itself read it, so an alias can never disagree with
/// the type it aliases.
///
/// A C type with no builtin here (a struct, a union, an enumeration, a
/// pointer, an array, a function) returns `None` and keeps its own daScript
/// spelling.
pub(crate) fn scalar_builtin_datype(kind: &CTypeKind) -> Option<DaType> {
    use CTypeKind::*;
    Some(match kind {
        Void => DaType::void(),
        Bool => DaType::bool(),
        Int | Int32 => DaType::int(),
        SChar | Char | Int8 => DaType::int8(),
        Short | Int16 => DaType::int16(),
        Int64 | Long | LongLong | IntPtr | SSize | PtrDiff | IntMax => DaType::int64(),
        UChar | UInt8 => DaType::uint8(),
        UShort | UInt16 => DaType::uint16(),
        UInt | UInt32 => DaType::uint(),
        UInt64 | ULong | ULongLong | UIntPtr | Size | WChar | UIntMax => DaType::uint64(),
        Float | BFloat16 => DaType::float(),
        Double => DaType::double(),
        _ => return None,
    })
}

/// True for the daScript types produced by `Translation::function_value_type`,
/// i.e. the ones that are already callable values and must never be wrapped in
/// `?` or crossed through the raw-pointer ABI.
pub(crate) fn is_function_value_type(ty: &DaType) -> bool {
    matches!(&ty.kind, DaTypeKind::Named(name)
        if name == UNTYPED_FUNCTION || name.starts_with("function<"))
}

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
    pub fn ensure_decl_name(&mut self, decl_id: CDeclId, name: &str) -> String {
        self.resolve_decl_name(decl_id)
            .unwrap_or_else(|| self.declare_decl_name(decl_id, name))
    }
    pub fn alias_decl_name(&mut self, new_id: CDeclId, old_id: CDeclId) {
        self.renamer.alias(new_id, &old_id)
    }
    pub fn resolve_decl_name(&self, decl_id: CDeclId) -> Option<String> {
        self.renamer.get(&decl_id)
    }
    pub fn declare_field_name(
        &mut self,
        rec_id: CRecordId,
        fld_id: CFieldId,
        name: &str,
    ) -> String {
        let key = FieldKey::Field(fld_id);
        if let Some(existing) = self.fields.get(&rec_id).and_then(|r| r.get(&key)) {
            return existing;
        }
        let name = if name.is_empty() {
            "c2da_unnamed"
        } else {
            name
        };
        self.fields
            .entry(rec_id)
            .or_insert_with(|| Renamer::keywords())
            .insert(key, name)
            .expect("Field already declared")
    }
    pub fn resolve_field_name(
        &self,
        rec_id: Option<CRecordId>,
        fld_id: CFieldId,
    ) -> Option<String> {
        let key = FieldKey::Field(fld_id);
        match rec_id {
            Some(id) => self.fields.get(&id)?.get(&key),
            None => self.fields.values().flat_map(|x| x.get(&key)).next(),
        }
    }
}

/// Does a parameter of a C function *type* have to be spelled `var`?
///
/// This must stay the exact mirror of how `Translation::convert_function`
/// declares the parameters of a function *definition* (`param_mut` for a
/// pointer or a non-`const` parameter, read-only for everything else, with a
/// by-value record parameter taken read-only so the callee's writes cannot
/// escape into the caller's object).  daScript's function-type identity
/// ignores parameter *names* but not their `var`-ness, so any divergence here
/// makes `@@f` fail to match the callback typedef that `f` implements.
fn function_type_param_is_var(ctxt: &TypedAstContext, param: CQualTypeId) -> bool {
    let is_const = param.qualifiers.is_const;
    let resolved = &ctxt.resolve_type(param.ctype).kind;
    // `Translation::is_by_value_record_param`: a mutable record parameter is
    // received read-only and copied into a local of its own.
    if !is_const
        && !ctxt.is_va_list(param.ctype)
        && matches!(resolved, CTypeKind::Struct(_) | CTypeKind::Union(_))
    {
        return false;
    }
    matches!(resolved, CTypeKind::Pointer(_)) || !is_const
}

// ====== Translation convenience methods ======

impl<'c> Translation<'c> {
    /// daScript's typed function value for a C function type.
    ///
    /// C `int (*)(int, int)` has no pointer analogue in daScript: the
    /// language's own `function<(a:int;b:int):int>` *is* the callable value.
    /// It compares against `null`, `default<T>` is its null value, `@@name`
    /// takes one from a function and `invoke` calls it.
    ///
    /// The component types are lowered with `convert_type`, the very same
    /// entry point that lowers the parameters and return type of a function
    /// *definition*, and the parameters are spelled `var` by the same rule
    /// `convert_function` uses.  That is what makes `@@f` assignable to the
    /// callback typedef `f` implements: a second, subtly different type
    /// lowering used only inside `function<…>` is precisely how `void *`
    /// became `uint64?` in a typedef and `uint8?` everywhere else.
    ///
    /// Parameter names are mandatory in the type syntax but take no part in
    /// type identity, so they are synthesised.
    ///
    /// A variadic function pointer keeps the untyped placeholder: the variadic
    /// ABI boundary is diagnosed at the call site
    /// (`is_variadic_function_pointer_callee`), and producing a
    /// `TranslationError` here instead would replace that precise diagnostic
    /// with a type-conversion one.
    pub fn function_value_type(
        &self,
        ret: CQualTypeId,
        params: &[CQualTypeId],
        is_variadic: bool,
    ) -> TranslationResult<DaType> {
        if is_variadic {
            return Ok(DaType::named(UNTYPED_FUNCTION));
        }
        let mut rendered = String::from("function<(");
        for (index, param) in params.iter().enumerate() {
            if index > 0 {
                rendered.push(';');
            }
            let param_type = self.convert_type(*param)?;
            if function_type_param_is_var(&self.ast_context, *param) {
                rendered.push_str("var ");
            }
            rendered.push_str(&format!("_arg{index}:{param_type}"));
        }
        rendered.push(')');
        let ret_type = self.convert_type(ret)?;
        rendered.push_str(&format!(":{ret_type}>"));
        Ok(DaType::named(&rendered))
    }

    pub fn convert_type(&self, qual: CQualTypeId) -> TranslationResult<DaType> {
        let dt = self.convert_type_inner(qual.ctype)?;
        // Propagate const qualifier from C type.
        // daScript supports `int const` for values and `int const?` for pointers.
        // Struct fields strip const separately if needed.
        Ok(DaType {
            is_const: qual.qualifiers.is_const,
            ..dt
        })
    }

    pub fn convert_type_inner(&self, typ: CTypeId) -> TranslationResult<DaType> {
        let mut cur = typ;
        loop {
            match &self.ast_context[cur].kind {
                CTypeKind::Typedef(decl_id) => {
                    if let CDeclKind::Typedef { name, typ, .. } = &self.ast_context[*decl_id].kind {
                        // Skip __-prefixed — resolve to base
                        if name.starts_with("__") {
                            cur = typ.ctype;
                            continue;
                        }
                        // A typedef of a C scalar arithmetic type is only a
                        // spelling: `size_t`, `ptrdiff_t` and every user alias
                        // of them denote a number daScript already names.
                        // Keeping the alias would make the type a *named* one,
                        // and a named type is not a conversion target — a cast
                        // to it can only be spelled as a bit reinterpretation,
                        // which reads the wrong width and silently corrupts the
                        // value (`(size_t)u` over a 4-byte `unsigned`).  It
                        // would also be rejected in the places daScript refuses
                        // an alias outright (`uint8_t?` in a struct field).
                        // Resolving to the builtin keeps the cast a conversion.
                        let base = self.ast_context.resolve_type(typ.ctype);
                        if scalar_builtin_datype(&base.kind).is_some() {
                            break;
                        }
                        // For struct/enum typedefs, register under the struct's record ID
                        // rather than the typedef's decl_id. The typedef handler's
                        // ensure_decl_name(rec_id, &name) searches by the record ID;
                        // using the same key ensures the name is found and reused.
                        let name_key = match &base.kind {
                            CTypeKind::Struct(r) | CTypeKind::Union(r) | CTypeKind::Enum(r) => *r,
                            _ => *decl_id,
                        };
                        let resolved_name = self
                            .type_converter
                            .borrow_mut()
                            .ensure_decl_name(name_key, name);
                        return Ok(DaType::named(&resolved_name));
                    }
                    break;
                }
                CTypeKind::Elaborated(inner) | CTypeKind::Paren(inner) => {
                    cur = *inner;
                }
                _ => break,
            }
        }
        let resolved = self.ast_context.resolve_type(typ);
        // Every C scalar arithmetic type is spelled by the shared table, so a
        // typedef of one and the type itself can never diverge.
        if let Some(scalar) = scalar_builtin_datype(&resolved.kind) {
            return Ok(scalar);
        }
        use CTypeKind::*;
        match resolved.kind {
            // daScript has no 128-bit integer and no wider-than-double float.
            // Silently narrowing them would change observable C results, so
            // the strict translator refuses instead.
            Int128 | UInt128 => Err(TranslationError::generic(
                "C 128-bit integer type has no daScript representation",
            )),
            LongDouble | Float128 => Err(TranslationError::generic(
                "C extended-precision floating type has no daScript representation",
            )),
            Pointer(inner) => {
                // A pointer to a function is the daScript function value itself.
                if let Function(ret, ref params, is_variadic, _, _) =
                    self.ast_context.resolve_type(inner.ctype).kind
                {
                    let params = params.clone();
                    return self.function_value_type(ret, &params, is_variadic);
                }
                if matches!(self.ast_context.resolve_type(inner.ctype).kind, Void) {
                    // C `void *` is still a pointer at the source boundary.
                    // Only the canonical runtime ABI represents exposed
                    // addresses as uint64; collapsing void* here loses the
                    // type needed to convert that address back to `T?`.
                    return Ok(DaType::pointer(DaType::uint8()));
                }
                let inner_ty = self.convert_type(inner)?;
                Ok(DaType::pointer(inner_ty))
            }
            // A C array of constant extent owns inline storage whose layout
            // Clang already described.  daScript's `T[N]` is the only array
            // form with that property: it is stored inline, it copies by
            // value, and `addr(a[0])` decays to a pointer over the same
            // bytes.  `array<T>` is a heap handle and would make every Clang
            // offset in object_memory.rs wrong.
            ConstantArray(inner, size) => {
                let inner_ty = self.convert_type_raw(inner)?;
                if size == 0 {
                    return Err(TranslationError::generic(
                        "zero-length C array has no daScript storage",
                    ));
                }
                Ok(DaType::fixed_array(inner_ty, size))
            }
            IncompleteArray(inner) | VariableArray(inner, _) => {
                let inner_ty = self.convert_type_raw(inner)?;
                Ok(DaType::array(inner_ty))
            }
            Vector(_, _) | UnhandledSveType => self.reject_vector_type(typ),
            Function(ret, ref params, is_variadic, _, _) => {
                let params = params.clone();
                self.function_value_type(ret, &params, is_variadic)
            }
            Struct(decl_id) | Union(decl_id) | Enum(decl_id) => {
                let decl = &self.ast_context[decl_id];
                if let Some(name) = decl.kind.get_name() {
                    let resolved_name = self
                        .type_converter
                        .borrow_mut()
                        .ensure_decl_name(decl_id, name);
                    Ok(DaType::named(&resolved_name))
                } else {
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
                    // An anonymous enumeration that no typedef names cannot be
                    // referred to anywhere in C except at the declaration that
                    // introduced it, and `convert_enum` has no name to declare
                    // it under.  Inventing an `Unnamed_N` label here would name
                    // a type the module never declares.  C already says what
                    // the variable is: an object of the enumeration's
                    // compatible integer type, and every enumerator is already
                    // exported as a module-level integer constant.
                    if tn.is_none() {
                        if let CDeclKind::Enum { integral_type, .. } = &decl.kind {
                            return self.enum_integral_type(*integral_type);
                        }
                    }
                    let name = tn.unwrap_or_else(|| "Unnamed".into());
                    let resolved_name = self
                        .type_converter
                        .borrow_mut()
                        .ensure_decl_name(decl_id, &name);
                    Ok(DaType::named(&resolved_name))
                }
            }
            _ => Ok(DaType::auto()),
        }
    }

    pub fn convert_type_raw(&self, typ: CTypeId) -> TranslationResult<DaType> {
        self.convert_type(CQualTypeId::new(typ))
    }

    pub fn is_pointer_type(&self, typ: CTypeId) -> bool {
        matches!(
            self.ast_context.resolve_type(typ).kind,
            CTypeKind::Pointer(_)
        )
    }
}
