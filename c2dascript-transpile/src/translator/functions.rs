//! Function translation — порт c2rust functions.rs + CFG pipeline
use super::*;
use crate::c_ast::iterators::{DFExpr, SomeId};

/// Names provided by the canonical daScript raw-memory runtime.  A source C
/// symbol is mapped here only after its runtime AST implementation exists.
fn canonical_runtime_function(name: &str) -> Option<&'static str> {
    match name {
        "malloc" | "__builtin_malloc" => Some("c2da_rt_malloc"),
        "calloc" | "__builtin_calloc" => Some("c2da_rt_calloc"),
        "realloc" | "__builtin_realloc" => Some("c2da_rt_realloc"),
        "free" | "__builtin_free" => Some("c2da_rt_free"),
        "memset" | "__builtin_memset" => Some("c2da_rt_memset"),
        "memcpy" | "__builtin_memcpy" => Some("c2da_rt_memcpy"),
        "memmove" | "__builtin_memmove" => Some("c2da_rt_memmove"),
        "memcmp" | "__builtin_memcmp" => Some("c2da_rt_memcmp"),
        "memchr" | "__builtin_memchr" => Some("c2da_rt_memchr"),
        _ => None,
    }
}

impl<'c> Translation<'c> {
    pub fn convert_variable(
        &self,
        ctx: ExprContext,
        decl_id: CDeclId,
        name: &str,
        typ: CQualTypeId,
        init: Option<CExprId>,
        is_static: bool,
    ) -> TranslationResult<DaDecl> {
        let das_type = self.convert_type(typ)?;
        let init = init
            .map(|e| self.convert_expr(ctx, e, Some(typ)))
            .transpose()?
            .map(|ws| {
                let init_val = normalize_array_initializer_for_type(ws.val, &das_type);
                let val = if matches!(das_type.kind, DaTypeKind::Pointer(_))
                    && !matches!(init_val, DaExpr::ConstNull)
                    && Self::infer_type(&init_val).map_or(true, |inferred| inferred != das_type)
                {
                    self.abi_pointer_cast(init_val, das_type.clone())
                } else if das_type.is_numeric()
                    && Self::infer_type(&init_val).map_or(true, |inferred| inferred != das_type)
                {
                    let mut to = das_type.clone();
                    to.is_const = false;
                    to.is_ref = false;
                    to.is_temporary = false;
                    DaExpr::Cast {
                        kind: das_ast::CastKind::Cast,
                        expr: Box::new(init_val),
                        to,
                    }
                } else {
                    init_val
                };
                if is_static && ws.is_unsafe {
                    DaExpr::Unsafe(Box::new(val))
                } else {
                    val
                }
            });
        let init = init.or_else(|| {
            let r = self.ast_context.resolve_type(typ.ctype);
            if let CTypeKind::ConstantArray(inner, size) = &r.kind {
                if *size > 0 && *size <= 10000 {
                    let elem_ty = type_kind_to_datype(&self.ast_context.resolve_type(*inner).kind);
                    let zero = if matches!(elem_ty.kind, DaTypeKind::Int) {
                        DaExpr::ConstInt(0)
                    } else {
                        DaExpr::Cast {
                            kind: das_ast::CastKind::Cast,
                            expr: Box::new(DaExpr::ConstInt(0)),
                            to: elem_ty,
                        }
                    };
                    return Some(DaExpr::MakeArray(vec![zero; *size]));
                }
            }
            None
        });
        let name = self.declare_value_name(decl_id, name);
        Ok(DaDecl::Variable(DaVariable {
            name,
            var_type: das_type,
            init,
            annotations: vec![],
        }))
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

        let (ret_ctype, is_variadic): (Option<CQualTypeId>, bool) =
            match self.ast_context.resolve_type(typ).kind {
                CTypeKind::Function(ret, _, is_var, is_noreturn, _) => {
                    (if is_noreturn { None } else { Some(ret) }, is_var)
                }
                _ => return Err(TranslationError::generic("not a function type")),
            };
        self.function_context
            .borrow_mut()
            .set_return_type(ret_ctype);

        // Convert return type for function signature
        let ret_type = ret_ctype
            .map(|q| self.convert_type(q))
            .transpose()?
            .unwrap_or(DaType::void());

        let mut params = vec![];
        let mut param_bindings = vec![];
        let mut unnamed_idx = 0u32;
        for param_id in parameters {
            if let CDeclKind::Variable { ref ident, typ, .. } = self.ast_context[*param_id].kind {
                let das_ty = self.convert_type(typ.clone())?;
                let is_const = typ.qualifiers.is_const;
                let is_ptr = self.is_pointer_type(typ.ctype);
                let pname = if ident.is_empty() || ident == "__" {
                    unnamed_idx += 1;
                    self.declare_value_name(*param_id, &format!("c2da_arg{}", unnamed_idx))
                } else {
                    self.declare_value_name(*param_id, ident)
                };
                self.function_context
                    .borrow_mut()
                    .add_param_alias(ident, &pname);
                param_bindings.push((*param_id, ident.clone(), typ, pname.clone()));
                if is_ptr || !is_const {
                    params.push(mk().param_mut(pname, das_ty, None));
                } else {
                    params.push(mk().param(pname, das_ty, None));
                }
            }
        }
        if let Some(body_id) = body {
            self.add_definition_param_aliases(body_id, &param_bindings);
        }

        let body_das = if let Some(body_id) = body {
            // Determine implicit return type
            let is_main = name == "main";
            let is_void = ret_ctype
                .map(|qty| self.ast_context[qty.ctype].kind == CTypeKind::Void)
                .unwrap_or(true);
            let imp_ret = if is_void {
                crate::cfg::ImplicitReturnType::Void
            } else if is_main {
                crate::cfg::ImplicitReturnType::Main
            } else {
                crate::cfg::ImplicitReturnType::NoImplicitReturnType
            };

            // Extract compound statement children
            let stmt_ids = match self.ast_context[body_id].kind {
                CStmtKind::Compound(ref stmts) => stmts.clone(),
                _ => vec![body_id],
            };

            // Run through CFG pipeline
            let body_stmts =
                crate::cfg::convert_function_body(self, body_id, &stmt_ids, imp_ret, ret_ctype)?;

            Some(DaExpr::Block(DaBlock { stmts: body_stmts }))
        } else {
            None
        };

        let fn_name = self.declare_value_name(decl_id, name);
        let mut func = mk().fn_decl(fn_name.as_str(), params, ret_type, body_das);
        if let DaDecl::Function(ref mut f) = func {
            if body.is_some() {
                f.annotations.push("export".into());
            }
        }
        Ok(func)
    }

