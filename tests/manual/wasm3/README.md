# wasm3

Manual corpus: the wasm3 WebAssembly interpreter, vendored under `upstream/` at the
revision recorded in `UPSTREAM.md`.  It is the first corpus whose target is an
*interpreter* rather than a decoder: the C graph reads a `.wasm` module, compiles its
function bodies to wasm3's metacode and runs them, so what the translator has to carry
across is an opcode dispatch loop and a code generator, not a fixed pipeline.

There is no WASI here, and no host imports of any kind.  The fixtures export `fib` and
import nothing, so the graph is the interpreter proper: `m3_host_none.h` for the system
layer, no `m3_api_wasi.c`, no `m3_api_libc.c`.  See `src/all.c` for the configuration and
why each define is set.

The corpus carries no case in `tests/canonical/cases.json` yet, because the graph does not
translate: see "Translation status" below.

## Layout

- `src/all.c` — the c2das target graph: the wasm3 configuration macros followed by the
  eleven core translation units, in one translation unit.
- `src/host.c` — the C entry.  Reads the `.wasm` file named by the last command-line
  argument into a static buffer, creates an environment and a 64 KiB runtime, parses and
  loads the module, finds its `fib` export and calls it for n in 1, 2, 5, 10, 15, 20, 24,
  printing `fib[n]=<value>` per call and then `count=<lines>`.  A failure prints
  `error=<m3 error string>` and exits non-zero.
- `src/host_bench.c` — the same, plus `setup_us` (parse and load) and `decode_us` (the call
  loop), measured with `clock_gettime(CLOCK_MONOTONIC)`.  Results are collected first and
  printed after the timed loop, and the file is read before any timer starts.
- `src/all_host.c` / `src/all_host_bench.c` — the graph plus one of those entries in a
  single translation unit, so a translated module would carry the program's `main` and run
  as is.  These are the `--libc std` translation inputs.
- `include/` — libc stubs that shadow the system headers for the whole graph, declared with
  the glibc ABI so the C build links against the real libc.  `stdio.h`, `stdlib.h`,
  `string.h`, `ctype.h` and `time.h`.
- `fixtures/` — `fib32.wasm` and `fib64.wasm`, 62 bytes each, upstream's own.

`stddef.h`, `stdint.h`, `stdbool.h`, `stdarg.h`, `limits.h`, `errno.h`, `float.h`,
`inttypes.h` and `assert.h` are *not* shadowed and come from the system for both the native
and the translation build.  `errno.h` is the one that matters: glibc reaches `errno`
through `__errno_location()`, and there is no other ABI to declare it with, so that symbol
is part of the graph whether or not the header is shadowed.

## Build and run, natively

```sh
clang-18 -std=c11 -O2 -Iinclude -Iupstream/wasm3/source -Isrc src/all_host.c -o /tmp/wasm3_host
/tmp/wasm3_host fixtures/fib32.wasm
```

`-O0` builds and runs identically.  `src/all_host_bench.c` builds the same way.  No `-D` is
needed: everything the configuration wants is in `src/all.c`, including
`M3_IMPLEMENT_ERROR_STRINGS`, which a unity build has to set before the first include of
`wasm3.h` for the `m3Err_*` table to be defined anywhere.

Expected output on either fixture:

```
bytes=62
fib[1]=1
fib[2]=1
fib[5]=5
fib[10]=55
fib[15]=610
fib[20]=6765
fib[24]=46368
count=7
```

## Dispatch and the native stack

wasm3 dispatches one opcode to the next by returning into it —
`nextOpDirect()` in `upstream/wasm3/source/m3_exec_defs.h` is
`M3_MUSTTAIL return nextOpImpl()`, and `nextOpImpl()` is
`((IM3Operation)(*_pc))(_pc + 1, ...)`.  With clang, `M3_MUSTTAIL` is
`__attribute__((musttail))` and `M3_GUARANTEED_TAIL_CALL` is 1, so this build gets
`d_m3CanTailCall` 1 and `d_m3EntryKeepsFrame` 0.  musttail is mandatory rather than an
optimisation, so it holds at `-O0` as well: an op ends in `jmp *%rax` at both `-O0` and
`-O2`, and the native stack stays flat across a dispatch.

Without it (`-DM3_HAS_TAIL_CALL=0`, which empties `M3_MUSTTAIL` and clears
`M3_GUARANTEED_TAIL_CALL`) the same op ends in `call *%rax` and returns, so the native
stack grows with the *Wasm call depth* times the ops executed per function body — not with
the total ops executed, because a Wasm return unwinds the whole chain behind it.  `fib` at
n = 24 nests 24 Wasm frames of roughly a dozen ops, a few tens of KiB of native stack, so
all four combinations of `-O0`/`-O2` and tail calls on/off run the fixture correctly.  What
is lost without the guarantee is `return_call` being iterative, which these fixtures do not
use.

Under `m3_host_none.h`, `m3_HostStackBase()` answers NULL, so nothing measures the real
stack: the interpreter's budget is the compile-time `d_m3MaxNativeStack`, 8 MiB less
128 KiB, and `d_m3NativeStackMargin` never applies.  On the main thread that is close
enough to the real 8 MiB stack; on a smaller thread the budget would overrun the stack
rather than trap before it.

## Translation status

`src/all_host.c` does not translate under `--libc std`.  The first stop is a translator
panic on wasm3's `__attribute__((musttail))`:

```
thread 'main' panicked at 'Unknown statement attribute: musttail',
c2dascript-transpile/src/c_ast/conversion.rs:1173:38
```

Past that (`-DM3_HAS_TAIL_CALL=0`), the run reports `unsupported external call: strcmp`,
and behind it a further chain of libc and builtin gaps.  Neutralising all of them in a
scratch copy does produce a `.das`, but that module does not parse: the translator emits
the opcode dispatch as `unsafe(reinterpret<IM3Operation>(*_pc))(...)`, calling a
`function<>`-typed value by juxtaposition, where daslang requires `invoke(...)` — which the
same translator emits correctly a few lines away when the callee is first stored in a
local.  That is 491 sites, all of them the interpreter's dispatch.
