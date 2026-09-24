# Translator ownership contract

The translator produces daScript AST, not repaired text.  C rvalues, C places, and raw addresses
must stay explicit in API names and result types.

| Owner | Charter |
|---|---|
| `abi.rs` | raw address ↔ typed pointer/null and storage-byte ABI conversions |
| `layout.rs` | canonical Clang-backed size, alignment, record offsets and diagnostics |
| `runtime.rs` | the complete `c2da_rt_*` declaration registry and raw-memory calls |
| `libc.rs` | the `--libc std` replacement table: `c2da_std_*` helpers, the standard streams, the `errno` cell and numbering, the std `FILE`'s own state, and the `main` entry wrapper |
| `object_memory.rs` | raw object addresses, field addresses, aligned/misaligned load/store |
| `functions.rs` | C call classification and ABI-facing argument/result lowering |
| `operators.rs` | typed C operators, including shifts and numeric coercion |
| `value_lowering.rs` | expected-type values and statement-producing coercions |
| CFG owners | C control-flow reconstruction, declaration dominance and exits |
| printer | daScript AST rendering only; no C semantic repair |

Clang facts are canonical for C layout.  Unsupported aggregate-by-value, foreign ABI,
volatile/atomic, callback, inline-asm/SIMD, and unfinished bitfield corners must produce a
source-located `TranslationError`, never an identity or daScript-value fallback.

Clang facts are canonical for the *target* too, not only for layout.  `errno`'s numbering is a
target fact next to `StdLayout`'s pointer width: it is read off the exported triple
(`TypedAstContext::target`), one numbering is implemented (Linux `asm-generic`), and a `std`
helper that would have to write a code for a target with no numbering is refused with a
source-located diagnostic rather than given another target's integers.  A `std` helper that
carries C library *text* — `strerror`'s catalogue — ships that text as one named implementation's
(glibc's), spelled out in this module, never derived.

## Module-wide policy

Facts that hold for the whole output rather than for one lowering — the `options` header and
the per-function `unsafe_deref` policy — are applied once where `mod.rs` assembles `DaModule`,
after every owner has contributed its declarations.  Nothing else may push them: the
`c2da_rt_*` registry, the `--libc std` prelude and the generated global initializers are
functions of this module too, and a per-owner push silently omits whichever builder is added
next.  The order of the header is fixed (`gen2`, `solid_context`, then the caller's
`--das-option` lines) so a given command line always writes the same header.

`options solid_context = true` is the translator's default, not a caller option: the emitted
module declares all of its own globals and never has another module splice more in, so baking
their offsets is always correct for what this translator writes.  `unsafe_deref` is opt-in
(`--unsafe-deref`) because it is a *policy* trade, not a correctness one: a C null dereference
is undefined behaviour, so dropping the check is faithful, but the program then faults instead
of raising daslang's located exception.

The printer renders a declaration's annotations as one bracketed, comma-separated block
(`[export, unsafe_deref]`).  daScript's grammar accepts exactly one block per declaration;
two consecutive `[...]` lines are a syntax error.

## Memory copies go to daslang's builtins

C `memcpy` and `memmove` are lowered to daslang's builtin `memcpy` / `memmove`
(`void?, void?, uint64`), not to the `c2da_rt_*` byte loops (`runtime.rs
CanonicalRuntimeFunction::builtin_copy`, `functions.rs lower_builtin_copy`): the two raw
addresses are converted to pointers by the same path every raw-address operand uses
(`abi::raw_address_to_pointer`), a constant non-zero size is passed as is, and any other size
is named first and guarded by `!= 0`, because the builtin checks neither the size nor the
pointers while C's `n == 0` is a no-op whatever the pointers hold.  All three operands are
evaluated before the guard so C's argument evaluation order is kept when the copy is skipped;
when the C result is used it is the named destination address.  `memset`, `memcmp` and
`memchr` stay on the runtime helpers.  Because the builtins are named unqualified, a C
translation unit that defines its own `memcpy`/`memmove` (a decoder's shim does) would
shadow them; `renamer.rs DASCRIPT_BUILTIN_COPY_NAMESPACE` reserves the two names, so such a
definition is emitted as `memcpy_0`.  With a daslang that lowers the builtins to LLVM
intrinsics (upstream #4089) the constant-size copies inline under `-jit`; on a toolchain
without it they are libc calls, and the measured gain is the interpreter's (6–27 %).

## The raw heap

`runtime.rs` owns C's heap: one `array<uint8>` (`c2da_rt_heap`) plus a record table
(`c2da_rt_alloc_addrs` / `_sizes` / `_live`) and a free list (`c2da_rt_alloc_free`).

- **Addresses never move.** The array's capacity is reserved once (`HEAP_RESERVE_BYTES`,
  1 GiB) before the first address is handed out, and `resize` never passes it, so the
  array never reallocates.  Growing past the reserve would move every live block, so a
  request that does not fit returns `NULL`, as C's `malloc` may.  The reserve is address
  space only: daslang's `reserve` leaves the pages untouched (a program's maximum RSS
  measured the same with no reserve and with 64 MiB to 1.5 GiB), and only bytes below the
  high-water mark are `resize`d, i.e. committed.  1 GiB keeps every offset inside the `int`
  daslang indexes arrays with.
- **Blocks.** A block's capacity is its request rounded up to 16 bytes and its start
  address is 16-aligned (`alignof(max_align_t)`); `malloc(0)` returns `NULL`.  Records are
  appended only when the bump pointer (`c2da_rt_next`) carves a new block, so the address
  column is sorted and `free`/`realloc` find a block by binary search.
- **Reuse.** `free` marks the record not live and pushes it on the free list; `free(NULL)`,
  a non-block pointer and a second free change nothing.  `malloc` first takes the
  best-fitting freed block whose capacity is at least the rounded request and at most twice
  it (blocks are never split or merged, so a small request cannot pin a large block), newest
  first, stopping at an exact fit; only then does the arena grow.
- **`realloc`** keeps the block when its capacity already holds the new size, grows the
  arena's last block in place, and otherwise allocates, copies the whole old block (every
  byte C preserves) and frees it.  `realloc(p, 0)` frees `p` and returns `NULL`.
- **`calloc`** clears what it returns: a reused block holds its previous owner's bytes.
- `c2da_rt_reset` forgets every block at once (records, free list, bump pointer), for
  harnesses that run several probes in one process.

`p56-heap-churn` is the acceptance case (cumulative allocation far beyond the reserve,
96 MiB live at once, alignment, `realloc`/`calloc`).
