#!/usr/bin/env python3
"""Lint translated daslang with daslang's own lint runner and write a Markdown report.

Input is one or more directories of generated output.  A directory holding a
`TRANSLATION.json` is one translation (a case/variant written by
`run_c2das_cases.py` or `corpus_matrix.py`); any other directory is searched for
such translations below it.  The default is every translation under
`latest_root()` (`<checkout>/.c2das-out/latest`, or `$C2DAS_LATEST_DIR`).

Every module file (`*.das`) of a translation is linted.  `.das.inc` fragments
of the source module layout are not linted on their own (they do not compile
alone); the lint of the module that includes them reports their findings under
the fragment's own file name, and the report keeps that name.

The lint runner is `<DASROOT>/utils/lint/main.das`, where DASROOT is
`$DASROOT` or the directory above the daslang binary's `bin/`/`build/`.  The
runner's per-file JSON mode (`--paths-from`) is used, files are split across
`-j` parallel lint processes, and the repository `.lint_config` (rules disabled
because the construct is the faithful spelling of C) is applied through
`DAS_LINT_CONFIG_PATH`.

    python3 scripts/lint_translated.py                       # every translation in latest
    python3 scripts/lint_translated.py --case 'doomgeneric*' --variant canonical
    python3 scripts/lint_translated.py .c2das-out/latest/wasm3-fib32-std -o /tmp/wasm3-lint.md
"""

from __future__ import annotations

import argparse
import collections
import concurrent.futures
import datetime
import fnmatch
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time

sys.path.insert(0, str(Path(__file__).resolve().parent))
from run_c2das_cases import ROOT, CaseFailure, find_daslang, git_head, latest_root  # noqa: E402

JSON_PREFIX = "##lint##\n"
# Translator arguments that carry a value which is a path or a per-run location, not a flag choice.
VALUE_ARGS = {"--output-dir", "--file"}


def find_dasroot(daslang: Path) -> Path:
    if os.environ.get("DASROOT"):
        return Path(os.environ["DASROOT"])
    parent = daslang.resolve().parent
    return parent.parent if parent.name in ("bin", "build") else parent


def daslang_version(daslang: Path, dasroot: Path) -> str:
    try:
        version = subprocess.run([str(daslang), "--version"], text=True, capture_output=True).stdout.strip()
    except OSError:
        version = "unknown"
    rev = subprocess.run(
        ["git", "-C", str(dasroot), "rev-parse", "--short=9", "HEAD"], text=True, capture_output=True
    ).stdout.strip()
    return f"{version.splitlines()[0] if version else 'unknown'}" + (f" ({rev})" if rev else "")


class Translation:
    def __init__(self, directory: Path) -> None:
        self.dir = directory
        manifest_path = directory / "TRANSLATION.json"
        manifest = json.loads(manifest_path.read_text()) if manifest_path.is_file() else {}
        self.case = manifest.get("case", directory.parent.name)
        self.variant = manifest.get("variant", directory.name)
        self.commit = manifest.get("commit", "?")
        command = manifest.get("command", [])
        args = command[command.index("--") + 1:] if "--" in command else command
        self.layout = "source" if "--module-layout" in args and "source" in args else "unity"
        flags: list[str] = []
        skip = False
        for arg in args:
            if skip:
                skip = False
                continue
            if arg in VALUE_ARGS:
                skip = True
                continue
            if arg == "--module-layout" or arg.startswith(("-I", "-std=", "/")) or arg in ("-w", "source"):
                continue
            flags.append(arg)
        self.flags = " ".join(flags)
        self.modules = sorted(directory.rglob("*.das"))
        self.fragments = sorted(directory.rglob("*.das.inc"))
        self.lines = sum(len(p.read_bytes().splitlines()) for p in self.modules + self.fragments)
        self.results: list[dict] = []

    @property
    def name(self) -> str:
        return f"{self.case}/{self.variant}"

    @property
    def issues(self) -> list[dict]:
        return [issue for result in self.results for issue in result.get("issues", [])]

    @property
    def failed(self) -> list[dict]:
        return [r for r in self.results if r.get("failed")]


