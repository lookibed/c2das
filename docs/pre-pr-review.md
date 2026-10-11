# Pre-PR review: two output critics

## Rule

Every change that can alter generated daslang must pass two read-only critics **once** before its
PR is opened (or before a direct push to `master`). The critics are defined in `.claude/agents/`:

| critic | file | judges |
|---|---|---|
| `das-critic-perf` | `.claude/agents/das-critic-perf.md` | interpreter/JIT/AOT cost of the generated code: node shapes, loops, temporaries, allocation |
| `das-critic-style` | `.claude/agents/das-critic-style.md` | idiom and noise against daslang's own code and its lint/format tools |

Changes that can alter generated daslang include the translator, `das_ast`, the runtime and libc
preludes, and translator flags or case flags.

Both critics compare the head against the merge base on the affected cases. Their references are:
- daslang's own code: `daslib`, `modules/dasLLAMA`, `modules/dasVulkan`, `modules/dasGlsl`,
  `modules/dasSpirv`, `examples`;
- the node emitter in `src/ast/ast_simulate.cpp`;
- `scripts/lint_translated.py`.

## When

Run them after the change is complete and the gates are green:
- `run_c2das_cases.py --all-ready` and the negatives;
- `cargo test -p c2dascript-transpile`;
- `check_test_registry.py --check`.

Do not run them on every intermediate step; they run once per PR.

## How

Start both agents in parallel (two agents at a time is the limit) with the range under review, for
example: "review `origin/master...HEAD`; affected cases: <ids>". A critic may regenerate cases and
run micro-benchmarks but never edits the repository.

## What blocks

- **`BLOCK` from `das-critic-perf`:** an interpreter regression, or an introduced construct
  ≥ 3% slower on a corpus.
- **`BLOCK` from `das-critic-style`:** new avoidable lint findings at no speed cost, or a readability
  regression.

Either one is fixed in the translator before the PR, or recorded with a reason in the PR body.

Findings with `PASS` go into the PR body as a short table; the ones worth doing become follow-ups
in `docs/followups/translated_output_critique.md`.

## Priority

Interpreter speed over beauty: a style finding never outranks a measured speed cost. Spellings kept
for speed are marked in the output (`// nolint:PERF020`, `// nolint:STYLE025`) and documented in
`das_ast/src/fold.rs`.
