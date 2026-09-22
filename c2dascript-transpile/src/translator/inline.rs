//! Inlining of tiny `static` C helper functions.
//!
//! The daslang interpreter pays one call dispatch per invocation, and a C
//! helper such as pl_mpeg's
//!
//! ```c
//! static inline uint8_t plm_clamp(int n) {
//!     if (n > 255) { n = 255; }
//!     else if (n < 0) { n = 0; }
//!     return n;
//! }
//! ```
//!
//! is called once per output RGB byte — 19.35 M times for seven 720p frames.
//! A native compiler folds it into two `cmov`s; the interpreter cannot, and
//! the translated body is worse still, because a C function body crosses
//! through the CFG relooper and comes out as labels and `goto`s.
//!
//! daslang 0.6.4 does have an `[inline]` function annotation, but it is a
//! *fail-closed* contract that rejects a body containing `goto` — exactly what
//! the relooper emits — so the annotation cannot be applied to a translated C
//! function at all.  It would not be worth much either: on a statement-shaped
//! body the annotation measured no faster than the call it replaced (479 ms
//! vs 485 ms per 20 M calls), because the interpreter pays for the
//! spliced statements instead.  What pays is turning the body into a single
//! *expression*, which is what this module does.  See `docs/perf-plmpeg.md`
//! for the probe numbers and the before/after benchmark; `--inline=off` (alias
//! `--no-inline`) turns the whole thing off, and its output is byte-identical
//! to the translator's output before this existed.  `--inline=on` and the
//! default `--inline=auto` substitute every candidate; see
//! [`Translation::inlining_enabled`] for why that is the default in every run
//! mode, the LLVM-compiled ones included.
//!
//! # The rule
//!
//! A C function is an inlining candidate when all of the following hold:
//!
//! * it has a body and internal linkage (`static`): no ABI surface, so no
//!   other translation unit can observe the difference;
//! * it is not variadic, takes at most [`MAX_INLINE_PARAMS`] parameters, and
//!   every parameter type and the return type is an arithmetic C type
//!   (integer, enumeration, `float`/`double`) — no records, arrays or
//!   pointers, whose ABI crossings are not worth duplicating;
//! * its body is either `return <expr>;` or the clamp shape — one `if`/`else`
//!   chain whose every arm assigns one and the same parameter, followed by
//!   `return <that parameter>;`;
//! * every expression in that body is *pure*: literals, reads of this
//!   function's own parameters, enumeration constants, casts, arithmetic,
//!   comparison, logical and bitwise operators, the conditional operator, and
//!   direct calls to other candidates.  No loops, no local variables, no
//!   statics, no globals, no `&`, no `++`/`--`, no assignment other than the
//!   clamp shape's own, no calls to anything else;
//! * it does not call itself.
//!
//! The original definition is still emitted: another translation unit, or a
//! function pointer taken in this one, may still reach it.  Only *direct*
//! calls are substituted.
//!
//! # What the call site becomes
//!
//! Every argument crosses exactly as a call would: converted at the
//! parameter's C type through [`Translation::lower_to_c_value`] with
//! [`ValueSite::CallArg`], so promotion and narrowing are unchanged.  An
//! argument that is not already a leaf (a variable read or a literal) binds a
//! `var` temp at the statement anchor, in call order, so it is evaluated
//! exactly once even when the body reads its parameter more than once — and if
//! any argument needs a temp, all of them get one, so the arguments keep C's
//! evaluation order relative to each other.  The clamp shape becomes a
//! conditional-expression chain `c0 ? e0 : (c1 ? e1 : p)`; the body's return
//! expression is then converted with the parameter bound to that chain, so the
//! function's own return conversion is applied to the result exactly once.
//!
//! An expansion that would need statements of its own inside a conditional arm
//! is declined and falls back to a real call, so nothing is ever hoisted out
//! of the arm that guards it.

use super::*;
use crate::InlineMode;
use std::collections::HashSet;

