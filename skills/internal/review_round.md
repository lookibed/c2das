# Multi-agent review round

Use for every non-trivial change or explicit review.  The algorithm is mandatory:

1. One read-only `targeted-reviewer` produces a **grounding** map for the whole diff: intent,
   integration surface, hotspots, blind spots, and applicable `REVIEW.md` files.
2. The orchestrator derives 3-6 change-specific risk dimensions.  Generic labels such as
   “correctness” are invalid.
3. In parallel, run one read-only surfacer per dimension, one general surfacer, one
   `review-md-auditor` per checklist, one `style-hygiene-auditor`, and one `tdd-auditor`.
4. Deduplicate same-location/same-concern reports.  A separate `targeted-reviewer` proves each
   survivor by first attempting falsification, then freshly verifying observations, inference,
   pre-change baseline, scope, and severity.
5. Report only confirmed defects, `UNPROVEN` evidence requests, and TDD verdicts.  Include the
   falsification trail and rejected-counts.  Zero findings is a result.
6. Land accepted fixes as one batch.  Any non-trivial batch receives a fresh cold review round.
7. `flashlight` surfaces only human decisions which repository evidence cannot settle.

Surfacers optimize recall; the prover optimizes precision.  All review roles are report-only.
