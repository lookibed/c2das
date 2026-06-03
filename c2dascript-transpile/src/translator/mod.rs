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

mod literals;

pub use crate::diagnostics::{TranslationError, TranslationErrorKind};

#[derive(Clone, Debug, Default)]
pub struct FuncContext {
    name: Option<String>,
}

impl FuncContext {
    pub fn new() -> Self { Self::default() }
    pub fn enter_new(&mut self, fn_name: &str) {
        *self = Self { name: Some(fn_name.to_string()) };
    }
    pub fn get_name(&self) -> &str { self.name.as_ref().unwrap() }
}

/// Options that impact an expression and all of its subexpressions.
#[derive(Copy, Clone, Debug)]
pub struct ExprContext {
    pub used: bool,
    pub is_const: bool,
}

impl ExprContext {
    pub fn used(self) -> Self { ExprContext { used: true, ..self } }
    pub fn unused(self) -> Self { ExprContext { used: false, ..self } }
    pub fn is_used(&self) -> bool { self.used }
    pub fn is_unused(&self) -> bool { !self.used }
    pub fn const_(self) -> Self { ExprContext { is_const: true, ..self } }
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
                let inner = self.convert_type(typ.clone());
                match inner {
                    Ok(dt) if !matches!(dt.kind, DaTypeKind::Auto) => {
                        Ok(DaDecl::Alias(DaAlias { name: name.clone(), aliased_type: dt }))
                    }
                    _ => Err(TranslationError::generic("type alias not yet implemented")),
                }
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

