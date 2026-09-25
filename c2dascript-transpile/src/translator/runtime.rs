//! Canonical daScript raw-memory runtime.
//!
//! This module deliberately builds `DaDecl`/`DaExpr` values.  It must never
//! repair printed text: all C/libc ABI boundaries are represented explicitly
//! in the generated AST.

use das_ast::{CastKind, DaBlock, DaDecl, DaExpr, DaFunction, DaStmt, DaType, DaVariable};

/// One allocation arena is reserved before an address is exposed.  Later
/// `resize` calls stay inside that reservation, so the array never reallocates
/// and a C pointer returned from `c2da_rt_malloc` does not move when a later
/// allocation grows the heap.
///
/// The reservation is address space, not memory: daslang's `reserve` does not
/// touch the pages (measured: a daslang program's maximum RSS is the same with
/// no reserve and with a 64 MiB, 256 MiB, 1 GiB or 1.5 GiB one), and only the
/// bytes below the allocation high-water mark are ever `resize`d, i.e. zeroed
/// and committed.  Heap offsets and sizes stay `uint64` in the runtime: the
/// arena is grown with the `int64` `resize` overload and indexed with the
/// 64-bit offset itself, so no size is narrowed to daslang's 32-bit `int`.  A
/// request past the reserve is refused (`malloc` returns `NULL`, as C's may),
/// never truncated.
pub const HEAP_RESERVE_BYTES: u64 = 1024 * 1024 * 1024;

/// C's `malloc` returns storage aligned for any object type, 16 bytes on the
/// supported targets (`alignof(max_align_t)`).  Every block starts at an
/// address that is a multiple of this, and every block capacity is one.
const HEAP_ALIGN_BYTES: u64 = 16;

// Allocation records and free-list slots are `int` indices (one record per
// block, every block at least `HEAP_ALIGN_BYTES` long), so the reserve must not
// hold more blocks than an `int` can count.
const _: () = assert!(HEAP_RESERVE_BYTES / HEAP_ALIGN_BYTES <= i32::MAX as u64);