    pub fn convert_function_call(
        &self,
        ctx: ExprContext,
        func: CExprId,
        args: &[CExprId],
        call_expr_ty: CQualTypeId,
        override_ty: Option<CQualTypeId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        if let CExprKind::ImplicitCast(_, fexp, CastKind::BuiltinFnToFnPtr, _, _) =
            &self.ast_context[func].kind
        {
            // libc allocation is represented by a compiler-owned runtime even
            // when Clang classifies the source declaration as a builtin.
            if self
                .direct_call_name(*fexp)
                .as_deref()
                .and_then(canonical_runtime_function)
                .is_none()
            {
                return self.convert_builtin_call(ctx, *fexp, args);
            }
        }
        let func_expr = self.convert_expr(ctx.used(), func, None)?;
        let mut is_unsafe = func_expr.is_unsafe;
        // Runtime policy is selected from the C declaration, not from the
        // already-lowered expression: an implicit function-to-pointer cast can
        // erase the direct `DaExpr::Var` shape.
        let func_name = self.direct_call_name(func).or_else(|| match &func_expr.val {
            DaExpr::Var(n) => Some(n.clone()),
            _ => None,
        });
        let runtime_name = func_name
            .as_deref()
            .and_then(canonical_runtime_function);
        let mut all_stmts = func_expr.stmts;
        let mut das_args = vec![];
        let arg_tys = self.call_arg_types(func);
        for (idx, &arg) in args.iter().enumerate() {
            let expected = arg_tys
                .get(idx)
                .copied()
                .filter(|_| {
                    self.libc_memory_arg_cast(func_name.as_deref(), idx).is_none()
                        && canonical_runtime_arg_type(runtime_name, idx).is_none()
                });
            let a = self.convert_expr(ctx, arg, expected)?;
            let a = if let Some(expected_ty) = expected {
                self.lower_to_c_value(
                    a,
                    self.ast_context[arg].kind.get_qual_type(),
                    self.convert_type(expected_ty)?,
                    ValueSite::CallArg,
                )?
            } else {
                a
            };
            is_unsafe |= a.is_unsafe;
            all_stmts.extend(a.stmts);
            let mut arg_val = a.val;
            if let Some(to) = self.libc_memory_arg_cast(func_name.as_deref(), idx) {
                arg_val = DaExpr::Cast {
                    kind: das_ast::CastKind::Cast,
                    expr: Box::new(arg_val),
                    to,
                };
            } else if let Some(expected_ty) = expected {
                let expected_da = self.convert_type(expected_ty)?;
                if matches!(expected_da.kind, DaTypeKind::Pointer(_))
                    && !matches!(arg_val, DaExpr::ConstNull)
                    && Self::infer_type(&arg_val).map_or(true, |actual| actual != expected_da)
                {
                    arg_val = self.abi_pointer_cast(arg_val, expected_da);
                }
            }
            // Canonical runtime ABI is raw-address/uint64 based.  This cast is
            // constructed before the daScript AST reaches the printer.
            if let Some(runtime_arg) = canonical_runtime_arg_type(runtime_name, idx) {
                arg_val = self.lower_runtime_arg(arg_val, runtime_arg);
            }
            if let Some((stmts, lowered_arg)) = self.lower_bool_numeric_cast_arg(arg_val.clone()) {
                all_stmts.extend(stmts);
                das_args.push(lowered_arg);
            } else {
                das_args.push(arg_val);
            }
        }
        let call_target = runtime_name
            .map(|name| DaExpr::Var(name.to_owned()))
            .unwrap_or(func_expr.val);
        let call = mk().call_expr(call_target, das_args);
        // The raw-memory runtime returns an address, not C's declared return
        // type. Materialize it once at the outermost pointer type demanded by
        // this expression: `(int *)malloc(...)` crosses as `uint64 -> int?`.
        let runtime_pointer_result_ty = runtime_name.and_then(|_| {
            override_ty
                .filter(|ty| self.is_pointer_type(ty.ctype))
                .or_else(|| self.is_pointer_type(call_expr_ty.ctype).then_some(call_expr_ty))
        });
        let call = if let Some(pointer_ty) = runtime_pointer_result_ty {
            self.abi_raw_address_to_pointer(call, self.convert_type(pointer_ty)?)
        } else {
            call
        };
        let result = if let Some(expected_ty) = override_ty {
            let ret_ty = self.convert_type(expected_ty)?;
            if runtime_pointer_result_ty == Some(expected_ty) {
                call
            } else if matches!(ret_ty.kind, DaTypeKind::Pointer(_)) {
                self.abi_pointer_cast(call, ret_ty)
            } else {
                DaExpr::Cast {
                    kind: das_ast::CastKind::Cast,
                    expr: Box::new(call),
                    to: ret_ty,
                }
            }
        } else {
            call
        };
        Ok(WithStmts::new_val(result)
            .prepend_stmts(all_stmts)
            .merge_unsafe(is_unsafe))
    }