def discover(inputs: list[Path]) -> list[Path]:
    found: list[Path] = []
    for item in inputs:
        if (item / "TRANSLATION.json").is_file():
            found.append(item)
            continue
        below = sorted(p.parent for p in item.rglob("TRANSLATION.json"))
        if below:
            found += below
        elif any(item.rglob("*.das")):
            found.append(item)
    return found


def lint_chunk(daslang: Path, main_das: Path, files: list[Path], env: dict[str, str]) -> list[dict]:
    with tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False) as handle:
        handle.write("".join(f"{f}\n" for f in files))
        paths_file = handle.name
    try:
        proc = subprocess.run(
            [str(daslang), str(main_das), "--", "--paths-from", paths_file, "--quiet"],
            cwd=ROOT, env=env, text=True, capture_output=True,
        )
    finally:
        os.unlink(paths_file)
    results = []
    for block in proc.stdout.split(JSON_PREFIX):
        block = block.strip()
        if block.startswith("{"):
            results.append(json.loads(block))
    seen = {r.get("file") for r in results}
    for f in files:
        if str(f) not in seen:
            message = (proc.stdout + proc.stderr).strip().splitlines()[-3:]
            results.append({"file": str(f), "failed": True, "issues": [],
                            "compile_errors": f"lint runner exit {proc.returncode}: " + " | ".join(message)})
    return results


def rel(path: str) -> str:
    try:
        return str(Path(path).resolve().relative_to(ROOT))
    except ValueError:
        return path


def short_name(path: str, translation: Translation) -> str:
    try:
        return str(Path(path).resolve().relative_to(translation.dir.resolve()))
    except ValueError:
        return rel(path)


def rule_table(issues: list[dict], name_of) -> list[str]:
    by_rule: dict[str, list[dict]] = collections.defaultdict(list)
    for issue in issues:
        by_rule[issue.get("code", "?")].append(issue)
    rows = ["| rule | count | example |", "|---|---:|---|"]
    for code, items in sorted(by_rule.items(), key=lambda kv: (-len(kv[1]), kv[0])):
        first = items[0]
        message = first.get("message", "").replace("|", "\\|").replace("\n", " ")
        if message.startswith(f"{code}: "):
            message = message[len(code) + 2:]
        rows.append(f"| {code} | {len(items)} | `{name_of(first)}:{first.get('line')}` {message} |")
    return rows


