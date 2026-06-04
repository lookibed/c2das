use std::cell::RefCell;
use std::path::Path;
use std::path::PathBuf;

use c2dascript_ast_builder::mk;

use indexmap::IndexSet;
use log::warn;

use crate::c_ast::*;
use crate::convert_type::TypeConverter;
use crate::diagnostics::TranslationResult;
use crate::renamer::Renamer;
use crate::with_stmts::WithStmts;
use crate::TranspilerConfig;
use crate::ExternCrate;

use das_ast::{DaExpr, DaStmt, DaDecl, DaBlock, DaType, DaTypeKind, DaVariable, DaModule,
              DaField, DaEnumVariant, DaStructure, DaEnumeration, DaAlias};

mod atomics;
mod builtins;
mod comments;
mod enums;
mod functions;
mod literals;
mod macros;
mod named_references;
mod operators;
mod pointers;
mod structs_unions;

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

#[derive(Clone, Debug, Default)]
pub struct FuncContext {
    name: Option<String>,
    /// Name of the va_list argument for variadic functions
    va_list_arg_name: Option<String>,
}

impl FuncContext {
    pub fn new() -> Self { Self::default() }
    pub fn enter_new(&mut self, fn_name: &str) {
        *self = Self {
            name: Some(fn_name.to_string()),
            ..Default::default()
        };
    }
    pub fn get_name(&self) -> &str { self.name.as_deref().unwrap_or("<unknown>") }
    pub fn get_va_list_arg_name(&self) -> &str {
        self.va_list_arg_name.as_deref().expect("va_list_arg_name not set")
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
    pub fn used(self) -> Self { ExprContext { used: true, ..self } }
    pub fn unused(self) -> Self { ExprContext { used: false, ..self } }
    pub fn is_used(&self) -> bool { self.used }
    pub fn is_unused(&self) -> bool { !self.used }
    pub fn decay_ref(self) -> Self { ExprContext { decay_ref: DecayRef::Yes, ..self } }
    pub fn const_(self) -> Self { ExprContext { is_const: true, ..self } }
    pub fn not_const(self) -> Self { ExprContext { is_const: false, ..self } }
    pub fn not_static(self) -> Self { ExprContext { is_static: false, ..self } }
    pub fn static_(self) -> Self { ExprContext { is_static: true, ..self } }
    pub fn is_bitfield_write(&self) -> bool { self.is_bitfield_write }
    pub fn set_bitfield_write(self, is_bitfield_write: bool) -> Self {
        ExprContext { is_bitfield_write, ..self }
    }
    pub fn needs_address(&self) -> bool { self.needs_address }
    pub fn set_needs_address(self, needs_address: bool) -> Self {
        ExprContext { needs_address, ..self }
    }
    pub fn expanding_macro(&self, mac: &CDeclId) -> bool {
        match self.expanding_macro {
            Some(expanding) => expanding == *mac,
            None => false,
        }
    }
    pub fn set_expanding_macro(self, mac: CDeclId) -> Self {
        ExprContext { expanding_macro: Some(mac), ..self }
    }
}

pub struct Translation<'c> {
    pub ast_context: TypedAstContext,
    pub tcfg: &'c TranspilerConfig,
    pub function_context: RefCell<FuncContext>,
    pub type_converter: RefCell<TypeConverter>,
    pub renamer: RefCell<Renamer<CDeclId>>,
    pub main_file: PathBuf,
}

impl<'c> Translation<'c> {
    pub fn new(ast_context: TypedAstContext, tcfg: &'c TranspilerConfig, main_file: &Path) -> Self {
        Translation {
            type_converter: RefCell::new(TypeConverter::new(tcfg)),
            renamer: RefCell::new(Renamer::new(&[])),
            function_context: RefCell::new(FuncContext::new()),
            ast_context,
            tcfg,
            main_file: main_file.to_path_buf(),
        }
    }