/// Parameter budget for a candidate.  Nothing about the substitution needs a
/// bound; this only keeps the analysis away from wide helper signatures that
/// were never the point.
const MAX_INLINE_PARAMS: usize = 4;

/// How deep one call site may expand candidates into each other.
const MAX_INLINE_DEPTH: usize = 4;

/// The body of a candidate, reduced to the pieces the substitution needs.
#[derive(Clone, Debug)]
pub(crate) enum InlineShape {
    /// `return <expr>;`
    Value { result: CExprId },
    /// `if (c0) p = e0; else if (c1) p = e1; ... [else p = d;] return p;`
    Clamp {
        /// The parameter every arm assigns and the body returns.
        param: CDeclId,
        /// `(condition, assigned value)` in source order.
        arms: Vec<(CExprId, CExprId)>,
        /// The value of a trailing bare `else`, if there is one.  Without it
        /// the chain falls through to the parameter itself.
        otherwise: Option<CExprId>,
        /// The body's `return` expression — a read of `param` through casts.
        result: CExprId,
    },
}

/// A C function this translator will substitute at its direct call sites.
#[derive(Clone, Debug)]
pub(crate) struct InlineCandidate {
    pub(crate) params: Vec<CDeclId>,
    pub(crate) shape: InlineShape,
}

impl<'c> Translation<'c> {
    /// Is call-site inlining switched on for this run?  `--inline=off` (or
    /// `--no-inline`) turns it off, which is how the effect is measured.
    ///
    /// `on` and `auto` admit every candidate today.  `auto` is the default
    /// *policy* and was chosen on the per-run-mode benchmark in
    /// `docs/followups/hot_path_levers.md` (lever 4): substituting the
    /// candidates this module accepts saves 15 % of pl_mpeg's interpreter
    /// time, and leaves `-jit`, `-exe` and AOT within run-to-run noise either
    /// way, because LLVM (and the C++ compiler, for AOT) inlines the call it
    /// would otherwise see.  Narrower policies measured — single-`return`
    /// bodies only, bodies of at most 5 or 3 expression nodes — lost the
    /// interpreter win and gained nothing compiled.  One `.das` feeds every
    /// run mode, so the policy cannot follow the mode that consumes it.
    pub(crate) fn inlining_enabled(&self) -> bool {
        match self.tcfg.inline {
            InlineMode::On | InlineMode::Auto => true,
            InlineMode::Off => false,
        }
    }

    /// The function declaration a direct call names, if the call is direct and
    /// the declaration is the one that carries the body.
    pub(crate) fn direct_call_decl(&self, func: CExprId) -> Option<CDeclId> {
        let mut func = func;
        while let CExprKind::ImplicitCast(_, inner, _, _, _) = &self.ast_context[func].kind {
            func = *inner;
        }
        let CExprKind::DeclRef(_, decl_id, _) = &self.ast_context[func].kind else {
            return None;
        };
        let CDeclKind::Function { body, name, .. } = &self.ast_context[*decl_id].kind else {
            return None;
        };
        if body.is_some() {
            return Some(*decl_id);
        }
        // Clang can resolve a call to a forward declaration.  The definition is
        // the declaration that owns the body, and there is at most one of them
        // per name in a translation unit.
        let name = name.clone();
        self.ast_context.iter_decls().find_map(|(id, decl)| {
            matches!(
                &decl.kind,
                CDeclKind::Function {
                    body: Some(_),
                    name: other,
                    ..
                } if *other == name
            )
            .then_some(*id)
        })
    }

