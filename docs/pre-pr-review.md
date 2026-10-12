# Pre-PR review: two output critics

## Rule

Every change that can alter generated daslang must pass two read-only critics **once** before its
PR is opened (or before a direct push to `master`). The critics are defined in `.claude/agents/`:

| critic | file | judges |
|---|---|---|
| `das-critic-perf` | `.claude/agents/das-critic-perf.md` | interpreter/JIT/AOT cost of the generated code: node shapes, loops, temporaries, allocation |
| `das-critic-style` | `.claude/agents/das-critic-style.md` | beauty, idiom and noise of all output in every mode, against daslang's own code and its lint/format tools |

Changes that can alter generated daslang include the translator, `das_ast`, the runtime and libc
preludes, and translator flags or case flags.

Both critics read the generated output as a blank sheet: all of it, in every translator mode, with no
"before" and no "pre-existing". The range only says which cases to regenerate first; perf also times
the merge base to catch regressions. Their references are:
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

## Record and gate

Record each review in `docs/reviews/<date>-<head-sha>.md`:
- name the range;
- a line `das-critic-perf: PASS|BLOCK …`;
- a line `das-critic-style: PASS|BLOCK …`;
- after any BLOCK, a `resolved:` line naming the fixing commit or the accepted reason.

`python3 scripts/pre_pr_review.py [<base>] [<head>]` (default `origin/master` `HEAD`) is the gate. It
exits 1 when the range changes generated-daslang sources and no record covers the last such commit.
Run it before opening the PR or pushing to `master`.

## What blocks

- **`BLOCK` from `das-critic-perf`:** an interpreter regression, or any construct in the output the
  translator could emit measurably faster, whoever introduced it.
- **`BLOCK` from `das-critic-style`:** any avoidable ugliness in the output, in any mode, that the
  translator could emit cleanly at no speed cost, whoever introduced it.

Either one is fixed in the translator before the PR, or recorded with a reason in the PR body.

Findings with `PASS` go into the PR body as a short table; the ones worth doing become follow-ups
in `docs/followups/translated_output_critique.md`.

## Priority

Interpreter speed over beauty: a style finding never outranks a measured speed cost. Spellings kept
for speed are marked in the output (`// nolint:PERF020`, `// nolint:STYLE025`) and documented in
`das_ast/src/fold.rs`.
