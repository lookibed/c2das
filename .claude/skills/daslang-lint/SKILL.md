---
name: daslang-lint
description: Meaning and fixes for daslang lint findings (LINT*, PERF*, STYLE* rules from paranoid, perf_lint and style_lint). Invoke when the LSP or mcp__daslang__lint reports a finding, or before running the three lint profiles.
---

# daslang lint (c2das)

Read the rule references in full before acting on a finding:

- `/root/daScript/skills/perf_lint.md` (PERF rules)
- `/root/daScript/skills/style_lint.md` (STYLE rules)
- LINT (paranoid) rules are documented inline next to their checks in
  `/root/daScript/daslib/lint.das` (search for the rule id, e.g. `LINT003`).

Running the three profiles on the expected outputs:

```sh
export DAS_LINT_CONFIG_PATH="$PWD/.lint_config"
for p in paranoid-only perf-only style-only; do
  /root/daScript/bin/daslang /root/daScript/utils/lint/main.das -- --$p tests/syntax
done
```

The repo policy file `.lint_config` disables the rules that flag constructs which are the
faithful spelling of the C source (reason written next to each rule). Lint findings on
transpiler output are translator or printer bugs: fix the Rust code that generates the
construct, never the `.das` output, and do not add rules to `.lint_config` to silence a
finding that can be fixed in the translator.

During editing use `mcp__daslang__lint` on the changed file; the LSP plugin pushes the same
findings as warnings after every edit.
