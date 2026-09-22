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
# `--libc` policies the translator accepts. A case that omits the key is
# translated with the translator's own default, which is `nostd`.
LIBC_MODES = ("nostd", "std", "ffi", "all")


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


def find_daslang() -> Path:
    """Locate the daslang binary without assuming any machine-specific layout.

    Order: $DASLANG (binary), $DASROOT/bin/daslang, $DASROOT/build/daslang,
    the pinned toolchain at <repo>/tmp/daslang-toolchain/bin/daslang (the one the
    Claude Code MCP/LSP servers use), `daslang` on PATH, then ~/daScript/{bin,build}/daslang.
    """
    candidates: list[Path] = []
    if os.environ.get("DASLANG"):
        candidates.append(Path(os.environ["DASLANG"]))
    if os.environ.get("DASROOT"):
        root = Path(os.environ["DASROOT"])
        candidates += [root / "bin/daslang", root / "build/daslang"]
    candidates.append(Path(__file__).resolve().parent.parent / "tmp/daslang-toolchain/bin/daslang")
    on_path = shutil.which("daslang")
    if on_path:
        candidates.append(Path(on_path))
    home = Path.home() / "daScript"
    candidates += [home / "bin/daslang", home / "build/daslang"]
    for candidate in candidates:
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return candidate
    raise CaseFailure(
        "daslang not found; set DASLANG=/path/to/daslang or DASROOT=/path/to/daScript, "
        "or put daslang on PATH (tried: " + ", ".join(map(str, candidates)) + ")"
    )


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
        libc = case.get("libc")
        if libc is not None and libc not in LIBC_MODES:
            raise CaseFailure(f"{identifier}: unknown libc mode {libc!r}")
        das_options = case.get("das_options", [])
        if not isinstance(das_options, list) or not all(
            isinstance(option, str) and option.strip() for option in das_options
        ):
            raise CaseFailure(f"{identifier}: das_options must be a list of option strings")
        translator_flags = case.get("translator_flags", [])
        if not isinstance(translator_flags, list) or not all(
            isinstance(flag, str) and flag.strip() for flag in translator_flags
        ):
            raise CaseFailure(f"{identifier}: translator_flags must be a list of flag strings")
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


def assert_no_stale_das(case: dict[str, Any], root: Path, preserved: set[Path]) -> None:
    """Prove the pre-transpile cleanup really emptied the copied fixture.

    Every `.das` under the copy must be a declared fixture-owned wrapper; any
    survivor could otherwise satisfy a `require` and hide a missing fresh
    translation.
    """
    stale = sorted(path for path in root.rglob("*.das") if path not in preserved)
    if stale:
        raise CaseFailure(
            f"{case['id']}: copied daScript modules survived cleanup: "
            + ", ".join(str(path) for path in stale)
        )


def stage_generated_das(
    case: dict[str, Any], generated_dir: Path, destination: Path, preserved: set[Path]
) -> list[Path]:
    """Place the fresh modules next to the fixture-owned `das_program`.

    daslang resolves `require <module>` against the entry file's own directory,
    so a wrapper such as `src/plmpeg_entry.das` can only see `all` if `all.das`
    sits beside it.  This runs *after* `assert_no_stale_das`, so nothing but the
    just-produced output can ever end up there.
    """
    staged: list[Path] = []
    for generated in sorted(generated_dir.rglob("*.das")):
        target = destination / generated.relative_to(generated_dir)
        if target in preserved:
            raise CaseFailure(
                f"{case['id']}: generated {generated.name} collides with the fixture-owned wrapper {target}"
            )
        if target.exists():
            raise CaseFailure(f"{case['id']}: stale daScript module reappeared at {target}")
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(generated, target)
        staged.append(target)
    if not staged:
        raise CaseFailure(f"{case['id']}: transpiler produced no module to stage in {destination}")
    return staged


def libc_flags(case: dict[str, Any]) -> list[str]:
    """The translator policy flags this case is translated under.

    `libc`: the `--libc` policy; a case without the key is translated exactly
    as before the flag existed, the translator's own default, `nostd`.

    `das_options`: daslang `options` the translator writes into the module
    header (`--das-option`), one per entry, e.g. `"stack = 16777216"` for a
    program whose interpreter-mode call depth exceeds daslang's default
    simulated stack.  It is a per-program resource setting declared by the
    case, the way a linker script sets a C program's stack; nothing edits
    generated text.

    `translator_flags`: translator switches passed verbatim, for a case whose
    build configuration differs from the translator's defaults, e.g.
    `"--unsafe-deref"` on the corpus cases (see
    `docs/followups/hot_path_levers.md`).  They come last so a case can
    override a policy the earlier keys set.
    """
    mode = case.get("libc")
    flags = ["--libc", mode] if mode else []
    for option in case.get("das_options", []):
        flags += ["--das-option", option]
    flags += list(case.get("translator_flags", []))
    return flags


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