    /// Decide, from the C AST alone, whether `decl_id` may be substituted at
    /// its direct call sites.  See the module documentation for the rule.
    pub(crate) fn inline_candidate(&self, decl_id: CDeclId) -> Option<InlineCandidate> {
        if let Some(cached) = self.inline_candidates.borrow().get(&decl_id) {
            return cached.clone();
        }
        // The answer for a function currently being analysed is "no": a
        // candidate that reaches itself, directly or through another
        // candidate, cannot be substituted into its own expansion.  Seeding
        // the cache before the walk both states that and keeps the analysis
        // itself from recursing forever.
        self.inline_candidates.borrow_mut().insert(decl_id, None);
        let candidate = self.compute_inline_candidate(decl_id);
        self.inline_candidates
            .borrow_mut()
            .insert(decl_id, candidate.clone());
        candidate
    }

    fn compute_inline_candidate(&self, decl_id: CDeclId) -> Option<InlineCandidate> {
        let CDeclKind::Function {
            is_global,
            is_implicit,
            typ,
            parameters,
            body: Some(body),
            ..
        } = &self.ast_context[decl_id].kind
        else {
            return None;
        };
        // Internal linkage only: an externally visible function keeps an ABI
        // that another translation unit is entitled to call.
        if *is_global || *is_implicit {
            return None;
        }
        let CTypeKind::Function(ret_ty, _, is_variadic, _, _) =
            self.ast_context.resolve_type(*typ).kind.clone()
        else {
            return None;
        };
        if is_variadic || !self.is_inline_scalar(ret_ty.ctype) {
            return None;
        }
        if parameters.len() > MAX_INLINE_PARAMS {
            return None;
        }
        let mut params = Vec::with_capacity(parameters.len());
        for &param in parameters {
            let CDeclKind::Variable { typ, .. } = &self.ast_context[param].kind else {
                return None;
            };
            if !self.is_inline_scalar(typ.ctype) {
                return None;
            }
            params.push(param);
        }
        let shape = self.inline_shape(*body, &params)?;
        let param_set: HashSet<CDeclId> = params.iter().copied().collect();
        let mut calls = Vec::new();
        let pure = match &shape {
            InlineShape::Value { result } => self.inline_pure_expr(*result, &param_set, &mut calls),
            InlineShape::Clamp {
                arms,
                otherwise,
                result,
                ..
            } => {
                arms.iter().all(|(cond, value)| {
                    self.inline_pure_expr(*cond, &param_set, &mut calls)
                        && self.inline_pure_expr(*value, &param_set, &mut calls)
                }) && otherwise.map_or(true, |d| self.inline_pure_expr(d, &param_set, &mut calls))
                    && self.inline_pure_expr(*result, &param_set, &mut calls)
            }
        };
        if !pure {
            return None;
        }
        // Direct self-recursion is not a candidate at all; mutual recursion is
        // caught at the call site by the expansion stack.
        if calls.contains(&decl_id) {
            return None;
        }
        Some(InlineCandidate { params, shape })
    }

    /// An arithmetic C type: the only thing worth duplicating into a call
    /// site.  A record, an array or a pointer crosses an ABI boundary of its
    /// own, and this is not the place to reproduce one.
    fn is_inline_scalar(&self, ty: CTypeId) -> bool {
        let kind = &self.ast_context.resolve_type(ty).kind;
        if matches!(kind, CTypeKind::Int128 | CTypeKind::UInt128) {
            return false;
        }
        kind.is_integral_type()
            || matches!(kind, CTypeKind::Float | CTypeKind::Double | CTypeKind::Enum(_))
    }

    /// Recognize the body shape.  Anything else declines.
    fn inline_shape(&self, body: CStmtId, params: &[CDeclId]) -> Option<InlineShape> {
        let CStmtKind::Compound(children) = &self.ast_context[body].kind else {
            return None;
        };
        let stmts: Vec<CStmtId> = children
            .iter()
            .copied()
            .filter(|s| !matches!(self.ast_context[*s].kind, CStmtKind::Empty))
            .collect();
        match stmts.as_slice() {
            [only] => {
                let CStmtKind::Return(Some(result)) = &self.ast_context[*only].kind else {
                    return None;
                };
                Some(InlineShape::Value { result: *result })
            }
            [chain, tail] => {
                let CStmtKind::Return(Some(result)) = &self.ast_context[*tail].kind else {
                    return None;
                };
                let param = self.inline_param_read(*result, params)?;
                let mut arms = Vec::new();
                let otherwise = self.inline_clamp_chain(*chain, param, &mut arms)?;
                (!arms.is_empty()).then_some(InlineShape::Clamp {
                    param,
                    arms,
                    otherwise,
                    result: *result,
                })
            }
            _ => None,
        }
    }

