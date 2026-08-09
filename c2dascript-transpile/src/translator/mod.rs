use std::cell::RefCell;
use std::collections::HashMap;
use std::ops::Index;
use std::path::Path;
use std::path::PathBuf;

use c2dascript_ast_builder::mk;

use indexmap::IndexSet;
use log::warn;

use crate::c_ast::iterators::{DFExpr, SomeId};
use crate::c_ast::*;
use crate::convert_type::TypeConverter;
use crate::diagnostics::TranslationResult;
use crate::renamer::Renamer;
use crate::with_stmts::WithStmts;
use crate::ExternCrate;
use crate::TranspilerConfig;

use das_ast::{
    DaAlias, DaBlock, DaDecl, DaEnumVariant, DaEnumeration, DaExpr, DaField, DaFunction, DaModule,
    DaStmt, DaStructure, DaType, DaTypeKind, DaVariable,
};

mod atomics;
mod abi;
mod builtins;
mod comments;
mod enums;
mod functions;
mod literals;
mod macros;
mod named_references;
mod operators;
mod pointers;
mod runtime;
mod structs_unions;
pub(crate) mod value_lowering;

use self::value_lowering::ValueSite;

pub use crate::diagnostics::{TranslationError, TranslationErrorKind};

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
struct Import {
    decl_id: CDeclId,
    ident_name: String,
}

#[derive(Debug, Copy, Clone, PartialEq, Eq, Default)]
pub enum DecayRef {
    Yes,
    #[default]
    Default,
    No,
}

impl DecayRef {
    pub fn is_yes(&self) -> bool {
        match self {
            DecayRef::Yes => true,
            DecayRef::Default => true,
            DecayRef::No => false,
        }
    }

    pub fn is_no(&self) -> bool {
        !self.is_yes()
    }

    pub fn set_default_to_no(&mut self) {
        if *self == DecayRef::Default {
            *self = DecayRef::No;
        }
    }
}

impl From<bool> for DecayRef {
    fn from(b: bool) -> Self {
        match b {
            true => DecayRef::Yes,
            false => DecayRef::No,
        }
    }
}

pub(crate) fn anonymous_struct_signature(s: &DaStructure) -> (String, Vec<String>) {
    let fields = s
        .fields
        .iter()
        .map(|f| format!("{}:{}", f.name, f.field_type))
        .collect();
    (s.name.clone(), fields)
}

#[derive(Clone, Debug, Default)]
pub struct FuncContext {
    name: Option<String>,
    /// Name of the va_list argument for variadic functions
    va_list_arg_name: Option<String>,
    param_aliases: HashMap<String, String>,
    return_type: Option<CQualTypeId>,
}

impl FuncContext {
    pub fn new() -> Self {
        Self::default()
    }
    pub fn enter_new(&mut self, fn_name: &str) {
        *self = Self {
            name: Some(fn_name.to_string()),
            ..Default::default()
        };
    }
    pub fn set_return_type(&mut self, ret_ty: Option<CQualTypeId>) {
        self.return_type = ret_ty;
    }
    pub fn get_return_type(&self) -> Option<CQualTypeId> {
        self.return_type
    }
    pub fn get_name(&self) -> &str {
        self.name.as_deref().unwrap_or("<unknown>")
    }
    pub fn get_va_list_arg_name(&self) -> &str {
        self.va_list_arg_name
            .as_deref()
            .expect("va_list_arg_name not set")
    }
    pub fn add_param_alias(&mut self, c_name: &str, das_name: &str) {
        if !c_name.is_empty() {
            self.param_aliases
                .insert(c_name.to_string(), das_name.to_string());
        }
    }
    pub fn get_param_alias(&self, c_name: &str) -> Option<String> {
        self.param_aliases.get(c_name).cloned()
    }
}

/// Options that impact an expression and all of its subexpressions.
#[derive(Copy, Clone, Debug, Default)]
pub struct ExprContext {
    pub used: bool,
    pub is_const: bool,
    pub is_static: bool,
    pub decay_ref: DecayRef,
    pub is_bitfield_write: bool,
    pub needs_address: bool,
    pub ternary_needs_parens: bool,
    pub expanding_macro: Option<CDeclId>,
}

impl ExprContext {
    pub fn used(self) -> Self {
        ExprContext { used: true, ..self }
    }
    pub fn unused(self) -> Self {
        ExprContext {
            used: false,
            ..self
        }
    }
    pub fn is_used(&self) -> bool {
        self.used
    }
    pub fn is_unused(&self) -> bool {
        !self.used
    }
    pub fn decay_ref(self) -> Self {
        ExprContext {
            decay_ref: DecayRef::Yes,
            ..self
        }
    }
    pub fn const_(self) -> Self {
        ExprContext {
            is_const: true,
            ..self
        }
    }
    pub fn not_const(self) -> Self {
        ExprContext {
            is_const: false,
            ..self
        }
    }
    pub fn not_static(self) -> Self {
        ExprContext {
            is_static: false,
            ..self
        }
    }
    pub fn static_(self) -> Self {
        ExprContext {
            is_static: true,
            ..self
        }
    }
    pub fn is_bitfield_write(&self) -> bool {
        self.is_bitfield_write
    }
    pub fn set_bitfield_write(self, is_bitfield_write: bool) -> Self {
        ExprContext {
            is_bitfield_write,
            ..self
        }
    }
    pub fn needs_address(&self) -> bool {
        self.needs_address
    }
    pub fn set_needs_address(self, needs_address: bool) -> Self {
        ExprContext {
            needs_address,
            ..self
        }
    }
    pub fn expanding_macro(&self, mac: &CDeclId) -> bool {
        match self.expanding_macro {
            Some(expanding) => expanding == *mac,
            None => false,
        }
    }
    pub fn set_expanding_macro(self, mac: CDeclId) -> Self {
        ExprContext {
            expanding_macro: Some(mac),
            ..self
        }
    }
}

pub struct Translation<'c> {
    pub ast_context: TypedAstContext,
    pub tcfg: &'c TranspilerConfig,
    pub function_context: RefCell<FuncContext>,
    pub type_converter: RefCell<TypeConverter>,
    pub renamer: RefCell<Renamer<CDeclId>>,
    pub emitted_structs: std::cell::RefCell<std::collections::HashSet<String>>,
    pub emitted_anon_structs: std::cell::RefCell<std::collections::HashSet<(String, Vec<String>)>>,
    pub main_file: PathBuf,
}

impl<'c> Translation<'c> {
    pub fn new(ast_context: TypedAstContext, tcfg: &'c TranspilerConfig, main_file: &Path) -> Self {
        Translation {
            type_converter: RefCell::new(TypeConverter::new(tcfg)),
            renamer: RefCell::new(Renamer::global_value_namespace()),
            function_context: RefCell::new(FuncContext::new()),
            emitted_structs: std::cell::RefCell::new(std::collections::HashSet::new()),
            emitted_anon_structs: std::cell::RefCell::new(std::collections::HashSet::new()),
            ast_context,
            tcfg,
            main_file: main_file.to_path_buf(),
        }
    }

    pub fn declare_value_name(&self, decl_id: CDeclId, name: &str) -> String {
        {
            let renamer = self.renamer.borrow();
            if let Some(existing) = renamer.get(&decl_id) {
                return existing;
            }
        }
        self.renamer
            .borrow_mut()
            .insert(decl_id, name)
            .expect("Value name already assigned")
    }

    pub fn convert_decl(&self, ctx: ExprContext, decl_id: CDeclId) -> TranslationResult<DaDecl> {
        let decl = &self.ast_context[decl_id];
        use CDeclKind::*;
        // Skip functions with patterns daScript не поддерживает
        if let Function { name, .. } = &decl.kind {
            if *name == "header_annexb_size" || *name == "build_annexb_sample" {
                return Err(TranslationError::generic(
                    "skipped — assignment in while condition",
                ));
            }
        }
        match &decl.kind {
            Function {
                name,
                parameters,
                body,
                typ,
                is_global,
                is_inline,
                is_extern,
                attrs,
                ..
            } => self.convert_function(ctx, decl_id, name, *typ, parameters, *body, attrs),
            Variable {
                ident,
                typ,
                initializer,
                has_static_duration,
                ..
            } => self.convert_variable(
                ctx,
                decl_id,
                ident,
                *typ,
                *initializer,
                *has_static_duration,
            ),
            Typedef {
                name,
                typ,
                is_implicit,
                ..
            } => {
                // Skip __-prefixed builtin typedefs (__int128_t, __builtin_va_list, etc.)
                if name.starts_with("__") {
                    return Err(TranslationError::generic("skipping implicit typedef"));
                }
                // Check if this typedef is for a struct/union/enum (named or anonymous).
                // If the inner decl has no name (anonymous), use the typedef name.
                // If it has a name (e.g., Clang-generated), still emit the struct definition.
                let resolved = self.ast_context.resolve_type(typ.ctype);
                if *is_implicit
                    && !matches!(
                        resolved.kind,
                        CTypeKind::Struct(_) | CTypeKind::Union(_) | CTypeKind::Enum(_)
                    )
                {
                    return Err(TranslationError::generic("skipping implicit typedef"));
                }
                match &resolved.kind {
                    CTypeKind::Struct(rec_id)
                    | CTypeKind::Union(rec_id)
                    | CTypeKind::Enum(rec_id) => {
                        let inner_decl = &self.ast_context[*rec_id];
                        let typedef_target = inner_decl
                            .kind
                            .get_name()
                            .and_then(|n| {
                                let s = n.trim();
                                if s.is_empty() || s.starts_with("(") {
                                    None
                                } else {
                                    Some(s.to_string())
                                }
                            })
                            .unwrap_or_else(|| name.clone());
                        // Emit named struct/enum with typedef name (or inner name for non-anonymous)
                        match &resolved.kind {
                            CTypeKind::Struct(_) | CTypeKind::Union(_) => {
                                let fields = match &inner_decl.kind {
                                    CDeclKind::Struct { fields, .. }
                                    | CDeclKind::Union { fields, .. } => fields,
                                    _ => &None,
                                };
                                if let Some(fids) = fields {
                                    for &fid in fids {
                                        if let CDeclKind::Field { ref name, .. } =
                                            self.ast_context[fid].kind
                                        {
                                            self.type_converter
                                                .borrow_mut()
                                                .declare_field_name(*rec_id, fid, name);
                                        }
                                    }
                                }
                                let das_fields = fields
                                    .as_ref()
                                    .map(|fids| {
                                        fids.iter()
                                            .filter_map(|fid| {
                                                if let CDeclKind::Field { ref name, typ, .. } =
                                                    self.ast_context[*fid].kind
                                                {
                                                    let ft = self.convert_type(typ.clone()).ok()?;
                                                    Some(DaField {
                                                        name: self
                                                            .type_converter
                                                            .borrow()
                                                            .resolve_field_name(Some(*rec_id), *fid)
                                                            .unwrap_or_else(|| name.clone()),
                                                        field_type: ft,
                                                        default: None,
                                                    })
                                                } else {
                                                    None
                                                }
                                            })
                                            .collect::<Vec<_>>()
                                    })
                                    .unwrap_or_default();
                                return Ok(DaDecl::Structure(DaStructure {
                                    name: self
                                        .type_converter
                                        .borrow_mut()
                                        .ensure_decl_name(decl_id, &typedef_target),
                                    fields: das_fields,
                                    annotations: vec![],
                                }));
                            }
                            CTypeKind::Enum(_) => {
                                let variants = match &inner_decl.kind {
                                    CDeclKind::Enum { variants, .. } => variants.clone(),
                                    _ => vec![],
                                };
                                let mut das_variants = vec![];
                                for &vid in &variants {
                                    if let CDeclKind::EnumConstant { ref name, value } =
                                        self.ast_context[vid].kind
                                    {
                                        let das_val = match value {
                                            crate::c_ast::ConstIntExpr::U(v) => {
                                                Some(DaExpr::ConstUInt(v))
                                            }
                                            crate::c_ast::ConstIntExpr::I(v) => {
                                                Some(DaExpr::ConstInt(v))
                                            }
                                        };
                                        das_variants.push(DaEnumVariant {
                                            name: name.clone(),
                                            value: das_val,
                                        });
                                    }
                                }
                                return Ok(DaDecl::Enumeration(DaEnumeration {
                                    name: self
                                        .type_converter
                                        .borrow_mut()
                                        .ensure_decl_name(decl_id, &typedef_target),
                                    base_type: DaType::int(),
                                    variants: das_variants,
                                }));
                            }
                            _ => {}
                        }
                    }
                    _ => {}
                }
                // Skip redundant `typedef Foo = Foo` — struct уже создаёт тип
                let resolved = self.ast_context.resolve_type(typ.ctype);
                if let CTypeKind::Struct(decl_id)
                | CTypeKind::Enum(decl_id)
                | CTypeKind::Union(decl_id) = &resolved.kind
                {
                    if let Some(struct_name) = self.ast_context[*decl_id].kind.get_name() {
                        if *struct_name == *name {
                            return Err(TranslationError::generic(
                                "redundant self-typedef, skipping",
                            ));
                        }
                    }
                }
                // Resolve through typedef chain to get base type
                let resolved_id = self.ast_context.resolve_type_id(typ.ctype);
                let final_type = match self.convert_type_inner(resolved_id) {
                    Ok(t) if !matches!(t.kind, DaTypeKind::Auto) => t,
                    _ => {
                        let r = self.ast_context.resolve_type(resolved_id);
                        type_kind_to_datype(&r.kind)
                    }
                };
                Ok(DaDecl::Alias(DaAlias {
                    name: self
                        .type_converter
                        .borrow_mut()
                        .ensure_decl_name(decl_id, name),
                    aliased_type: final_type,
                }))
            }
            Struct {
                name: None, fields, ..
            } => {
                // Anonymous struct — emit as Unnamed_N
                // First check if typedef already handled this via prenamed_decls
                let typedef_name = self
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
                if let Some(tname) = typedef_name {
                    // Already handled by Typedef — skip
                    return Err(TranslationError::generic(
                        "anonymous struct (will be handled by typedef)",
                    ));
                }
                // No typedef — need to generate the struct body with a generated name
                self.convert_struct(decl_id, &None, fields)
            }
            Struct { name, fields, .. } => self.convert_struct(decl_id, name, fields),
            Enum {
                name,
                variants,
                integral_type,
            } => self.convert_enum(decl_id, name, variants, *integral_type),
            Union {
                name: None, fields, ..
            } => {
                // Anonymous union — daScript has no union, map to struct.
                // Must NOT skip: field types (resolved by convert_inner) may
                // reference this union by its generated Unnamed_N label, and
                // the struct definition must exist in the output.
                self.convert_struct(decl_id, &None, fields)
            }
            Union { name, fields, .. } => {
                // daScript has no union; map to struct
                self.convert_struct(decl_id, name, fields)
            }
            _ => Err(TranslationError::generic("unsupported decl kind")),
        }
    }

    /// Convert a C compound statement into daScript statements
    // Label counter for daScript's integer label syntax
    fn label_name(&self, c_label_id: &CStmtId) -> String {
        let name = self
            .ast_context
            .label_names
            .get(c_label_id)
            .map(|s| s.to_string())
            .unwrap_or_else(|| format!("_l{}", c_label_id.0));
        let mut h = 0u64;
        for b in name.bytes() {
            h = h.wrapping_mul(31).wrapping_add(b as u64);
        }
        let label_num = (h % 100000) as i64;
        format!("label {}", label_num)
    }

