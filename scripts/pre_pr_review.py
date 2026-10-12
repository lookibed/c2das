#!/usr/bin/env python3
"""Gate for the mandatory pre-PR critic review (docs/pre-pr-review.md).

usage: python3 scripts/pre_pr_review.py [<base>] [<head>]      (default origin/master HEAD)

If the range touches anything that can change generated daslang (the translator, das_ast,
runtime/libc preludes, case or translator flags), a review record must exist under
docs/reviews/ that names the range's head commit (or a commit after the last such change)
and carries a verdict line from both critics:

    das-critic-perf: PASS|BLOCK ...
    das-critic-style: PASS|BLOCK ...

A BLOCK verdict needs a following "resolved:" line (fixed in commit X, or the reason it is
accepted).  Exit 0 when the range needs no review or a valid record covers it, 1 otherwise,
printing what is missing and which cases the critics should look at.
"""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TRIGGERS = (
    "c2dascript-transpile/src/",
    "das_ast/src/",
    "tests/canonical/cases.json",
)


def git(*args: str) -> str:
    return subprocess.run(["git", *args], cwd=ROOT, text=True, capture_output=True, check=True).stdout


def main() -> int:
    base = sys.argv[1] if len(sys.argv) > 1 else "origin/master"
    head = sys.argv[2] if len(sys.argv) > 2 else "HEAD"
    changed = [f for f in git("diff", "--name-only", f"{base}...{head}").split() if f]
    relevant = [f for f in changed if f.startswith(TRIGGERS)]
    if not relevant:
        print(f"pre-PR review: {base}...{head} changes no generated-daslang source; no critic review needed")
        return 0
    # the last commit in the range that touched a trigger path must be covered by a record
    last = git("log", "-1", "--format=%H", f"{base}..{head}", "--", *TRIGGERS).strip()
    covered = set(git("rev-list", f"{last}^..{head}").split()) if last else set()
    records = sorted((ROOT / "docs/reviews").glob("*.md"))
    for rec in records:
        text = rec.read_text(encoding="utf-8")
        shas = set(re.findall(r"\b[0-9a-f]{9,40}\b", text.split("\n", 3)[0] + "\n" + text))
        if not any(any(c.startswith(s) for c in covered) for s in shas):
            continue
        perf = re.search(r"^das-critic-perf:\s*(PASS|BLOCK)", text, re.M)
        style = re.search(r"^das-critic-style:\s*(PASS|BLOCK)", text, re.M)
        unresolved = [m.group(0) for m in re.finditer(r"^das-critic-(perf|style):\s*BLOCK.*$", text, re.M)
                      if not re.search(r"^resolved:", text[m.end():], re.M)]
        if perf and style and not unresolved:
            print(f"pre-PR review: {rec.relative_to(ROOT)} covers {base}...{head} "
                  f"(perf {perf.group(1)}, style {style.group(1)})")
            return 0
    print(f"pre-PR review MISSING for {base}...{head}: {len(relevant)} generated-daslang file(s) changed, "
          f"last at {last[:9]}.")
    print("Run the two critics (.claude/agents/das-critic-perf.md, das-critic-style.md) on the range and "
          "record their verdicts in docs/reviews/<date>-<head-sha>.md (see docs/pre-pr-review.md).")
    return 1


if __name__ == "__main__":
    sys.exit(main())