    /// Walk an `if`/`else if` chain whose every arm assigns `param`.  Returns
    /// the value of a trailing bare `else`, or `None` when the chain has none;
    /// declines by returning `None` from the outer `Option` — the two are
    /// distinguished by `arms` staying empty.
    fn inline_clamp_chain(
        &self,
        stmt: CStmtId,
        param: CDeclId,
        arms: &mut Vec<(CExprId, CExprId)>,
    ) -> Option<Option<CExprId>> {
        let CStmtKind::If {
            scrutinee,
            true_variant,
            false_variant,
        } = &self.ast_context[stmt].kind
        else {
            return None;
        };
        let value = self.inline_param_assignment(*true_variant, param)?;
        arms.push((*scrutinee, value));
        match false_variant {
            None => Some(None),
            Some(alternative) => {
                let alternative = self.inline_only_stmt(*alternative)?;
                if matches!(self.ast_context[alternative].kind, CStmtKind::If { .. }) {
                    self.inline_clamp_chain(alternative, param, arms)
                } else {
                    Some(Some(self.inline_param_assignment(alternative, param)?))
                }
            }
        }
    }

    /// The single statement a branch runs, with one level of braces removed.
    fn inline_only_stmt(&self, stmt: CStmtId) -> Option<CStmtId> {
        match &self.ast_context[stmt].kind {
            CStmtKind::Compound(children) => {
                let mut it = children
                    .iter()
                    .copied()
                    .filter(|s| !matches!(self.ast_context[*s].kind, CStmtKind::Empty));
                let only = it.next()?;
                it.next().is_none().then_some(only)
            }
            _ => Some(stmt),
        }
    }

    /// `param = <expr>;` — returns the assigned expression.
    fn inline_param_assignment(&self, stmt: CStmtId, param: CDeclId) -> Option<CExprId> {
        let stmt = self.inline_only_stmt(stmt)?;
        let CStmtKind::Expr(expr) = &self.ast_context[stmt].kind else {
            return None;
        };
        let CExprKind::Binary(_, CBinOp::Assign, lhs, rhs, _, _) = &self.ast_context[*expr].kind
        else {
            return None;
        };
        (self.inline_param_read(*lhs, &[param])? == param).then_some(*rhs)
    }

    /// A read of one of `params` through nothing but casts and parentheses.
    fn inline_param_read(&self, expr: CExprId, params: &[CDeclId]) -> Option<CDeclId> {
        let mut expr = expr;
        loop {
            match &self.ast_context[expr].kind {
                CExprKind::ImplicitCast(_, inner, _, _, _)
                | CExprKind::ExplicitCast(_, inner, _, _, _)
                | CExprKind::Paren(_, inner) => expr = *inner,
                CExprKind::DeclRef(_, decl_id, _) => {
                    return params.contains(decl_id).then_some(*decl_id);
                }
                _ => return None,
            }
        }
    }