    pub(crate) fn lower_bool_numeric_cast_arg(
        &self,
        expr: DaExpr,
    ) -> Option<(Vec<DaStmt>, DaExpr)> {
        let DaExpr::Cast { kind, expr, to } = expr else {
            return None;
        };
        let bool_expr = unwrap_numeric_casts(expr);
        if kind != das_ast::CastKind::Cast
            || !to.is_numeric()
            || matches!(to.kind, DaTypeKind::Bool)
            || !Self::infer_type(&bool_expr).map_or(false, |ty| matches!(ty.kind, DaTypeKind::Bool))
        {
            return None;
        }

        let tmp = self.renamer.borrow_mut().fresh();
        let one = DaExpr::Cast {
            kind: das_ast::CastKind::Cast,
            expr: Box::new(DaExpr::ConstInt(1)),
            to: to.clone(),
        };
        let zero = DaExpr::Cast {
            kind: das_ast::CastKind::Cast,
            expr: Box::new(DaExpr::ConstInt(0)),
            to: to.clone(),
        };
        let stmts = vec![
            DaStmt::Var {
                name: tmp.clone(),
                var_type: to,
                init: Some(zero.clone()),
            },
            mk().expr_stmt(DaExpr::IfThenElse {
                cond: Box::new(bool_expr),
                then: Box::new(DaExpr::Block(DaBlock {
                    stmts: vec![DaStmt::Expr(DaExpr::Assign(
                        Box::new(DaExpr::Var(tmp.clone())),
                        Box::new(one),
                    ))],
                })),
                elifs: vec![],
                else_: None,
            }),
        ];
        Some((stmts, DaExpr::Var(tmp)))
    }

