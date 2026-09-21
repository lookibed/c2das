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
