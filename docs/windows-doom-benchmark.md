### Windows — AMD Ryzen 7 7435HS

Platform information:

- Captured by `tests/manual/doomgeneric/sdl/bench.sh` on 2026-10-05 at commit `f761d899e` (`REPS=5` `FRAMES=1000`)
- OS: Microsoft Windows [Version 10.0.19045.2673]
- Toolchain: MSVC 19.44.35214; clang-cl 22.1.2; daslang 0.6.4 (69a589623); SDL 3.4.16
- Program: the doomgeneric corpus (`-timedemo demo1`, 320×200) as an SDL3 window application, the engine translated whole by c2das (`c2dascript-transpile --strict --libc std`) and the same C built natively

A cell is the median of the runs, each its own process, of the frame rate the program itself measures over its loop (`fps` = frames / loop seconds from SDL's performance counter; the engine's start-up and the first 41 frames of the screen wipe are outside it). `±` is half the sample range as a share of the median. **Higher is better** in the frames-per-second table; lower is better in the slowdown and start-up tables. Rows are the presentation modes and columns the variants, so the best result in each row (in bold) is the fastest variant in that mode. `-` means no value: the run failed its hash check (the first 70 frame hashes against the corpus oracle, all frames against the C build's) or printed no `fps=`. **window** uses SDL's default video driver and renderer; **dummy** is `SDL_VIDEODRIVER=dummy`, headless, SDL's software renderer scaling to 960×600; **nopresent** is `--no-present`, the engine plus palette conversion alone.

#### Frames per second (higher is better)

| Mode | C msvc_O2 | C msvc_avx2 | C clang_O2 | C clang_native | DAS interpreter | DAS JIT | DAS AOT\* |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| window | 2690.7 ±3% | 2681.8 ±2% | 2700.8 ±3% | 2717.3 ±1% | 98.2 ±1% | **3007.8** ±13% | 910.5 ±1% |
| dummy | 389.8 ±1% | 388.5 ±1% | 383.9 ±0% | 383.0 ±1% | 82.2 ±1% | **390.5** ±3% | 299.6 ±0% |
| nopresent | 7018.6 ±0% | 6963.0 ±0% | 7237.2 ±2% | **7614.3** ±1% | 102.0 ±0% | 6494.4 ±0% | 1083.5 ±0% |

#### Slowdown against `C clang_native` (lower is better)

`C clang_native` frames per second divided by the variant's, per mode; 1.00× is the speed of the C build compiled for this CPU, the fair ceiling for `-jit`, which compiles for the host CPU too.

| Mode | C msvc_O2 | C msvc_avx2 | C clang_O2 | C clang_native | DAS interpreter | DAS JIT | DAS AOT\* |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| window | 1.01× ±3% | 1.01× ±2% | 1.01× ±3% | 1.00× ±1% | 27.67× ±1% | **0.90×** ±13% | 2.98× ±1% |
| dummy | 0.98× ±1% | 0.99× ±1% | 1.00× ±0% | 1.00× ±1% | 4.66× ±1% | **0.98×** ±3% | 1.28× ±0% |
| nopresent | 1.08× ±0% | 1.09× ±0% | 1.05× ±2% | **1.00×** ±1% | 74.65× ±0% | 1.17× ±0% | 7.03× ±0% |

#### Startup (lower is better)

`setup_us` as the program prints it: the engine's whole start-up including the first 41 frames, in milliseconds. It does not include process start, script compilation or JIT codegen, which the harness does not time.

| Mode | C msvc_O2 | C msvc_avx2 | C clang_O2 | C clang_native | DAS interpreter | DAS JIT | DAS AOT\* |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| window | **5.6ms** ±3% | 5.8ms ±4% | 5.7ms ±3% | 5.6ms ±3% | 200.0ms ±2% | 6.9ms ±7% | 15.5ms ±1% |
| dummy | 6.0ms ±5% | **5.7ms** ±4% | 5.9ms ±3% | 5.9ms ±4% | 204.7ms ±4% | 6.9ms ±7% | 15.6ms ±3% |
| nopresent | 6.0ms ±2% | 6.1ms ±2% | **5.9ms** ±3% | 6.0ms ±6% | 203.2ms ±2% | 6.3ms ±4% | 15.2ms ±2% |

Builds: C msvc_O2: `cl /O2 /MD`; C msvc_avx2: `cl /O2 /arch:AVX2 /MD`; C clang_O2: `clang-cl /O2 /MD` (generic x86-64); C clang_native: `clang-cl /O2 /clang:-march=native /MD`; DAS interpreter: `daslang doom_sdl.das`; DAS JIT: `daslang -jit doom_sdl.das`; DAS AOT\*: `daslang -use-aot doom_sdl.das`, generated C++ built by MSVC `/O2 /arch:AVX2`.

\* AOT is built from a second translation without `solid_context` and without daslang's auto-inliner (`--public-module --no-solid-context --das-option disable_auto_inline`, `translate.sh`), as in the corpus benchmark; the interpreter and `-jit` run the default translation (`options solid_context = true`, null checks on every pointer dereference).
