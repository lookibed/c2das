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

- `compile_check`, `lint`, `type_of`, `goto_definition`, `find_references`,
  `find_symbol`, `format_file`: project-relative paths work
  (`tests/manual/tmp_ptr_reinterpret_check.das`), absolute paths work too.
- `run_script`, `run_test`, `outline`, `grep_usage`, `cpp_outline`: relative paths are
  joined onto the toolchain root (`/root/daScript`), not the server's cwd, so always
  pass absolute paths: `directory: <repo root>/tests/manual`,
  `file: <repo root>/tests/manual/tmp_ptr_reinterpret_check.das`. Observed with a
  relative path: `run_script` and `run_test` fail with
  `missing prerequisite '/root/daScript/tests/manual/...'`; `outline` returns no
  output, `grep_usage` reports `0 matches in 0 files`, `cpp_outline` reports
  `No C++ declarations found`. This is a daScript MCP server defect (`resolve_path`
  in `utils/mcp/tools/common.das`), not a `.mcp.json` problem.
- `run_script` needs an `[export] def main()`; the transpiler outputs under `tests/`
  are plain modules, so it answers `function 'main' not found` for them (expected).
- `cpp_grep_usage`, `cpp_outline`, `cpp_find_symbol` work on C/C++ sources: the C
  inputs under `tests/` and the Clang exporter in `c2rust-ast-exporter/src`; pass
  absolute paths. `cpp_goto_definition` (needs `file`, `symbol`, `line`, `column`)
  answered `No definition found` for a class declared in the same file; prefer
  `cpp_find_symbol` or `cpp_grep_usage`.
- `cpp_compile_check` and `cpp_build_info` only know the toolchain's
  `build/compile_commands.json`, so they answer `no compile DB entry` for c2das
  sources; `cpp_format_file` is a no-op because `clang-format` is not installed
  (`cpp_status` reports both).
- Files outside `/root/c2das` (for example the session scratchpad) get a
  CROSS-TREE WARNING from every file tool; the result is still produced.
- The MCP results are development aids. `scripts/run_c2das_cases.py` with the real
  `daslang` and `cargo test` are authoritative.
