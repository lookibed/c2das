# How the corpus benchmark builds its programs: C (`-O3 -march=native`, `-O2`, `-O0`) vs daslang interp / jit / exe / aot

This is the build recipe behind `docs/corpus-benchmark.md`, written out command by command.
`scripts/corpus_matrix.py bench` runs exactly these steps; the paths below are the ones it
uses for the pl_mpeg 320×240 case, and the h264bsd case differs only where noted.  Nothing
here is hand-run: every command is issued by the driver, and the numbers in the benchmark
document come from no other build.

## Toolchain

| Tool | Version / location |
|---|---|
| daslang | 0.6.4, `/root/daScript/bin/daslang` (`<das_root>` = `/root/daScript`, the parent of `bin/`) |
| daslang runtime libraries | `<das_root>/lib/liblibDaScriptDyn.so`, `<das_root>/lib/liblibDaScriptDyn_runtime.so` |
| C compiler | `clang-18`, Ubuntu clang 18.1.8 |
| C++ compiler (AOT objects, AOT host) | `clang++-18`, same release |
| translator | `cargo run -q -p c2dascript-transpile` from this checkout (`--strict`) |

## 0. Workspace

The driver copies the fixture directory to a temporary workspace and deletes every `.das`
in the copy that is not a registered entry, so only a fresh translation can satisfy
`require all`:

```text
<work>/input/            copy of tests/manual/plmpeg-stream
<work>/input/src/        all.c, all_reference.c, module.c, ..., plmpeg_file_bench_entry.{c,das}
<work>/input/fixtures/   testsrc2_320x240.m1v
<work>/generated/        the translator's output directory
```

Every program below receives the fixture as its last argument:
`<fixture>` = `<work>/input/fixtures/testsrc2_320x240.m1v` (`cases.json: program_args`).
The C entries read it with libc, the daslang entries with `daslib/fio`, and both hand the
bytes to `plmpeg_frames_begin_bytes(bytes, length)` in the translated graph.

## 1. Translation (shared by interp, jit and exe)

```sh
cargo run -q -p c2dascript-transpile -- --strict \
    --output-dir <work>/generated \
    --file <work>/input/src/all.c \
    -std=c11 -DPLM_NO_STDIO -I<work>/input/include -I<work>/input/upstream \
    -I<work>/input/fixtures -I<work>/input/src
cp <work>/generated/all.das <work>/input/src/all.das      # staged beside the entry
```

The clang flags are the case's `clang.flags` from `tests/canonical/cases.json`; for
h264bsd-mp4 they are `-std=c11 -w -Iinclude -Iupstream/h264bsd/src -Iupstream/minimp4 -Isrc`.

The corpus cases declare no `translator_flags`, so every row without a `+` suffix runs the
translator's defaults — one of the two measured levers of
`docs/followups/hot_path_levers.md`, not both:

```text
options gen2
options solid_context = true      # the translator's default header
...
[export]                          # daslang's null checks stay in place
def plm_video_decode_block(...) { ... }
```

`solid_context` bakes the offsets of the module's globals instead of looking each one up by
mangled name through the context on every read.  `--no-solid-context` turns the header line
off; nothing else in the module changes.  The output is otherwise an anonymous module.

### 1a. The `+ unsafe_deref` rows: a second translation with `--unsafe-deref`