    /// daScript has no scalar `bool -> int` conversion.  Materialize the C
    /// value as `0` or `1` before an enclosing expression consumes it.
    ///
    /// This operates on an already-built AST cast so every owner of a numeric
    /// coercion (calls, explicit casts, and binary operators) shares the same
    /// lowering and preserves the operand's evaluation order.
    pub(crate) fn lower_bool_numeric_cast(
        &self,
        value: WithStmts<DaExpr>,
    ) -> WithStmts<DaExpr> {
        let is_unsafe = value.is_unsafe;
        let mut stmts = value.stmts;
        let expr = value.val;
        if let Some((lowered_stmts, lowered_val)) = self.lower_bool_numeric_cast_arg(expr.clone()) {
            stmts.extend(lowered_stmts);
            WithStmts::new(stmts, lowered_val).merge_unsafe(is_unsafe)
        } else {
            WithStmts::new(stmts, expr).merge_unsafe(is_unsafe)
        }
    }

    pub(crate) fn call_arg_types(&self, func: CExprId) -> Vec<CQualTypeId> {
        let func = match &self.ast_context[func].kind {
            CExprKind::ImplicitCast(_, inner, _, _, _) => *inner,
            _ => func,
        };
        let CExprKind::DeclRef(_, decl_id, _) = &self.ast_context[func].kind else {
            return vec![];
        };
        let CDeclKind::Function { parameters, .. } = &self.ast_context[*decl_id].kind else {
            return vec![];
        };
        parameters
            .iter()
            .filter_map(|param| match &self.ast_context[*param].kind {
                CDeclKind::Variable { typ, .. } => Some(*typ),
                _ => None,
            })
            .collect()
    }

    /// The only source-call boundary conversions for the canonical raw-memory
    /// runtime.  Keeping them here prevents type repair from leaking to the
    /// printer or into each individual libc special case.
    fn lower_runtime_arg(&self, arg: DaExpr, kind: RuntimeArgType) -> DaExpr {
        match kind {
            RuntimeArgType::UInt64 => integer_literal_for_type(arg, DaType::uint64()),
            RuntimeArgType::RawAddress => self.abi_pointer_to_raw_address(arg),
            RuntimeArgType::UInt8 => integer_literal_for_type(arg, DaType::uint8()),
        }
    }

    fn direct_call_name(&self, func: CExprId) -> Option<String> {
        let mut func = func;
        while let CExprKind::ImplicitCast(_, inner, _, _, _) = &self.ast_context[func].kind {
            func = *inner;
        }
        let CExprKind::DeclRef(_, decl_id, _) = &self.ast_context[func].kind else {
            return None;
        };
        self.ast_context[*decl_id].kind.get_name().cloned()
    }

    pub(crate) fn libc_memory_arg_cast(
        &self,
        func_name: Option<&str>,
        idx: usize,
    ) -> Option<DaType> {
        if idx != 2 || !matches!(func_name, Some("memset" | "memcpy" | "memmove")) {
            return None;
        }
        Some(DaType::uint64())
    }

    pub fn convert_function_param(
        &self,
        _ctx: ExprContext,
        typ: CQualTypeId,
    ) -> TranslationResult<DaType> {
        if self.ast_context.is_va_list(typ.ctype) {
            return Ok(DaType::uint64());
        }
        self.convert_type(typ)
    }

    pub fn convert_call_args(
        &self,
        ctx: ExprContext,
        exprs: &[CExprId],
        arg_tys: Option<&[CQualTypeId]>,
        _is_variadic: bool,
    ) -> TranslationResult<WithStmts<Vec<DaExpr>>> {
        let arg_tys = arg_tys.unwrap_or(&[]);
        exprs
            .iter()
            .enumerate()
            .map(|(n, arg)| self.convert_call_arg(ctx, *arg, arg_tys.get(n).copied()))
            .collect()
    }
    fn convert_call_arg(
        &self,
        ctx: ExprContext,
        expr_id: CExprId,
        override_ty: Option<CQualTypeId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        self.convert_expr(ctx, expr_id, override_ty)
    }

