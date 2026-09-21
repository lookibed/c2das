# Translator gaps exposed by the wasm3 corpus

Recorded 2026-09-21 from the first `--libc std` translation attempt of
`tests/manual/wasm3` (wasm3 `deeaca9ce`, interpreter core only, no WASI, host
`src/host.c` over `fixtures/fib32.wasm`).  The native C build works
(`fib[24]=46368`, both `-O0` and `-O2`, with `musttail` honoured by clang at
both levels).  Translation stopped on ten things; six were input-side and were
handled in the corpus itself (fixture stub headers for `ctype.h`, wasm3's own
`d_m3MaxNativeStack 0` to compile the `__builtin_frame_address` stack probe
out, `M3_IMPLEMENT_ERROR_STRINGS` for the unity build).  The remaining four are
the translator's, they are generic, and each needs a deliberate decision, not
only a patch.  Nothing here is wasm3-specific.

| # | Gap | Where it bites | What is at stake |
|---|---|---|---|
| 1 | A call through an **expression** callee of function-pointer type, `((Op)(*pc))(pc + 1, ...)`, is printed by juxtaposition instead of `invoke(f, ...)`; the same call through a local variable is printed correctly | all 491 opcode-dispatch sites (`nextOpImpl()` in `m3_exec_defs.h`); any interpreter, vtable or jump table in C | The generated module does not parse.  Fix: route every non-direct callee through `invoke` in call lowering, with the decay/deref peeled as for the variable case; canonical case `p73-indirect-call-expression` |
| 2 | `__attribute__((musttail))` **panics** the translator (`c_ast/conversion.rs`, "Unknown statement attribute") instead of a located diagnostic | `nextOpDirect`/`jumpOpDirect` | Two questions: the panic (must become a `TranslationError` or an accepted, dropped attribute) and the semantics — daslang gives no tail-call guarantee, so a continuation-passing interpreter loses wasm3's flat native stack and `return_call` stops being iterative.  Which run modes (interp / jit / aot / exe) actually overflow, and at what wasm call depth, is to be measured on the corpus, not assumed |
| 3 | A **`va_list` received as a parameter** (`m3_CallVL(fn, ap)`, the `vfoo(fmt, ap)` idiom) is unsupported: "va_arg uses a va_list without va_start" | `m3_CallV -> m3_CallVL`, `m3_GetResultsV -> m3_GetResultsVL`, the host's direct call path | The variadic ABI (`array<C2daVaArg>` + `C2daVaCursor`, `translator/variadic.rs`) covers `va_start` in the same function only.  Decision: cursor passed by reference or by value, `va_copy` semantics; canonical case `p75-va-list-parameter` |
| 4 | The **`std` table lacks** the NUL-terminated string family (`strcmp`, `strlen`, `strncmp`, `strcpy`, `strstr`, `strchr` ...), `strtoll`/`strtoull`, `abort`, the `ctype` predicates, and `__errno_location` | `m3_env.c`, `m3_parse.c`, `m3_bind.c`, `m3_module.c` | Six generic libc entry points.  `__errno_location` is the one that no fixture header can shadow: glibc's `errno` data symbol is `GLIBC_PRIVATE`, so the function *is* the ABI; decision: an `errno` cell in the raw heap owned by the std prelude, with `ERANGE`/`EINVAL` set by `strto*` |

Already fine without changes: `__builtin_clz`, `__builtin_ctz`, `__builtin_popcount`
(and `ll` forms) lower to daslang's `clz`/`ctz`/`popcnt`; `__builtin_expect` is
transparent.  Noted for later: daslang has no byte-swap builtin, so
`__builtin_bswap16/32/64` (compiled out on little-endian here) would need shifts.

Status: generic fixes for all four, each with a canonical case, are being drafted;
the corpus is not registered as a canonical case until the translated module runs.
When they land, this page keeps the *decision* for each row (the chosen lowering
and why), and the wasm3 rows join `docs/corpus-convergence.md` /
`docs/corpus-benchmark.md` like the decoders.
