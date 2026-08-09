//! Canonical daScript ABI conversions shared by translator lowering paths.
//!
//! C pointers remain typed `T?` in translated program expressions.  Raw
//! `uint64` addresses are an implementation detail used only at explicit ABI
//! boundaries such as the raw-memory runtime and pointer comparisons.

use super::*;

pub(crate) fn null_pointer(pointer: &DaType) -> DaExpr {
    debug_assert!(matches!(pointer.kind, DaTypeKind::Pointer(_)));
    DaExpr::ConstNull
}

impl<'c> Translation<'c> {
    pub(crate) fn abi_raw_address_to_pointer(&self, raw_address: DaExpr, pointer: DaType) -> DaExpr {
        debug_assert!(matches!(pointer.kind, DaTypeKind::Pointer(_)));
        DaExpr::Unsafe(Box::new(DaExpr::Cast {
            kind: das_ast::CastKind::Reinterpret,
            expr: Box::new(raw_address),
            to: pointer,
        }))
    }

    pub(crate) fn abi_pointer_to_raw_address(&self, pointer: DaExpr) -> DaExpr {
        DaExpr::Unsafe(Box::new(DaExpr::Cast {
            kind: das_ast::CastKind::Reinterpret,
            expr: Box::new(pointer),
            to: DaType::uint64(),
        }))
    }

    /// Reinterpret a value already represented as a daScript pointer (or an
    /// array-decay value) to another typed C pointer.  Null stays null rather
    /// than becoming an invalid numeric pointer cast.
    pub(crate) fn abi_pointer_cast(&self, pointer: DaExpr, target: DaType) -> DaExpr {
        debug_assert!(matches!(target.kind, DaTypeKind::Pointer(_)));
        if matches!(pointer, DaExpr::ConstNull) {
            return self.abi_null_pointer(&target);
        }
        DaExpr::Unsafe(Box::new(DaExpr::Cast {
            kind: das_ast::CastKind::Reinterpret,
            expr: Box::new(pointer),
            to: target,
        }))
    }

    pub(crate) fn abi_null_pointer(&self, pointer: &DaType) -> DaExpr {
        null_pointer(pointer)
    }

    pub(crate) fn abi_pointer_comparison_operand(&self, expr: DaExpr, is_pointer: bool) -> DaExpr {
        if matches!(expr, DaExpr::ConstNull) {
            return DaExpr::Cast {
                kind: das_ast::CastKind::Cast,
                expr: Box::new(DaExpr::ConstInt(0)),
                to: DaType::uint64(),
            };
        }
        if is_pointer {
            self.abi_pointer_to_raw_address(expr)
        } else {
            DaExpr::Cast {
                kind: das_ast::CastKind::Cast,
                expr: Box::new(expr),
                to: DaType::uint64(),
            }
        }
    }
}
