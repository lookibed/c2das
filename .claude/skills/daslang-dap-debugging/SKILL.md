---
name: daslang-dap-debugging
description: Stateful step debugging of .das programs through the daslang-dap MCP server (debug_launch, breakpoints, threads, configuration_done, stack/scopes/variables, stepping, disconnect). Invoke before any runtime investigation that needs breakpoints or stepping.
---

# daslang DAP debugging (c2das)

Read first:

- `/root/daScript/utils/dap/README.md` (bridge contract, launch and attach workflows)
- `/root/daScript/doc/source/reference/utils/dap.rst` (tool-by-tool reference)

The `daslang-dap` server in `.mcp.json` runs `/root/daScript/utils/dap/main.das` on the
local daScript build with `--repo-root /root/c2das` and that build's `bin/daslang` as the
debuggee executable. Compile, lint and test gates use the same `/root/daScript/bin/daslang`.

Canonical launch lifecycle:

```text
debug_launch(file=..., stepping_debugger=true|false; omit port)
  -> debug_set_breakpoints (optional, once per source file)
  -> debug_threads               (mandatory startup gate)
  -> debug_configuration_done
  -> debug_wait_event(stopped|terminated)
after stopped: debug_stack_trace -> debug_scopes -> debug_variables / debug_evaluate
             -> debug_continue | debug_step_in | debug_step_over | debug_step_out
finish:      debug_terminate or debug_disconnect (idempotent; already_disconnected=true is success)
```

Rules: never pick ports by hand, never `pkill daslang` broadly, always `debug_disconnect`
before a new `debug_launch`, and record `session` fields (`return_code`, `close_reason`,
`last_dap_termination`, `process_output_tail`) when a session dies unexpectedly. Use
`/root/daScript/utils/dap/_fixture.das` for connection smoke tests. In c2das the debuggee
is usually a transpiler output (`tests/syntax/*.das`, `tests/unit/*/src/*.das`, or a file
written by `scripts/run_c2das_cases.py --keep-workdir`), so debug the generated daScript, then fix
the translator that produced it, never the generated file by hand.
