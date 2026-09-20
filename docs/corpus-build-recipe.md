# How the corpus benchmark builds its programs: C `clang -O2` vs daslang interp / jit / aot / exe

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
The output starts with `options gen2` and is an anonymous module.

## 2. C reference builds

The C graph is `src/all_reference.c` (which includes `shim.c`, the fixture's bump
allocator and mem* replacements, then the decoder and `module.c`) plus the benchmark entry:

```sh
clang-18 -std=c11 -DPLM_NO_STDIO -I<work>/input/include -I<work>/input/upstream \
    -I<work>/input/fixtures -I<work>/input/src -O2 \
    <work>/input/src/all_reference.c <work>/input/src/plmpeg_file_bench_entry.c \
    -o <work>/c_bench_O2
clang-18 ... -O0 ... -o <work>/c_bench_O0                 # same command, -O0

<work>/c_bench_O2 <fixture>
```

`-O2` is the baseline every ratio in the table refers to; `-O0` is there to show what an
unoptimised native build costs against the same source.

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

### 6a. Second translation, with the AOT module header

```sh
cargo run -q -p c2dascript-transpile -- --strict \
    --public-module --das-option disable_auto_inline \
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

`module all public` is required because `daslang -aot` emits bodies only for a named public
module's unexported functions (an anonymous module keeps nothing that is not exported or
reached).  `options disable_auto_inline` is required because daslang's optimizer otherwise
splices small same-module callees into their callers and declares the callee's locals at
the call site (`_inl*` temporaries); in a jump-rendered body that puts an initialised
declaration between a `goto` and its label, which C++ rejects (`cannot jump from this goto
statement to its label`).  The C++ compiler inlines those calls itself.  The entry is fixture
source, so the driver prepends the same `options disable_auto_inline` line to a copy of it:

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
inside the host; the decode loop itself runs the pre-compiled C++.

## 6½. `--libc std`: the C entry is the translation input

The `*-std` cases (`plmpeg-stream-320x240-std`, `h264bsd-mp4-640x360-std`) run no
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
amalgamation with `--libc std --das-option disable_auto_inline`, whose module already
carries the option, so nothing is prepended to anything.  Note the difference from step
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
  copy of the stream, decoder (and demuxer) creation.
- **wall** is the whole process as the driver sees it (`time.perf_counter` around
  `subprocess.run`), and **startup** = wall − decode − setup.
- A run counts only if its exit code is 0 and its `frame[i]=` lines equal the C `-O2`
  build's; a variant that ever differs is reported as failed instead of timed.

## 8. The other cases

| case | entry pair | fixture | argument |
|---|---|---|---|
| `plmpeg-stream` | `plmpeg_bench_entry.{c,das}` | `src/sample_mpg_data.h` (embedded `fixtures/sample.m1v`) | none |
| `h264bsd-mp4` | `h264_bench_entry.{c,das}` | `src/sample_mp4_data.h` (embedded `fixtures/sample.mp4`) | none |
| `plmpeg-stream-320x240` | `plmpeg_file_bench_entry.{c,das}` | `fixtures/testsrc2_320x240.m1v` | last argument |
| `h264bsd-mp4-640x360` | `h264_file_bench_entry.{c,das}` | `fixtures/test_640x360.mp4` | last argument |
| `plmpeg-stream-320x240-std` | `plmpeg_file_bench_entry.c` only, translated via `plmpeg_file_bench_all.c` (`--libc std`) | `fixtures/testsrc2_320x240.m1v` | last argument |
| `h264bsd-mp4-640x360-std` | `h264_file_bench_entry.c` only, translated via `h264_file_bench_all.c` (`--libc std`) | `fixtures/test_640x360.mp4` | last argument |

The embedded-sample cases follow the same steps with no program argument; the h264bsd cases
use the graph `src/all.c` = `shim.c` + `h264bsd.c` + `minimp4.c` + `module.c` and the
`h264mp4_frames_*` probes.