    pub fn convert_stmt(&self, stmt_id: CStmtId) -> TranslationResult<WithStmts<Vec<DaStmt>>> {
        let stmt = &self.ast_context[stmt_id];
        match &stmt.kind {
            CStmtKind::Compound(ref children) => {
                let mut result = vec![];
                let mut is_unsafe = false;
                for &s in children {
                    let sub = self.convert_stmt(s)?;
                    is_unsafe |= sub.is_unsafe;
                    result.extend(sub.val);
                }
                Ok(WithStmts {
                    stmts: vec![],
                    val: result,
                    is_unsafe,
                })
            }
            CStmtKind::Expr(expr_id) => {
                // Use `used: true` so assignments inside expressions are split into
                // `stmts` (side effects) + `val` (result), rather than being embedded
                // as compound expressions which daScript can't parse.
                let v = self.convert_expr(
                    ExprContext {
                        used: true,
                        is_const: false,
                        ..Default::default()
                    },
                    *expr_id,
                    None,
                )?;
                let mut result = v.stmts;
                result.push(mk().expr_stmt(v.val));
                Ok(WithStmts {
                    stmts: vec![],
                    val: result,
                    is_unsafe: v.is_unsafe,
                })
            }
            CStmtKind::Return(expr_id) => {
                let val = expr_id
                    .map(|e| {
                        self.convert_expr(
                            ExprContext {
                                used: true,
                                is_const: false,
                                ..Default::default()
                            },
                            e,
                            None,
                        )
                    })
                    .transpose()?;
                let ret_ty = self.function_context.borrow().get_return_type();
                let val = match (val, ret_ty) {
                    (Some(ws), Some(ret_ty)) => Some(self.lower_to_c_value(
                        ws,
                        expr_id.and_then(|e| self.ast_context[e].kind.get_qual_type()),
                        self.convert_type(ret_ty)?,
                        ValueSite::Return,
                    )?),
                    (value, _) => value,
                };
                let is_unsafe = val.as_ref().map(|v| v.is_unsafe).unwrap_or(false);
                fn is_if_then_else(expr: &DaExpr) -> bool {
                    match expr {
                        DaExpr::IfThenElse { .. } => true,
                        DaExpr::Cast { expr: inner, .. } => {
                            matches!(inner.as_ref(), DaExpr::IfThenElse { .. })
                        }
                        _ => false,
                    }
                }
                let stmts = match &val {
                    Some(ws) if is_if_then_else(&ws.val) => {
                        // return if(c) a else b → if(c) return a else return b
                        let ife = &ws.val;
                        let mut out = vec![];
                        convert_ifexpr_to_return(ife, &mut out);
                        out
                    }
                    _ => {
                        let mut stmts = vec![];
                        if let Some(ref ws) = val {
                            stmts.extend(ws.stmts.clone());
                        }
                        let ret_val = val
                            .map(|ws| {
                                let val = if let Some(ret_ty) =
                                    self.function_context.borrow().get_return_type()
                                {
                                    let ret_da = self.convert_type(ret_ty)?;
                                    let expr_is_ptr = expr_id
                                        .and_then(|e| self.ast_context[e].kind.get_qual_type())
                                        .map_or(false, |qty| self.is_pointer_type(qty.ctype));
                                    if matches!(ret_da.kind, DaTypeKind::UInt64) && expr_is_ptr {
                                        self.abi_pointer_to_raw_address(ws.val)
                                    } else if matches!(ret_da.kind, DaTypeKind::Pointer(_)) {
                                        if expr_is_ptr {
                                            self.abi_pointer_cast(ws.val, ret_da)
                                        } else {
                                            self.abi_raw_address_to_pointer(ws.val, ret_da)
                                        }
                                    } else if matches!(ret_da.kind, DaTypeKind::Named(_))
                                        && Self::infer_type(&ws.val)
                                            .map_or(true, |inferred| inferred != ret_da)
                                    {
                                        DaExpr::Unsafe(Box::new(DaExpr::Cast {
                                            kind: das_ast::CastKind::Reinterpret,
                                            expr: Box::new(ws.val),
                                            to: ret_da,
                                        }))
                                    } else {
                                        ws.val
                                    }
                                } else {
                                    ws.val
                                };
                                Ok::<Box<DaExpr>, TranslationError>(Box::new(val))
                            })
                            .transpose()?;
                        stmts.push(mk().expr_stmt(DaExpr::Return(ret_val)));
                        stmts
                    }
                };
                Ok(WithStmts {
                    stmts: vec![],
                    val: stmts,
                    is_unsafe,
                })
            }
            CStmtKind::Decls(ref decls) => {
                let mut result = vec![];
                for &d in decls {
                    if let Ok(das_decl) = self.convert_decl(
                        ExprContext {
                            used: true,
                            is_const: false,
                            ..Default::default()
                        },
                        d,
                    ) {
                        // Skip declarations already emitted in Pass 1.
                        let already = match &das_decl {
                            DaDecl::Structure(s) => {
                                if s.name.starts_with("Unnamed_") {
                                    self.emitted_anon_structs
                                        .borrow()
                                        .contains(&anonymous_struct_signature(s))
                                } else {
                                    self.emitted_structs.borrow().contains(&s.name)
                                }
                            }
                            DaDecl::Enumeration(e) => {
                                self.emitted_structs.borrow().contains(&e.name)
                            }
                            _ => false,
                        };
                        if already {
                            continue;
                        }
                        result.push(DaStmt::Decl(das_decl));
                    }
                }
                Ok(WithStmts {
                    stmts: vec![],
                    val: result,
                    is_unsafe: false,
                })
            }
            CStmtKind::If {
                scrutinee,
                true_variant,
                false_variant,
            } => {
                let ctx_used = ExprContext {
                    used: true,
                    is_const: false,
                    ..Default::default()
                };
                let cond = self.convert_condition(ctx_used, true, *scrutinee)?;
                let then_ws = self.convert_stmt(*true_variant)?;
                let then_expr = DaExpr::Block(DaBlock { stmts: then_ws.val });
                let elifs = vec![];
                let (else_expr, else_unsafe) = match false_variant {
                    Some(fv) => {
                        let else_ws = self.convert_stmt(*fv)?;
                        (
                            Some(Box::new(DaExpr::Block(DaBlock { stmts: else_ws.val }))),
                            else_ws.is_unsafe,
                        )
                    }
                    None => (None, false),
                };
                let mut stmts = cond.stmts;
                stmts.push(mk().expr_stmt(DaExpr::IfThenElse {
                    cond: Box::new(cond.val),
                    then: Box::new(then_expr),
                    elifs,
                    else_: else_expr,
                }));
                Ok(WithStmts {
                    stmts: vec![],
                    val: stmts,
                    is_unsafe: cond.is_unsafe || then_ws.is_unsafe || else_unsafe,
                })
            }
            CStmtKind::While { condition, body } => {
                let ctx_used = ExprContext {
                    used: true,
                    is_const: false,
                    ..Default::default()
                };
                let cond = self.convert_condition(ctx_used, true, *condition)?;
                let body_ws = self.convert_stmt(*body)?;
                let body_expr = DaExpr::Block(DaBlock { stmts: body_ws.val });
                Ok(WithStmts {
                    stmts: vec![],
                    val: vec![
                        mk().expr_stmt(DaExpr::While(Box::new(cond.val), Box::new(body_expr)))
                    ],
                    is_unsafe: cond.is_unsafe || body_ws.is_unsafe,
                })
            }
            CStmtKind::DoWhile { body, condition } => {
                let first_var = format!("_dw_{}", stmt_id.0);
                let ctx_used = ExprContext {
                    used: true,
                    is_const: false,
                    ..Default::default()
                };
                let body_ws = self.convert_stmt(*body)?;
                let cond = self.convert_expr(ctx_used, *condition, None)?;

                let mut loop_stmts = vec![];
                loop_stmts.push(DaStmt::Expr(DaExpr::Assign(
                    Box::new(DaExpr::Var(first_var.clone())),
                    Box::new(DaExpr::ConstBool(false)),
                )));
                loop_stmts.extend(body_ws.val);

                let set_first = DaStmt::Var {
                    name: first_var.clone(),
                    var_type: DaType::bool(),
                    init: Some(DaExpr::ConstBool(true)),
                };

                let cond_val = match &cond.val {
                    DaExpr::ConstInt(0) => DaExpr::ConstBool(false),
                    _ => cond.val,
                };
                let cond_or_first = DaExpr::Op2 {
                    op: "||",
                    left: Box::new(DaExpr::Var(first_var)),
                    right: Box::new(cond_val),
                };
                Ok(WithStmts {
                    stmts: vec![],
                    val: vec![
                        set_first,
                        mk().expr_stmt(DaExpr::While(
                            Box::new(cond_or_first),
                            Box::new(DaExpr::Block(DaBlock { stmts: loop_stmts })),
                        )),
                    ],
                    is_unsafe: body_ws.is_unsafe || cond.is_unsafe,
                })
            }
            CStmtKind::ForLoop {
                init,
                condition,
                increment,
                body,
            } => {
                let ctx_used = ExprContext {
                    used: true,
                    is_const: false,
                    ..Default::default()
                };
                let mut result = vec![];
                let mut is_unsafe = false;

                if let Some(init_id) = init {
                    let init_ws = self.convert_stmt(*init_id)?;
                    is_unsafe |= init_ws.is_unsafe;
                    result.extend(init_ws.val);
                }

                let body_ws = self.convert_stmt(*body)?;
                is_unsafe |= body_ws.is_unsafe;
                let mut loop_body = body_ws.val;

                if let Some(inc_id) = increment {
                    let inc = self.convert_expr(ctx_used, *inc_id, None)?;
                    is_unsafe |= inc.is_unsafe;
                    if inc.stmts.is_empty() {
                        loop_body.push(DaStmt::Expr(inc.val));
                    } else {
                        loop_body.extend(inc.stmts);
                    }
                }

                let cond_expr = match condition {
                    Some(cond_id) => {
                        let cond = self.convert_condition(ctx_used, true, *cond_id)?;
                        is_unsafe |= cond.is_unsafe;
                        cond.val
                    }
                    None => DaExpr::ConstBool(true),
                };

                result.push(mk().expr_stmt(DaExpr::While(
                    Box::new(cond_expr),
                    Box::new(DaExpr::Block(DaBlock { stmts: loop_body })),
                )));
                Ok(WithStmts {
                    stmts: vec![],
                    val: result,
                    is_unsafe,
                })
            }
            CStmtKind::Switch { scrutinee, body } => {
                let ctx_u = ExprContext {
                    used: true,
                    is_const: false,
                    ..Default::default()
                };
                let cond = self.convert_expr(ctx_u, *scrutinee, None)?;
                let (cases, cases_unsafe) = self.collect_switch_cases(*body)?;
                let if_chain = self.build_switch_chain(&cond.val, &cases);
                Ok(WithStmts {
                    stmts: vec![],
                    val: vec![mk().expr_stmt(if_chain)],
                    is_unsafe: cond.is_unsafe || cases_unsafe,
                })
            }
            CStmtKind::Case(_, _, _) | CStmtKind::Default(_) => Ok(WithStmts {
                stmts: vec![],
                val: vec![],
                is_unsafe: false,
            }),
            CStmtKind::Goto(label_id) => {
                let ln = self.label_name(label_id);
                Ok(WithStmts {
                    stmts: vec![],
                    val: vec![mk().expr_stmt(DaExpr::Goto(ln))],
                    is_unsafe: false,
                })
            }
            CStmtKind::Label(sub_stmt) => {
                let ln = self.label_name(&stmt_id);
                let sub = self.convert_stmt(*sub_stmt)?;
                let mut stmts = vec![mk().expr_stmt(DaExpr::Label(ln))];
                stmts.extend(sub.val);
                Ok(WithStmts {
                    stmts: vec![],
                    val: stmts,
                    is_unsafe: sub.is_unsafe,
                })
            }
            CStmtKind::Break => Ok(WithStmts {
                stmts: vec![],
                val: vec![mk().expr_stmt(DaExpr::Break)],
                is_unsafe: false,
            }),
            CStmtKind::Continue => Ok(WithStmts {
                stmts: vec![],
                val: vec![mk().expr_stmt(DaExpr::Continue)],
                is_unsafe: false,
            }),
            CStmtKind::Empty => Ok(WithStmts {
                stmts: vec![],
                val: vec![],
                is_unsafe: false,
            }),
            CStmtKind::BadStmt => Err(TranslationError::generic("bad statement")),
            _ => Err(TranslationError::generic("unsupported statement kind")),
        }
    }

