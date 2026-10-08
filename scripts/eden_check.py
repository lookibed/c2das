#!/usr/bin/env python3
"""Gate generated daScript against a local model of the EdenSpark sandbox.

Usage:
    EDEN_SANDBOX_PROJECT=<path/to/sandbox.das_project> \\
        python3 scripts/eden_check.py <generated dir or .das file>...

For every generated `.das` module under the given paths this script

1. compiles the module *as the program file* under the sandbox model:
   `daslang -no-dynamic-modules -project $EDEN_SANDBOX_PROJECT -compile-only
   <module>.das`, run from the module's own directory so its sibling
   `require`s resolve.  Each module is compiled on its own because the model
   judges only the program file and the modules whose names its prefixes
   match (docs/eden-flags.md, "Measured on master daslang"): a generated
   sub-module that is merely `require`d would not be checked.
2. prints a census of the constructs the sandbox refuses in every form
   (docs/eden-target.md §2), counted over the module text: `unsafe`,
   `addr(`, `reinterpret<`, `intptr(`.  The census reads the output; it never
   edits it.  The translator's own located census is `--no-unsafe=report`.

The sandbox model is the `sandbox.das_project` of the wasm3das EdenSpark port
(`scripts/eden/sandbox.das_project` in that repository).  It is found through
`--project` or the `EDEN_SANDBOX_PROJECT` environment variable; there is no
default path.  daslang is found through `--daslang`, `$DASLANG`,
`$DASROOT/bin/daslang`, or `daslang` on PATH.

Exit status: 0 when every module compiles under the model, 1 otherwise, 2 for a
usage error.  The census never changes the exit status.
"""
from __future__ import annotations

import argparse
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

CENSUS = {
    "unsafe": re.compile(r"\bunsafe\b"),
    "addr": re.compile(r"\baddr\s*[(<]"),
    "reinterpret": re.compile(r"\breinterpret\s*<"),
    "intptr": re.compile(r"\bintptr\s*\("),
}


def find_daslang(explicit: str | None) -> Path | None:
    candidates: list[Path] = []
    if explicit:
        candidates.append(Path(explicit))
    if os.environ.get("DASLANG"):
        candidates.append(Path(os.environ["DASLANG"]))
    if os.environ.get("DASROOT"):
        root = Path(os.environ["DASROOT"])
        candidates += [root / "bin/daslang", root / "build/daslang"]
    on_path = shutil.which("daslang")
    if on_path:
        candidates.append(Path(on_path))
    for candidate in candidates:
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return candidate
    return None


def modules(paths: list[str]) -> list[Path]:
    found: list[Path] = []
    for raw in paths:
        path = Path(raw)
        if path.is_dir():
            found += sorted(p for p in path.rglob("*.das") if not any(
                part.startswith(".") for part in p.relative_to(path).parts))
        elif path.suffix == ".das" and path.is_file():
            found.append(path)
        else:
            print(f"eden_check: not a .das file or directory: {path}", file=sys.stderr)
            sys.exit(2)
    return found


def census(text: str) -> dict[str, int]:
    code = "\n".join(line.split("//", 1)[0] for line in text.splitlines())
    return {name: len(pattern.findall(code)) for name, pattern in CENSUS.items()}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("paths", nargs="+", help="generated directory or .das files")
    parser.add_argument("--project", help="sandbox .das_project (default: $EDEN_SANDBOX_PROJECT)")
    parser.add_argument("--daslang", help="daslang binary (default: $DASLANG, $DASROOT, PATH)")
    parser.add_argument("--census-only", action="store_true", help="skip the sandbox compile")
    args = parser.parse_args()

    files = modules(args.paths)
    if not files:
        print("eden_check: no .das modules found", file=sys.stderr)
        return 2

    project = args.project or os.environ.get("EDEN_SANDBOX_PROJECT")
    daslang = find_daslang(args.daslang)
    if not args.census_only:
        if not project or not Path(project).is_file():
            print("eden_check: set EDEN_SANDBOX_PROJECT (or --project) to the sandbox "
                  ".das_project; got " + repr(project), file=sys.stderr)
            return 2
        if daslang is None:
            print("eden_check: daslang not found; set DASLANG or DASROOT, or put it on PATH",
                  file=sys.stderr)
            return 2

    failed = 0
    totals = {name: 0 for name in CENSUS}
    print(f"{'module':<40} {'sandbox':>8} " + " ".join(f"{n:>11}" for n in CENSUS))
    for path in files:
        counts = census(path.read_text(encoding="utf-8", errors="replace"))
        for name, count in counts.items():
            totals[name] += count
        status = "skipped"
        detail = ""
        if not args.census_only:
            result = subprocess.run(
                [str(daslang), "-no-dynamic-modules", "-project", str(Path(project).resolve()),
                 "-compile-only", path.name],
                cwd=path.parent, text=True, capture_output=True,
            )
            status = "ok" if result.returncode == 0 else "FAIL"
            if result.returncode != 0:
                failed += 1
                lines = [line for line in (result.stdout + result.stderr).splitlines()
                         if line.strip() and "atexit" not in line]
                detail = "\n".join("      " + line for line in lines[:6])
        print(f"{path.name:<40} {status:>8} " + " ".join(f"{counts[n]:>11}" for n in CENSUS))
        if detail:
            print(detail)
    print(f"{'total (' + str(len(files)) + ' modules)':<40} {'':>8} "
          + " ".join(f"{totals[n]:>11}" for n in CENSUS))
    if args.census_only:
        return 0
    print(f"eden_check: {len(files) - failed}/{len(files)} modules compile under the sandbox model")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
