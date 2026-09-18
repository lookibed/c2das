---
name: daslang-mcp-tools
description: Reference for the daslang MCP server tools (compile_check, lint, grep_usage, outline, find_symbol, run_test, format_file, cpp_* and live_* tools). Invoke when choosing how to search, compile, lint, or run .das code.
---

# daslang MCP tools (c2das)

Read the full tool table and notes first:
`/root/daScript/skills/mcp_tools.md`.

How the server is wired in this project (`.mcp.json`): the `daslang` server is the
`/root/daScript/bin/watchdog` stdio front, which spawns
`/root/daScript/bin/daslang -ignore-manifest /root/daScript/utils/mcp/main.das` with
cwd = c2das root on the first tool call and respawns it after a kill or a rebuild;
`DAS_LINT_CONFIG_PATH` points it at this repository's `.lint_config`. The `daslang-dap`
server is the same front over `utils/dap/main.das`, and the LSP plugin
(`.claude/skills/daslang-lsp`) runs `watchdog --lsp` from the same checkout, which is
built with the `stddlg` module the watchdog requires.

Path conventions that follow from that:

Every statement below was confirmed by calling the tool against
`tests/manual/tmp_ptr_reinterpret_check.das` (or the exporter sources) from this
project; keep it that way when editing.

- Project-relative paths (`tests/manual/tmp_ptr_reinterpret_check.das`,
  `directory: tests/manual`) resolve against the served tree, `/root/c2das`, for
  every file tool: confirmed for `compile_check`, `lint`, `type_of`,
  `goto_definition`, `find_references`, `find_symbol`, `format_file`, `run_script`,
  `run_test`, `outline`, `grep_usage`, `cpp_outline`, `cpp_find_symbol`,
  `cpp_goto_definition`. Absolute paths work too. This needs daScript commit
  `6fe6d8e75` ("a tool's relative path resolves against the served tree") or later;
  on an older checkout `run_script`, `run_test`, `outline`, `grep_usage` and the
  `cpp_*` tools join relative paths onto `/root/daScript` instead, and the symptom
  is `missing prerequisite '/root/daScript/tests/...'` from `run_script`. After
  pulling daScript, call the `shutdown` tool once so the watchdog respawns the
  server on the new code.
- `run_script` needs an `[export] def main()`; the transpiler outputs under `tests/`
  are plain modules, so it answers `function 'main' not found` for them (expected).
  `run_test` on such a file reports `0 tests ... SUCCESS`.
- `cpp_grep_usage`, `cpp_outline`, `cpp_find_symbol`, `cpp_goto_definition` work on
  C/C++ sources: the C inputs under `tests/` and the Clang exporter in
  `c2rust-ast-exporter/src`. The `cpp_*` index covers the whole served tree, so
  `cpp_goto_definition` (needs `file`, `symbol`, `line`, `column`) finds the
  `TranslateConsumer` class and constructor in `AstExporter.cpp`.
- `cpp_compile_check` and `cpp_build_info` probe `build/`, `build-ninja/` and
  `build*/` under `/root/c2das` by default; c2das has no such directory, so without
  `build_dir` they answer `No compile_commands.json found`. The exporter's cargo
  build configures CMake with `CMAKE_EXPORT_COMPILE_COMMANDS=ON`, so pass that
  database as `build_dir` (a directory or the JSON file itself, relative or
  absolute):

  ```
  find target -path '*c2rust-ast-exporter-*/out/build/compile_commands.json'
  ```

  The hash in the path changes on rebuilds, so look it up rather than hard-coding
  it. Observed with `build_dir` set to the release database: `cpp_compile_check`
  on `c2rust-ast-exporter/src/AstExporter.cpp` answers `Compile check OK`, and
  `cpp_build_info` prints the `/usr/bin/c++ ... -std=c++17` command from that DB.
- `cpp_format_file` formats in place with the root `.clang-format` (LLVM style,
  4-space indent); `cpp_status` reports `clang-format` from `/root/.local/bin`.
  Observed on a copy of `tests/syntax/p11_function_pointer_decay.c`: status
  `formatted`, `message: formatted in place using style from ../c2das/.clang-format`.
  It rewrites the file it is given (the probe's three-line function collapsed to
  one line), so do not point it at tracked C inputs under `tests/` unless a
  reformat of that file is the intent.
- Files outside `/root/c2das` (for example the session scratchpad) get a
  CROSS-TREE WARNING from every file tool; the result is still produced.
- The MCP results are development aids. `scripts/run_c2das_cases.py` with the real
  `daslang` and `cargo test` are authoritative.
