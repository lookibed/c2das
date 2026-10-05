# Corpus benchmark: how much slower than C is c2das-translated C, per daslang run mode

Each program below is a C code base translated whole by c2das and run in each daslang mode against the same C compiled natively. The snapshot answers the one question — which daslang mode, how many times slower than C — and the appendix holds every number behind it, every build command and every variant (the hand-written-entry cases and the embedded micro fixtures included). The measurement rules are in `docs/benchmark-methodology.md`.

## Benchmark Snapshot

### Linux — AMD Ryzen 7 7435HS

Platform information:

- Captured by `python3 scripts/corpus_matrix.py bench --runs 5` on 2026-10-05 at commit `f761d899e`
- OS: Ubuntu 22.04.5 LTS, kernel 6.6.87.2-microsoft-standard-WSL2
- Toolchain: Ubuntu clang version 18.1.8 (++20240731024944+3b5b5c1ec4a3-1~exp1~20240731145000.144); daslang 0.6.4
- Programs: each one a C code base translated whole by c2das (`c2dascript-transpile --strict --libc std`, the C `main` included) and run unchanged in every daslang mode

A cell is the median of 5 runs, each its own process after one warm-up run, of the time the program itself measures around its work loop (the decode loop of the video decoders, the frame loop of the emulators, the call loop of wasm3) — process start, script compilation and JIT codegen are not in it (they are in the Startup table). `±` is half the sample range as a share of the median. Lower is better. The fastest result in each row is in bold. `-` means no value: the mode failed its per-frame hash check against C or did not build. Every mode's per-frame (per-value) hashes are checked against the C build's on every run; a mode that ever differs is reported as failed, never timed. `(micro)` marks a program whose C -O2 work loop runs under 5 ms, where timer resolution and cache state dominate the ratios.

#### Translated C vs native C

| Program | C -O3 native | C -O2 | DAS interpreter | DAS JIT | DAS exe | DAS AOT\* |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| pl_mpeg (MPEG-1 video), 320×240, 59 frames | **34.48ms** ±1% | 37.95ms ±1% | 1270.72ms ±1% | 37.58ms ±11% | 38.26ms ±1% | 40.28ms ±1% |
| h264bsd + minimp4 (H.264 video), 640×360, 73 frames | **74.24ms** ±0% | 77.97ms ±13% | 4098.23ms ±3% | 77.82ms ±1% | 77.58ms ±1% | 85.55ms ±1% |
| wasm3 (WebAssembly interpreter), fib32, 7 checked values (micro) | 1.80ms ±2% | **1.78ms** ±4% | 110.48ms ±18% | 4.56ms ±0% | 4.47ms ±3% | 2.69ms ±3% |
| binjgb (Game Boy Color emulator), cgb-acid2, 300 frames | **58.05ms** ±17% | 58.69ms ±2% | 4746.39ms ±5% | 60.36ms ±1% | 67.16ms ±0% | 68.11ms ±1% |
| doomgeneric (Doom engine), 320×200, 1000 frames | **118.48ms** ±0% | 121.24ms ±1% | 6497.58ms ±3% | 135.43ms ±10% | 124.37ms ±0% | 559.14ms ±0% |

#### Ratio to C -O3 native

The same measurements as the slowdown against `clang-18 -O3 -march=native` (1.00× is C speed); `C -O2` is the portable generic-x86-64 build, kept as the reference a `clang -O2` user would see.

| Program | C -O2 | DAS interpreter | DAS JIT | DAS exe | DAS AOT\* |
| --- | ---: | ---: | ---: | ---: | ---: |
| pl_mpeg (MPEG-1 video), 320×240, 59 frames | 1.10× ±1% | 36.85× ±1% | **1.09×** ±11% | 1.11× ±1% | 1.17× ±1% |
| h264bsd + minimp4 (H.264 video), 640×360, 73 frames | 1.05× ±13% | 55.20× ±3% | 1.05× ±1% | **1.05×** ±1% | 1.15× ±1% |
| wasm3 (WebAssembly interpreter), fib32, 7 checked values (micro) | **0.99×** ±4% | 61.48× ±18% | 2.54× ±0% | 2.49× ±3% | 1.50× ±3% |
| binjgb (Game Boy Color emulator), cgb-acid2, 300 frames | **1.01×** ±2% | 81.76× ±5% | 1.04× ±1% | 1.16× ±0% | 1.17× ±1% |
| doomgeneric (Doom engine), 320×200, 1000 frames | **1.02×** ±1% | 54.84× ±3% | 1.14× ±10% | 1.05× ±0% | 4.72× ±0% |

#### Option: `--unsafe-deref`

The tables above are the translator's default output. These rows come from a second translation of each program with `[unsafe_deref]` on every function, which removes daslang's null check in front of every pointer dereference (`ExprAt`, `ExprPtr2Ref`, field access): C's unchecked access, where a null dereference crashes instead of raising a located daslang exception. It is an option, not the default — the same effect is available by writing the code on raw pointers; it is a choice of which unsafety to accept — and the annotation has a known miscompile ([lookibed/daScript#7](https://github.com/lookibed/daScript/issues/7)), which the per-frame hash check guards these rows against (`docs/followups/hot_path_levers.md`). Cells are the ratio to the same `clang-18 -O3 -march=native` build, and in parentheses the change against the same mode without the option (negative = faster).

| Program | DAS JIT + unsafe_deref | DAS exe + unsafe_deref | DAS AOT\* + unsafe_deref |
| --- | ---: | ---: | ---: |
| pl_mpeg (MPEG-1 video), 320×240, 59 frames | **1.05×** ±0% (−3 %) | 1.11× ±1% (−0 %) | 1.17× ±2% (+0 %) |
| h264bsd + minimp4 (H.264 video), 640×360, 73 frames | 1.00× ±1% (−4 %) | **1.00×** ±0% (−4 %) | 1.12× ±0% (−2 %) |
| wasm3 (WebAssembly interpreter), fib32, 7 checked values (micro) | 2.55× ±1% (+0 %) | 2.63× ±10% (+6 %) | **1.42×** ±32% (−5 %) |
| binjgb (Game Boy Color emulator), cgb-acid2, 300 frames | 1.13× ±1% (+8 %) | **1.12×** ±1% (−3 %) | 1.19× ±0% (+2 %) |
| doomgeneric (Doom engine), 320×200, 1000 frames | **0.96×** ±9% (−16 %) | 0.96× ±1% (−9 %) | 4.69× ±0% (−1 %) |

