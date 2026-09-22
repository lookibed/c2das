# Can translated C beat `clang -O2` under `-jit` / `-exe`?  Measured levers

Recorded 2026-09-22 from three parallel research runs on the corpus (pl_mpeg 320×240,
h264bsd 640×360, both `-std` cases; wasm3's dispatch story is settled in
`translator_gaps_wasm3.md` and was excluded).  Each run pinned its own cores; medians of
≥ 5 runs after a warm-up (up to 31 interleaved rounds for the headline pairs); every
variant's frame hashes were checked against the C `-O2` build.  No `perf`/`valgrind` on
the machine, so attribution is by controlled variants, `objdump`, and the JIT's own IR
dump (`--jit-dump`).  The box was shared, so absolute milliseconds are not comparable to
`docs/corpus-benchmark.md`; the ratios within one window are.

## The answer

Yes, on pl_mpeg it already does once two module-level facts are fixed, and h264bsd comes
within 5 %.  But the reason is not that a JIT sees more than a C compiler: it is that
daslang's LLVM backend compiles for *this* CPU (`default<O3>`, host CPU and features,
inline threshold 1024) while a plain `clang -O2` binary targets generic x86-64 (SSE2).
Against a fair C build (`-O3 -march=native`) the translated program is still ≈ 10 %
behind on pl_mpeg and ≈ 5 % behind on h264bsd, and the rest is C-semantics tax that the
translator itself adds and can remove.

| pl_mpeg 320×240, ratio to C `-O2` | value |
|---|---|
| C `-O3 -march=native` (fair ceiling) | 0.87–0.91 |
| `-jit` as translated today | 1.02–1.08 |
| `-jit` + `options solid_context` | **0.997** |
| `-exe` + `solid_context` + `[unsafe_deref]` + host ISA | **0.975** |

| h264bsd 640×360, ratio to C `-O2` | value |
|---|---|
| C `-O3` / `-march=native` / `-flto` (fair ceiling) | 0.95–1.05 (C `-O2` is the ceiling) |
| `-jit` as translated today | 1.26–1.35 |
| `-jit` + `solid_context` | 1.06 |
| `-jit` + `[unsafe_deref]` on every function | 1.16 (from 1.34) |
| `-exe` + `solid_context` + `[unsafe_deref]` + host ISA | **1.05** |

## What the daslang pipeline is (read from source)