    /// Is `expr` free of side effects and free of anything the substitution
    /// cannot reproduce at a call site?  Records every direct callee in
    /// `calls`, so self-recursion can be rejected afterwards.
    fn inline_pure_expr(
        &self,
        expr: CExprId,
        params: &HashSet<CDeclId>,
        calls: &mut Vec<CDeclId>,
    ) -> bool {
        match &self.ast_context[expr].kind {
            CExprKind::Literal(..) | CExprKind::ImplicitValueInit(_) => true,
            CExprKind::DeclRef(_, decl_id, _) => {
                // Only this function's own parameters and enumeration
                // constants: a global or a `static` local would have to be
                // reachable from every call site, and a local cannot exist in
                // a body of this shape anyway.
                params.contains(decl_id)
                    || matches!(
                        self.ast_context[*decl_id].kind,
                        CDeclKind::EnumConstant { .. }
                    )
            }
            CExprKind::Paren(_, inner) | CExprKind::ConstantExpr(_, inner, _) => {
                self.inline_pure_expr(*inner, params, calls)
            }
            CExprKind::ImplicitCast(_, inner, kind, _, _)
            | CExprKind::ExplicitCast(_, inner, kind, _, _) => {
                // A cast between arithmetic types is a value conversion; a
                // decay or a pointer crossing is a place, and places are not
                // duplicated into call sites.
                matches!(
                    kind,
                    CastKind::LValueToRValue
                        | CastKind::NoOp
                        | CastKind::ConstCast
                        | CastKind::IntegralCast
                        | CastKind::IntegralToBoolean
                        | CastKind::IntegralToFloating
                        | CastKind::FloatingToIntegral
                        | CastKind::FloatingCast
                        | CastKind::FloatingToBoolean
                        | CastKind::BooleanToSignedIntegral
                        | CastKind::ToVoid
                ) && self.inline_pure_expr(*inner, params, calls)
            }
            CExprKind::Unary(_, op, inner, _) => {
                matches!(
                    op,
                    CUnOp::Plus | CUnOp::Negate | CUnOp::Complement | CUnOp::Not | CUnOp::Extension
                ) && self.inline_pure_expr(*inner, params, calls)
            }
            CExprKind::UnaryType(..) | CExprKind::OffsetOf(..) => true,
            CExprKind::Binary(_, op, lhs, rhs, _, _) => {
                !matches!(
                    op,
                    CBinOp::Assign
                        | CBinOp::Comma
                        | CBinOp::AssignAdd
                        | CBinOp::AssignSubtract
                        | CBinOp::AssignMultiply
                        | CBinOp::AssignDivide
                        | CBinOp::AssignModulus
                        | CBinOp::AssignBitXor
                        | CBinOp::AssignShiftLeft
                        | CBinOp::AssignShiftRight
                        | CBinOp::AssignBitOr
                        | CBinOp::AssignBitAnd
                ) && self.inline_pure_expr(*lhs, params, calls)
                    && self.inline_pure_expr(*rhs, params, calls)
            }
            CExprKind::Conditional(_, cond, then, els) => {
                self.inline_pure_expr(*cond, params, calls)
                    && self.inline_pure_expr(*then, params, calls)
                    && self.inline_pure_expr(*els, params, calls)
            }
            CExprKind::Call(_, func, args) => {
                // A call is pure only when the callee is a candidate itself,
                // which is what makes it substitutable in turn.
                let Some(callee) = self.direct_call_decl(*func) else {
                    return false;
                };
                calls.push(callee);
                if self.inline_candidate(callee).is_none() {
                    return false;
                }
                args.iter()
                    .all(|arg| self.inline_pure_expr(*arg, params, calls))
            }
            _ => false,
        }
    }

