//! Canonical daScript raw-memory runtime.
//!
//! This module deliberately builds `DaDecl`/`DaExpr` values.  It must never
//! repair printed text: all C/libc ABI boundaries are represented explicitly
//! in the generated AST.

use das_ast::{CastKind, DaBlock, DaDecl, DaExpr, DaFunction, DaStmt, DaType, DaVariable};

/// One allocation arena is reserved before an address is exposed.  Later
/// `resize` calls stay inside that reservation, so a C pointer returned from
/// `c2da_rt_malloc` does not move when a later allocation grows the heap.
pub const HEAP_RESERVE_BYTES: u64 = 64 * 1024 * 1024;

const HEAP: &str = "c2da_rt_heap";
const NEXT: &str = "c2da_rt_next";
const ALLOC_ADDRS: &str = "c2da_rt_alloc_addrs";
const ALLOC_SIZES: &str = "c2da_rt_alloc_sizes";
const ALLOC_LIVE: &str = "c2da_rt_alloc_live";

/// Canonical C library entry points implemented by the generated raw-memory
/// runtime.  This is the sole registry shared by call lowering and runtime
/// declaration generation; fixture sources never define an alternative target
/// implementation for these symbols.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum CanonicalRuntimeFunction {
    Malloc,
    Calloc,
    Realloc,
    Free,
    Memset,
    Memcpy,
    Memmove,
    Memcmp,
    Memchr,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum RuntimeArgKind {
    UInt64,
    RawAddress,
    UInt8,
}

impl CanonicalRuntimeFunction {
    pub(crate) fn target_name(self) -> &'static str {
        match self {
            Self::Malloc => "c2da_rt_malloc",
            Self::Calloc => "c2da_rt_calloc",
            Self::Realloc => "c2da_rt_realloc",
            Self::Free => "c2da_rt_free",
            Self::Memset => "c2da_rt_memset",
            Self::Memcpy => "c2da_rt_memcpy",
            Self::Memmove => "c2da_rt_memmove",
            Self::Memcmp => "c2da_rt_memcmp",
            Self::Memchr => "c2da_rt_memchr",
        }
    }

    pub(crate) fn arg_kind(self, index: usize) -> Option<RuntimeArgKind> {
        match (self, index) {
            (Self::Malloc, 0)
            | (Self::Calloc, 0 | 1)
            | (Self::Realloc, 1)
            | (Self::Memset | Self::Memcpy | Self::Memmove | Self::Memcmp | Self::Memchr, 2) => {
                Some(RuntimeArgKind::UInt64)
            }
            (Self::Realloc | Self::Free, 0)
            | (Self::Memset | Self::Memchr, 0)
            | (Self::Memcpy | Self::Memmove | Self::Memcmp, 0 | 1) => {
                Some(RuntimeArgKind::RawAddress)
            }
            (Self::Memset | Self::Memchr, 1) => Some(RuntimeArgKind::UInt8),
            _ => None,
        }
    }
}

pub(crate) fn canonical_runtime_function(name: &str) -> Option<CanonicalRuntimeFunction> {
    match name {
        "malloc" | "__builtin_malloc" => Some(CanonicalRuntimeFunction::Malloc),
        "calloc" | "__builtin_calloc" => Some(CanonicalRuntimeFunction::Calloc),
        "realloc" | "__builtin_realloc" => Some(CanonicalRuntimeFunction::Realloc),
        "free" | "__builtin_free" => Some(CanonicalRuntimeFunction::Free),
        "memset" | "__builtin_memset" => Some(CanonicalRuntimeFunction::Memset),
        "memcpy" | "__builtin_memcpy" => Some(CanonicalRuntimeFunction::Memcpy),
        "memmove" | "__builtin_memmove" => Some(CanonicalRuntimeFunction::Memmove),
        "memcmp" | "__builtin_memcmp" => Some(CanonicalRuntimeFunction::Memcmp),
        "memchr" | "__builtin_memchr" => Some(CanonicalRuntimeFunction::Memchr),
        _ => None,
    }
}

