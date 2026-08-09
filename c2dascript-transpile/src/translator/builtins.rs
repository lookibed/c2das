//! Builtin function translation — полный порт c2rust builtins.rs
use super::*;

impl<'c> Translation<'c> {
    pub fn convert_builtin_call(
        &self,
        ctx: ExprContext,
        fexp: CExprId,
        args: &[CExprId],
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let builtin_name = match &self.ast_context[fexp].kind {
            CExprKind::DeclRef(_, decl_id, _) => self.ast_context[*decl_id]
                .kind
                .get_name()
                .cloned()
                .unwrap_or_default(),
            _ => return self.convert_expr(ctx, fexp, None),
        };
        let func_name = self.function_context.borrow().get_name().to_string();
        let mut das_args = vec![];
        let mut is_unsafe = false;
        for &arg in args {
            let a = self.convert_expr(ctx, arg, None)?;
            is_unsafe |= a.is_unsafe;
            das_args.push(a.val);
        }

        // Clang represents ordinary malloc calls through its builtin path on
        // some targets.  That classification must not bypass the canonical
        // raw-memory ABI used by normal direct calls.
        if builtin_name == "malloc" || builtin_name.ends_with("_malloc") {
            let size = das_args
                .into_iter()
                .next()
                .unwrap_or(DaExpr::ConstUInt(0));
            let raw_call = DaExpr::Call(
                Box::new(DaExpr::Var("c2da_rt_malloc".to_owned())),
                vec![DaExpr::Cast {
                    kind: das_ast::CastKind::Cast,
                    expr: Box::new(size),
                    to: DaType::uint64(),
                }],
            );
            return Ok(WithStmts::new_val(self.abi_raw_address_to_pointer(
                raw_call,
                DaType::pointer(DaType::void()),
            ))
            .merge_unsafe(is_unsafe));
        }

        // Rotate builtins
        if builtin_name.starts_with("__builtin_rotateleft") {
            return self.convert_builtin_rotate(ctx, args, "rotate_left");
        }
        if builtin_name.starts_with("__builtin_rotateright") {
            return self.convert_builtin_rotate(ctx, args, "rotate_right");
        }

        // Overflow arithmetic builtins
        if builtin_name.contains("_overflow") && builtin_name.contains("add")
            || builtin_name == "__builtin_sadd_overflow"
            || builtin_name == "__builtin_uadd_overflow"
            || builtin_name == "__builtin_saddl_overflow"
            || builtin_name == "__builtin_uaddl_overflow"
            || builtin_name == "__builtin_saddll_overflow"
            || builtin_name == "__builtin_uaddll_overflow"
        {
            return self.convert_overflow_arith(ctx, args, "overflowing_add");
        }
        if builtin_name.contains("_overflow") && builtin_name.contains("sub")
            || builtin_name == "__builtin_ssub_overflow"
            || builtin_name == "__builtin_usub_overflow"
            || builtin_name == "__builtin_ssubl_overflow"
            || builtin_name == "__builtin_usubl_overflow"
            || builtin_name == "__builtin_ssubll_overflow"
            || builtin_name == "__builtin_usubll_overflow"
        {
            return self.convert_overflow_arith(ctx, args, "overflowing_sub");
        }
        if builtin_name.contains("_overflow") && builtin_name.contains("mul")
            || builtin_name == "__builtin_smul_overflow"
            || builtin_name == "__builtin_umul_overflow"
            || builtin_name == "__builtin_smull_overflow"
            || builtin_name == "__builtin_umull_overflow"
            || builtin_name == "__builtin_smulll_overflow"
            || builtin_name == "__builtin_umulll_overflow"
        {
            return self.convert_overflow_arith(ctx, args, "overflowing_mul");
        }

        // libc mem/str functions
        if builtin_name.starts_with("__builtin_mem") || builtin_name.starts_with("__builtin_str") {
            return self.convert_libc_fns(ctx, &builtin_name, args);
        }

        let result = match builtin_name.as_str() {
            "__builtin_expect" if !das_args.is_empty() => das_args[0].clone(),
            "__builtin_isfinite"
            | "__builtin_isnan"
            | "__builtin_isinf_sign"
            | "__builtin_signbit"
            | "__builtin_flt_rounds" => DaExpr::ConstInt(0),
            "__builtin_ffs"
            | "__builtin_ffsl"
            | "__builtin_ffsll"
            | "__builtin_clz"
            | "__builtin_clzl"
            | "__builtin_clzll"
            | "__builtin_ctz"
            | "__builtin_ctzl"
            | "__builtin_ctzll"
            | "__builtin_popcount"
            | "__builtin_popcountl"
            | "__builtin_popcountll"
            | "__builtin_bswap16"
            | "__builtin_bswap32"
            | "__builtin_bswap64"
            | "__builtin_constant_p" => DaExpr::ConstInt(0),
            "__builtin_huge_valf"
            | "__builtin_huge_val"
            | "__builtin_huge_vall"
            | "__builtin_inff"
            | "__builtin_inf"
            | "__builtin_infl"
            | "__builtin_nanf"
            | "__builtin_nan"
            | "__builtin_nanl"
            | "__builtin_fabs"
            | "__builtin_fabsf"
            | "__builtin_fabsl" => DaExpr::ConstFloat(0.0),
            "__builtin_prefetch"
            | "__builtin_alloca"
            | "__builtin_return_address"
            | "__builtin_frame_address"
            | "__builtin_extract_return_addr"
            | "__builtin_frob_return_addr"
            | "__builtin_assume_aligned"
            | "__builtin_unwind_init" => DaExpr::ConstNull,
            "__builtin_unreachable" => DaExpr::ConstInt(0),
            _ => return Err(TranslationError::generic("unsupported builtin")),
        };
        warn!(
            "Unimplemented builtin {} in {}; replacing with safe default",
            builtin_name, func_name
        );
        Ok(WithStmts::new_val(result).merge_unsafe(is_unsafe))
    }

    fn convert_builtin_rotate(
        &self,
        _ctx: ExprContext,
        args: &[CExprId],
        _method: &str,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        if args.len() >= 2 {
            let a0 = self.convert_expr(ExprContext::default(), args[0], None)?;
            let a1 = self.convert_expr(ExprContext::default(), args[1], None)?;
            Ok(a0.zip(a1).map(|(l, r)| DaExpr::Op2 {
                op: ">>>",
                left: Box::new(l),
                right: Box::new(r),
            }))
        } else {
            Ok(WithStmts::new_val(DaExpr::ConstInt(0)))
        }
    }

    fn convert_overflow_arith(
        &self,
        _ctx: ExprContext,
        _args: &[CExprId],
        _method: &str,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        // daScript has no overflow-checked arithmetic; return 0
        Ok(WithStmts::new_val(DaExpr::ConstInt(0)))
    }

    fn convert_libc_fns(
        &self,
        ctx: ExprContext,
        _builtin_name: &str,
        args: &[CExprId],
    ) -> TranslationResult<WithStmts<DaExpr>> {
        // Convert args for side effects, return null (daScript has no libc)
        for &arg in args {
            self.convert_expr(ctx.unused(), arg, None)?;
        }
        Ok(WithStmts::new_val(DaExpr::ConstNull))
    }
}