`-jit`: LLVM `default<O3>`, loop/SLP vectorizers and unrolling on, inline threshold 1024
(clang's default 225), target = host CPU + host features (`llvm_jit_plan.das`).  `-exe`:
the same pipeline at generic x86-64 unless `DAS_JIT_X64_FORCE_FEATURES` or
`DAS_JIT_BASELINE` is set (0 `ymm` instructions in the pl_mpeg exe vs 1313 in the JIT
DLL).  `--jit-opt-level` (already 3), `--jit-size-level`, `--jit-split-modules` change
nothing measurable; `-jit-stack` costs +37 %/+60 % if turned on (it is off);
`DAS_JIT_BASELINE=x86-vnni512` SIGILLs on a Zen3 host (no feature check).

## Levers, ranked by measured gain

1. **`options solid_context = true` in every translated module.**  Every read of a
   translated C global (`c2da_rt_heap`, the allocator tables, quant/zig-zag matrices, the
   std stream tables) is `call @jit_get_global_mnh(hash, ctx)` — a mangled-name lookup —
   171 sites in pl_mpeg's IR, 836 in h264's; a loop bound read from a global is reloaded
   every iteration and blocks vectorization (25× on a copy loop).  `solid_context` bakes
   the offsets: 1046 call sites gone from the h264 exe, **h264 1.27 → 1.06, pl_mpeg
   1.05 → 1.00**.  One header line; nothing in the body changes.

   *Correction, 2026-09-22, on implementation.*  The AOT half of that claim does not hold
   in general.  With `options solid_context = true`, `daslang -aot` generates C++ that
   compiles, but `das_program_simulate` under `fail_on_no_aot` then refuses the program
   (`aot_host: simulation failed`) for **both h264bsd corpus cases**, with and without
   `[unsafe_deref]`; pl_mpeg and wasm3 AOT-run with the option on.  daslang's own
   documentation says `solid_context` prohibits AOT, so the corpus AOT build now passes
   `--no-solid-context` (`corpus_matrix.AOT_GRAPH_FLAGS`, documented at step 6a of
   `docs/corpus-build-recipe.md`), exactly as it passes `disable_auto_inline`.  interp,
   `-jit` and `-exe` — the three modes the lever was measured on — keep the option.  What
   inside the h264bsd graph the AOT path cannot take is not yet attributed; it is a
   candidate for the fork.
2. **`[unsafe_deref]` on every translated function.**  `ExprAt`, `ExprPtr2Ref` and field
   dereferences emit `check_ptr_zero` unless the *function* carries the annotation
   (`llvm_jit.das:2760/4981/6225`); the expression-level `unsafe(...)` the translator
   emits does not suppress it.  h264's module has 7074 null-check sites and 2150 panic
   blocks; a loop with 20 of them becomes 20 side exits and `LoopVectorize` bails
   (`h264bsdInterpolateChromaHor`).  **h264 −8…−13 %, pl_mpeg exe −5…−9 %**, a 2-D
   table walk 16×.  Faithful: a null dereference is undefined behaviour in C, so the
   check is not a semantic the program had.  It trades a located daslang exception for a
   SIGSEGV, so it is a policy switch, not a silent change.  Blanket
   `hint(unsafe_alias, unsafe_capture)` on top is unsound for C and measured *worse*.
3. **Host ISA for `-exe`** (`DAS_JIT_X64_FORCE_FEATURES=avx2,f16c,fma,bmi,bmi2` or
   `DAS_JIT_BASELINE=x86-avx2` at build time): pl_mpeg exe 1.065 → 0.998; h264 mixed
   across windows (0 % to −8 %, once +8 %).  A recipe decision, not a translator one, and
   it costs the binary's portability; the benchmark should carry both an `-exe` (generic)
   row and a `C -O3 -march=native` column so the ratios are honest.
4. **Translator expression-inlining hurts the compiled modes.**  `translator/inline.rs`
   substitutes tiny static helpers for the interpreter's sake; `--no-inline` gave pl_mpeg
   `-jit` −5…−12 % and h264 `-jit` −4 %, but hurt `-exe`.  Needs a knob
   (`--inline=interp|off`) and a per-mode measurement before a default changes.
5. **Small-block `memcpy`/`memset`.**  The `c2da_rt_*` helpers are byte loops that LLVM
   does not recognise as `llvm.memcpy`; the jitted helper is already an AVX2 copy, so what
   is left is the call itself (1.6 M calls from h264's `FillRow1`, 9–21 bytes each).
   Word-wise or builtin bodies: 0–5 %, inside noise.  Lowering constant-size calls at the
   call site is unmeasured, bounded by that call count.
6. **`nsw` on translated index arithmetic.**  The JIT's IR lacks `nsw` on `i32` index
   math (and `inbounds` on most GEPs); an `opt-18` A/B proved the missing `nsw` alone
   loses the `<8 x i8>` SLP in `plm_video_decode_block`.  A semantics decision (daslang
   `int` wraps, C signed overflow is undefined); not timed separately.
7. **Identity `reinterpret<T?>(x : T?)`** — 456/456 of h264's hot-set occurrences, zero
   cost under LLVM; worth dropping for the interpreter and readability only.

Measured as **not worth touching**: `switch` as an if/elif ladder (LLVM rebuilds the jump
table, 2–3 % at 16 and 64 arms); the goto-rendered CFG, boolean materialisation and
`c2da_postinc` dead stores (no difference vs a hand-structured loop; the translated IDCT
runs at C `-march=native` speed under `-jit`); the `c2da_rt_local` shadow stack (zero
call sites in both decoders — dead code); whole-program/LTO visibility (both sides are one
translation unit; clang at the JIT's inline threshold gains nothing); run-time value
specialisation (0–3 %, three ways); aliasing (clang's TBAA is `omnipotent char` on
pixels; the JIT has no `noalias` on C pointers; both need the same runtime memchecks);
`--jit-opt-level`, size level, module splitting.

## daslang-side findings (candidates for the fork, with repros in the research dirs)

- An `int16` loop with an `(i + 1) & (N - 1)` index wrap runs 2× slower than clang at
  the same ISA under `-jit`/`-exe` while the unwrapped loop is at parity (re-measured on
  a pure-daslang pointer loop with its C twin and filed as
  [lookibed/daScript#6](https://github.com/lookibed/daScript/issues/6); the research
  run's 10× was on the translated shape).  An `int64` multiply/shift loop likewise lags
  (8.5× behind `-march=native` C on the research probe; not yet reduced to a pure repro).
- `-exe` targets generic x86-64 by default while `-jit` targets the host; there is no
  host feature check on `DAS_JIT_BASELINE` (SIGILL).
- The JIT emits 1.2–4× more instructions per function than clang for the same graph
  (h264 DLL 94.9 k vs 46.7 k); an unattributed ≈ 15 % of h264's decode loop remains after
  levers 1–2 and cannot be attributed without hardware counters.

## Decision

Implement 1 and 2 in the translator (2 behind `--checked-deref` to keep the located
exceptions for debugging; the faithful default is unchecked), then re-measure the whole
matrix on a quiet machine with a `C -O3 -march=native` column added to
`docs/corpus-benchmark.md`.  3 is a recipe row, not a default.  4–6 wait for their own
measurements.

*As implemented, 2026-09-22.*  1 is `options solid_context = true`, written by default,
with `--no-solid-context` to drop it.  2 is `[unsafe_deref]` on every emitted function
behind `--unsafe-deref`, **opt-in**: the located daslang exception stays the default and
the corpus cases ask for the unchecked build with `"translator_flags": ["--unsafe-deref"]`
in `tests/canonical/cases.json`, so the production configuration is the measured one while
a debugging translation keeps its exceptions.  `scripts/corpus_matrix.py bench` now builds
a third C row, `clang-18 -O3 -march=native`, and prints a `× C native decode` column beside
`× C -O2 decode`; the numbers in `docs/corpus-benchmark.md` are still the old ones until
the matrix is re-measured on a quiet machine.
