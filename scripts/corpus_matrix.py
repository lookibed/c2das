#!/usr/bin/env python3
"""Corpus matrix: every corpus canonical case, in C and in every daslang run mode.

Two commands, two committed documents:

  converge  -> docs/corpus-convergence.md
      For each case with a `corpus` block in tests/canonical/cases.json: build
      the C reference program, translate the C graph afresh, then run the
      fixture-owned daslang entry in every run mode and require its stdout to be
      byte-identical to the C reference stdout (which itself must equal the pinned
      `expected.stdout`).  The stdout carries one line per decoded frame, so this is
      a per-frame comparison.  `--check` regenerates the document in memory and
      fails when it differs from the committed one (the preflight gate).

  bench     -> docs/corpus-benchmark.md
      Same fresh translation, but the benchmark entries (`corpus.bench_c_entry`,
      `corpus.bench_das_entry`), which print the per-frame hashes plus the time
      spent inside the decode loop.  Every variant is run once to warm up and then
      `--runs` times (default 5); a variant's hashes must equal the C -O2 build's on
      every run, otherwise its row is a failure, never a number.

daslang run modes ("interop" in the project's wording is the interpreter):

  interp   daslang entry.das                          interpreter
  jit      daslang -jit entry.das                     LLVM JIT at load time
  aot      daslang -aot <module>.das <module>.cpp     C++ generated ahead of time,
           per module, compiled with the toolchain's own AOT flags, linked with
           scripts/corpus/aot_host.c against the daslang runtime; the host
           compiles the script with policies.aot + fail_on_no_aot.  The graph is
           translated a second time with `--public-module --das-option
           disable_auto_inline` (see transpile_for_aot): without the module
           declaration daslang emits no AOT body for an anonymous module's
           unexported functions, and without the option daslang's optimizer
           splices callee locals into jump-rendered bodies and the C++ does
           not compile.  The entry gets the same option prepended to a copy.
  exe      daslang -exe entry.das -output <bin>       LLVM-compiled standalone
           executable linked against the daslang runtime shared library

The C side is the same graph compiled with the case's clang flags, at -O2 and -O0
for the benchmark and with the case's flags alone for the reference.

A case may carry `program_args` (fixture-root-relative paths): every program, C or
daslang in any mode, receives them as its command-line arguments, which is how the
`*_file_*` entries read a fixture file at run time instead of embedding it (see
with_args for the per-launcher spelling).

A case may carry `"libc": "std"`: the translator then replaces the libc calls of the
translation unit (translator/libc.rs), the unit is expected to contain the C `main`,
and the translated module itself is the program — no `das_program`, no
`bench_das_entry`; `corpus.bench_translation_entry` names the C amalgamation (graph +
C benchmark entry) the benchmark translates instead.  The C builds keep using
`c_reference.sources` and `corpus.bench_c_entry` as before, so the same C entry is the
reference and the translation input.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import platform
import re
import shutil
import statistics
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).resolve().parent))
import run_c2das_cases as runner  # noqa: E402

ROOT = runner.ROOT
CONVERGENCE_DOC = ROOT / "docs/corpus-convergence.md"
BENCHMARK_DOC = ROOT / "docs/corpus-benchmark.md"
AOT_HOST = ROOT / "scripts/corpus/aot_host.cpp"
MODES = ("interp", "jit", "aot", "exe")
# One line per checked item: `frame[i]=<hash>` for the decoders, `fib[n]=<value>`
# for a program that produces numbered results; any `<name>[<index>]=<int>`.
FRAME_LINE = re.compile(r"^[a-z_]+\[(\d+)\]=(-?\d+)$")
KEY_LINE = re.compile(r"^([a-z_]+)=(-?\d+)$")
# Mirrors the flags daScript's own build applies to its AOT stubs
# (CMakeFiles/libDaScriptAot.dir); used when the toolchain has no
# build/compile_commands.json to read them from.
AOT_FALLBACK_FLAGS = [
    "-std=gnu++17", "-O3", "-fno-rtti", "-fwrapv", "-fno-strict-aliasing",
    "-Wno-invalid-offsetof", "-DDAS_ENABLE_DYN_INCLUDES=1", "-DDAS_FUSION=2",
    "-DDAS_NO_ASSERTIONS", "-DSIZE_OF_VOID_P=8", "-DNDEBUG=1",
]


class MatrixFailure(RuntimeError):
    pass


# ----------------------------------------------------------------------------
# environment facts
# ----------------------------------------------------------------------------

def sh(command: list[str], *, cwd: Path | None = None, env: dict[str, str] | None = None,
       label: str = "") -> subprocess.CompletedProcess[str]:
    result = subprocess.run(command, cwd=cwd, env=env, text=True, capture_output=True)
    if result.returncode != 0:
        raise MatrixFailure(
            f"{label or command[0]} failed with exit {result.returncode}\n"
            f"command: {' '.join(map(str, command))}\nstdout:\n{result.stdout}\nstderr:\n{result.stderr}"
        )
    return result


def first_line(command: list[str]) -> str:
    try:
        out = subprocess.run(command, text=True, capture_output=True, timeout=30)
    except (OSError, subprocess.TimeoutExpired):
        return "unavailable"
    text = (out.stdout or out.stderr).strip()
    return text.splitlines()[0] if text else "unavailable"


def cpu_model() -> str:
    try:
        for line in Path("/proc/cpuinfo").read_text(encoding="utf-8").splitlines():
            if line.startswith("model name"):
                return line.split(":", 1)[1].strip()
    except OSError:
        pass
    return platform.processor() or "unknown"


def git_head() -> str:
    try:
        return sh(["git", "rev-parse", "--short=9", "HEAD"], cwd=ROOT).stdout.strip()
    except MatrixFailure:
        return "unknown"


def environment_facts(daslang: Path) -> dict[str, str]:
    das_root = daslang.parent.parent
    return {
        "date": dt.date.today().isoformat(),
        "commit": git_head(),
        "cpu": cpu_model(),
        "os": first_line(["bash", "-c", ". /etc/os-release && echo \"$PRETTY_NAME\""]),
        "kernel": platform.release(),
        "daslang": f"{first_line([str(daslang), '--version'])} ({daslang})",
        "das_root": str(das_root),
        "clang": first_line(["clang-18", "--version"]),
    }


# ----------------------------------------------------------------------------
# workspace: fresh translation exactly as the canonical runner stages it
# ----------------------------------------------------------------------------

class Prepared:
    def __init__(self, case: dict[str, Any], work: Path, daslang: Path, env: dict[str, str]) -> None:
        self.case = case
        self.work = work
        self.daslang = daslang
        self.env = env
        self.copied_root = work / "input"
        # A nostd case runs a fixture-owned daslang entry (`das_program`) beside
        # the translated graph; a std case's program is the translated graph
        # itself, whose C `main` the translator lowers (see `translate`).
        self.libc = case.get("libc", "nostd")
        self.das_program = (
            self.copied_root / Path(case["das_program"]) if "das_program" in case else None
        )
        self.translation_entry = self.copied_root / Path(case["translation_entry"])
        self.program: Path | None = None
        self.flags = runner.copied_flags(case["clang"].get("flags", []), self.copied_root)
        self.compiler = case["clang"].get("compiler", "clang-18")
        self.staged: list[Path] = []
        self.source_root = ROOT / case["source_root"]
        # `program_args`: fixture-root-relative paths every program gets as its
        # arguments (an entry that reads a fixture file at run time)
        for arg in case.get("program_args", []):
            if Path(arg).is_absolute() or ".." in Path(arg).parts:
                raise MatrixFailure(f"{case['id']}: program_args must be fixture-root relative")
        self.args = [str(self.copied_root / Path(arg)) for arg in case.get("program_args", [])]

    @property
    def corpus(self) -> dict[str, Any]:
        return self.case["corpus"]

    @property
    def bench_das(self) -> Path | None:
        """The fixture-owned daslang benchmark entry (nostd cases)."""
        if "bench_das_entry" not in self.corpus:
            return None
        return self.copied_root / Path(self.corpus["bench_das_entry"])

    @property
    def bench_translation_entry(self) -> Path | None:
        """The C graph + C benchmark entry to translate as one module (std cases)."""
        if "bench_translation_entry" not in self.corpus:
            return None
        return self.copied_root / Path(self.corpus["bench_translation_entry"])

    @property
    def bench_c(self) -> Path:
        return self.copied_root / Path(self.corpus["bench_c_entry"])

    def c_sources(self, entry: Path) -> list[Path]:
        sources = [self.copied_root / Path(p) for p in self.case["c_reference"]["sources"]]
        # the graph without its canonical entry, plus the requested entry
        graph = [s for s in sources if s.name != Path(self.case["c_reference"]["sources"][-1]).name]
        return graph + [entry]

    def libc_flags(self) -> list[str]:
        """`--libc` and `--das-option` exactly as the canonical runner passes them."""
        return runner.libc_flags(self.case)

    def translate(self, c_entry: Path, out_dir: Path, extra: list[str] | None = None) -> Path:
        """Strict translation of one C translation unit; returns the module it wrote."""
        sh(
            ["cargo", "run", "-q", "-p", "c2dascript-transpile", "--", "--strict", *(extra or []),
             *self.libc_flags(), "--output-dir", str(out_dir), "--file", str(c_entry), *self.flags],
            cwd=ROOT, env=self.env, label=f"c2das transpilation of {c_entry.name}",
        )
        module = out_dir / c_entry.with_suffix(".das").name
        if not module.is_file():
            raise MatrixFailure(f"{self.case['id']}: transpiler produced no fresh output for {c_entry.name}")
        return module


def prepare(case: dict[str, Any], daslang: Path) -> Prepared:
    if "corpus" not in case:
        raise MatrixFailure(f"{case['id']}: not a corpus case (no corpus block)")
    env = os.environ.copy()
    env["CARGO_TARGET_DIR"] = env.get("C2DAS_CASE_CARGO_TARGET_DIR", str(ROOT / "target"))
    work = Path(tempfile.mkdtemp(prefix=f"c2das-matrix-{case['id']}-"))
    prepared = Prepared(case, work, daslang, env)
    shutil.copytree(prepared.source_root, prepared.copied_root)
    preserved = {prepared.copied_root / Path(p) for p in case.get("preserve_das", [])}
    for wrapper in (prepared.das_program, prepared.bench_das):
        if wrapper is not None and wrapper not in preserved:
            raise MatrixFailure(f"{case['id']}: {wrapper.name} must be listed in preserve_das")
    if any(not p.is_file() for p in preserved):
        raise MatrixFailure(f"{case['id']}: a declared daScript wrapper is missing")
    runner.remove_copied_das(prepared.copied_root, preserved)
    runner.assert_no_stale_das(case, prepared.copied_root, preserved)
    module = prepared.translate(prepared.translation_entry, work / "generated")
    if prepared.das_program is not None:
        prepared.staged = runner.stage_generated_das(
            case, module.parent, prepared.das_program.parent, preserved
        )
        prepared.program = prepared.das_program
    else:
        prepared.staged = [module]
        prepared.program = module
    return prepared


# ----------------------------------------------------------------------------
# builds
# ----------------------------------------------------------------------------

def build_c(p: Prepared, entry: Path, opt: str | None, name: str) -> list[str]:
    binary = p.work / name
    flags = list(p.flags) + ([opt] if opt else [])
    sh([p.compiler, *flags, *map(str, p.c_sources(entry)), "-o", str(binary)],
       cwd=p.work, env=p.env, label=f"C build {name}")
    return [str(binary)]


def build_exe(p: Prepared, entry: Path, name: str) -> list[str]:
    output = p.work / name
    sh([str(p.daslang), "-exe", str(entry), "-output", str(output)], cwd=p.work, env=p.env,
       label="daslang -exe")
    binary = output.with_suffix(".exe")
    if not binary.is_file():
        raise MatrixFailure(f"daslang -exe produced no {binary}")
    return [str(binary)]


def aot_compile_flags(das_root: Path) -> list[str]:
    """The -std/-D/-I flags daScript compiled its own AOT stubs with, else the mirror."""
    db = das_root / "build/compile_commands.json"
    try:
        entries = json.loads(db.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        entries = []
    for entry in entries:
        if "_aot_generated" not in entry.get("file", ""):
            continue
        tokens = entry["command"].split()
        keep = [t for t in tokens if t.startswith(("-D", "-I", "-std=", "-f", "-O", "-Wno-invalid-offsetof"))]
        keep = [t for t in keep if not t.startswith("-fPIC")]
        if keep:
            return keep
    return AOT_FALLBACK_FLAGS + [f"-I{das_root / 'include'}", f"-I{das_root / '3rdparty/fmt/include'}",
                                 f"-I{das_root / 'build/include'}"]


# A graph module that a separate entry `require`s must be a named public module
# for daslang to emit AOT bodies for its unexported functions.  A module that is
# the program itself (a `--libc std` translation carrying `main`) must stay
# anonymous: declared public, its exported `main` no longer AOT-links
# ("entry 'main' is not AOT-linked" from the host, verified 2026-09-21).
AOT_GRAPH_FLAGS = ["--public-module", "--das-option", "disable_auto_inline"]
AOT_PROGRAM_FLAGS = ["--das-option", "disable_auto_inline"]
AOT_ENTRY_OPTIONS = ["options disable_auto_inline\n"]


def transpile_for_aot(p: Prepared, c_entry: Path, generated_dir: Path, flags: list[str]) -> list[Path]:
    """Translate a C translation unit again, with the module header an AOT build needs.

    The translator writes the header itself (`--public-module`, `--das-option`);
    nothing edits generated text.  Two things differ from the plain translation:

    * `module <name> public`: daslang emits AOT bodies for a module's functions
      only when the module is a named public one; an anonymous module keeps
      nothing that is not exported or reached.
    * `options disable_auto_inline`: daslang's optimizer splices small
      same-module callees into their callers and declares the callee's locals
      at the call site (`ast_inline.cpp`, `_inl*` temporaries).  In a
      jump-rendered body that puts an initialised declaration between a `goto`
      and its label, which C++ rejects; the C++ compiler inlines those calls
      itself, so the AOT build loses nothing by leaving them as calls.

    Everything else is byte-identical to the translation the other modes run,
    because the translator is deterministic over the same C input and flags.
    """
    p.translate(c_entry, generated_dir, flags)
    modules = sorted(generated_dir.rglob("*.das"))
    if not modules:
        raise MatrixFailure(f"{p.case['id']}: AOT translation produced no module")
    return modules


def build_aot(p: Prepared, entry: Path, name: str, c_entry: Path | None) -> list[str]:
    """`c_entry` is the C unit whose translation *is* the program (std cases);
    `None` means `entry` is a fixture-owned daslang entry over the graph."""
    das_root = p.daslang.parent.parent
    aot_dir = p.work / name
    aot_dir.mkdir()
    if c_entry is not None:
        # the program is the translated C unit; its header already carries the
        # AOT options, so there is nothing to prepend
        modules: list[Path] = []
        entry_copy = transpile_for_aot(p, c_entry, aot_dir / "generated", AOT_PROGRAM_FLAGS)[0]
        shutil.copyfile(entry_copy, aot_dir / entry_copy.name)
        entry_copy = aot_dir / entry_copy.name
    else:
        # the AOT translation of the graph, plus the fixture-owned entry beside
        # it so `require <module>` resolves against these modules, never the
        # staged ones; the entry is fixture source, so its one AOT option is
        # prepended to a copy rather than edited in place
        modules = transpile_for_aot(p, p.translation_entry, aot_dir / "generated", AOT_GRAPH_FLAGS)
        entry_copy = aot_dir / entry.name
        entry_text = entry.read_text(encoding="utf-8")
        entry_copy.write_text("".join(AOT_ENTRY_OPTIONS) + entry_text, encoding="utf-8")
        for module in modules:
            shutil.copyfile(module, aot_dir / module.name)
        modules = [aot_dir / module.name for module in modules]
    objects: list[str] = []
    flags = aot_compile_flags(das_root)
    for script in modules + [entry_copy]:
        cpp = aot_dir / f"{script.name}.cpp"
        sh([str(p.daslang), "-aot", str(script), str(cpp)], cwd=aot_dir, env=p.env, label=f"daslang -aot {script.name}")
        obj = aot_dir / f"{script.name}.o"
        sh(["clang++-18", *flags, "-c", str(cpp), "-o", str(obj)], cwd=aot_dir, env=p.env, label=f"AOT C++ {script.name}")
        objects.append(str(obj))
    host_obj = aot_dir / "aot_host.o"
    sh(["clang++-18", *flags, "-c", str(AOT_HOST), "-o", str(host_obj)], cwd=aot_dir, env=p.env, label="AOT host")
    binary = aot_dir / "aot_host"
    lib = das_root / "lib"
    sh(["clang++-18", str(host_obj), *objects, f"-L{lib}", "-llibDaScriptDyn", "-llibDaScriptDyn_runtime",
        f"-Wl,-rpath,{lib}", "-o", str(binary)], cwd=aot_dir, env=p.env, label="AOT link")
    return [str(binary), str(das_root), str(entry_copy), "main"]


def build_mode(p: Prepared, mode: str, entry: Path, name: str, c_entry: Path | None = None) -> list[str]:
    if mode == "interp":
        return [str(p.daslang), str(entry)]
    if mode == "jit":
        return [str(p.daslang), "-jit", str(entry)]
    if mode == "exe":
        return build_exe(p, entry, f"{name}_exe")
    if mode == "aot":
        return build_aot(p, entry, f"{name}_aot", c_entry)
    raise MatrixFailure(f"unknown mode {mode}")


def with_args(command: list[str], mode: str, args: list[str]) -> list[str]:
    """The program's arguments, spelled the way each launcher passes them on.

    `daslang` (interpreter and -jit) and the AOT host take script arguments
    after `--`; the -exe binary is the program itself, so its arguments are
    plain trailing ones.  All four reach the script's
    get_command_line_arguments() with the argument last, which is what the file
    entries rely on, and all four give a `--libc std` module the same C `argv`:
    the separator is what tells its `main` wrapper where the launcher's own
    command line ends.
    """
    if not args:
        return command
    if mode == "exe":
        return [*command, *args]
    return [*command, "--", *args]


def describe_mode(mode: str, entry_name: str) -> str:
    return {
        "interp": f"`daslang {entry_name}`",
        "jit": f"`daslang -jit {entry_name}`",
        "aot": f"`daslang -aot` per module + `aot_host` (policies.aot, fail_on_no_aot)",
        "exe": f"`daslang -exe {entry_name}` → standalone executable",
    }[mode]


# ----------------------------------------------------------------------------
# runs
# ----------------------------------------------------------------------------

class Run:
    def __init__(self, result: subprocess.CompletedProcess[str], wall_ms: float) -> None:
        self.result = result
        self.wall_ms = wall_ms
        self.frames: list[tuple[int, int]] = []
        self.values: dict[str, int] = {}
        # `daslang -jit` writes its own progress lines ("[I] LLVM JIT: ...") to
        # stdout, in front of the program's output; they are the JIT's log, not
        # the program's, so the comparison sees the program lines only.
        self.log_lines = [line for line in result.stdout.splitlines() if line.startswith("[I] ")]
        self.program_stdout = "".join(
            line + "\n" for line in result.stdout.splitlines() if not line.startswith("[I] ")
        )
        for line in self.program_stdout.splitlines():
            frame = FRAME_LINE.match(line)
            if frame:
                self.frames.append((int(frame.group(1)), int(frame.group(2))))
                continue
            key = KEY_LINE.match(line)
            if key:
                self.values[key.group(1)] = int(key.group(2))

    @property
    def stdout_lines(self) -> list[str]:
        return self.program_stdout.splitlines()


def run_once(command: list[str], cwd: Path, env: dict[str, str]) -> Run:
    start = time.perf_counter()
    result = subprocess.run(command, cwd=cwd, env=env, text=True, capture_output=True)
    return Run(result, (time.perf_counter() - start) * 1000.0)


def median(values: list[float]) -> float:
    return statistics.median(values)


# ----------------------------------------------------------------------------
# converge
# ----------------------------------------------------------------------------

def converge_case(case: dict[str, Any], daslang: Path, keep: bool) -> dict[str, Any]:
    p = prepare(case, daslang)
    try:
        entry = p.program
        c_entry = None if p.das_program is not None else p.translation_entry
        reference_cmd = build_c(p, p.copied_root / Path(case["c_reference"]["sources"][-1]), None, "c_reference")
        reference = run_once([*reference_cmd, *p.args], p.work, p.env)
        expected = case["expected"]
        if reference.result.returncode != expected["exit_code"] or reference.result.stdout != expected["stdout"]:
            raise MatrixFailure(
                f"{case['id']}: C reference diverged from the pinned oracle\n"
                f"expected exit={expected['exit_code']} stdout={expected['stdout']!r}\n"
                f"actual exit={reference.result.returncode} stdout={reference.result.stdout!r}\n"
                f"stderr:\n{reference.result.stderr}"
            )
        rows: list[dict[str, Any]] = []
        for mode in MODES:
            row: dict[str, Any] = {"mode": mode, "build": describe_mode(mode, entry.name)}
            try:
                cmd = with_args(build_mode(p, mode, entry, "canonical", c_entry), mode, p.args)
                run = run_once(cmd, p.work, p.env)
                identical = run.program_stdout == reference.program_stdout
                row["exit"] = run.result.returncode
                row["identical"] = identical and run.result.returncode == reference.result.returncode
                row["lines"] = len(run.stdout_lines)
                if run.log_lines:
                    row["detail"] = f"{len(run.log_lines)} `[I]` JIT log lines on stdout excluded"
                if not row["identical"]:
                    row["detail"] = (
                        f"stdout differs" if not identical else f"exit {run.result.returncode} != {reference.result.returncode}"
                    )
                    row["stdout"] = run.result.stdout
                    row["stderr"] = run.result.stderr[-2000:]
            except MatrixFailure as error:
                row["exit"] = None
                row["identical"] = False
                row["lines"] = 0
                row["detail"] = str(error).splitlines()[0]
                row["stderr"] = str(error)[-2000:]
            rows.append(row)
            status = "identical" if row["identical"] else "DIVERGED"
            print(f"  {case['id']} {mode:6} {status} ({row.get('detail', '')})".rstrip())
        return {
            "case": case,
            "reference": reference,
            "rows": rows,
            "frames": reference.frames,
            "values": reference.values,
            "fixture_bytes": (p.source_root / p.corpus["fixture"]).stat().st_size,
        }
    finally:
        if keep:
            print(f"kept workspace: {p.work}")
        else:
            shutil.rmtree(p.work, ignore_errors=True)


def render_convergence(results: list[dict[str, Any]], facts: dict[str, str]) -> str:
    out: list[str] = []
    out.append("# Corpus convergence: C reference vs c2das output, per frame, per run mode\n")
    out.append(
        "Generated by `python3 scripts/corpus_matrix.py converge` "
        f"on {facts['date']} at commit `{facts['commit']}` "
        f"(daslang {facts['daslang']}; {facts['clang']}; {facts['cpu']}; {facts['os']}, kernel {facts['kernel']}).\n"
    )
    out.append(
        "For every case the C graph is compiled with the case's clang flags and run; its stdout must equal the "
        "oracle pinned in `tests/canonical/cases.json`. The same C graph is then translated afresh with "
        "`c2dascript-transpile --strict`, and the fixture-owned daslang entry is run in each mode. A mode "
        "converges only when its stdout is byte-identical to the C reference stdout and the exit codes match. "
        "The stdout carries one `frame[i]=<hash>` line per decoded frame (a 32-bit FNV-style fold of the "
        "frame's RGB or YUV bytes), so this is a per-frame comparison, not a summary hash.\n"
    )
    out.append("Run modes: " + "; ".join(f"**{m}** = {describe_mode(m, 'entry.das')}" for m in MODES) + ".\n")
    for r in results:
        case = r["case"]
        rw = case["corpus"]
        out.append(f"## {rw['label']} — canonical case `{case['id']}`\n")
        out.append(f"- Source revision: `{case['source_root']}/{rw['upstream']}`")
        out.append(f"- Fixture: `{case['source_root']}/{rw['fixture']}` ({r['fixture_bytes']} bytes)")
        values = r["values"]
        size = f"{values.get('width', '?')}×{values.get('height', '?')}"
        out.append(f"- C reference: {len(r['reference'].stdout_lines)} stdout lines, exit {r['reference'].result.returncode}, "
                   f"{size}, {len(r['frames'])} decoded frames")
        if "das_program" in case:
            out.append(f"- Entry: `{case['das_program']}` (daslang) / `{case['c_reference']['sources'][-1]}` (C)\n")
        else:
            out.append(
                f"- Entry: the translated `{case['translation_entry']}` itself (`--libc {case.get('libc', 'nostd')}`, "
                f"C `main` lowered by the translator) / `{case['c_reference']['sources'][-1]}` (C)\n"
            )
        out.append("| mode | build | stdout identical to C | exit | note |")
        out.append("|---|---|---|---|---|")
        for row in r["rows"]:
            mark = "yes" if row["identical"] else "**NO**"
            exit_code = "—" if row["exit"] is None else str(row["exit"])
            out.append(f"| {row['mode']} | {row['build']} | {mark} ({row['lines']} lines) | {exit_code} | {row.get('detail', '')} |")
        out.append("")
        out.append("Per-frame hashes (C reference; every converging mode printed the same lines):\n")
        out.append("| frame | hash (int32) |")
        out.append("|---|---|")
        for index, digest in r["frames"]:
            out.append(f"| {index} | {digest} |")
        out.append("")
        diverged = [row for row in r["rows"] if not row["identical"]]
        for row in diverged:
            out.append(f"<details><summary>{row['mode']} output</summary>\n")
            out.append("```")
            out.append(row.get("stdout", "").rstrip())
            out.append("--- stderr ---")
            out.append(row.get("stderr", "").rstrip())
            out.append("```\n</details>\n")
    return "\n".join(out).rstrip() + "\n"


# ----------------------------------------------------------------------------
# bench
# ----------------------------------------------------------------------------

def measure(command: list[str], cwd: Path, env: dict[str, str], runs: int,
            reference_frames: list[tuple[int, int]] | None) -> dict[str, Any]:
    run_once(command, cwd, env)  # warm-up: page cache, JIT DLL cache, module cache
    samples: list[Run] = []
    for _ in range(runs):
        run = run_once(command, cwd, env)
        if run.result.returncode != 0:
            raise MatrixFailure(f"exit {run.result.returncode}\nstdout:\n{run.result.stdout}\nstderr:\n{run.result.stderr}")
        if "decode_us" not in run.values:
            raise MatrixFailure(f"no decode_us line\nstdout:\n{run.result.stdout}\nstderr:\n{run.result.stderr}")
        if reference_frames is not None and run.frames != reference_frames:
            raise MatrixFailure(f"per-frame hashes differ from the C -O2 build\nstdout:\n{run.result.stdout}")
        samples.append(run)
    decode = [s.values["decode_us"] / 1000.0 for s in samples]
    setup = [s.values.get("setup_us", 0) / 1000.0 for s in samples]
    wall = [s.wall_ms for s in samples]
    return {
        "frames": samples[0].frames,
        "decode_median": median(decode),
        "decode_min": min(decode),
        "setup_median": median(setup),
        "wall_median": median(wall),
        "startup_median": median([w - d - s for w, d, s in zip(wall, decode, setup)]),
        "runs": runs,
    }


def bench_case(case: dict[str, Any], daslang: Path, runs: int, keep: bool) -> dict[str, Any]:
    p = prepare(case, daslang)
    try:
        variants: list[dict[str, Any]] = []
        c_o2 = [*build_c(p, p.bench_c, "-O2", "c_bench_O2"), *p.args]
        base = measure(c_o2, p.work, p.env, runs, None)
        variants.append({"name": "C clang-18 -O2", "build": f"`clang-18 {' '.join(case['clang']['flags'])} -O2`", **base})
        print(f"  {case['id']} C -O2: decode {base['decode_median']:.3f} ms")
        reference_frames = base["frames"]
        c_o0 = [*build_c(p, p.bench_c, "-O0", "c_bench_O0"), *p.args]
        try:
            m = measure(c_o0, p.work, p.env, runs, reference_frames)
            variants.append({"name": "C clang-18 -O0", "build": f"`clang-18 {' '.join(case['clang']['flags'])} -O0`", **m})
            print(f"  {case['id']} C -O0: decode {m['decode_median']:.3f} ms")
        except MatrixFailure as error:
            variants.append({"name": "C clang-18 -O0", "build": "", "error": str(error).splitlines()[0]})
        if p.bench_translation_entry is not None:
            # std case: the benchmark program is the translated C graph + C entry
            entry = p.translate(p.bench_translation_entry, p.work / "generated_bench")
            c_entry: Path | None = p.bench_translation_entry
        else:
            entry = p.bench_das
            c_entry = None
        if entry is None:
            raise MatrixFailure(f"{case['id']}: corpus block names neither bench_das_entry nor bench_translation_entry")
        for mode in MODES:
            name = f"daslang {mode}"
            try:
                cmd = with_args(build_mode(p, mode, entry, "bench", c_entry), mode, p.args)
                m = measure(cmd, p.work, p.env, runs, reference_frames)
                variants.append({"name": name, "build": describe_mode(mode, entry.name), **m})
                print(f"  {case['id']} {mode}: decode {m['decode_median']:.3f} ms, wall {m['wall_median']:.1f} ms")
            except MatrixFailure as error:
                variants.append({"name": name, "build": describe_mode(mode, entry.name), "error": str(error).splitlines()[0]})
                print(f"  {case['id']} {mode}: FAILED {str(error).splitlines()[0]}")
        return {"case": case, "variants": variants, "frames": len(reference_frames),
                "fixture_bytes": (p.source_root / p.corpus["fixture"]).stat().st_size}
    finally:
        if keep:
            print(f"kept workspace: {p.work}")
        else:
            shutil.rmtree(p.work, ignore_errors=True)


def render_benchmark(results: list[dict[str, Any]], facts: dict[str, str], runs: int) -> str:
    out: list[str] = []
    out.append("# Corpus benchmark: C vs c2das output in every daslang run mode\n")
    out.append(
        "Generated by `python3 scripts/corpus_matrix.py bench` "
        f"on {facts['date']} at commit `{facts['commit']}` "
        f"(daslang {facts['daslang']}; {facts['clang']}; {facts['cpu']}; {facts['os']}, kernel {facts['kernel']}).\n"
    )
    out.append(
        f"Each variant runs once to warm up (page cache, the JIT's `.jitted_scripts` DLL cache, the module cache) and "
        f"then {runs} times; the table reports the median over those {runs} runs. **decode** is the time the program "
        "itself measured around its frame loop (`decode_us`, C `clock_gettime(CLOCK_MONOTONIC)`, daslang "
        "`ref_time_ticks`/`get_time_usec`), so it excludes process start, script compilation, JIT codegen and decoder "
        "setup. **setup** is the measured `frames_begin()` call (runtime reset, sample copy, demuxer/decoder "
        "creation). **wall** is the whole process as seen by the driver, and **startup** = wall − decode − setup: what a "
        "mode spends before and after the work (loading the runtime, compiling the script, JIT codegen, teardown). "
        "A row is printed only when its per-frame hashes equalled the C -O2 build's on every run. "
        "Every build and run command behind these rows is written out in `docs/corpus-build-recipe.md`.\n"
    )
    out.append("Run modes: " + "; ".join(f"**{m}** = {describe_mode(m, 'bench_entry.das')}" for m in MODES) + ".\n")
    for r in results:
        case = r["case"]
        rw = case["corpus"]
        out.append(f"## {rw['label']} — `{case['id']}`, {r['frames']} frames of `{rw['fixture']}` ({r['fixture_bytes']} bytes)\n")
        base = next((v for v in r["variants"] if v["name"] == "C clang-18 -O2" and "error" not in v), None)
        out.append("| variant | decode ms (median) | decode ms (min) | setup ms | wall ms | startup ms | × C -O2 decode |")
        out.append("|---|---|---|---|---|---|---|")
        for v in r["variants"]:
            if "error" in v:
                out.append(f"| {v['name']} | failed | | | | | {v['error']} |")
                continue
            ratio = f"{v['decode_median'] / base['decode_median']:.2f}×" if base and base["decode_median"] > 0 else "—"
            out.append(
                f"| {v['name']} | {v['decode_median']:.3f} | {v['decode_min']:.3f} | {v['setup_median']:.3f} | "
                f"{v['wall_median']:.1f} | {v['startup_median']:.1f} | {ratio} |"
            )
        out.append("")
        out.append("Builds: " + "; ".join(f"{v['name']}: {v['build']}" for v in r["variants"] if v.get("build")) + "\n")
    return "\n".join(out).rstrip() + "\n"


# ----------------------------------------------------------------------------
# main
# ----------------------------------------------------------------------------

def select_cases(case_id: str | None) -> list[dict[str, Any]]:
    cases = [c for c in runner.load_cases() if "corpus" in c]
    if case_id:
        cases = [c for c in cases if c["id"] == case_id]
        if not cases:
            raise MatrixFailure(f"no corpus case named {case_id}")
    if not cases:
        raise MatrixFailure("no corpus cases registered")
    return cases


def stable_body(document: str) -> str:
    return "\n".join(line for line in document.splitlines() if not line.startswith("Generated by "))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command", required=True)
    conv = sub.add_parser("converge", help="per-frame convergence of every run mode against the C reference")
    conv.add_argument("--case")
    conv.add_argument("--check", action="store_true", help="compare with the committed document instead of writing it")
    conv.add_argument("--keep-workdir", action="store_true")
    bench = sub.add_parser("bench", help="decode-loop timing of every variant")
    bench.add_argument("--case")
    bench.add_argument("--runs", type=int, default=5)
    bench.add_argument("--keep-workdir", action="store_true")
    args = parser.parse_args()
    try:
        daslang = runner.find_daslang()
        facts = environment_facts(daslang)
        cases = select_cases(args.case)
        if args.command == "converge":
            results = [converge_case(case, daslang, args.keep_workdir) for case in cases]
            document = render_convergence(results, facts)
            failed = [r["case"]["id"] for r in results if any(not row["identical"] for row in r["rows"])]
            if args.check:
                if args.case:
                    raise MatrixFailure("--check needs the whole matrix, not --case")
                committed = CONVERGENCE_DOC.read_text(encoding="utf-8") if CONVERGENCE_DOC.is_file() else ""
                if stable_body(committed) != stable_body(document):
                    print(f"FAIL {CONVERGENCE_DOC.relative_to(ROOT)} no longer matches a fresh run; regenerate and review",
                          file=sys.stderr)
                    return 1
                print(f"PASS {CONVERGENCE_DOC.relative_to(ROOT)} matches a fresh run")
            elif args.case:
                print(document)
            else:
                CONVERGENCE_DOC.write_text(document, encoding="utf-8")
                print(f"wrote {CONVERGENCE_DOC.relative_to(ROOT)}")
            if failed:
                print(f"FAIL diverged: {', '.join(failed)}", file=sys.stderr)
                return 1
            return 0
        results = [bench_case(case, daslang, args.runs, args.keep_workdir) for case in cases]
        document = render_benchmark(results, facts, args.runs)
        if args.case:
            print(document)
        else:
            BENCHMARK_DOC.write_text(document, encoding="utf-8")
            print(f"wrote {BENCHMARK_DOC.relative_to(ROOT)}")
        failed = [f"{r['case']['id']}/{v['name']}" for r in results for v in r["variants"] if "error" in v]
        if failed:
            print(f"FAIL variants: {', '.join(failed)}", file=sys.stderr)
            return 1
        return 0
    except (MatrixFailure, runner.CaseFailure) as error:
        print(f"FAIL {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
