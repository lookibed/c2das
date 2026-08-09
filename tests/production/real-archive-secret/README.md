# miniz_archive_das

C → [daScript](https://dascript.org/) transpilation test case: ZIP archive extraction using [miniz](https://github.com/richgel999/miniz).

## Structure

| File | Source | Description |
|------|--------|-------------|
| `all.c` | hand-written | Unity build `#include` shim + miniz + module |
| `module.c` | hand-written | C module: miniz wrapper (extract secretik.txt from ZIP) |
| `shim.c` | hand-written | libc stubs (malloc, free, memset, memcpy, memcmp) |
| `all.das` | transpiled by c2dascript | Full unity build output (6625 lines, ~100+ type errors) |
| `module.das` | transpiled by c2dascript | module.c only (698 lines, needs runtime stubs) |
| `runtime.das` | hand-written | Stubs for external functions called by module.das |
| `cc_all.json` | hand-written | compile_commands.json for unity build |
| `cc_module.json` | hand-written | compile_commands.json for module.c only |
| `secretik.zip` | fixture | ZIP with `secretik.txt` → `"Hi Bebra 2026!"` |
| `main.lua` | hand-written | Original LuaJIT test harness |

## Original Repos

- **miniz** — https://github.com/richgel999/miniz
- **daScript** — https://dascript.org/ | https://github.com/GaijinEntertainment/daScript
- **c2dascript** — https://github.com/anomalyco/c2dascript (C → daScript transpiler, fork of c2rust)
- **c2rust** — https://github.com/immunant/c2rust

## Pipeline

```
all.c → c2dascript-transpile → all.das → daslang.exe → verify
```

## Status

- Transpilation: success (relooper panics fixed)
- Compilation: type errors remain (known transpiler issues: `uint64+int`, `!` on non-bool, `int(bool)`, string→array init, const-pointer mismatch, function pointer fields as `auto`)
