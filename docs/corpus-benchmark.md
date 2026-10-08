# Corpus benchmark: how much slower than C is c2das-translated C, per daslang run mode

Each program below is a C code base translated whole by c2das and run in each daslang mode against the same C compiled natively. The snapshot answers the one question — which daslang mode, how many times slower than C — and the appendix holds every number behind it, every build command and every variant (the hand-written-entry cases and the embedded micro fixtures included). The measurement rules are in `docs/benchmark-methodology.md`.

## Benchmark Snapshot

### Linux — AMD Ryzen 7 7435HS

Platform information:

- Captured by `python3 scripts/corpus_matrix.py bench --runs 5` on 2026-10-08 at commit `712474e26`
- OS: Ubuntu 22.04.5 LTS, kernel 6.6.87.2-microsoft-standard-WSL2
- Toolchain: Ubuntu clang version 18.1.8 (++20240731024944+3b5b5c1ec4a3-1~exp1~20240731145000.144); daslang 0.6.4
- Programs: each one a C code base translated whole by c2das (`c2dascript-transpile --strict --libc std`, the C `main` included) and run unchanged in every daslang mode

A cell is the median of 5 runs, each its own process after one warm-up run, of the time the program itself measures around its work loop (the decode loop of the video decoders, the frame loop of the emulators, the call loop of wasm3) — process start, script compilation and JIT codegen are not in it (they are in the Startup table). `±` is half the sample range as a share of the median. Lower is better. The fastest result in each row is in bold. `-` means no value: the mode failed its per-frame hash check against C or did not build. Every mode's per-frame (per-value) hashes are checked against the C build's on every run; a mode that ever differs is reported as failed, never timed. `(micro)` marks a program whose C -O2 work loop runs under 5 ms, where timer resolution and cache state dominate the ratios.

#### Translated C vs native C

| Program | C -O3 native | C -O2 | DAS interpreter | DAS JIT | DAS exe | DAS AOT\* |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| pl_mpeg (MPEG-1 video), 320×240, 59 frames | **33.25ms** ±1% | 36.88ms ±1% | 1143.81ms ±1% | 36.14ms ±1% | 38.77ms ±1% | 40.10ms ±1% |
| h264bsd + minimp4 (H.264 video), 640×360, 73 frames | 74.71ms ±1% | **72.93ms** ±1% | 3786.62ms ±1% | 77.14ms ±2% | 79.68ms ±1% | 87.71ms ±12% |
| wasm3 (WebAssembly interpreter), fib32, 7 checked values (micro) | **1.77ms** ±3% | 1.79ms ±3% | 111.33ms ±1% | 4.63ms ±3% | 4.26ms ±1% | 2.80ms ±4% |
| binjgb (Game Boy Color emulator), cgb-acid2, 300 frames | 58.15ms ±1% | **57.42ms** ±1% | 4044.06ms ±2% | 59.93ms ±1% | 60.52ms ±1% | 63.69ms ±1% |
| doomgeneric (Doom engine), 320×200, 1000 frames | **110.34ms** ±0% | 111.53ms ±1% | 3868.26ms ±1% | 128.21ms ±0% | 121.74ms ±1% | 393.28ms ±1% |

#### Ratio to C -O3 native

The same measurements as the slowdown against `clang-18 -O3 -march=native` (1.00× is C speed); `C -O2` is the portable generic-x86-64 build, kept as the reference a `clang -O2` user would see.

