//! Atomic builtin translation — ported from c2rust.
//! daScript has no atomic intrinsics; all atomics are replaced with safe defaults.
use super::*;

impl<'c> Translation<'c> {
    pub fn convert_atomic(
        &self,
        _ctx: ExprContext,
        name: &str,
        _ptr_id: CExprId,
        _order_id: CExprId,
        _val1_id: Option<CExprId>,
        _order_fail_id: Option<CExprId>,
        _val2_id: Option<CExprId>,
        _weak_id: Option<CExprId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        warn!("Atomic {} not supported in daScript; replacing with 0", name);
        Ok(WithStmts::new_val(DaExpr::ConstInt(0)))
    }

    pub fn convert_atomic_cxchg(
        &self,
        _ctx: ExprContext,
        _weak: bool,
        _order_succ: std::sync::atomic::Ordering,
        _order_fail: std::sync::atomic::Ordering,
        _dst: DaExpr,
        _old_val: DaExpr,
        _src_val: DaExpr,
        _returns_val: bool,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        Ok(WithStmts::new_val(DaExpr::ConstInt(0)))
    }

    pub fn convert_atomic_op(
        &self,
        _ctx: ExprContext,
        _atomic_op: CAtomicBinOp,
        _order: std::sync::atomic::Ordering,
        _dst: DaExpr,
        _src: DaExpr,
        _src_type_id: CQualTypeId,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        Ok(WithStmts::new_val(DaExpr::ConstInt(0)))
    }

    pub fn atomic_intrinsic_expr(&self, _base_name: &str, _orders: &[std::sync::atomic::Ordering]) -> DaExpr {
        DaExpr::ConstInt(0)
    }
}

/// Atomic binary operations (mirrors c2rust CAtomicBinOp)
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CAtomicBinOp {
    FetchAdd, FetchSub, FetchOr, FetchAnd, FetchXor, FetchNand,
    AddFetch, SubFetch, OrFetch, AndFetch, XorFetch, NandFetch,
}

impl CAtomicBinOp {
    pub fn from_atomic_fn(name: &str) -> Option<Self> {
        Some(match name {
            "__atomic_fetch_add" | "__c11_atomic_fetch_add" => Self::FetchAdd,
            "__atomic_fetch_sub" | "__c11_atomic_fetch_sub" => Self::FetchSub,
            "__atomic_fetch_or" | "__c11_atomic_fetch_or" => Self::FetchOr,
            "__atomic_fetch_and" | "__c11_atomic_fetch_and" => Self::FetchAnd,
            "__atomic_fetch_xor" | "__c11_atomic_fetch_xor" => Self::FetchXor,
            "__atomic_fetch_nand" | "__c11_atomic_fetch_nand" => Self::FetchNand,
            "__atomic_add_fetch" => Self::AddFetch,
            "__atomic_sub_fetch" => Self::SubFetch,
            "__atomic_or_fetch" => Self::OrFetch,
            "__atomic_and_fetch" => Self::AndFetch,
            "__atomic_xor_fetch" => Self::XorFetch,
            "__atomic_nand_fetch" => Self::NandFetch,
            _ => return None,
        })
    }

    pub fn from_sync_builtin_fn(name: &str) -> Option<Self> {
        Some(match name {
            "__sync_add_and_fetch_1" | "__sync_add_and_fetch_2"
            | "__sync_add_and_fetch_4" | "__sync_add_and_fetch_8"
            | "__sync_add_and_fetch_16" => Self::AddFetch,
            "__sync_sub_and_fetch_1" | "__sync_sub_and_fetch_2"
            | "__sync_sub_and_fetch_4" | "__sync_sub_and_fetch_8"
            | "__sync_sub_and_fetch_16" => Self::SubFetch,
            "__sync_fetch_and_add_1" | "__sync_fetch_and_add_2"
            | "__sync_fetch_and_add_4" | "__sync_fetch_and_add_8"
            | "__sync_fetch_and_add_16" => Self::FetchAdd,
            "__sync_fetch_and_sub_1" | "__sync_fetch_and_sub_2"
            | "__sync_fetch_and_sub_4" | "__sync_fetch_and_sub_8"
            | "__sync_fetch_and_sub_16" => Self::FetchSub,
            "__sync_fetch_and_or_1" | "__sync_fetch_and_or_2"
            | "__sync_fetch_and_or_4" | "__sync_fetch_and_or_8"
            | "__sync_fetch_and_or_16" => Self::FetchOr,
            "__sync_fetch_and_and_1" | "__sync_fetch_and_and_2"
            | "__sync_fetch_and_and_4" | "__sync_fetch_and_and_8"
            | "__sync_fetch_and_and_16" => Self::FetchAnd,
            "__sync_fetch_and_xor_1" | "__sync_fetch_and_xor_2"
            | "__sync_fetch_and_xor_4" | "__sync_fetch_and_xor_8"
            | "__sync_fetch_and_xor_16" => Self::FetchXor,
            "__sync_fetch_and_nand_1" | "__sync_fetch_and_nand_2"
            | "__sync_fetch_and_nand_4" | "__sync_fetch_and_nand_8"
            | "__sync_fetch_and_nand_16" => Self::FetchNand,
            _ => return None,
        })
    }

    pub fn fetches_first(self) -> bool {
        matches!(self, Self::FetchAdd | Self::FetchSub | Self::FetchOr
            | Self::FetchAnd | Self::FetchXor | Self::FetchNand)
    }

    pub fn is_nand(self) -> bool {
        matches!(self, Self::FetchNand | Self::NandFetch)
    }

    pub fn rust_intrinsic_base_name(self) -> &'static str {
        match self {
            Self::FetchAdd | Self::AddFetch => "xadd",
            Self::FetchSub | Self::SubFetch => "xsub",
            Self::FetchOr | Self::OrFetch => "or",
            Self::FetchAnd | Self::AndFetch => "and",
            Self::FetchXor | Self::XorFetch => "xor",
            Self::FetchNand | Self::NandFetch => "nand",
        }
    }
}