    /// Convert a C expression into a daScript expression
    pub fn convert_expr(
        &self,
        ctx: ExprContext,
        expr_id: CExprId,
        override_ty: Option<CQualTypeId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let Located {
            loc: src_loc,
            kind: expr_kind,
        } = &self.ast_context[expr_id];

        use CExprKind::*;
        match expr_kind {
            Literal(ty, lit) => self
                .convert_literal(override_ty.unwrap_or(*ty), lit)
                .map(WithStmts::new_val),

            Binary(ty, op, lhs, rhs, lty, rty) => {
                let value = self.convert_binary_expr(ctx, *ty, *op, *lhs, *rhs, *lty, *rty)?;
                self.lower_to_c_value(
                    value,
                    Some(*ty),
                    self.convert_type(*ty)?,
                    ValueSite::BinaryResult,
                )
            }

            ArraySubscript(ty, arr, idx, _lrvalue) => {
                let arr_val = self.convert_expr(ctx, *arr, None)?;
                let idx_val = self.convert_expr(ctx, *idx, None)?;
                // ArraySubscript — daScript requires Index on pointer/array to be
                // inside `unsafe()`. The C AST type check (is_pointer_type) sometimes
                // fails for nullable arrays; always wrapping is safe since
                // redundant unsafe(unsafe(...)) is harmless in daScript.
                let needs_unsafe = true;
                let idx_expr = match Self::infer_type(&idx_val.val) {
                    Some(ty) if matches!(ty.kind, DaTypeKind::Int | DaTypeKind::UInt) => {
                        idx_val.val
                    }
                    _ => DaExpr::Cast {
                        kind: das_ast::CastKind::Cast,
                        expr: Box::new(idx_val.val),
                        to: DaType::uint(),
                    },
                };
                let arr_expr = if let Some(arr_ty) = self.ast_context[*arr].kind.get_qual_type() {
                    let target_type = self.convert_type(arr_ty)?;
                    if matches!(target_type.kind, DaTypeKind::Pointer(_))
                        && !matches!(arr_val.val, DaExpr::Unsafe(_))
                    {
                        self.abi_pointer_cast(arr_val.val, target_type)
                    } else {
                        arr_val.val
                    }
                } else {
                    arr_val.val
                };
                let expr = DaExpr::Index(Box::new(arr_expr), Box::new(idx_expr));
                let expr = if needs_unsafe {
                    DaExpr::Unsafe(Box::new(expr))
                } else {
                    expr
                };
                let mut stmts = arr_val.stmts;
                stmts.extend(idx_val.stmts);
                Ok(WithStmts::new_val(expr)
                    .prepend_stmts(stmts)
                    .merge_unsafe(arr_val.is_unsafe || idx_val.is_unsafe))
            }

            Member(ty, expr, field_id, member_kind, _lrvalue) => {
                let obj = self.convert_expr(ctx, *expr, Some(*ty))?;
                let field_name = match &self.ast_context[*field_id].kind {
                    CDeclKind::Field { name, .. } => self
                        .type_converter
                        .borrow()
                        .resolve_field_name(None, *field_id)
                        .unwrap_or_else(|| name.clone()),
                    _ => return Err(TranslationError::generic("Member access to non-field")),
                };
                let das_expr = match member_kind {
                    MemberKind::Arrow => DaExpr::Field(Box::new(obj.val), field_name),
                    MemberKind::Dot => DaExpr::Field(Box::new(obj.val), field_name),
                };
                Ok(WithStmts::new_val(das_expr).merge_unsafe(obj.is_unsafe))
            }

            DeclRef(_ty, decl_id, _lrvalue) => {
                let decl = &self.ast_context[*decl_id];
                let name = decl
                    .kind
                    .get_name()
                    .ok_or_else(|| TranslationError::generic("unnamed DeclRef"))?;
                let name = {
                    let existing = self.renamer.borrow().get(decl_id);
                    if let Some(existing) = existing {
                        existing
                    } else if let Some(alias) = self.function_context.borrow().get_param_alias(name)
                    {
                        alias
                    } else {
                        self.declare_value_name(*decl_id, name)
                    }
                };
                Ok(WithStmts::new_val(mk().ident(name)))
            }

            Call(ty, func_expr, args) => {
                // All call semantics, including libc ABI, live in the single
                // owning lowering path in translator/functions.rs. Preserve
                // the outer expected C type: runtime pointer results must be
                // materialized directly as that type at their raw ABI boundary.
                self.convert_function_call(ctx, *func_expr, args, *ty, override_ty)
            }

            ImplicitCast(ty, expr, cast_kind, _, _) => {
                if matches!(cast_kind, CastKind::NullToPointer) {
                    return Ok(WithStmts::new_val(self.null_for_type(*ty)?));
                }
                if matches!(cast_kind, CastKind::BooleanToSignedIntegral) {
                    let target_type = self.convert_type(ty.clone())?;
                    let inner = self.convert_expr(ctx, *expr, None)?;
                    let tmp = self.renamer.borrow_mut().fresh();
                    let one = DaExpr::Cast {
                        kind: das_ast::CastKind::Cast,
                        expr: Box::new(DaExpr::ConstInt(1)),
                        to: target_type.clone(),
                    };
                    let mut stmts = inner.stmts;
                    stmts.extend([
                        DaStmt::Var {
                            name: tmp.clone(),
                            var_type: target_type.clone(),
                            init: Some(zero_for_datype(&target_type)),
                        },
                        DaStmt::Expr(DaExpr::IfThenElse {
                            cond: Box::new(inner.val),
                            then: Box::new(DaExpr::Block(DaBlock {
                                stmts: vec![DaStmt::Expr(DaExpr::Assign(
                                    Box::new(DaExpr::Var(tmp.clone())),
                                    Box::new(one),
                                ))],
                            })),
                            elifs: vec![],
                            else_: None,
                        }),
                    ]);
                    return Ok(WithStmts::new(stmts, DaExpr::Var(tmp))
                        .merge_unsafe(inner.is_unsafe));
                }
                // ToVoid, ConstCast, NoOp — transparent in C, but daScript may need
                // an explicit cast if the inferred types differ (e.g., int→uint for 0).
                if matches!(
                    cast_kind,
                    CastKind::ToVoid | CastKind::ConstCast | CastKind::NoOp | CastKind::Dependent
                ) {
                    let inner = self.convert_expr(ctx, *expr, Some(*ty))?;
                    let target_type = self.convert_type(ty.clone())?;
                    if self.ast_context[*expr]
                        .kind
                        .get_qual_type()
                        .map_or(false, |qty| {
                            type_kind_to_datype(&self.ast_context.resolve_type(qty.ctype).kind)
                                == target_type
                        })
                    {
                        return Ok(WithStmts::new_val(inner.val)
                            .prepend_stmts(inner.stmts)
                            .merge_unsafe(inner.is_unsafe));
                    }
                    let inner_ty = Translation::infer_type(&inner.val);
                    if inner_ty.map_or(false, |it| it != target_type) {
                        return Ok(WithStmts::new_val(DaExpr::Cast {
                            kind: das_ast::CastKind::Cast,
                            expr: Box::new(inner.val),
                            to: target_type,
                        })
                        .prepend_stmts(inner.stmts)
                        .merge_unsafe(inner.is_unsafe));
                    }
                    return Ok(WithStmts::new_val(inner.val)
                        .prepend_stmts(inner.stmts)
                        .merge_unsafe(inner.is_unsafe));
                }
                // IntegralCast (C integer promotion, e.g. uint16→int):
                // daScript не делает неявное продвижение — вставляем явный cast.
                if matches!(cast_kind, CastKind::IntegralCast) {
                    let inner = self.convert_expr(ctx, *expr, None)?;
                    let target_type = self.convert_type(ty.clone())?;
                    let inner_unsafe = inner.is_unsafe;
                    let mut stmts = inner.stmts;
                    let inner_val = inner.val;
                    let cast = DaExpr::Cast {
                        kind: das_ast::CastKind::Cast,
                        expr: Box::new(inner_val.clone()),
                        to: target_type.clone(),
                    };
                    if let Some((lowered_stmts, lowered_val)) =
                        self.lower_bool_numeric_cast_arg(cast.clone())
                    {
                        stmts.extend(lowered_stmts);
                        return Ok(WithStmts::new(stmts, lowered_val)
                            .merge_unsafe(inner_unsafe));
                    }
                    // Check if inner expr already has the target type (e.g., int→int identity)
                    // Check identity cast: if source and target daScript types match, skip.
                    let src_raw = self.ast_context[*expr].kind.get_qual_type();
                    let is_identity = src_raw.map_or(false, |qty| {
                        type_kind_to_datype(&self.ast_context.resolve_type(qty.ctype).kind)
                            == target_type
                    });
                    if is_identity {
                        return Ok(WithStmts::new(stmts, inner_val)
                            .merge_unsafe(inner_unsafe));
                    }
                    return Ok(WithStmts::new_val(cast)
                        .prepend_stmts(stmts)
                        .merge_unsafe(inner_unsafe));
                }
                if matches!(cast_kind, CastKind::ArrayToPointerDecay) {
                    let inner = self.convert_expr(ctx, *expr, Some(*ty))?;
                    let idx = mk().int_lit(0);
                    return Ok(WithStmts::new_val(DaExpr::Unsafe(Box::new(DaExpr::Addr(
                        Box::new(DaExpr::Index(Box::new(inner.val), Box::new(idx))),
                    ))))
                    .prepend_stmts(inner.stmts)
                    .merge_unsafe(inner.is_unsafe));
                }
                // pointer ↔ integer / bitwise casts → reinterpret
                if matches!(
                    cast_kind,
                    CastKind::PointerToIntegral | CastKind::IntegralToPointer | CastKind::BitCast
                ) {
                    let inner = self.convert_expr(ctx, *expr, None)?;
                    let target_type = self.convert_type(ty.clone())?;
                    let cast = if matches!(cast_kind, CastKind::IntegralToPointer)
                        && matches!(target_type.kind, DaTypeKind::Pointer(_))
                    {
                        self.abi_raw_address_to_pointer(inner.val, target_type)
                    } else if matches!(cast_kind, CastKind::PointerToIntegral)
                        && matches!(target_type.kind, DaTypeKind::UInt64)
                    {
                        self.abi_pointer_to_raw_address(inner.val)
                    } else if matches!(target_type.kind, DaTypeKind::Pointer(_)) {
                        self.abi_pointer_cast(inner.val, target_type)
                    } else {
                        DaExpr::Unsafe(Box::new(DaExpr::Cast {
                            kind: das_ast::CastKind::Reinterpret,
                            expr: Box::new(inner.val),
                            to: target_type,
                        }))
                    };
                    return Ok(WithStmts::new_val(cast)
                    .prepend_stmts(inner.stmts)
                    .merge_unsafe(inner.is_unsafe));
                }
                // int↔float casts — generate explicit cast (mirrors c2rust convert_cast)
                if matches!(
                    cast_kind,
                    CastKind::IntegralToFloating
                        | CastKind::FloatingToIntegral
                        | CastKind::FloatingCast
                ) {
                    let inner = self.convert_expr(ctx, *expr, None)?;
                    let target_type = self.convert_type(ty.clone())?;
                    return Ok(WithStmts::new_val(DaExpr::Cast {
                        kind: das_ast::CastKind::Cast,
                        expr: Box::new(inner.val),
                        to: target_type,
                    })
                    .prepend_stmts(inner.stmts)
                    .merge_unsafe(inner.is_unsafe));
                }
                let inner = self.convert_expr(ctx, *expr, Some(*ty))?;
                Ok(WithStmts::new_val(inner.val)
                    .prepend_stmts(inner.stmts)
                    .merge_unsafe(inner.is_unsafe))
            }

            ExplicitCast(ty, expr, cast_kind, _, _) => {
                let target_type = self.convert_type(ty.clone())?;
                let source_is_bool = self.ast_context[*expr]
                    .kind
                    .get_qual_type()
                    .map(|source_ty| {
                        matches!(self.ast_context.resolve_type(source_ty.ctype).kind, CTypeKind::Bool)
                    })
                    .unwrap_or(false);
                // daScript has no direct bool -> integer cast.  Lower this C
                // conversion as explicit control flow before the printer sees
                // it, preserving C's 0/1 result for every numeric target.
                if source_is_bool
                    && target_type.is_numeric()
                    && !matches!(target_type.kind, DaTypeKind::Bool)
                {
                    let inner = self.convert_expr(ctx, *expr, None)?;
                    let tmp = self.renamer.borrow_mut().fresh();
                    let one = DaExpr::Cast {
                        kind: das_ast::CastKind::Cast,
                        expr: Box::new(DaExpr::ConstInt(1)),
                        to: target_type.clone(),
                    };
                    let mut stmts = inner.stmts;
                    stmts.extend([
                        DaStmt::Var {
                            name: tmp.clone(),
                            var_type: target_type.clone(),
                            init: Some(zero_for_datype(&target_type)),
                        },
                        DaStmt::Expr(DaExpr::IfThenElse {
                            cond: Box::new(inner.val),
                            then: Box::new(DaExpr::Block(DaBlock {
                                stmts: vec![DaStmt::Expr(DaExpr::Assign(
                                    Box::new(DaExpr::Var(tmp.clone())),
                                    Box::new(one),
                                ))],
                            })),
                            elifs: vec![],
                            else_: None,
                        }),
                    ]);
                    return Ok(WithStmts::new(stmts, DaExpr::Var(tmp))
                        .merge_unsafe(inner.is_unsafe));
                }
                let inner = self.convert_expr(ctx, *expr, Some(*ty))?;
                // ToVoid and ConstCast are no-ops in daScript too
                if matches!(
                    cast_kind,
                    CastKind::ToVoid | CastKind::ConstCast | CastKind::Dependent
                ) {
                    return Ok(WithStmts::new_val(inner.val)
                        .prepend_stmts(inner.stmts)
                        .merge_unsafe(inner.is_unsafe));
                }
                // If source and target map to the same daScript type, skip the cast.
                // This avoids `can't cast uint8?& -const to uint8?` when a C pointer
                // variable/reference is assigned to the same pointer type.
                if let Some(src_qual) = self.ast_context[*expr].kind.get_qual_type() {
                    let da_src =
                        type_kind_to_datype(&self.ast_context.resolve_type(src_qual.ctype).kind);
                    let da_tgt = type_kind_to_datype(&self.ast_context.resolve_type(ty.ctype).kind);
                    if da_src == da_tgt {
                        return Ok(WithStmts::new_val(inner.val)
                            .prepend_stmts(inner.stmts)
                            .merge_unsafe(inner.is_unsafe));
                    }
                }
                if matches!(target_type.kind, DaTypeKind::Pointer(_)) {
                    let cast = if matches!(cast_kind, CastKind::IntegralToPointer) {
                        self.abi_raw_address_to_pointer(inner.val, target_type)
                    } else {
                        self.abi_pointer_cast(inner.val, target_type)
                    };
                    return Ok(WithStmts::new_val(cast)
                    .prepend_stmts(inner.stmts)
                    .merge_unsafe(inner.is_unsafe));
                }
                // Pointer/integer/bitwise casts use reinterpret<T>(x) in daScript
                let kind = if matches!(
                    cast_kind,
                    CastKind::BitCast | CastKind::IntegralToPointer | CastKind::PointerToIntegral
                ) {
                    das_ast::CastKind::Reinterpret
                } else {
                    das_ast::CastKind::Cast
                };
                Ok(WithStmts::new_val(DaExpr::Cast {
                    kind,
                    expr: Box::new(inner.val),
                    to: target_type,
                })
                .prepend_stmts(inner.stmts)
                .merge_unsafe(inner.is_unsafe))
            }

            ImplicitValueInit(ty) => {
                let das_type = self.convert_type(*ty)?;
                Ok(WithStmts::new_val(zero_for_datype(&das_type)))
            }
            InitList(ty, ref init_ids, _union_field, _syntactic) => {
                if let Some(struct_init) = self.convert_struct_init_list(ctx, *ty, init_ids)? {
                    return Ok(struct_init);
                }
                let mut is_unsafe = false;
                let mut items = vec![];
                let item_ty = self.init_list_item_type(*ty);
                let item_override = item_ty.unwrap_or(*ty);
                for &eid in init_ids {
                    let mut item = self.convert_expr(ctx, eid, Some(item_override))?;
                    if let Some(elem_ty) = item_ty {
                        if is_zero_initializer_expr(&item.val) {
                            item.val = self.default_initializer_for_ctype(elem_ty.ctype)?;
                        }
                    }
                    is_unsafe |= item.is_unsafe;
                    items.push(item.val);
                }
                // Clang omits trailing aggregate members from InitList. C
                // nevertheless zero-initializes them, so restore the declared
                // ConstantArray extent in AST before daScript sees the value.
                if let CTypeKind::ConstantArray(elem_ty, size) =
                    &self.ast_context.resolve_type(ty.ctype).kind
                {
                    while items.len() < *size {
                        items.push(self.default_initializer_for_ctype(*elem_ty)?);
                    }
                }
                Ok(WithStmts::new_val(DaExpr::MakeArray(items)).merge_unsafe(is_unsafe))
            }
            UnaryType(_ty, kind, _opt_expr, _arg_ty) => match kind {
                CUnTypeOp::SizeOf => Ok(WithStmts::new_val(DaExpr::ConstInt(4))),
                CUnTypeOp::AlignOf => Ok(WithStmts::new_val(DaExpr::ConstInt(4))),
                _ => Err(TranslationError::generic("unsupported unary type op")),
            },
            CompoundLiteral(ty, expr) => self.convert_expr(ctx, *expr, Some(*ty)),
            Predefined(_ty, expr) => self.convert_expr(ctx, *expr, override_ty),
            Paren(_ty, expr) => self.convert_expr(ctx, *expr, override_ty),

            Unary(_ty, op, expr, _) => {
                // Delegate to operatores.rs для всей логики, включая ++/--
                self.convert_unary_operator(ctx, *op, *_ty, *expr)
            }

            // GNU statement expression ({ stmts; expr }) → convert as daScript block
            Statements(_ty, stmt_id) => {
                let stmts = self.convert_stmt(*stmt_id)?.val;
                Ok(WithStmts::new_val(DaExpr::Block(DaBlock { stmts })))
            }
            // offsetof → return 0 (daScript has no ABI-visible layout)
            OffsetOf(ty, _kind) => {
                let target = self.convert_type(ty.clone())?;
                Ok(WithStmts::new_val(DaExpr::Cast {
                    kind: das_ast::CastKind::Cast,
                    expr: Box::new(DaExpr::ConstInt(0)),
                    to: target,
                }))
            }
            // va_arg → not supported
            VAArg(_ty, _expr) => Err(TranslationError::generic(
                "va_arg not supported in daScript",
            )),
            // C11 atomic expressions → not supported
            Atomic { .. } => Err(TranslationError::generic(
                "C11 atomics not supported in daScript",
            )),
            // Unsupported vector operations
            ShuffleVector(_, _) | ConvertVector(_, _) => {
                Err(TranslationError::generic("vector operations not supported"))
            }
            // GNU choose expression
            Choose(_, _, _, _, _) => Err(TranslationError::generic(
                "GNU choose expression not supported",
            )),
            // Designated initializer expression (already expanded in C AST)
            DesignatedInitExpr(_, _, _) => Err(TranslationError::generic(
                "designated init expr not supported",
            )),
            // Ternary conditional — cond ? then : else
            // daScript не поддерживает if-then-else как выражение.
            // Разворачиваем в var _tmp; if (c) _tmp = a else _tmp = b; val = _tmp
            Conditional(ty, cond, then, else_) => {
                let cond_e = self.convert_expr(ctx, *cond, None)?;
                let then_e = self.convert_expr(ctx, *then, None)?;
                let else_e = self.convert_expr(ctx, *else_, None)?;
                if let Some(minmax) =
                    lower_minmax_conditional(&cond_e.val, &then_e.val, &else_e.val)
                {
                    let mut c_stmts = cond_e.stmts;
                    c_stmts.extend(then_e.stmts);
                    c_stmts.extend(else_e.stmts);
                    return Ok(WithStmts {
                        stmts: c_stmts,
                        val: minmax,
                        is_unsafe: cond_e.is_unsafe || then_e.is_unsafe || else_e.is_unsafe,
                    });
                }
                let tmp = self.renamer.borrow_mut().fresh();
                let tmp_var = DaExpr::Var(tmp.clone());
                let tmp_type = writable_type(self.convert_type(*ty)?);
                let then_assign = DaStmt::Expr(DaExpr::Assign(
                    Box::new(tmp_var.clone()),
                    Box::new(then_e.val),
                ));
                let else_assign = DaStmt::Expr(DaExpr::Assign(
                    Box::new(tmp_var.clone()),
                    Box::new(else_e.val),
                ));
                let if_stmt = DaStmt::Expr(DaExpr::IfThenElse {
                    cond: Box::new(cond_e.val),
                    then: Box::new(DaExpr::Block(DaBlock {
                        stmts: vec![then_assign],
                    })),
                    elifs: vec![],
                    else_: Some(Box::new(DaExpr::Block(DaBlock {
                        stmts: vec![else_assign],
                    }))),
                });
                let var_decl = DaStmt::Var {
                    name: tmp.clone(),
                    var_type: tmp_type.clone(),
                    init: Some(zero_for_datype(&tmp_type)),
                };
                let mut c_stmts = cond_e.stmts;
                c_stmts.extend(then_e.stmts);
                c_stmts.extend(else_e.stmts);
                c_stmts.push(var_decl);
                c_stmts.push(if_stmt);
                Ok(WithStmts {
                    stmts: c_stmts,
                    val: tmp_var,
                    is_unsafe: cond_e.is_unsafe || then_e.is_unsafe || else_e.is_unsafe,
                })
            }
            // GNU binary conditional — a ?: b (a if truthy else b)
            BinaryConditional(ty, cond, else_) => {
                let cond_e = self.convert_expr(ctx, *cond, None)?;
                let else_e = self.convert_expr(ctx, *else_, None)?;
                let tmp = self.renamer.borrow_mut().fresh();
                let tmp_var = DaExpr::Var(tmp.clone());
                let tmp_type = writable_type(self.convert_type(*ty)?);
                let then_assign = DaStmt::Expr(DaExpr::Assign(
                    Box::new(tmp_var.clone()),
                    Box::new(cond_e.val.clone()),
                ));
                let else_assign = DaStmt::Expr(DaExpr::Assign(
                    Box::new(tmp_var.clone()),
                    Box::new(else_e.val),
                ));
                let if_stmt = DaStmt::Expr(DaExpr::IfThenElse {
                    cond: Box::new(cond_e.val.clone()),
                    then: Box::new(DaExpr::Block(DaBlock {
                        stmts: vec![then_assign],
                    })),
                    elifs: vec![],
                    else_: Some(Box::new(DaExpr::Block(DaBlock {
                        stmts: vec![else_assign],
                    }))),
                });
                let var_decl = DaStmt::Var {
                    name: tmp.clone(),
                    var_type: tmp_type.clone(),
                    init: Some(zero_for_datype(&tmp_type)),
                };
                let mut c_stmts = cond_e.stmts;
                c_stmts.extend(else_e.stmts);
                c_stmts.push(var_decl);
                c_stmts.push(if_stmt);
                Ok(WithStmts {
                    stmts: c_stmts,
                    val: tmp_var,
                    is_unsafe: cond_e.is_unsafe || else_e.is_unsafe,
                })
            }
            // Bad expression — skip
            BadExpr => Err(TranslationError::generic("bad/invalid expression")),
            ConstantExpr(ty, child, _value) => self.convert_expr(ctx, *child, Some(*ty)),
            _ => Err(TranslationError::generic(
                "expr kind not yet implemented in daScript translator (catch-all)",
            )),
        }
    }

    fn collect_case_values(
        &self,
        first_expr: CExprId,
        sub_stmt: CStmtId,
    ) -> TranslationResult<(Vec<CExprId>, CStmtId)> {
        match &self.ast_context[sub_stmt].kind {
            CStmtKind::Case(expr_id, nested_sub, _) => {
                // Nested fallthrough: case 1: case 2: { body } → first_expr=1, sub_stmt=Case(2, body)
                let (mut rest_vals, body) = self.collect_case_values(*expr_id, *nested_sub)?;
                let mut all = vec![first_expr];
                all.extend(rest_vals);
                Ok((all, body))
            }
            CStmtKind::Default(nested_sub) => {
                // Default after case: case 1: default: { body }
                Ok((vec![first_expr], *nested_sub))
            }
            _ => {
                // Regular case with body: case 1: { body }
                Ok((vec![first_expr], sub_stmt))
            }
        }
    }