    /// Substitute a direct call to `callee` at the call site, or decline by
    /// returning `Ok(None)` so the caller emits an ordinary call.
    pub(crate) fn try_inline_call(
        &self,
        ctx: ExprContext,
        callee: CDeclId,
        args: &[CExprId],
        override_ty: Option<CQualTypeId>,
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        // A discarded result would leave a value expression in statement
        // position, and a constant initializer has no statement anchor for the
        // argument temps.  Both keep the call.
        if ctx.is_unused() || ctx.is_static || ctx.is_const || ctx.needs_address {
            return Ok(None);
        }
        if self.inline_stack.borrow().len() >= MAX_INLINE_DEPTH
            || self.inline_stack.borrow().contains(&callee)
        {
            return Ok(None);
        }
        let Some(candidate) = self.inline_candidate(callee) else {
            return Ok(None);
        };
        if candidate.params.len() != args.len() {
            return Ok(None);
        }
        let CDeclKind::Function { typ, .. } = &self.ast_context[callee].kind else {
            return Ok(None);
        };
        let CTypeKind::Function(ret_ty, _, _, _, _) =
            self.ast_context.resolve_type(*typ).kind.clone()
        else {
            return Ok(None);
        };

        // --- arguments: exactly the crossings a call would perform ---
        let mut stmts = Vec::new();
        let mut is_unsafe = false;
        let mut values = Vec::with_capacity(args.len());
        for (idx, &arg) in args.iter().enumerate() {
            let CDeclKind::Variable { typ: param_ty, .. } =
                &self.ast_context[candidate.params[idx]].kind
            else {
                return Ok(None);
            };
            let param_ty = *param_ty;
            let param_da = writable_type(self.convert_type(param_ty)?);
            let converted = self.convert_expr(ctx.used(), arg, Some(param_ty))?;
            let converted = self.lower_to_c_value(
                converted,
                self.ast_context[arg].kind.get_qual_type(),
                param_da.clone(),
                ValueSite::CallArg,
            )?;
            is_unsafe |= converted.is_unsafe;
            stmts.extend(converted.stmts);
            // The same crossing an ordinary call performs: daScript has no
            // conversion from `bool` at all, so a C `_Bool` argument has to be
            // materialized as a number through statements first.
            let mut value = converted.val;
            if let Some((lowered_stmts, lowered)) = self.bool_to_integer_cast(value.clone()) {
                stmts.extend(lowered_stmts);
                value = lowered;
            }
            values.push((param_da, value));
        }
        // A parameter may be read more than once by the substituted body, and
        // C evaluates an argument exactly once, at the call.  A leaf can be
        // duplicated; anything else binds a temp — and once any argument does,
        // all of them do, so their evaluation order relative to each other is
        // the order C wrote them in.
        let needs_temps = values.iter().any(|(_, val)| !Self::is_inline_leaf(val));
        let mut bindings: HashMap<CDeclId, DaExpr> = HashMap::new();
        let mut bound: HashMap<String, DaType> = HashMap::new();
        for (idx, (param_da, val)) in values.into_iter().enumerate() {
            let value = if needs_temps {
                let tmp = self.renamer.borrow_mut().fresh();
                stmts.push(DaStmt::Var {
                    name: tmp.clone(),
                    var_type: param_da.clone(),
                    init: Some(val),
                });
                bound.insert(tmp.clone(), param_da);
                DaExpr::Var(tmp)
            } else {
                // The argument crossed at the parameter's type just above, so
                // a bare name here is already spelled in it: recording that
                // keeps a redundant cast out of the conditional chain.
                if let DaExpr::Var(name) = &val {
                    bound.insert(name.clone(), param_da);
                }
                val
            };
            bindings.insert(candidate.params[idx], value);
        }

        // --- body: converted with the parameters bound to those values ---
        // `callee` on the expansion stack is what makes a mutually recursive
        // candidate decline instead of expanding forever.
        self.inline_stack.borrow_mut().push(callee);
        self.inline_frames.borrow_mut().push(bindings.clone());
        let expanded = self.expand_inline_shape(ctx, &candidate, &ret_ty, &bindings, &bound);
        self.inline_frames.borrow_mut().pop();
        self.inline_stack.borrow_mut().pop();
        let Some(expanded) = expanded? else {
            return Ok(None);
        };
        is_unsafe |= expanded.is_unsafe;
        stmts.extend(expanded.stmts);

        // --- result: the same use-site crossing an ordinary call would get ---
        let result = if let Some(expected_ty) = override_ty {
            let expected_da = self.convert_type(expected_ty)?;
            self.narrow_to_storage(expanded.val, &writable_type(expected_da))
        } else {
            expanded.val
        };
        Ok(Some(
            WithStmts::new_val(result)
                .prepend_stmts(stmts)
                .merge_unsafe(is_unsafe),
        ))
    }