| Program | C -O2 | DAS interpreter | DAS JIT | DAS exe | DAS AOT\* |
| --- | ---: | ---: | ---: | ---: | ---: |
| pl_mpeg (MPEG-1 video), 320×240, 59 frames | 1.11× ±1% | 34.40× ±1% | **1.09×** ±1% | 1.17× ±1% | 1.21× ±1% |
| h264bsd + minimp4 (H.264 video), 640×360, 73 frames | **0.98×** ±1% | 50.68× ±1% | 1.03× ±2% | 1.07× ±1% | 1.17× ±12% |
| wasm3 (WebAssembly interpreter), fib32, 7 checked values (micro) | **1.01×** ±3% | 62.97× ±1% | 2.62× ±3% | 2.41× ±1% | 1.58× ±4% |
| binjgb (Game Boy Color emulator), cgb-acid2, 300 frames | **0.99×** ±1% | 69.55× ±2% | 1.03× ±1% | 1.04× ±1% | 1.10× ±1% |
| doomgeneric (Doom engine), 320×200, 1000 frames | **1.01×** ±1% | 35.06× ±1% | 1.16× ±0% | 1.10× ±1% | 3.56× ±1% |

#### Option: `--unsafe-deref`

The tables above are the translator's default output. These rows come from a second translation of each program with `[unsafe_deref]` on every function, which removes daslang's null check in front of every pointer dereference (`ExprAt`, `ExprPtr2Ref`, field access): C's unchecked access, where a null dereference crashes instead of raising a located daslang exception. It is an option, not the default — the same effect is available by writing the code on raw pointers; it is a choice of which unsafety to accept — and the annotation has a known miscompile ([lookibed/daScript#7](https://github.com/lookibed/daScript/issues/7)), which the per-frame hash check guards these rows against (`docs/followups/hot_path_levers.md`). Cells are the ratio to the same `clang-18 -O3 -march=native` build, and in parentheses the change against the same mode without the option (negative = faster).

| Program | DAS JIT + unsafe_deref | DAS exe + unsafe_deref | DAS AOT\* + unsafe_deref |
| --- | ---: | ---: | ---: |
| pl_mpeg (MPEG-1 video), 320×240, 59 frames | **1.09×** ±1% (+0 %) | 1.13× ±2% (−3 %) | 1.20× ±1% (−0 %) |
| h264bsd + minimp4 (H.264 video), 640×360, 73 frames | **0.99×** ±0% (−5 %) | 1.05× ±5% (−2 %) | 1.11× ±1% (−6 %) |
| wasm3 (WebAssembly interpreter), fib32, 7 checked values (micro) | 2.56× ±1% (−2 %) | 2.48× ±4% (+3 %) | **1.40×** ±3% (−11 %) |
| binjgb (Game Boy Color emulator), cgb-acid2, 300 frames | 1.05× ±1% (+2 %) | **1.03×** ±1% (−1 %) | 1.11× ±1% (+1 %) |
| doomgeneric (Doom engine), 320×200, 1000 frames | **1.03×** ±3% (−11 %) | 1.04× ±1% (−6 %) | 3.62× ±1% (+1 %) |

#### Startup

Wall time of the whole process minus the timed work and the timed setup: process start, loading the runtime, compiling the script, JIT codegen and teardown. The AOT host recompiles the script on every launch, so its start-up is a compiler's, not a program's, and is shown as `-`.

| Program | C -O3 native | C -O2 | DAS interpreter | DAS JIT | DAS exe | DAS AOT\* |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| pl_mpeg (MPEG-1 video), 320×240, 59 frames | 1.7ms ±8% | **1.6ms** ±10% | 75.7ms ±2% | 231.4ms ±1% | 20.6ms ±3% | - |
| h264bsd + minimp4 (H.264 video), 640×360, 73 frames | **1.8ms** ±8% | 1.8ms ±6% | 205.3ms ±3% | 425.7ms ±2% | 21.4ms ±3% | - |
| wasm3 (WebAssembly interpreter), fib32, 7 checked values (micro) | 1.0ms ±5% | **1.0ms** ±15% | 401.6ms ±4% | 554.0ms ±3% | 21.1ms ±2% | - |
| binjgb (Game Boy Color emulator), cgb-acid2, 300 frames | 1.6ms ±1% | **1.5ms** ±5% | 183.6ms ±1% | 370.8ms ±2% | 21.1ms ±3% | - |
| doomgeneric (Doom engine), 320×200, 1000 frames | **2.6ms** ±6% | 2.6ms ±5% | 507.0ms ±1% | 798.3ms ±2% | 24.6ms ±3% | - |