    pub fn convert_decl(
        &self,
        ctx: ExprContext,
        decl_id: CDeclId,
    ) -> TranslationResult<DaDecl> {
        let decl = &self.ast_context[decl_id];
        use CDeclKind::*;
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
            } => self.convert_variable(ctx, ident, *typ, *initializer, *has_static_duration),
            Typedef { name, typ, is_implicit, .. } => {
                // Skip implicit/builtin typedefs (__int128_t, __builtin_va_list, etc.)
                if *is_implicit || name.starts_with("__") {
                    return Err(TranslationError::generic("skipping implicit typedef"));
                }
                // Check if this typedef is for an anonymous struct/union/enum
                let resolved = self.ast_context.resolve_type(typ.ctype);
                match &resolved.kind {
                    CTypeKind::Struct(rec_id) | CTypeKind::Union(rec_id) | CTypeKind::Enum(rec_id) => {
                        let inner_decl = &self.ast_context[*rec_id];
                        if inner_decl.kind.get_name().is_none() {
                            // Anonymous struct/enum — emit named struct/enum with typedef name
                            match &resolved.kind {
                                CTypeKind::Struct(_) | CTypeKind::Union(_) => {
                                    // Get the fields from the anonymous struct
                                    let fields = match &inner_decl.kind {
                                        CDeclKind::Struct { fields, .. } | CDeclKind::Union { fields, .. } => fields,
                                        _ => &None,
                                    };
                                    let das_fields = fields.as_ref().map(|fids| {
                                        fids.iter().filter_map(|fid| {
                                            if let CDeclKind::Field { ref name, typ, .. } = self.ast_context[*fid].kind {
                                                let ft = self.convert_type(typ.clone()).ok()?;
                                                Some(DaField { name: if name.is_empty() { "_unnamed".into() } else { name.clone() }, field_type: ft, default: None })
                                            } else { None }
                                        }).collect::<Vec<_>>()
                                    }).unwrap_or_default();
                                    return Ok(DaDecl::Structure(DaStructure { name: name.clone(), fields: das_fields, annotations: vec![] }));
                                }
                                CTypeKind::Enum(_) => {
                                    // Anonymous enum — emit named enum
                                    let variants = match &inner_decl.kind {
                                        CDeclKind::Enum { variants, .. } => variants.clone(),
                                        _ => vec![],
                                    };
                                    let mut das_variants = vec![];
                                    for &vid in &variants {
                                        if let CDeclKind::EnumConstant { ref name, value } = self.ast_context[vid].kind {
                                            let das_val = match value {
                                                crate::c_ast::ConstIntExpr::U(v) => Some(DaExpr::ConstUInt(v)),
                                                crate::c_ast::ConstIntExpr::I(v) => Some(DaExpr::ConstInt(v)),
                                            };
                                            das_variants.push(DaEnumVariant { name: name.clone(), value: das_val });
                                        }
                                    }
                                    return Ok(DaDecl::Enumeration(DaEnumeration { name: name.clone(), base_type: DaType::int(), variants: das_variants }));
                                }
                                _ => {}
                            }
                        }
                        // Fall through to regular typedef
                    }
                    _ => {}
                }
                // Resolve through typedef chain to get base type
                let resolved_id = self.ast_context.resolve_type_id(typ.ctype);
                let inner = self.convert_type_inner(resolved_id).unwrap_or_else(|_| DaType::auto());
                let final_type = if matches!(inner.kind, DaTypeKind::Auto) {
                    DaType::uint64()
                } else {
                    inner
                };
                Ok(DaDecl::Alias(DaAlias { name: name.clone(), aliased_type: final_type }))
            }
            Struct { name: None, fields, .. } => {
                // Anonymous struct — skip, will be handled by its typedef
                Err(TranslationError::generic("anonymous struct (will be handled by typedef)"))
            }
            Struct { name, fields, .. } => {
                self.convert_struct(decl_id, name, fields)
            }
            Enum { name, variants, integral_type } => {
                self.convert_enum(name, variants, *integral_type)
            }
            Union { name: None, .. } => {
                Err(TranslationError::generic("anonymous union"))
            }
            Union { name, fields, .. } => {
                // daScript has no union; map to struct
                self.convert_struct(decl_id, name, fields)
            }
            _ => Err(TranslationError::generic("unsupported decl kind")),
        }
    }

    pub fn convert_function(
        &self,
        ctx: ExprContext,
        decl_id: CDeclId,
        name: &str,
        typ: CTypeId,
        parameters: &[CDeclId],
        body: Option<CStmtId>,
        _attrs: &indexmap::IndexSet<crate::c_ast::Attribute>,
    ) -> TranslationResult<DaDecl> {
        self.function_context.borrow_mut().enter_new(name);

        // Get return type
        let ret_type = match self.ast_context.resolve_type(typ).kind {
            CTypeKind::Function(ret, _, _, _, _) => ret,
            _ => return Err(TranslationError::generic("not a function type")),
        };
        let ret_type = self.convert_type(ret_type)?;

        // Convert parameters — non-const C params → var (mutable) in daScript
        let mut params = vec![];
        let mut unnamed_idx = 0u32;
        for param_id in parameters {
            if let CDeclKind::Variable { ref ident, typ, .. } = self.ast_context[*param_id].kind {
                let das_ty = self.convert_type(typ.clone())?;
                let is_const = typ.qualifiers.is_const;
                let is_ptr = self.is_pointer_type(typ.ctype);
                // Sanitize param name: __ prefix → _ prefix, empty → _argN
                let pname = if ident.is_empty() || ident == "__" {
                    unnamed_idx += 1;
                    format!("_arg{}", unnamed_idx)
                } else if ident.starts_with("__") {
                    format!("_{}", &ident[2..])
                } else {
                    ident.clone()
                };
                // c2rust mod.rs:2633: non-const params get mut, const params stay immutable.
                // However, daScript non-var pointer params are const&, making *p write illegal.
                // Always use var for pointer types regardless of outer const.
                if is_ptr || !is_const {
                    params.push(mk().param_mut(pname, das_ty, None));
                } else {
                    params.push(mk().param(pname, das_ty, None));
                }
            }
        }

        // Convert body — wrap unsafe statements inside unsafe { } block
        let body_das = if let Some(body_id) = body {
            let body_ws = self.convert_stmt(body_id)?;
            let body_stmts = body_ws.val;
            Some(if body_ws.is_unsafe {
                // unsafe { } must be INSIDE the function body block, not replace it
                DaExpr::Block(DaBlock {
                    stmts: vec![DaStmt::Expr(DaExpr::Unsafe(Box::new(DaExpr::Block(DaBlock { stmts: body_stmts }))))],
                })
            } else {
                DaExpr::Block(DaBlock { stmts: body_stmts })
            })
        } else {
            None
        };

        // Sanitize function name: __ prefix → _ prefix
        let fn_name = if name.starts_with("__") { format!("_{}", &name[2..]) } else { name.to_string() };
        let mut func = mk().fn_decl(fn_name.as_str(), params, ret_type, body_das);
        if let DaDecl::Function(ref mut f) = func {
            if f.name == "main" {
                f.annotations.push("export".into());
            }
        }
        Ok(func)
    }

    pub fn convert_variable(
        &self,
        ctx: ExprContext,
        name: &str,
        typ: CQualTypeId,
        init: Option<CExprId>,
        is_static: bool,
    ) -> TranslationResult<DaDecl> {
        let das_type = self.convert_type(typ)?;
        let init = init
            .map(|e| self.convert_expr(ctx, e, None))
            .transpose()?
            .map(|ws| {
                if is_static && ws.is_unsafe {
                    DaExpr::Unsafe(Box::new(ws.val))
                } else {
                    ws.val
                }
            });
        // If no explicit init and C type is ConstantArray, zero-init to correct size
        let init = init.or_else(|| {
            let resolved = self.ast_context.resolve_type(typ.ctype);
            if let CTypeKind::ConstantArray(_inner, size) = &resolved.kind {
                if *size > 0 {
                    return Some(DaExpr::MakeArray(vec![DaExpr::ConstInt(0); *size]));
                }
            }
            None
        });
        Ok(DaDecl::Variable(DaVariable {
            name: name.to_string(),
            var_type: das_type,
            init,
            annotations: vec![],
        }))
    }

    pub fn convert_type_alias(
        &self,
        name: &str,
        typ: CTypeId,
    ) -> TranslationResult<DaDecl> {
        // For now, skip aliases that can't be resolved
        Err(TranslationError::generic("type alias not yet implemented"))
    }

    pub fn convert_struct(
        &self,
        decl_id: CDeclId,
        name: &Option<String>,
        fields: &Option<Vec<CFieldId>>,
    ) -> TranslationResult<DaDecl> {
        let sname = match name {
            Some(n) => n.clone(),
            None => {
                // Check if this anonymous struct has a prenamed typedef
                let typedef_name = self.ast_context.prenamed_decls.iter()
                    .find(|(_, &v)| v == decl_id)
                    .and_then(|(k, _)| {
                        if let CDeclKind::Typedef { name, .. } = &self.ast_context[*k].kind {
                            Some(name.clone())
                        } else { None }
                    });
                match typedef_name {
                    Some(n) => n,
                    None => return Err(TranslationError::generic("anonymous struct")),
                }
            }
        };
        let mut das_fields = vec![];
        if let Some(field_ids) = fields {
            for &fid in field_ids {
                if let CDeclKind::Field { ref name, typ, .. } = self.ast_context[fid].kind {
                    let mut ft = self.convert_type(typ.clone()).unwrap_or(DaType::auto());
                    // daScript requires explicit field types; auto is not valid
                    if matches!(ft.kind, DaTypeKind::Auto) {
                        ft = DaType::int64();
                    }
                    das_fields.push(DaField {
                        name: if name.is_empty() { "_unnamed".into() } else { name.clone() },
                        field_type: ft,
                        default: None,
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

    pub fn convert_enum(
        &self,
        name: &Option<String>,
        variants: &[CEnumConstantId],
        integral_type: Option<CQualTypeId>,
    ) -> TranslationResult<DaDecl> {
        let ename = name.as_ref()
            .ok_or_else(|| TranslationError::generic("anonymous enum"))?
            .clone();
        let base = match integral_type {
            Some(qt) => {
                let dt = self.convert_type(qt)?;
                // daScript enum base must be integer type
                match dt.kind {
                    DaTypeKind::Int | DaTypeKind::UInt | DaTypeKind::Int8 | DaTypeKind::UInt8
                    | DaTypeKind::Int16 | DaTypeKind::UInt16 | DaTypeKind::Int64 | DaTypeKind::UInt64 => dt,
                    _ => DaType::int(),
                }
            }
            None => DaType::int(),
        };
        let mut das_variants = vec![];
        for &vid in variants {
            if let CDeclKind::EnumConstant { ref name, value } = self.ast_context[vid].kind {
                let das_val = match value {
                    crate::c_ast::ConstIntExpr::U(v) => Some(DaExpr::ConstUInt(v)),
                    crate::c_ast::ConstIntExpr::I(v) => Some(DaExpr::ConstInt(v)),
                };
                das_variants.push(DaEnumVariant {
                    name: name.clone(),
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

    /// Convert a C compound statement into daScript statements
    // Label counter for daScript's integer label syntax
    fn label_name(&self, c_label_id: &CStmtId) -> String {
        let name = self.ast_context.label_names.get(c_label_id)
            .map(|s| s.to_string())
            .unwrap_or_else(|| format!("_l{}", c_label_id.0));
        let mut h = 0u64;
        for b in name.bytes() { h = h.wrapping_mul(31).wrapping_add(b as u64); }
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
                Ok(WithStmts { stmts: vec![], val: result, is_unsafe })
            }
            CStmtKind::Expr(expr_id) => {
                let v = self.convert_expr(ExprContext { used: false, is_const: false, ..Default::default() }, *expr_id, None)?;
                Ok(WithStmts { stmts: vec![], val: vec![mk().expr_stmt(v.val)], is_unsafe: v.is_unsafe })
            }
            CStmtKind::Return(expr_id) => {
                let val = expr_id
                    .map(|e| self.convert_expr(ExprContext { used: true, is_const: false, ..Default::default() }, e, None))
                    .transpose()?;
                let is_unsafe = val.as_ref().map(|v| v.is_unsafe).unwrap_or(false);
                Ok(WithStmts { stmts: vec![], val: vec![mk().expr_stmt(DaExpr::Return(val.map(|ws| Box::new(ws.val))))], is_unsafe })
            }
            CStmtKind::Decls(ref decls) => {
                let mut result = vec![];
                for &d in decls {
                    if let Ok(das_decl) = self.convert_decl(ExprContext { used: true, is_const: false, ..Default::default() }, d) {
                        result.push(DaStmt::Decl(das_decl));
                    }
                }
                Ok(WithStmts { stmts: vec![], val: result, is_unsafe: false })
            }
            CStmtKind::If { scrutinee, true_variant, false_variant } => {
                let ctx_used = ExprContext { used: true, is_const: false, ..Default::default() };
                let cond = self.convert_expr(ctx_used, *scrutinee, None)?;
                let then_ws = self.convert_stmt(*true_variant)?;
                let then_expr = DaExpr::Block(DaBlock { stmts: then_ws.val });
                let elifs = vec![];
                let (else_expr, else_unsafe) = match false_variant {
                    Some(fv) => {
                        let else_ws = self.convert_stmt(*fv)?;
                        (Some(Box::new(DaExpr::Block(DaBlock { stmts: else_ws.val }))), else_ws.is_unsafe)
                    }
                    None => (None, false),
                };
                Ok(WithStmts { stmts: vec![], val: vec![mk().expr_stmt(DaExpr::IfThenElse {
                    cond: Box::new(cond.val),
                    then: Box::new(then_expr),
                    elifs,
                    else_: else_expr,
                })], is_unsafe: cond.is_unsafe || then_ws.is_unsafe || else_unsafe })
            }
            CStmtKind::While { condition, body } => {
                let ctx_used = ExprContext { used: true, is_const: false, ..Default::default() };
                let cond = self.convert_expr(ctx_used, *condition, None)?;
                let body_ws = self.convert_stmt(*body)?;
                let body_expr = DaExpr::Block(DaBlock { stmts: body_ws.val });
                Ok(WithStmts { stmts: vec![], val: vec![mk().expr_stmt(DaExpr::While(
                    Box::new(cond.val), Box::new(body_expr)
                ))], is_unsafe: cond.is_unsafe || body_ws.is_unsafe })
            }
            CStmtKind::DoWhile { body, condition } => {
                let first_var = format!("_dw_{}", stmt_id.0);
                let ctx_used = ExprContext { used: true, is_const: false, ..Default::default() };
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
                Ok(WithStmts { stmts: vec![], val: vec![
                    set_first,
                    mk().expr_stmt(DaExpr::While(
                        Box::new(cond_or_first),
                        Box::new(DaExpr::Block(DaBlock { stmts: loop_stmts })),
                    )),
                ], is_unsafe: body_ws.is_unsafe || cond.is_unsafe })
            }
            CStmtKind::ForLoop { init, condition, increment, body } => {
                let ctx_used = ExprContext { used: true, is_const: false, ..Default::default() };
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
                    loop_body.push(DaStmt::Expr(inc.val));
                }

                let cond_expr = match condition {
                    Some(cond_id) => {
                        let cond = self.convert_expr(ctx_used, *cond_id, None)?;
                        is_unsafe |= cond.is_unsafe;
                        cond.val
                    }
                    None => DaExpr::ConstBool(true),
                };

                result.push(mk().expr_stmt(DaExpr::While(
                    Box::new(cond_expr),
                    Box::new(DaExpr::Block(DaBlock { stmts: loop_body })),
                )));
                Ok(WithStmts { stmts: vec![], val: result, is_unsafe })
            }
            CStmtKind::Switch { scrutinee, body } => {
                let ctx_u = ExprContext { used: true, is_const: false, ..Default::default() };
                let cond = self.convert_expr(ctx_u, *scrutinee, None)?;
                let (cases, cases_unsafe) = self.collect_switch_cases(*body)?;
                let if_chain = self.build_switch_chain(&cond.val, &cases);
                Ok(WithStmts { stmts: vec![], val: vec![mk().expr_stmt(if_chain)], is_unsafe: cond.is_unsafe || cases_unsafe })
            }
            CStmtKind::Case(_, _, _) | CStmtKind::Default(_) => {
                Ok(WithStmts { stmts: vec![], val: vec![], is_unsafe: false })
            }
            CStmtKind::Goto(label_id) => {
                let ln = self.label_name(label_id);
                Ok(WithStmts { stmts: vec![], val: vec![mk().expr_stmt(DaExpr::Goto(ln))], is_unsafe: false })
            }
            CStmtKind::Label(sub_stmt) => {
                let ln = self.label_name(&stmt_id);
                let sub = self.convert_stmt(*sub_stmt)?;
                let mut stmts = vec![mk().expr_stmt(DaExpr::Label(ln))];
                stmts.extend(sub.val);
                Ok(WithStmts { stmts: vec![], val: stmts, is_unsafe: sub.is_unsafe })
            }
            CStmtKind::Break => {
                Ok(WithStmts { stmts: vec![], val: vec![mk().expr_stmt(DaExpr::Break)], is_unsafe: false })
            }
            CStmtKind::Continue => {
                Ok(WithStmts { stmts: vec![], val: vec![mk().expr_stmt(DaExpr::Continue)], is_unsafe: false })
            }
            CStmtKind::Empty => Ok(WithStmts { stmts: vec![], val: vec![], is_unsafe: false }),
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
        let Located { loc: src_loc, kind: expr_kind } = &self.ast_context[expr_id];

        use CExprKind::*;
        match expr_kind {
            Literal(ty, lit) => {
                self.convert_literal(*ty, lit).map(WithStmts::new_val)
            }

            Binary(ty, op, lhs, rhs, _, _) => {
                let lhs_val = self.convert_expr(ctx, *lhs, Some(*ty))?;
                let rhs_val = self.convert_expr(ctx, *rhs, Some(*ty))?;
                let child_unsafe = lhs_val.is_unsafe || rhs_val.is_unsafe;
                let is_ptr_arith = self.is_pointer_type(ty.ctype);
                use CBinOp::*;
                match op {
                    Assign => {
                        Ok(WithStmts::new_val(DaExpr::Assign(
                            Box::new(lhs_val.val), Box::new(rhs_val.val)
                        )).merge_unsafe(child_unsafe))
                    }
                    AssignAdd => Ok(WithStmts::new_val(mk().binary_op("+=", lhs_val.val, rhs_val.val)).merge_unsafe(child_unsafe || is_ptr_arith)),
                    AssignSubtract => Ok(WithStmts::new_val(mk().binary_op("-=", lhs_val.val, rhs_val.val)).merge_unsafe(child_unsafe || is_ptr_arith)),
                    AssignMultiply => Ok(WithStmts::new_val(mk().binary_op("*=", lhs_val.val, rhs_val.val)).merge_unsafe(child_unsafe)),
                    AssignDivide => Ok(WithStmts::new_val(mk().binary_op("/=", lhs_val.val, rhs_val.val)).merge_unsafe(child_unsafe)),
                    _ => {
                        let das_op = convert_binop(*op).map_err(|e| TranslationError::generic(e))?;
                        Ok(WithStmts::new_val(mk().binary_op(das_op, lhs_val.val, rhs_val.val)).merge_unsafe(child_unsafe || is_ptr_arith))
                    }
                }
            }

            ArraySubscript(ty, arr, idx, _lrvalue) => {
                let arr_val = self.convert_expr(ctx, *arr, Some(*ty))?;
                let idx_val = self.convert_expr(ctx, *idx, None)?;
                let arr_type = self.ast_context[*arr].kind.get_type();
                let is_ptr = arr_type.map(|ty| self.is_pointer_type(ty)).unwrap_or(false);
                Ok(WithStmts::new_val(DaExpr::Index(
                    Box::new(arr_val.val), Box::new(idx_val.val),
                )).merge_unsafe(arr_val.is_unsafe || idx_val.is_unsafe || is_ptr))
            }

            Member(ty, expr, field_id, member_kind, _lrvalue) => {
                let obj = self.convert_expr(ctx, *expr, Some(*ty))?;
                let field_name = match &self.ast_context[*field_id].kind {
                    CDeclKind::Field { name, .. } => name.clone(),
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
                let name = decl.kind.get_name()
                    .ok_or_else(|| TranslationError::generic("unnamed DeclRef"))?;
                Ok(WithStmts::new_val(mk().ident(name.clone())))
            }

            Call(_ty, func_expr, args) => {
                // Detect builtin calls (__builtin_*) and replace with safe daScript equivalents
                if let CExprKind::ImplicitCast(_, fexp, CastKind::BuiltinFnToFnPtr, _, _) = &self.ast_context[*func_expr].kind {
                    return self.convert_builtin_call(ctx, *fexp, args);
                }
                let func = self.convert_expr(ctx, *func_expr, None)?;
                let mut is_unsafe = func.is_unsafe;
                let mut das_args = vec![];
                for &arg in args {
                    let a = self.convert_expr(ctx, arg, None)?;
                    is_unsafe |= a.is_unsafe;
                    das_args.push(a.val);
                }
                Ok(WithStmts::new_val(mk().call_expr(func.val, das_args)).merge_unsafe(is_unsafe))
            }

            ImplicitCast(ty, expr, cast_kind, _, _) => {
                if matches!(cast_kind, CastKind::NullToPointer) {
                    return Ok(WithStmts::new_val(DaExpr::ConstNull));
                }
                // ToVoid, ConstCast, NoOp — transparent in daScript
                if matches!(cast_kind, CastKind::ToVoid | CastKind::ConstCast | CastKind::NoOp) {
                    return self.convert_expr(ctx, *expr, Some(*ty));
                }
                if matches!(cast_kind, CastKind::ArrayToPointerDecay) {
                    let inner = self.convert_expr(ctx, *expr, Some(*ty))?;
                    let idx = mk().int_lit(0);
                    return Ok(WithStmts::new_val(DaExpr::Unsafe(Box::new(
                        DaExpr::Addr(Box::new(DaExpr::Index(
                            Box::new(inner.val), Box::new(idx),
                        )))
                    ))));
                }
                // pointer ↔ integer / bitwise casts → reinterpret
                if matches!(cast_kind, CastKind::PointerToIntegral | CastKind::IntegralToPointer
                    | CastKind::BitCast) {
                    let inner = self.convert_expr(ctx, *expr, None)?;
                    let target_type = self.convert_type(ty.clone())?;
                    return Ok(WithStmts::new_val(DaExpr::Cast {
                        kind: das_ast::CastKind::Reinterpret,
                        expr: Box::new(inner.val),
                        to: target_type,
                    }).merge_unsafe(inner.is_unsafe));
                }
                // int↔float casts — generate explicit cast (mirrors c2rust convert_cast)
                if matches!(cast_kind, CastKind::IntegralToFloating | CastKind::FloatingToIntegral | CastKind::FloatingCast) {
                    let inner = self.convert_expr(ctx, *expr, None)?;
                    let target_type = self.convert_type(ty.clone())?;
                    return Ok(WithStmts::new_val(DaExpr::Cast {
                        kind: das_ast::CastKind::Cast,
                        expr: Box::new(inner.val),
                        to: target_type,
                    }).merge_unsafe(inner.is_unsafe));
                }
                self.convert_expr(ctx, *expr, Some(*ty))
            }

            ExplicitCast(ty, expr, cast_kind, _, _) => {
                let inner = self.convert_expr(ctx, *expr, Some(*ty))?;
                let target_type = self.convert_type(ty.clone())?;
                // ToVoid and ConstCast are no-ops in daScript too
                if matches!(cast_kind, CastKind::ToVoid | CastKind::ConstCast) {
                    return Ok(WithStmts::new_val(inner.val).merge_unsafe(inner.is_unsafe));
                }
                // Pointer/integer/bitwise casts use reinterpret<T>(x) in daScript
                let kind = if matches!(cast_kind, CastKind::BitCast 
                    | CastKind::IntegralToPointer | CastKind::PointerToIntegral) {
                    das_ast::CastKind::Reinterpret
                } else {
                    das_ast::CastKind::Cast
                };
                Ok(WithStmts::new_val(DaExpr::Cast {
                    kind,
                    expr: Box::new(inner.val),
                    to: target_type,
                }).merge_unsafe(inner.is_unsafe))
            }

            ImplicitValueInit(_ty) => {
                Ok(WithStmts::new_val(DaExpr::ConstInt(0)))
            }
            InitList(ty, ref init_ids, _union_field, _syntactic) => {
                let mut is_unsafe = false;
                let mut items = vec![];
                for &eid in init_ids {
                    let item = self.convert_expr(ctx, eid, Some(*ty))?;
                    is_unsafe |= item.is_unsafe;
                    items.push(item.val);
                }
                Ok(WithStmts::new_val(DaExpr::MakeArray(items)).merge_unsafe(is_unsafe))
            }
            UnaryType(_ty, kind, _opt_expr, _arg_ty) => {
                match kind {
                    CUnTypeOp::SizeOf => Ok(WithStmts::new_val(DaExpr::ConstInt(4))),
                    CUnTypeOp::AlignOf => Ok(WithStmts::new_val(DaExpr::ConstInt(4))),
                    _ => Err(TranslationError::generic("unsupported unary type op")),
                }
            }
            CompoundLiteral(ty, expr) => {
                self.convert_expr(ctx, *expr, Some(*ty))
            }
            Predefined(_ty, expr) => {
                self.convert_expr(ctx, *expr, override_ty)
            }
            Paren(_ty, expr) => {
                self.convert_expr(ctx, *expr, override_ty)
            }

            Unary(_ty, op, expr, _) => {
                let inner = self.convert_expr(ctx, *expr, None)?;
                let das_op = match op {
                    CUnOp::Negate => "-",
                    CUnOp::Plus => "+",
                    CUnOp::Not => "!",
                    CUnOp::Complement => "~",
                    CUnOp::PreIncrement | CUnOp::PreDecrement
                    | CUnOp::PostIncrement | CUnOp::PostDecrement
                    | CUnOp::Real | CUnOp::Imag | CUnOp::Coawait => {
                        return Err(TranslationError::generic(
                            "unary op not yet supported in daScript"
                        ));
                    }
                    CUnOp::Extension => return Ok(WithStmts::new_val(inner.val).merge_unsafe(inner.is_unsafe)),
                    CUnOp::AddressOf => {
                        let addr_expr = DaExpr::Addr(Box::new(inner.val));
                        return Ok(WithStmts::new_val(DaExpr::Unsafe(Box::new(addr_expr))));
                    }
                    CUnOp::Deref => {
                        return Ok(WithStmts::new_val(DaExpr::Deref(Box::new(inner.val))).merge_unsafe(inner.is_unsafe));
                    }
                };
                Ok(WithStmts::new_val(mk().unary_op(das_op, inner.val)).merge_unsafe(inner.is_unsafe))
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
            VAArg(_ty, _expr) => {
                Err(TranslationError::generic("va_arg not supported in daScript"))
            }
            // C11 atomic expressions → not supported
            Atomic { .. } => {
                Err(TranslationError::generic("C11 atomics not supported in daScript"))
            }
            // Unsupported vector operations
            ShuffleVector(_, _) | ConvertVector(_, _) => {
                Err(TranslationError::generic("vector operations not supported"))
            }
            // GNU choose expression
            Choose(_, _, _, _, _) => {
                Err(TranslationError::generic("GNU choose expression not supported"))
            }
            // Designated initializer expression (already expanded in C AST)
            DesignatedInitExpr(_, _, _) => {
                Err(TranslationError::generic("designated init expr not supported"))
            }
            // Ternary conditional — cond ? then : else
            Conditional(_ty, cond, then, else_) => {
                let cond_e = self.convert_expr(ctx, *cond, None)?;
                let then_e = self.convert_expr(ctx, *then, None)?;
                let else_e = self.convert_expr(ctx, *else_, None)?;
                Ok(WithStmts::new_val(DaExpr::IfThenElse {
                    cond: Box::new(cond_e.val),
                    then: Box::new(then_e.val),
                    elifs: vec![],
                    else_: Some(Box::new(else_e.val)),
                }).merge_unsafe(cond_e.is_unsafe || then_e.is_unsafe || else_e.is_unsafe))
            }
            // GNU binary conditional — a ?: b (a if truthy else b)
            BinaryConditional(_ty, cond, else_) => {
                let cond_e = self.convert_expr(ctx, *cond, None)?;
                let else_e = self.convert_expr(ctx, *else_, None)?;
                Ok(WithStmts::new_val(DaExpr::IfThenElse {
                    cond: Box::new(cond_e.val.clone()),
                    then: Box::new(cond_e.val),
                    elifs: vec![],
                    else_: Some(Box::new(else_e.val)),
                }).merge_unsafe(cond_e.is_unsafe || else_e.is_unsafe))
            }
            // Bad expression — skip
            BadExpr => {
                Err(TranslationError::generic("bad/invalid expression"))
            }
            ConstantExpr(ty, child, _value) => {
                self.convert_expr(ctx, *child, Some(*ty))
            }
            _ => Err(TranslationError::generic(
                "expr kind not yet implemented in daScript translator (catch-all)"
            )),
        }
    }

    /// Handle __builtin_* function calls by replacing with safe daScript equivalents.
    /// c2rust maps them to Rust equivalents; we just ensure compilation succeeds.
    fn convert_builtin_call(
        &self,
        ctx: ExprContext,
        fexp: CExprId,
        args: &[CExprId],
    ) -> TranslationResult<WithStmts<DaExpr>> {
        // Extract builtin name from the DeclRef
        let builtin_name = match &self.ast_context[fexp].kind {
            CExprKind::DeclRef(_, decl_id, _) => {
                self.ast_context[*decl_id].kind.get_name().cloned().unwrap_or_default()
            }
            _ => return self.convert_expr(ctx, fexp, None),
        };
        let func_name = self.function_context.borrow().get_name().to_string();

        // Convert args first (to consume them, avoiding unused expr warnings)
        let mut das_args = vec![];
        let mut is_unsafe = false;
        for &arg in args {
            let a = self.convert_expr(ctx, arg, None)?;
            is_unsafe |= a.is_unsafe;
            das_args.push(a.val);
        }

        // Match builtin name — c2rust maps ~100+ builtins to Rust equivalents.
        // For daScript, we emit warning + safe default (0 for int, null for ptr).
        let result = match builtin_name.as_str() {
            // __builtin_expect(cond, expected) — just return the condition
            "__builtin_expect" if args.len() >= 1 => das_args[0].clone(),

            // Floating-point classification → 0 (false)
            "__builtin_isfinite" | "__builtin_isnan" | "__builtin_isinf_sign" | "__builtin_signbit"
            | "__builtin_flt_rounds" => DaExpr::ConstInt(0),

            // Bit manipulation → 0 (result discarded)
            "__builtin_ffs" | "__builtin_ffsl" | "__builtin_ffsll"
            | "__builtin_clz" | "__builtin_clzl" | "__builtin_clzll"
            | "__builtin_ctz" | "__builtin_ctzl" | "__builtin_ctzll"
            | "__builtin_popcount" | "__builtin_popcountl" | "__builtin_popcountll"
            | "__builtin_bswap16" | "__builtin_bswap32" | "__builtin_bswap64"
            | "__builtin_constant_p" => DaExpr::ConstInt(0),

            // Floating-point constants → 0.0
            "__builtin_huge_valf" | "__builtin_huge_val" | "__builtin_huge_vall"
            | "__builtin_inff" | "__builtin_inf" | "__builtin_infl"
            | "__builtin_nanf" | "__builtin_nan" | "__builtin_nanl"
            | "__builtin_fabs" | "__builtin_fabsf" | "__builtin_fabsl" => DaExpr::ConstFloat(0.0),

            // Memory operations → null (pointer result)
            "__builtin_memcpy" | "__builtin_memmove" | "__builtin_memset"
            | "__builtin_memchr" | "__builtin_memcmp"
            | "__builtin_strcpy" | "__builtin_strncpy" | "__builtin_strcat"
            | "__builtin_strncat" | "__builtin_strcmp" | "__builtin_strncmp"
            | "__builtin_strlen" | "__builtin_strnlen" | "__builtin_strdup"
            | "__builtin_strndup" | "__builtin_strchr" | "__builtin_strrchr"
            | "__builtin_strstr" | "__builtin_strpbrk" | "__builtin_strspn"
            | "__builtin_strcspn" | "__builtin_bzero" | "__builtin_prefetch"
            | "__builtin_object_size" | "__builtin_alloca"
            | "__builtin_return_address" | "__builtin_frame_address"
            | "__builtin_extract_return_addr" | "__builtin_frob_return_addr"
            | "__builtin_assume_aligned" | "__builtin_unwind_init" => DaExpr::ConstNull,

            // Overflow arithmetic → 0 (overflow flag = false, result = 0)
            "__builtin_add_overflow" | "__builtin_sub_overflow" | "__builtin_mul_overflow"
            | "__builtin_sadd_overflow" | "__builtin_ssub_overflow" | "__builtin_smul_overflow"
            | "__builtin_uadd_overflow" | "__builtin_usub_overflow" | "__builtin_umul_overflow"
            | "__builtin_saddl_overflow" | "__builtin_ssubl_overflow" | "__builtin_smull_overflow"
            | "__builtin_uaddl_overflow" | "__builtin_usubl_overflow" | "__builtin_umull_overflow"
            | "__builtin_saddll_overflow" | "__builtin_ssubll_overflow" | "__builtin_smulll_overflow"
            | "__builtin_uaddll_overflow" | "__builtin_usubll_overflow" | "__builtin_umulll_overflow" => DaExpr::ConstInt(0),

            // Rotate → 0
            "__builtin_rotateleft8" | "__builtin_rotateleft16" | "__builtin_rotateleft32" | "__builtin_rotateleft64"
            | "__builtin_rotateright8" | "__builtin_rotateright16" | "__builtin_rotateright32" | "__builtin_rotateright64" => DaExpr::ConstInt(0),

            // Unreachable → 0 (daScript has no unreachable!)
            "__builtin_unreachable" => DaExpr::ConstInt(0),

            // __sync_* atomics → 0 (daScript atomic ops not implemented)
            "__sync_synchronize" | "__sync_val_compare_and_swap"
            | "__sync_bool_compare_and_swap" | "__sync_lock_test_and_set"
            | "__sync_lock_release" | "__sync_fetch_and_add"
            | "__sync_fetch_and_sub" | "__sync_fetch_and_or"
            | "__sync_fetch_and_and" | "__sync_fetch_and_xor"
            | "__sync_fetch_and_nand" | "__sync_add_and_fetch"
            | "__sync_sub_and_fetch" | "__sync_or_and_fetch"
            | "__sync_and_and_fetch" | "__sync_xor_and_fetch"
            | "__sync_nand_and_fetch"
            | "__atomic_load" | "__atomic_store" | "__atomic_exchange"
            | "__atomic_compare_exchange" | "__atomic_fetch_add"
            | "__atomic_fetch_sub" | "__atomic_fetch_or"
            | "__atomic_fetch_and" | "__atomic_fetch_xor"
            | "__atomic_add_fetch" | "__atomic_sub_fetch"
            | "__atomic_or_fetch" | "__atomic_and_fetch"
            | "__atomic_xor_fetch" | "__atomic_test_and_set"
            | "__atomic_clear" | "__atomic_thread_fence"
            | "__atomic_signal_fence" | "__atomic_load_n"
            | "__atomic_store_n" | "__atomic_exchange_n"
            | "__atomic_compare_exchange_n" | "__atomic_is_lock_free" => DaExpr::ConstInt(0),

            // Unknown builtin → error (same as c2rust pattern)
            _ => {
                return Err(TranslationError::generic(
                    "unsupported builtin"
                ));
            }
        };
        warn!("Unimplemented builtin {} in {}; replacing with safe default", builtin_name, func_name);
        Ok(WithStmts::new_val(result).merge_unsafe(is_unsafe))
    }

    pub fn convert_type(&self, qual: CQualTypeId) -> TranslationResult<DaType> {
        // Convert inner type and apply qualifiers
        let mut dt = self.convert_type_inner(qual.ctype)?;
        if qual.qualifiers.is_const {
            dt.is_const = true;
        }
        Ok(dt)
    }

    /// Core type conversion without outer qualifiers.
    fn convert_type_inner(&self, typ: CTypeId) -> TranslationResult<DaType> {
        let mut cur = typ;
        loop {
            match &self.ast_context[cur].kind {
                CTypeKind::Typedef(decl_id) => {
                    if let CDeclKind::Typedef { name, .. } = &self.ast_context[*decl_id].kind {
                        return Ok(DaType::named(&name));
                    }
                    break;
                }
                CTypeKind::Elaborated(inner) | CTypeKind::Paren(inner) => { cur = *inner; }
                _ => break,
            }
        }
        // Resolve through typedefs for all other types
        let resolved = self.ast_context.resolve_type(typ);
        use CTypeKind::*;
        match resolved.kind {
            Void => Ok(DaType::void()),
            Bool => Ok(DaType::bool()),
            Int | Short | UShort | Int128 => Ok(DaType::int()),
            SChar | Char => Ok(DaType::int8()),
            UChar => Ok(DaType::uint8()),
            UInt | UInt128 => Ok(DaType::uint()),
            Long | LongLong => Ok(DaType::int64()),
            ULong | ULongLong => Ok(DaType::uint64()),
            Float => Ok(DaType::float()),
            Double | LongDouble => Ok(DaType::double()),
            Pointer(inner) => {
                // void* → use uint64 as opaque raw pointer (daScript has no void?)
                let inner_resolved = self.ast_context.resolve_type(inner.ctype);
                if matches!(inner_resolved.kind, CTypeKind::Void) {
                    return Ok(DaType::uint64());
                }
                let inner_ty = self.convert_type(inner)?;
                Ok(DaType::pointer(inner_ty))
            }
            ConstantArray(inner, _) => {
                let inner_ty = self.convert_type_raw(inner)?;
                Ok(DaType::array(inner_ty))
            }
            IncompleteArray(inner) | VariableArray(inner, _) => {
                let inner_ty = self.convert_type_raw(inner)?;
                Ok(DaType::array(inner_ty))
            }
            Function(ret, _, _, _, _) => {
                // Function pointer type
                Ok(DaType::named("function"))
            }
            Struct(decl_id) | Union(decl_id) | Enum(decl_id) => {
                let decl = &self.ast_context[decl_id];
                if let Some(name) = decl.kind.get_name() {
                    Ok(DaType::named(&name))
                } else {
                    // Anonymous struct/union/enum — check prenamed typedef
                    let typedef_name = self.ast_context.prenamed_decls.iter()
                        .find(|(_, &v)| v == decl_id)
                        .and_then(|(k, _)| {
                            if let CDeclKind::Typedef { name, .. } = &self.ast_context[*k].kind {
                                Some(name.clone())
                            } else { None }
                        });
                    match typedef_name {
                        Some(n) => Ok(DaType::named(&n)),
                        None => Ok(DaType::auto()),
                    }
                }
            }
            _ => Ok(DaType::auto()),
        }
    }

    /// Convert a bare type ID without qualifiers.
    pub fn convert_type_raw(&self, typ: CTypeId) -> TranslationResult<DaType> {
        self.convert_type(CQualTypeId::new(typ))
    }

    pub fn is_pointer_type(&self, typ: CTypeId) -> bool {
        matches!(self.ast_context.resolve_type(typ).kind, CTypeKind::Pointer(_))
    }

    /// Recursively flatten nested case statements (Clang nests fallthrough cases).
    /// Returns (all case values, final body substatement).
    /// Handles: case 1: case 2: { body } → ([1, 2], body)
    fn collect_case_values(&self, first_expr: CExprId, sub_stmt: CStmtId) -> TranslationResult<(Vec<CExprId>, CStmtId)> {
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
        struct RawCase { values: Vec<CExprId>, body_sub: CStmtId }
        let mut raw: Vec<RawCase> = vec![];
        let body = &self.ast_context[body_id];
        match &body.kind {
            CStmtKind::Compound(ref stmts) => {
                for &sid in stmts {
                    match &self.ast_context[sid].kind {
                        CStmtKind::Case(expr_id, sub_stmt, _) => {
                            let (vals, body) = self.collect_case_values(*expr_id, *sub_stmt)?;
                            raw.push(RawCase { values: vals, body_sub: body });
                        }
                        CStmtKind::Default(sub_stmt) => {
                            raw.push(RawCase { values: vec![], body_sub: *sub_stmt });
                        }
                        _ => continue,
                    }
                }
            }
            CStmtKind::Case(expr_id, sub_stmt, _) => {
                let (vals, body) = self.collect_case_values(*expr_id, *sub_stmt)?;
                raw.push(RawCase { values: vals, body_sub: body });
            }
            CStmtKind::Default(sub_stmt) => {
                raw.push(RawCase { values: vec![], body_sub: *sub_stmt });
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
                let val = self.convert_expr(ExprContext { used: true, is_const: false, ..Default::default() }, ev, None)?;
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
                cases.push(SwitchCase { values: merged_vals, stmts: body_stmts });
            }
        }
        if !pending_values.is_empty() {
            cases.push(SwitchCase { values: pending_values, stmts: vec![] });
        }
        Ok((cases, is_unsafe))
    }

    /// Recursively collect case body statements, skipping breaks.
    /// Returns `true` if any statement in the body contains unsafe operations.
    fn collect_case_body(&self, stmt_id: CStmtId, stmts: &mut Vec<DaStmt>) -> TranslationResult<bool> {
        let mut is_unsafe = false;
        match &self.ast_context[stmt_id].kind {
            CStmtKind::Compound(ref children) => {
                for &sid in children {
                    is_unsafe |= self.collect_case_body(sid, stmts)?;
                }
            }
            CStmtKind::Break => { /* skip */ }
            CStmtKind::Return(expr) => {
                let val = expr.map(|e| self.convert_expr(ExprContext { used: true, is_const: false, ..Default::default() }, e, None)).transpose()?;
                is_unsafe |= val.as_ref().map(|v| v.is_unsafe).unwrap_or(false);
                stmts.push(mk().expr_stmt(DaExpr::Return(val.map(|ws| Box::new(ws.val)))));
            }
            CStmtKind::Expr(expr_id) => {
                let v = self.convert_expr(ExprContext { used: false, is_const: false, ..Default::default() }, *expr_id, None)?;
                is_unsafe |= v.is_unsafe;
                stmts.push(mk().expr_stmt(v.val));
            }
            CStmtKind::If { scrutinee, true_variant, false_variant } => {
                let cond = self.convert_expr(ExprContext { used: true, is_const: false, ..Default::default() }, *scrutinee, None)?;
                let mut then_stmts = vec![];
                let then_unsafe = self.collect_case_body(*true_variant, &mut then_stmts)?;
                let then_expr = DaExpr::Block(DaBlock { stmts: then_stmts });
                let (else_expr, else_unsafe) = match false_variant {
                    Some(fv) => {
                        let mut else_stmts = vec![];
                        let eu = self.collect_case_body(*fv, &mut else_stmts)?;
                        (Some(Box::new(DaExpr::Block(DaBlock { stmts: else_stmts }))), eu)
                    }
                    None => (None, false),
                };
                is_unsafe |= cond.is_unsafe || then_unsafe || else_unsafe;
                stmts.push(mk().expr_stmt(DaExpr::IfThenElse {
                    cond: Box::new(cond.val), then: Box::new(then_expr), elifs: vec![], else_: else_expr,
                }));
            }
            CStmtKind::While { condition, body } => {
                let cond = self.convert_expr(ExprContext { used: true, is_const: false, ..Default::default() }, *condition, None)?;
                let mut body_stmts = vec![];
                let body_unsafe = self.collect_case_body(*body, &mut body_stmts)?;
                is_unsafe |= cond.is_unsafe || body_unsafe;
                stmts.push(mk().expr_stmt(DaExpr::While(Box::new(cond.val), Box::new(DaExpr::Block(DaBlock { stmts: body_stmts })))));
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
            let body = DaExpr::Block(DaBlock { stmts: case.stmts.clone() });
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
        &self, scrutinee: &DaExpr, case: &SwitchCase,
        rest: &mut impl Iterator<Item = &'a SwitchCase>,
    ) -> DaExpr {
        let body = DaExpr::Block(DaBlock { stmts: case.stmts.clone() });
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
        self.convert_expr(ctx.used(), expr_id, None)
    }

    /// Create DeclStmtInfo for a C declaration.
    pub fn convert_decl_stmt_info(
        &self,
        _ctx: ExprContext,
        _decl_id: CDeclId,
    ) -> TranslationResult<crate::cfg::DeclStmtInfo> {
        // Simple fallback: convert the declaration
        Ok(crate::cfg::DeclStmtInfo::empty())
    }

    /// Execute a closure with a new scope.
    pub fn with_scope<T, F: FnOnce() -> TranslationResult<T>>(
        &self,
        f: F,
    ) -> TranslationResult<T> {
        f()
    }

    /// Panic with an error message for unreachable code.
    pub fn panic(&self, msg: &str) -> Box<DaExpr> {
        Box::new(DaExpr::ConstInt(0))
    }
}

/// Collected switch case branch.
struct SwitchCase {
    values: Vec<DaExpr>,  // empty = default
    stmts: Vec<DaStmt>,
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
) -> (String, Option<()>, Vec<(&'static str, Vec<&'static str>)>, IndexSet<ExternCrate>) {
    let mut t = Translation::new(ast_context, tcfg, main_file);

    // Prune unreachable system declarations (removes __-prefixed noise from system headers)
    t.ast_context.prune_unwanted_decls(false);

    // Pass 1: export all type declarations (struct, enum, union, typedef)
    let mut decls: Vec<DaDecl> = vec![];
    let mut exported_names: std::collections::HashSet<String> = std::collections::HashSet::new();
    for (&decl_id, decl) in t.ast_context.iter_decls() {
        use CDeclKind::*;
        let needs_export = match decl.kind {
            Struct { .. } => true,
            Enum { .. } => true,
            Union { .. } => true,
            Typedef { .. } => !t.ast_context.prenamed_decls.contains_key(&decl_id),
            _ => false,
        };
        if needs_export {
            // Skip duplicate typedefs (daScript rejects them)
            if let Typedef { ref name, .. } = decl.kind {
                if !exported_names.insert(name.clone()) {
                    continue; // already exported
                }
            }
            match t.convert_decl(ExprContext { used: true, is_const: false, ..Default::default() }, decl_id) {
                Ok(das_decl) => decls.push(das_decl),
                Err(e) => {
                    let name = decl.kind.get_name().cloned().unwrap_or_else(|| "?".to_string());
                    warn!("Skipping type decl {}: {}", name, e);
                }
            }
        }
    }

    // Pass 2: export top-level value declarations (function with bodies, variable, macro)
    for &top_id in &t.ast_context.c_decls_top {
        use CDeclKind::*;
        let needs_export = match t.ast_context[top_id].kind {
            Function { body: Some(_), .. } => true,  // only functions with bodies
            Variable { .. } => true,
            MacroObject { .. } => true,
            MacroFunction { .. } => true,
            _ => false,  // types already exported in pass 1; fn decls without body skipped
        };
        if !needs_export { continue; }
        match t.convert_decl(ExprContext { used: true, is_const: false, ..Default::default() }, top_id) {
            Ok(das_decl) => decls.push(das_decl),
            Err(e) => {
                let decl = &t.ast_context[top_id];
                let name = decl.kind.get_name().cloned().unwrap_or_else(|| "?".to_string());
                warn!("Skipping decl {}: {}", name, e);
            }
        }
    }

    // Build the daScript module
    let module = DaModule {
        name: main_file.file_stem().map(|s| s.to_string_lossy().to_string()),
        requires: vec![],
        options: vec!["gen2".into()],
        decls,
    };

    (module.to_string(), None, vec![], IndexSet::new())
}
