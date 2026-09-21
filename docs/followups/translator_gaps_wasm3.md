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

## Status 2026-09-21: fixes landed, decisions still open

Commit `066b30e1b` fixes all four generically, each with a canonical case
(`p73-indirect-call-expression`, `p74-musttail-return` + `n09-unknown-statement-attribute`,
`p75-va-list-parameter`, `p76-std-strings`), and five more defects the same graph
exposed on the way (`p77`–`p80`: scalar brace initializer, `_Bool` value semantics,
typedef order / parameter-const / `@@f` init dependency, VLA sizing).  The
translated `src/all_host.c` (39 114 lines) then runs under `daslang -jit`
byte-identical to the native C program (`fib[24]=46368`, `count=7`), with no
stack overflow at this wasm call depth.

Measured the same day on a frozen copy of `becdefa42` (`src/all_host_bench.c` on
`fixtures/fib32.wasm`, warm-up + 5 runs, medians of `decode_us`, the fib call loop):

| variant | output | decode_us | ÷ C -O2 | wall |
|---|---|---|---|---|
| C `clang-18 -O2` | `fib[24]=46368 count=7` | 1790 | 1.00× | 5.6 ms |
| C `clang-18 -O0` | identical | 4168 | 2.33× | 7.8 ms |
| daslang interp | fails (below) | — | — | 6.0 s to the throw |
| daslang `-jit` | identical | 5067 | 2.83× | 686 ms |
| daslang `-exe` | identical | 4899 | 2.74× | 26.5 ms |
| daslang aot | identical | 2802 | 1.57× | 2.13 s |

The dropped `musttail` is bounded, not fatal: live native depth is (wasm call depth) ×
(ops per activation), and a wasm return unwinds it.  No mode crashed up to
`fib(36)`; bisecting `ulimit -s` gives ≈ 751 B per wasm frame under `-exe` (n_max ≈
10 900 at 8 MiB), ≈ 205 B under `-jit` (≈ 39 700), ≈ 239 B under aot (≈ 34 100),
against ≈ 614 B for the C `-O0 -DM3_HAS_TAIL_CALL=0` control.  `options stack = N`
changes nothing under `-jit`/`-exe` (they recurse on the native stack; exhaustion is
a bare SIGSEGV because `d_m3MaxNativeStack 0` removed wasm3's own guard); the
interpreter's `invoke` recursion lives on the simulated stack and does scale with it.

Two more translator findings from that run, both generic:

- **Struct emission order.** `daslang -aot`'s C++ does not compile out of the
  translator: four `field has incomplete type` errors (`M3Module` embeds `M3Memory`
  by value but is emitted first).  The translator emits records in C's *first-name*
  order, not *definition* order.  daslang's AOT emitter does sort by-value members
  ahead of their container, but gives up when the embedded struct also points back
  at the container (pure repro and control in
  [lookibed/daScript#2](https://github.com/lookibed/daScript/issues/2)); wasm3's
  records are such cycles.  The aot row above needed a hand reorder in a scratch
  copy.  Translator-side avoidance, independent of that issue: emit records in C
  definition order, which is complete-before-by-value-use by construction (pointer
  members do not constrain), like `global_order` already does for aliases and
  initializers.
- **Interpreter blocker, translator-side avoidance.** The throwing shape
  `unsafe(reinterpret<uint64>(unsafe(p + N)))` is emitted at exactly one site,
  `abi.rs pointer_to_raw_address()` (pointer comparison operands).  Reported with a
  9-line pure repro and the tried variants as
  [lookibed/daScript#3](https://github.com/lookibed/daScript/issues/3): a bound
  extern returning a pointer (`i_das_ptr_add`/`i_das_ptr_sub`) cannot be read
  through an integer slot; element type, offset spelling and `-no-optimization` do
  not matter.  Hoisting the pointer expression into a temporary
  (`var t = unsafe(p + N)`) and reinterpreting the temporary runs in the
  interpreter (verified in isolation), needs no pointee knowledge at the site, and
  is a legitimate generic lowering choice.  Also noted and reported as
  [lookibed/daScript#1](https://github.com/lookibed/daScript/issues/1):
  `reinterpret<uint>` (32-bit) of a pointer sum breaks the JIT's codegen
  (`Trunc only operates on integer`); the translator never emits a 32-bit
  reinterpret of a pointer, so this one needs no avoidance.

None of the three daslang issues is a dependency: the translator-side avoidances
are to be implemented regardless, and the issues are recorded here so that the
avoidances can be revisited when daslang changes.

Two things remain, and this page owns them:

- **The plain interpreter stops** with `EXCEPTION: internal binding error: typed
  eval on wrong extern return kind, i_das_ptr_add` after the first line.  It is a
  daslang-side extern binding error (`include/daScript/simulate/interop.h`,
  `ext_wrong_slot`), reduced to a 9-line pure-daslang repro:
  `var a : uint64 = unsafe(reinterpret<uint64>(unsafe(p + int(4))))` throws in the
  interpreter and prints `0x4` under `-jit`.  Not a c2das defect; the corpus stays out
  of the canonical set until the interpreter path runs or the case is declared
  jit/exe/aot-only.
- **The decision per row** the user asked for is still due: (1) every non-direct
  callee goes through `invoke`, decided by type — keep; (2) `musttail` is dropped and
  the flat-stack guarantee is not preserved — measure the overflow depth per mode on
  this corpus before calling it acceptable; (3) the `va_list` cursor crosses by
  reference next to the caller's argument array — keep unless a callee stores the
  cursor beyond the call; (4) `errno` is a cell in the raw heap behind
  `__errno_location`, with `ERANGE`/`EINVAL` set by `strto*` — keep, and extend
  when the next corpus needs more of `errno.h`.
