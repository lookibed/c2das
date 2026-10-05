# c2das

**c2das** translates C programs into [daslang](https://dascript.org/) (formerly daScript)
source, whole code bases at a time, and runs them unchanged in every daslang mode —
interpreter, LLVM JIT, standalone executable and AOT C++. It is an architectural fork of
[C2Rust](https://github.com/immunant/c2rust): the Clang-based front end stays, the back end
builds and prints daslang AST instead of Rust. The goal is behavioural translation checked
against the C program itself: a construct c2das does not support fails with a located
diagnostic, never with a plausible-looking approximation.

## Benchmark Snapshot

Every number below is generated: `python3 scripts/corpus_matrix.py bench` measures each
corpus program as native C and as its c2das translation in every daslang mode, writes
[`docs/corpus-benchmark.md`](docs/corpus-benchmark.md) and rewrites the block between the
markers here. The rules — what is timed, medians and `±` spread, the C baselines, the JIT and
AOT flags, the safe default versus the `--unsafe-deref` option — are in
[`docs/benchmark-methodology.md`](docs/benchmark-methodology.md).

<!-- benchmark:begin -->
_The Linux snapshot is written here by `python3 scripts/corpus_matrix.py bench`; it has not
been run in this checkout yet. Until then see
[`docs/corpus-benchmark.md`](docs/corpus-benchmark.md)._
<!-- benchmark:end -->

### Windows — doomgeneric as an SDL3 window application

The same translated Doom engine runs as a real SDL3 window program on Windows, in the
interpreter, under `-jit` and as AOT, against the same program built natively with MSVC and
clang-cl, in three presentation modes (window, headless dummy driver, no present). The figure
there is frames per second (higher is better), hash-checked against the corpus oracle on
every run. The harness, its environment and the latest measured table are in
[`tests/manual/doomgeneric/sdl/README.md`](tests/manual/doomgeneric/sdl/README.md);
`bench.sh --markdown <path>` writes the table in the same layout as the Linux snapshot above.

## Architecture

```text
Clang AST -> CBOR -> C AST -> translator -> daScript AST -> printer -> .das
```

![c2das translation roadmap](docs/c2das-roadmap.png)

The translator keeps C facts separate from daslang representation: exported Clang facts are
the truth for size, alignment, offsets, padding, `packed`, unions and bitfields; raw
addresses, typed pointers, nulls and storage bytes cross one explicit ABI contract
(`translator/abi.rs`); pointer-backed C objects go through address-aware raw-memory lowering
(`translator/object_memory.rs`); allocation and memory primitives lower to a `c2da_rt_*`
runtime prelude, and under `--libc std` the C program's libc calls and `main` are lowered
too, so the translated module is the program. The printer renders the AST only — no
text-level repair. The long version, with the build and translate instructions, is
[`docs/translator-overview.md`](docs/translator-overview.md); the contracts are
[`ARCHITECTURE_COMMON.md`](ARCHITECTURE_COMMON.md), [`REVIEW_COMMON.md`](REVIEW_COMMON.md)
and [`LAWS.md`](LAWS.md).

## Corpora

The programs the snapshot measures. Each is vendored with its licence and revision
(`tests/manual/<corpus>/UPSTREAM.md`), translated whole under `--strict --libc std`, and
pinned to an oracle produced by the C build in `tests/canonical/cases.json`.

| Program | Upstream | Licence | Workload | Oracle |
|---|---|---|---|---|
| pl_mpeg (MPEG-1 video decoder) | [phoboslab/pl_mpeg](https://github.com/phoboslab/pl_mpeg) | MIT | a synthesized 320×240 MPEG-1 stream, 59 decoded frames | RGB hash of every frame |
| h264bsd + minimp4 (H.264 baseline decoder, MP4 demuxer) | [oneam/h264bsd](https://github.com/oneam/h264bsd), [lieff/minimp4](https://github.com/lieff/minimp4) | Apache-2.0, CC0 | h264bsd's own 640×360 test vector, 73 pictures | YUV hash of every picture |
| wasm3 (WebAssembly interpreter core, no WASI) | [wasm3/wasm3](https://github.com/wasm3/wasm3) | MIT | its `fib32.wasm` test module, `fib(n)` for seven `n` | the seven values (micro: under 5 ms in C) |
| binjgb (Game Boy Color emulator core) | [binji/binjgb](https://github.com/binji/binjgb) | MIT | the cgb-acid2 test ROM (MIT), 60 emulated frames | RGB555 hash of every frame |
| doomgeneric (Doom engine) | [ozkl/doomgeneric](https://github.com/ozkl/doomgeneric) | GPL-2.0 | `-timedemo demo1` of the shareware IWAD, 1000 frames timed, the first 70 pinned | RGB hash of every frame |

`docs/followups/corpus_status.md` is the ledger of each corpus's status and gates.

## How results are verified

There is no readiness percentage. A claim is made only when the canonical runner reproduces
it from fresh translator output on the real `daslang`:

```sh
python3 scripts/run_c2das_cases.py --all-ready        # every ready case: C reference == fresh daslang output
python3 scripts/run_c2das_cases.py --all-known-red    # survey of the cases expected to fail
python3 scripts/check_test_registry.py --check        # fixture registry is derived from cases.json
python3 scripts/corpus_matrix.py converge --check     # every corpus program, every mode, per frame, equals C
cargo test -p c2dascript-transpile                    # Rust contract and snapshot tests
bash scripts/c2das_preflight.sh [--fast|--full|--extended]   # the local gate; GitHub Actions mirrors part of it
```

- **Cases** (`tests/canonical/cases.json`): each one copies a C graph to a temporary
  workspace, compiles the C reference with `clang-18`, requires fresh `--strict` output, runs
  it with `daslang` and compares stdout and exit code with the oracle (or with what the C
  program printed). Negative cases must fail with the declared diagnostic and write nothing.
- **Fixtures** (`tests/registry/fixtures.json`): every remaining fixture's exact status, derived
  from the cases, never "covered" by assumption.
- **Convergence** (`docs/corpus-convergence.md`): every corpus program in the interpreter,
  `-jit`, `-exe` and AOT prints the same per-frame hashes as the C build; `--check` fails the
  preflight when the committed document no longer matches a fresh run.
- **Benchmark** (`docs/corpus-benchmark.md`): the same hash check on every timed run; a mode
  that ever differs is a failure, never a number.

`daslang` is found through `DASLANG`, `DASROOT`, `PATH` or `~/daScript`; prerequisites and
the translate commands are in `docs/translator-overview.md`.

## Documentation

- [`docs/translator-overview.md`](docs/translator-overview.md) — what the translator does,
  known gaps, build and translate, the validation pipeline, CI, principles, C2Rust lineage.
- [`docs/benchmark-methodology.md`](docs/benchmark-methodology.md) — the measurement rules.
- [`docs/corpus-benchmark.md`](docs/corpus-benchmark.md) — the generated Linux benchmark,
  snapshot and full appendix; [`docs/corpus-build-recipe.md`](docs/corpus-build-recipe.md)
  — every build and run command behind it.
- [`docs/corpus-convergence.md`](docs/corpus-convergence.md) — per-frame equality of every
  run mode with C; [`docs/followups/corpus_status.md`](docs/followups/corpus_status.md) —
  the corpus ledger.
- [`tests/manual/doomgeneric/sdl/README.md`](tests/manual/doomgeneric/sdl/README.md) — the
  Windows SDL3 Doom harness and its table.
- [`docs/known-limitations.md`](docs/known-limitations.md), [`docs/followups/`](docs/followups)
  — what is not supported yet and what each lever was measured to buy
  (`hot_path_levers.md`, `translator_gaps_wasm3.md`).
- [`docs/testing-registry.md`](docs/testing-registry.md) — the test system and its registry;
  [`docs/c2rust_parity_map.md`](docs/c2rust_parity_map.md) — the c2rust → c2das
  architecture map.
- [`CODEX.md`](CODEX.md), [`AGENTS.md`](AGENTS.md) — the contributor and agent contract.

## License and acknowledgements

c2das is distributed under the [BSD-3-Clause license](LICENSE). It contains and adapts
components originating in C2Rust; their notices and third-party licenses remain in the
repository. C2Rust was inspired by Jamey Sharp's
[Corrode](https://github.com/jameysharp/corrode) translator and uses Emscripten's Relooper
approach for arbitrary C control flow. The corpora keep their own licences beside their
sources (`tests/manual/<corpus>/upstream/`).

daslang is an independent language and runtime. See [dascript.org](https://dascript.org/) for
its documentation and licensing.
