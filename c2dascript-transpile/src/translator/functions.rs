//! Function translation — порт c2rust functions.rs + CFG pipeline
use super::runtime::{
    canonical_runtime_function, runtime_declared_arity, runtime_declares, CanonicalRuntimeFunction,
    RuntimeArgKind,
};
use super::*;
use crate::c_ast::iterators::{DFExpr, SomeId};
use crate::format_translation_err;

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
        if self.is_va_decl(decl_id)
            || (self.function_context.borrow().va_list_arg_name.is_some()
                && self.ast_context.is_va_list(typ.ctype))
        {
            return self.convert_va_list_variable(decl_id, name, init);
        }
        let das_type = self.convert_type(typ)?;
        let name = self.declare_value_name(decl_id, name);
        let init = init
            .map(|e| self.convert_expr(ctx, e, Some(typ)))
            .transpose()?
            .map(|ws| {
                let init_stmts = ws.stmts.clone();
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
                let val = if is_static && ws.is_unsafe {
                    DaExpr::Unsafe(Box::new(val))
                } else {
                    val
                };
                (init_stmts, val)
            })
            .map(|(stmts, val)| {
                // A daScript module-level variable is initialized by a single
                // expression, but a C initializer can need statements to build
                // its object — a union's storage has to be allocated and then
                // written.  Those statements become a generated initializer
                // function so the object is still built exactly once, before
                // any code observes the variable; dropping them would leave
                // the variable referring to a temporary that never existed.
                if stmts.is_empty() {
                    return val;
                }
                let init_fn = format!("c2da_ginit_{name}");
                let mut body = stmts;
                body.push(DaStmt::Expr(DaExpr::Return(Some(Box::new(val)))));
                self.hoisted_statics
                    .borrow_mut()
                    .push(DaDecl::Function(das_ast::DaFunction {
                        name: init_fn.clone(),
                        params: vec![],
                        ret_type: writable_type(das_type.clone()),
                        body: Some(DaExpr::Block(das_ast::DaBlock { stmts: body })),
                        annotations: vec![],
                        is_public: false,
                        is_unsafe: false,
                    }));
                DaExpr::Call(Box::new(DaExpr::Var(init_fn)), vec![])
            });
        // A daScript fixed array is zero-initialized by its declaration, at
        // any extent, so an uninitialized C array global needs no initializer
        // expression at all.
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
        // A `va_list` parameter is the caller's cursor over the caller's own
        // promoted-argument array, so a function that receives one takes the
        // canonical `array<C2daVaArg>` parameter exactly as a variadic function
        // does: the cursor alone would index nothing.
        let va_list_params = self.va_list_params(parameters);
        let variadic_arg_name = (is_variadic || !va_list_params.is_empty())
            .then(|| body.map(|body_id| self.register_va_decls(body_id, &va_list_params)))
            .flatten();
        // The cursors are known now, so the one thing the by-reference model
        // cannot represent — a `va_list` address that outlives the frame — is
        // diagnosed before any of the body is lowered.
        if variadic_arg_name.is_some() {
            if let Some(body_id) = body {
                self.check_va_list_address_lifetimes(body_id)?;
            }
        }

        // Convert return type for function signature
        let ret_type = ret_ctype
            .map(|q| self.convert_type(q))
            .transpose()?
            .unwrap_or(DaType::void());

        let mut params = vec![];
        let mut param_bindings = vec![];
        let mut by_value_records = vec![];
        let mut unnamed_idx = 0u32;
        for param_id in parameters {
            if let CDeclKind::Variable { ref ident, typ, .. } = self.ast_context[*param_id].kind {
                // A `va_list` parameter is a cursor record, not the pointer the
                // platform ABI decayed it to: it crosses as `var`, which is how
                // daScript passes a record by reference, so the callee's
                // `va_arg` advances the caller's cursor exactly as C does.
                if self.ast_context.is_va_list(typ.ctype) {
                    let pname = self.declare_value_name(*param_id, ident);
                    self.function_context
                        .borrow_mut()
                        .add_param_alias(ident, &pname);
                    params.push(mk().param_mut(pname, self.va_cursor_type(), None));
                    continue;
                }
                // C11 6.7.6.3p15: in determining type compatibility, "each
                // parameter declared with qualified type is taken as having
                // the unqualified version of its declared type" — a
                // parameter's *top-level* qualifier is not part of the
                // function type.  Clang follows that rule in the function type
                // and keeps the qualifier on the defining declaration, so a
                // `cbytes_t` (`const u8 *const`) parameter came out as
                // `cbytes_t const` in the definition and as plain `cbytes_t`
                // in the callback typedef the definition implements, and
                // daScript stopped accepting the one for the other.  The
                // parameter's *type* therefore drops the qualifier; whether it
                // is spelled `var` is decided from the C declaration below,
                // exactly as `convert_type::function_type_param_is_var`
                // decides it for the function type.
                let mut unqualified = typ;
                unqualified.qualifiers.is_const = false;
                let das_ty = self.convert_type(unqualified)?;
                let is_record = matches!(
                    self.ast_context.resolve_type(typ.ctype).kind,
                    CTypeKind::Struct(_) | CTypeKind::Union(_)
                );
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
                // A daScript record parameter is a reference to the caller's
                // object, so `var` on it would let the callee's writes escape.
                // C passes a record by value: the parameter is a local object
                // initialized from the argument.  The incoming reference is
                // therefore taken read-only under a name of its own, and the
                // name the body uses is declared as a copy of it.  A `const`
                // record parameter is already read-only and needs no copy.
                if self.is_by_value_record_param(typ) {
                    let incoming = self.renamer.borrow_mut().fresh();
                    params.push(mk().param(incoming.clone(), das_ty.clone(), None));
                    by_value_records.push((pname, incoming, typ, das_ty));
                } else if is_record {
                    // A `const` record parameter cannot be written at all, so
                    // it needs no copy — and it stays read-only, which is what
                    // `function_type_param_is_var` answers for it too.
                    params.push(mk().param(pname, das_ty, None));
                } else {
                    params.push(mk().param_mut(pname, das_ty, None));
                }
            }
        }
        if let Some(arg_name) = variadic_arg_name {
            params.push(mk().param_mut(arg_name, DaType::array(self.va_arg_type()), None));
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
            let mut body_stmts =
                crate::cfg::convert_function_body(self, body_id, &stmt_ids, imp_ret, ret_ctype)?;

            // The parameter copies are the first thing the function does: the
            // body already refers to them by the C parameter's name, and a
            // `goto` cannot jump ahead of index 0.
            let mut prologue = self.by_value_record_prologue(&by_value_records)?;
            prologue.append(&mut body_stmts);

            Some(DaExpr::Block(DaBlock { stmts: prologue }))
        } else {
            None
        };

        let fn_name = self.declare_value_name(decl_id, name);
        let mut func = mk().fn_decl(fn_name.as_str(), params, ret_type, body_das);
        if let DaDecl::Function(ref mut f) = func {
            // Only the translation unit's own functions are part of its API.
            // A header's `static inline` helpers (`__bswap_32` and friends, which
            // arrive with <stdio.h>) are implementation detail that happens to be
            // visible here; exporting them published names the C program never
            // defined.
            if body.is_some() && self.is_defined_in_main_file(decl_id) {
                f.annotations.push("export".into());
            }
        }
        // A C `main` is not a daslang entry point whatever its parameter list:
        // daslang calls an exported zero-argument function, and C's `main`
        // keeps the name the renamer gave it (`main_0`). In `--libc std` the
        // translator adds the wrapper that calls it, and — for a
        // `main(argc, argv)` — turns the daslang command line into a C `argv`.
        // `nostd` naming is untouched.
        if self.libc_std() && name == "main" && body.is_some() {
            self.require_std_main_wrapper(&fn_name, decl_id, parameters.len())?;
        }
        Ok(func)
    }

    /// True for a parameter C passes by value as a record object the callee
    /// may modify without the caller seeing it.
    ///
    /// A pointer parameter refers to the caller's object by design, a `const`
    /// record parameter cannot be written at all, and `va_list` is the ABI's
    /// own cursor rather than a C record — none of them is copied.
    fn is_by_value_record_param(&self, typ: CQualTypeId) -> bool {
        if typ.qualifiers.is_const || self.ast_context.is_va_list(typ.ctype) {
            return false;
        }
        matches!(
            self.ast_context.resolve_type(typ.ctype).kind,
            CTypeKind::Struct(_) | CTypeKind::Union(_)
        )
    }

    /// The declarations that turn read-only record parameters into the private
    /// local objects C says they are.
    fn by_value_record_prologue(
        &self,
        params: &[(String, String, CQualTypeId, DaType)],
    ) -> TranslationResult<Vec<DaStmt>> {
        let mut stmts = vec![];
        for (pname, incoming, ctype, das_ty) in params {
            // A storage-backed record is nothing but the address of its bytes,
            // so daScript's copy would leave the local sharing the caller's
            // object.  The callee's own object is allocated and the caller's
            // bytes copied into it, which is exactly C's by-value rule.
            if let Some(record_id) = self.storage_backed_record_of(ctype.ctype) {
                let copy = self.copy_storage_record_by_value(
                    WithStmts::new_val(DaExpr::Var(incoming.clone())),
                    Some(*ctype),
                )?;
                stmts.extend(copy.stmts);
                stmts.push(DaStmt::Var {
                    name: pname.clone(),
                    var_type: DaType::named(&self.storage_record_name(record_id)?),
                    init: Some(copy.val),
                });
                continue;
            }
            // daScript's copy duplicates scalars and inline fixed arrays, which
            // is all C asks of a record whose layout is the natural one: such a
            // record cannot contain a storage-backed member.
            stmts.push(DaStmt::Var {
                name: pname.clone(),
                var_type: writable_type(das_ty.clone()),
                init: Some(DaExpr::Var(incoming.clone())),
            });
        }
        Ok(stmts)
    }

    pub fn convert_function_call(
        &self,
        ctx: ExprContext,
        func: CExprId,
        args: &[CExprId],
        call_expr_ty: CQualTypeId,
        override_ty: Option<CQualTypeId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        if let Some(part) = self.match_vapart(func, args) {
            return self.convert_vapart(part);
        }
        if self.is_variadic_function_pointer_callee(func) {
            return Err(format_translation_err!(
                self.ast_context.display_loc(&self.ast_context[func].loc),
                "unsupported variadic ABI boundary: variadic function pointer call",
            ));
        }
        if let CExprKind::ImplicitCast(_, fexp, CastKind::BuiltinFnToFnPtr, _, _) =
            &self.ast_context[func].kind
        {
            // libc allocation is represented by a compiler-owned runtime even
            // when Clang classifies the source declaration as a builtin, and
            // so is the `--libc std` replacement table.
            if self
                .direct_call_name(*fexp)
                .as_deref()
                .and_then(canonical_runtime_function)
                .is_none()
                && self.std_libc_call(*fexp).is_none()
            {
                return self.convert_builtin_call(ctx, *fexp, args);
            }
        }
        self.reject_unknown_external_call(func)?;
        // A call through a function pointer is `invoke(f, args…)` in daScript,
        // and the callee expression is the function value itself: C's
        // decay-to-pointer and the `(*f)(…)` dereference are both identities on
        // it, so they are peeled off rather than lowered as pointer operations.
        let is_direct = self.is_direct_function_declaration(func);
        let indirect_callee = (!is_direct)
            .then(|| self.function_value_operand(func))
            .flatten();
        // A direct call names the function; the decay to a pointer that Clang
        // records around it must not become a `@@name` function *value*.
        let callee_expr_id = match (indirect_callee, is_direct) {
            (Some(value), _) => value,
            (None, true) => strip_implicit_casts(&self.ast_context, func),
            (None, false) => func,
        };
        // A direct call to a tiny `static` helper is substituted here, before
        // the callee expression is lowered: the interpreter pays one dispatch
        // per call, and the translated body of such a helper is a relooped
        // label-and-goto graph, so the call is far more expensive than the
        // expression it stands for. See `translator/inline.rs` for the rule.
        if self.inlining_enabled() && is_direct && indirect_callee.is_none() {
            if let Some(callee) = self.direct_call_decl(func) {
                let is_runtime = self
                    .direct_call_name(func)
                    .as_deref()
                    .and_then(canonical_runtime_function)
                    .is_some();
                if !is_runtime {
                    if let Some(inlined) = self.try_inline_call(ctx, callee, args, override_ty)? {
                        return Ok(inlined);
                    }
                }
            }
        }
        let func_expr = self.convert_expr(ctx.used(), callee_expr_id, None)?;
        let mut is_unsafe = func_expr.is_unsafe;
        // Runtime policy is selected from the C declaration, not from the
        // already-lowered expression: an implicit function-to-pointer cast can
        // erase the direct `DaExpr::Var` shape.
        let func_name = self
            .direct_call_name(func)
            .or_else(|| match &func_expr.val {
                DaExpr::Var(n) => Some(n.clone()),
                _ => None,
            });
        let runtime = func_name.as_deref().and_then(canonical_runtime_function);
        // The `--libc std` replacement is selected from the C declaration for
        // the same reason, and never for a symbol the translation unit defines
        // itself.
        let std_libc = self.std_libc_call(func);
        // A literal format string is checked before anything is lowered: a
        // conversion the std engine does not implement is a translation-time
        // failure, never output whose later conversions read the wrong
        // arguments.
        self.check_std_format(std_libc, args)?;
        let mut all_stmts = func_expr.stmts;
        let mut das_args = vec![];
        let mut variadic_tail = vec![];
        let arg_tys = self.call_arg_types(func);
        let is_variadic = self.is_variadic_callee(func);
        // Forwarding a `va_list` (`vprintf`-style) crosses the canonical
        // variadic ABI, not C's: the callee receives the caller's cursor and,
        // with it, the caller's own promoted-argument array.
        let forwards_va_list = arg_tys
            .iter()
            .any(|ty| self.ast_context.is_va_list(ty.ctype));
        for (idx, &arg) in args.iter().enumerate() {
            if arg_tys
                .get(idx)
                .map_or(false, |ty| self.ast_context.is_va_list(ty.ctype))
            {
                das_args.push(self.va_list_call_argument(arg)?);
                continue;
            }
            let std_arg = std_libc.and_then(|function| function.arg_kind(idx));
            let expected = arg_tys.get(idx).copied().filter(|_| {
                self.libc_memory_arg_cast(func_name.as_deref(), idx)
                    .is_none()
                    && canonical_runtime_arg_type(runtime, idx).is_none()
                    && std_arg.is_none()
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
            if let Some(runtime_arg) = canonical_runtime_arg_type(runtime, idx) {
                let lowered = self.lower_runtime_arg(arg_val, runtime_arg);
                all_stmts.extend(lowered.stmts);
                arg_val = lowered.val;
            }
            // The std replacement helpers take the same raw-address ABI.
            if let Some(std_arg) = std_arg {
                let lowered = self.lower_runtime_arg(arg_val, std_arg);
                all_stmts.extend(lowered.stmts);
                arg_val = lowered.val;
            }
            if is_variadic && idx >= arg_tys.len() {
                variadic_tail.push((arg, arg_val));
            } else if let Some((stmts, lowered_arg)) = self.bool_to_integer_cast(arg_val.clone()) {
                all_stmts.extend(stmts);
                das_args.push(lowered_arg);
            } else {
                das_args.push(arg_val);
            }
        }
        if is_variadic {
            das_args.push(DaExpr::MakeArray(
                self.pack_variadic_call_tail(0, variadic_tail)?,
            ));
        } else if forwards_va_list {
            das_args.push(self.forwarded_va_args(func)?);
        }
        let call = if let Some(function) = runtime {
            mk().call_expr(DaExpr::Var(function.target_name().to_owned()), das_args)
        } else if let Some(function) = std_libc {
            let helper = self.require_std_function(function, func)?;
            mk().call_expr(DaExpr::Var(helper.to_owned()), das_args)
        } else if indirect_callee.is_some() {
            // `invoke` is daScript's call-through-a-function-value operator.
            let mut invoke_args = vec![func_expr.val];
            invoke_args.extend(das_args);
            mk().call_expr(DaExpr::Var("invoke".to_owned()), invoke_args)
        } else {
            mk().call_expr(func_expr.val, das_args)
        };
        // The raw-memory runtime returns an address, not C's declared return
        // type. Materialize it once at the outermost pointer type demanded by
        // this expression: `(int *)malloc(...)` crosses as `uint64 -> int?`.
        let returns_raw_address =
            runtime.is_some() || std_libc.map_or(false, |f| f.returns_raw_address());
        let runtime_pointer_result_ty = returns_raw_address.then_some(()).and_then(|_| {
            override_ty
                .filter(|ty| self.is_pointer_type(ty.ctype))
                .or_else(|| {
                    self.is_pointer_type(call_expr_ty.ctype)
                        .then_some(call_expr_ty)
                })
        });
        let call = if let Some(pointer_ty) = runtime_pointer_result_ty {
            self.raw_address_to_pointer(call, self.convert_type(pointer_ty)?)
        } else {
            call
        };
        let result = if let Some(expected_ty) = override_ty {
            let ret_ty = self.convert_type(expected_ty)?;
            if runtime_pointer_result_ty == Some(expected_ty) {
                call
            } else if self.is_callable_type(expected_ty.ctype)
                || crate::convert_type::is_function_value_type(&ret_ty)
            {
                // daScript function values have no conversion syntax and need
                // none: a C function pointer only ever crosses to itself.
                call
            } else if matches!(ret_ty.kind, DaTypeKind::Pointer(_)) {
                self.abi_pointer_cast(call, ret_ty)
            } else if self.convert_type(call_expr_ty).ok().as_ref() == Some(&ret_ty) {
                // The callee already returns this very type, so C asks for no
                // conversion at all.  Emitting one anyway is at best noise and
                // at worst impossible: a C `_Bool` function reaching a `_Bool`
                // use-site would come out as `bool(f())`, and daScript has no
                // `bool` conversion function of any kind.
                call
            } else {
                // A C enumeration return type crossing into an enumeration
                // use-site is a reinterpretation, not a conversion; every
                // other target is the plain numeric conversion.
                self.cast_to_type(call, ret_ty)
            }
        } else {
            call
        };
        Ok(WithStmts::new_val(result)
            .prepend_stmts(all_stmts)
            .merge_unsafe(is_unsafe))
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

    fn is_variadic_callee(&self, func: CExprId) -> bool {
        let mut func = func;
        while let CExprKind::ImplicitCast(_, inner, _, _, _) = &self.ast_context[func].kind {
            func = *inner;
        }
        let CExprKind::DeclRef(_, decl_id, _) = self.ast_context[func].kind else { return false; };
        let CDeclKind::Function { typ, .. } = self.ast_context[decl_id].kind else { return false; };
        matches!(
            self.ast_context.resolve_type(typ).kind,
            CTypeKind::Function(_, _, true, _, _)
        )
    }

    fn is_variadic_function_pointer_callee(&self, func: CExprId) -> bool {
        // A direct reference to a variadic C declaration is represented by
        // Clang as an implicit function-to-pointer conversion at the call
        // site.  That is still our supported direct ABI boundary.  Only an
        // actual indirect expression (variable, field, dereference, etc.)
        // is the unsupported function-pointer boundary.
        if self.is_direct_function_declaration(func) {
            return false;
        }
        let Some(ty) = self.ast_context[func].kind.get_qual_type() else { return false; };
        let CTypeKind::Pointer(pointee) = self.ast_context.resolve_type(ty.ctype).kind else { return false; };
        matches!(
            self.ast_context.resolve_type(pointee.ctype).kind,
            CTypeKind::Function(_, _, true, _, _)
        )
    }

    /// The only source-call boundary conversions for the canonical raw-memory
    /// runtime.  Keeping them here prevents type repair from leaking to the
    /// printer or into each individual libc special case.
    fn lower_runtime_arg(&self, arg: DaExpr, kind: RuntimeArgKind) -> WithStmts<DaExpr> {
        match kind {
            RuntimeArgKind::UInt64 => {
                WithStmts::new_val(self.integer_literal_for_type(arg, DaType::uint64()))
            }
            // `memmove(sp + returnSlots, sp + stackOffset, n)`: the raw address
            // of a pointer sum is read as an integer, which the daslang
            // interpreter cannot do in place, so the pointer is named first
            // (see `Translation::named_pointer_value`).
            RuntimeArgKind::RawAddress => self
                .named_pointer_value(arg, None)
                .map(|pointer| self.pointer_to_raw_address(pointer)),
            RuntimeArgKind::UInt8 => {
                WithStmts::new_val(self.integer_literal_for_type(arg, DaType::uint8()))
            }
        }
    }

    pub(crate) fn direct_call_name(&self, func: CExprId) -> Option<String> {
        let mut func = func;
        while let CExprKind::ImplicitCast(_, inner, _, _, _) = &self.ast_context[func].kind {
            func = *inner;
        }
        let CExprKind::DeclRef(_, decl_id, _) = &self.ast_context[func].kind else {
            return None;
        };
        self.ast_context[*decl_id].kind.get_name().cloned()
    }

    /// True when this declaration comes from the translation unit's own source
    /// file rather than from an included header.
    ///
    /// If the main file cannot be located in the source map the answer is `true`:
    /// mislabelling every function as external would be a far worse failure than
    /// exporting a few header helpers.
    fn is_defined_in_main_file(&self, decl_id: CDeclId) -> bool {
        let Some(main_file_id) = self.ast_context.find_file_id(&self.main_file) else {
            return true;
        };
        self.ast_context
            .file_id(&self.ast_context[decl_id])
            .map_or(true, |file_id| file_id == main_file_id)
    }

    /// The daScript name of the function a value-position expression names, if
    /// it names one directly (`add`, `(add)`, `*add`, …).
    pub(crate) fn direct_function_reference(&self, expr: CExprId) -> Option<String> {
        let mut current = expr;
        loop {
            match &self.ast_context[current].kind {
                CExprKind::Paren(_, inner) => current = *inner,
                CExprKind::ImplicitCast(_, inner, CastKind::FunctionToPointerDecay, _, _)
                | CExprKind::ImplicitCast(_, inner, CastKind::LValueToRValue, _, _) => {
                    current = *inner
                }
                CExprKind::Unary(_, CUnOp::Deref, inner, _) => current = *inner,
                CExprKind::DeclRef(_, decl_id, _) => {
                    let CDeclKind::Function { ref name, .. } = self.ast_context[*decl_id].kind
                    else {
                        return None;
                    };
                    return Some(self.declare_value_name(*decl_id, name));
                }
                _ => return None,
            }
        }
    }

    /// Peel the C conversions that only exist because C has no function values.
    ///
    /// `f(…)`, `(*f)(…)` and `(**f)(…)` all call the same object; Clang spells
    /// them as a decay-to-pointer over zero or more dereferences of an lvalue.
    /// daScript's `function<…>` *is* the value, so every one of those layers is
    /// an identity.  Returns the expression that actually holds the function
    /// value, or `None` when this is not a function-pointer callee at all.
    ///
    /// What decides the answer is the *type* the callee expression carries,
    /// never how many identity layers were peeled off it.  daScript calls a
    /// `function<…>` value only through `invoke`, so every callee that is not a
    /// direct function declaration has to reach that operator — a variable, a
    /// dereference, a cast (`((Op)(*pc))(…)`, an interpreter's whole dispatch),
    /// a struct field, an array element or a conditional alike.  Requiring a
    /// peel here once made an unpeeled callee such as a cast or a conditional
    /// come out as a call by juxtaposition, which daScript cannot parse.
    fn function_value_operand(&self, func: CExprId) -> Option<CExprId> {
        let mut current = func;
        loop {
            match &self.ast_context[current].kind {
                CExprKind::ImplicitCast(_, inner, CastKind::FunctionToPointerDecay, _, _)
                | CExprKind::ImplicitCast(_, inner, CastKind::LValueToRValue, _, _) => {
                    current = *inner;
                }
                // `*f` is an identity only when it yields a *function*: that is
                // C's rule that dereferencing a function pointer gives back the
                // function designator, which is why `f`, `(*f)` and `(**f)` all
                // call the same object.  A dereference that yields another
                // pointer — `Unary *slot; (*slot)(x)` — is a real load out of
                // the caller's memory and has to be lowered as one.
                CExprKind::Unary(_, CUnOp::Deref, inner, _)
                    if self.yields_function_designator(current) =>
                {
                    current = *inner;
                }
                CExprKind::Paren(_, inner) => {
                    current = *inner;
                }
                _ => break,
            }
        }
        // The remaining expression must still be a function pointer (or a
        // function): anything else means we peeled through a real C pointer.
        let is_callable = self.ast_context[current]
            .kind
            .get_qual_type()
            .map(|ty| self.is_callable_type(ty.ctype))
            .unwrap_or(false);
        is_callable.then_some(current)
    }

    /// True when this expression's own C type is a function type, i.e. it is a
    /// function designator rather than a pointer to one.
    fn yields_function_designator(&self, expr: CExprId) -> bool {
        self.ast_context[expr]
            .kind
            .get_qual_type()
            .map_or(false, |ty| {
                matches!(
                    self.ast_context.resolve_type(ty.ctype).kind,
                    CTypeKind::Function(..)
                )
            })
    }

    /// True for a C function type or a pointer to one.
    pub(crate) fn is_callable_type(&self, ctype: CTypeId) -> bool {
        match self.ast_context.resolve_type(ctype).kind {
            CTypeKind::Function(..) => true,
            CTypeKind::Pointer(inner) => matches!(
                self.ast_context.resolve_type(inner.ctype).kind,
                CTypeKind::Function(..)
            ),
            _ => false,
        }
    }

    /// Reject a direct call to a C function that this translation unit neither
    /// defines nor lowers to the compiler-owned runtime.
    ///
    /// Emitting the bare call anyway produced daScript that names a function
    /// which does not exist — a link error at best, and silently different
    /// behaviour whenever daScript happened to have a name of its own.
    fn reject_unknown_external_call(&self, func: CExprId) -> TranslationResult<()> {
        let mut callee = func;
        while let CExprKind::ImplicitCast(_, inner, _, _, _) = &self.ast_context[callee].kind {
            callee = *inner;
        }
        let CExprKind::DeclRef(_, decl_id, _) = self.ast_context[callee].kind else {
            return Ok(());
        };
        let CDeclKind::Function {
            ref name,
            body,
            ref parameters,
            ..
        } = self.ast_context[decl_id].kind
        else {
            return Ok(());
        };
        if body.is_some() || canonical_runtime_function(name).is_some() {
            return Ok(());
        }
        // `--libc std` replaces a fixed table of libc entry points with
        // translator-emitted daslang helpers. Everything outside that table is
        // still an unsupported external call, in every mode.
        if self.std_libc_call(func).is_some() {
            return Ok(());
        }
        // The compiler-owned runtime is part of every generated module, so a
        // translation unit is allowed to declare one of its entry points (the
        // explicit runtime API, e.g. `c2da_rt_reset`) and call it directly.
        // The declaration must still describe the function that will actually
        // be emitted, otherwise the generated call would not type-check.
        if runtime_declares(name) {
            let runtime_arity =
                runtime_declared_arity(name).expect("runtime declares a function by this name");
            if parameters.len() == runtime_arity {
                return Ok(());
            }
            return Err(format_translation_err!(
                self.ast_context.display_loc(&self.ast_context[func].loc),
                "declared C prototype does not match runtime function {}: \
                 declared {} parameter(s), runtime takes {}",
                name,
                parameters.len(),
                runtime_arity,
            ));
        }
        // A declaration without a body may still be defined elsewhere in this
        // translation unit; `body` is only set on the defining declaration.
        if self.ast_context.iter_decls().any(|(_, decl)| {
            matches!(&decl.kind, CDeclKind::Function { name: other, body: Some(_), .. }
                if other == name)
        }) {
            return Ok(());
        }
        Err(format_translation_err!(
            self.ast_context.display_loc(&self.ast_context[func].loc),
            "unsupported external call: {}",
            name,
        ))
    }

    fn is_direct_function_declaration(&self, func: CExprId) -> bool {
        let mut func = func;
        while let CExprKind::ImplicitCast(_, inner, _, _, _) = &self.ast_context[func].kind {
            func = *inner;
        }
        let CExprKind::DeclRef(_, decl_id, _) = self.ast_context[func].kind else {
            return false;
        };
        matches!(self.ast_context[decl_id].kind, CDeclKind::Function { .. })
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

/// Drop the implicit conversions Clang records around an expression.
pub(crate) fn strip_implicit_casts(ast_context: &TypedAstContext, expr: CExprId) -> CExprId {
    let mut current = expr;
    while let CExprKind::ImplicitCast(_, inner, _, _, _) = &ast_context[current].kind {
        current = *inner;
    }
    current
}

fn canonical_runtime_arg_type(
    runtime: Option<CanonicalRuntimeFunction>,
    idx: usize,
) -> Option<RuntimeArgKind> {
    runtime.and_then(|function| function.arg_kind(idx))
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

/// The value a hoisted declaration starts with: a record's constructor call,
/// otherwise the type's zero.  Shared with `cfg::labels`, which hoists the
/// statement lowering's site temporaries the same way.
pub(crate) fn default_initializer_for_datype(ty: &DaType) -> DaExpr {
    // A daScript function value is spelled `function<…>`, which is a named
    // *type expression* and not a constructible record: `function<…>()` is a
    // syntax error.  Its null value is `default<function<…>>`, which
    // `zero_for_datype` already knows how to spell.
    if crate::convert_type::is_function_value_type(ty) {
        return zero_for_datype(ty);
    }
    match &ty.kind {
        DaTypeKind::Named(name) => DaExpr::Call(Box::new(DaExpr::Var(name.clone())), vec![]),
        _ => zero_for_datype(ty),
    }
}
