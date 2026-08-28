# Real-world corpus status ledger

| Corpus | Source revision | Status | First blocker | Owner | Acceptance gate |
|---|---|---|---|---|---|
| PLMPEG stream | canonical repository graph | known red | `abi::null_pointer` is invoked for a non-pointer condition after aggregate raw-object rvalue lowering | condition/value lowering and `abi.rs` contract | canonical graph → transpile → WSL `daslang` result equals C reference |
| h264bsd + minimp4 | recorded in `tests/manual/real-world-h264bsd-mp4/UPSTREAM.md` | inventory only | no canonical graph/transpile/runtime result yet | corpus graph inventory | graph → transpile → WSL execution; every first blocker classified |

Known-red entries are never counted as successful validation or readiness.