fn var(name: &str) -> DaExpr {
    DaExpr::Var(name.to_owned())
}

fn call(name: &str, args: Vec<DaExpr>) -> DaExpr {
    DaExpr::Call(Box::new(var(name)), args)
}

fn op(op: &'static str, left: DaExpr, right: DaExpr) -> DaExpr {
    DaExpr::Op2 {
        op,
        left: Box::new(left),
        right: Box::new(right),
    }
}

fn assign(name: &str, value: DaExpr) -> DaStmt {
    DaStmt::Expr(DaExpr::Assign(Box::new(var(name)), Box::new(value)))
}

fn ret(value: DaExpr) -> DaStmt {
    DaStmt::Expr(DaExpr::Return(Some(Box::new(value))))
}

fn block(stmts: Vec<DaStmt>) -> Box<DaExpr> {
    Box::new(DaExpr::Block(DaBlock { stmts }))
}

fn uint_to_int(expr: DaExpr) -> DaExpr {
    DaExpr::Cast {
        kind: CastKind::Cast,
        expr: Box::new(expr),
        to: DaType::int(),
    }
}

fn uint_to_uint8(expr: DaExpr) -> DaExpr {
    DaExpr::Cast {
        kind: CastKind::Cast,
        expr: Box::new(expr),
        to: DaType::uint8(),
    }
}

fn byte_to_uint(expr: DaExpr) -> DaExpr {
    DaExpr::Cast {
        kind: CastKind::Cast,
        expr: Box::new(expr),
        to: DaType::uint(),
    }
}

fn heap_address(offset: DaExpr) -> DaExpr {
    // intptr(addr(heap[int(offset)])) is the sole pointer->raw-address
    // conversion used by the runtime.
    DaExpr::Unsafe(Box::new(call(
        "intptr",
        vec![DaExpr::Unsafe(Box::new(DaExpr::Addr(Box::new(
            DaExpr::Index(Box::new(var(HEAP)), Box::new(uint_to_int(offset))),
        ))))],
    )))
}

fn raw_byte_at(address: DaExpr, offset: DaExpr) -> DaExpr {
    // The runtime owns the only raw-address -> typed-pointer conversion used
    // for byte-wise libc operations.  Source-level pointer lowering must not
    // manufacture this representation itself.
    DaExpr::Unsafe(Box::new(DaExpr::Index(
        Box::new(DaExpr::Unsafe(Box::new(DaExpr::Cast {
            kind: CastKind::Reinterpret,
            expr: Box::new(address),
            to: DaType::pointer(DaType::uint8()),
        }))),
        Box::new(uint_to_int(offset)),
    )))
}

fn function(name: &str, params: Vec<DaStmt>, ret_type: DaType, stmts: Vec<DaStmt>) -> DaDecl {
    DaDecl::Function(DaFunction {
        name: name.to_owned(),
        params,
        ret_type,
        body: Some(DaExpr::Block(DaBlock { stmts })),
        annotations: vec![],
        is_public: false,
        is_unsafe: false,
    })
}