    /// The substituted body value, or `None` when a piece of it would need
    /// statements of its own inside a conditional arm.
    fn expand_inline_shape(
        &self,
        ctx: ExprContext,
        candidate: &InlineCandidate,
        ret_ty: &CQualTypeId,
        bindings: &HashMap<CDeclId, DaExpr>,
        bound: &HashMap<String, DaType>,
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        let ret_da = self.convert_type(*ret_ty)?;
        match &candidate.shape {
            InlineShape::Value { result } => {
                let value = self.convert_expr(ctx.used(), *result, None)?;
                let value = self.lower_to_c_value(
                    value,
                    self.ast_context[*result].kind.get_qual_type(),
                    ret_da,
                    ValueSite::Return,
                )?;
                Ok(Some(value))
            }
            InlineShape::Clamp {
                param,
                arms,
                otherwise,
                result,
            } => {
                let param_da = match &self.ast_context[*param].kind {
                    CDeclKind::Variable { typ, .. } => writable_type(self.convert_type(*typ)?),
                    _ => return Ok(None),
                };
                // Every arm of the chain is one daScript conditional
                // expression, so nothing an arm needs may leave the arm.
                let mut lowered = Vec::with_capacity(arms.len());
                for (cond, value) in arms {
                    let Some(cond) = self.inline_condition(ctx, *cond)? else {
                        return Ok(None);
                    };
                    let Some(value) = self.inline_arm_value(ctx, *value, &param_da, bound)? else {
                        return Ok(None);
                    };
                    lowered.push((cond, value));
                }
                let mut chain = match otherwise {
                    Some(default) => {
                        let Some(value) =
                            self.inline_arm_value(ctx, *default, &param_da, bound)?
                        else {
                            return Ok(None);
                        };
                        value
                    }
                    None => {
                        // Without a trailing `else` the chain falls through to
                        // the parameter, which is the argument the call site
                        // bound for it.
                        let Some(tail) = bindings.get(param).cloned() else {
                            return Ok(None);
                        };
                        self.inline_typed_as(tail, &param_da, bound)
                    }
                };
                for (cond, value) in lowered.into_iter().rev() {
                    chain = DaExpr::Op3 {
                        cond: Box::new(cond),
                        then: Box::new(value),
                        else_: Box::new(chain),
                    };
                }
                // The body's `return` reads the parameter exactly once and
                // through nothing but casts, so binding it to the chain
                // applies C's return conversion to the chain and to nothing
                // else.
                let mut frame = bindings.clone();
                frame.insert(*param, chain);
                self.inline_frames.borrow_mut().push(frame);
                let value = self.convert_expr(ctx.used(), *result, None);
                self.inline_frames.borrow_mut().pop();
                let value = value?;
                if !value.stmts.is_empty() {
                    return Ok(None);
                }
                let value = self.lower_to_c_value(
                    value,
                    self.ast_context[*result].kind.get_qual_type(),
                    ret_da,
                    ValueSite::Return,
                )?;
                if !value.stmts.is_empty() {
                    return Ok(None);
                }
                Ok(Some(value))
            }
        }
    }

