# Test-system architecture

`tests/registry/catalog.json` is the frozen inventory of every c2das-managed C
fixture and runner.  It records a C graph, Clang facts, owner, entrypoint,
expected result or diagnostic state, runtime requirement, and truth status;
`fixtures.json` is its checked expansion.  A new fixture or runner is invalid
until the registry check is updated.

`tests/syntax` is the future canonical executable ABI suite, not yet a green
one.  Its C inputs and Rust render assertions must be paired with fresh
temporary `.das` output and WSL `daslang` execution.  Generated `.das` in the
checkout is historical evidence only, never a runtime oracle.  Corpus runners
remain separate from the fast suite.

`tests/canonical/cases.json` is the executable subset.  Its one canonical WSL
runner copies each C graph to a temporary workspace, builds its C reference,
requires fresh c2das output, executes daScript, and compares both stdout and
exit status.  It is the only runtime gate allowed in preflight.