`[unsafe_deref]` on every function is a benchmark **option**, not the default (decision of
2026-09-23): it drops daslang's generated null check in front of every `ExprAt`,
`ExprPtr2Ref` and field dereference, which turns daslang's checked pointer access into C's
unchecked one — the same thing the code would get rewritten on raw pointers, a choice of
which unsafety to accept.  It also has a known miscompile
([lookibed/daScript#7](https://github.com/lookibed/daScript/issues/7): a nested `void`
function whose only effect is a store through `reinterpret<uint8?>(uint64)` is dropped in
all modes), which the per-frame hash check guards the benchmark rows against.  A case
offers it through its corpus block:

```json
"optional_translator_flags": { "unsafe_deref": ["--unsafe-deref"] }
```

For each such label the driver translates the benchmark program again with the switches
added, into its own directory under the workspace, and measures jit, exe and aot on it as
rows named `daslang jit + unsafe_deref`, `daslang exe + unsafe_deref`, `daslang aot +
unsafe_deref`:

```sh
cargo run -q -p c2dascript-transpile -- --strict --unsafe-deref \
    --output-dir <work>/bench_unsafe_deref/generated \
    --file <work>/input/src/all.c  <same clang flags as step 1>
cp <work>/bench_unsafe_deref/generated/all.das <work>/bench_unsafe_deref/all.das
cp <work>/input/src/plmpeg_file_bench_entry.das <work>/bench_unsafe_deref/   # the entry, beside its modules
cd <work>/bench_unsafe_deref && daslang -jit plmpeg_file_bench_entry.das -- <fixture>
```

(a `--libc std` case translates its `bench_translation_entry` straight into
`<work>/bench_unsafe_deref/`, and that module is the program).  The rows run from that
directory, so their `.jitted_scripts/` cache is never the default rows'.  exe is step 5 on
that entry (`<work>/bench_unsafe_deref_exe`); aot is step 6 with `--unsafe-deref` added to
the AOT translation's switches (`<work>/bench_unsafe_deref_aot/`).  The interpreter is not
measured with the option.  The headline table stays on the default translation; a second
table under it gives each option row as a ratio to native C and its change against the same
mode without the option.

## 2. C reference builds

The C graph is `src/all_reference.c` (which includes `shim.c`, the fixture's bump
allocator and mem* replacements, then the decoder and `module.c`) plus the benchmark entry:

```sh
clang-18 -std=c11 -DPLM_NO_STDIO -I<work>/input/include -I<work>/input/upstream \
    -I<work>/input/fixtures -I<work>/input/src -O2 \
    <work>/input/src/all_reference.c <work>/input/src/plmpeg_file_bench_entry.c \
    -o <work>/c_bench_O2
clang-18 ... -O0 ... -o <work>/c_bench_O0                 # same command, -O0
clang-18 ... -O3 -march=native ... -o <work>/c_bench_native   # same command, -O3 -march=native

<work>/c_bench_O2 <fixture>
```

`-O3 -march=native` is the headline baseline: every cell of the benchmark's headline table
and the first ratio column (`× C native`) of each appendix table is a ratio to it.  A plain
`clang -O2` binary targets generic x86-64 (SSE2) while daslang's LLVM backend compiles for
the host CPU and its features under `-jit`, so `-O2` alone is not a fair ceiling for the
daslang rows; it stays as the portable reference (`× C -O2`).  `-O0` is there to show what
an unoptimised native build costs against the same source.  All three are measured the
same way, and the `-O0` and native rows must reproduce the `-O2` build's per-frame hashes
on every run or they are reported as a failure, not a number.

## 3. daslang interp

```sh
daslang <work>/input/src/plmpeg_file_bench_entry.das -- <fixture>
```

Plain interpreter: `daslang` compiles the entry and `all.das` at start-up and simulates
them.  Script arguments follow `--`.

## 4. daslang jit

```sh
cd <work>
daslang -jit <work>/input/src/plmpeg_file_bench_entry.das -- <fixture>
```

`-jit` compiles the whole program with the LLVM JIT at load time (`lib/LLVM.dll` in the
toolchain).  The generated code is cached under `<work>/.jitted_scripts/`; the warm-up run
populates that cache, the five measured runs hit it.  The JIT writes `[I] LLVM JIT: ...`
progress lines to stdout; the driver drops lines that start with `[I] ` before it reads
the program's output.

The JIT runs with `--jit-split-modules=-1`: split codegen, one object per das-module,
optimized and emitted on auto threads, linked into one cached DLL.  That is daslang's
default for the DLL path (`modules/dasLLVM/daslib/llvm_jit_cli.das`: "-1 = split + auto
threads (JobQue count; the default)"), and the driver does **not** pass it, because it
cannot be passed without changing the program: `daslang` rejects `--jit-*` switches in
front of the script, and the JIT reads them from the script's own arguments after `--`
(`llvm_jit_plan.make_jit_plan` → `clargs.parse_args` → `get_user_args()`), where the
translated `main` also finds them — `p81-std-printf-edge` prints `argc=2` without the
switch and `argc=3` with it.  Instead the driver requires every measured run's log to
report the split build (`[I] LLVM JIT: <n> functions in <t> sec (cache, O3, split)`; a
monolithic build prints `(cache, O3)`), and fails the row otherwise.  Monolithic emission
(`--jit-split-modules=0`, full cross-module inlining) measured the same on the two large
`-std` programs (2026-09-22, `taskset -c 8-15`, 14 runs per setting in ABAB blocks of 7,
hashes checked): pl_mpeg 320×240 37.66 ms split vs 37.91 ms monolithic, h264bsd 640×360
77.76 ms vs 78.11 ms, i.e. monolithic 0.4–0.7 % slower, inside noise — a `--libc std`
program is a single das-module, so its split build is one partition anyway.

## 5. daslang exe

```sh
daslang -exe <work>/input/src/plmpeg_file_bench_entry.das -output <work>/bench_exe
<work>/bench_exe.exe <fixture>
```

`-exe` runs the same LLVM pipeline once, ahead of time, and links a standalone executable
(`bench_exe.exe`, an ELF binary despite the suffix) against
`<das_root>/lib/liblibDaScriptDyn_runtime.so`.  It takes its arguments directly, no `--`.
This is the variant with the smallest start-up cost (about 20 ms).

## 6. daslang aot

daslang's AOT is a two-stage build: `daslang -aot` emits C++ for the program's functions,
and a host links that C++ next to the daslang runtime and compiles the same script again
with `policies.aot = 1` so `simulate()` binds every function to its pre-compiled body.

**The aot row is built from a different translation than interp, jit and exe.**  Those
three run the module of step 1 (`solid_context` on, daslang's auto-inliner free to run);
the aot row runs a second translation with `--no-solid-context --das-option
disable_auto_inline` (plus `--public-module` when a fixture entry `require`s the graph),
because without them the program does not build or does not run under AOT (6a); the `aot +
unsafe_deref` row adds `--unsafe-deref` to that translation (1a).  The aot row therefore lacks the
`solid_context` lever the other compiled rows have, and its ratio is not a like-for-like
comparison with them; the benchmark says so in the row's build text and under the headline
table.  Its start-up is not comparable either: the host recompiles the script on every
launch (6d), so the benchmark prints `n/a (recompiles per run)` in its startup column.

### 6a. Second translation, with the AOT module header

```sh
cargo run -q -p c2dascript-transpile -- --strict \
    --public-module --no-solid-context --das-option disable_auto_inline \
    --output-dir <work>/bench_aot/generated \
    --file <work>/input/src/all.c  <same clang flags as step 1>
cp <work>/bench_aot/generated/all.das <work>/bench_aot/all.das
```

The body is byte-identical to step 1; only the header differs:

```text
options gen2
options disable_auto_inline
module all public
```

The header's order is fixed everywhere: `gen2`, then `solid_context` when it is on, then
the `--das-option` lines in the order they were given.

`module all public` is required because `daslang -aot` emits bodies only for a named public
module's unexported functions (an anonymous module keeps nothing that is not exported or
reached).  `options disable_auto_inline` is required because daslang's optimizer otherwise
splices small same-module callees into their callers and declares the callee's locals at
the call site (`_inl*` temporaries); in a jump-rendered body that puts an initialised
declaration between a `goto` and its label, which C++ rejects (`cannot jump from this goto
statement to its label`).  The C++ compiler inlines those calls itself.

`--no-solid-context` is required for the same kind of reason.  The translator writes
`options solid_context = true` by default, and daslang's AOT cannot run the h264bsd graph
with it: `daslang -aot` generates the C++ and `clang++-18` compiles it, but
`das_program_simulate` under `fail_on_no_aot` then refuses the program (`aot_host:
simulation failed`).  Measured 2026-09-22 on both `h264bsd-mp4` and
`h264bsd-mp4-640x360-std`, with and without `--unsafe-deref`; with `--no-solid-context` all
four modes converge again.  pl_mpeg and wasm3 AOT-run either way, and daslang's own
documentation says the option prohibits AOT, so the AOT build honours that and the three
modes the option was measured on — interp, `-jit`, `-exe` — keep it.

The entry is fixture source, so the driver prepends the same `options disable_auto_inline`
line to a copy of it:

```sh
{ echo "options disable_auto_inline"; cat <work>/input/src/plmpeg_file_bench_entry.das; } \
    > <work>/bench_aot/plmpeg_file_bench_entry.das
```

### 6b. C++ generation

```sh
cd <work>/bench_aot
daslang -aot all.das all.das.cpp
daslang -aot plmpeg_file_bench_entry.das plmpeg_file_bench_entry.das.cpp
```

### 6c. Compiling the generated C++ and the host

The flags are read from the toolchain's own `<das_root>/build/compile_commands.json` (the
entry that compiles daScript's `daslib/_aot_generated/*.das.cpp`), so the objects are built
exactly the way the runtime they link against was built.  On this machine that is:

```sh
clang++-18 -DDAS_ENABLE_DYN_INCLUDES=1 -DDAS_FUSION=2 \
    -DDAS_INSTALL_BINDIR=\"/usr/local/bin\" -DDAS_INSTALL_DATADIR=\"/usr/local/\" \
    -DDAS_NO_ASSERTIONS -DSIZE_OF_VOID_P=8 \
    -DSQLITE_ENABLE_COLUMN_METADATA=1 -DSQLITE_ENABLE_FTS5=1 -DSQLITE_ENABLE_SNAPSHOT=1 \
    -DSQLITE_ENABLE_STMT_SCANSTATUS=1 -DSQLITE_THREADSAFE=1 \
    -DURIPARSER_BUILD_CHAR -DURI_STATIC_BUILD \
    -I/root/daScript/include -I/root/daScript/3rdparty/fmt/include \
    -I/root/daScript/build/include -I/root/daScript/3rdparty/uriparser/include \
    -Wno-invalid-offsetof -O3 -fno-rtti -fomit-frame-pointer -fno-stack-protector \
    -DNDEBUG=1 -std=gnu++17 -fno-strict-aliasing -fwrapv \
    -c all.das.cpp -o all.das.o
clang++-18 <same flags> -c plmpeg_file_bench_entry.das.cpp -o plmpeg_file_bench_entry.das.o
clang++-18 <same flags> -c /root/c2das/scripts/corpus/aot_host.cpp -o aot_host.o
```

(When a toolchain has no `build/compile_commands.json`, the driver falls back to
`-std=gnu++17 -O3 -fno-rtti -fwrapv -fno-strict-aliasing -Wno-invalid-offsetof
-DDAS_ENABLE_DYN_INCLUDES=1 -DDAS_FUSION=2 -DDAS_NO_ASSERTIONS -DSIZE_OF_VOID_P=8 -DNDEBUG=1`
plus the three include directories.)

### 6d. Linking and running

```sh
clang++-18 aot_host.o all.das.o plmpeg_file_bench_entry.das.o \
    -L/root/daScript/lib -llibDaScriptDyn -llibDaScriptDyn_runtime \
    -Wl,-rpath,/root/daScript/lib -o aot_host
./aot_host /root/daScript <work>/bench_aot/plmpeg_file_bench_entry.das main <fixture>
```

`scripts/corpus/aot_host.cpp` sets the daslang root, hands its whole argv to
`das::setCommandLineArguments` (so the entry sees the fixture as its last argument, as in
every other mode), compiles the script with `DAS_POLICY_AOT` and `DAS_POLICY_FAIL_ON_NO_AOT`,
refuses to run an entry that is not AOT-linked, and returns the script's `main` result.
The start-up cost of this variant (0.6–3.5 s) is that second compilation of the script
inside the host, paid on every launch; the decode loop itself runs the pre-compiled C++.
That is why the benchmark reports no startup figure for the aot rows.

## 6½. `--libc std`: the C entry is the translation input

The `*-std` cases (`plmpeg-stream-320x240-std`, `h264bsd-mp4-640x360-std`, `wasm3-fib32-std`) run no
fixture-owned daslang entry at all.  Their translation input is an amalgamation of the
graph and the very C entry the C builds use:

```c
/* src/plmpeg_file_bench_all.c */
#include "all.c"
#include "plmpeg_file_bench_entry.c"
```

translated with the libc replacement policy:

```sh
cargo run -q -p c2dascript-transpile -- --strict --libc std \
    --output-dir <work>/generated_bench \
    --file <work>/input/src/plmpeg_file_bench_all.c  <same clang flags as step 1>
```

Under `--libc std` the translator lowers the entry's `printf`, `fopen`, `fread`, `fclose`,
`setvbuf`, `fflush`, `fseek`, `ftell`, `clock_gettime`, `exit` and the `stdout`/`stderr`/
`stdin` streams to translator-emitted `c2da_std_*` helpers over `daslib/fio` and the
daslang builtins (`translator/libc.rs`), and adds an exported zero-argument `main` that
builds a C `argv` from `get_command_line_arguments()` and calls the translated
`main(argc, argv)`.  The C side declares that libc subset in the fixture's `include/stdio.h`
and `include/time.h` with the glibc ABI, so `clang -O2` links the same source against the
real libc.  Nothing is written by hand on the daslang side: the module
`generated_bench/plmpeg_file_bench_all.das` is the program.

The four run modes then take that module exactly as steps 3–6 take the fixture entry:
`daslang <module> -- <fixture>`, `daslang -jit <module> -- <fixture>`,
`daslang -exe <module> -output ...`, and for AOT one more translation of the same
amalgamation with `--libc std --no-solid-context --das-option disable_auto_inline`, whose
module already carries the option, so nothing is prepended to anything.  Note the difference from step
6a: a module that is the program itself stays anonymous.  Declared `module ... public`,
its exported `main` no longer AOT-links (the host reports `entry 'main' is not
AOT-linked`); every function is reachable from `main`, so the anonymous module loses
nothing.  A case declares
this with `"libc": "std"` and `corpus.bench_translation_entry` in `cases.json`; the
convergence side uses `translation_entry` = `src/plmpeg_file_all.c` (graph +
`plmpeg_file_reference_entry.c`) the same way.

## 7. What is measured

- Each variant is run once as a warm-up (page cache, `.jitted_scripts/`, module cache) and
  then 5 times; the tables report the median of the 5, and the minimum beside it.
- **decode** is `decode_us`, measured by the program itself around its `frames_next()`
  loop: `clock_gettime(CLOCK_MONOTONIC)` in C, `ref_time_ticks` / `get_time_usec` in
  daslang.  The hashes are collected in memory during the loop and printed after it, so
  printing never lands inside the timed region.  Reading the fixture file happens before
  any timer starts.
- **setup** is `setup_us`, measured around `frames_begin_bytes()`: runtime reset, working
  copy of the stream, decoder (and demuxer) creation.  The hand-written daslang entries
  (`*_bench_entry.das`) call `all::c2da_rt_init_heap()` before their timer starts.  The
  translated heap is reserved (`reserve(c2da_rt_heap, 64 MiB)`) on the first
  `c2da_rt_malloc`; in C the heap is a static array that exists before `main`, and in a
  `--libc std` program the translated `main` wrapper's argv construction allocates first,
  so both of those enter `frames_begin_bytes()` with the heap in place.  Without the call
  the das entries' first allocation happened inside the timed region: measured 2026-09-22
  on `plmpeg-stream-320x240` under `-jit` (`taskset -c 8-15`, 9 runs), setup_us median
  317 µs as shipped vs 22 µs with the heap reserved first (the `-std` twin shows 16–46 µs);
  the interpreter's 4.6–4.8 ms setup is its own execution cost and does not move.  The
  reservation is not part of the decoder's setup in either C program, so it is not timed.
  One residue is left and is not a harness defect: the das-harness **aot** rows still show
  ≈ 0.2 ms (the `-std` aot rows 0.01–0.03 ms).  A probe on the kept AOT host (9 runs)
  attributes it to the first touch of the translated heap's pages: pre-allocating and
  resetting 1 MB before the timer drops it to 16 µs, a warm `frames_begin_bytes` +
  `frames_end` to 6 µs, while a cheap first cross-module call changes nothing.  Whether
  those pages fault depends on the process's allocator history, not on the program; the
  C builds always fault on their static heap (≈ 0.13 ms on pl_mpeg 320×240), so the
  harness does not pre-touch anything C does not.
- **wall** is the whole process as the driver sees it (`time.perf_counter` around
  `subprocess.run`), and **startup** = wall − decode − setup.  The aot rows print none (6d).
- A run counts only if its exit code is 0 and its `frame[i]=` lines equal the C `-O2`
  build's; a variant that ever differs is reported as failed instead of timed.
- The document opens with one headline table — one row per case whose corpus block has a
  `headline` label (the three `-std` programs: the entire C, entry included, is
  translated), columns interp / jit / exe / aot, each cell the ratio to `clang-18 -O3
  -march=native`, plus the native C median in ms — and exactly three lines under it
  (baseline, process start of exe and jit, the aot footnote with each headline case's
  `note`), then one option table (last item of this list).  Everything else is in the
  appendix below a rule, one table per case.
- Appendix ratio columns: **× C native** first, against `clang-18 -O3 -march=native`, the
  headline figure; **× C -O2** second, against the portable build.  `-O2` is generic
  x86-64 while the JIT compiles for the host CPU, so a single `-O2` column would flatter
  the daslang rows.  A C row is itself divided by both, so the two C builds' own ratio to
  each other is in the table.
- Per-case vocabulary comes from the corpus block: `unit` names what one checked line is
  (default `frames`; wasm3's are `checked values`), `timed` names the timed loop (default
  `decode loop`; wasm3's is the `fib call loop`), and `note` is a markdown sentence printed
  under the case's table and in the headline footnote.  A non-headline case whose C `-O2`
  loop runs under 5 ms (the embedded 96×64 samples) is marked as a noise-dominated micro
  fixture.
- The interp, jit and exe rows are built from the translator's default module:
  `options solid_context = true` in the header, daslang's null checks left in place.  The
  `+ unsafe_deref` rows are the same case translated again with `--unsafe-deref` (step 1a),
  the case's `corpus.optional_translator_flags`; the corpus cases no longer carry the flag
  in `translator_flags`.  Neither lever changes a body, so the per-frame hashes are the
  same either way — which is what the hash check proves on every run.  The **aot** row
  carries neither `solid_context` nor daslang's auto-inliner (and `aot + unsafe_deref`
  adds only `[unsafe_deref]`): daslang's AOT refuses the h264bsd graph with the option on
  and the inliner's output does not compile as C++ (step 6a), so the aot rows are not
  comparable to the others on those levers.
- Under the headline table, one more table per benchmark option (today only
  `unsafe_deref`): the headline programs' `jit`, `exe` and `aot` rows of the option, each
  as a ratio to `clang-18 -O3 -march=native` with the change against the same mode without
  the option in parentheses.

## 8. The other cases

| case | entry pair | fixture | argument |
|---|---|---|---|
| `plmpeg-stream` | `plmpeg_bench_entry.{c,das}` | `src/sample_mpg_data.h` (embedded `fixtures/sample.m1v`) | none |
| `h264bsd-mp4` | `h264_bench_entry.{c,das}` | `src/sample_mp4_data.h` (embedded `fixtures/sample.mp4`) | none |
| `plmpeg-stream-320x240` | `plmpeg_file_bench_entry.{c,das}` | `fixtures/testsrc2_320x240.m1v` | last argument |
| `h264bsd-mp4-640x360` | `h264_file_bench_entry.{c,das}` | `fixtures/test_640x360.mp4` | last argument |
| `plmpeg-stream-320x240-std` | `plmpeg_file_bench_entry.c` only, translated via `plmpeg_file_bench_all.c` (`--libc std`) | `fixtures/testsrc2_320x240.m1v` | last argument |
| `h264bsd-mp4-640x360-std` | `h264_file_bench_entry.c` only, translated via `h264_file_bench_all.c` (`--libc std`) | `fixtures/test_640x360.mp4` | last argument |
| `wasm3-fib32-std` | `host_bench.c` only, translated via `all_host_bench.c` (`--libc std`, `--das-option "stack = 4194304"`) | `fixtures/fib32.wasm` | last argument |

`wasm3-fib32-std` is the one case whose translation carries a daslang option beyond the AOT
header: the case's `das_options` key becomes `--das-option "stack = 4194304"` on every
translation (interp, jit, exe and the AOT one alike), so the module header reads `options
stack = 4194304`.  Only the interpreter uses it: wasm3's dispatch recurses one translated
call per executed opcode on the simulated stack, and daslang's default overflows around
`fib(20)`; jit, exe and aot recurse on the native stack.  Its C builds are the single
translation unit `src/all_host_bench.c` (`-std=c11 -Iinclude -Iupstream/wasm3/source -Isrc`),
and its checked lines are the seven `fib[n]=` values (`corpus.unit` = `checked values`,
`corpus.timed` = `fib call loop`, so the benchmark reads "7 checked values" and never
"decode" for it).  Its `corpus.note` explains why aot runs it faster than jit and exe:
the `-jit`/`-exe` path makes no tail calls (daslang's LLVM backend never emits sibling
calls, so each executed wasm opcode costs a native frame) while the AOT C++ gets them from
`clang++ -O3` ([lookibed/daScript#4](https://github.com/lookibed/daScript/issues/4),
`docs/followups/translator_gaps_wasm3.md`).

**4 MiB is a ceiling, not a starting point.**  The translation drops wasm3's
`__attribute__((musttail))` (`-Wmust-tail`, 489 warnings on this graph), so a dispatch
chain that iterated in C recurses here, and how deep a run may go is a per-mode fact.
Measured on plain wasm recursion with an 8 MiB native stack
(`docs/followups/translator_gaps_wasm3.md`, decision 2):

| mode | `n_max` | bytes per wasm frame |
|---|---|---|
| C `-O2` | 130 940 | 64 |
| aot | 74 774 | 112 |
| `-exe` | 16 891 | 497 |
| `-jit` | 15 386 | 545 |
| interp | 6 704 | 1251 (a catchable daslang exception) |

Only the interpreter's limit is `options stack`'s to give, and it does not give it:
raising the option from 4 MiB to 32 MiB does **not** raise the interpreter's `n_max` and
turns its catchable exception into a SIGSEGV.  `stack = 4194304` must therefore not be
raised — a larger value buys no depth and converts a diagnosable overflow into a crash.
The compiled modes recurse on the native stack and answer to `ulimit -s` instead
(doubling it doubles `-exe`'s `n_max` exactly).

The embedded-sample cases follow the same steps with no program argument; the h264bsd cases
use the graph `src/all.c` = `shim.c` + `h264bsd.c` + `minimp4.c` + `module.c` and the
`h264mp4_frames_*` probes.
