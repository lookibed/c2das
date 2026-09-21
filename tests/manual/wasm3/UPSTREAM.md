# Upstream provenance

This directory vendors fixture input as ordinary source files.  It intentionally contains no
nested Git metadata.

| Component | Upstream | Revision | License retained at |
|---|---|---|---|
| wasm3 | https://github.com/wasm3/wasm3 | `deeaca9ce815565478ab854e0db9046a479c92ff` | `upstream/wasm3/LICENSE` (MIT) |

Import procedure: clone the upstream at the recorded revision into a temporary directory, copy
`source/*.c`, `source/*.h` into `upstream/wasm3/source/` and `LICENSE` into `upstream/wasm3/`
while excluding `.git`, then record the new revision here.  `source/extensions/`,
`source/extra/`, `platforms/`, `extra/` and `test/` are not vendored: the corpus builds the
interpreter core only.  Local graph wrappers and generated outputs belong outside `upstream/`.

The vendored `source/` is the whole of upstream's top-level source directory, unmodified.
`src/all.c` compiles eleven of its translation units — `m3_bind.c`, `m3_code.c`,
`m3_compile.c`, `m3_core.c`, `m3_env.c`, `m3_exec.c`, `m3_function.c`, `m3_info.c`,
`m3_module.c`, `m3_parse.c`, `m3_validate.c`.  The WASI files (`m3_api_wasi.c`,
`m3_api_uvwasi.c`, `m3_api_meta_wasi.c` and their `m3_api_wasi_*.h` host layers), the tracer
and `m3_api_libc.c` are vendored for provenance and never compiled: the fixtures import
nothing, so the module needs no host imports at all.  `m3_host_none.h` is the
`m3_host.h` implementation the corpus selects, so `m3_host_posix.h` and `m3_host_win32.h`
are likewise never compiled.

## Fixtures

| File | Bytes | sha256 | Content | Origin |
|---|---|---|---|---|
| `fixtures/fib32.wasm` | 62 | `80073d9035c403b6caf62252600c5bda29cf2fb5e3f814ba723640fe047a6b87` | one module exporting `fib`, `(param i32) (result i32)`, naive double recursion | wasm3's own `test/lang/fib32.wasm` at the revision above |
| `fixtures/fib64.wasm` | 62 | `a219b0377b2b12ad70cf46071824fb17a1d266131a0795e7bef6cd753c927243` | the same module with `i64` throughout | wasm3's own `test/lang/fib64.wasm` at the revision above |

Both are copied byte for byte and carry the same MIT license as the interpreter.  Their
source text is upstream's `test/lang/fib32.wat` and `fib64.wat`, which are not vendored.
Neither imports anything, so neither needs WASI or any other host module, and neither
executes a float operation — which is what lets `src/all.c` build with `d_m3HasFloat 0`.
They are read at run time by the `src/host*` entries (last command-line argument), never
embedded.