const HEAP: &str = "c2da_rt_heap";
/// Arena offset of the first byte no block has ever covered (the bump pointer).
const NEXT: &str = "c2da_rt_next";
/// One record per block ever carved from the arena, in arena order: records are
/// only appended by the bump path, so `ALLOC_ADDRS` is sorted by address and a
/// block is found by binary search.
const ALLOC_ADDRS: &str = "c2da_rt_alloc_addrs";
/// A block's capacity in bytes (a multiple of `HEAP_ALIGN_BYTES`, at least the
/// size it was requested with); it stays with the block across reuse.
const ALLOC_SIZES: &str = "c2da_rt_alloc_sizes";
const ALLOC_LIVE: &str = "c2da_rt_alloc_live";
/// Indices of the records that are not live: the blocks `malloc` may reuse.
const ALLOC_FREE: &str = "c2da_rt_alloc_free";
/// Addresses of frame-scoped C objects, innermost frame last.
const LOCALS: &str = "c2da_rt_locals";

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

    /// The daslang builtin a source-level call of this function lowers to
    /// instead of its `c2da_rt_*` helper, if any.
    ///
    /// daslang's own `memcpy`/`memmove` (the `uint64`-size overloads) copy
    /// between two real pointers, and a raw address *is* a real pointer, so a
    /// C copy crosses to them directly rather than through a daslang byte
    /// loop.  They return nothing; the call site keeps C's `dst` result
    /// itself.  The helpers stay: the runtime's own `realloc` and the
    /// storage-backed object copies still call `c2da_rt_memcpy`.
    pub(crate) fn builtin_copy(self) -> Option<&'static str> {
        match self {
            Self::Memcpy => Some("memcpy"),
            Self::Memmove => Some("memmove"),
            _ => None,
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

/// A `uint64` size or offset as the `int64` that daslang's 64-bit
/// `resize`/`reserve` overloads and `long_length` use.  Every value converted
/// is bounded by `HEAP_RESERVE_BYTES`, so it is exact.
fn uint_to_int64(expr: DaExpr) -> DaExpr {
    DaExpr::Cast {
        kind: CastKind::Cast,
        expr: Box::new(expr),
        to: DaType::int64(),
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
    // intptr(addr(heap[offset])) is the sole pointer->raw-address conversion
    // used by the runtime.  The `uint64` offset indexes the array directly:
    // daslang bounds-checks a 64-bit index as a 64-bit value.
    DaExpr::Unsafe(Box::new(call(
        "intptr",
        vec![DaExpr::Unsafe(Box::new(DaExpr::Addr(Box::new(
            DaExpr::Index(Box::new(var(HEAP)), Box::new(offset)),
        ))))],
    )))
}

fn raw_byte_at(address: DaExpr, offset: DaExpr) -> DaExpr {
    // The runtime owns the only raw-address -> typed-pointer conversion used
    // for byte-wise libc operations.  Source-level pointer lowering must not
    // manufacture this representation itself.  The `uint64` offset indexes
    // the pointer directly, so a count past 2^31 does not wrap to a negative
    // `int` offset.
    DaExpr::Unsafe(Box::new(DaExpr::Index(
        Box::new(DaExpr::Unsafe(Box::new(DaExpr::Cast {
            kind: CastKind::Reinterpret,
            expr: Box::new(address),
            to: DaType::pointer(DaType::uint8()),
        }))),
        Box::new(offset),
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

fn param(name: &str, param_type: DaType) -> DaStmt {
    DaStmt::Param {
        name: name.to_owned(),
        param_type,
        default: None,
        is_mutable: false,
    }
}

fn let_var(name: &str, var_type: DaType, init: DaExpr) -> DaStmt {
    DaStmt::Var {
        name: name.to_owned(),
        var_type,
        init: Some(init),
    }
}

fn when(cond: DaExpr, then: Vec<DaStmt>) -> DaStmt {
    DaStmt::Expr(DaExpr::IfThenElse {
        cond: Box::new(cond),
        then: block(then),
        elifs: vec![],
        else_: None,
    })
}

fn at(array: &str, index: DaExpr) -> DaExpr {
    DaExpr::Index(Box::new(var(array)), Box::new(index))
}

fn store(target: DaExpr, value: DaExpr) -> DaStmt {
    DaStmt::Expr(DaExpr::Assign(Box::new(target), Box::new(value)))
}

fn length_of(array: &str) -> DaExpr {
    call("length", vec![var(array)])
}

/// The 64-bit element count of `array` (`long_length`), for comparisons with
/// and conversions to a `uint64` size.
fn long_length_of(array: &str) -> DaExpr {
    call("long_length", vec![var(array)])
}

/// `value` rounded up to a multiple of `HEAP_ALIGN_BYTES`.  `value` is a
/// size already bounded by `HEAP_RESERVE_BYTES` or an address inside the
/// arena, so the addition cannot wrap.
fn align_up(value: DaExpr) -> DaExpr {
    op(
        "*",
        op(
            "/",
            op("+", value, DaExpr::ConstUInt(HEAP_ALIGN_BYTES - 1)),
            DaExpr::ConstUInt(HEAP_ALIGN_BYTES),
        ),
        DaExpr::ConstUInt(HEAP_ALIGN_BYTES),
    )
}

/// Grows the materialized arena to `end` bytes (never past the reserve, which
/// the caller has checked), so `addr(heap[offset])` is valid below `end`.
fn materialize_heap_to(end: DaExpr) -> DaStmt {
    when(
        op(">", uint_to_int64(end.clone()), long_length_of(HEAP)),
        vec![DaStmt::Expr(call(
            "resize",
            vec![var(HEAP), uint_to_int64(end)],
        ))],
    )
}

/// `let address = c2da_rt_calloc(1, size + 1)`, then a panic when the arena
/// cannot hold it.  C's `malloc` may return `NULL`, but a C object with
/// automatic or static storage duration cannot fail to exist: a `NULL` here
/// would be dereferenced as the object's address, so running out of the
/// reserve stops the program with a message instead.
fn object_storage(what: &str) -> Vec<DaStmt> {
    vec![
        DaStmt::Let {
            name: "address".to_owned(),
            init: Some(call(
                "c2da_rt_calloc",
                vec![
                    DaExpr::Cast {
                        kind: CastKind::Cast,
                        expr: Box::new(DaExpr::ConstUInt(1)),
                        to: DaType::uint64(),
                    },
                    op("+", var("size"), DaExpr::ConstUInt(1)),
                ],
            )),
        },
        when(
            op("==", var("address"), DaExpr::ConstUInt(0)),
            vec![DaStmt::Expr(call(
                "panic",
                vec![DaExpr::ConstString(format!(
                    "c2da runtime: the {HEAP_RESERVE_BYTES}-byte heap reserve cannot hold \
                     storage for {what}"
                ))],
            ))],
        ),
    ]
}

/// The daScript parameter count of the runtime function `name`, or `None` when
/// the runtime emits no function by that name.
///
/// This is the single source of truth for "the compiler-owned runtime defines
/// this symbol".  It is derived from [`declarations`] itself, so a runtime
/// function added there is never forgotten here.  Call classification consults
/// it so that a translation unit may declare a `c2da_rt_*` prototype (the
/// explicit runtime API, e.g. `c2da_rt_reset`) and call it, while an unknown
/// `c2da_rt_*` name still fails translation.
///
/// The set is rebuilt per query rather than cached: this is only reached when
/// classifying a body-less non-libc call, i.e. on the diagnostic path.
pub(crate) fn runtime_declared_arity(name: &str) -> Option<usize> {
    declarations().into_iter().find_map(|decl| match decl {
        DaDecl::Function(function) if function.name == name => Some(function.params.len()),
        _ => None,
    })
}

/// Whether the compiler-owned runtime emits a function called `name`.
pub(crate) fn runtime_declares(name: &str) -> bool {
    runtime_declared_arity(name).is_some()
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
            cond: Box::new(call("empty", vec![var(HEAP)])),
            then: block(vec![
                DaStmt::Expr(call(
                    "reserve",
                    vec![
                        var(HEAP),
                        uint_to_int64(DaExpr::ConstUInt(HEAP_RESERVE_BYTES)),
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
            DaStmt::Expr(call("resize", vec![var(ALLOC_FREE), DaExpr::ConstInt(0)])),
        ],
    );

    // The record of the block that starts at `address`, or -1.  Records are
    // appended in arena order, so the address column is sorted.
    let find_record = function(
        "c2da_rt_find_record",
        vec![param("address", uint64.clone())],
        DaType::int(),
        vec![
            let_var("lo", DaType::int(), DaExpr::ConstInt(0)),
            let_var("hi", DaType::int(), length_of(ALLOC_ADDRS)),
            DaStmt::Expr(DaExpr::While(
                Box::new(op("<", var("lo"), var("hi"))),
                block(vec![
                    let_var(
                        "mid",
                        DaType::int(),
                        op("/", op("+", var("lo"), var("hi")), DaExpr::ConstInt(2)),
                    ),
                    DaStmt::Expr(DaExpr::IfThenElse {
                        cond: Box::new(op("<", at(ALLOC_ADDRS, var("mid")), var("address"))),
                        then: block(vec![assign("lo", op("+", var("mid"), DaExpr::ConstInt(1)))]),
                        elifs: vec![],
                        else_: Some(block(vec![assign("hi", var("mid"))])),
                    }),
                ]),
            )),
            when(
                op(
                    "&&",
                    op("<", var("lo"), length_of(ALLOC_ADDRS)),
                    op("==", at(ALLOC_ADDRS, var("lo")), var("address")),
                ),
                vec![ret(var("lo"))],
            ),
            ret(DaExpr::ConstInt(-1)),
        ],
    );

    // Takes the best-fitting freed block of at least `need` bytes off the free
    // list and returns its record, or -1.  A block more than twice `need` is
    // not reused (blocks are never split), so a small request cannot pin a
    // large block.  The list is scanned newest first and an exact fit ends the
    // scan, so a free/malloc pair of one size is constant time.
    let take_free = function(
        "c2da_rt_take_free",
        vec![param("need", uint64.clone())],
        DaType::int(),
        vec![
            let_var("best", DaType::int(), DaExpr::ConstInt(-1)),
            let_var("best_slot", DaType::int(), DaExpr::ConstInt(-1)),
            let_var(
                "slot",
                DaType::int(),
                op("-", length_of(ALLOC_FREE), DaExpr::ConstInt(1)),
            ),
            DaStmt::Expr(DaExpr::While(
                Box::new(op(">=", var("slot"), DaExpr::ConstInt(0))),
                block(vec![
                    let_var("record", DaType::int(), at(ALLOC_FREE, var("slot"))),
                    let_var("capacity", uint64.clone(), at(ALLOC_SIZES, var("record"))),
                    when(
                        op(
                            "&&",
                            op(">=", var("capacity"), var("need")),
                            op("<=", op("-", var("capacity"), var("need")), var("need")),
                        ),
                        vec![
                            when(
                                op(
                                    "||",
                                    op("<", var("best"), DaExpr::ConstInt(0)),
                                    op("<", var("capacity"), at(ALLOC_SIZES, var("best"))),
                                ),
                                vec![
                                    assign("best", var("record")),
                                    assign("best_slot", var("slot")),
                                ],
                            ),
                            when(
                                op("==", var("capacity"), var("need")),
                                vec![DaStmt::Expr(DaExpr::Break)],
                            ),
                        ],
                    ),
                    assign("slot", op("-", var("slot"), DaExpr::ConstInt(1))),
                ]),
            )),
            when(
                op(">=", var("best"), DaExpr::ConstInt(0)),
                vec![
                    store(
                        at(ALLOC_FREE, var("best_slot")),
                        at(
                            ALLOC_FREE,
                            op("-", length_of(ALLOC_FREE), DaExpr::ConstInt(1)),
                        ),
                    ),
                    DaStmt::Expr(call("pop", vec![var(ALLOC_FREE)])),
                ],
            ),
            ret(var("best")),
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
            // Checked before rounding so `align_up` cannot wrap.
            when(
                op(">", var("size"), DaExpr::ConstUInt(HEAP_RESERVE_BYTES)),
                vec![ret(DaExpr::ConstUInt(0))],
            ),
            let_var("need", uint64.clone(), align_up(var("size"))),
            // A freed block is reused before the arena grows.  Its contents
            // are whatever its last owner left: C's malloc makes no promise,
            // and calloc clears what it returns itself.
            let_var(
                "reused",
                DaType::int(),
                call("c2da_rt_take_free", vec![var("need")]),
            ),
            when(
                op(">=", var("reused"), DaExpr::ConstInt(0)),
                vec![
                    store(at(ALLOC_LIVE, var("reused")), DaExpr::ConstBool(true)),
                    ret(at(ALLOC_ADDRS, var("reused"))),
                ],
            ),
            // The block starts at the first 16-aligned *address* at or after
            // the bump pointer; the arena's base address is fixed by the
            // reservation, so this is an arena offset like any other.
            let_var("base", uint64.clone(), heap_address(DaExpr::ConstUInt(0))),
            let_var(
                "start",
                uint64.clone(),
                op("-", align_up(op("+", var("base"), var(NEXT))), var("base")),
            ),
            let_var("end", uint64.clone(), op("+", var("start"), var("need"))),
            when(
                op(">", var("end"), DaExpr::ConstUInt(HEAP_RESERVE_BYTES)),
                vec![ret(DaExpr::ConstUInt(0))],
            ),
            materialize_heap_to(var("end")),
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
                    expr: Box::new(long_length_of(ALLOC_ADDRS)),
                    to: uint64.clone(),
                }),
            },
            DaStmt::Expr(call(
                "resize",
                vec![
                    var(ALLOC_ADDRS),
                    uint_to_int64(op("+", var("record"), DaExpr::ConstUInt(1))),
                ],
            )),
            DaStmt::Expr(call(
                "resize",
                vec![
                    var(ALLOC_SIZES),
                    uint_to_int64(op("+", var("record"), DaExpr::ConstUInt(1))),
                ],
            )),
            DaStmt::Expr(call(
                "resize",
                vec![
                    var(ALLOC_LIVE),
                    uint_to_int64(op("+", var("record"), DaExpr::ConstUInt(1))),
                ],
            )),
            store(at(ALLOC_ADDRS, var("record")), var("address")),
            store(at(ALLOC_SIZES, var("record")), var("need")),
            store(at(ALLOC_LIVE, var("record")), DaExpr::ConstBool(true)),
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
        // `free(NULL)`, a pointer that is not a block start and a second free
        // of one block find no live record and change nothing.
        vec![
            let_var(
                "record",
                DaType::int(),
                call("c2da_rt_find_record", vec![var("address")]),
            ),
            when(
                op(
                    "&&",
                    op(">=", var("record"), DaExpr::ConstInt(0)),
                    at(ALLOC_LIVE, var("record")),
                ),
                vec![
                    store(at(ALLOC_LIVE, var("record")), DaExpr::ConstBool(false)),
                    DaStmt::Expr(call("push", vec![var(ALLOC_FREE), var("record")])),
                ],
            ),
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
            let_var(
                "record",
                DaType::int(),
                call("c2da_rt_find_record", vec![var("address")]),
            ),
            when(
                op(
                    "||",
                    op("<", var("record"), DaExpr::ConstInt(0)),
                    op(
                        "==",
                        at(ALLOC_LIVE, var("record")),
                        DaExpr::ConstBool(false),
                    ),
                ),
                vec![ret(DaExpr::ConstUInt(0))],
            ),
            let_var("capacity", uint64.clone(), at(ALLOC_SIZES, var("record"))),
            // The block already holds `size` bytes: C keeps the object where
            // it is, contents unchanged.
            when(
                op("<=", var("size"), var("capacity")),
                vec![ret(var("address"))],
            ),
            when(
                op(">", var("size"), DaExpr::ConstUInt(HEAP_RESERVE_BYTES)),
                vec![ret(DaExpr::ConstUInt(0))],
            ),
            // The last block of the arena grows in place when the reserve
            // allows it: nothing lies behind it, so no live block moves.
            let_var("need", uint64.clone(), align_up(var("size"))),
            let_var(
                "start",
                uint64.clone(),
                op("-", var("address"), heap_address(DaExpr::ConstUInt(0))),
            ),
            let_var("end", uint64.clone(), op("+", var("start"), var("need"))),
            when(
                op(
                    "&&",
                    op("==", op("+", var("start"), var("capacity")), var(NEXT)),
                    op("<=", var("end"), DaExpr::ConstUInt(HEAP_RESERVE_BYTES)),
                ),
                vec![
                    materialize_heap_to(var("end")),
                    assign(NEXT, var("end")),
                    store(at(ALLOC_SIZES, var("record")), var("need")),
                    ret(var("address")),
                ],
            ),
            let_var(
                "replacement",
                uint64.clone(),
                call("c2da_rt_malloc", vec![var("size")]),
            ),
            when(
                op("==", var("replacement"), DaExpr::ConstUInt(0)),
                vec![ret(DaExpr::ConstUInt(0))],
            ),
            // `capacity < size` here, so the whole old block fits and covers
            // every byte C preserves (the old object's size is at most its
            // capacity; bytes past it were indeterminate in C).
            DaStmt::Expr(call(
                "c2da_rt_memcpy",
                vec![var("replacement"), var("address"), var("capacity")],
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

    // Frame-scoped storage for addressable C locals (the byte model gives
    // every aggregate, and every scalar whose address is taken, raw storage
    // with its C layout). A function that owns such objects brackets its body
    // with `c2da_rt_frame_enter` / `c2da_rt_frame_leave`; every `return`
    // leaves the frame first. This is the API contract; the implementation
    // below is the simplest correct one (objects are heap blocks released on
    // leave) and is replaced by the per-block allocator.
    let frame_enter = function(
        "c2da_rt_frame_enter",
        vec![],
        DaType::int(),
        vec![ret(call("length", vec![var(LOCALS)]))],
    );
    let frame_leave = function(
        "c2da_rt_frame_leave",
        vec![DaStmt::Param {
            name: "mark".to_owned(),
            param_type: DaType::int(),
            default: None,
            is_mutable: false,
        }],
        DaType::void(),
        vec![DaStmt::Expr(DaExpr::While(
            Box::new(op(">", call("length", vec![var(LOCALS)]), var("mark"))),
            block(vec![
                DaStmt::Expr(call(
                    "c2da_rt_free",
                    vec![DaExpr::Index(
                        Box::new(var(LOCALS)),
                        Box::new(op(
                            "-",
                            call("length", vec![var(LOCALS)]),
                            DaExpr::ConstInt(1),
                        )),
                    )],
                )),
                DaStmt::Expr(call("pop", vec![var(LOCALS)])),
            ]),
        ))],
    );
    let local = function(
        "c2da_rt_local",
        vec![
            DaStmt::Param {
                name: "size".to_owned(),
                param_type: uint64.clone(),
                default: None,
                is_mutable: false,
            },
            DaStmt::Param {
                name: "align".to_owned(),
                param_type: uint64.clone(),
                default: None,
                is_mutable: false,
            },
        ],
        uint64.clone(),
        {
            let mut stmts = object_storage("a C local");
            stmts.push(DaStmt::Expr(call(
                "push",
                vec![var(LOCALS), var("address")],
            )));
            stmts.push(ret(var("address")));
            stmts
        },
    );
    let static_ = function(
        "c2da_rt_static",
        vec![
            DaStmt::Param {
                name: "size".to_owned(),
                param_type: uint64.clone(),
                default: None,
                is_mutable: false,
            },
            DaStmt::Param {
                name: "align".to_owned(),
                param_type: uint64.clone(),
                default: None,
                is_mutable: false,
            },
        ],
        uint64.clone(),
        {
            let mut stmts = object_storage("a C static object");
            stmts.push(ret(var("address")));
            stmts
        },
    );

    vec![
        DaDecl::Variable(DaVariable {
            name: HEAP.to_owned(),
            var_type: bytes,
            init: None,
            annotations: vec![],
        }),
        DaDecl::Variable(DaVariable {
            name: LOCALS.to_owned(),
            var_type: DaType::array(DaType::uint64()),
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
        DaDecl::Variable(DaVariable {
            name: ALLOC_FREE.to_owned(),
            var_type: DaType::array(DaType::int()),
            init: None,
            annotations: vec![],
        }),
        init_heap,
        reset,
        find_record,
        take_free,
        malloc,
        free,
        realloc,
        memset,
        calloc,
        memcpy,
        memcmp,
        memmove,
        memchr,
        frame_enter,
        frame_leave,
        local,
        static_,
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
        assert!(rendered.contains("c2da_rt_memset(address, 0x0u8, total)"));
        assert!(rendered.contains("reserve(c2da_rt_heap"));
        assert!(rendered.contains("c2da_rt_alloc_addrs[record] = address"));
        assert!(rendered.contains("intptr(unsafe(addr(c2da_rt_heap[start])))"));
        assert!(!rendered.contains(".replace("));
    }

    #[test]
    fn heap_sizes_and_offsets_are_never_narrowed_to_int() {
        // A heap or record-table size is a `uint64`; narrowing it to `int`
        // would silently truncate past 2^31 instead of failing closed.
        let rendered = declarations()
            .into_iter()
            .map(|decl| decl.to_string())
            .collect::<Vec<_>>()
            .join("\n");
        for narrowing in [
            "resize(c2da_rt_heap, int(",
            "reserve(c2da_rt_heap, int(",
            "uint64(length(",
            "c2da_rt_heap[int(",
            "[int(record)]",
            "[int(i)]",
        ] {
            assert!(
                !rendered.contains(narrowing),
                "runtime narrows a size: {narrowing}\n{rendered}"
            );
        }
        let malloc = rendered_function("c2da_rt_malloc");
        assert!(malloc.contains("if (int64(end) > long_length(c2da_rt_heap)) {"));
        assert!(malloc.contains("resize(c2da_rt_heap, int64(end))"));
        assert!(malloc.contains("var record : uint64 = uint64(long_length(c2da_rt_alloc_addrs))"));
        assert!(malloc.contains("resize(c2da_rt_alloc_addrs, int64(record + 0x1))"));
        let memcpy = rendered_function("c2da_rt_memcpy");
        assert!(memcpy.contains("reinterpret<uint8?>(dst))[i]"));
    }

    #[test]
    fn object_storage_fails_closed_when_the_reserve_is_exhausted() {
        // C may see `NULL` from malloc, but not as the address of a local or
        // static object: the runtime panics instead of handing it out.
        for name in ["c2da_rt_local", "c2da_rt_static"] {
            let function = rendered_function(name);
            let check = function
                .find("if (address == 0x0) {")
                .unwrap_or_else(|| panic!("{name} checks its allocation:\n{function}"));
            assert!(function[check..].contains("panic(\"c2da runtime: the"));
            assert!(
                check
                    < function
                        .find("return address")
                        .expect("returns the address")
            );
        }
    }

    fn rendered_function(name: &str) -> String {
        declarations()
            .into_iter()
            .find_map(|decl| match &decl {
                DaDecl::Function(function) if function.name == name => Some(decl.to_string()),
                _ => None,
            })
            .unwrap_or_else(|| panic!("runtime emits {name}"))
    }

    #[test]
    fn heap_reserve_is_large_and_reserved_with_the_int64_overload() {
        // The reserve is address space only (measured, see the constant); it
        // is passed to the `int64` overload, and the record count it bounds
        // fits the `int` record indices.
        assert!(HEAP_RESERVE_BYTES >= 512 * 1024 * 1024);
        assert!(HEAP_RESERVE_BYTES / HEAP_ALIGN_BYTES <= i32::MAX as u64);
        assert_eq!(HEAP_RESERVE_BYTES % HEAP_ALIGN_BYTES, 0);
        let init = rendered_function("c2da_rt_init_heap");
        assert!(init.contains("if (empty(c2da_rt_heap)) {"));
        assert!(init.contains(&format!("reserve(c2da_rt_heap, {HEAP_RESERVE_BYTES}l)")));
    }

    #[test]
    fn malloc_reuses_freed_blocks_before_growing_the_arena_and_aligns_every_block() {
        let malloc = rendered_function("c2da_rt_malloc");
        let reuse = malloc
            .find("c2da_rt_take_free(need)")
            .expect("malloc consults the free list");
        let bump = malloc
            .find("c2da_rt_next = end")
            .expect("malloc bumps the arena");
        assert!(
            reuse < bump,
            "free-list reuse precedes arena growth:\n{malloc}"
        );
        // Capacity and start address are both rounded to the 16-byte C alignment.
        assert!(malloc.contains("var need : uint64 = (size + 0xf) / 0x10 * 0x10"));
        assert!(malloc.contains("(base + c2da_rt_next + 0xf) / 0x10 * 0x10 - base"));
        assert!(malloc.contains("c2da_rt_alloc_sizes[record] = need"));

        let free = rendered_function("c2da_rt_free");
        assert!(free.contains("c2da_rt_find_record(address)"));
        assert!(free.contains("push(c2da_rt_alloc_free, record)"));
        // Only a live record is released, so a double free cannot enter the
        // free list twice and hand one block to two owners.
        assert!(free.contains("record >= 0 && c2da_rt_alloc_live[record]"));

        let reset = rendered_function("c2da_rt_reset");
        assert!(reset.contains("resize(c2da_rt_alloc_free, 0)"));
    }

    #[test]
    fn realloc_keeps_the_block_when_it_fits_and_copies_the_whole_old_block_otherwise() {
        let realloc = rendered_function("c2da_rt_realloc");
        assert!(realloc.contains("if (size <= capacity) {\n        return address"));
        assert!(realloc.contains("start + capacity == c2da_rt_next"));
        assert!(realloc.contains("c2da_rt_memcpy(replacement, address, capacity)"));
        let calloc = rendered_function("c2da_rt_calloc");
        // A reused block holds its previous owner's bytes: calloc clears it.
        assert!(calloc.contains("c2da_rt_memset(address, 0x0u8, total)"));
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