    fn add_definition_param_aliases(
        &self,
        body_id: CStmtId,
        param_bindings: &[(CDeclId, String, CQualTypeId, String)],
    ) {
        if param_bindings.is_empty() {
            return;
        }

        let local_decls: IndexSet<CDeclId> = DFExpr::new(&self.ast_context, body_id.into())
            .filter_map(SomeId::stmt)
            .flat_map(|sid| match &self.ast_context[sid].kind {
                CStmtKind::Decls(decls) => decls.clone(),
                _ => vec![],
            })
            .collect();

        let mut candidates = vec![];
        let mut seen = IndexSet::new();
        for expr_id in DFExpr::new(&self.ast_context, body_id.into()).filter_map(SomeId::expr) {
            if let CExprKind::DeclRef(_, decl_id, _) = self.ast_context[expr_id].kind {
                if local_decls.contains(&decl_id) || !seen.insert(decl_id) {
                    continue;
                }
                if let CDeclKind::Variable { ref ident, typ, .. } = self.ast_context[decl_id].kind {
                    if !ident.is_empty() {
                        candidates.push((decl_id, ident.clone(), typ));
                    }
                }
            }
        }

        let mut used_candidates = IndexSet::new();
        for (_param_id, param_ident, param_ty, pname) in param_bindings {
            if !param_ident.starts_with("__") && !param_ident.is_empty() {
                continue;
            }
            if let Some((decl_id, ident, _)) = candidates.iter().find(|(decl_id, ident, typ)| {
                !used_candidates.contains(decl_id)
                    && ident != param_ident
                    && typ.ctype == param_ty.ctype
            }) {
                used_candidates.insert(*decl_id);
                self.function_context
                    .borrow_mut()
                    .add_param_alias(ident, pname);
            }
        }
    }
}

fn integer_literal_for_type(expr: DaExpr, target: DaType) -> DaExpr {
    let base = strip_numeric_literal_casts(expr);
    DaExpr::Cast {
        kind: das_ast::CastKind::Cast,
        expr: Box::new(base),
        to: target,
    }
}

fn strip_numeric_literal_casts(expr: DaExpr) -> DaExpr {
    match expr {
        DaExpr::Cast {
            kind: das_ast::CastKind::Cast,
            expr,
            to,
        } if to.is_numeric() => {
            let inner = strip_numeric_literal_casts(*expr);
            if matches!(inner, DaExpr::ConstInt(_) | DaExpr::ConstUInt(_)) {
                inner
            } else {
                DaExpr::Cast {
                    kind: das_ast::CastKind::Cast,
                    expr: Box::new(inner),
                    to,
                }
            }
        }
        expr => expr,
    }
}

/// C may carry a comparison through one or more integral identity casts even
/// though daScript represents the comparison itself as bool.  Peel only those
/// numeric casts so bool-to-number lowering owns the final conversion.
fn unwrap_numeric_casts(mut expr: Box<DaExpr>) -> DaExpr {
    loop {
        match *expr {
            DaExpr::Cast {
                kind: das_ast::CastKind::Cast,
                expr: inner,
                to,
            } if to.is_numeric() && !matches!(to.kind, DaTypeKind::Bool) => expr = inner,
            other => return other,
        }
    }
}

#[derive(Clone, Copy)]
enum RuntimeArgType {
    UInt64,
    RawAddress,
    UInt8,
}

fn canonical_runtime_arg_type(runtime_name: Option<&str>, idx: usize) -> Option<RuntimeArgType> {
    match (runtime_name, idx) {
        (Some("c2da_rt_malloc"), 0)
        | (Some("c2da_rt_calloc"), 0 | 1)
        | (Some("c2da_rt_realloc"), 1)
        | (Some("c2da_rt_memset" | "c2da_rt_memcpy" | "c2da_rt_memmove" | "c2da_rt_memcmp" | "c2da_rt_memchr"), 2) => Some(RuntimeArgType::UInt64),
        (Some("c2da_rt_realloc" | "c2da_rt_free"), 0)
        | (Some("c2da_rt_memset" | "c2da_rt_memchr"), 0)
        | (Some("c2da_rt_memcpy" | "c2da_rt_memmove" | "c2da_rt_memcmp"), 0 | 1) => Some(RuntimeArgType::RawAddress),
        (Some("c2da_rt_memset" | "c2da_rt_memchr"), 1) => Some(RuntimeArgType::UInt8),
        _ => None,
    }
}

pub(crate) fn normalize_array_initializer_for_type(expr: DaExpr, ty: &DaType) -> DaExpr {
    let DaTypeKind::Array(elem_ty) = &ty.kind else {
        return expr;
    };
    let DaExpr::MakeArray(items) = expr else {
        return expr;
    };
    DaExpr::MakeArray(
        items
            .into_iter()
            .map(|item| {
                if is_zero_initializer_expr(&item) {
                    default_initializer_for_datype(elem_ty.as_ref())
                } else {
                    item
                }
            })
            .collect(),
    )
}

fn default_initializer_for_datype(ty: &DaType) -> DaExpr {
    match &ty.kind {
        DaTypeKind::Named(name) => DaExpr::Call(Box::new(DaExpr::Var(name.clone())), vec![]),
        _ => zero_for_datype(ty),
    }
}