#### Startup

Wall time of the whole process minus the timed work and the timed setup: process start, loading the runtime, compiling the script, JIT codegen and teardown. The AOT host recompiles the script on every launch, so its start-up is a compiler's, not a program's, and is shown as `-`.

| Program | C -O3 native | C -O2 | DAS interpreter | DAS JIT | DAS exe | DAS AOT\* |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| pl_mpeg (MPEG-1 video), 320×240, 59 frames | **1.4ms** ±4% | 1.5ms ±9% | 69.8ms ±1% | 257.0ms ±9% | 18.5ms ±1% | - |
| h264bsd + minimp4 (H.264 video), 640×360, 73 frames | **1.6ms** ±6% | 1.7ms ±6% | 210.1ms ±12% | 426.9ms ±1% | 18.7ms ±2% | - |
| wasm3 (WebAssembly interpreter), fib32, 7 checked values (micro) | **1.0ms** ±20% | 1.0ms ±12% | 419.2ms ±3% | 558.8ms ±1% | 19.4ms ±2% | - |
| binjgb (Game Boy Color emulator), cgb-acid2, 300 frames | 1.4ms ±6% | **1.4ms** ±2% | 188.9ms ±1% | 377.3ms ±1% | 20.6ms ±3% | - |
| doomgeneric (Doom engine), 320×200, 1000 frames | **2.4ms** ±3% | 2.4ms ±6% | 649.2ms ±4% | 928.2ms ±7% | 21.6ms ±1% | - |

