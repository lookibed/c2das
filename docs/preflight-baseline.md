# Initial preflight baseline — 2026-08-28

This is the committed starting measurement before the new gates are treated as a compatibility
claim.  A red row is a real baseline failure, not an exemption or a green result.

| Gate | Result | Evidence / next owner |
|---|---|---|
| Windows Rust test invocation | red | `c2rust-ast-exporter` cannot find LLVM; Windows source editing is not the canonical runtime gate. |
| `cargo fmt --check` | red | Existing workspace formatting differs from the configured rustfmt across pre-existing files; format normalization is a separate, reviewable cleanup. |
| WSL mirror hash | green | Windows source and `/root/c2das-preflight-Andry` produced `3a6359e21b9b0f58297f38c053086d04f11073cf27fb58771b1b3b3e262d906f`. |
| Governance contracts | green | `cargo test -p c2dascript-transpile --test governance_tests`: 4 passed. |
| Existing translator architecture | green | `cargo test -p c2dascript-transpile --test architecture_tests`: 11 passed. |
| PLMPEG C graph | green | `tests/manual/real-world-plmpeg-stream/check_c_graph.sh` completed before the next chained gate. |
| ABI daScript suite | red | Canonical runner stops at missing generated fixture `tests/syntax/p26_variadic_sum.das`.  The fixture/output registration owner must classify or implement it; do not weaken the runner. |

The new preflight is intentionally fail-closed from this baseline forward.  Each row turns green
only through its owner layer and a new recorded result.
