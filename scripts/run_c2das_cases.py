#!/usr/bin/env python3
"""Canonical isolated C -> daScript executable-case runner for WSL/Linux."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
from typing import Any


ROOT = Path(__file__).resolve().parent.parent
CASE_FILE = ROOT / "tests/canonical/cases.json"


class CaseFailure(RuntimeError):
    pass


def run(command: list[str], *, cwd: Path, env: dict[str, str], label: str) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(command, cwd=cwd, env=env, text=True, capture_output=True)
    if result.returncode != 0:
        raise CaseFailure(
            f"{label} failed with exit {result.returncode}\n"
            f"command: {' '.join(command)}\nstdout:\n{result.stdout}\nstderr:\n{result.stderr}"
        )
    return result


def load_cases() -> list[dict[str, Any]]:
    document = json.loads(CASE_FILE.read_text(encoding="utf-8"))
    if document.get("schema_version") != 1 or not isinstance(document.get("cases"), list):
        raise CaseFailure("invalid canonical case manifest")
    identifiers: set[str] = set()
    for case in document["cases"]:
        identifier = case.get("id")
        if not isinstance(identifier, str) or identifier in identifiers:
            raise CaseFailure(f"invalid or duplicate case id: {identifier!r}")
        identifiers.add(identifier)
        for key in ("source_root", "translation_entry", "c_graph", "c_reference", "das_entrypoint", "expected"):
            if key not in case:
                raise CaseFailure(f"{identifier}: missing {key}")
        if "expected_exporter_failure" in case:
            failure = case["expected_exporter_failure"]
            if not isinstance(failure, dict) or not all(
                key in failure for key in ("phase", "signal", "trace")
            ):
                raise CaseFailure(f"{identifier}: invalid expected_exporter_failure")
            if case.get("status") != "known-red":
                raise CaseFailure(
                    f"{identifier}: exporter-failure contract must be known-red, never ready"
                )
    return document["cases"]


def remove_copied_das(root: Path, preserved: set[Path]) -> None:
    for generated in root.rglob("*.das"):
        if generated not in preserved:
            generated.unlink()


def copied_flags(flags: list[str], copied_root: Path) -> list[str]:
    resolved: list[str] = []
    for flag in flags:
        if flag.startswith("-I") and len(flag) > 2:
            resolved.append(f"-I{copied_root / flag[2:]}")
        else:
            resolved.append(flag)
    return resolved


def make_reference_main(case: dict[str, Any], destination: Path) -> Path:
    reference = case["c_reference"]
    if reference.get("return_type") != "int":
        raise CaseFailure(f"{case['id']}: only int C entrypoints are implemented in the initial runner")
    entrypoint = reference.get("entrypoint")
    if not isinstance(entrypoint, str):
        raise CaseFailure(f"{case['id']}: C reference entrypoint must be a string")
    wrapper = destination / "c2das_reference_main.c"
    wrapper.write_text(
        "/* Generated in the temporary case workspace. */\n"
        f"extern int {entrypoint}(void);\n"
        f"int main(void) {{ return {entrypoint}(); }}\n",
        encoding="utf-8",
    )
    return wrapper


def compare(case: dict[str, Any], label: str, result: subprocess.CompletedProcess[str], expected: dict[str, Any]) -> None:
    if result.returncode != expected["exit_code"] or result.stdout != expected["stdout"]:
        raise CaseFailure(
            f"{case['id']}: {label} diverged from declared oracle\n"
            f"expected exit={expected['exit_code']} stdout={expected['stdout']!r}\n"
            f"actual exit={result.returncode} stdout={result.stdout!r}\n"
            f"stderr:\n{result.stderr}"
        )


def run_rust_assertion(case: dict[str, Any], env: dict[str, str]) -> None:
    assertion = case.get("rust_assertion")
    if assertion is None:
        return
    if not isinstance(assertion, str) or "::" not in assertion:
        raise CaseFailure(f"{case['id']}: rust_assertion must be test-target::test-name")
    target, test_name = assertion.split("::", 1)
    run(
        [
            "cargo",
            "test",
            "-q",
            "-p",
            "c2dascript-transpile",
            "--test",
            target,
            test_name,
            "--",
            "--exact",
        ],
        cwd=ROOT,
        env=env,
        label="Rust AST/render assertion",
    )


def execute(case: dict[str, Any], dasroot: Path, keep: bool) -> None:
    source_root = ROOT / case["source_root"]
    entry = Path(case["translation_entry"])
    if entry.is_absolute() or ".." in entry.parts:
        raise CaseFailure(f"{case['id']}: translation entry must be source-root relative")
    if not (source_root / entry).is_file():
        raise CaseFailure(f"{case['id']}: missing C input {source_root / entry}")
    env = os.environ.copy()
    env["CARGO_TARGET_DIR"] = env.get(
        "C2DAS_CASE_CARGO_TARGET_DIR", "/root/.cache/c2das/canonical-cases"
    )
    if case["status"] == "negative":
        run_rust_assertion(case, env)
        print(f"PASS {case['id']}: exact TranslationError contract")
        return
    if "expected_exporter_failure" in case:
        run_rust_assertion(case, env)
        print(f"PASS {case['id']}: exact isolated exporter-failure contract")
        return
    if case.get("status") == "known-red":
        raise CaseFailure(
            f"{case['id']}: known-red case has no executable canonical contract"
        )

    daslang = dasroot / "bin/daslang"
    if not os.access(daslang, os.X_OK):
        raise CaseFailure(f"{case['id']}: daslang is not executable: {daslang}")

    work = Path(tempfile.mkdtemp(prefix=f"c2das-case-{case['id']}-"))
    try:
        copied_root = work / "input"
        shutil.copytree(source_root, copied_root)
        preserved = {copied_root / Path(path) for path in case.get("preserve_das", [])}
        if any(not path.is_file() for path in preserved):
            raise CaseFailure(f"{case['id']}: declared daScript wrapper is missing")
        remove_copied_das(copied_root, preserved)
        translated_c = copied_root / entry
        generated_dir = work / "generated"
        generated_das = generated_dir / entry.with_suffix(".das").name
        if generated_das.exists():
            raise CaseFailure(f"{case['id']}: copied generated output survived cleanup")

        run_rust_assertion(case, env)
        compiler = case["clang"].get("compiler", "clang-18")
        if shutil.which(compiler) is None:
            raise CaseFailure(f"{case['id']}: C compiler is unavailable: {compiler}")
        reference = work / "c-reference"
        clang_flags = copied_flags(case["clang"].get("flags", []), copied_root)
        reference_sources = case["c_reference"].get("sources")
        if reference_sources is None:
            wrapper = make_reference_main(case, work)
            c_sources = [translated_c, wrapper]
        else:
            c_sources = [copied_root / Path(path) for path in reference_sources]
            if any(not source.is_file() for source in c_sources):
                raise CaseFailure(f"{case['id']}: declared C reference source is missing")
        run(
            [compiler, *clang_flags, *(str(source) for source in c_sources), "-o", str(reference)],
            cwd=work,
            env=env,
            label="C reference compilation",
        )
        expected = case["expected"]
        reference_result = subprocess.run([str(reference)], cwd=work, env=env, text=True, capture_output=True)
        compare(case, "C reference", reference_result, expected)

        run(
            [
                "cargo",
                "run",
                "-q",
                "-p",
                "c2dascript-transpile",
                "--",
                "--strict",
                "--output-dir",
                str(generated_dir),
                "--file",
                str(translated_c),
                *clang_flags,
            ],
            cwd=ROOT,
            env=env,
            label="c2das transpilation",
        )
        if not generated_das.is_file():
            raise CaseFailure(f"{case['id']}: transpiler produced no fresh output at {generated_das}")

        da_result = subprocess.run(
            [
                str(daslang),
                str(
                    copied_root / Path(case["das_program"])
                    if "das_program" in case
                    else generated_das
                ),
                "-main",
                case["das_entrypoint"],
            ],
            cwd=work,
            env=env,
            text=True,
            capture_output=True,
        )
        compare(case, "daScript", da_result, expected)
        print(f"PASS {case['id']}: C reference == fresh daScript")
    finally:
        if keep:
            print(f"kept temporary workspace: {work}")
        else:
            shutil.rmtree(work)


def main() -> int:
    parser = argparse.ArgumentParser()
    selection = parser.add_mutually_exclusive_group(required=True)
    selection.add_argument("--case")
    selection.add_argument("--all-ready", action="store_true")
    selection.add_argument("--all-exporter-failures", action="store_true")
    selection.add_argument("--list", action="store_true")
    parser.add_argument("--keep-workdir", action="store_true")
    args = parser.parse_args()
    cases = load_cases()
    if args.list:
        for case in cases:
            print(f"{case['status']:10} {case['id']}")
        return 0
    if args.case:
        selected = [case for case in cases if case["id"] == args.case]
    elif args.all_ready:
        selected = [
            case
            for case in cases
            if case["status"] == "ready" and "expected_exporter_failure" not in case
        ]
    else:
        selected = [
            case
            for case in cases
            if case["status"] == "known-red" and "expected_exporter_failure" in case
        ]
    if not selected:
        if args.all_exporter_failures:
            print("PASS: no isolated exporter-failure cases are currently registered")
            return 0
        print("no canonical cases selected", file=sys.stderr)
        return 2
    dasroot = Path(os.environ.get("DASROOT", "/root/daScript"))
    try:
        for case in selected:
            execute(case, dasroot, args.keep_workdir)
    except CaseFailure as error:
        print(f"FAIL {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