/// Emits the first canonical raw-memory runtime slice.
///
/// Call lowering is intentionally added separately in `functions.rs`; keeping
/// generation and source-call policy separate prevents fixture-specific libc
/// behavior from leaking into the AST printer.
pub fn declarations() -> Vec<DaDecl> {
    let bytes = DaType::array(DaType::uint8());
    let uint64 = DaType::uint64();
    let bools = DaType::array(DaType::bool());

    let init_heap = function(
        "c2da_rt_init_heap",
        vec![],
        DaType::void(),
        vec![DaStmt::Expr(DaExpr::IfThenElse {
            cond: Box::new(op(
                "==",
                call("length", vec![var(HEAP)]),
                DaExpr::ConstInt(0),
            )),
            then: block(vec![
                DaStmt::Expr(call(
                    "reserve",
                    vec![
                        var(HEAP),
                        uint_to_int(DaExpr::ConstUInt(HEAP_RESERVE_BYTES)),
                    ],
                )),
                // `addr(heap[0])` needs a materialized first byte even for an
                // allocation request of size zero.
                DaStmt::Expr(call("resize", vec![var(HEAP), DaExpr::ConstInt(1)])),
            ]),
            elifs: vec![],
            else_: None,
        })],
    );

    // Fixture runners may execute several independent probes in one daScript
    // process.  This is an explicit runtime API, not a translated fixture
    // allocator: it invalidates the current arena allocation records exactly
    // as the C reference fixture resets its bump allocator.
    let reset = function(
        "c2da_rt_reset",
        vec![],
        DaType::void(),
        vec![
            assign(NEXT, DaExpr::ConstUInt(0)),
            DaStmt::Expr(call("resize", vec![var(ALLOC_ADDRS), DaExpr::ConstInt(0)])),
            DaStmt::Expr(call("resize", vec![var(ALLOC_SIZES), DaExpr::ConstInt(0)])),
            DaStmt::Expr(call("resize", vec![var(ALLOC_LIVE), DaExpr::ConstInt(0)])),
        ],
    );

    let malloc = function(
        "c2da_rt_malloc",
        vec![DaStmt::Param {
            name: "size".to_owned(),
            param_type: uint64.clone(),
            default: None,
            is_mutable: false,
        }],
        uint64.clone(),
        vec![
            DaStmt::Expr(call("c2da_rt_init_heap", vec![])),
            DaStmt::Expr(DaExpr::IfThenElse {
                cond: Box::new(op("==", var("size"), DaExpr::ConstUInt(0))),
                then: block(vec![ret(DaExpr::ConstUInt(0))]),
                elifs: vec![],
                else_: None,
            }),
            DaStmt::Var {
                name: "start".to_owned(),
                var_type: uint64.clone(),
                init: Some(var(NEXT)),
            },
            DaStmt::Var {
                name: "end".to_owned(),
                var_type: uint64.clone(),
                init: Some(op("+", var("start"), var("size"))),
            },
            DaStmt::Expr(DaExpr::IfThenElse {
                cond: Box::new(op(">", var("end"), DaExpr::ConstUInt(HEAP_RESERVE_BYTES))),
                then: block(vec![ret(DaExpr::ConstUInt(0))]),
                elifs: vec![],
                else_: None,
            }),
            DaStmt::Expr(DaExpr::IfThenElse {
                cond: Box::new(op(
                    ">",
                    uint_to_int(var("end")),
                    call("length", vec![var(HEAP)]),
                )),
                then: block(vec![DaStmt::Expr(call(
                    "resize",
                    vec![var(HEAP), uint_to_int(var("end"))],
                ))]),
                elifs: vec![],
                else_: None,
            }),
            assign(NEXT, var("end")),
            // The raw-address ABI exposes the actual address of the reserved
            // arena.  Bookkeeping must retain that same value: `start` is an
            // arena-relative offset and is only meaningful while deriving this
            // address, never as an allocation identity.
            DaStmt::Var {
                name: "address".to_owned(),
                var_type: uint64.clone(),
                init: Some(heap_address(var("start"))),
            },
            // Allocation metadata is deliberately separate from the raw byte
            // arena: free/realloc must never infer an allocation boundary from
            // a typed C pointer.
            DaStmt::Var {
                name: "record".to_owned(),
                var_type: uint64.clone(),
                init: Some(DaExpr::Cast {
                    kind: CastKind::Cast,
                    expr: Box::new(call("length", vec![var(ALLOC_ADDRS)])),
                    to: uint64.clone(),
                }),
            },
            DaStmt::Expr(call(
                "resize",
                vec![
                    var(ALLOC_ADDRS),
                    uint_to_int(op("+", var("record"), DaExpr::ConstUInt(1))),
                ],
            )),
            DaStmt::Expr(call(
                "resize",
                vec![
                    var(ALLOC_SIZES),
                    uint_to_int(op("+", var("record"), DaExpr::ConstUInt(1))),
                ],
            )),
            DaStmt::Expr(call(
                "resize",
                vec![
                    var(ALLOC_LIVE),
                    uint_to_int(op("+", var("record"), DaExpr::ConstUInt(1))),
                ],
            )),
            DaStmt::Expr(DaExpr::Assign(
                Box::new(DaExpr::Index(
                    Box::new(var(ALLOC_ADDRS)),
                    Box::new(uint_to_int(var("record"))),
                )),
                Box::new(var("address")),
            )),
            DaStmt::Expr(DaExpr::Assign(
                Box::new(DaExpr::Index(
                    Box::new(var(ALLOC_SIZES)),
                    Box::new(uint_to_int(var("record"))),
                )),
                Box::new(var("size")),
            )),
            DaStmt::Expr(DaExpr::Assign(
                Box::new(DaExpr::Index(
                    Box::new(var(ALLOC_LIVE)),
                    Box::new(uint_to_int(var("record"))),
                )),
                Box::new(DaExpr::ConstBool(true)),
            )),
            ret(var("address")),
        ],
    );

    let free = function(
        "c2da_rt_free",
        vec![DaStmt::Param {
            name: "address".to_owned(),
            param_type: uint64.clone(),
            default: None,
            is_mutable: false,
        }],
        DaType::void(),
        vec![
            DaStmt::Var {
                name: "i".to_owned(),
                var_type: uint64.clone(),
                init: Some(DaExpr::ConstUInt(0)),
            },
            DaStmt::Expr(DaExpr::While(
                Box::new(op(
                    "<",
                    uint_to_int(var("i")),
                    call("length", vec![var(ALLOC_ADDRS)]),
                )),
                block(vec![
                    DaStmt::Expr(DaExpr::IfThenElse {
                        cond: Box::new(op(
                            "&&",
                            DaExpr::Index(
                                Box::new(var(ALLOC_LIVE)),
                                Box::new(uint_to_int(var("i"))),
                            ),
                            op(
                                "==",
                                DaExpr::Index(
                                    Box::new(var(ALLOC_ADDRS)),
                                    Box::new(uint_to_int(var("i"))),
                                ),
                                var("address"),
                            ),
                        )),
                        then: block(vec![
                            DaStmt::Expr(DaExpr::Assign(
                                Box::new(DaExpr::Index(
                                    Box::new(var(ALLOC_LIVE)),
                                    Box::new(uint_to_int(var("i"))),
                                )),
                                Box::new(DaExpr::ConstBool(false)),
                            )),
                            DaStmt::Expr(DaExpr::Return(None)),
                        ]),
                        elifs: vec![],
                        else_: None,
                    }),
                    assign("i", op("+", var("i"), DaExpr::ConstUInt(1))),
                ]),
            )),
        ],
    );

    let realloc = function(
        "c2da_rt_realloc",
        vec![
            DaStmt::Param {
                name: "address".to_owned(),
                param_type: uint64.clone(),
                default: None,
                is_mutable: false,
            },
            DaStmt::Param {
                name: "size".to_owned(),
                param_type: uint64.clone(),
                default: None,
                is_mutable: false,
            },
        ],
        uint64.clone(),
        vec![
            DaStmt::Expr(DaExpr::IfThenElse {
                cond: Box::new(op("==", var("address"), DaExpr::ConstUInt(0))),
                then: block(vec![ret(call("c2da_rt_malloc", vec![var("size")]))]),
                elifs: vec![],
                else_: None,
            }),
            DaStmt::Expr(DaExpr::IfThenElse {
                cond: Box::new(op("==", var("size"), DaExpr::ConstUInt(0))),
                then: block(vec![
                    DaStmt::Expr(call("c2da_rt_free", vec![var("address")])),
                    ret(DaExpr::ConstUInt(0)),
                ]),
                elifs: vec![],
                else_: None,
            }),
            DaStmt::Var {
                name: "i".to_owned(),
                var_type: uint64.clone(),
                init: Some(DaExpr::ConstUInt(0)),
            },
            DaStmt::Var {
                name: "old_size".to_owned(),
                var_type: uint64.clone(),
                init: Some(DaExpr::ConstUInt(0)),
            },
            DaStmt::Var {
                name: "found".to_owned(),
                var_type: DaType::bool(),
                init: Some(DaExpr::ConstBool(false)),
            },
            DaStmt::Expr(DaExpr::While(
                Box::new(op(
                    "<",
                    uint_to_int(var("i")),
                    call("length", vec![var(ALLOC_ADDRS)]),
                )),
                block(vec![
                    DaStmt::Expr(DaExpr::IfThenElse {
                        cond: Box::new(op(
                            "&&",
                            DaExpr::Index(
                                Box::new(var(ALLOC_LIVE)),
                                Box::new(uint_to_int(var("i"))),
                            ),
                            op(
                                "==",
                                DaExpr::Index(
                                    Box::new(var(ALLOC_ADDRS)),
                                    Box::new(uint_to_int(var("i"))),
                                ),
                                var("address"),
                            ),
                        )),
                        then: block(vec![
                            assign(
                                "old_size",
                                DaExpr::Index(
                                    Box::new(var(ALLOC_SIZES)),
                                    Box::new(uint_to_int(var("i"))),
                                ),
                            ),
                            assign("found", DaExpr::ConstBool(true)),
                        ]),
                        elifs: vec![],
                        else_: None,
                    }),
                    assign("i", op("+", var("i"), DaExpr::ConstUInt(1))),
                ]),
            )),
            DaStmt::Expr(DaExpr::IfThenElse {
                cond: Box::new(op("==", var("found"), DaExpr::ConstBool(false))),
                then: block(vec![ret(DaExpr::ConstUInt(0))]),
                elifs: vec![],
                else_: None,
            }),
            DaStmt::Var {
                name: "replacement".to_owned(),
                var_type: uint64.clone(),
                init: Some(call("c2da_rt_malloc", vec![var("size")])),
            },
            DaStmt::Expr(DaExpr::IfThenElse {
                cond: Box::new(op("==", var("replacement"), DaExpr::ConstUInt(0))),
                then: block(vec![ret(DaExpr::ConstUInt(0))]),
                elifs: vec![],
                else_: None,
            }),
            DaStmt::Var {
                name: "copy_size".to_owned(),
                var_type: uint64.clone(),
                init: Some(DaExpr::ConstUInt(0)),
            },
            DaStmt::Expr(DaExpr::IfThenElse {
                cond: Box::new(op("<", var("old_size"), var("size"))),
                then: block(vec![assign("copy_size", var("old_size"))]),
                elifs: vec![],
                else_: Some(block(vec![assign("copy_size", var("size"))])),
            }),
            DaStmt::Expr(call(
                "c2da_rt_memcpy",
                vec![var("replacement"), var("address"), var("copy_size")],
            )),
            DaStmt::Expr(call("c2da_rt_free", vec![var("address")])),
            ret(var("replacement")),
        ],
    );

    let memset = function(
        "c2da_rt_memset",
        vec![
            DaStmt::Param {
                name: "dst".to_owned(),
                param_type: uint64.clone(),
                default: None,
                is_mutable: false,
            },
            DaStmt::Param {
                name: "value".to_owned(),
                param_type: DaType::uint8(),
                default: None,
                is_mutable: false,
            },
            DaStmt::Param {
                name: "count".to_owned(),
                param_type: uint64.clone(),
                default: None,
                is_mutable: false,
            },
        ],
        uint64.clone(),
        vec![
            DaStmt::Var {
                name: "i".to_owned(),
                var_type: uint64.clone(),
                init: Some(DaExpr::ConstUInt(0)),
            },
            DaStmt::Expr(DaExpr::While(
                Box::new(op("<", var("i"), var("count"))),
                block(vec![
                    DaStmt::Expr(DaExpr::Assign(
                        Box::new(raw_byte_at(var("dst"), var("i"))),
                        Box::new(var("value")),
                    )),
                    assign("i", op("+", var("i"), DaExpr::ConstUInt(1))),
                ]),
            )),
            ret(var("dst")),
        ],
    );

    let calloc = function(
        "c2da_rt_calloc",
        vec![
            DaStmt::Param {
                name: "count".to_owned(),
                param_type: uint64.clone(),
                default: None,
                is_mutable: false,
            },
            DaStmt::Param {
                name: "size".to_owned(),
                param_type: uint64.clone(),
                default: None,
                is_mutable: false,
            },
        ],
        uint64.clone(),
        vec![
            DaStmt::Var {
                name: "total".to_owned(),
                var_type: uint64.clone(),
                init: Some(op("*", var("count"), var("size"))),
            },
            // C calloc must fail rather than wrapping a multiplication.
            DaStmt::Expr(DaExpr::IfThenElse {
                cond: Box::new(op(
                    "&&",
                    op("!=", var("size"), DaExpr::ConstUInt(0)),
                    op("!=", op("/", var("total"), var("size")), var("count")),
                )),
                then: block(vec![ret(DaExpr::ConstUInt(0))]),
                elifs: vec![],
                else_: None,
            }),
            DaStmt::Var {
                name: "address".to_owned(),
                var_type: uint64.clone(),
                init: Some(call("c2da_rt_malloc", vec![var("total")])),
            },
            DaStmt::Expr(DaExpr::IfThenElse {
                cond: Box::new(op("!=", var("address"), DaExpr::ConstUInt(0))),
                then: block(vec![DaStmt::Expr(call(
                    "c2da_rt_memset",
                    vec![
                        var("address"),
                        uint_to_uint8(DaExpr::ConstUInt(0)),
                        var("total"),
                    ],
                ))]),
                elifs: vec![],
                else_: None,
            }),
            ret(var("address")),
        ],
    );

    let memcpy = function(
        "c2da_rt_memcpy",
        vec![
            DaStmt::Param {
                name: "dst".to_owned(),
                param_type: uint64.clone(),
                default: None,
                is_mutable: false,
            },
            DaStmt::Param {
                name: "src".to_owned(),
                param_type: uint64.clone(),
                default: None,
                is_mutable: false,
            },
            DaStmt::Param {
                name: "count".to_owned(),
                param_type: uint64.clone(),
                default: None,
                is_mutable: false,
            },
        ],
        uint64.clone(),
        vec![
            DaStmt::Var {
                name: "i".to_owned(),
                var_type: uint64.clone(),
                init: Some(DaExpr::ConstUInt(0)),
            },
            DaStmt::Expr(DaExpr::While(
                Box::new(op("<", var("i"), var("count"))),
                block(vec![
                    DaStmt::Expr(DaExpr::Assign(
                        Box::new(raw_byte_at(var("dst"), var("i"))),
                        Box::new(raw_byte_at(var("src"), var("i"))),
                    )),
                    assign("i", op("+", var("i"), DaExpr::ConstUInt(1))),
                ]),
            )),
            ret(var("dst")),
        ],
    );

    let memcmp = function(
        "c2da_rt_memcmp",
        vec![
            DaStmt::Param {
                name: "left".to_owned(),
                param_type: uint64.clone(),
                default: None,
                is_mutable: false,
            },
            DaStmt::Param {
                name: "right".to_owned(),
                param_type: uint64.clone(),
                default: None,
                is_mutable: false,
            },
            DaStmt::Param {
                name: "count".to_owned(),
                param_type: uint64.clone(),
                default: None,
                is_mutable: false,
            },
        ],
        DaType::int(),
        vec![
            DaStmt::Var {
                name: "i".to_owned(),
                var_type: uint64.clone(),
                init: Some(DaExpr::ConstUInt(0)),
            },
            DaStmt::Expr(DaExpr::While(
                Box::new(op("<", var("i"), var("count"))),
                block(vec![
                    DaStmt::Expr(DaExpr::IfThenElse {
                        cond: Box::new(op(
                            "<",
                            byte_to_uint(raw_byte_at(var("left"), var("i"))),
                            byte_to_uint(raw_byte_at(var("right"), var("i"))),
                        )),
                        then: block(vec![ret(DaExpr::ConstInt(-1))]),
                        elifs: vec![],
                        else_: None,
                    }),
                    DaStmt::Expr(DaExpr::IfThenElse {
                        cond: Box::new(op(
                            ">",
                            byte_to_uint(raw_byte_at(var("left"), var("i"))),
                            byte_to_uint(raw_byte_at(var("right"), var("i"))),
                        )),
                        then: block(vec![ret(DaExpr::ConstInt(1))]),
                        elifs: vec![],
                        else_: None,
                    }),
                    assign("i", op("+", var("i"), DaExpr::ConstUInt(1))),
                ]),
            )),
            ret(DaExpr::ConstInt(0)),
        ],
    );

    let memmove = function(
        "c2da_rt_memmove",
        vec![
            DaStmt::Param {
                name: "dst".to_owned(),
                param_type: uint64.clone(),
                default: None,
                is_mutable: false,
            },
            DaStmt::Param {
                name: "src".to_owned(),
                param_type: uint64.clone(),
                default: None,
                is_mutable: false,
            },
            DaStmt::Param {
                name: "count".to_owned(),
                param_type: uint64.clone(),
                default: None,
                is_mutable: false,
            },
        ],
        uint64.clone(),
        vec![
            // Forward copying is valid when destination begins before source.
            DaStmt::Expr(DaExpr::IfThenElse {
                cond: Box::new(op("<", var("dst"), var("src"))),
                then: block(vec![
                    DaStmt::Var {
                        name: "i".to_owned(),
                        var_type: uint64.clone(),
                        init: Some(DaExpr::ConstUInt(0)),
                    },
                    DaStmt::Expr(DaExpr::While(
                        Box::new(op("<", var("i"), var("count"))),
                        block(vec![
                            DaStmt::Expr(DaExpr::Assign(
                                Box::new(raw_byte_at(var("dst"), var("i"))),
                                Box::new(raw_byte_at(var("src"), var("i"))),
                            )),
                            assign("i", op("+", var("i"), DaExpr::ConstUInt(1))),
                        ]),
                    )),
                ]),
                elifs: vec![],
                else_: Some(block(vec![
                    // Backward copying protects a source range that starts at
                    // or before the destination range.
                    DaStmt::Var {
                        name: "i".to_owned(),
                        var_type: uint64.clone(),
                        init: Some(var("count")),
                    },
                    DaStmt::Expr(DaExpr::While(
                        Box::new(op(">", var("i"), DaExpr::ConstUInt(0))),
                        block(vec![
                            assign("i", op("-", var("i"), DaExpr::ConstUInt(1))),
                            DaStmt::Expr(DaExpr::Assign(
                                Box::new(raw_byte_at(var("dst"), var("i"))),
                                Box::new(raw_byte_at(var("src"), var("i"))),
                            )),
                        ]),
                    )),
                ])),
            }),
            ret(var("dst")),
        ],
    );

    let memchr = function(
        "c2da_rt_memchr",
        vec![
            DaStmt::Param {
                name: "src".to_owned(),
                param_type: uint64.clone(),
                default: None,
                is_mutable: false,
            },
            DaStmt::Param {
                name: "value".to_owned(),
                param_type: DaType::uint8(),
                default: None,
                is_mutable: false,
            },
            DaStmt::Param {
                name: "count".to_owned(),
                param_type: uint64.clone(),
                default: None,
                is_mutable: false,
            },
        ],
        uint64.clone(),
        vec![
            DaStmt::Var {
                name: "i".to_owned(),
                var_type: uint64.clone(),
                init: Some(DaExpr::ConstUInt(0)),
            },
            DaStmt::Expr(DaExpr::While(
                Box::new(op("<", var("i"), var("count"))),
                block(vec![
                    DaStmt::Expr(DaExpr::IfThenElse {
                        cond: Box::new(op("==", raw_byte_at(var("src"), var("i")), var("value"))),
                        then: block(vec![ret(op("+", var("src"), var("i")))]),
                        elifs: vec![],
                        else_: None,
                    }),
                    assign("i", op("+", var("i"), DaExpr::ConstUInt(1))),
                ]),
            )),
            ret(DaExpr::ConstUInt(0)),
        ],
    );

    vec![
        DaDecl::Variable(DaVariable {
            name: HEAP.to_owned(),
            var_type: bytes,
            init: None,
            annotations: vec![],
        }),
        DaDecl::Variable(DaVariable {
            name: NEXT.to_owned(),
            var_type: uint64,
            init: Some(DaExpr::ConstUInt(0)),
            annotations: vec![],
        }),
        DaDecl::Variable(DaVariable {
            name: ALLOC_ADDRS.to_owned(),
            var_type: DaType::array(DaType::uint64()),
            init: None,
            annotations: vec![],
        }),
        DaDecl::Variable(DaVariable {
            name: ALLOC_SIZES.to_owned(),
            var_type: DaType::array(DaType::uint64()),
            init: None,
            annotations: vec![],
        }),
        DaDecl::Variable(DaVariable {
            name: ALLOC_LIVE.to_owned(),
            var_type: bools,
            init: None,
            annotations: vec![],
        }),
        init_heap,
        reset,
        malloc,
        free,
        realloc,
        memset,
        calloc,
        memcpy,
        memcmp,
        memmove,
        memchr,
    ]
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn runtime_is_ast_generated_and_uses_explicit_pointer_to_address_conversion() {
        let rendered = declarations()
            .into_iter()
            .map(|decl| decl.to_string())
            .collect::<Vec<_>>()
            .join("\n");

        assert!(rendered.contains("def c2da_rt_malloc"));
        assert!(rendered.contains("def c2da_rt_memset"));
        assert!(rendered.contains("def c2da_rt_calloc"));
        assert!(rendered.contains("def c2da_rt_memcpy"));
        assert!(rendered.contains("def c2da_rt_memcmp"));
        assert!(rendered.contains("def c2da_rt_memmove"));
        assert!(rendered.contains("def c2da_rt_memchr"));
        assert!(rendered.contains("def c2da_rt_free"));
        assert!(rendered.contains("def c2da_rt_realloc"));
        assert!(rendered.contains("def c2da_rt_reset"));
        assert!(rendered.contains("resize(c2da_rt_alloc_addrs, 0)"));
        assert!(rendered.contains("c2da_rt_memset(address, uint8("));
        assert!(rendered.contains("reserve(c2da_rt_heap"));
        assert!(rendered.contains("c2da_rt_alloc_addrs[int(record)] = address"));
        assert!(rendered.contains("intptr(unsafe(addr(c2da_rt_heap[int(start)])))"));
        assert!(!rendered.contains(".replace("));
    }

    #[test]
    fn runtime_registry_owns_every_lowered_libc_symbol_and_its_abi() {
        for (source, target) in [
            ("malloc", "c2da_rt_malloc"),
            ("calloc", "c2da_rt_calloc"),
            ("realloc", "c2da_rt_realloc"),
            ("free", "c2da_rt_free"),
            ("memset", "c2da_rt_memset"),
            ("memcpy", "c2da_rt_memcpy"),
            ("memmove", "c2da_rt_memmove"),
            ("memcmp", "c2da_rt_memcmp"),
            ("memchr", "c2da_rt_memchr"),
        ] {
            let runtime = canonical_runtime_function(source).expect("registered libc symbol");
            assert_eq!(runtime.target_name(), target);
        }
        assert_eq!(
            canonical_runtime_function("memset").unwrap().arg_kind(1),
            Some(RuntimeArgKind::UInt8)
        );
        assert_eq!(
            canonical_runtime_function("memcpy").unwrap().arg_kind(0),
            Some(RuntimeArgKind::RawAddress)
        );
        assert_eq!(
            canonical_runtime_function("calloc").unwrap().arg_kind(1),
            Some(RuntimeArgKind::UInt64)
        );
    }
}
