# Test-system freeze — 2026-08-28

The project now has a complete machine-readable inventory at
[`tests/registry/fixtures.json`](../tests/registry/fixtures.json), generated
from [`tests/registry/catalog.json`](../tests/registry/catalog.json).  It
contains every c2das-managed C fixture, its source and C graph, recorded
Clang invocation facts, owner, entrypoint state, expected result/diagnostic
state, runtime requirement, status, and every current top-level runner.

At the freeze baseline the registry contains 295 fixtures, 25 runners, and 5
C graphs.  This is coverage inventory, not a pass count.  The supported
runtime cases are `p17`–`p25`. The complete `p17`–`p41`
ABI/object-memory family is now individually registered; every other entry remains
explicitly classified rather than inferred from a generated file. The
statuses expose reality:

- `known-red`: a declared c2das path with a recorded blocker;
- `ast-green`: its isolated Rust AST/render assertion is green, but it has no
  C-reference-to-`daslang` runtime proof and receives no readiness credit;
- `quarantined`: useful input whose old runner/oracle cannot be trusted;
- `historical`: retained upstream or diagnostic material, not c2das proof;
- `inventory-only`: a corpus whose graph/runtime contract is not yet defined.

`python3 scripts/check_test_registry.py --check` is a mandatory preflight
gate.  It fails if a C fixture under the audited roots lacks exactly one owner
family, if a record lacks C-graph/owner/status facts, or if the checked JSON
has drifted from the catalog.  Adding a C file is therefore not enough to add
a test: the resulting registry change must be reviewed together with its
future oracle.

The canonical runner now writes generated output only to a temporary
`--output-dir` and invokes `c2dascript-transpile --strict`. AST/render tests
use the same strict API and a temporary output directory. A negative fixture
is promotable only when it returns a `TranslationError` containing its source
location, C type, and lowering operation; a process crash in the Clang/CBOR
frontend is a known-red frontend defect, not a diagnostic pass.

The exporter boundary is itself executable proof. Rust negative controls cover
large child diagnostics, timeout, malformed and missing CBOR, debug argument
propagation, and invalid ClangTool options. The parent receives a typed
`ExporterFailure` with input, phase, status or signal, command and last trace
event; a child crash can never be a diagnostic pass. `p26`–`p28` and `p33`
previously exposed the `BuiltinFn` crash and are now canonical runtime cases.
