# c2das

C to [daslang](https://dascript.org/) translator: whole C code bases become daslang source that
runs in the interpreter, the LLVM JIT, as a standalone executable and as AOT C++. A fork of
[C2Rust](https://github.com/immunant/c2rust) with a daslang back end.

## Benchmark Snapshot

<!-- benchmark:begin -->
Medians of 5 runs, `±` is half the sample range; the best value in each row is bold. Every run is checked frame by frame against the C build. Methodology: [`docs/benchmark-methodology.md`](docs/benchmark-methodology.md); every variant and the build commands: [`docs/corpus-benchmark.md`](docs/corpus-benchmark.md).

### Linux — AMD Ryzen 7 7435HS

- Captured by `python3 scripts/corpus_matrix.py bench --runs 5` on 2026-10-08 at commit `712474e26`
- OS: Ubuntu 22.04.5 LTS, kernel 6.6.87.2-microsoft-standard-WSL2
- Toolchain: Ubuntu clang version 18.1.8 (++20240731024944+3b5b5c1ec4a3-1~exp1~20240731145000.144); daslang 0.6.4

#### Translated C vs native C

| Program | C -O3 native | C -O2 | DAS interpreter | DAS JIT | DAS exe | DAS AOT\* |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| pl_mpeg (MPEG-1 video), 320×240, 59 frames | **33.25ms** ±1% | 36.88ms ±1% | 1143.81ms ±1% | 36.14ms ±1% | 38.77ms ±1% | 40.10ms ±1% |
| h264bsd + minimp4 (H.264 video), 640×360, 73 frames | 74.71ms ±1% | **72.93ms** ±1% | 3786.62ms ±1% | 77.14ms ±2% | 79.68ms ±1% | 87.71ms ±12% |
| wasm3 (WebAssembly interpreter), fib32, 7 checked values (micro) | **1.77ms** ±3% | 1.79ms ±3% | 111.33ms ±1% | 4.63ms ±3% | 4.26ms ±1% | 2.80ms ±4% |
| binjgb (Game Boy Color emulator), cgb-acid2, 300 frames | 58.15ms ±1% | **57.42ms** ±1% | 4044.06ms ±2% | 59.93ms ±1% | 60.52ms ±1% | 63.69ms ±1% |
| doomgeneric (Doom engine), 320×200, 1000 frames | **110.34ms** ±0% | 111.53ms ±1% | 3868.26ms ±1% | 128.21ms ±0% | 121.74ms ±1% | 393.28ms ±1% |

#### Ratio to C -O3 native

| Program | C -O2 | DAS interpreter | DAS JIT | DAS exe | DAS AOT\* |
| --- | ---: | ---: | ---: | ---: | ---: |
| pl_mpeg (MPEG-1 video), 320×240, 59 frames | 1.11× ±1% | 34.40× ±1% | **1.09×** ±1% | 1.17× ±1% | 1.21× ±1% |
| h264bsd + minimp4 (H.264 video), 640×360, 73 frames | **0.98×** ±1% | 50.68× ±1% | 1.03× ±2% | 1.07× ±1% | 1.17× ±12% |
| wasm3 (WebAssembly interpreter), fib32, 7 checked values (micro) | **1.01×** ±3% | 62.97× ±1% | 2.62× ±3% | 2.41× ±1% | 1.58× ±4% |
| binjgb (Game Boy Color emulator), cgb-acid2, 300 frames | **0.99×** ±1% | 69.55× ±2% | 1.03× ±1% | 1.04× ±1% | 1.10× ±1% |
| doomgeneric (Doom engine), 320×200, 1000 frames | **1.01×** ±1% | 35.06× ±1% | 1.16× ±0% | 1.10× ±1% | 3.56× ±1% |

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