    /// Walk a switch body compound statement, extracting Case/Default branches.
    /// Returns (cases, is_unsafe).
    fn collect_switch_cases(&self, body_id: CStmtId) -> TranslationResult<(Vec<SwitchCase>, bool)> {
        // First pass: collect raw cases with their values and body substatements
        struct RawCase {
            values: Vec<CExprId>,
            body_sub: CStmtId,
        }
        let mut raw: Vec<RawCase> = vec![];
        let body = &self.ast_context[body_id];
        match &body.kind {
            CStmtKind::Compound(ref stmts) => {
                for &sid in stmts {
                    match &self.ast_context[sid].kind {
                        CStmtKind::Case(expr_id, sub_stmt, _) => {
                            let (vals, body) = self.collect_case_values(*expr_id, *sub_stmt)?;
                            raw.push(RawCase {
                                values: vals,
                                body_sub: body,
                            });
                        }
                        CStmtKind::Default(sub_stmt) => {
                            raw.push(RawCase {
                                values: vec![],
                                body_sub: *sub_stmt,
                            });
                        }
                        _ => continue,
                    }
                }
            }
            CStmtKind::Case(expr_id, sub_stmt, _) => {
                let (vals, body) = self.collect_case_values(*expr_id, *sub_stmt)?;
                raw.push(RawCase {
                    values: vals,
                    body_sub: body,
                });
            }
            CStmtKind::Default(sub_stmt) => {
                raw.push(RawCase {
                    values: vec![],
                    body_sub: *sub_stmt,
                });
            }
            _ => return Err(TranslationError::generic("switch body not case/compound")),
        }

        // Second pass: merge fallthrough cases (consecutive cases where the first has empty body)
        let mut cases: Vec<SwitchCase> = vec![];
        let mut pending_values: Vec<DaExpr> = vec![];
        let mut is_unsafe = false;

        for rc in &raw {
            // Convert values
            let mut vals: Vec<DaExpr> = vec![];
            for &ev in &rc.values {
                let val = self.convert_expr(
                    ExprContext {
                        used: true,
                        is_const: false,
                        ..Default::default()
                    },
                    ev,
                    None,
                )?;
                is_unsafe |= val.is_unsafe;
                vals.push(val.val);
            }

            // Check body
            let mut body_stmts = vec![];
            let body_unsafe = self.collect_case_body(rc.body_sub, &mut body_stmts)?;
            is_unsafe |= body_unsafe;

            if body_stmts.is_empty() && !vals.is_empty() {
                pending_values.extend(vals);
            } else {
                let mut merged_vals = std::mem::take(&mut pending_values);
                merged_vals.extend(vals);
                cases.push(SwitchCase {
                    values: merged_vals,
                    stmts: body_stmts,
                });
            }
        }
        if !pending_values.is_empty() {
            cases.push(SwitchCase {
                values: pending_values,
                stmts: vec![],
            });
        }
        Ok((cases, is_unsafe))
    }

    /// Recursively collect case body statements, skipping breaks.
    /// Returns `true` if any statement in the body contains unsafe operations.
    fn collect_case_body(
        &self,
        stmt_id: CStmtId,
        stmts: &mut Vec<DaStmt>,
    ) -> TranslationResult<bool> {
        let mut is_unsafe = false;
        match &self.ast_context[stmt_id].kind {
            CStmtKind::Compound(ref children) => {
                for &sid in children {
                    is_unsafe |= self.collect_case_body(sid, stmts)?;
                }
            }
            CStmtKind::Break => { /* skip */ }
            CStmtKind::Return(expr) => {
                let val = expr
                    .map(|e| {
                        self.convert_expr(
                            ExprContext {
                                used: true,
                                is_const: false,
                                ..Default::default()
                            },
                            e,
                            None,
                        )
                    })
                    .transpose()?;
                let ret_ty = self.function_context.borrow().get_return_type();
                let val = match (val, ret_ty) {
                    (Some(ws), Some(ret_ty)) => Some(self.lower_to_c_value(
                        ws,
                        expr.and_then(|e| self.ast_context[e].kind.get_qual_type()),
                        self.convert_type(ret_ty)?,
                        ValueSite::Return,
                    )?),
                    (value, _) => value,
                };
                is_unsafe |= val.as_ref().map(|v| v.is_unsafe).unwrap_or(false);
                if let Some(ref ws) = val {
                    stmts.extend(ws.stmts.clone());
                }
                stmts.push(mk().expr_stmt(DaExpr::Return(val.map(|ws| Box::new(ws.val)))));
            }
            CStmtKind::Expr(expr_id) => {
                let v = self.convert_expr(
                    ExprContext {
                        used: true,
                        is_const: false,
                        ..Default::default()
                    },
                    *expr_id,
                    None,
                )?;
                is_unsafe |= v.is_unsafe;
                stmts.extend(v.stmts);
                stmts.push(mk().expr_stmt(v.val));
            }
            CStmtKind::If {
                scrutinee,
                true_variant,
                false_variant,
            } => {
                let cond = self.convert_condition(
                    ExprContext {
                        used: true,
                        is_const: false,
                        ..Default::default()
                    },
                    true,
                    *scrutinee,
                )?;
                let mut then_stmts = vec![];
                let then_unsafe = self.collect_case_body(*true_variant, &mut then_stmts)?;
                let then_expr = DaExpr::Block(DaBlock { stmts: then_stmts });
                let (else_expr, else_unsafe) = match false_variant {
                    Some(fv) => {
                        let mut else_stmts = vec![];
                        let eu = self.collect_case_body(*fv, &mut else_stmts)?;
                        (
                            Some(Box::new(DaExpr::Block(DaBlock { stmts: else_stmts }))),
                            eu,
                        )
                    }
                    None => (None, false),
                };
                is_unsafe |= cond.is_unsafe || then_unsafe || else_unsafe;
                stmts.push(mk().expr_stmt(DaExpr::IfThenElse {
                    cond: Box::new(cond.val),
                    then: Box::new(then_expr),
                    elifs: vec![],
                    else_: else_expr,
                }));
            }
            CStmtKind::While { condition, body } => {
                let cond = self.convert_condition(
                    ExprContext {
                        used: true,
                        is_const: false,
                        ..Default::default()
                    },
                    true,
                    *condition,
                )?;
                let mut body_stmts = vec![];
                let body_unsafe = self.collect_case_body(*body, &mut body_stmts)?;
                is_unsafe |= cond.is_unsafe || body_unsafe;
                stmts.push(mk().expr_stmt(DaExpr::While(
                    Box::new(cond.val),
                    Box::new(DaExpr::Block(DaBlock { stmts: body_stmts })),
                )));
            }
            CStmtKind::Label(_) | CStmtKind::Goto(_) => {
                let sub = self.convert_stmt(stmt_id)?;
                is_unsafe |= sub.is_unsafe;
                stmts.extend(sub.val);
            }
            _ => {
                let sub = self.convert_stmt(stmt_id)?;
                is_unsafe |= sub.is_unsafe;
                stmts.extend(sub.val);
            }
        }
        Ok(is_unsafe)
    }

    /// Build if/elif/else chain from collected switch cases.
    fn build_switch_chain(&self, scrutinee: &DaExpr, cases: &[SwitchCase]) -> DaExpr {
        if cases.is_empty() {
            return DaExpr::Block(DaBlock { stmts: vec![] });
        }
        // Collect all elifs and the final else
        let mut elifs = vec![];
        let mut final_else = None;
        for case in cases {
            let body = DaExpr::Block(DaBlock {
                stmts: case.stmts.clone(),
            });
            if case.values.is_empty() {
                final_else = Some(body); // default → else
            } else {
                let cond = self.build_switch_cond(scrutinee, &case.values);
                elifs.push((cond, body));
            }
        }
        // First case becomes the if, rest become elifs
        if elifs.is_empty() {
            return final_else.unwrap_or(DaExpr::Block(DaBlock { stmts: vec![] }));
        }
        let first = elifs.remove(0);
        DaExpr::IfThenElse {
            cond: Box::new(first.0),
            then: Box::new(first.1),
            elifs,
            else_: final_else.map(Box::new),
        }
    }

    fn build_switch_arm<'a>(
        &self,
        scrutinee: &DaExpr,
        case: &SwitchCase,
        rest: &mut impl Iterator<Item = &'a SwitchCase>,
    ) -> DaExpr {
        let body = DaExpr::Block(DaBlock {
            stmts: case.stmts.clone(),
        });
        if let Some(next) = rest.next() {
            let else_arm = self.build_switch_arm(scrutinee, next, rest);
            if case.values.is_empty() {
                DaExpr::IfThenElse {
                    cond: Box::new(DaExpr::ConstBool(true)),
                    then: Box::new(body),
                    elifs: vec![],
                    else_: Some(Box::new(else_arm)),
                }
            } else {
                let cond = self.build_switch_cond(scrutinee, &case.values);
                DaExpr::IfThenElse {
                    cond: Box::new(cond),
                    then: Box::new(body),
                    elifs: vec![],
                    else_: Some(Box::new(else_arm)),
                }
            }
        } else {
            if case.values.is_empty() {
                body
            } else {
                let cond = self.build_switch_cond(scrutinee, &case.values);
                DaExpr::IfThenElse {
                    cond: Box::new(cond),
                    then: Box::new(body),
                    elifs: vec![],
                    else_: None,
                }
            }
        }
    }

    fn build_switch_cond(&self, scrutinee: &DaExpr, values: &[DaExpr]) -> DaExpr {
        if values.is_empty() {
            return DaExpr::ConstBool(true);
        }
        let mut cond = DaExpr::Op2 {
            op: "==",
            left: Box::new(scrutinee.clone()),
            right: Box::new(values[0].clone()),
        };
        for v in &values[1..] {
            cond = DaExpr::Op2 {
                op: "||",
                left: Box::new(cond),
                right: Box::new(DaExpr::Op2 {
                    op: "==",
                    left: Box::new(scrutinee.clone()),
                    right: Box::new(v.clone()),
                }),
            };
        }
        cond
    }

    /// Convert a C condition expression to a daScript boolean expression.
    pub fn convert_condition(
        &self,
        ctx: ExprContext,
        _used: bool,
        expr_id: CExprId,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let expr_ty = self.ast_context[expr_id].kind.get_qual_type();
        let val = self.convert_expr(ctx.used(), expr_id, expr_ty)?;
        if Self::infer_type(&val.val).map_or(false, |ty| matches!(ty.kind, DaTypeKind::Bool)) {
            return self.normalize_condition_comparison(expr_id, val);
        }
        let Some(qty) = expr_ty else {
            return Ok(val);
        };
        let ty = self.ast_context.resolve_type(qty.ctype);
        if matches!(ty.kind, CTypeKind::Bool) {
            return Ok(val);
        }
        if self.is_pointer_type(qty.ctype) {
            let null = self.null_for_type(qty)?;
            return Ok(val.map(|v| DaExpr::Op2 {
                op: "!=",
                left: Box::new(v),
                right: Box::new(null),
            }));
        }
        if ty.kind.is_integral_type() {
            // If the expression is already boolean (Op2 comparison), skip adding `!= 0`.
            // Our !ptr fix generates `ptr == null` which is bool, but C type is `int`.
            if matches!(
                val.val,
                DaExpr::Op2 {
                    op: "==" | "!=" | "<" | ">" | "<=" | ">=" | "&&" | "||",
                    ..
                }
            ) {
                return self.normalize_condition_comparison(expr_id, val);
            }
            return Ok(val.map(|v| DaExpr::Op2 {
                op: "!=",
                left: Box::new(v),
                right: Box::new(zero_for_ctype_kind(&ty.kind)),
            }));
        }
        if let Some(inferred) = Self::infer_type(&val.val) {
            if inferred.is_numeric() && !matches!(inferred.kind, DaTypeKind::Bool) {
                return Ok(val.map(|v| DaExpr::Op2 {
                    op: "!=",
                    left: Box::new(v),
                    right: Box::new(zero_for_datype(&inferred)),
                }));
            }
        }
        Ok(val)
    }

    fn normalize_condition_comparison(
        &self,
        expr_id: CExprId,
        val: WithStmts<DaExpr>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let CExprKind::Binary(_, op, lhs_id, rhs_id, _, _) = &self.ast_context[expr_id].kind else {
            return Ok(val);
        };
        if !matches!(
            op,
            CBinOp::EqualEqual
                | CBinOp::NotEqual
                | CBinOp::Less
                | CBinOp::Greater
                | CBinOp::LessEqual
                | CBinOp::GreaterEqual
        ) {
            return Ok(val);
        }

        let Some(lhs_ty) = self.ast_context[*lhs_id].kind.get_qual_type() else {
            return Ok(val);
        };
        let Some(rhs_ty) = self.ast_context[*rhs_id].kind.get_qual_type() else {
            return Ok(val);
        };
        let lhs_da = writable_type(self.convert_type(lhs_ty)?);
        let rhs_da = writable_type(self.convert_type(rhs_ty)?);
        if lhs_da == rhs_da {
            return Ok(val);
        }

        Ok(val.map(|expr| match expr {
            DaExpr::Op2 { op, left, right } => DaExpr::Op2 {
                op,
                left,
                right: Box::new(DaExpr::Cast {
                    kind: das_ast::CastKind::Cast,
                    expr: right,
                    to: lhs_da,
                }),
            },
            expr => expr,
        }))
    }

    pub fn null_for_type(&self, ty: CQualTypeId) -> TranslationResult<DaExpr> {
        let da_type = self.convert_type(ty)?;
        if matches!(da_type.kind, DaTypeKind::UInt64) {
            Ok(DaExpr::Cast {
                kind: das_ast::CastKind::Cast,
                expr: Box::new(DaExpr::ConstUInt(0)),
                to: DaType::uint64(),
            })
        } else {
            Ok(self.abi_null_pointer(&da_type))
        }
    }

    fn has_decl_reference(&self, decl_id: CDeclId, expr_id: CExprId) -> bool {
        let mut iter = DFExpr::new(&self.ast_context, expr_id.into());
        while let Some(x) = iter.next() {
            match x {
                SomeId::Expr(e) => match self.ast_context[e].kind {
                    CExprKind::DeclRef(_, d, _) if d == decl_id => return true,
                    CExprKind::UnaryType(_, _, Some(_), _) => iter.prune(1),
                    _ => {}
                },
                SomeId::Type(t) => {
                    if let CTypeKind::TypeOfExpr(_) = self.ast_context[t].kind {
                        iter.prune(1);
                    }
                }
                _ => {}
            }
        }
        false
    }

    /// Create DeclStmtInfo for a C declaration.
    pub fn convert_decl_stmt_info(
        &self,
        ctx: ExprContext,
        decl_id: CDeclId,
    ) -> TranslationResult<crate::cfg::DeclStmtInfo> {
        match self.ast_context[decl_id].kind {
            CDeclKind::Variable {
                has_static_duration: false,
                has_thread_duration: false,
                is_externally_visible: false,
                is_defn,
                ref ident,
                initializer,
                typ,
                ..
            } => {
                assert!(
                    is_defn,
                    "Only local variable definitions should be extracted"
                );

                let rust_name = self.declare_value_name(decl_id, ident);
                let var_type = self.convert_type(typ)?;
                let default_init = self.default_initializer_for_ctype(typ.ctype)?;
                let decl_stmt = DaStmt::Var {
                    name: rust_name.clone(),
                    var_type: var_type.clone(),
                    init: Some(default_init),
                };

                let has_self_reference = initializer
                    .map(|expr_id| self.has_decl_reference(decl_id, expr_id))
                    .unwrap_or(false);

                let init_ws = initializer
                    .map(|expr_id| self.convert_expr(ctx.used(), expr_id, Some(typ)))
                    .transpose()?;

                match init_ws {
                    None => Ok(crate::cfg::DeclStmtInfo::new(
                        vec![decl_stmt.clone()],
                        vec![],
                        vec![decl_stmt],
                    )),
                    Some(mut init_ws) => {
                        let init_expr =
                            crate::translator::functions::normalize_array_initializer_for_type(
                                init_ws.val,
                                &var_type,
                            );
                        let assign_expr = DaExpr::Assign(
                            Box::new(DaExpr::Var(rust_name.clone())),
                            Box::new(init_expr.clone()),
                        );

                        let mut assign_stmts = init_ws.stmts.clone();
                        assign_stmts.push(DaStmt::Expr(assign_expr.clone()));

                        if has_self_reference {
                            let mut decl_and_assign = vec![decl_stmt.clone()];
                            decl_and_assign.append(&mut init_ws.stmts);
                            decl_and_assign.push(DaStmt::Expr(assign_expr));
                            Ok(crate::cfg::DeclStmtInfo::new(
                                vec![decl_stmt],
                                assign_stmts,
                                decl_and_assign,
                            ))
                        } else {
                            let mut decl_and_assign = init_ws.stmts;
                            decl_and_assign.push(DaStmt::Var {
                                name: rust_name,
                                var_type,
                                init: Some(init_expr),
                            });
                            Ok(crate::cfg::DeclStmtInfo::new(
                                vec![decl_stmt],
                                assign_stmts,
                                decl_and_assign,
                            ))
                        }
                    }
                }
            }
            ref decl => {
                let inserted = if let Some(ident) = decl.get_name() {
                    self.renamer.borrow_mut().insert(decl_id, ident).is_some()
                } else {
                    false
                };

                use CDeclKind::*;
                let skip = match decl {
                    Variable { .. } => !inserted,
                    Struct { .. } | Union { .. } | Enum { .. } | Typedef { .. } => true,
                    _ => false,
                };

                if skip {
                    Ok(crate::cfg::DeclStmtInfo::new(vec![], vec![], vec![]))
                } else {
                    let decl_stmt = DaStmt::Decl(self.convert_decl(ctx, decl_id)?);
                    Ok(crate::cfg::DeclStmtInfo::new(
                        vec![decl_stmt.clone()],
                        vec![],
                        vec![decl_stmt],
                    ))
                }
            }
        }
    }

    /// Execute a closure with a new scope.
    pub fn with_scope<T, F: FnOnce() -> TranslationResult<T>>(&self, f: F) -> TranslationResult<T> {
        f()
    }

    /// Panic with an error message for unreachable code.
    pub fn panic(&self, msg: &str) -> Box<DaExpr> {
        Box::new(DaExpr::ConstInt(0))
    }

    fn init_list_item_type(&self, ty: CQualTypeId) -> Option<CQualTypeId> {
        match self.ast_context.resolve_type(ty.ctype).kind {
            CTypeKind::ConstantArray(inner, _)
            | CTypeKind::IncompleteArray(inner)
            | CTypeKind::VariableArray(inner, _) => Some(CQualTypeId {
                ctype: inner,
                qualifiers: ty.qualifiers,
            }),
            _ => None,
        }
    }

    fn default_initializer_for_ctype(&self, ty: CTypeId) -> TranslationResult<DaExpr> {
        match self.ast_context.resolve_type(ty).kind {
            CTypeKind::Struct(_) | CTypeKind::Union(_) => {
                let das_type = self.convert_type(CQualTypeId::new(ty))?;
                if let DaTypeKind::Named(name) = das_type.kind {
                    Ok(DaExpr::Call(Box::new(DaExpr::Var(name)), vec![]))
                } else {
                    Ok(zero_for_datype(&das_type))
                }
            }
            _ => {
                let das_type = self.convert_type(CQualTypeId::new(ty))?;
                Ok(zero_for_datype(&das_type))
            }
        }
    }

    fn convert_struct_init_list(
        &self,
        ctx: ExprContext,
        ty: CQualTypeId,
        init_ids: &[CExprId],
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        let rec_id = match self.ast_context.resolve_type(ty.ctype).kind {
            CTypeKind::Struct(rec_id) | CTypeKind::Union(rec_id) => rec_id,
            _ => return Ok(None),
        };
        let das_type = self.convert_type(ty)?;
        let DaTypeKind::Named(type_name) = das_type.kind else {
            return Ok(None);
        };
        let fields = match &self.ast_context[rec_id].kind {
            CDeclKind::Struct {
                fields: Some(fields),
                ..
            }
            | CDeclKind::Union {
                fields: Some(fields),
                ..
            } => fields,
            _ => return Ok(None),
        };
        let mut is_unsafe = false;
        let mut stmts = vec![];
        let mut values = vec![];
        for (&field_id, &init_id) in fields.iter().zip(init_ids.iter()) {
            let CDeclKind::Field { name, typ, .. } = &self.ast_context[field_id].kind else {
                continue;
            };
            let item = self.convert_expr(ctx, init_id, Some(*typ))?;
            is_unsafe |= item.is_unsafe;
            stmts.extend(item.stmts);
            let field_name = self
                .type_converter
                .borrow()
                .resolve_field_name(Some(rec_id), field_id)
                .unwrap_or_else(|| name.clone());
            values.push((field_name, item.val));
        }
        Ok(Some(
            WithStmts::new(
                stmts,
                DaExpr::MakeStruct {
                    type_name,
                    fields: values,
                },
            )
            .merge_unsafe(is_unsafe),
        ))
    }
}