def run_negative_translation(case: dict[str, Any], c_input: Path, env: dict[str, str]) -> None:
    """Prove a negative case directly: strict translation must fail with the
    declared diagnostic and must not write any output file."""
    expected = case.get("expected_error")
    if not isinstance(expected, dict) or not isinstance(expected.get("cause"), str):
        raise CaseFailure(f"{case['id']}: negative case needs expected_error.cause or a rust_assertion")
    work = Path(tempfile.mkdtemp(prefix=f"c2das-negative-{case['id']}-"))
    try:
        generated_dir = work / "generated"
        flags = copied_flags(case["clang"].get("flags", []), c_input.parent)
        result = subprocess.run(
            [
                "cargo", "run", "-q", "-p", "c2dascript-transpile", "--",
                "--strict", *libc_flags(case), "--output-dir", str(generated_dir),
                "--file", str(c_input), *flags,
            ],
            cwd=ROOT, env=env, text=True, capture_output=True,
        )
        if result.returncode == 0:
            raise CaseFailure(f"{case['id']}: strict translation unexpectedly succeeded\nstderr:\n{result.stderr}")
        if expected["cause"] not in result.stderr:
            raise CaseFailure(
                f"{case['id']}: diagnostic does not mention the declared cause\n"
                f"expected cause: {expected['cause']!r}\nstderr:\n{result.stderr}"
            )
        location = expected.get("location")
        if isinstance(location, str) and location not in result.stderr:
            raise CaseFailure(f"{case['id']}: diagnostic does not name {location!r}\nstderr:\n{result.stderr}")
        written = list(generated_dir.glob("*.das")) if generated_dir.exists() else []
        if written:
            raise CaseFailure(f"{case['id']}: failed translation still wrote {written}")
    finally:
        shutil.rmtree(work, ignore_errors=True)


def execute(case: dict[str, Any], daslang: Path, keep: bool) -> None:
    source_root = ROOT / case["source_root"]
    entry = Path(case["translation_entry"])
    if entry.is_absolute() or ".." in entry.parts:
        raise CaseFailure(f"{case['id']}: translation entry must be source-root relative")
    if not (source_root / entry).is_file():
        raise CaseFailure(f"{case['id']}: missing C input {source_root / entry}")
    env = os.environ.copy()
    env["CARGO_TARGET_DIR"] = env.get(
        "C2DAS_CASE_CARGO_TARGET_DIR", str(ROOT / "target")
    )
    if case["status"] == "negative":
        if case.get("rust_assertion") is not None:
            run_rust_assertion(case, env)
        else:
            run_negative_translation(case, source_root / entry, env)
        print(f"PASS {case['id']}: exact TranslationError contract")
        return
    if "expected_exporter_failure" in case:
        run_rust_assertion(case, env)
        print(f"PASS {case['id']}: exact isolated exporter-failure contract")
        return

    work = Path(tempfile.mkdtemp(prefix=f"c2das-case-{case['id']}-"))
    try:
        copied_root = work / "input"
        shutil.copytree(source_root, copied_root)
        preserved = {copied_root / Path(path) for path in case.get("preserve_das", [])}
        if any(not path.is_file() for path in preserved):
            raise CaseFailure(f"{case['id']}: declared daScript wrapper is missing")
        remove_copied_das(copied_root, preserved)
        assert_no_stale_das(case, copied_root, preserved)
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
        if reference_sources is None and case["c_reference"].get("entrypoint") == "main":
            # The fixture defines its own C main; it is the reference program.
            c_sources = [translated_c]
        elif reference_sources is None:
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
        # `program_args`: fixture-root-relative paths handed to both programs
        # (a fixture file an entry reads at run time instead of embedding it).
        program_args = [str(copied_root / Path(arg)) for arg in case.get("program_args", [])]
        if any(".." in Path(arg).parts or Path(arg).is_absolute() for arg in case.get("program_args", [])):
            raise CaseFailure(f"{case['id']}: program_args must be fixture-root relative")
        reference_result = subprocess.run(
            [str(reference), *program_args], cwd=work, env=env, text=True, capture_output=True
        )
        if expected.get("oracle") == "c-reference":
            # Differential mode: the C program's observable behaviour is the
            # oracle, whatever it is; the daScript run must reproduce it.
            expected = {"exit_code": reference_result.returncode, "stdout": reference_result.stdout}
            print(
                f"     {case['id']}: C reference exit={expected['exit_code']} stdout={expected['stdout']!r}"
            )
        else:
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
                *libc_flags(case),
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

        if "das_program" in case:
            das_program = copied_root / Path(case["das_program"])
            if das_program not in preserved:
                raise CaseFailure(
                    f"{case['id']}: das_program must also be declared in preserve_das"
                )
            stage_generated_das(case, generated_dir, das_program.parent, preserved)
            das_entry = das_program
        else:
            das_entry = generated_das

        # `--` is what separates the launcher's own command line from the
        # program's.  A `--libc std` module turns that command line into a C
        # `argv`, so the separator has to be there even when the program takes
        # no arguments: without it the launcher's `-main <entry>` would reach
        # the C program as `argv[1]` and `argv[2]`, and `argc` would not match
        # the native program's.
        separated = case.get("libc") == "std" or bool(program_args)
        da_result = subprocess.run(
            [
                str(daslang),
                str(das_entry),
                "-main",
                case["das_entrypoint"],
                *(["--", *program_args] if separated else []),
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
    selection.add_argument(
        "--all-known-red",
        action="store_true",
        help="survey every known-red case; report PASS/FAIL per case without stopping",
    )
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
    elif args.all_known_red:
        selected = [
            case
            for case in cases
            if case["status"] == "known-red" and "expected_exporter_failure" not in case
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
    try:
        daslang = find_daslang()
    except CaseFailure as error:
        print(f"FAIL {error}", file=sys.stderr)
        return 1
    if args.all_known_red:
        # Survey mode: known-red cases are expected to fail; report each one
        # so that newly passing cases can be promoted to `ready`.
        passed = 0
        for case in selected:
            try:
                execute(case, daslang, args.keep_workdir)
                passed += 1
            except CaseFailure as error:
                first_line = str(error).splitlines()[0] if str(error) else "unknown failure"
                print(f"FAIL {case['id']}: {first_line}")
        print(f"known-red survey: {passed}/{len(selected)} now pass")
        return 0
    try:
        for case in selected:
            execute(case, daslang, args.keep_workdir)
    except CaseFailure as error:
        print(f"FAIL {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
