# c2das

C to [daslang](https://dascript.org/) translator: whole C code bases become daslang source that
runs in the interpreter, the LLVM JIT, as a standalone executable and as AOT C++. A fork of
[C2Rust](https://github.com/immunant/c2rust) with a daslang back end.

## Benchmark Snapshot

<!-- benchmark:begin -->
Medians of 5 runs, `±` is half the sample range; the best value in each row is bold. Every run is checked frame by frame against the C build. Methodology: [`docs/benchmark-methodology.md`](docs/benchmark-methodology.md); every variant and the build commands: [`docs/corpus-benchmark.md`](docs/corpus-benchmark.md).

### Linux — AMD Ryzen 7 7435HS

- Captured by `python3 scripts/corpus_matrix.py bench --runs 5` on 2026-10-05 at commit `f761d899e`
- OS: Ubuntu 22.04.5 LTS, kernel 6.6.87.2-microsoft-standard-WSL2
- Toolchain: Ubuntu clang version 18.1.8 (++20240731024944+3b5b5c1ec4a3-1~exp1~20240731145000.144); daslang 0.6.4

#### Translated C vs native C

| Program | C -O3 native | C -O2 | DAS interpreter | DAS JIT | DAS exe | DAS AOT\* |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| pl_mpeg (MPEG-1 video), 320×240, 59 frames | **34.48ms** ±1% | 37.95ms ±1% | 1270.72ms ±1% | 37.58ms ±11% | 38.26ms ±1% | 40.28ms ±1% |
| h264bsd + minimp4 (H.264 video), 640×360, 73 frames | **74.24ms** ±0% | 77.97ms ±13% | 4098.23ms ±3% | 77.82ms ±1% | 77.58ms ±1% | 85.55ms ±1% |
| wasm3 (WebAssembly interpreter), fib32, 7 checked values (micro) | 1.80ms ±2% | **1.78ms** ±4% | 110.48ms ±18% | 4.56ms ±0% | 4.47ms ±3% | 2.69ms ±3% |
| binjgb (Game Boy Color emulator), cgb-acid2, 300 frames | **58.05ms** ±17% | 58.69ms ±2% | 4746.39ms ±5% | 60.36ms ±1% | 67.16ms ±0% | 68.11ms ±1% |
| doomgeneric (Doom engine), 320×200, 1000 frames | **118.48ms** ±0% | 121.24ms ±1% | 6497.58ms ±3% | 135.43ms ±10% | 124.37ms ±0% | 559.14ms ±0% |

#### Ratio to C -O3 native

| Program | C -O2 | DAS interpreter | DAS JIT | DAS exe | DAS AOT\* |
| --- | ---: | ---: | ---: | ---: | ---: |
| pl_mpeg (MPEG-1 video), 320×240, 59 frames | 1.10× ±1% | 36.85× ±1% | **1.09×** ±11% | 1.11× ±1% | 1.17× ±1% |
| h264bsd + minimp4 (H.264 video), 640×360, 73 frames | 1.05× ±13% | 55.20× ±3% | 1.05× ±1% | **1.05×** ±1% | 1.15× ±1% |
| wasm3 (WebAssembly interpreter), fib32, 7 checked values (micro) | **0.99×** ±4% | 61.48× ±18% | 2.54× ±0% | 2.49× ±3% | 1.50× ±3% |
| binjgb (Game Boy Color emulator), cgb-acid2, 300 frames | **1.01×** ±2% | 81.76× ±5% | 1.04× ±1% | 1.16× ±0% | 1.17× ±1% |
| doomgeneric (Doom engine), 320×200, 1000 frames | **1.02×** ±1% | 54.84× ±3% | 1.14× ±10% | 1.05× ±0% | 4.72× ±0% |

### Windows — AMD Ryzen 7 7435HS

- Captured by `tests/manual/doomgeneric/sdl/bench.sh` on 2026-10-05 at commit `f761d899e` (`REPS=5` `FRAMES=1000`)
- OS: Microsoft Windows [Version 10.0.19045.2673]
- Toolchain: MSVC 19.44.35214; clang-cl 22.1.2; daslang 0.6.4 (69a589623); SDL 3.4.16

#### Frames per second (higher is better)

| Mode | C msvc_O2 | C msvc_avx2 | C clang_O2 | C clang_native | DAS interpreter | DAS JIT | DAS AOT\* |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| window | 2690.7 ±3% | 2681.8 ±2% | 2700.8 ±3% | 2717.3 ±1% | 98.2 ±1% | **3007.8** ±13% | 910.5 ±1% |
| dummy | 389.8 ±1% | 388.5 ±1% | 383.9 ±0% | 383.0 ±1% | 82.2 ±1% | **390.5** ±3% | 299.6 ±0% |
| nopresent | 7018.6 ±0% | 6963.0 ±0% | 7237.2 ±2% | **7614.3** ±1% | 102.0 ±0% | 6494.4 ±0% | 1083.5 ±0% |

#### Slowdown against `C clang_native` (lower is better)

| Mode | C msvc_O2 | C msvc_avx2 | C clang_O2 | C clang_native | DAS interpreter | DAS JIT | DAS AOT\* |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| window | 1.01× ±3% | 1.01× ±2% | 1.01× ±3% | 1.00× ±1% | 27.67× ±1% | **0.90×** ±13% | 2.98× ±1% |
| dummy | 0.98× ±1% | 0.99× ±1% | 1.00× ±0% | 1.00× ±1% | 4.66× ±1% | **0.98×** ±3% | 1.28× ±0% |
| nopresent | 1.08× ±0% | 1.09× ±0% | 1.05× ±2% | **1.00×** ±1% | 74.65× ±0% | 1.17× ±0% | 7.03× ±0% |

Doom on Windows in full: [`docs/windows-doom-benchmark.md`](docs/windows-doom-benchmark.md).

\* AOT is built without `solid_context` and without daslang's auto-inliner (see the methodology).
<!-- benchmark:end -->

## Corpora

| Program | Upstream | Licence | Workload |
|---|---|---|---|
| pl_mpeg | [phoboslab/pl_mpeg](https://github.com/phoboslab/pl_mpeg) | MIT | 320×240 MPEG-1, 59 frames |
| h264bsd + minimp4 | [oneam/h264bsd](https://github.com/oneam/h264bsd), [lieff/minimp4](https://github.com/lieff/minimp4) | Apache-2.0, CC0 | 640×360 H.264, 73 frames |
| wasm3 | [wasm3/wasm3](https://github.com/wasm3/wasm3) | MIT | `fib32.wasm`, 7 values |
| binjgb | [binji/binjgb](https://github.com/binji/binjgb) | MIT | cgb-acid2 ROM, 300 frames |
| doomgeneric | [ozkl/doomgeneric](https://github.com/ozkl/doomgeneric) | GPL-2.0 | `-timedemo demo1`, 1000 frames |

## Verify

```sh
python3 scripts/run_c2das_cases.py --all-ready      # every case: C output == translated daslang output
python3 scripts/corpus_matrix.py converge --check   # every corpus, every mode, frame by frame == C
python3 scripts/corpus_matrix.py bench              # docs/corpus-benchmark.md and the snapshot above
python3 scripts/corpus_matrix.py readme             # the snapshot above from the generated docs
```

## Documentation

- [Translator overview, build and usage](docs/translator-overview.md)
- [Benchmark methodology](docs/benchmark-methodology.md), [full benchmark](docs/corpus-benchmark.md), [build recipe](docs/corpus-build-recipe.md)
- [Convergence](docs/corpus-convergence.md), [corpus status](docs/followups/corpus_status.md), [known limitations](docs/known-limitations.md)
- [Doom on Windows (SDL3 harness)](tests/manual/doomgeneric/sdl/README.md)
- [Architecture contracts](ARCHITECTURE_COMMON.md), [laws](LAWS.md), [contributing](CODEX.md)

## License

BSD-3-Clause, see [LICENSE](LICENSE); C2Rust-derived components keep their notices. Each corpus
keeps its own licence in `tests/manual/<corpus>/`.