        // Convert parameters — add `var` for pointer types (daScript needs mutable params for write access)
        let mut params = vec![];
        for param_id in parameters {
            if let CDeclKind::Variable { ref ident, typ, .. } = self.ast_context[*param_id].kind {
                let das_ty = self.convert_type(typ.clone())?;
                let is_ptr = self.is_pointer_type(typ.ctype);
                if is_ptr {
                    params.push(mk().param_mut(ident.clone(), das_ty, None));
                } else {
                    params.push(mk().param(ident.clone(), das_ty, None));
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

        let mut func = mk().fn_decl(name, params, ret_type, body_das);
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
                    let ft = self.convert_type(typ.clone())?;
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
                let v = self.convert_expr(ExprContext { used: false, is_const: false }, *expr_id, None)?;
                Ok(WithStmts { stmts: vec![], val: vec![mk().expr_stmt(v.val)], is_unsafe: v.is_unsafe })
            }
            CStmtKind::Return(expr_id) => {
                let val = expr_id
                    .map(|e| self.convert_expr(ExprContext { used: true, is_const: false }, e, None))
                    .transpose()?;
                let is_unsafe = val.as_ref().map(|v| v.is_unsafe).unwrap_or(false);
                Ok(WithStmts { stmts: vec![], val: vec![mk().expr_stmt(DaExpr::Return(val.map(|ws| Box::new(ws.val))))], is_unsafe })
            }
            CStmtKind::Decls(ref decls) => {
                let mut result = vec![];
                for &d in decls {
                    if let Ok(das_decl) = self.convert_decl(ExprContext { used: true, is_const: false }, d) {
                        result.push(DaStmt::Decl(das_decl));
                    }
                }
                Ok(WithStmts { stmts: vec![], val: result, is_unsafe: false })
            }
            CStmtKind::If { scrutinee, true_variant, false_variant } => {
                let ctx_used = ExprContext { used: true, is_const: false };
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
                let ctx_used = ExprContext { used: true, is_const: false };
                let cond = self.convert_expr(ctx_used, *condition, None)?;
                let body_ws = self.convert_stmt(*body)?;
                let body_expr = DaExpr::Block(DaBlock { stmts: body_ws.val });
                Ok(WithStmts { stmts: vec![], val: vec![mk().expr_stmt(DaExpr::While(
                    Box::new(cond.val), Box::new(body_expr)
                ))], is_unsafe: cond.is_unsafe || body_ws.is_unsafe })
            }
            CStmtKind::DoWhile { body, condition } => {
                let first_var = format!("_dw_{}", stmt_id.0);
                let ctx_used = ExprContext { used: true, is_const: false };
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
                let ctx_used = ExprContext { used: true, is_const: false };
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
                let ctx_u = ExprContext { used: true, is_const: false };
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
                        let das_op = convert_binop(*op);
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
                if matches!(cast_kind, CastKind::ArrayToPointerDecay) {
                    let inner = self.convert_expr(ctx, *expr, Some(*ty))?;
                    let idx = mk().int_lit(0);
                    return Ok(WithStmts::new_val(DaExpr::Unsafe(Box::new(
                        DaExpr::Addr(Box::new(DaExpr::Index(
                            Box::new(inner.val), Box::new(idx),
                        )))
                    ))));
                }
                self.convert_expr(ctx, *expr, Some(*ty))
            }

            ExplicitCast(ty, expr, _cast_kind, _, _) => {
                let inner = self.convert_expr(ctx, *expr, Some(*ty))?;
                let target_type = self.convert_type(ty.clone())?;
                Ok(WithStmts::new_val(DaExpr::Cast {
                    kind: das_ast::CastKind::Cast,
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

            ConstantExpr(ty, child, _value) => {
                self.convert_expr(ctx, *child, Some(*ty))
            }
            _ => Err(TranslationError::generic(
                "expr kind not yet implemented in daScript translator (catch-all)"
            )),
        }
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
                // inner is CQualTypeId — pass full qual so const propagates to pointee
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
                let val = self.convert_expr(ExprContext { used: true, is_const: false }, ev, None)?;
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
                let val = expr.map(|e| self.convert_expr(ExprContext { used: true, is_const: false }, e, None)).transpose()?;
                is_unsafe |= val.as_ref().map(|v| v.is_unsafe).unwrap_or(false);
                stmts.push(mk().expr_stmt(DaExpr::Return(val.map(|ws| Box::new(ws.val)))));
            }
            CStmtKind::Expr(expr_id) => {
                let v = self.convert_expr(ExprContext { used: false, is_const: false }, *expr_id, None)?;
                is_unsafe |= v.is_unsafe;
                stmts.push(mk().expr_stmt(v.val));
            }
            CStmtKind::If { scrutinee, true_variant, false_variant } => {
                let cond = self.convert_expr(ExprContext { used: true, is_const: false }, *scrutinee, None)?;
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
                let cond = self.convert_expr(ExprContext { used: true, is_const: false }, *condition, None)?;
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
}

/// Collected switch case branch.
struct SwitchCase {
    values: Vec<DaExpr>,  // empty = default
    stmts: Vec<DaStmt>,
}

fn convert_binop(op: CBinOp) -> &'static str {
    use CBinOp::*;
    match op {
        Add => "+",
        Subtract => "-",
        Multiply => "*",
        Divide => "/",
        Modulus => "%",
        And => "&&",
        Or => "||",
        BitAnd => "&",
        BitOr => "|",
        BitXor => "^",
        ShiftLeft => "<<",
        ShiftRight => ">>",
        EqualEqual => "==",
        NotEqual => "!=",
        Less => "<",
        Greater => ">",
        LessEqual => "<=",
        GreaterEqual => ">=",
        _ => panic!("unexpected non-binary op in convert_binop: {:?}", op),
    }
}

/// Main entry point: creates a Translation and produces a daScript module string.
pub fn translate(
    ast_context: TypedAstContext,
    tcfg: &TranspilerConfig,
    main_file: &Path,
) -> (String, Option<()>, Vec<(&'static str, Vec<&'static str>)>, IndexSet<ExternCrate>) {
    let t = Translation::new(ast_context, tcfg, main_file);

    // Process top-level declarations
    let mut decls: Vec<DaDecl> = vec![];
    for &decl_id in &t.ast_context.c_decls_top {
        match t.convert_decl(ExprContext { used: true, is_const: false }, decl_id) {
            Ok(das_decl) => decls.push(das_decl),
            Err(e) => {
                let decl = &t.ast_context[decl_id];
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