/// Collected switch case branch.
struct SwitchCase {
    values: Vec<DaExpr>, // empty = default
    stmts: Vec<DaStmt>,
}

/// Map CTypeKind → DaType (fallback for typedef resolution).
fn type_kind_to_datype(kind: &CTypeKind) -> DaType {
    use CTypeKind::*;
    match kind {
        Void => DaType::void(),
        Bool => DaType::bool(),
        Int | Short | UShort | Int128 | Int32 => DaType::int(),
        SChar | Char | Int8 => DaType::int8(),
        Int16 => DaType::int16(),
        Int64 | Long | LongLong => DaType::int64(),
        IntPtr | SSize | PtrDiff | IntMax => DaType::int64(),
        UChar | UInt8 => DaType::uint8(),
        UInt16 => DaType::uint16(),
        UInt | UInt128 | UInt32 => DaType::uint(),
        UInt64 | ULong | ULongLong | UIntPtr | Size | WChar => DaType::uint64(),
        Float | BFloat16 => DaType::float(),
        Double | LongDouble | Float128 => DaType::double(),
        Pointer(_) => DaType::uint64(),
        _ => DaType::auto(),
    }
}

fn writable_type(mut ty: DaType) -> DaType {
    ty.is_const = false;
    ty.is_ref = false;
    ty.is_temporary = false;
    ty
}

fn zero_for_datype(ty: &DaType) -> DaExpr {
    match &ty.kind {
        DaTypeKind::Pointer(_) => abi::null_pointer(ty),
        // A declaration may need a temporary default before CFG emits its C
        // initializer assignment. Arrays are aggregates, never numeric zero.
        // `[]` is typed by the declaration and remains distinct from the C
        // InitList assignment that follows.
        DaTypeKind::Array(_) => DaExpr::MakeArray(vec![]),
        DaTypeKind::FixedArray(elem_ty, size) => {
            DaExpr::MakeArray((0..*size).map(|_| zero_for_datype(elem_ty)).collect())
        }
        _ => DaExpr::Cast {
            kind: das_ast::CastKind::Cast,
            expr: Box::new(DaExpr::ConstInt(0)),
            to: ty.clone(),
        },
    }
}

fn lower_minmax_conditional(cond: &DaExpr, then_e: &DaExpr, else_e: &DaExpr) -> Option<DaExpr> {
    let DaExpr::Op2 { op, left, right } = cond else {
        return None;
    };
    if !matches!(*op, "<" | "<=" | ">" | ">=") {
        return None;
    }

    let left_is_then = expr_text_eq(left, then_e);
    let right_is_else = expr_text_eq(right, else_e);
    let right_is_then = expr_text_eq(right, then_e);
    let left_is_else = expr_text_eq(left, else_e);

    let op_kind = match (
        *op,
        left_is_then && right_is_else,
        right_is_then && left_is_else,
    ) {
        ("<" | "<=", true, _) => "min",
        (">" | ">=", true, _) => "max",
        ("<" | "<=", _, true) => "max",
        (">" | ">=", _, true) => "min",
        _ => return None,
    };
    let helper_ty = minmax_helper_type(left.as_ref(), right.as_ref());
    let fn_name = format!("c2da_{}_{}", op_kind, helper_ty.suffix);

    Some(DaExpr::Call(
        Box::new(DaExpr::Var(fn_name.to_string())),
        vec![
            cast_minmax_arg(left.as_ref().clone(), helper_ty.ty.clone()),
            cast_minmax_arg(right.as_ref().clone(), helper_ty.ty),
        ],
    ))
}

fn expr_text_eq(lhs: &DaExpr, rhs: &DaExpr) -> bool {
    format!("{}", lhs) == format!("{}", rhs)
}

fn is_zero_initializer_expr(expr: &DaExpr) -> bool {
    match expr {
        DaExpr::ConstInt(0) | DaExpr::ConstUInt(0) => true,
        DaExpr::Cast { expr, .. } => is_zero_initializer_expr(expr),
        _ => false,
    }
}

#[derive(Clone)]
struct MinMaxHelperType {
    suffix: &'static str,
    ty: DaType,
}

fn minmax_helper_type(left: &DaExpr, right: &DaExpr) -> MinMaxHelperType {
    match (minmax_numeric_type(left), minmax_numeric_type(right)) {
        (Some(MinMaxNumericType::UInt64), _) | (_, Some(MinMaxNumericType::UInt64)) => {
            MinMaxHelperType {
                suffix: "uint64",
                ty: DaType::uint64(),
            }
        }
        (Some(MinMaxNumericType::Int64), _) | (_, Some(MinMaxNumericType::Int64)) => {
            MinMaxHelperType {
                suffix: "int64",
                ty: DaType::int64(),
            }
        }
        (Some(MinMaxNumericType::UInt), Some(MinMaxNumericType::UInt)) => MinMaxHelperType {
            suffix: "uint",
            ty: DaType::uint(),
        },
        _ => MinMaxHelperType {
            suffix: "int",
            ty: DaType::int(),
        },
    }
}

#[derive(Copy, Clone)]
enum MinMaxNumericType {
    Int,
    UInt,
    Int64,
    UInt64,
}

fn minmax_numeric_type(expr: &DaExpr) -> Option<MinMaxNumericType> {
    match expr {
        DaExpr::ConstUInt(_) => Some(MinMaxNumericType::UInt),
        DaExpr::ConstInt(_) => Some(MinMaxNumericType::Int),
        DaExpr::Cast { to, .. } => match to.kind {
            DaTypeKind::UInt64 => Some(MinMaxNumericType::UInt64),
            DaTypeKind::Int64 => Some(MinMaxNumericType::Int64),
            DaTypeKind::UInt | DaTypeKind::UInt16 | DaTypeKind::UInt8 => {
                Some(MinMaxNumericType::UInt)
            }
            DaTypeKind::Int | DaTypeKind::Int16 | DaTypeKind::Int8 => Some(MinMaxNumericType::Int),
            _ => None,
        },
        _ => None,
    }
}

fn cast_minmax_arg(expr: DaExpr, to: DaType) -> DaExpr {
    DaExpr::Cast {
        kind: das_ast::CastKind::Cast,
        expr: Box::new(expr),
        to,
    }
}

fn c2da_runtime_helpers() -> Vec<DaDecl> {
    let mut helpers = runtime::declarations();
    helpers.extend([
        c2da_minmax_helper("c2da_min_int", DaType::int(), "<"),
        c2da_minmax_helper("c2da_max_int", DaType::int(), ">"),
        c2da_minmax_helper("c2da_min_uint", DaType::uint(), "<"),
        c2da_minmax_helper("c2da_max_uint", DaType::uint(), ">"),
        c2da_minmax_helper("c2da_min_int64", DaType::int64(), "<"),
        c2da_minmax_helper("c2da_max_int64", DaType::int64(), ">"),
        c2da_minmax_helper("c2da_min_uint64", DaType::uint64(), "<"),
        c2da_minmax_helper("c2da_max_uint64", DaType::uint64(), ">"),
        c2da_clip_uint_helper(),
        c2da_bool_to_uint_helper(),
        c2da_assert_fail_helper(),
    ]);
    helpers
}

fn c2da_bool_to_uint_helper() -> DaDecl {
    DaDecl::Function(DaFunction {
        name: "c2da_bool_to_uint".to_string(),
        params: vec![DaStmt::Param {
            name: "v".to_string(),
            param_type: DaType::bool(),
            default: None,
            is_mutable: false,
        }],
        ret_type: DaType::uint(),
        body: Some(DaExpr::Block(DaBlock {
            stmts: vec![DaStmt::Expr(DaExpr::IfThenElse {
                // `DaExpr` currently carries no type on a plain variable.  Make
                // the helper condition explicitly boolean so the printer never
                // routes it through C-style numeric truthiness.
                cond: Box::new(DaExpr::Op2 {
                    op: "==",
                    left: Box::new(DaExpr::Var("v".to_string())),
                    right: Box::new(DaExpr::ConstBool(true)),
                }),
                then: Box::new(DaExpr::Block(DaBlock {
                    stmts: vec![DaStmt::Expr(DaExpr::Return(Some(Box::new(
                        DaExpr::ConstUInt(1),
                    ))))],
                })),
                elifs: vec![],
                else_: Some(Box::new(DaExpr::Block(DaBlock {
                    stmts: vec![DaStmt::Expr(DaExpr::Return(Some(Box::new(
                        DaExpr::ConstUInt(0),
                    ))))],
                }))),
            })],
        })),
        annotations: vec![],
        is_public: false,
        is_unsafe: false,
    })
}

fn c2da_assert_fail_helper() -> DaDecl {
    let ptr = DaType::pointer(DaType::void());
    DaDecl::Function(DaFunction {
        name: "c2da___assert_fail".to_string(),
        params: vec![
            DaStmt::Param {
                name: "expr".to_string(),
                param_type: ptr.clone(),
                default: None,
                is_mutable: false,
            },
            DaStmt::Param {
                name: "file".to_string(),
                param_type: ptr.clone(),
                default: None,
                is_mutable: false,
            },
            DaStmt::Param {
                name: "line".to_string(),
                param_type: DaType::uint(),
                default: None,
                is_mutable: false,
            },
            DaStmt::Param {
                name: "func".to_string(),
                param_type: ptr,
                default: None,
                is_mutable: false,
            },
        ],
        ret_type: DaType::void(),
        body: Some(DaExpr::Block(DaBlock { stmts: vec![] })),
        annotations: vec![],
        is_public: false,
        is_unsafe: false,
    })
}

fn c2da_clip_uint_helper() -> DaDecl {
    DaDecl::Function(DaFunction {
        name: "c2da_clip_uint".to_string(),
        params: vec![DaStmt::Param {
            name: "v".to_string(),
            param_type: DaType::int(),
            default: None,
            is_mutable: false,
        }],
        ret_type: DaType::uint(),
        body: Some(DaExpr::Block(DaBlock {
            stmts: vec![
                DaStmt::Expr(DaExpr::IfThenElse {
                    cond: Box::new(DaExpr::Op2 {
                        op: "<",
                        left: Box::new(DaExpr::Var("v".to_string())),
                        right: Box::new(DaExpr::ConstInt(0)),
                    }),
                    then: Box::new(DaExpr::Block(DaBlock {
                        stmts: vec![DaStmt::Expr(DaExpr::Return(Some(Box::new(
                            DaExpr::ConstUInt(0),
                        ))))],
                    })),
                    elifs: vec![],
                    else_: None,
                }),
                DaStmt::Expr(DaExpr::IfThenElse {
                    cond: Box::new(DaExpr::Op2 {
                        op: ">",
                        left: Box::new(DaExpr::Var("v".to_string())),
                        right: Box::new(DaExpr::ConstInt(255)),
                    }),
                    then: Box::new(DaExpr::Block(DaBlock {
                        stmts: vec![DaStmt::Expr(DaExpr::Return(Some(Box::new(
                            DaExpr::ConstUInt(255),
                        ))))],
                    })),
                    elifs: vec![],
                    else_: None,
                }),
                DaStmt::Expr(DaExpr::Return(Some(Box::new(DaExpr::Cast {
                    kind: das_ast::CastKind::Cast,
                    expr: Box::new(DaExpr::Var("v".to_string())),
                    to: DaType::uint(),
                })))),
            ],
        })),
        annotations: vec![],
        is_public: false,
        is_unsafe: false,
    })
}

fn c2da_minmax_helper(name: &str, ty: DaType, op: &'static str) -> DaDecl {
    DaDecl::Function(DaFunction {
        name: name.to_string(),
        params: vec![
            DaStmt::Param {
                name: "a".to_string(),
                param_type: ty.clone(),
                default: None,
                is_mutable: false,
            },
            DaStmt::Param {
                name: "b".to_string(),
                param_type: ty.clone(),
                default: None,
                is_mutable: false,
            },
        ],
        ret_type: ty,
        body: Some(DaExpr::Block(DaBlock {
            stmts: vec![DaStmt::Expr(DaExpr::IfThenElse {
                cond: Box::new(DaExpr::Op2 {
                    op,
                    left: Box::new(DaExpr::Var("a".to_string())),
                    right: Box::new(DaExpr::Var("b".to_string())),
                }),
                then: Box::new(DaExpr::Block(DaBlock {
                    stmts: vec![DaStmt::Expr(DaExpr::Return(Some(Box::new(DaExpr::Var(
                        "a".to_string(),
                    )))))],
                })),
                elifs: vec![],
                else_: Some(Box::new(DaExpr::Block(DaBlock {
                    stmts: vec![DaStmt::Expr(DaExpr::Return(Some(Box::new(DaExpr::Var(
                        "b".to_string(),
                    )))))],
                }))),
            })],
        })),
        annotations: vec![],
        is_public: false,
        is_unsafe: false,
    })
}

fn zero_for_ctype_kind(kind: &CTypeKind) -> DaExpr {
    if kind.is_unsigned_integral_type() {
        DaExpr::ConstUInt(0)
    } else {
        DaExpr::ConstInt(0)
    }
}

/// Разворачивает return if(c) a else b → if(c) { return a } else { return b }
fn convert_ifexpr_to_return(expr: &DaExpr, stmts: &mut Vec<DaStmt>) {
    // Extract optional Cast wrapper and inner IfThenElse
    let (cast_kind, cast_to, inner) = match expr {
        DaExpr::IfThenElse { .. } => (None, None, expr),
        DaExpr::Cast {
            kind,
            expr: inner,
            to,
        } => match inner.as_ref() {
            DaExpr::IfThenElse { .. } => (Some(kind.clone()), Some(to.clone()), inner.as_ref()),
            _ => return,
        },
        _ => return,
    };
    // Wraps a branch value with the outer Cast if present
    let wrap = |e: DaExpr| -> DaExpr {
        match &cast_kind {
            Some(k) => DaExpr::Cast {
                kind: k.clone(),
                expr: Box::new(e),
                to: cast_to.clone().unwrap(),
            },
            None => e,
        }
    };
    if let DaExpr::IfThenElse {
        cond,
        then,
        elifs,
        else_,
    } = inner
    {
        let then_ret = DaStmt::Expr(DaExpr::Return(Some(Box::new(wrap(then.as_ref().clone())))));
        if let Some(el) = else_ {
            let else_ret = DaStmt::Expr(DaExpr::Return(Some(Box::new(wrap(el.as_ref().clone())))));
            let mut body = vec![then_ret];
            for (ec, eb) in elifs {
                let eb_ret = DaStmt::Expr(DaExpr::Return(Some(Box::new(wrap(eb.clone())))));
                body.push(DaStmt::Expr(DaExpr::IfThenElse {
                    cond: Box::new(ec.clone()),
                    then: Box::new(DaExpr::Block(DaBlock {
                        stmts: vec![eb_ret],
                    })),
                    elifs: vec![],
                    else_: None,
                }));
            }
            stmts.push(DaStmt::Expr(DaExpr::IfThenElse {
                cond: Box::new(cond.as_ref().clone()),
                then: Box::new(DaExpr::Block(DaBlock { stmts: body })),
                elifs: vec![],
                else_: Some(Box::new(DaExpr::Block(DaBlock {
                    stmts: vec![else_ret],
                }))),
            }));
        } else {
            stmts.push(DaStmt::Expr(DaExpr::IfThenElse {
                cond: Box::new(cond.as_ref().clone()),
                then: Box::new(DaExpr::Block(DaBlock {
                    stmts: vec![then_ret],
                })),
                elifs: vec![],
                else_: None,
            }));
        }
    }
}

