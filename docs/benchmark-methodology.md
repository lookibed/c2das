# Benchmark methodology

The measurement rules behind every number this repository publishes: the Linux corpus
benchmark (`docs/corpus-benchmark.md`, the snapshot of which is also written into
`README.md`) and the Windows SDL3 Doom frame-rate table
(`tests/manual/doomgeneric/sdl/README.md`). Both documents are generated; this page says
what their cells mean and what they deliberately leave out. The build commands behind the
Linux rows are written out in `docs/corpus-build-recipe.md`.

## What is compared

- **The program is the same C.** Each program is a C code base translated whole by c2das
  (`c2dascript-transpile --strict`, under `--libc std` so the C `main`, `printf`, `fopen`,
  `fread` and `clock_gettime` are lowered too) and run unchanged in every daslang mode. The C
  reference is the same source compiled by clang. No hand-written daslang stands between the
  C and the measured program for the headline rows; the cases that run a hand-written daslang
  entry over the translated graph are in the appendix only.
- **Correctness first.** Every run prints one hash per decoded frame (per emulated frame, per
  checked value), and every daslang run's hashes must equal the C build's. A variant that
  ever differs is reported as failed, never timed. The convergence document
  (`docs/corpus-convergence.md`, `python3 scripts/corpus_matrix.py converge --check`) is the
  gate on the same hashes.
- **Work, not wall.** The time compared is what the program itself measures around its work
  loop (`decode_us`: C `clock_gettime(CLOCK_MONOTONIC)`, daslang `ref_time_ticks`), so
  process start, script compilation, JIT codegen, setup and teardown are not in it. They are
  reported separately as **startup** = wall − work − setup.

## Samples and spread

- One warm-up run first (page cache, the JIT's `.jitted_scripts/` DLL cache, module cache),
  then `--runs` timed runs (default 5), each its own process.
- A cell is the **median** of those runs; `±N%` is **half the sample range as a share of the
  median** — the convention of [dasProfile](https://github.com/borisbat/dasProfile), so the
  two projects' tables read alike. Lower is better in every time table; the fastest cell of a
  row is in bold; `-` is no value (failed hash check, or did not build).
- A program whose C `-O2` work loop runs under 5 ms is marked **(micro)**: timer resolution
  and cache state dominate its ratios, and it stays in the tables for completeness, not as a
  headline.

## C baselines

- **`clang-18 -O3 -march=native`** is the headline baseline: the build a C programmer would
  ship for this machine. daslang's LLVM backend compiles `-jit` and `-exe` for the host CPU,
  so this is the fair ceiling.
- **`clang-18 -O2`** (generic x86-64, SSE2) is kept as the portable reference a `clang -O2`
  user would see. `-O0` is in the appendix as the unoptimized floor.
- On Windows the equivalents are `clang-cl /O2 /clang:-march=native` (`clang_native`, the
  headline) and `cl /O2`, `cl /O2 /arch:AVX2`, `clang-cl /O2`.

## daslang modes and their flags

| Mode | Command | Translation it runs |
|---|---|---|
| interpreter | `daslang entry.das` | the default translation |
| JIT | `daslang -jit entry.das`, daslang's default split codegen with auto threads (`--jit-split-modules=-1`). The switch is not passed, because the JIT reads its switches from the script's own arguments, where it would change the C program's `argc`; instead every measured run's JIT log must report the split build. | the default translation |
| exe | `daslang -exe entry.das -output <bin>`, an LLVM-compiled standalone executable linked against the daslang runtime shared library | the default translation |
| AOT | `daslang -aot` per module, the C++ compiled with the toolchain's own AOT flags and linked with `scripts/corpus/aot_host.cpp` (`policies.aot`, `fail_on_no_aot`); on Windows `daslang -use-aot` with the C++ linked into the dasSDL3 module | **a second translation** with `--no-solid-context --das-option disable_auto_inline` (and `--public-module` for a graph a separate entry `require`s) |

The AOT caveat, marked `*` in every table: daslang's AOT refuses the h264bsd program with
`options solid_context` on, and daslang's auto-inliner puts initialised locals between a
`goto` and its label, which the generated C++ rejects; so the AOT rows lack both. The AOT host
also recompiles the script on every launch, so its start-up is a compiler's and is not shown.

The default translation carries `options solid_context = true` and leaves daslang's null
check in front of every pointer dereference. `docs/followups/hot_path_levers.md` records the
levers and what each was measured to buy.

## Safe default versus `--unsafe-deref`

The headline tables are the translator's default output. The **option** table is a second
translation of each program with `--unsafe-deref`, which puts `[unsafe_deref]` on every
function and removes the null check before each dereference: C's unchecked access, where a
null dereference crashes instead of raising a located daslang exception. It is an option, not
the default — the same unsafety is available by writing the code on raw pointers, so it is a
choice of which unsafety to accept — and the annotation has a known miscompile
([lookibed/daScript#7](https://github.com/lookibed/daScript/issues/7)), which the per-frame
hash check guards those rows against. The option rows are measured in the compiled modes
only (JIT, exe, AOT), where a translator lever shows as generated code.

## Machines

Each snapshot states its own machine in its "Platform information" bullets: capture date and
commit, CPU, OS and kernel, compiler and daslang versions. The Linux generator reads them
from `/proc/cpuinfo`, `/etc/os-release`, `clang-18 --version` and `daslang --version`; the
Windows harness from `ver`, `/proc/cpuinfo` of the WSL side (the same machine), `cl`,
`clang-cl --version`, `daslang --version` plus the daScript checkout's commit, and SDL's
`SDL_version.h`. A fact the harness cannot find is printed as `unavailable`; the numbers never
depend on it. Both machines so far are the same laptop (AMD Ryzen 7 7435HS) under WSL2 Ubuntu
22.04 and under Windows 10. Numbers from different machines are not compared with each other;
ratios within one snapshot are.

## Windows SDL3 Doom

`tests/manual/doomgeneric/sdl/bench.sh` runs the translated doomgeneric engine as an SDL3
window program on Windows in three presentation modes — **window** (SDL's default driver and
renderer), **dummy** (`SDL_VIDEODRIVER=dummy`, headless software renderer scaling to 960×600)
and **nopresent** (`--no-present`, engine plus palette conversion alone) — against the same
program built natively with MSVC and clang-cl. The figure is **frames per second** of the
program's own loop (`fps` = frames / loop seconds from SDL's performance counter), so there
**higher is better**; the slowdown table divides `clang_native`'s FPS by the variant's so it
reads like the Linux ratios (lower is better). The engine's start-up (`setup_us`, including
the first 41 frames of the screen wipe) is outside the loop. The first 70 frame hashes of every
run must equal the corpus oracle and all frames must equal the C build's in the same mode.
`bench.sh --markdown <path>` writes the snapshot in the same layout as the Linux one
(`bench_markdown.py`).

## Regenerating

```sh
python3 scripts/corpus_matrix.py bench                 # docs/corpus-benchmark.md + the README block
python3 scripts/corpus_matrix.py converge              # docs/corpus-convergence.md
python3 scripts/corpus_matrix.py converge --check      # the preflight gate on the committed document
tests/manual/doomgeneric/sdl/bench.sh --markdown <path> <work-dir>   # Windows, from WSL
```

A benchmark document is never edited by hand: a number that is wrong is regenerated, and a
rule that is wrong is changed in the generator and then regenerated.