\* AOT is built from a second translation without `solid_context` and without daslang's auto-inliner (`--no-solid-context --das-option disable_auto_inline`), because daslang's AOT refuses the h264bsd program with `solid_context` on and its inliner produces C++ that does not compile; every other mode runs the default translation (`options solid_context = true`, daslang's null checks on every pointer dereference). The JIT runs daslang's default split codegen with auto threads (`--jit-split-modules=-1`, not passed — see the appendix). wasm3: the `-jit`/`-exe` path makes no tail calls — daslang's LLVM backend never emits sibling calls, so every executed wasm opcode costs a native frame — while the AOT C++ gets them from `clang++ -O3`; hence aot ahead of jit/exe here ([lookibed/daScript#4](https://github.com/lookibed/daScript/issues/4), `docs/followups/translator_gaps_wasm3.md`).

---

## Appendix: full measurements

Reference data behind the snapshot above. Generated by `python3 scripts/corpus_matrix.py bench` on 2026-10-08 at commit `712474e26` (daslang 0.6.4 (/root/daScript/bin/daslang); Ubuntu clang version 18.1.8 (++20240731024944+3b5b5c1ec4a3-1~exp1~20240731145000.144); AMD Ryzen 7 7435HS; Ubuntu 22.04.5 LTS, kernel 6.6.87.2-microsoft-standard-WSL2). Every build and run command is written out in `docs/corpus-build-recipe.md`.

Columns: **ms (median / min)** is the program's own timer around its work loop (`decode_us`; C `clock_gettime(CLOCK_MONOTONIC)`, daslang `ref_time_ticks`), excluding process start, script compilation, JIT codegen and setup. **setup** is the timed `frames_begin_bytes()` call (runtime reset, working copy of the input, decoder creation). **wall** is the whole process as the driver sees it and **startup** = wall − work − setup (loading the runtime, compiling the script, JIT codegen, teardown); the aot host compiles the script again on every launch, so its startup is not shown. **× C native** is the ratio to `clang-18 -O3 -march=native`, the headline; **× C -O2** to the portable `clang-18 -O2` build (generic x86-64, SSE2), shown for reference because daslang's LLVM backend compiles `-jit` for the host CPU. The translated modules are the translator's defaults: `options solid_context = true` in the header and daslang's null checks on every pointer dereference (no `--unsafe-deref`). A row named `daslang <mode> + unsafe_deref` is the option: a separate translation of the same case with `--unsafe-deref`, `[unsafe_deref]` on every function, measured the same way; see `docs/followups/hot_path_levers.md`, which also names the next lever, vectorization of the loops the JIT leaves scalar. The aot rows are the exception named in each case's build list. Cases that repeat a headline program through a hand-written daslang entry (no `--libc std`) and the embedded micro fixtures are here only.

### pl_mpeg (MPEG-1 video decoder) — `plmpeg-stream`, 11 frames of `fixtures/sample.m1v` (22929 bytes) — micro fixture: C -O2 runs under 5 ms, noise-dominated

| variant | × C native | × C -O2 | decode loop ms (median) | decode loop ms (min) | setup ms | wall ms | startup ms |
|---|---|---|---|---|---|---|---|
| C clang-18 -O3 -march=native | 1.00× | 0.88× | 0.991 | 0.985 | 0.019 | 2.0 | 1.0 |
| C clang-18 -O2 | 1.14× | 1.00× | 1.129 | 1.106 | 0.019 | 2.2 | 1.0 |
| C clang-18 -O0 | 4.87× | 4.27× | 4.822 | 4.759 | 0.048 | 5.9 | 1.1 |
| daslang interp | 43.27× | 37.98× | 42.880 | 42.351 | 0.052 | 232.8 | 188.3 |
| daslang jit | 1.04× | 0.91× | 1.027 | 1.015 | 0.007 | 264.4 | 263.4 |
| daslang jit + unsafe_deref | 1.05× | 0.92× | 1.041 | 1.024 | 0.007 | 257.3 | 256.3 |
| daslang exe | 1.24× | 1.09× | 1.225 | 1.211 | 0.011 | 18.6 | 17.3 |
| daslang exe + unsafe_deref | 1.15× | 1.01× | 1.135 | 1.123 | 0.013 | 18.1 | 17.0 |
| daslang aot | 1.29× | 1.13× | 1.280 | 1.231 | 0.191 | 320.5 | n/a (recompiles per run) |
| daslang aot + unsafe_deref | 1.30× | 1.14× | 1.290 | 1.234 | 0.229 | 326.6 | n/a (recompiles per run) |

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
| C clang-18 -O3 -march=native | 1.00× | 1.07× | 0.738 | 0.687 | 0.024 | 1.6 | 0.9 |
| C clang-18 -O2 | 0.93× | 1.00× | 0.689 | 0.661 | 0.016 | 1.7 | 0.9 |
| C clang-18 -O0 | 3.81× | 4.08× | 2.809 | 2.787 | 0.026 | 3.9 | 1.1 |
| daslang interp | 46.80× | 50.13× | 34.541 | 34.476 | 0.191 | 259.8 | 225.0 |
| daslang jit | 1.01× | 1.08× | 0.743 | 0.709 | 0.028 | 427.8 | 427.0 |
| daslang jit + unsafe_deref | 1.04× | 1.12× | 0.769 | 0.739 | 0.029 | 441.2 | 440.4 |
| daslang exe | 0.98× | 1.05× | 0.723 | 0.708 | 0.036 | 19.4 | 18.6 |
| daslang exe + unsafe_deref | 0.95× | 1.02× | 0.700 | 0.683 | 0.034 | 18.5 | 17.7 |
| daslang aot | 1.14× | 1.22× | 0.840 | 0.828 | 0.180 | 920.8 | n/a (recompiles per run) |
| daslang aot + unsafe_deref | 1.13× | 1.21× | 0.836 | 0.812 | 0.178 | 939.4 | n/a (recompiles per run) |

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
| C clang-18 -O3 -march=native | 1.00× | 0.90× | 33.984 | 33.714 | 0.141 | 35.8 | 1.6 |
| C clang-18 -O2 | 1.11× | 1.00× | 37.639 | 37.261 | 0.150 | 39.3 | 1.6 |
| C clang-18 -O0 | 4.68× | 4.23× | 159.060 | 157.851 | 0.468 | 161.2 | 1.7 |
| daslang interp | 34.27× | 30.94× | 1164.685 | 1152.591 | 0.050 | 1259.6 | 94.8 |
| daslang jit | 1.08× | 0.98× | 36.767 | 36.452 | 0.017 | 287.5 | 250.5 |
| daslang jit + unsafe_deref | 1.09× | 0.98× | 36.964 | 36.572 | 0.019 | 296.0 | 258.9 |
| daslang exe | 1.13× | 1.02× | 38.540 | 38.284 | 0.028 | 59.3 | 21.0 |
| daslang exe + unsafe_deref | 1.14× | 1.03× | 38.668 | 38.281 | 0.025 | 59.2 | 20.6 |
| daslang aot | 1.19× | 1.08× | 40.521 | 40.013 | 0.178 | 299.8 | n/a (recompiles per run) |
| daslang aot + unsafe_deref | 1.19× | 1.08× | 40.583 | 40.430 | 0.184 | 287.9 | n/a (recompiles per run) |

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
| C clang-18 -O3 -march=native | 1.00× | 1.02× | 75.881 | 75.069 | 0.025 | 77.8 | 1.8 |
| C clang-18 -O2 | 0.98× | 1.00× | 74.243 | 73.430 | 0.019 | 76.0 | 1.8 |
| C clang-18 -O0 | 5.31× | 5.42× | 402.628 | 400.009 | 0.036 | 404.6 | 1.9 |
| daslang interp | 50.50× | 51.62× | 3832.246 | 3812.501 | 0.299 | 4048.8 | 221.1 |
| daslang jit | 1.02× | 1.04× | 77.437 | 76.846 | 0.020 | 516.0 | 439.1 |
| daslang jit + unsafe_deref | 0.98× | 1.00× | 74.454 | 74.037 | 0.031 | 514.2 | 439.3 |
| daslang exe | 1.04× | 1.07× | 79.272 | 78.618 | 0.042 | 101.1 | 21.8 |
| daslang exe + unsafe_deref | 0.98× | 1.00× | 74.342 | 73.922 | 0.035 | 94.9 | 20.6 |
| daslang aot | 1.14× | 1.16× | 86.264 | 85.234 | 0.168 | 1025.2 | n/a (recompiles per run) |
| daslang aot + unsafe_deref | 1.07× | 1.10× | 81.524 | 81.393 | 0.183 | 1017.9 | n/a (recompiles per run) |

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
| C clang-18 -O3 -march=native | 1.00× | 0.90× | 33.248 | 33.039 | 0.139 | 35.2 | 1.7 |
| C clang-18 -O2 | 1.11× | 1.00× | 36.877 | 36.616 | 0.152 | 38.7 | 1.6 |
| C clang-18 -O0 | 4.69× | 4.23× | 155.844 | 155.520 | 0.456 | 157.9 | 1.6 |
| daslang interp | 34.40× | 31.02× | 1143.808 | 1142.620 | 0.048 | 1219.6 | 75.7 |
| daslang jit | 1.09× | 0.98× | 36.143 | 36.016 | 0.045 | 267.5 | 231.4 |
| daslang jit + unsafe_deref | 1.09× | 0.98× | 36.265 | 36.068 | 0.048 | 269.7 | 233.0 |
| daslang exe | 1.17× | 1.05× | 38.766 | 38.333 | 0.016 | 59.3 | 20.6 |
| daslang exe + unsafe_deref | 1.13× | 1.02× | 37.652 | 37.374 | 0.016 | 58.2 | 20.5 |
| daslang aot | 1.21× | 1.09× | 40.101 | 39.983 | 0.018 | 291.6 | n/a (recompiles per run) |
| daslang aot + unsafe_deref | 1.20× | 1.08× | 39.909 | 39.808 | 0.023 | 292.7 | n/a (recompiles per run) |

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
| C clang-18 -O3 -march=native | 1.00× | 1.02× | 74.712 | 74.432 | 0.023 | 76.4 | 1.8 |
| C clang-18 -O2 | 0.98× | 1.00× | 72.934 | 72.723 | 0.021 | 74.8 | 1.8 |
| C clang-18 -O0 | 5.25× | 5.38× | 392.458 | 391.686 | 0.035 | 394.4 | 1.9 |
| daslang interp | 50.68× | 51.92× | 3786.625 | 3769.297 | 0.250 | 3992.2 | 205.3 |
| daslang jit | 1.03× | 1.06× | 77.140 | 76.319 | 0.015 | 504.2 | 425.7 |
| daslang jit + unsafe_deref | 0.99× | 1.01× | 73.652 | 73.343 | 0.027 | 496.7 | 423.0 |
| daslang exe | 1.07× | 1.09× | 79.680 | 78.861 | 0.021 | 101.1 | 21.4 |
| daslang exe + unsafe_deref | 1.05× | 1.07× | 78.270 | 74.801 | 0.020 | 101.3 | 23.0 |
| daslang aot | 1.17× | 1.20× | 87.708 | 85.711 | 0.015 | 1065.4 | n/a (recompiles per run) |
| daslang aot + unsafe_deref | 1.11× | 1.13× | 82.738 | 82.226 | 0.019 | 1029.7 | n/a (recompiles per run) |

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
| C clang-18 -O3 -march=native | 1.00× | 0.99× | 1.768 | 1.702 | 0.068 | 2.9 | 1.0 |
| C clang-18 -O2 | 1.01× | 1.00× | 1.789 | 1.710 | 0.070 | 2.9 | 1.0 |
| C clang-18 -O0 | 2.34× | 2.31× | 4.139 | 4.041 | 0.102 | 5.5 | 1.3 |
| daslang interp | 62.97× | 62.23× | 111.329 | 110.583 | 0.251 | 513.9 | 401.6 |
| daslang jit | 2.62× | 2.59× | 4.631 | 4.472 | 0.060 | 558.7 | 554.0 |
| daslang jit + unsafe_deref | 2.56× | 2.53× | 4.522 | 4.501 | 0.060 | 550.0 | 545.5 |
| daslang exe | 2.41× | 2.38× | 4.263 | 4.258 | 0.043 | 25.4 | 21.1 |
| daslang exe + unsafe_deref | 2.48× | 2.45× | 4.378 | 4.326 | 0.035 | 26.5 | 21.9 |
| daslang aot | 1.58× | 1.57× | 2.801 | 2.693 | 0.056 | 1288.0 | n/a (recompiles per run) |
| daslang aot + unsafe_deref | 1.40× | 1.39× | 2.484 | 2.428 | 0.054 | 1294.0 | n/a (recompiles per run) |

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
| C clang-18 -O3 -march=native | 1.00× | 1.01× | 58.148 | 57.664 | 0.190 | 59.9 | 1.6 |
| C clang-18 -O2 | 0.99× | 1.00× | 57.423 | 57.129 | 0.185 | 59.2 | 1.5 |
| C clang-18 -O0 | 3.43× | 3.48× | 199.658 | 197.829 | 0.380 | 201.6 | 1.6 |
| daslang interp | 69.55× | 70.43× | 4044.061 | 3981.702 | 1.990 | 4230.6 | 183.6 |
| daslang jit | 1.03× | 1.04× | 59.932 | 59.813 | 0.143 | 431.5 | 370.8 |
| daslang jit + unsafe_deref | 1.05× | 1.07× | 61.278 | 60.949 | 0.132 | 430.9 | 369.8 |
| daslang exe | 1.04× | 1.05× | 60.515 | 59.924 | 0.091 | 81.7 | 21.1 |
| daslang exe + unsafe_deref | 1.03× | 1.04× | 59.915 | 59.595 | 0.086 | 80.7 | 20.7 |
| daslang aot | 1.10× | 1.11× | 63.692 | 62.785 | 0.088 | 668.4 | n/a (recompiles per run) |
| daslang aot + unsafe_deref | 1.11× | 1.13× | 64.647 | 64.235 | 0.087 | 684.2 | n/a (recompiles per run) |

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
| C clang-18 -O3 -march=native | 1.00× | 0.99× | 110.341 | 110.205 | 6.706 | 119.7 | 2.6 |
| C clang-18 -O2 | 1.01× | 1.00× | 111.535 | 111.379 | 6.839 | 121.1 | 2.6 |
| C clang-18 -O0 | 2.74× | 2.71× | 302.696 | 301.928 | 12.048 | 317.3 | 2.6 |
| daslang interp | 35.06× | 34.68× | 3868.264 | 3851.155 | 98.414 | 4476.5 | 507.0 |
| daslang jit | 1.16× | 1.15× | 128.205 | 127.927 | 6.310 | 932.7 | 798.3 |
| daslang jit + unsafe_deref | 1.03× | 1.02× | 114.136 | 113.559 | 5.680 | 850.3 | 727.3 |
| daslang exe | 1.10× | 1.09× | 121.740 | 120.956 | 6.011 | 152.6 | 24.6 |
| daslang exe + unsafe_deref | 1.04× | 1.03× | 114.791 | 113.992 | 5.831 | 145.4 | 25.3 |
| daslang aot | 3.56× | 3.53× | 393.282 | 391.308 | 6.588 | 2679.3 | n/a (recompiles per run) |
| daslang aot + unsafe_deref | 3.62× | 3.58× | 399.031 | 394.478 | 6.923 | 2763.8 | n/a (recompiles per run) |

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