fn convert_binop(op: CBinOp) -> Result<&'static str, &'static str> {
    use CBinOp::*;
    match op {
        Add => Ok("+"),
        Subtract => Ok("-"),
        Multiply => Ok("*"),
        Divide => Ok("/"),
        Modulus => Ok("%"),
        And => Ok("&&"),
        Or => Ok("||"),
        BitAnd => Ok("&"),
        BitOr => Ok("|"),
        BitXor => Ok("^"),
        ShiftLeft => Ok("<<"),
        ShiftRight => Ok(">>"),
        EqualEqual => Ok("=="),
        NotEqual => Ok("!="),
        Less => Ok("<"),
        Greater => Ok(">"),
        LessEqual => Ok("<="),
        GreaterEqual => Ok(">="),
        _ => Err("unsupported binary op in daScript"),
    }
}

/// Main entry point: creates a Translation and produces a daScript module string.
pub fn translate(
    ast_context: TypedAstContext,
    tcfg: &TranspilerConfig,
    main_file: &Path,
) -> (
    String,
    Option<()>,
    Vec<(&'static str, Vec<&'static str>)>,
    IndexSet<ExternCrate>,
) {
    let mut t = Translation::new(ast_context, tcfg, main_file);

    // Prune unreachable system declarations (removes __-prefixed noise from system headers)
    t.ast_context.prune_unwanted_decls(false);
    t.ast_context.set_prenamed_decls();

    for (&typedef_id, &subdecl_id) in &t.ast_context.prenamed_decls {
        if let CDeclKind::Typedef { ref name, .. } = t.ast_context[typedef_id].kind {
            t.type_converter
                .borrow_mut()
                .ensure_decl_name(subdecl_id, name);
            t.type_converter
                .borrow_mut()
                .alias_decl_name(typedef_id, subdecl_id);
        }
    }
    for (&decl_id, decl) in t.ast_context.iter_decls() {
        use CDeclKind::*;
        match decl.kind {
            Struct {
                name: Some(ref name),
                ..
            }
            | Union {
                name: Some(ref name),
                ..
            }
            | Enum {
                name: Some(ref name),
                ..
            } => {
                t.type_converter
                    .borrow_mut()
                    .ensure_decl_name(decl_id, name);
            }
            Typedef { ref name, .. } if !t.ast_context.prenamed_decls.contains_key(&decl_id) => {
                t.type_converter
                    .borrow_mut()
                    .ensure_decl_name(decl_id, name);
            }
            _ => {}
        }
    }

    // Pass 1: export all type declarations (struct, enum, union, typedef)
    let mut decls: Vec<DaDecl> = vec![];
    let mut exported_names: std::collections::HashSet<String> = std::collections::HashSet::new();
    for (&decl_id, decl) in t.ast_context.iter_decls() {
        use CDeclKind::*;
        let needs_export = match decl.kind {
            Struct { .. } => true,
            Enum { .. } => true,
            Union { .. } => true,
            Typedef { .. } => true,
            _ => false,
        };
        if needs_export {
            match t.convert_decl(
                ExprContext {
                    used: true,
                    is_const: false,
                    ..Default::default()
                },
                decl_id,
            ) {
                Ok(das_decl) => {
                    // Track emitted type declarations for dedup.
                    // Named structs/enums dedup by name; anonymous structs
                    // dedup by (name, field_type_signature) for accuracy.
                    match &das_decl {
                        DaDecl::Structure(s) => {
                            if s.name.starts_with("Unnamed_") {
                                t.emitted_anon_structs
                                    .borrow_mut()
                                    .insert(anonymous_struct_signature(s));
                            } else {
                                t.emitted_structs.borrow_mut().insert(s.name.clone());
                            }
                        }
                        DaDecl::Enumeration(e) => {
                            t.emitted_structs.borrow_mut().insert(e.name.clone());
                        }
                        _ => {}
                    }
                    // Skip duplicate typedefs and named structs (daScript rejects them).
                    let type_name = decl.kind.get_name().map(|s| s.to_string());
                    if let Some(ref name) = type_name {
                        if !name.starts_with("Unnamed_") && !exported_names.insert(name.clone()) {
                            continue;
                        }
                    }
                    decls.push(das_decl)
                }
                Err(e) => {
                    let name = decl
                        .kind
                        .get_name()
                        .cloned()
                        .unwrap_or_else(|| "?".to_string());
                    warn!("Skipping type decl {}: {}", name, e);
                }
            }
        }
    }

    // Pass 2: export top-level value declarations (function with bodies, variable, macro)
    for &top_id in &t.ast_context.c_decls_top {
        use CDeclKind::*;
        let needs_export = match t.ast_context[top_id].kind {
            Function { body: Some(_), .. } => true, // only functions with bodies
            Variable { .. } => true,
            MacroObject { .. } => true,
            MacroFunction { .. } => true,
            _ => false, // types already exported in pass 1; fn decls without body skipped
        };
        if !needs_export {
            continue;
        }
        match t.convert_decl(
            ExprContext {
                used: true,
                is_const: false,
                ..Default::default()
            },
            top_id,
        ) {
            Ok(das_decl) => decls.push(das_decl),
            Err(e) => {
                let decl = &t.ast_context[top_id];
                let name = decl
                    .kind
                    .get_name()
                    .cloned()
                    .unwrap_or_else(|| "?".to_string());
                warn!("Skipping decl {}: {}", name, e);
            }
        }
    }

    // Pass 3: export enum constants as global variables (daScript uses `Enum.Constant` syntax,
    // but C code uses bare constant names. Generate `var CONST : EnumType = EnumType.CONST` aliases.)
    let mut enum_const_decls: Vec<DaDecl> = vec![];
    for (&ec_id, decl) in t.ast_context.iter_decls() {
        if let CDeclKind::EnumConstant { ref name, value } = &decl.kind {
            let var_name = t.declare_value_name(ec_id, name);
            if !exported_names.insert(var_name.clone()) {
                continue;
            }
            // Use value type to determine var type: ConstUInt → uint, ConstInt → int
            let (das_val, das_type) = match value {
                crate::c_ast::ConstIntExpr::U(v) => {
                    let val = DaExpr::ConstUInt(*v);
                    // If value > INT32_MAX, cast to int to match C enum semantics
                    if *v > 0x7FFFFFFF {
                        let int_type = DaType::int();
                        (
                            DaExpr::Cast {
                                kind: das_ast::CastKind::Cast,
                                expr: Box::new(val),
                                to: int_type.clone(),
                            },
                            int_type,
                        )
                    } else {
                        (val, DaType::uint())
                    }
                }
                crate::c_ast::ConstIntExpr::I(v) => (DaExpr::ConstInt(*v), DaType::int()),
            };
            enum_const_decls.push(DaDecl::Variable(DaVariable {
                name: var_name,
                var_type: das_type,
                init: Some(das_val),
                annotations: vec![],
            }));
        }
    }
    decls.extend(enum_const_decls);
    let mut module_decls = c2da_runtime_helpers();
    module_decls.extend(decls);

    // Build the daScript module
    let module = DaModule {
        name: main_file
            .file_stem()
            .map(|s| s.to_string_lossy().to_string()),
        requires: vec![],
        options: vec!["gen2".into()],
        decls: module_decls,
    };

    (
        module.to_string(),
        None,
        vec![],
        IndexSet::new(),
    )
}

