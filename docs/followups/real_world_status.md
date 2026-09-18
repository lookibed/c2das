# Real-world corpus status ledger

| Corpus | Source revision | Status | Canonical case | Last verified | Acceptance gate |
|---|---|---|---|---|---|
| PLMPEG stream | vendored under `tests/manual/real-world-plmpeg-stream/upstream` (no `UPSTREAM.md`; add one when the revision is next refreshed) | ready | `plmpeg-stream` in `tests/canonical/cases.json`, graph `plmpeg-target`, entry `src/all.c` | 2026-09-18 on master after `e6cd45993`: `scripts/run_c2das_cases.py --case plmpeg-stream` → `PASS plmpeg-stream: C reference == fresh daScript` | canonical graph → transpile → WSL `daslang` result equals C reference |
| h264bsd + minimp4 | `tests/manual/real-world-h264bsd-mp4/UPSTREAM.md`: h264bsd `42bcb5d7`, minimp4 `4575afb4` | ready | `h264bsd-mp4` in `tests/canonical/cases.json`, graph `h264bsd-mp4`, entry `src/all.c` | 2026-09-18 on master after `e6cd45993`: `scripts/run_c2das_cases.py --case h264bsd-mp4` → `PASS h264bsd-mp4: C reference == fresh daScript` | canonical graph → transpile → WSL `daslang` result equals C reference |

Both corpora were already `ready` in the `c2das-v0.1.0` release (2026-09-10); its
notes record pl_mpeg decoding all five streams from 96×64 to 1920×1080 with identical
RGB hashes and h264bsd + minimp4 decoding 8 frames at 96×64 with all nine probes equal
to C. The previous version of this ledger (PLMPEG "known red" on `abi::null_pointer`,
h264bsd "inventory only") predated those promotions and was never updated.

`--all-ready` stops at the first failing case, and `p56-heap-churn` (a synthetic
200 MiB heap-churn test, red in the release too) precedes both corpora in registry
order, so a full-registry run does not reach them until that case is fixed or
skipped; verify them with `--case` as above.

Known-red entries are never counted as successful validation or readiness. A `ready`
row is only as current as its "Last verified" cell: re-run the case and update the
cell whenever the translator, the runtime prelude or the vendored sources change.
