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
