# Canonical executable cases

`cases.json` is the executable subset of the frozen fixture registry.  A case
is not a generated `.das` file: it declares one C graph, exact Clang facts, a
C reference entrypoint, a daScript entrypoint, and an exact stdout/exit oracle.

`python3 scripts/run_c2das_cases.py --all-ready` executes every ready case in
an isolated temporary directory:

```text
C graph -> C reference -> c2das -> fresh .das -> daslang -> stdout/exit comparison
```

The runner copies the declared source root, removes every copied `.das` before
translation, invokes strict translation with a temporary `--output-dir`, and
never writes generated output into the checkout. A case may become
`supported` only after the corresponding AST/render assertion and this runtime
path are both green.  `known-red` cases stay in the fixture registry and do
not execute by default.

`p17`–`p41` are each a case record. `ast-green` means only the isolated
AST/render proof has passed; it is not runtime compatibility. `negative`
cases declare the exact required `TranslationError` contract (location, C
type, operation, and cause) and cannot be marked supported by absence of
printed output.

`plmpeg-stream` is the first known-red graph case. Run it explicitly with
`--case plmpeg-stream`; its first canonical failure belongs in the real-world
ledger and receives no readiness credit.