    /// The guard of one chain arm as a daScript boolean *expression*.
    ///
    /// [`Translation::convert_condition`] is the statement-position lowering:
    /// it converts the C condition at the C type C gives it — `int` for a
    /// comparison — and daScript has no conversion from `bool` to a number, so
    /// the 0/1 has to be materialized through control flow.  A conditional
    /// expression has nowhere to put those statements, so the comparison is
    /// taken at its own daScript type instead.
    fn inline_condition(
        &self,
        ctx: ExprContext,
        expr: CExprId,
    ) -> TranslationResult<Option<DaExpr>> {
        let mut expr = expr;
        while let CExprKind::Paren(_, inner) = &self.ast_context[expr].kind {
            expr = *inner;
        }
        // A C comparison has type `int`, and every value path in this
        // translator therefore materializes its 0/1 through statements.  Going
        // straight to the binary lowering keeps the `bool` daScript already
        // produced, which is what a condition slot wants anyway.
        if let CExprKind::Binary(ty, op, lhs, rhs, opt_lhs, opt_rhs) =
            self.ast_context[expr].kind.clone()
        {
            if matches!(
                op,
                CBinOp::EqualEqual
                    | CBinOp::NotEqual
                    | CBinOp::Less
                    | CBinOp::Greater
                    | CBinOp::LessEqual
                    | CBinOp::GreaterEqual
            ) {
                let value =
                    self.convert_binary_expr(ctx.used(), ty, op, lhs, rhs, opt_lhs, opt_rhs)?;
                let value = self.normalize_condition_comparison(expr, value)?;
                if !value.stmts.is_empty() {
                    return Ok(None);
                }
                if Self::infer_type(&value.val)
                    .map_or(false, |ty| matches!(ty.kind, DaTypeKind::Bool))
                {
                    return Ok(Some(self.as_bool_condition(value.val)));
                }
                return Ok(None);
            }
        }
        let value = self.convert_expr(ctx.used(), expr, None)?;
        if !value.stmts.is_empty() {
            return Ok(None);
        }
        if Self::infer_type(&value.val).map_or(false, |ty| matches!(ty.kind, DaTypeKind::Bool)) {
            return Ok(Some(self.as_bool_condition(value.val)));
        }
        let Some(qty) = self.ast_context[expr].kind.get_qual_type() else {
            return Ok(None);
        };
        let da = writable_type(self.convert_type(qty)?);
        if !da.is_numeric() {
            return Ok(None);
        }
        Ok(Some(self.value_is_truthy(value.val, &da)))
    }

    /// The value one chain arm assigns, at the chain's own type: every arm of
    /// a daScript conditional expression has to have the same one.
    fn inline_arm_value(
        &self,
        ctx: ExprContext,
        expr: CExprId,
        param_da: &DaType,
        bound: &HashMap<String, DaType>,
    ) -> TranslationResult<Option<DaExpr>> {
        let value = self.convert_expr(ctx.used(), expr, None)?;
        let value = self.lower_to_c_value(
            value,
            self.ast_context[expr].kind.get_qual_type(),
            param_da.clone(),
            ValueSite::Assignment,
        )?;
        if !value.stmts.is_empty() {
            return Ok(None);
        }
        Ok(Some(self.inline_typed_as(value.val, param_da, bound)))
    }

    /// `value` spelled at `target`, unless it demonstrably already is.
    fn inline_typed_as(
        &self,
        value: DaExpr,
        target: &DaType,
        bound: &HashMap<String, DaType>,
    ) -> DaExpr {
        let known = match &value {
            DaExpr::Var(name) => bound.get(name).cloned(),
            other => Self::infer_type(other),
        };
        if known.as_ref() == Some(target) {
            return value;
        }
        self.cast_to_type(value, target.clone())
    }

    /// A value that may be duplicated into a call site without changing how
    /// often, or in what order, anything is evaluated.
    fn is_inline_leaf(value: &DaExpr) -> bool {
        match value {
            DaExpr::Var(_)
            | DaExpr::ConstInt(_)
            | DaExpr::ConstUInt(_)
            | DaExpr::ConstFloat(_)
            | DaExpr::ConstDouble(_)
            | DaExpr::ConstBool(_)
            | DaExpr::ConstNull => true,
            DaExpr::Cast { expr, .. } | DaExpr::Unsafe(expr) => Self::is_inline_leaf(expr),
            _ => false,
        }
    }

    /// The value bound to `decl_id` by the innermost inline expansion, if any.
    pub(crate) fn inline_binding(&self, decl_id: CDeclId) -> Option<DaExpr> {
        self.inline_frames
            .borrow()
            .last()
            .and_then(|frame| frame.get(&decl_id).cloned())
    }
}