def write_report(path: Path, translations: list[Translation], meta: dict[str, str]) -> None:
    out = [
        "# Lint of translated daslang",
        "",
        "Generated by `python3 scripts/lint_translated.py`; overwritten on every run.  Each module",
        "file of each translation is linted by daslang's lint runner (`utils/lint/main.das`, paranoid,",
        "perf and style passes) with the repository `.lint_config` applied.  Findings in `.das.inc`",
        "fragments are reported by the module that includes them, under the fragment's name.",
        "",
        f"- date: {meta['date']}",
        f"- c2das commit: {meta['commit']}",
        f"- daslang: {meta['daslang']}",
        f"- translations: {len(translations)}; module files: {sum(len(t.modules) for t in translations)};"
        f" fragments: {sum(len(t.fragments) for t in translations)}; lines: {sum(t.lines for t in translations)}",
        f"- findings: {sum(len(t.issues) for t in translations)}; files that failed to lint:"
        f" {sum(len(t.failed) for t in translations)}; lint wall time: {meta['elapsed']}",
        "",
        "Layout is `unity` (one module) or `source` (`--module-layout source`, one module per C unit).",
        "Flags are the translator arguments other than paths, include dirs and `-std`.",
        "",
        "## Top rules across all translations",
        "",
    ]
    out += ["Counts sum over every translation, so a case translated in several variants counts once per variant.", ""]
    out += rule_table([i for t in translations for i in t.issues], lambda i: rel(i.get("file", "?")))
    canonical = [t for t in translations if t.variant == "canonical"]
    if canonical and len(canonical) != len(translations):
        out += ["", f"## Top rules across canonical variants only ({len(canonical)} translations)", ""]
        out += rule_table([i for t in canonical for i in t.issues], lambda i: rel(i.get("file", "?")))
    out += ["", "## Summary", "",
            "| case | variant | layout | flags | files | lines | findings | lint failures |",
            "|---|---|---|---|---:|---:|---:|---:|"]
    for t in translations:
        files = f"{len(t.modules)}" + (f" + {len(t.fragments)} inc" if t.fragments else "")
        out.append(f"| {t.case} | {t.variant} | {t.layout} | `{t.flags}` | {files} | {t.lines} |"
                   f" {len(t.issues)} | {len(t.failed)} |")
    out += ["", "## Per translation", ""]
    for t in sorted(translations, key=lambda t: (-len(t.issues), t.name)):
        if not t.issues and not t.failed:
            continue
        in_fragments = sum(1 for i in t.issues if str(i.get("file", "")).endswith(".das.inc"))
        out += [f"### {t.name}", "",
                f"{t.layout} layout, flags `{t.flags}`, translated at commit {t.commit}; "
                f"{len(t.modules)} module file(s), {len(t.fragments)} fragment(s), {t.lines} lines, "
                f"{len(t.issues)} finding(s)" + (f" ({in_fragments} in fragments)" if t.fragments else "") + ".", ""]
        for failure in t.failed:
            errors = (failure.get("compile_errors") or "").strip().replace("\n", " ")[:300]
            out.append(f"- lint failed on `{short_name(failure['file'], t)}`: {errors}")
        if t.failed:
            out.append("")
        if t.issues:
            out += rule_table(t.issues, lambda i, t=t: short_name(i.get("file", "?"), t)) + [""]
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(out).rstrip() + "\n")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("dirs", nargs="*", type=Path, help="generated dirs (default: every translation in latest_root())")
    parser.add_argument("-o", "--output", type=Path, default=ROOT / "docs/lint-translated.md")
    parser.add_argument("--case", action="append", default=[], help="fnmatch filter on case id (repeatable)")
    parser.add_argument("--variant", action="append", default=[], help="fnmatch filter on variant (repeatable)")
    parser.add_argument("-j", "--jobs", type=int, default=os.cpu_count() or 1, help="parallel lint processes")
    args = parser.parse_args()

    try:
        daslang = find_daslang()
    except CaseFailure as error:
        print(error, file=sys.stderr)
        return 1
    dasroot = find_dasroot(daslang)
    main_das = dasroot / "utils/lint/main.das"
    if not main_das.is_file():
        print(f"lint runner not found at {main_das}; set DASROOT", file=sys.stderr)
        return 1

    inputs = args.dirs or [latest_root()]
    translations = [Translation(d) for d in discover(inputs)]
    translations = [t for t in translations
                    if (not args.case or any(fnmatch.fnmatch(t.case, p) for p in args.case))
                    and (not args.variant or any(fnmatch.fnmatch(t.variant, p) for p in args.variant))]
    translations.sort(key=lambda t: t.name)
    if not translations:
        print("no translations found", file=sys.stderr)
        return 1

    env = dict(os.environ)
    if (ROOT / ".lint_config").is_file():
        env.setdefault("DAS_LINT_CONFIG_PATH", str(ROOT / ".lint_config"))
    # Largest files first, one file per job: the big unity modules dominate the wall time.
    jobs = sorted(((t, f) for t in translations for f in t.modules), key=lambda tf: -tf[1].stat().st_size)
    started = time.monotonic()
    with concurrent.futures.ThreadPoolExecutor(max_workers=max(1, args.jobs)) as pool:
        futures = {pool.submit(lint_chunk, daslang, main_das, [f.resolve()], env): t for t, f in jobs}
        for future in concurrent.futures.as_completed(futures):
            futures[future].results += future.result()
    elapsed = time.monotonic() - started

    meta = {
        "date": datetime.datetime.now().astimezone().isoformat(timespec="seconds"),
        "commit": git_head(),
        "daslang": daslang_version(daslang, dasroot),
        "elapsed": f"{elapsed:.1f}s with {args.jobs} job(s)",
    }
    write_report(args.output, translations, meta)
    total = sum(len(t.issues) for t in translations)
    failed = sum(len(t.failed) for t in translations)
    print(f"{len(translations)} translation(s), {total} finding(s), {failed} lint failure(s), "
          f"{elapsed:.1f}s -> {rel(str(args.output))}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