\* AOT is built from a second translation without `solid_context` and without daslang's auto-inliner (`--no-solid-context --das-option disable_auto_inline`), because daslang's AOT refuses the h264bsd program with `solid_context` on and its inliner produces C++ that does not compile; every other mode runs the default translation (`options solid_context = true`, daslang's null checks on every pointer dereference). The JIT runs daslang's default split codegen with auto threads (`--jit-split-modules=-1`, not passed — see the appendix). wasm3: the `-jit`/`-exe` path makes no tail calls — daslang's LLVM backend never emits sibling calls, so every executed wasm opcode costs a native frame — while the AOT C++ gets them from `clang++ -O3`; hence aot ahead of jit/exe here ([lookibed/daScript#4](https://github.com/lookibed/daScript/issues/4), `docs/followups/translator_gaps_wasm3.md`).

---

## Appendix: full measurements

Reference data behind the snapshot above. Generated by `python3 scripts/corpus_matrix.py bench` on 2026-10-05 at commit `f761d899e` (daslang 0.6.4 (/root/daScript/bin/daslang); Ubuntu clang version 18.1.8 (++20240731024944+3b5b5c1ec4a3-1~exp1~20240731145000.144); AMD Ryzen 7 7435HS; Ubuntu 22.04.5 LTS, kernel 6.6.87.2-microsoft-standard-WSL2). Every build and run command is written out in `docs/corpus-build-recipe.md`.

Columns: **ms (median / min)** is the program's own timer around its work loop (`decode_us`; C `clock_gettime(CLOCK_MONOTONIC)`, daslang `ref_time_ticks`), excluding process start, script compilation, JIT codegen and setup. **setup** is the timed `frames_begin_bytes()` call (runtime reset, working copy of the input, decoder creation). **wall** is the whole process as the driver sees it and **startup** = wall − work − setup (loading the runtime, compiling the script, JIT codegen, teardown); the aot host compiles the script again on every launch, so its startup is not shown. **× C native** is the ratio to `clang-18 -O3 -march=native`, the headline; **× C -O2** to the portable `clang-18 -O2` build (generic x86-64, SSE2), shown for reference because daslang's LLVM backend compiles `-jit` for the host CPU. The translated modules are the translator's defaults: `options solid_context = true` in the header and daslang's null checks on every pointer dereference (no `--unsafe-deref`). A row named `daslang <mode> + unsafe_deref` is the option: a separate translation of the same case with `--unsafe-deref`, `[unsafe_deref]` on every function, measured the same way; see `docs/followups/hot_path_levers.md`, which also names the next lever, vectorization of the loops the JIT leaves scalar. The aot rows are the exception named in each case's build list. Cases that repeat a headline program through a hand-written daslang entry (no `--libc std`) and the embedded micro fixtures are here only.

### pl_mpeg (MPEG-1 video decoder) — `plmpeg-stream`, 11 frames of `fixtures/sample.m1v` (22929 bytes) — micro fixture: C -O2 runs under 5 ms, noise-dominated

| variant | × C native | × C -O2 | decode loop ms (median) | decode loop ms (min) | setup ms | wall ms | startup ms |
|---|---|---|---|---|---|---|---|
| C clang-18 -O3 -march=native | 1.00× | 0.88× | 1.009 | 0.988 | 0.017 | 1.8 | 0.8 |
| C clang-18 -O2 | 1.13× | 1.00× | 1.141 | 1.133 | 0.017 | 1.9 | 0.8 |
| C clang-18 -O0 | 4.73× | 4.18× | 4.770 | 4.707 | 0.046 | 5.8 | 1.0 |
| daslang interp | 45.06× | 39.85× | 45.469 | 44.944 | 0.058 | 234.4 | 189.2 |
| daslang jit | 1.00× | 0.88× | 1.006 | 0.998 | 0.008 | 246.1 | 245.1 |
| daslang jit + unsafe_deref | 1.01× | 0.89× | 1.018 | 1.011 | 0.007 | 249.0 | 248.0 |
| daslang exe | 1.13× | 1.00× | 1.141 | 1.131 | 0.016 | 17.0 | 15.8 |
| daslang exe + unsafe_deref | 1.12× | 0.99× | 1.131 | 1.122 | 0.012 | 16.7 | 15.6 |
| daslang aot | 1.26× | 1.12× | 1.273 | 1.228 | 0.189 | 355.4 | n/a (recompiles per run) |
| daslang aot + unsafe_deref | 1.24× | 1.10× | 1.254 | 1.235 | 0.170 | 351.0 | n/a (recompiles per run) |

Builds:

- C clang-18 -O3 -march=native: `clang-18 -std=c11 -DPLM_NO_STDIO -Iinclude -Iupstream -Ifixtures -Isrc -O3 -march=native`
- C clang-18 -O2: `clang-18 -std=c11 -DPLM_NO_STDIO -Iinclude -Iupstream -Ifixtures -Isrc -O2`
- C clang-18 -O0: `clang-18 -std=c11 -DPLM_NO_STDIO -Iinclude -Iupstream -Ifixtures -Isrc -O0`
- daslang interp: `daslang plmpeg_bench_entry.das`
- daslang jit: `daslang -jit plmpeg_bench_entry.das`, split codegen with auto threads (`--jit-split-modules=-1`, daslang's default for the DLL path; not passed, because the JIT reads its switches from the script's own arguments, where it would change C `argc` — each run's JIT log is required to say `split`)
- daslang jit + unsafe_deref: as the row without the suffix, from a separate translation with `--unsafe-deref`: `daslang -jit plmpeg_bench_entry.das`, split codegen with auto threads (`--jit-split-modules=-1`, daslang's default for the DLL path; not passed, because the JIT reads its switches from the script's own arguments, where it would change C `argc` — each run's JIT log is required to say `split`)
- daslang exe: `daslang -exe plmpeg_bench_entry.das` → standalone executable
- daslang exe + unsafe_deref: as the row without the suffix, from a separate translation with `--unsafe-deref`: `daslang -exe plmpeg_bench_entry.das` → standalone executable
- daslang aot: `daslang -aot` per module + `aot_host` (policies.aot, fail_on_no_aot); **built from a second translation with `--public-module --no-solid-context --das-option disable_auto_inline`** (the fixture entry gets `options disable_auto_inline` prepended to a copy): a named public module (daslang emits AOT bodies only for those); no `solid_context` (daslang's AOT refuses the h264bsd program with it on); no daslang auto-inlining (its inlined locals land between a `goto` and its label, which the generated C++ rejects); the host recompiles the script on every run, so its start-up is not comparable
- daslang aot + unsafe_deref: `daslang -aot` per module + `aot_host` (policies.aot, fail_on_no_aot); **built from a second translation with `--unsafe-deref --public-module --no-solid-context --das-option disable_auto_inline`** (the fixture entry gets `options disable_auto_inline` prepended to a copy): a named public module (daslang emits AOT bodies only for those); no `solid_context` (daslang's AOT refuses the h264bsd program with it on); no daslang auto-inlining (its inlined locals land between a `goto` and its label, which the generated C++ rejects); the host recompiles the script on every run, so its start-up is not comparable

### h264bsd + minimp4 (H.264 baseline decoder, MP4 demuxer) — `h264bsd-mp4`, 12 frames of `fixtures/sample.mp4` (8044 bytes) — micro fixture: C -O2 runs under 5 ms, noise-dominated

| variant | × C native | × C -O2 | decode loop ms (median) | decode loop ms (min) | setup ms | wall ms | startup ms |
|---|---|---|---|---|---|---|---|
| C clang-18 -O3 -march=native | 1.00× | 1.07× | 0.717 | 0.699 | 0.020 | 1.5 | 0.8 |
| C clang-18 -O2 | 0.93× | 1.00× | 0.670 | 0.639 | 0.015 | 1.4 | 0.7 |
| C clang-18 -O0 | 3.90× | 4.17× | 2.795 | 2.792 | 0.025 | 3.7 | 0.9 |
| daslang interp | 51.56× | 55.18× | 36.970 | 36.741 | 0.229 | 254.9 | 217.7 |
| daslang jit | 1.09× | 1.17× | 0.785 | 0.734 | 0.027 | 434.7 | 433.9 |
| daslang jit + unsafe_deref | 1.09× | 1.17× | 0.783 | 0.725 | 0.024 | 425.8 | 425.0 |
| daslang exe | 0.98× | 1.05× | 0.704 | 0.699 | 0.038 | 16.8 | 16.0 |
| daslang exe + unsafe_deref | 0.97× | 1.04× | 0.699 | 0.688 | 0.039 | 17.0 | 16.3 |
| daslang aot | 1.15× | 1.23× | 0.823 | 0.803 | 0.186 | 1077.9 | n/a (recompiles per run) |
| daslang aot + unsafe_deref | 1.14× | 1.22× | 0.816 | 0.807 | 0.182 | 1080.6 | n/a (recompiles per run) |

Builds:

- C clang-18 -O3 -march=native: `clang-18 -std=c11 -w -Iinclude -Iupstream/h264bsd/src -Iupstream/minimp4 -Isrc -O3 -march=native`
- C clang-18 -O2: `clang-18 -std=c11 -w -Iinclude -Iupstream/h264bsd/src -Iupstream/minimp4 -Isrc -O2`
- C clang-18 -O0: `clang-18 -std=c11 -w -Iinclude -Iupstream/h264bsd/src -Iupstream/minimp4 -Isrc -O0`
- daslang interp: `daslang h264_bench_entry.das`
- daslang jit: `daslang -jit h264_bench_entry.das`, split codegen with auto threads (`--jit-split-modules=-1`, daslang's default for the DLL path; not passed, because the JIT reads its switches from the script's own arguments, where it would change C `argc` — each run's JIT log is required to say `split`)
- daslang jit + unsafe_deref: as the row without the suffix, from a separate translation with `--unsafe-deref`: `daslang -jit h264_bench_entry.das`, split codegen with auto threads (`--jit-split-modules=-1`, daslang's default for the DLL path; not passed, because the JIT reads its switches from the script's own arguments, where it would change C `argc` — each run's JIT log is required to say `split`)
- daslang exe: `daslang -exe h264_bench_entry.das` → standalone executable
- daslang exe + unsafe_deref: as the row without the suffix, from a separate translation with `--unsafe-deref`: `daslang -exe h264_bench_entry.das` → standalone executable
- daslang aot: `daslang -aot` per module + `aot_host` (policies.aot, fail_on_no_aot); **built from a second translation with `--public-module --no-solid-context --das-option disable_auto_inline`** (the fixture entry gets `options disable_auto_inline` prepended to a copy): a named public module (daslang emits AOT bodies only for those); no `solid_context` (daslang's AOT refuses the h264bsd program with it on); no daslang auto-inlining (its inlined locals land between a `goto` and its label, which the generated C++ rejects); the host recompiles the script on every run, so its start-up is not comparable
- daslang aot + unsafe_deref: `daslang -aot` per module + `aot_host` (policies.aot, fail_on_no_aot); **built from a second translation with `--unsafe-deref --public-module --no-solid-context --das-option disable_auto_inline`** (the fixture entry gets `options disable_auto_inline` prepended to a copy): a named public module (daslang emits AOT bodies only for those); no `solid_context` (daslang's AOT refuses the h264bsd program with it on); no daslang auto-inlining (its inlined locals land between a `goto` and its label, which the generated C++ rejects); the host recompiles the script on every run, so its start-up is not comparable

### pl_mpeg (MPEG-1 video decoder), 320×240 stream read from a file — `plmpeg-stream-320x240`, 59 frames of `fixtures/testsrc2_320x240.m1v` (266389 bytes)

| variant | × C native | × C -O2 | decode loop ms (median) | decode loop ms (min) | setup ms | wall ms | startup ms |
|---|---|---|---|---|---|---|---|
| C clang-18 -O3 -march=native | 1.00× | 0.88× | 33.855 | 33.523 | 0.137 | 35.5 | 1.4 |
| C clang-18 -O2 | 1.13× | 1.00× | 38.259 | 38.156 | 0.132 | 39.8 | 1.5 |
| C clang-18 -O0 | 4.79× | 4.24× | 162.180 | 161.182 | 0.448 | 164.3 | 1.5 |
| daslang interp | 37.33× | 33.03× | 1263.862 | 1253.773 | 0.049 | 1351.9 | 87.4 |
| daslang jit | 1.08× | 0.96× | 36.618 | 36.392 | 0.018 | 281.6 | 245.0 |
| daslang jit + unsafe_deref | 1.09× | 0.96× | 36.817 | 36.534 | 0.018 | 282.9 | 245.8 |
| daslang exe | 1.12× | 0.99× | 37.995 | 37.670 | 0.022 | 56.2 | 18.2 |
| daslang exe + unsafe_deref | 1.14× | 1.01× | 38.477 | 37.982 | 0.022 | 56.9 | 18.7 |
| daslang aot | 1.18× | 1.05× | 40.094 | 39.953 | 0.200 | 302.4 | n/a (recompiles per run) |
| daslang aot + unsafe_deref | 1.18× | 1.05× | 40.022 | 39.848 | 0.222 | 301.6 | n/a (recompiles per run) |

Builds:

- C clang-18 -O3 -march=native: `clang-18 -std=c11 -DPLM_NO_STDIO -Iinclude -Iupstream -Ifixtures -Isrc -O3 -march=native`
- C clang-18 -O2: `clang-18 -std=c11 -DPLM_NO_STDIO -Iinclude -Iupstream -Ifixtures -Isrc -O2`
- C clang-18 -O0: `clang-18 -std=c11 -DPLM_NO_STDIO -Iinclude -Iupstream -Ifixtures -Isrc -O0`
- daslang interp: `daslang plmpeg_file_bench_entry.das`
- daslang jit: `daslang -jit plmpeg_file_bench_entry.das`, split codegen with auto threads (`--jit-split-modules=-1`, daslang's default for the DLL path; not passed, because the JIT reads its switches from the script's own arguments, where it would change C `argc` — each run's JIT log is required to say `split`)
- daslang jit + unsafe_deref: as the row without the suffix, from a separate translation with `--unsafe-deref`: `daslang -jit plmpeg_file_bench_entry.das`, split codegen with auto threads (`--jit-split-modules=-1`, daslang's default for the DLL path; not passed, because the JIT reads its switches from the script's own arguments, where it would change C `argc` — each run's JIT log is required to say `split`)
- daslang exe: `daslang -exe plmpeg_file_bench_entry.das` → standalone executable
- daslang exe + unsafe_deref: as the row without the suffix, from a separate translation with `--unsafe-deref`: `daslang -exe plmpeg_file_bench_entry.das` → standalone executable
- daslang aot: `daslang -aot` per module + `aot_host` (policies.aot, fail_on_no_aot); **built from a second translation with `--public-module --no-solid-context --das-option disable_auto_inline`** (the fixture entry gets `options disable_auto_inline` prepended to a copy): a named public module (daslang emits AOT bodies only for those); no `solid_context` (daslang's AOT refuses the h264bsd program with it on); no daslang auto-inlining (its inlined locals land between a `goto` and its label, which the generated C++ rejects); the host recompiles the script on every run, so its start-up is not comparable
- daslang aot + unsafe_deref: `daslang -aot` per module + `aot_host` (policies.aot, fail_on_no_aot); **built from a second translation with `--unsafe-deref --public-module --no-solid-context --das-option disable_auto_inline`** (the fixture entry gets `options disable_auto_inline` prepended to a copy): a named public module (daslang emits AOT bodies only for those); no `solid_context` (daslang's AOT refuses the h264bsd program with it on); no daslang auto-inlining (its inlined locals land between a `goto` and its label, which the generated C++ rejects); the host recompiles the script on every run, so its start-up is not comparable

### h264bsd + minimp4, 640×360 upstream test vector read from a file — `h264bsd-mp4-640x360`, 73 frames of `fixtures/test_640x360.mp4` (232093 bytes)

| variant | × C native | × C -O2 | decode loop ms (median) | decode loop ms (min) | setup ms | wall ms | startup ms |
|---|---|---|---|---|---|---|---|
| C clang-18 -O3 -march=native | 1.00× | 1.03× | 74.692 | 73.827 | 0.026 | 76.4 | 1.6 |
| C clang-18 -O2 | 0.97× | 1.00× | 72.492 | 72.355 | 0.020 | 74.1 | 1.6 |
| C clang-18 -O0 | 5.30× | 5.46× | 395.838 | 394.002 | 0.033 | 397.3 | 1.6 |
| daslang interp | 55.07× | 56.74× | 4113.029 | 4072.600 | 0.281 | 4311.7 | 201.0 |
| daslang jit | 1.02× | 1.05× | 76.436 | 76.205 | 0.023 | 483.1 | 406.5 |
| daslang jit + unsafe_deref | 1.00× | 1.03× | 74.983 | 74.210 | 0.023 | 487.3 | 411.6 |
| daslang exe | 1.05× | 1.08× | 78.200 | 77.362 | 0.039 | 96.8 | 18.5 |
| daslang exe + unsafe_deref | 0.99× | 1.02× | 73.725 | 73.335 | 0.037 | 92.1 | 18.3 |
| daslang aot | 1.12× | 1.15× | 83.409 | 83.174 | 0.188 | 1124.8 | n/a (recompiles per run) |
| daslang aot + unsafe_deref | 1.10× | 1.13× | 82.220 | 81.508 | 0.153 | 1137.1 | n/a (recompiles per run) |

Builds:

- C clang-18 -O3 -march=native: `clang-18 -std=c11 -w -Iinclude -Iupstream/h264bsd/src -Iupstream/minimp4 -Isrc -O3 -march=native`
- C clang-18 -O2: `clang-18 -std=c11 -w -Iinclude -Iupstream/h264bsd/src -Iupstream/minimp4 -Isrc -O2`
- C clang-18 -O0: `clang-18 -std=c11 -w -Iinclude -Iupstream/h264bsd/src -Iupstream/minimp4 -Isrc -O0`
- daslang interp: `daslang h264_file_bench_entry.das`
- daslang jit: `daslang -jit h264_file_bench_entry.das`, split codegen with auto threads (`--jit-split-modules=-1`, daslang's default for the DLL path; not passed, because the JIT reads its switches from the script's own arguments, where it would change C `argc` — each run's JIT log is required to say `split`)
- daslang jit + unsafe_deref: as the row without the suffix, from a separate translation with `--unsafe-deref`: `daslang -jit h264_file_bench_entry.das`, split codegen with auto threads (`--jit-split-modules=-1`, daslang's default for the DLL path; not passed, because the JIT reads its switches from the script's own arguments, where it would change C `argc` — each run's JIT log is required to say `split`)
- daslang exe: `daslang -exe h264_file_bench_entry.das` → standalone executable
- daslang exe + unsafe_deref: as the row without the suffix, from a separate translation with `--unsafe-deref`: `daslang -exe h264_file_bench_entry.das` → standalone executable
- daslang aot: `daslang -aot` per module + `aot_host` (policies.aot, fail_on_no_aot); **built from a second translation with `--public-module --no-solid-context --das-option disable_auto_inline`** (the fixture entry gets `options disable_auto_inline` prepended to a copy): a named public module (daslang emits AOT bodies only for those); no `solid_context` (daslang's AOT refuses the h264bsd program with it on); no daslang auto-inlining (its inlined locals land between a `goto` and its label, which the generated C++ rejects); the host recompiles the script on every run, so its start-up is not comparable
- daslang aot + unsafe_deref: `daslang -aot` per module + `aot_host` (policies.aot, fail_on_no_aot); **built from a second translation with `--unsafe-deref --public-module --no-solid-context --das-option disable_auto_inline`** (the fixture entry gets `options disable_auto_inline` prepended to a copy): a named public module (daslang emits AOT bodies only for those); no `solid_context` (daslang's AOT refuses the h264bsd program with it on); no daslang auto-inlining (its inlined locals land between a `goto` and its label, which the generated C++ rejects); the host recompiles the script on every run, so its start-up is not comparable

### pl_mpeg (MPEG-1 video decoder), 320×240 stream, C entry translated under --libc std — `plmpeg-stream-320x240-std`, 59 frames of `fixtures/testsrc2_320x240.m1v` (266389 bytes) — in the headline table

| variant | × C native | × C -O2 | decode loop ms (median) | decode loop ms (min) | setup ms | wall ms | startup ms |
|---|---|---|---|---|---|---|---|
| C clang-18 -O3 -march=native | 1.00× | 0.91× | 34.481 | 34.029 | 0.137 | 36.0 | 1.4 |
| C clang-18 -O2 | 1.10× | 1.00× | 37.952 | 37.824 | 0.135 | 39.6 | 1.5 |
| C clang-18 -O0 | 4.67× | 4.24× | 160.961 | 160.314 | 0.448 | 162.8 | 1.4 |
| daslang interp | 36.85× | 33.48× | 1270.724 | 1248.641 | 0.043 | 1339.6 | 69.8 |
| daslang jit | 1.09× | 0.99× | 37.575 | 37.113 | 0.048 | 302.5 | 257.0 |
| daslang jit + unsafe_deref | 1.05× | 0.96× | 36.348 | 36.293 | 0.050 | 260.9 | 224.6 |
| daslang exe | 1.11× | 1.01× | 38.255 | 38.188 | 0.015 | 56.7 | 18.5 |
| daslang exe + unsafe_deref | 1.11× | 1.00× | 38.113 | 38.099 | 0.015 | 56.7 | 18.5 |
| daslang aot | 1.17× | 1.06× | 40.277 | 40.131 | 0.019 | 313.2 | n/a (recompiles per run) |
| daslang aot + unsafe_deref | 1.17× | 1.06× | 40.363 | 40.129 | 0.049 | 319.6 | n/a (recompiles per run) |

Builds:

- C clang-18 -O3 -march=native: `clang-18 -std=c11 -DPLM_NO_STDIO -Iinclude -Iupstream -Ifixtures -Isrc -O3 -march=native`
- C clang-18 -O2: `clang-18 -std=c11 -DPLM_NO_STDIO -Iinclude -Iupstream -Ifixtures -Isrc -O2`
- C clang-18 -O0: `clang-18 -std=c11 -DPLM_NO_STDIO -Iinclude -Iupstream -Ifixtures -Isrc -O0`
- daslang interp: `daslang plmpeg_file_bench_all.das`
- daslang jit: `daslang -jit plmpeg_file_bench_all.das`, split codegen with auto threads (`--jit-split-modules=-1`, daslang's default for the DLL path; not passed, because the JIT reads its switches from the script's own arguments, where it would change C `argc` — each run's JIT log is required to say `split`)
- daslang jit + unsafe_deref: as the row without the suffix, from a separate translation with `--unsafe-deref`: `daslang -jit plmpeg_file_bench_all.das`, split codegen with auto threads (`--jit-split-modules=-1`, daslang's default for the DLL path; not passed, because the JIT reads its switches from the script's own arguments, where it would change C `argc` — each run's JIT log is required to say `split`)
- daslang exe: `daslang -exe plmpeg_file_bench_all.das` → standalone executable
- daslang exe + unsafe_deref: as the row without the suffix, from a separate translation with `--unsafe-deref`: `daslang -exe plmpeg_file_bench_all.das` → standalone executable
- daslang aot: `daslang -aot` per module + `aot_host` (policies.aot, fail_on_no_aot); **built from a second translation with `--no-solid-context --das-option disable_auto_inline`**: no `solid_context` (daslang's AOT refuses the h264bsd program with it on); no daslang auto-inlining (its inlined locals land between a `goto` and its label, which the generated C++ rejects); the host recompiles the script on every run, so its start-up is not comparable
- daslang aot + unsafe_deref: `daslang -aot` per module + `aot_host` (policies.aot, fail_on_no_aot); **built from a second translation with `--unsafe-deref --no-solid-context --das-option disable_auto_inline`**: no `solid_context` (daslang's AOT refuses the h264bsd program with it on); no daslang auto-inlining (its inlined locals land between a `goto` and its label, which the generated C++ rejects); the host recompiles the script on every run, so its start-up is not comparable

### h264bsd + minimp4, 640×360 upstream test vector, C entry translated under --libc std — `h264bsd-mp4-640x360-std`, 73 frames of `fixtures/test_640x360.mp4` (232093 bytes) — in the headline table

| variant | × C native | × C -O2 | decode loop ms (median) | decode loop ms (min) | setup ms | wall ms | startup ms |
|---|---|---|---|---|---|---|---|
| C clang-18 -O3 -march=native | 1.00× | 0.95× | 74.239 | 74.004 | 0.023 | 75.8 | 1.6 |
| C clang-18 -O2 | 1.05× | 1.00× | 77.969 | 75.119 | 0.018 | 79.6 | 1.7 |
| C clang-18 -O0 | 5.48× | 5.22× | 406.801 | 399.341 | 0.033 | 408.5 | 1.6 |
| daslang interp | 55.20× | 52.56× | 4098.230 | 4073.915 | 0.279 | 4311.4 | 210.1 |
| daslang jit | 1.05× | 1.00× | 77.817 | 77.457 | 0.020 | 504.9 | 426.9 |
| daslang jit + unsafe_deref | 1.00× | 0.95× | 74.319 | 74.037 | 0.023 | 504.0 | 429.6 |
| daslang exe | 1.05× | 1.00× | 77.585 | 77.392 | 0.023 | 96.4 | 18.7 |
| daslang exe + unsafe_deref | 1.00× | 0.95× | 74.126 | 73.974 | 0.018 | 92.9 | 18.7 |
| daslang aot | 1.15× | 1.10× | 85.548 | 84.786 | 0.018 | 1189.9 | n/a (recompiles per run) |
| daslang aot + unsafe_deref | 1.12× | 1.07× | 83.447 | 82.895 | 0.020 | 1189.2 | n/a (recompiles per run) |

Builds:

- C clang-18 -O3 -march=native: `clang-18 -std=c11 -w -Iinclude -Iupstream/h264bsd/src -Iupstream/minimp4 -Isrc -O3 -march=native`
- C clang-18 -O2: `clang-18 -std=c11 -w -Iinclude -Iupstream/h264bsd/src -Iupstream/minimp4 -Isrc -O2`
- C clang-18 -O0: `clang-18 -std=c11 -w -Iinclude -Iupstream/h264bsd/src -Iupstream/minimp4 -Isrc -O0`
- daslang interp: `daslang h264_file_bench_all.das`
- daslang jit: `daslang -jit h264_file_bench_all.das`, split codegen with auto threads (`--jit-split-modules=-1`, daslang's default for the DLL path; not passed, because the JIT reads its switches from the script's own arguments, where it would change C `argc` — each run's JIT log is required to say `split`)
- daslang jit + unsafe_deref: as the row without the suffix, from a separate translation with `--unsafe-deref`: `daslang -jit h264_file_bench_all.das`, split codegen with auto threads (`--jit-split-modules=-1`, daslang's default for the DLL path; not passed, because the JIT reads its switches from the script's own arguments, where it would change C `argc` — each run's JIT log is required to say `split`)
- daslang exe: `daslang -exe h264_file_bench_all.das` → standalone executable
- daslang exe + unsafe_deref: as the row without the suffix, from a separate translation with `--unsafe-deref`: `daslang -exe h264_file_bench_all.das` → standalone executable
- daslang aot: `daslang -aot` per module + `aot_host` (policies.aot, fail_on_no_aot); **built from a second translation with `--no-solid-context --das-option disable_auto_inline`**: no `solid_context` (daslang's AOT refuses the h264bsd program with it on); no daslang auto-inlining (its inlined locals land between a `goto` and its label, which the generated C++ rejects); the host recompiles the script on every run, so its start-up is not comparable
- daslang aot + unsafe_deref: `daslang -aot` per module + `aot_host` (policies.aot, fail_on_no_aot); **built from a second translation with `--unsafe-deref --no-solid-context --das-option disable_auto_inline`**: no `solid_context` (daslang's AOT refuses the h264bsd program with it on); no daslang auto-inlining (its inlined locals land between a `goto` and its label, which the generated C++ rejects); the host recompiles the script on every run, so its start-up is not comparable

### wasm3 (WebAssembly interpreter core, no WASI), fib32 module, C entry translated under --libc std — `wasm3-fib32-std`, 7 checked values of `fixtures/fib32.wasm` (62 bytes) — in the headline table

| variant | × C native | × C -O2 | fib call loop ms (median) | fib call loop ms (min) | setup ms | wall ms | startup ms |
|---|---|---|---|---|---|---|---|
| C clang-18 -O3 -march=native | 1.00× | 1.01× | 1.797 | 1.742 | 0.064 | 2.8 | 1.0 |
| C clang-18 -O2 | 0.99× | 1.00× | 1.780 | 1.746 | 0.060 | 2.8 | 1.0 |
| C clang-18 -O0 | 2.53× | 2.55× | 4.541 | 4.495 | 0.076 | 5.6 | 1.0 |
| daslang interp | 61.48× | 62.07× | 110.482 | 110.327 | 0.320 | 530.1 | 419.2 |
| daslang jit | 2.54× | 2.56× | 4.562 | 4.557 | 0.069 | 563.4 | 558.8 |
| daslang jit + unsafe_deref | 2.55× | 2.58× | 4.584 | 4.482 | 0.052 | 561.9 | 557.3 |
| daslang exe | 2.49× | 2.51× | 4.470 | 4.317 | 0.043 | 23.9 | 19.4 |
| daslang exe + unsafe_deref | 2.63× | 2.65× | 4.719 | 4.547 | 0.041 | 24.1 | 19.5 |
| daslang aot | 1.50× | 1.51× | 2.694 | 2.658 | 0.063 | 1402.7 | n/a (recompiles per run) |
| daslang aot + unsafe_deref | 1.42× | 1.44× | 2.558 | 2.526 | 0.051 | 1583.7 | n/a (recompiles per run) |

wasm3: the `-jit`/`-exe` path makes no tail calls — daslang's LLVM backend never emits sibling calls, so every executed wasm opcode costs a native frame — while the AOT C++ gets them from `clang++ -O3`; hence aot ahead of jit/exe here ([lookibed/daScript#4](https://github.com/lookibed/daScript/issues/4), `docs/followups/translator_gaps_wasm3.md`).

Builds:

- C clang-18 -O3 -march=native: `clang-18 -std=c11 -Iinclude -Iupstream/wasm3/source -Isrc -O3 -march=native`
- C clang-18 -O2: `clang-18 -std=c11 -Iinclude -Iupstream/wasm3/source -Isrc -O2`
- C clang-18 -O0: `clang-18 -std=c11 -Iinclude -Iupstream/wasm3/source -Isrc -O0`
- daslang interp: `daslang all_host_bench.das`
- daslang jit: `daslang -jit all_host_bench.das`, split codegen with auto threads (`--jit-split-modules=-1`, daslang's default for the DLL path; not passed, because the JIT reads its switches from the script's own arguments, where it would change C `argc` — each run's JIT log is required to say `split`)
- daslang jit + unsafe_deref: as the row without the suffix, from a separate translation with `--unsafe-deref`: `daslang -jit all_host_bench.das`, split codegen with auto threads (`--jit-split-modules=-1`, daslang's default for the DLL path; not passed, because the JIT reads its switches from the script's own arguments, where it would change C `argc` — each run's JIT log is required to say `split`)
- daslang exe: `daslang -exe all_host_bench.das` → standalone executable
- daslang exe + unsafe_deref: as the row without the suffix, from a separate translation with `--unsafe-deref`: `daslang -exe all_host_bench.das` → standalone executable
- daslang aot: `daslang -aot` per module + `aot_host` (policies.aot, fail_on_no_aot); **built from a second translation with `--no-solid-context --das-option disable_auto_inline`**: no `solid_context` (daslang's AOT refuses the h264bsd program with it on); no daslang auto-inlining (its inlined locals land between a `goto` and its label, which the generated C++ rejects); the host recompiles the script on every run, so its start-up is not comparable
- daslang aot + unsafe_deref: `daslang -aot` per module + `aot_host` (policies.aot, fail_on_no_aot); **built from a second translation with `--unsafe-deref --no-solid-context --das-option disable_auto_inline`**: no `solid_context` (daslang's AOT refuses the h264bsd program with it on); no daslang auto-inlining (its inlined locals land between a `goto` and its label, which the generated C++ rejects); the host recompiles the script on every run, so its start-up is not comparable

### binjgb (Game Boy Color emulator core), cgb-acid2 ROM, C entry translated under --libc std — `binjgb-cgb-acid2-std`, 300 frames of `fixtures/cgb-acid2.gbc` (32768 bytes) — in the headline table

| variant | × C native | × C -O2 | frame loop ms (median) | frame loop ms (min) | setup ms | wall ms | startup ms |
|---|---|---|---|---|---|---|---|
| C clang-18 -O3 -march=native | 1.00× | 0.99× | 58.050 | 57.699 | 0.178 | 59.6 | 1.4 |
| C clang-18 -O2 | 1.01× | 1.00× | 58.688 | 58.060 | 0.178 | 60.3 | 1.4 |
| C clang-18 -O0 | 3.48× | 3.44× | 201.873 | 200.986 | 0.361 | 203.6 | 1.4 |
| daslang interp | 81.76× | 80.87× | 4746.390 | 4714.183 | 2.104 | 4937.2 | 188.9 |
| daslang jit | 1.04× | 1.03× | 60.357 | 60.218 | 0.134 | 438.3 | 377.3 |
| daslang jit + unsafe_deref | 1.13× | 1.12× | 65.448 | 65.279 | 0.144 | 468.4 | 401.8 |
| daslang exe | 1.16× | 1.14× | 67.158 | 67.096 | 0.103 | 87.8 | 20.6 |
| daslang exe + unsafe_deref | 1.12× | 1.11× | 64.870 | 64.601 | 0.093 | 85.4 | 20.3 |
| daslang aot | 1.17× | 1.16× | 68.112 | 67.791 | 0.095 | 772.0 | n/a (recompiles per run) |
| daslang aot + unsafe_deref | 1.19× | 1.18× | 69.148 | 68.803 | 0.088 | 795.0 | n/a (recompiles per run) |

Builds:

- C clang-18 -O3 -march=native: `clang-18 -std=c11 -DNDEBUG -Iinclude -Iupstream/binjgb/src -Isrc -O3 -march=native`
- C clang-18 -O2: `clang-18 -std=c11 -DNDEBUG -Iinclude -Iupstream/binjgb/src -Isrc -O2`
- C clang-18 -O0: `clang-18 -std=c11 -DNDEBUG -Iinclude -Iupstream/binjgb/src -Isrc -O0`
- daslang interp: `daslang binjgb_bench_all.das`
- daslang jit: `daslang -jit binjgb_bench_all.das`, split codegen with auto threads (`--jit-split-modules=-1`, daslang's default for the DLL path; not passed, because the JIT reads its switches from the script's own arguments, where it would change C `argc` — each run's JIT log is required to say `split`)
- daslang jit + unsafe_deref: as the row without the suffix, from a separate translation with `--unsafe-deref`: `daslang -jit binjgb_bench_all.das`, split codegen with auto threads (`--jit-split-modules=-1`, daslang's default for the DLL path; not passed, because the JIT reads its switches from the script's own arguments, where it would change C `argc` — each run's JIT log is required to say `split`)
- daslang exe: `daslang -exe binjgb_bench_all.das` → standalone executable
- daslang exe + unsafe_deref: as the row without the suffix, from a separate translation with `--unsafe-deref`: `daslang -exe binjgb_bench_all.das` → standalone executable
- daslang aot: `daslang -aot` per module + `aot_host` (policies.aot, fail_on_no_aot); **built from a second translation with `--no-solid-context --das-option disable_auto_inline`**: no `solid_context` (daslang's AOT refuses the h264bsd program with it on); no daslang auto-inlining (its inlined locals land between a `goto` and its label, which the generated C++ rejects); the host recompiles the script on every run, so its start-up is not comparable
- daslang aot + unsafe_deref: `daslang -aot` per module + `aot_host` (policies.aot, fail_on_no_aot); **built from a second translation with `--unsafe-deref --no-solid-context --das-option disable_auto_inline`**: no `solid_context` (daslang's AOT refuses the h264bsd program with it on); no daslang auto-inlining (its inlined locals land between a `goto` and its label, which the generated C++ rejects); the host recompiles the script on every run, so its start-up is not comparable

### doomgeneric (Doom engine), -timedemo demo1 of the shareware IWAD, C entry translated under --libc std — `doomgeneric-demo1-std`, 1000 frames of `fixtures/doom1.wad` (4196020 bytes) — in the headline table

| variant | × C native | × C -O2 | demo tick loop ms (median) | demo tick loop ms (min) | setup ms | wall ms | startup ms |
|---|---|---|---|---|---|---|---|
| C clang-18 -O3 -march=native | 1.00× | 0.98× | 118.478 | 118.412 | 6.782 | 127.7 | 2.4 |
| C clang-18 -O2 | 1.02× | 1.00× | 121.237 | 119.847 | 6.808 | 130.4 | 2.4 |
| C clang-18 -O0 | 2.75× | 2.68× | 325.491 | 324.711 | 12.530 | 340.7 | 2.4 |
| daslang interp | 54.84× | 53.59× | 6497.578 | 6209.690 | 169.060 | 7323.7 | 649.2 |
| daslang jit | 1.14× | 1.12× | 135.426 | 125.453 | 7.593 | 1079.9 | 928.2 |
| daslang jit + unsafe_deref | 0.96× | 0.94× | 113.655 | 113.279 | 5.508 | 952.3 | 824.8 |
| daslang exe | 1.05× | 1.03× | 124.366 | 124.121 | 5.852 | 152.1 | 21.6 |
| daslang exe + unsafe_deref | 0.96× | 0.94× | 113.668 | 113.483 | 5.783 | 141.3 | 21.6 |
| daslang aot | 4.72× | 4.61× | 559.140 | 556.303 | 13.801 | 3217.1 | n/a (recompiles per run) |
| daslang aot + unsafe_deref | 4.69× | 4.58× | 555.859 | 553.924 | 13.570 | 3216.1 | n/a (recompiles per run) |

Builds:

- C clang-18 -O3 -march=native: `clang-18 -std=c11 -Iinclude -Iupstream/doomgeneric/doomgeneric -Isrc -O3 -march=native`
- C clang-18 -O2: `clang-18 -std=c11 -Iinclude -Iupstream/doomgeneric/doomgeneric -Isrc -O2`
- C clang-18 -O0: `clang-18 -std=c11 -Iinclude -Iupstream/doomgeneric/doomgeneric -Isrc -O0`
- daslang interp: `daslang doom_bench_all.das`
- daslang jit: `daslang -jit doom_bench_all.das`, split codegen with auto threads (`--jit-split-modules=-1`, daslang's default for the DLL path; not passed, because the JIT reads its switches from the script's own arguments, where it would change C `argc` — each run's JIT log is required to say `split`)
- daslang jit + unsafe_deref: as the row without the suffix, from a separate translation with `--unsafe-deref`: `daslang -jit doom_bench_all.das`, split codegen with auto threads (`--jit-split-modules=-1`, daslang's default for the DLL path; not passed, because the JIT reads its switches from the script's own arguments, where it would change C `argc` — each run's JIT log is required to say `split`)
- daslang exe: `daslang -exe doom_bench_all.das` → standalone executable
- daslang exe + unsafe_deref: as the row without the suffix, from a separate translation with `--unsafe-deref`: `daslang -exe doom_bench_all.das` → standalone executable
- daslang aot: `daslang -aot` per module + `aot_host` (policies.aot, fail_on_no_aot); **built from a second translation with `--no-solid-context --das-option disable_auto_inline`**: no `solid_context` (daslang's AOT refuses the h264bsd program with it on); no daslang auto-inlining (its inlined locals land between a `goto` and its label, which the generated C++ rejects); the host recompiles the script on every run, so its start-up is not comparable
- daslang aot + unsafe_deref: `daslang -aot` per module + `aot_host` (policies.aot, fail_on_no_aot); **built from a second translation with `--unsafe-deref --no-solid-context --das-option disable_auto_inline`**: no `solid_context` (daslang's AOT refuses the h264bsd program with it on); no daslang auto-inlining (its inlined locals land between a `goto` and its label, which the generated C++ rejects); the host recompiles the script on every run, so its start-up is not comparable
