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

## Status 2026-09-21: both avoidances landed, the interpreter path runs

Both are generic passes with a canonical case each.

- **Record emission order** (`translator/global_order.rs
  order_record_declarations`, canonical case `p84-struct-definition-order`,
  invariant test `c2dascript-transpile/tests/record_order_tests.rs`).  The
  module's record declarations are topologically ordered over *by-value* edges
  only — a field's own type, an array's element type, and whatever a `typedef`
  resolves to; a pointer member stops the walk, which is what lets the cycle
  exist.  Aliases keep their slots, so `order_type_aliases` is unaffected, and
  a record field naming a later `typedef` is accepted by daslang and by its
  AOT alike.  wasm3's type section comes out `M3Memory` before `M3Module`,
  `M3CompilationScope`/`M3Compilation` before `M3Runtime`, and `daslang -aot`'s
  C++ compiles with `clang++-18` and the toolchain's own AOT flags, with no
  hand reorder.
- **Raw address of a pointer sum** (`translator/abi.rs named_pointer_value`,
  canonical case `p85-pointer-sum-compare`).  A pointer value is given a name —
  `var t : T? = unsafe(p + int(4))` — before `reinterpret<uint64>` reads it,
  whenever the value is pointer arithmetic, including behind a
  pointer-to-pointer `reinterpret` that daslang folds away
  (`reinterpret<uint64>(reinterpret<uint8?>(p + n))` throws exactly like the
  bare form).  Three crossings route through it: the pointer comparison
  operand (`operators.rs`), the explicit and implicit pointer-to-integer cast
  (`translator/mod.rs`), and the raw-address argument of a runtime/std helper
  (`functions.rs lower_runtime_arg`, which is how `memmove(sp + returnSlots,
  sp + stackOffset, n)` in wasm3's `op_ReturnCall*` reached it).  A translation
  that never takes the raw address of a pointer sum is byte-identical to
  before: over `tests/syntax/*.c` in `nostd`, 2 of 142 modules differ, both on
  that shape.

`tests/manual/wasm3/src/all_host.c` under `--libc std` now prints
`bytes=62 … fib[24]=46368 … count=7` under the **plain interpreter** and
byte-identically under `-jit`.  The interpreter needs a larger simulated stack
than daslang's default: its `invoke` recursion lives there, and the default
overflows in `op_Entry` around fib(20) — the same depth story the table above
measures per mode.  Measured on the registered translation: the default
overflows, `stack = 1048576` (1 MiB) already runs fib(24), and 4, 16 and 64 MiB
run identically (15–21 s each, dominated by the interpreter, not the stack).
The corpus is registered as `wasm3-fib32-std` with `das_options: ["stack =
4194304"]`, a new case key the runner and the corpus driver pass to the
translator as `--das-option`, i.e. the module header carries `options stack =
4194304` and nothing edits generated text.  One `reinterpret<uint64>` of pointer
arithmetic remains in the tree, in `p54-address-taken`
(`object_memory.rs raw_byte_address`): there the address is handed straight
back to `reinterpret<T?>`, never read as an integer, and the case passes in
every mode.

## Decisions 2026-09-21, from measurement

Four parallel research runs (one per row; probes, models, surveys and raw logs are
session artefacts, the numbers are reproduced here).  Every timing is a median of
≥ 5 runs after a warm-up, pinned to its own cores, against a C baseline measured
the same way at the same time.  `perf`/`valgrind` are not on the machine, so where a
profile would have been used the evidence is exact dynamic counts plus controlled
builds plus disassembly.

### 1. Indirect calls: keep `invoke` on a `function<>` value.  Do not devirtualise.

wasm3 executes 1 305 795 dispatches per run (counted in an instrumented C copy).
Per dispatch: C `-O2` 1.34 ns; aot 2.14 (+0.80); `-exe` 4.05 (+2.72); `-jit` 4.22
(+2.88); interp 124 (+122).  A C `-O2` build with the tail call disabled costs 2.46
(+1.12), so ≈ 40 % of the jit/exe gap is the missing tail call, not `invoke`.

- **AOT** compiles `invoke` to a direct call through `SimFunction::aotFunction` *in
  tail position* (clang's sibling-call optimisation fires through
  `das_invoke_function`), so the AOT build reproduces wasm3's `musttail` chain.  The
  +0.80 ns is one extra `Context*` argument, two null checks, one extra load and a
  frame for the cold paths — the whole AOT gap.  A cheaper lowering would need a raw
  C function-pointer call that daslang does not offer; achievable gain today: 0.
- **JIT/exe** lower `invoke` to a call through `vec4f (*)(Context*, vec4f*, void*)`
  with `ctx.stopFlags = 0` after it, which forbids a tail call (daslang side).
- **Alternatives measured and rejected**: `lambda` values are slower in all four
  modes; an `if/elif` devirtualisation costs 2.47 ns per arm in the interpreter (no
  `switch` node exists) — ≈ 580 ns for wasm3's 473 address-taken functions, 4.5× worse
  — and the compiled modes' good numbers come from LLVM jump tables on dense
  integers, impossible for 64-bit `Func` comparisons; the callee set is not provable
  anyway (the value is cast out of the bytecode array).  `options solid_context`
  changes no AOT read and prohibits AOT.
- **Unrelated finding worth its own work**: in AOT every daslang *global* read inside
  a loop containing an opaque call is a mangled-name hash probe
  (`das_global<T,mnh>` → `globalOffsetByMangledName`), ≈ 4.1 ns per access (jit 0.8,
  exe 0.55).  wasm3's handlers read no globals, so it does not show there; translated
  C whose hot loop touches file-scope variables will pay it.  Translator-side hoisting
  is unsound (any pointer may alias a global); the AOT emitter has `das_global_solid`
  and uses it only for initialisers.  Filed with a pure repro (loop with an opaque
  call reading two globals vs a local copy: aot 4.1×, `-jit` 2.2×, `-exe` 2.6×, and
  the generated `das_global<T,mnh>` line) as
  [lookibed/daScript#5](https://github.com/lookibed/daScript/issues/5); the decoder
  `-std` cases are still to be measured for it.

### 2. `musttail`: drop it with a source-located warning (`-Wmust-tail`).

- **Time**: at `-O2` clang sibling-calls all 474 dispatch sites with or without the
  attribute (474 indirect `jmp` in both objects; at `-O0` without it, 0 `jmp` /
  479 `call`).  fib32 decode: stock 1778 µs, attribute dropped only 1743 (0.98×),
  `-DM3_HAS_TAIL_CALL=0` 1832 (1.03×).  The attribute is worth 1.37× only at `-O0`.
  So "fail closed and rebuild the input without tail calls" is refuted: it is slower
  and restores nothing (`return_call` stops being iterative in the C reference too).
- **Stack** (plain wasm recursion, 8 MiB native stack, `n_max` / bytes per wasm
  frame): C `-O2` 130 940 / 64; aot 74 774 / 112; `-exe` 16 891 / 497; `-jit`
  15 386 / 545; interp 6 704 / 1251 (a catchable daslang exception).  `ulimit -s`
  doubled doubles `-exe`'s `n_max` exactly.  Raising `options stack` from 4 MiB to
  32 MiB does **not** raise the interpreter's `n_max` and turns its exception into a
  SIGSEGV: 4 MiB is the right value for the registered case, and it must not be
  raised.
- **`return_call`** (a wasm tail loop): C `-O2` and aot are unbounded — `clang++ -O3`
  sibling-calls the AOT C++ (418 indirect `jmp` vs 13 in `-exe`'s object) — while
  `-jit`/`-exe`/interp are bounded (16 364 / 14 534 / 6 718).  Under `-jit`/`-exe` a
  C program that uses `musttail` for an unbounded loop has no depth at which it is
  correct; that is the one qualitative loss.
- **Trampoline** (a generic same-signature-SCC rewrite, prototyped on a model):
  wins 1.8× under `-jit`/`-exe`, loses 1.5× under aot and 1.18× in the interpreter,
  2.4× in C; it must rewrite every function-pointer type of the signature and prove
  it sees every producer of a dispatch value, and cannot help `musttail` into an
  unrelated callee.  Declined.
- **daslang side**: no tail-call notion at all.  `LLVMSetTailCallKind` is bound
  (`modules/dasLLVM/bindings/llvm_func.das`) and never called; the site is
  `make_call` in `llvm_jit.das`, blocked by the epilogue emitted between the call and
  `ret`.  Filed as [lookibed/daScript#4](https://github.com/lookibed/daScript/issues/4)
  with two pure repros (an 8-handler indirect dispatch chain: interp exception and
  `-jit`/`-exe` SIGSEGV at 100 000, aot fine at 10 000 000 with 7 sibling calls in its
  object against 0 in `-exe`'s; and direct self recursion, which LLVM's own
  tail-recursion elimination handles under `-jit`/aot while the interpreter
  segfaults natively at 1 000 000 despite `options stack`); proposals: JIT musttail,
  `[[clang::musttail]]` in the AOT printer, a diagnosed annotation.  Not a dependency.
- **Work** (done): `Diagnostic::MustTail` is a default-on warning emitted at the drop
  site in `cfg::CfgBuilder::convert_stmt`, once per attributed statement, with that
  statement's source location; a *direct* self-recursive tail call says so (mutual
  recursion does not — no call-graph SCC is computed).  `-Wno-must-tail` switches it
  off (`TranspilerConfig::disabled_warnings`; a `-W…` name the translator does not
  own still reaches clang).  wasm3 reports 489 drops over 204 distinct locations —
  its ops are macro expansions.  `p74-musttail-return` and
  `c2dascript-transpile/tests/diagnostic_tests.rs` pin the wording, the per-statement
  count and the off switch.  `tests/manual/wasm3/README.md` (the `call *%rax` claim
  holds at `-O0` only) and the depth table plus the 4 MiB ceiling in
  `docs/corpus-build-recipe.md` are corrected.

### 3. `va_list` parameters: keep by-reference; fix two live defects; escape check.

- **ABI**: x86-64 `va_list` is `struct __va_list_tag[1]` (by reference); aarch64,
  riscv64, i386, ppc64le pass it by value.  C99 7.15.1p1 makes the caller's `ap`
  indeterminate after the call, so conforming programs cannot tell.
- **Idioms** (19 programs, native vs interp vs `-jit`, the two daslang modes never
  disagreed): every model-independent idiom matches; the two ABI-dependent ones
  (caller reads on after the callee consumed; the same `ap` handed to a consumer
  twice) match glibc because the model is by-reference — a hand-made by-value
  simulation gives 3001/3003 where native gives 3003/3007.
- **Survey** (Lua, zlib, stb, musl, picolibc, SQLite, curl, wasm3): 175 `va_list`
  parameter sites; every `va_copy` copies a parameter (18), never a local; zero
  `va_list` values escape their frame; zero "reuse after consume".  `&ap` occurs 14
  times, all frame-local synchronous passes (musl's `printf_core(…, va_list *ap, …)`,
  picolibc's struct wrapper) — an address-taken check would reject exactly the printf
  engines a port will meet; an escape (lifetime) check fires on none of them.
- **Defects found** (both silent, both outrank the model question):
  `va_start` on an already-started object emits nothing (`VaPart::Start` →
  `ConstInt(0)`), so a second `va_start` continues instead of rewinding: the
  measure-then-format two-pass shape gives a wrong value (1203 for 1201) or runs off
  the argument array; and the std shims (`c2da_std_vsnprintf` etc.) take the cursor
  *without* `var`, i.e. by value, so forwarding to libc uses the opposite model from
  forwarding to translated C (two probes diverge; one passes only because the two
  defects cancel).  Also accepted and unsound: storing `&ap` of a parameter in a
  global (a 4-byte cursor reinterpreted as a 24-byte struct pointer).
- **Work**: emit `<cursor>.index = 0` on `va_start`; `var ap` in every std shim with
  the advance written back; a located error when the address of a `va_list` object
  is stored anywhere but a call argument; optionally poison the cursor on `va_end`.
  Cases: va-start rewind (nostd), shared-cursor ABI pin (nostd), std forwarding
  (std), negative escape.  `AstContext::va_list_kind` already exists if a
  `--va-list-abi` switch is ever wanted; not now.

### 4. `errno`: keep the raw-heap cell; fix two mechanical defects; grow the table.

- **Equivalence**: 20 idioms native vs interp vs `-jit`; every idiom whose value the
  translator writes is byte-identical, including a unit that includes the real
  `<errno.h>` (the macro expands to `(*__errno_location())`, which is exactly what
  the translator intercepts).  Misses are all "nobody wrote the value": failed
  `fopen` (`ENOENT`), failed `fseek` (`EINVAL`), failed allocation (`ENOMEM`, which
  no surveyed codebase checks).
- **Alternative** (a daslang global reached through `addr()`): addressable in every
  mode (verified), marginally cheaper under `-jit`, but `&errno` would no longer live
  in the C address space, and threading does not discriminate (a `jobque` clone
  re-initialises the globals *and* the heap array alike).  Rejected.
- **Cell defects**: lazy allocation (a branch per access, ≈ 2× in the interpreter,
  18 % under `-jit`) and unguarded reads when `c2da_rt_malloc` returns 0.  Allocate
  eagerly in the prelude, make the accessor a pure getter.
- **Survey** (Lua, SQLite, zlib, miniz, stb, lz4, cJSON, PCRE2, wasm3): `errno` in
  6/10; most *writers* are POSIX syscalls outside ANSI scope (the cell must stay an
  assignable `int`, nothing more); `strerror(errno)` is the first error path in 6/10;
  `ferror`/`feof`/`clearerr` are load-bearing in Lua and lz4; `EINTR` loops are pure
  reads; `EAGAIN == EWOULDBLOCK` on Linux.  daslib offers `feof` (no null check),
  `get_env_variable`, `remove`/`rename` with an error *string*; no `ferror`,
  `clearerr`, `strerror` or errno at script level.
- **Numbering**: `ERANGE=34` etc. are Linux UAPI (`asm-generic`), not glibc-specific;
  the program side already takes its constants from its own headers.  The helper
  side should treat the numbering as a target fact next to `StdLayout` (fail closed
  on an unknown target), and `strerror`'s catalogue must be shipped explicitly as
  glibc's.
- **Work**, in order: `strerror`, `perror`; `ferror`/`feof`/`clearerr` with a sticky
  flag in the std `FILE`; `ENOENT`/`EACCES`/`EISDIR` on a failed `fopen` (from
  `fexist`/`stat`); `getenv`; `strtod`; `EINVAL` on `fseek` plus `fwrite`/`fclose`
  failure paths; `remove`/`rename`; `fgets`/`fgetc`/`fputc`/`ungetc`/`rewind`/
  `fileno`; 15 constants.  Cases: errno idioms, real headers, strerror/perror,
  stream flags, fopen errno, one negative.  Adjacent blocker: glibc's `assert` fails
  as "statement expression has no final value" and gates SQLite.

Nothing on this page is now undecided.  The open items are the work lists above.

## Status 2026-09-21: decision 4 implemented, with the std part of decision 3

The `errno` work list above is done, and with it the shim half of decision 3.
Canonical cases `p89`–`p94` and `n11`; every one of them is the C program's own
output as the oracle.

- **The cell** (`libc.rs build_cell_alloc`, `build_errno_cell`).  Allocated
  eagerly in the module's globals — the raw-memory runtime's own globals are
  declared ahead of the std prelude, so the arena is usable at that point — and
  `c2da_std_errno_location()` is now a getter with no branch.  The arena cannot
  hand out four bytes only if its reserve (1 GiB) is exhausted at start-up, which
  is not a state a C program can be handed a null `errno` for: the allocator
  panics instead, because the *read* happens in the translated C, where the
  translator can no longer guard.  Case `p89` (the ten idioms), `p90` (the same
  unit through the system's own `<errno.h>`).
- **The numbering is a target fact** (`ErrnoNumbering`, in `StdLayout`).  The
  discriminator is the Clang-exported target triple, which the pipeline already
  carries as `TypedAstContext::target`; `ErrnoNumbering::of_target` answers
  `AsmGeneric` for Linux except the four architectures with a numbering of their
  own (alpha, mips, parisc, sparc), and `Unknown` otherwise.  A `std` helper
  that has to write a code for an `Unknown` target is refused at
  `require_std_function` with the C call's own source location.  `strerror`'s
  catalogue is shipped explicitly as glibc's, in `STRERROR_CATALOGUE`.
- **The std `FILE`'s own state.**  The std `FILE *` is unchanged — the daslib
  handle, reinterpreted — and what C carries and daslib does not (a sticky error
  indicator, one `ungetc` byte, a descriptor number) lives in a side table keyed
  by that address.  `clearerr` clears the host's end-of-file the way C itself
  guarantees, by seeking to the current position, since daslib exposes no
  `clearerr`.  Case `p92`, including Lua's `clearerr(f); errno = 0;` prologue
  and the `ferror` sample taken before `fclose`.
- **Grown table**: `strerror`, `perror`, `feof`, `ferror`, `clearerr`,
  `getenv`, `strtod`/`strtold`/`strtof`, `remove`, `rename`, `fgets`,
  `fgetc`/`getc`, `fputc`/`putc`, `ungetc`, `rewind`, `fileno`, `vprintf`,
  `vfprintf`.  `fopen` now says *why* it failed (`ENOENT`/`EISDIR`/`EACCES`,
  from `fexist`/`stat`), `fseek` reports the two `EINVAL` cases it can decide,
  `fclose` reports `EBADF`, and `fread`/`fwrite` raise the sticky error flag.
  Cases `p91` and `p93`.
- **The v-shims take the cursor by reference** (decision 3's shim half).
  `c2da_std_vformat`'s start index is `var start : int&` and every `v*` shim
  writes the advance back, so forwarding to libc is the same shared-cursor model
  as forwarding to translated C.  Found on the way, and worth recording next to
  the ABI decision: in daScript `var x : int` is a *mutable copy*, and only
  `int&` is the caller's slot — a `var` record parameter aliases, a `var` scalar
  one does not, and neither does a field of a `var` record passed on its own.
  Case `p94` (gap-3 idioms i10, i18, i19, plus `va_copy`).

Known divergences, deliberate and documented at their helpers: `strtod` does not
report `ERANGE` for a result that rounds to a *subnormal* (the format cannot
tell afterwards, and daslang's `to_double` answers zero for both overflow and
underflow, so the direction comes from the parsed decimal exponent); hexadecimal
floating constants and `inf`/`nan` are refused, at translation time for a
literal subject and by panic for a computed one; `fileno` answers a synthetic
descriptor for a stream that is not one of the three standard ones, the host's
being unreachable from daslib.

With that, nothing on this page is open: decision 1 needs no translator work,
decision 2's `-Wmust-tail` warning and decision 3's `va_start` rewind, `va_end`
poison and escape check landed in the same day's commits (cases `p86`–`p88`,
`n10`).  What remains are the two daslang-side issues on the fork (#4 tail calls,
#5 global reads in AOT), which nothing here depends on.