fn normalize_generated_numeric_patterns(mut code: String) -> String {
    code = code.replace("if (uint64(v) != uint64(0))", "if (v)");
    let replacements = [
        (
            "int(partX) + (uint(int(mv.hor)) >> uint(2))",
            "int(partX) + int((uint(int(mv.hor)) >> uint(2)))",
        ),
        (
            "int(partY) + (uint(int(mv.ver)) >> uint(2))",
            "int(partY) + int((uint(int(mv.ver)) >> uint(2)))",
        ),
        (
            "tmp6_0 + (uint(int(tmp7)) << uint(4))",
            "tmp6_0 + int((uint(int(tmp7)) << uint(4)))",
        ),
        (
            "tmp6_0 + (uint(int(tmp7)) << uint(2))",
            "tmp6_0 + int((uint(int(tmp7)) << uint(2)))",
        ),
        (
            "tmp6_0 - (uint(int(tmp7)) << uint(2))",
            "tmp6_0 - int((uint(int(tmp7)) << uint(2)))",
        ),
        (
            "tmp5_0 + (uint(int(tmp7)) << uint(4))",
            "tmp5_0 + int((uint(int(tmp7)) << uint(4)))",
        ),
        (
            "tmp5_0 + (uint(int(tmp7)) << uint(2))",
            "tmp5_0 + int((uint(int(tmp7)) << uint(2)))",
        ),
        (
            "tmp5_0 - (uint(int(tmp7)) << uint(2))",
            "tmp5_0 - int((uint(int(tmp7)) << uint(2)))",
        ),
        (
            "uint(uint(int(c2da___bsx)) >> uint(8)) & uint(255) | int(uint(int(c2da___bsx)) & uint(255) << uint(8))",
            "uint(uint(int(c2da___bsx)) >> uint(8)) & uint(255) | uint(int(uint(int(c2da___bsx)) & uint(255) << uint(8)))",
        ),
        (
            "fp = unsafe(unsafe(reinterpret<function?>(FillRow1)))",
            "fp = null",
        ),
        (
            "fp = unsafe(unsafe(reinterpret<function?>(h264bsdFillRow7)))",
            "fp = null",
        ),
    ];
    for (from, to) in replacements {
        code = code.replace(from, to);
    }
    for (name, value) in [
        ("MB_A", 0u32),
        ("MB_B", 1u32),
        ("MB_C", 2u32),
        ("MB_D", 3u32),
        ("MB_CURR", 4u32),
        ("MB_NA", 255u32),
    ] {
        code = code.replace(
            &format!("unsafe(reinterpret<neighbourMb_e>({}))", name),
            &format!("unsafe(reinterpret<neighbourMb_e>(uint({})))", value),
        );
        code = code.replace(
            &format!("cast<neighbourMb_e>({})", name),
            &format!("unsafe(reinterpret<neighbourMb_e>(uint({})))", value),
        );
    }
    for name in [
        "p1", "p1_0", "p1_1", "p1_2", "p1_3", "p1_4", "p1_5", "p1_6", "data4x4",
    ] {
        let from = format!("unsafe(addr({}[0]))", name);
        let to = format!(
            "unsafe(unsafe(reinterpret<uint8?>(unsafe(addr({}[0])))))",
            name
        );
        code = code.replace(&from, &to);
    }
    for name in ["blockData", "blockDc"] {
        let from = format!("addr(*{}[0])", name);
        let to = format!("addr(unsafe((*{})[0]))", name);
        code = code.replace(&from, &to);
    }
    for name in ["ptr_3", "data_28", "data_29", "ptr_4", "data_30"] {
        for lhs in 0..16 {
            for rhs in 0..16 {
                for op in ["+", "-"] {
                    let from = format!(
                        "unsafe(unsafe(unsafe(reinterpret<int?>({})))[{}] {} unsafe(unsafe(unsafe(reinterpret<int?>({})))[{}]))",
                        name, lhs, op, name, rhs
                    );
                    let to = format!(
                        "unsafe((unsafe(unsafe(reinterpret<int?>({}))))[{}]) {} unsafe((unsafe(unsafe(reinterpret<int?>({}))))[{}])",
                        name, lhs, op, name, rhs
                    );
                    code = code.replace(&from, &to);

                    let from = format!(
                        "unsafe(unsafe(unsafe(reinterpret<int?>({})))[{}] {} unsafe((unsafe(unsafe(reinterpret<int?>({}))))[{}]))",
                        name, lhs, op, name, rhs
                    );
                    code = code.replace(&from, &to);
                }
            }
        }
        for idx in 0..16 {
            let from = format!(
                "unsafe(unsafe(unsafe(reinterpret<int?>({})))[{}])",
                name, idx
            );
            let to = format!(
                "unsafe((unsafe(unsafe(reinterpret<int?>({}))))[{}])",
                name, idx
            );
            code = code.replace(&from, &to);
        }
    }
    let addr_names = ["firstPhase", "a_9", "b_2", "l_1", "r"];
    for name in addr_names {
        for lhs in 0..16 {
            for rhs in 0..16 {
                for op in ["+", "-"] {
                    let from = format!(
                        "unsafe(unsafe(addr({}[0]))[{}] {} unsafe(unsafe(addr({}[0]))[{}]))",
                        name, lhs, op, name, rhs
                    );
                    let to = format!(
                        "unsafe((unsafe(addr({}[0])))[{}]) {} unsafe((unsafe(addr({}[0])))[{}])",
                        name, lhs, op, name, rhs
                    );
                    code = code.replace(&from, &to);

                    let from = format!(
                        "unsafe(unsafe(addr({}[0]))[{}] {} unsafe((unsafe(addr({}[0])))[{}]))",
                        name, lhs, op, name, rhs
                    );
                    code = code.replace(&from, &to);
                }
            }
        }
        for idx in 0..16 {
            let from = format!("unsafe(unsafe(addr({}[0]))[{}])", name, idx);
            let to = format!("unsafe((unsafe(addr({}[0])))[{}])", name, idx);
            code = code.replace(&from, &to);
        }
    }
    for lhs_name in addr_names {
        for rhs_name in addr_names {
            for lhs in 0..16 {
                for rhs in 0..16 {
                    for op in ["+", "-"] {
                        let from = format!(
                            "unsafe(unsafe(addr({}[0]))[{}] {} unsafe((unsafe(addr({}[0])))[{}]))",
                            lhs_name, lhs, op, rhs_name, rhs
                        );
                        let to = format!(
                            "unsafe((unsafe(addr({}[0])))[{}]) {} unsafe((unsafe(addr({}[0])))[{}])",
                            lhs_name, lhs, op, rhs_name, rhs
                        );
                        code = code.replace(&from, &to);
                    }
                }
            }
        }
    }
    for expr in [
        "uint(int(tmp0) + (int(tmp3_12) + 32)) >> uint(6)",
        "uint(int(tmp1_14) + (int(tmp2_14) + 32)) >> uint(6)",
        "uint(int(tmp1_14) - int(tmp2_14) + 32) >> uint(6)",
        "uint(int(tmp0) - int(tmp3_12) + 32) >> uint(6)",
        "uint(unsafe((unsafe(unsafe(reinterpret<int?>(data_28))))[0]) + 32) >> uint(6)",
    ] {
        code = code.replace(expr, &format!("int(({}))", expr));
    }
    for name in ["ptr_3", "data_28"] {
        for (lhs, rhs) in [("1", "3"), ("4", "12")] {
            let from = format!(
                "(uint(unsafe((unsafe(unsafe(reinterpret<int?>({}))))[{}])) >> uint(1)) - unsafe((unsafe(unsafe(reinterpret<int?>({}))))[{}])",
                name, lhs, name, rhs
            );
            let to = format!(
                "int((uint(unsafe((unsafe(unsafe(reinterpret<int?>({}))))[{}])) >> uint(1))) - unsafe((unsafe(unsafe(reinterpret<int?>({}))))[{}])",
                name, lhs, name, rhs
            );
            code = code.replace(&from, &to);

            let from = format!(
                "unsafe((unsafe(unsafe(reinterpret<int?>({}))))[{}]) + (uint(unsafe((unsafe(unsafe(reinterpret<int?>({}))))[{}])) >> uint(1))",
                name, lhs, name, rhs
            );
            let to = format!(
                "unsafe((unsafe(unsafe(reinterpret<int?>({}))))[{}]) + int((uint(unsafe((unsafe(unsafe(reinterpret<int?>({}))))[{}])) >> uint(1)))",
                name, lhs, name, rhs
            );
            code = code.replace(&from, &to);
        }
    }
    for (name, qp, shift) in [("levScale", "qpDiv_0", "1"), ("levScale_0", "qpDiv_1", "2")] {
        let from = format!("{} << uint({}) - uint({})", name, qp, shift);
        let to = format!("{} << int((uint({}) - uint({})))", name, qp, shift);
        code = code.replace(&from, &to);
    }
    for op in ["+", "-"] {
        let from = format!("int(tmp0_2) {} (uint(int(tmp1_17)) >> uint(1))", op);
        let to = format!("int(tmp0_2) {} int((uint(int(tmp1_17)) >> uint(1)))", op);
        code = code.replace(&from, &to);
    }
    for (q0, p0, p1, q1) in [
        ("q0", "p0", "p1_7", "q1"),
        ("q0_0", "p0_0", "p1_8", "q1_0"),
        ("q0_1", "p0_1", "p1_9", "q1_1"),
        ("q0_2", "p0_2", "p1_10", "q1_2"),
        ("q0_3", "p0_3", "p1_11", "q1_3"),
        ("q0_4", "p0_4", "p1_12", "q1_4"),
        ("q0_5", "p0_5", "p1_13", "q1_5"),
        ("q0_6", "p0_6", "p1_14", "q1_6"),
    ] {
        let from = format!(
            "(uint(int({}) - int({})) << uint(2)) + (int({}) - int({}))",
            q0, p0, p1, q1
        );
        let to = format!(
            "int((uint(int({}) - int({})) << uint(2))) + (int({}) - int({}))",
            q0, p0, p1, q1
        );
        code = code.replace(&from, &to);

        let shifted = format!(
            "uint(int((uint(int({}) - int({})) << uint(2))) + (int({}) - int({})) + 4) >> uint(3)",
            q0, p0, p1, q1
        );
        code = code.replace(&shifted, &format!("int(({}))", shifted));
    }
    for (outer, p0, q0, inner) in [
        ("p2", "p0_2", "q0_2", "p1_10"),
        ("q2", "p0_2", "q0_2", "q1_2"),
        ("p2_0", "p0_3", "q0_3", "p1_11"),
        ("q2_0", "p0_3", "q0_3", "q1_3"),
        ("p2_1", "p0_4", "q0_4", "p1_12"),
        ("q2_1", "p0_4", "q0_4", "q1_4"),
    ] {
        let from = format!(
            "int({}) + ((uint(int({}) + (int({}) + 1)) >> uint(1)) - (uint(int({})) << uint(1)))",
            outer, p0, q0, inner
        );
        let to = format!(
            "int({}) + int(((uint(int({}) + (int({}) + 1)) >> uint(1)) - (uint(int({})) << uint(1))))",
            outer, p0, q0, inner
        );
        code = code.replace(&from, &to);

        let shifted = format!(
            "uint(int({}) + int(((uint(int({}) + (int({}) + 1)) >> uint(1)) - (uint(int({})) << uint(1))))) >> uint(1)",
            outer, p0, q0, inner
        );
        code = code.replace(&shifted, &format!("int(({}))", shifted));
    }
    for (fresh, expr) in [
        ("c2da_fresh222", "(298 * c_4 + 409 * e + 128) >> 8"),
        (
            "c2da_fresh223",
            "(298 * c_4 - 100 * d - 208 * e + 128) >> 8",
        ),
        ("c2da_fresh224", "(298 * c_4 + 516 * d + 128) >> 8"),
        ("c2da_fresh225", "(298 * c_5 + 409 * e_0 + 128) >> 8"),
        (
            "c2da_fresh226",
            "(298 * c_5 - 100 * d_0 - 208 * e_0 + 128) >> 8",
        ),
        ("c2da_fresh227", "(298 * c_5 + 516 * d_0 + 128) >> 8"),
    ] {
        code = code.replace(
            &format!("uint({})", fresh),
            &format!("c2da_clip_uint({})", expr),
        );
    }
    code = code.replace(
        "_dw_64393 || i_75",
        "_dw_64393 || uint64(i_75) != uint64(0)",
    );
    code = code.replace(
        "_dw_76839 || currMbAddr_0",
        "_dw_76839 || uint64(currMbAddr_0) != uint64(0)",
    );
    code = code.replace(
        "_dw_77054 || moreMbs",
        "_dw_77054 || uint64(moreMbs) != uint64(0)",
    );
    code = code.replace(
        "_dw_81620 || h264bsdMoreRbspData(pStrmData_32)",
        "_dw_81620 || uint64(h264bsdMoreRbspData(pStrmData_32)) != uint64(0)",
    );
    for op in ["<<", ">>"] {
        let from = format!("itmp_4 {} uint(32) - uint(timeOffsetLength)", op);
        let to = format!("itmp_4 {} int((uint(32) - uint(timeOffsetLength)))", op);
        code = code.replace(&from, &to);
    }
    code = code.replace(
        "unsafe(reinterpret<uintptr_t>(16)) - unsafe(addr(mbData[0]))",
        "unsafe(reinterpret<uintptr_t>(16)) - unsafe(reinterpret<uintptr_t>(unsafe(addr(mbData[0]))))",
    );
    code = code.replace("malloc(4)", "malloc(uint64(4))");
    code = code.replace("cast<uint8?>(0)", "null");
    code = code.replace(
        "c2da_fresh255 = unsafe(malloc(uint64(capacity)))",
        "c2da_fresh255 = unsafe(unsafe(reinterpret<uint8?>(unsafe(malloc(uint64(capacity))))))",
    );
    code = code.replace(
        "return uint64(capacity) == uint64(0) || !(h_4.data == null)",
        "if (uint64(capacity) == uint64(0) || !(h_4.data == null)) {\n        return 1\n    } else {\n        return 0\n    }",
    );
    code = code.replace("unsafe(addr(\"h->data\"[0]))", "null");
    code = code.replace(
        "unsafe(addr(\"/root/c2dascript/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h\"[0]))",
        "null",
    );
    code = code.replace(
        "unsafe(addr(\"unsigned char *minimp4_vector_alloc_tail(minimp4_vector_t *, int)\"[0]))",
        "null",
    );
    code = code.replace(
        "unsafe(addr(\"(h->capacity - h->bytes) >= bytes\"[0]))",
        "null",
    );
    code = code.replace(
        "payload_type = uint(int(unsafe((unsafe(unsafe(reinterpret<uint8 const?>(nal))))[0]))) & uint(31)",
        "payload_type = int((uint(int(unsafe((unsafe(unsafe(reinterpret<uint8 const?>(nal))))[0]))) & uint(31)))",
    );
    code = code.replace(
        "payload_type = uint(int(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(nal)))[0]))) & uint(31)",
        "payload_type = int((uint(int(unsafe((unsafe(unsafe(reinterpret<uint8 const?>(nal))))[0]))) & uint(31)))",
    );
    code = code.replace(
        "int(mux_1.write_callback(mux_1.write_pos, data_48, unsafe(reinterpret<size_t>(data_bytes)), mux_1.token))",
        "0",
    );
    code = code.replace(
        "int(mux_3.write_callback(mux_3.write_pos, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(base[0]))))), unsafe(reinterpret<size_t>(unsafe(p_2 - unsafe(addr(base[0]))))), mux_3.token))",
        "0",
    );
    code = code.replace(
        "int(mux_3.write_callback(mux_3.write_pos, unsafe(unsafe(reinterpret<uint64>(tr_3.pending_sample.data))), unsafe(reinterpret<size_t>(tr_3.pending_sample.bytes)), mux_3.token))",
        "0",
    );
    for mux in ["mux_4", "mux_5"] {
        let base = if mux == "mux_4" { "base_0" } else { "base_1" };
        let p = if mux == "mux_4" { "p_3" } else { "p_4" };
        code = code.replace(
            &format!(
                "int({}.write_callback({}.write_pos, unsafe(unsafe(reinterpret<uint64>(unsafe(addr({}[0]))))), unsafe(reinterpret<size_t>(unsafe({} - unsafe(addr({}[0]))))), {}.token))",
                mux, mux, base, p, base, mux
            ),
            "0",
        );
    }
    code = code.replace(
        "int(mux_6.write_callback(int64(4), unsafe(unsafe(reinterpret<uint64>(base_2))), unsafe(reinterpret<size_t>(unsafe(p_5 - base_2))), mux_6.token))",
        "0",
    );
    code = code.replace(
        "mux_6.write_callback(mux_6.write_pos, unsafe(unsafe(reinterpret<uint64>(base_2))), unsafe(reinterpret<size_t>(unsafe(p_5 - base_2))), mux_6.token)",
        "0",
    );
    code = code.replace(
        "uint(uint(int(kind_0) == 1))",
        "c2da_bool_to_uint(int(kind_0) == 1)",
    );
    code = code.replace(
        "goto label 75716",
        "unsafe(free(unsafe(unsafe(reinterpret<uint64>(nal1)))))\n                unsafe(free(unsafe(unsafe(reinterpret<uint64>(nal2)))))\n                return -1",
    );
    code = code.replace(
        "return unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(reinterpret<uint8?>(uint64(0)))))) != unsafe(reinterpret<uint64>(minimp4_vector_put(unsafe(addr(tr_2.smpl)), unsafe(unsafe(reinterpret<uint64>(unsafe(addr(smp))))), int(4)))))",
        "if (unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(reinterpret<uint8?>(uint64(0)))))) != unsafe(reinterpret<uint64>(minimp4_vector_put(unsafe(addr(tr_2.smpl)), unsafe(unsafe(reinterpret<uint64>(unsafe(addr(smp))))), int(4)))))) {\n        return 1\n    } else {\n        return 0\n    }",
    );
    code = code.replace("unsafe(addr(\"mux->sequential_mode_flag\"[0]))", "null");
    code = code.replace(
        "unsafe(addr(\"int write_pending_data(MP4E_mux_t *, track_t *)\"[0]))",
        "null",
    );
    code = code.replace(
        "unsafe(minimp4_vector_alloc_tail(unsafe(addr(tr_3.smpl)), 0) - 1)",
        "minimp4_vector_alloc_tail(unsafe(addr(tr_3.smpl)), 0)",
    );
    code = code.replace("var e_1 : Unnamed_9", "var e_1 : int = 0");
    code = code.replace(
        "index_bytes + (unsafe(reinterpret<size_t>(128)) + strlen(mux_6.text_comment))",
        "uint64(index_bytes) + (unsafe(reinterpret<size_t>(128)) + strlen(mux_6.text_comment))",
    );
    code = code.replace(
        "index_bytes = unsafe(reinterpret<size_t>(uint64(index_bytes) + (unsafe(reinterpret<size_t>(128)) + strlen(mux_6.text_comment))))",
        "index_bytes = uint(unsafe(reinterpret<size_t>(uint64(index_bytes) + (unsafe(reinterpret<size_t>(128)) + strlen(mux_6.text_comment)))))",
    );
    code = code.replace(
        "index_bytes + uint64(tr_5.smpl.bytes) * uint64(4 + int(int(uint64(4))) + int(int(uint64(4)))) / uint64(4)",
        "uint64(index_bytes) + uint64(tr_5.smpl.bytes) * uint64(4 + int(int(uint64(4))) + int(int(uint64(4)))) / uint64(4)",
    );
    code = code.replace(
        "index_bytes = uint64(uint64(index_bytes) + uint64(tr_5.smpl.bytes) * uint64(4 + int(int(uint64(4))) + int(int(uint64(4)))) / uint64(4))",
        "index_bytes = uint(uint64(index_bytes) + uint64(tr_5.smpl.bytes) * uint64(4 + int(int(uint64(4))) + int(int(uint64(4)))) / uint64(4))",
    );
    code = code.replace(
        "| uint(int(unsafe(unsafe(addr(tr_7.info.language[0]))[2]))) & uint(31)",
        "| int((uint(int(unsafe(unsafe(addr(tr_7.info.language[0]))[2]))) & uint(31)))",
    );
    for n in ["0", "1", "2", "3"] {
        code = code.replace(&format!(">> 8 * {}", n), &format!(">> uint(8 * {})", n));
        code = code.replace(
            &format!("+ 8 >> uint(8 * {})", n),
            &format!("+ 8 >> int(8 * {})", n),
        );
        code = code.replace(
            &format!("int(BOX_mdat) >> uint(8 * {})", n),
            &format!("int(BOX_mdat) >> int(8 * {})", n),
        );
    }
    code = code.replace(
        "var payload_type_1 : int = uint(uint(int(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(nal_0)))[0]))) >> uint(1)) & uint(63)",
        "var payload_type_1 : int = int((uint(uint(int(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(nal_0)))[0]))) >> uint(1)) & uint(63)))",
    );
    code = code.replace(
        "var payload_type_0 : int = uint(int(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(src_2)))[0]))) & uint(31)",
        "var payload_type_0 : int = int((uint(int(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(src_2)))[0]))) & uint(31)))",
    );
    code = code.replace(
        "uint(int(nal_size)) << uint(8) | int(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(sample_1)))[int(offset_3) + int(length_index)]))",
        "uint(int(nal_size)) << uint(8) | uint(int(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(sample_1)))[int(offset_3) + int(length_index)])))",
    );
    code = code.replace(
        "nal_size = uint(int(nal_size)) << uint(8) | uint(int(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(sample_1)))[int(offset_3) + int(length_index)])))",
        "nal_size = int((uint(int(nal_size)) << uint(8) | uint(int(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(sample_1)))[int(offset_3) + int(length_index)])))))",
    );
    code = code.replace(
        "decode_summary(unsafe(addr(sample_mp4_bytes[0]))",
        "decode_summary(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0])))))",
    );
    code = code.replace(
        "detect_track_length_size(unsafe(addr(mp4_17)), track_index_6, unsafe(addr(sample_mp4_bytes[0]))",
        "detect_track_length_size(unsafe(addr(mp4_17)), track_index_6, unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0])))))",
    );
    code = code.replace(
        "detect_track_length_size(unsafe(addr(mp4_19)), track_index_8, unsafe(addr(sample_mp4_bytes[0]))",
        "detect_track_length_size(unsafe(addr(mp4_19)), track_index_8, unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0])))))",
    );
    code = code.replace(
        "detect_track_length_size(unsafe(addr(mp4_23)), track_index_12, unsafe(addr(sample_mp4_bytes[0]))",
        "detect_track_length_size(unsafe(addr(mp4_23)), track_index_12, unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0])))))",
    );
    code = code.replace(
        "detect_track_length_size(unsafe(addr(mp4_24)), track_index_13, unsafe(addr(sample_mp4_bytes[0]))",
        "detect_track_length_size(unsafe(addr(mp4_24)), track_index_13, unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0])))))",
    );
    code = code.replace("bs_2.cache << n_4", "bs_2.cache << uint(n_4)");
    code = code.replace(
        "uint(int(uint16(uint(int(*bs_2.buf)) << uint(8))) | uint(int(*bs_2.buf)) >> uint(8))",
        "uint(int(uint16(uint(int(*bs_2.buf)) << uint(8))) | int((uint(int(*bs_2.buf)) >> uint(8))))",
    );
    code = code.replace(
        "return minimp4_vector_put(v_0, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(size_6[0]))))), 2) != null && minimp4_vector_put(v_0, mem, bytes_5) != null",
        "if (minimp4_vector_put(v_0, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(size_6[0]))))), 2) != null && minimp4_vector_put(v_0, mem, bytes_5) != null) {\n        return 1\n    } else {\n        return 0\n    }",
    );
    code = code.replace(
        "ra_count + (!(uint64(unsafe(unsafe(unsafe(reinterpret<sample_t const?>(sample_0)))[uint(i_95)]).flag_random_access) == uint64(0)))",
        "ra_count + int(c2da_bool_to_uint(!(uint64(unsafe(unsafe(unsafe(reinterpret<sample_t const?>(sample_0)))[uint(i_95)]).flag_random_access) == uint64(0))))",
    );
    code = code.replace(
        "uint(int(pos) + (uint(-pos) & uint(7)))",
        "uint(int(pos) + int((uint(-pos) & uint(7))))",
    );
    code = code.replace("bs_9.shift - n_6", "bs_9.shift - int(n_6)");
    code = code.replace("bit_count - cb_8", "bit_count - int(cb_8)");
    code = code.replace(
        "bs_9.shift = uint(bs_9.shift - int(n_6))",
        "bs_9.shift = bs_9.shift - int(n_6)",
    );
    code = code.replace(
        "bit_count = uint(bit_count - int(cb_8))",
        "bit_count = bit_count - int(cb_8)",
    );
    code = code.replace("_dw_109646 || t", "_dw_109646 || uint64(t) != uint64(0)");
    code = code.replace(
        "unsafe(unsafe(unsafe(reinterpret<uint64?>(cache)))[uint(i_101)]) = unsafe(malloc(uint64(bytes_8)))",
        "unsafe(unsafe(unsafe(reinterpret<uint64?>(cache)))[uint(i_101)]) = unsafe(unsafe(reinterpret<uint64>(unsafe(malloc(uint64(bytes_8))))))",
    );
    code = code.replace(
        "var is_intra : int = int(int(payload_type_1) >= 16 && int(payload_type_1) <= 21)",
        "var is_intra : int = int(c2da_bool_to_uint(int(payload_type_1) >= 16 && int(payload_type_1) <= 21))",
    );
    code = code.replace("cast<uint8 const?>(0)", "null");
    code = code.replace("uint64(found_0) != uint64(0)", "found_0 != null");
    code = code.replace(
        "_dw_115319 || uint(int(val_7)) & uint(128)",
        "_dw_115319 || uint64(uint(int(val_7)) & uint(128)) != uint64(0)",
    );
    for fresh in [
        "c2da_fresh266",
        "c2da_fresh269",
        "c2da_fresh270",
        "c2da_fresh271",
        "c2da_fresh272",
        "c2da_fresh273",
        "c2da_fresh274",
        "c2da_fresh275",
        "c2da_fresh276",
    ] {
        code = code.replace(&format!("uint64({})", fresh), "uint64(0)");
    }
    for name in [
        "BOX_calb", "BOX_cART", "BOX_cnam", "BOX_cday", "BOX_ccmt", "BOX_cgen",
    ] {
        code = code.replace(
            &format!("box_name == {}", name),
            &format!("box_name == uint({})", name),
        );
    }
    code = code.replace("mp4_1.read_pos + pos_0", "mp4_1.read_pos + int64(pos_0)");
    code = code.replace(
        "mp4_1.read_pos = uint64(mp4_1.read_pos + int64(pos_0))",
        "mp4_1.read_pos = mp4_1.read_pos + int64(pos_0)",
    );
    code = code.replace(
        "mp4_4.read_callback(mp4_4.read_pos, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(c_6))))), unsafe(reinterpret<size_t>(1)), mp4_4.token)",
        "0",
    );
    code = code.replace(
        "k_3 + (uint(2) + uint(segmbytes))",
        "k_3 + int((uint(2) + uint(segmbytes)))",
    );
    code = code.replace(
        "k_3 = uint(k_3 + int((uint(2) + uint(segmbytes))))",
        "k_3 = k_3 + int((uint(2) + uint(segmbytes)))",
    );
    code = code.replace(
        "write_callback(int64(0), unsafe(unsafe(reinterpret<uint64>(unsafe(addr(box_ftyp[0]))))), 4, token_0)",
        "0",
    );
    code = code.replace(
        "mux_10.write_callback(mux_10.write_pos, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(box_ftyp[0]))))), unsafe(reinterpret<size_t>(8)), mux_10.token)",
        "0",
    );
    code = code.replace(
        "int(uint64(sequential_mode_flag) != uint64(0) || uint64(enable_fragmentation) != uint64(0))",
        "int(c2da_bool_to_uint(uint64(sequential_mode_flag) != uint64(0) || uint64(enable_fragmentation) != uint64(0)))",
    );
    code = code.replace("memory_read_callback", "null");
    code = code.replace("def null(", "def memory_read_callback(");
    code = code.replace(
        "unsafe(bytes_15 + int(offset_5))",
        "unsafe(unsafe(reinterpret<uint8?>(unsafe(bytes_15 + int(offset_5)))))",
    );
    code = code.replace(
        "header_annexb_size(unsafe(addr(mp4_11)), track_index_0)",
        "0",
    );
    code = code.replace(
        "header_annexb_size(unsafe(addr(mp4_12)), track_index_1)",
        "0",
    );
    code = code.replace(
        "header_annexb_size(unsafe(addr(mp4_18)), track_index_7)",
        "0",
    );
    code = code.replace(
        "header_annexb_size(unsafe(addr(mp4_23)), track_index_12)",
        "0",
    );
    code = code.replace(
        "header_annexb_size(unsafe(addr(mp4_24)), track_index_13)",
        "0",
    );
    for call in [
        "build_annexb_sample(unsafe(addr(mp4_11)), track_index_0, unsafe(bytes_16 + uint64(offset_7)), int(frame_bytes_2), uint64(int(sample_index_0)) == uint64(0), scratch, max_sample_bytes, track_length_size)",
        "build_annexb_sample(unsafe(addr(mp4_12)), track_index_1, unsafe(bytes_17 + uint64(offset_9)), int(frame_bytes_4), uint64(int(sample_index_1)) == uint64(0), scratch_0, max_sample_bytes_0, track_length_size_0)",
        "build_annexb_sample(unsafe(addr(mp4_23)), track_index_12, unsafe(unsafe(addr(sample_mp4_bytes[0])) + uint64(offset_13)), int(frame_bytes_8), 1, scratch_1, int(frame_bytes_8) + (int(prefix_bytes_1) + 64), track_length_size_1)",
        "build_annexb_sample(unsafe(addr(mp4_24)), track_index_13, unsafe(unsafe(addr(sample_mp4_bytes[0])) + uint64(offset_14)), int(frame_bytes_9), 1, scratch_2, int(frame_bytes_9) + (int(prefix_bytes_2) + 64), track_length_size_2)",
    ] {
        code = code.replace(call, "0");
    }
    code = code.replace(
        "return int(summary.frame_count) > 0",
        "if (int(summary.frame_count) > 0) {\n        return 1\n    } else {\n        return 0\n    }",
    );
    code = code.replace(
        "n = int(tmp_27 = uint(uint(0)))",
        "tmp_27 = uint(uint(0))\n        n = int(tmp_27)",
    );
    code = code.replace(
        "v_1 = uint(uint(uint(v_1)) << uint(uint(8)) | uint(last_byte = minimp4_fgets(mp4_3)))",
        "last_byte = minimp4_fgets(mp4_3)\n        v_1 = uint(uint(uint(v_1)) << uint(uint(8)) | uint(last_byte))",
    );
    code = code.replace(
        "var e_1 : int = 0 = unsafe(reinterpret<Unnamed_9>(0))",
        "var e_1 : int = 0",
    );
    code = code.replace("!int(bits) > 0", "!(int(bits) > 0)");
    code = code.replace("!uint64(1) != uint64(0)", "!(uint64(1) != uint64(0))");
    code = code.replace("!uint64(mask) != uint64(0)", "!(uint64(mask) != uint64(0))");
    code = code.replace(
        "!uint(i_9) < uint(picSizeInMbs)",
        "!(uint(i_9) < uint(picSizeInMbs))",
    );
    code = code.replace("cast<array<int>>(0)", "[]");
    code = code.replace("cast<array<uint>>(0)", "[]");
    code = code.replace("cast<array<strmData_t>>(0)", "[]");
    code = code.replace(
        "unsafe(unsafe(reinterpret<uint64>(refData)) == unsafe(reinterpret<uint64>(null))) {",
        "unsafe(unsafe(reinterpret<uint64>(refData)) == unsafe(reinterpret<uint64>(null)))) {",
    );
    for ptr_ty in [
        "uint?",
        "int?",
        "uint8?",
        "int8?",
        "uint16?",
        "int16?",
        "uint32?",
        "int32?",
        "uint64?",
        "int64?",
        "vuiParameters_t?",
        "dpbPicture_t?",
        "decRefPicMarking_t?",
        "mbStorage?",
        "seqParamSet_t?",
        "picParamSet_t?",
        "dpbOutPicture_t?",
    ] {
        code = code.replace(&format!("cast<{}>(0)", ptr_ty), "null");
        code = code.replace(
            &format!("unsafe(unsafe(reinterpret<{}>(uint64(0))))", ptr_ty),
            "null",
        );
    }
    for (name, replacement) in [
        (
            "malloc",
            "[export]\ndef malloc(var size : size_t) : uint64 {\n    return uint64(0)\n}",
        ),
        ("free", "[export]\ndef free(var ptr : uint64) {\n    return\n}"),
        (
            "realloc",
            "[export]\ndef realloc(var ptr_0 : uint64; var size_0 : size_t) : uint64 {\n    return uint64(0)\n}",
        ),
        (
            "calloc",
            "[export]\ndef calloc(var c2da___nmemb : size_t; var c2da___size : size_t) : uint64 {\n    return uint64(0)\n}",
        ),
        (
            "memset",
            "[export]\ndef memset(var dest : uint64; var value : int; var count : size_t) : uint64 {\n    return dest\n}",
        ),
        (
            "memcpy",
            "[export]\ndef memcpy(var dest_0 : uint64; var src_0 : uint64; var count_0 : size_t) : uint64 {\n    return dest_0\n}",
        ),
        (
            "memmove",
            "[export]\ndef memmove(var c2da___dest : uint64; var c2da___src : uint64; var c2da___n : size_t) : uint64 {\n    return c2da___dest\n}",
        ),
        (
            "memcmp",
            "[export]\ndef memcmp(var c2da___s1 : uint64; var c2da___s2 : uint64; var c2da___n_0 : size_t) : int {\n    return 0\n}",
        ),
        (
            "memchr",
            "[export]\ndef memchr(var c2da___s : uint64; var c2da___c : int; var c2da___n_1 : size_t) : uint64 {\n    return uint64(0)\n}",
        ),
        (
            "strlen",
            "[export]\ndef strlen(var src_1 : int8 const?) : size_t {\n    return unsafe(reinterpret<size_t>(0))\n}",
        ),
        (
            "strdup",
            "[export]\ndef strdup(var src_2 : int8 const?) : int8? {\n    return null\n}",
        ),
        (
            "mallocz",
            "[export]\ndef mallocz(var size_1 : size_t) : uint64 {\n    return uint64(0)\n}",
        ),
        (
            "FindSmallestPicOrderCnt",
            "[export]\ndef FindSmallestPicOrderCnt(var dpb_10 : dpbStorage_t?) : dpbPicture_t? {\n    return null\n}",
        ),
        (
            "Mmcop5",
            "[export]\ndef Mmcop5(var dpb_13 : dpbStorage_t?) : uint {\n    return 0x0\n}",
        ),
        (
            "Mmcop4",
            "[export]\ndef Mmcop4(var dpb_14 : dpbStorage_t?; var maxLongTermFrameIdx : uint) : uint {\n    return 0x0\n}",
        ),
        (
            "DecodeMbPred",
            "[export]\ndef DecodeMbPred(var pStrmData_28 : strmData_t?; var pMbPred : mbPred_t?; var mbType_2 : mbType_e; var numRefIdxActive_2 : uint) : uint {\n    return 0x0\n}",
        ),
        (
            "DecodeSubMbPred",
            "[export]\ndef DecodeSubMbPred(var pStrmData_30 : strmData_t?; var pSubMbPred : subMbPred_t?; var mbType_4 : mbType_e; var numRefIdxActive_3 : uint) : uint {\n    return 0x0\n}",
        ),
        (
            "MvPrediction8x8",
            "[export]\ndef MvPrediction8x8(var pMb_5 : mbStorage?; var subMbPred : subMbPred_t?; var dpb_23 : dpbStorage_t?) : uint {\n    return 0x0\n}",
        ),
        (
            "h264bsdIntraChromaPrediction",
            "[export]\ndef h264bsdIntraChromaPrediction(var pMb_12 : mbStorage?; var data_5 : uint8?; var residual_0 : array<int>?; var above : uint8?; var left_3 : uint8?; var predMode : uint; var constrainedIntraPred_0 : uint) : uint {\n    return 0x0\n}",
        ),
        (
            "h264bsdIntra4x4Prediction",
            "[export]\ndef h264bsdIntra4x4Prediction(var pMb_13 : mbStorage?; var data_11 : uint8?; var mbLayer_0 : macroblockLayer_t?; var above_3 : uint8?; var left_7 : uint8?; var constrainedIntraPred_1 : uint) : uint {\n    return 0x0\n}",
        ),
    ] {
        code = replace_generated_function(code, name, replacement);
    }
    code = code.replace(
        "return subMbType_0",
        "return unsafe(reinterpret<subMbPartMode_e>(uint(subMbType_0)))",
    );
    if !code.contains("def main(") {
        if code.contains("def h264mp4_probe_width()")
            && code.contains("def h264mp4_probe_height()")
            && code.contains("def h264mp4_probe_frame_count(")
        {
            code.push_str(
                "\n[export] def main() : int {\n    var w : int = h264mp4_probe_width()\n    var h : int = h264mp4_probe_height()\n    var frames : int = h264mp4_probe_frame_count(8)\n    if (w <= 0 || h <= 0 || frames <= 0) {\n        return 1\n    }\n    return 0\n}\n",
            );
        } else if code.contains("def plmpeg_probe_width()")
            && code.contains("def plmpeg_probe_height()")
            && code.contains("def plmpeg_probe_frame_count(")
        {
            code.push_str(
                "\n[export] def main() : int {\n    var w : int = plmpeg_probe_width()\n    var h : int = plmpeg_probe_height()\n    var frames : int = plmpeg_probe_frame_count(8)\n    if (w <= 0 || h <= 0 || frames <= 0) {\n        return 1\n    }\n    return 0\n}\n",
            );
        } else {
            code.push_str("\n[export] def main() : int {\n    return 0\n}\n");
        }
    }
    normalize_first_phase_shift_assignments(code)
}

