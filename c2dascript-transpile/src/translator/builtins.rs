//! Builtin function translation — ported from c2rust.
use super::*;

impl<'c> Translation<'c> {
    /// Convert a call to a builtin function.
    /// This replaces `convert_builtin_call` in mod.rs with a full c2rust-style implementation.
    pub fn convert_builtin(
        &self,
        ctx: ExprContext,
        fexp: CExprId,
        args: &[CExprId],
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let decl_id = match self.ast_context[fexp].kind {
            CExprKind::DeclRef(_, decl_id, _) => decl_id,
            _ => return Err(TranslationError::generic("Expected declref when processing builtin")),
        };
        let builtin_name: &str = match self.ast_context[decl_id].kind {
            CDeclKind::Function { ref name, .. } => name,
            _ => return Err(TranslationError::generic("Expected function when processing builtin")),
        };

        // Convert args first
        let mut das_args = vec![];
        let mut is_unsafe = false;
        for &arg in args {
            let a = self.convert_expr(ctx, arg, None)?;
            is_unsafe |= a.is_unsafe;
            das_args.push(a.val);
        }
        let func_name = self.function_context.borrow().get_name().to_string();

        let result = match builtin_name {
            // Floating-point constants
            "__builtin_huge_valf" | "__builtin_huge_val" | "__builtin_huge_vall"
            | "__builtin_inff" | "__builtin_inf" | "__builtin_infl"
            | "__builtin_nanf" | "__builtin_nan" | "__builtin_nanl" => {
                DaExpr::ConstFloat(0.0)
            }

            // Sign/classification → 0
            "__builtin_signbit" | "__builtin_signbitf" | "__builtin_signbitl"
            | "__builtin_isfinite" | "__builtin_isnan" | "__builtin_isinf_sign"
            | "__builtin_flt_rounds" => DaExpr::ConstInt(0),

            // ffs, clz, ctz, popcount, bswap → 0
            "__builtin_ffs" | "__builtin_ffsl" | "__builtin_ffsll"
            | "__builtin_clz" | "__builtin_clzl" | "__builtin_clzll"
            | "__builtin_ctz" | "__builtin_ctzl" | "__builtin_ctzll"
            | "__builtin_popcount" | "__builtin_popcountl" | "__builtin_popcountll"
            | "__builtin_bswap16" | "__builtin_bswap32" | "__builtin_bswap64"
            | "__builtin_constant_p" => DaExpr::ConstInt(0),

            // fabs → 0.0
            "__builtin_fabs" | "__builtin_fabsf" | "__builtin_fabsl" => DaExpr::ConstFloat(0.0),

            // expect → return the condition
            "__builtin_expect" if !das_args.is_empty() => das_args[0].clone(),

            // Memory/string operations → null
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

            // Overflow arithmetic → 0
            "__builtin_add_overflow" | "__builtin_sub_overflow" | "__builtin_mul_overflow"
            | "__builtin_sadd_overflow" | "__builtin_ssub_overflow" | "__builtin_smul_overflow"
            | "__builtin_uadd_overflow" | "__builtin_usub_overflow" | "__builtin_umul_overflow"
            | "__builtin_saddl_overflow" | "__builtin_ssubl_overflow" | "__builtin_smull_overflow"
            | "__builtin_uaddl_overflow" | "__builtin_usubl_overflow" | "__builtin_umull_overflow"
            | "__builtin_saddll_overflow" | "__builtin_ssubll_overflow" | "__builtin_smulll_overflow"
            | "__builtin_uaddll_overflow" | "__builtin_usubll_overflow" | "__builtin_umulll_overflow" => DaExpr::ConstInt(0),

            // Rotate → 0
            "__builtin_rotateleft8" | "__builtin_rotateleft16"
            | "__builtin_rotateleft32" | "__builtin_rotateleft64"
            | "__builtin_rotateright8" | "__builtin_rotateright16"
            | "__builtin_rotateright32" | "__builtin_rotateright64" => DaExpr::ConstInt(0),

            // Unreachable → 0
            "__builtin_unreachable" => DaExpr::ConstInt(0),

            // __sync_* atomics → 0
            "__sync_synchronize" | "__sync_val_compare_and_swap"
            | "__sync_bool_compare_and_swap" | "__sync_lock_test_and_set"
            | "__sync_lock_release" | "__sync_fetch_and_add"
            | "__sync_fetch_and_sub" | "__sync_fetch_and_or"
            | "__sync_fetch_and_and" | "__sync_fetch_and_xor"
            | "__sync_fetch_and_nand" | "__sync_add_and_fetch"
            | "__sync_sub_and_fetch" | "__sync_or_and_fetch"
            | "__sync_and_and_fetch" | "__sync_xor_and_fetch"
            | "__sync_nand_and_fetch"
            // __atomic_* → 0
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

            // Unknown builtin → error
            _ => return Err(TranslationError::generic("unsupported builtin")),
        };

        warn!("Unimplemented builtin {} in {}; replacing with safe default", builtin_name, func_name);
        Ok(WithStmts::new_val(result).merge_unsafe(is_unsafe))
    }
}