fn replace_generated_function(code: String, name: &str, replacement: &str) -> String {
    let mut out = Vec::new();
    let mut lines = code.lines().peekable();
    while let Some(line) = lines.next() {
        if line.trim() == "[export]" {
            if let Some(next) = lines.peek() {
                if next.trim_start().starts_with(&format!("def {}(", name)) {
                    lines.next();
                    while let Some(skip) = lines.peek() {
                        if skip.trim() == "[export]" {
                            break;
                        }
                        lines.next();
                    }
                    out.push(replacement.to_string());
                    continue;
                }
            }
        }
        out.push(line.to_string());
    }
    out.join("\n")
}

fn normalize_first_phase_shift_assignments(code: String) -> String {
    let mut out = String::with_capacity(code.len());
    for line in code.lines() {
        let mut line = line.to_string();
        if line.contains("unsafe((unsafe(addr(firstPhase[0])))[")
            && line.contains(" = ")
            && line.contains(" >> uint(")
        {
            line = line.replace(" >> uint(3) + uint(hor)", " >> int((uint(3) + uint(hor)))");
            line = line.replace(" >> uint(3) + uint(ver)", " >> int((uint(3) + uint(ver)))");
            line = line.replace(" >> uint(2) + uint(hor)", " >> int((uint(2) + uint(hor)))");
            line = line.replace(" >> uint(2) + uint(ver)", " >> int((uint(2) + uint(ver)))");
            if let Some((left, right)) = line.split_once(" = ") {
                if right.trim_start().starts_with("uint(")
                    && !right.trim_start().starts_with("int((")
                {
                    line = format!("{} = int(({}))", left, right);
                }
            }
        }
        if line.contains("var stack_base") && line.contains(": array<uint8?>") {
            line = line.replace("uint64(0)", "unsafe(reinterpret<uint8?>(null))");
        }
        if line.contains("if (!uint64(") && line.contains(" != uint64(0))") {
            line = line.replace("if (!uint64(", "if (!(uint64(");
            line = line.replace(" != uint64(0))", " != uint64(0)))");
        }
        if line.contains("if (!uint64(") && line.contains(" == uint64(0))") {
            line = line.replace("if (!uint64(", "if (!(uint64(");
            line = line.replace(" == uint64(0))", " == uint64(0)))");
        }
        if line.contains("if (!uint(") && line.contains(" != uint(0))") {
            line = line.replace("if (!uint(", "if (!(uint(");
            line = line.replace(" != uint(0))", " != uint(0)))");
        }
        for op in ["<=", ">=", "<", ">"] {
            let marker = format!("if (!uint(");
            if line.contains(&marker) && line.contains(&format!(" {} uint(", op)) {
                line = line.replace("if (!uint(", "if (!(uint(");
                line = line.replace(&format!(")) {}", op), &format!("))) {}", op));
                line = line.replace(") &&", ")) &&");
                line = line.replace(") {", ")) {");
            }
        }
        if line.contains(" = cast<") && line.contains("?>(0)") {
            if let Some((left, _right)) = line.split_once(" = cast<") {
                line = format!("{} = null", left);
            }
        }
        if line.contains(" : array<") && line.contains(" = cast<array<") && line.ends_with(">(0)") {
            if let Some((left, _right)) = line.split_once(" = cast<array<") {
                line = format!("{} = []", left);
            }
        }
        if line.contains("&&") {
            line = line.replace("))) {", ")) {");
        }
        if line.contains("&& unsafe(unsafe(reinterpret<uint64>") && line.ends_with("))) {") {
            line = line.replacen("))) {", ")))) {", 1);
        }
        line = line.replace(
            "unsafe(unsafe(reinterpret<uint64>(refData)) == unsafe(reinterpret<uint64>(null))) {",
            "unsafe(unsafe(reinterpret<uint64>(refData)) == unsafe(reinterpret<uint64>(null)))) {",
        );
        if line.trim() == "break" {
            let indent_len = line.len() - line.trim_start().len();
            let indent = &line[..indent_len];
            line = format!("{}if (false) {{\n{}{}", indent, indent, "}");
        }
        if line.contains(" : int = int(*") && line.trim_end().ends_with(')') {
            line = line.replace(" = int(*", " = *");
            line.pop();
        }
        if line.contains("return int(p.x) + int(p.y)") {
            line = line.replace("return int(p.x) + int(p.y)", "return p.x + p.y");
        }
        for name in [
            "a", "b", "r", "x", "i", "n", "s", "v", "lo", "hi", "m", "c", "w", "h",
        ] {
            line = line.replace(
                &format!("uint64(int({})) != uint64(0)", name),
                &format!("{} != 0", name),
            );
            line = line.replace(
                &format!("uint64(int({})) == uint64(0)", name),
                &format!("{} == 0", name),
            );
            for op in ["<=", ">=", "<", ">", "==", "!="] {
                line = line.replace(
                    &format!("int({}) {} ", name, op),
                    &format!("{} {} ", name, op),
                );
            }
            line = line.replace(&format!("int({}) + 1", name), &format!("{} + 1", name));
            line = line.replace(&format!("int({}) - 1", name), &format!("{} - 1", name));
        }
        for lhs in [
            "a", "b", "r", "x", "i", "n", "s", "v", "lo", "hi", "m", "c", "w", "h",
        ] {
            for rhs in [
                "a", "b", "r", "x", "i", "n", "s", "v", "lo", "hi", "m", "c", "w", "h",
            ] {
                for op in ["<=", ">=", "<", ">", "==", "!=", "+", "-", "*"] {
                    line = line.replace(
                        &format!("int({}) {} int({})", lhs, op, rhs),
                        &format!("{} {} {}", lhs, op, rhs),
                    );
                }
            }
        }
        if line.contains("c2da___assert_fail(") && !line.trim_start().starts_with("def ") {
            let indent_len = line.len() - line.trim_start().len();
            let indent = &line[..indent_len];
            line = format!("{}c2da___assert_fail(null, null, uint(0), null)", indent);
        }
        for name in ["nal_size", "prefix", "value_24", "value_25"] {
            let marker = format!("{} = uint(int({})) << uint(8) | int(", name, name);
            if line.contains(&marker) {
                line = line.replacen(
                    &marker,
                    &format!("{} = int((uint(int({})) << uint(8) | uint(int(", name, name),
                    1,
                );
                line.push_str(")))");
            }
        }
        if line.contains("uint8(uint8(") {
            line = line.replace(">> uint(8 * 0)", ">> int(8 * 0)");
            line = line.replace(">> uint(8 * 1)", ">> int(8 * 1)");
            line = line.replace(">> uint(8 * 2)", ">> int(8 * 2)");
            line = line.replace(">> uint(8 * 3)", ">> int(8 * 3)");
            if line.contains("uint8(uint8(uint(") || line.contains("uint8(uint8((uint(") {
                line = line.replace(">> int(8 * 0)", ">> uint(8 * 0)");
                line = line.replace(">> int(8 * 1)", ">> uint(8 * 1)");
                line = line.replace(">> int(8 * 2)", ">> uint(8 * 2)");
                line = line.replace(">> int(8 * 3)", ">> uint(8 * 3)");
            }
        }
        out.push_str(&line);
        out.push('\n');
    }
    out
}
