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
      every run, otherwise its row is a failure, never a number.  Three C rows are
      built — `-O2`, `-O0` and `-O3 -march=native` — and every row carries two ratio
      columns, one against each of the two optimized C builds: a `clang -O2` binary
      targets generic x86-64 (SSE2) while daslang's LLVM backend compiles for the
      host CPU and its features, so the native build is the fair ceiling (the
      headline) and the `-O2` one is the portable reference.  The document opens
      with one table of the cases whose corpus block names a `headline` label
      (cells: ratio to the native build per mode) and three lines under it; every
      case's full table follows in an appendix.  `--output` writes it elsewhere.

Optional corpus keys read only by the benchmark: `optional_translator_flags` (see
below), `headline` (the case's row
label in the headline table; its presence puts the case there), `unit` (what one
checked line is, default "frames"), `timed` (what the program times, default "decode
loop") and `note` (a markdown sentence printed under the case's table and in the
headline footnote).

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

The C side is the same graph compiled with the case's clang flags, at -O2, -O0 and
-O3 -march=native for the benchmark and with the case's flags alone for the reference.

A case may carry `translator_flags`: translator switches passed verbatim, in addition
to the `--libc` and `--das-option` its other keys imply.  Both this driver and
scripts/run_c2das_cases.py read them through runner.libc_flags, so a case is
translated under one configuration whichever builds it.  The corpus cases declare
none: every row without a `+` suffix runs the translator's defaults, `options
solid_context = true` in the header and daslang's null checks left in place
(`docs/followups/hot_path_levers.md`).

A corpus block may carry `optional_translator_flags`, a map from an option label to
translator switches, e.g. `{"unsafe_deref": ["--unsafe-deref"]}`.  The benchmark
alone reads it: for each label it translates the case a second time with those
switches added, into its own directory under the workspace (`bench_<label>/`, the
fixture entry copied beside the modules for a nostd case), and measures the
OPTION_MODES on it as separate rows named `daslang <mode> + <label>`, run from that
directory so the JIT's `.jitted_scripts/` cache is never shared with the default
rows.  The headline table stays on the default translation; a second table beside
it shows what each option buys.

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
# The two C rows every other row is reported as a ratio of: the portable build
# (`-O2`, generic x86-64) and the fair ceiling for this machine (`-O3
# -march=native`).  Named once, because both `bench_case` and
# `render_benchmark` have to agree on the spelling.
C_O2_VARIANT = "C clang-18 -O2"
C_NATIVE_VARIANT = "C clang-18 -O3 -march=native"
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
        """`--libc`, `--das-option` and `translator_flags` exactly as the canonical runner passes them.

        Both drivers read the same function, so a corpus case is translated
        under one configuration whichever of them builds it.  A benchmark
        option's switches (`optional_translator_flags`) are passed through
        `translate`'s `extra`, never through this list.
        """
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
    """Build the C graph with `entry` as its entry point, at optimization `opt`.

    `opt` is the whole optimization setting as it would be typed on a command
    line, so it may be several words (`"-O3 -march=native"`), not only one
    (`"-O2"`); `None` builds with the case's own clang flags alone.
    """
    binary = p.work / name
    flags = list(p.flags) + (opt.split() if opt else [])
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
#
# `--no-solid-context` is the AOT path's second header difference.  The
# translator writes `options solid_context = true` by default, and daslang's
# AOT cannot run the h264bsd graph with it: the C++ generates and compiles,
# but `das_program_simulate` under `fail_on_no_aot` then refuses the program
# ("aot_host: simulation failed"), for both `h264bsd-mp4` and
# `h264bsd-mp4-640x360-std`, with and without `--unsafe-deref` (verified
# 2026-09-22; pl_mpeg and wasm3 AOT-run with the option on).  daslang's own
# documentation says `solid_context` prohibits AOT, so this is the AOT build
# honouring that, the same way it honours `disable_auto_inline`.  The option
# is a `-jit`/`-exe`/interpreter lever, and those three modes keep it.
AOT_GRAPH_FLAGS = ["--public-module", "--no-solid-context", "--das-option", "disable_auto_inline"]
AOT_PROGRAM_FLAGS = ["--no-solid-context", "--das-option", "disable_auto_inline"]
AOT_ENTRY_OPTIONS = ["options disable_auto_inline\n"]


def transpile_for_aot(p: Prepared, c_entry: Path, generated_dir: Path, flags: list[str]) -> list[Path]:
    """Translate a C translation unit again, with the module header an AOT build needs.

    The translator writes the header itself (`--public-module`, `--das-option`,
    `--no-solid-context`); nothing edits generated text.  Three things differ
    from the plain translation:

    * `module <name> public`: daslang emits AOT bodies for a module's functions
      only when the module is a named public one; an anonymous module keeps
      nothing that is not exported or reached.
    * `options disable_auto_inline`: daslang's optimizer splices small
      same-module callees into their callers and declares the callee's locals
      at the call site (`ast_inline.cpp`, `_inl*` temporaries).  In a
      jump-rendered body that puts an initialised declaration between a `goto`
      and its label, which C++ rejects; the C++ compiler inlines those calls
      itself, so the AOT build loses nothing by leaving them as calls.
    * no `options solid_context`: see AOT_GRAPH_FLAGS.  daslang's AOT refuses
      the h264bsd graph when the option is on.

    Everything else is byte-identical to the translation the other modes run,
    because the translator is deterministic over the same C input and flags.
    """
    p.translate(c_entry, generated_dir, flags)
    modules = sorted(generated_dir.rglob("*.das"))
    if not modules:
        raise MatrixFailure(f"{p.case['id']}: AOT translation produced no module")
    return modules


def build_aot(p: Prepared, entry: Path, name: str, c_entry: Path | None,
              option_flags: list[str] | None = None) -> list[str]:
    """`c_entry` is the C unit whose translation *is* the program (std cases);
    `None` means `entry` is a fixture-owned daslang entry over the graph.
    `option_flags`: a benchmark option's translator switches, added to the AOT
    translation's own."""
    das_root = p.daslang.parent.parent
    aot_dir = p.work / name
    aot_dir.mkdir()
    extra = list(option_flags or [])
    if c_entry is not None:
        # the program is the translated C unit; its header already carries the
        # AOT options, so there is nothing to prepend
        modules: list[Path] = []
        entry_copy = transpile_for_aot(p, c_entry, aot_dir / "generated", [*AOT_PROGRAM_FLAGS, *extra])[0]
        shutil.copyfile(entry_copy, aot_dir / entry_copy.name)
        entry_copy = aot_dir / entry_copy.name
    else:
        # the AOT translation of the graph, plus the fixture-owned entry beside
        # it so `require <module>` resolves against these modules, never the
        # staged ones; the entry is fixture source, so its one AOT option is
        # prepended to a copy rather than edited in place
        modules = transpile_for_aot(p, p.translation_entry, aot_dir / "generated", [*AOT_GRAPH_FLAGS, *extra])
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


def build_mode(p: Prepared, mode: str, entry: Path, name: str, c_entry: Path | None = None,
               option_flags: list[str] | None = None) -> list[str]:
    """`option_flags` matter only to aot, which translates again; the other
    modes take `entry`, already translated with them."""
    if mode == "interp":
        return [str(p.daslang), str(entry)]
    if mode == "jit":
        return [str(p.daslang), "-jit", str(entry)]
    if mode == "exe":
        return build_exe(p, entry, f"{name}_exe")
    if mode == "aot":
        return build_aot(p, entry, f"{name}_aot", c_entry, option_flags)
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


# `daslang -jit` reads its own `--jit-*` switches from the *script's* arguments
# (`llvm_jit_plan.make_jit_plan` → `clargs.parse_args` → `get_user_args()`, the
# words after `--`); daslang's command line proper rejects them in front of the
# script.  Passed explicitly they would therefore become program arguments and
# change a `--libc std` program's C `argc` (verified 2026-09-22 on
# `p81-std-printf-edge`: `argc=2` becomes `argc=3`).  `--jit-split-modules=-1`
# is the DLL path's default (`llvm_jit_cli.das`: "-1 = split + auto threads
# (JobQue count; the default)"), so the driver runs without it and instead
# requires every measured run's JIT log to report the split build, which makes
# the setting explicit without touching the program's argv.
JIT_SPLIT_LOG = re.compile(r"\bsplit\b")


def describe_bench_mode(mode: str, entry_name: str, std_program: bool,
                        option_flags: list[str] | None = None) -> str:
    """The benchmark's build text for a daslang row: the command and every way it
    differs from the translation the other rows run.  `option_flags`: the row is
    a benchmark option's, built from a translation with those switches added."""
    if option_flags:
        if mode == "aot":
            return describe_bench_mode(mode, entry_name, std_program, None).replace(
                "translation with `", f"translation with `{' '.join(option_flags)} ", 1
            )
        return (
            f"as the row without the suffix, from a separate translation with `{' '.join(option_flags)}`: "
            + describe_bench_mode(mode, entry_name, std_program, None)
        )
    if mode == "jit":
        return (
            f"`daslang -jit {entry_name}`, split codegen with auto threads (`--jit-split-modules=-1`, daslang's "
            "default for the DLL path; not passed, because the JIT reads its switches from the script's own "
            "arguments, where it would change C `argc` — each run's JIT log is required to say `split`)"
        )
    if mode == "aot":
        flags = AOT_PROGRAM_FLAGS if std_program else AOT_GRAPH_FLAGS
        reasons = [
            "no `solid_context` (daslang's AOT refuses the h264bsd program with it on)",
            "no daslang auto-inlining (its inlined locals land between a `goto` and its label, which the "
            "generated C++ rejects)",
        ]
        entry = ""
        if not std_program:
            reasons.insert(0, "a named public module (daslang emits AOT bodies only for those)")
            entry = " (the fixture entry gets `options disable_auto_inline` prepended to a copy)"
        return (
            "`daslang -aot` per module + `aot_host` (policies.aot, fail_on_no_aot); **built from a second "
            f"translation with `{' '.join(flags)}`**{entry}: {'; '.join(reasons)}; the host recompiles the "
            "script on every run, so its start-up is not comparable"
        )
    return describe_mode(mode, entry_name)


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
            reference_frames: list[tuple[int, int]] | None,
            require_log: re.Pattern[str] | None = None) -> dict[str, Any]:
    """`require_log`: a pattern some `[I]` log line of every measured run must
    match (the `-jit` rows require the split-codegen report, see JIT_SPLIT_LOG)."""
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
        if require_log is not None and not any(require_log.search(line) for line in run.log_lines):
            raise MatrixFailure(
                f"no JIT log line matches {require_log.pattern!r}\nlog:\n" + "\n".join(run.log_lines)
            )
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


# The modes a benchmark option (`optional_translator_flags`) is measured in: the
# compiled ones, where a translator lever shows as generated code; the
# interpreter row stays on the default translation only.
OPTION_MODES = ("jit", "exe", "aot")
OPTION_LABEL = re.compile(r"^[a-z][a-z0-9_]*$")
# What a known option does, for the sentence above its table in the document.
OPTION_TEXT = {
    "unsafe_deref": (
        "These rows come from a second translation of each program with `[unsafe_deref]` on every function, "
        "which removes daslang's null check in front of every pointer dereference (`ExprAt`, `ExprPtr2Ref`, "
        "field access): C's unchecked access, where a null dereference crashes instead of raising a located "
        "daslang exception. It is an option, not the default — the same effect is available by writing the "
        "code on raw pointers; it is a choice of which unsafety to accept (`docs/followups/hot_path_levers.md`)."
    ),
}


def optional_translator_flags(case: dict[str, Any]) -> dict[str, list[str]]:
    """`corpus.optional_translator_flags`: option label -> translator switches."""
    options = case["corpus"].get("optional_translator_flags", {})
    if not isinstance(options, dict):
        raise MatrixFailure(f"{case['id']}: optional_translator_flags must map a label to a flag list")
    for label, flags in options.items():
        if not OPTION_LABEL.match(label):
            raise MatrixFailure(f"{case['id']}: optional_translator_flags label {label!r} is not [a-z][a-z0-9_]*")
        if not isinstance(flags, list) or not flags or not all(isinstance(f, str) and f.strip() for f in flags):
            raise MatrixFailure(f"{case['id']}: optional_translator_flags[{label!r}] must be a non-empty flag list")
    return options


def translate_option(p: Prepared, option_dir: Path, flags: list[str]) -> Path:
    """Translate the benchmark program again with an option's switches added;
    returns the entry to run.  Everything lands in `option_dir` under the
    workspace: a std case's module is the program, a nostd case's modules sit
    beside a copy of the fixture's benchmark entry so its `require` resolves to
    them and never to the default translation."""
    option_dir.mkdir()
    if p.bench_translation_entry is not None:
        return p.translate(p.bench_translation_entry, option_dir, flags)
    if p.bench_das is None:
        raise MatrixFailure(f"{p.case['id']}: corpus block names neither bench_das_entry nor bench_translation_entry")
    generated = option_dir / "generated"
    p.translate(p.translation_entry, generated, flags)
    for module in sorted(generated.rglob("*.das")):
        target = option_dir / module.relative_to(generated)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(module, target)
    entry = option_dir / p.bench_das.name
    if entry.exists():
        raise MatrixFailure(f"{p.case['id']}: generated module collides with the entry {entry.name}")
    shutil.copyfile(p.bench_das, entry)
    return entry


def bench_case(case: dict[str, Any], daslang: Path, runs: int, keep: bool) -> dict[str, Any]:
    p = prepare(case, daslang)
    try:
        variants: list[dict[str, Any]] = []
        c_o2 = [*build_c(p, p.bench_c, "-O2", "c_bench_O2"), *p.args]
        base = measure(c_o2, p.work, p.env, runs, None)
        variants.append({"name": C_O2_VARIANT, "build": f"`clang-18 {' '.join(case['clang']['flags'])} -O2`", **base})
        print(f"  {case['id']} C -O2: decode {base['decode_median']:.3f} ms")
        reference_frames = base["frames"]
        # The two further C builds: the unoptimized floor, and the build a C
        # programmer would actually ship for this machine.  `-O2` targets
        # generic x86-64 while daslang's LLVM backend compiles for the host
        # CPU under `-jit`, so `-O2` alone is not a fair ceiling — the native
        # build is what the daslang rows have to be read against.
        for opt, variant_name, binary_name in (
            ("-O0", "C clang-18 -O0", "c_bench_O0"),
            ("-O3 -march=native", C_NATIVE_VARIANT, "c_bench_native"),
        ):
            try:
                cmd = [*build_c(p, p.bench_c, opt, binary_name), *p.args]
                m = measure(cmd, p.work, p.env, runs, reference_frames)
                variants.append({"name": variant_name, "build": f"`clang-18 {' '.join(case['clang']['flags'])} {opt}`", **m})
                print(f"  {case['id']} C {opt}: decode {m['decode_median']:.3f} ms")
            except MatrixFailure as error:
                variants.append({"name": variant_name, "build": "", "error": str(error).splitlines()[0]})
        if p.bench_translation_entry is not None:
            # std case: the benchmark program is the translated C graph + C entry
            entry = p.translate(p.bench_translation_entry, p.work / "generated_bench")
            c_entry: Path | None = p.bench_translation_entry
        else:
            entry = p.bench_das
            c_entry = None
        if entry is None:
            raise MatrixFailure(f"{case['id']}: corpus block names neither bench_das_entry nor bench_translation_entry")

        def daslang_row(mode: str, row_entry: Path, name: str, cwd: Path,
                        option: str | None = None, option_flags: list[str] | None = None) -> None:
            label = f"daslang {mode}" + (f" + {option}" if option else "")
            build = describe_bench_mode(mode, row_entry.name, c_entry is not None, option_flags)
            try:
                cmd = with_args(build_mode(p, mode, row_entry, name, c_entry, option_flags), mode, p.args)
                m = measure(cmd, cwd, p.env, runs, reference_frames,
                            JIT_SPLIT_LOG if mode == "jit" else None)
                variant = {"name": label, "mode": mode, "option": option, "build": build, **m}
                if mode == "aot":
                    # aot_host compiles the script again (policies.aot) on every
                    # launch, so its wall − work is a compiler's start-up, not a
                    # comparable process start
                    variant["startup_note"] = "n/a (recompiles per run)"
                variants.append(variant)
                print(f"  {case['id']} {label}: decode {m['decode_median']:.3f} ms, wall {m['wall_median']:.1f} ms")
            except MatrixFailure as error:
                variants.append({"name": label, "mode": mode, "option": option, "build": build,
                                 "error": str(error).splitlines()[0]})
                print(f"  {case['id']} {label}: FAILED {str(error).splitlines()[0]}")

        for mode in MODES:
            daslang_row(mode, entry, "bench", p.work)
        for option, option_flags in optional_translator_flags(case).items():
            # A separate translation per option, in its own directory under the
            # workspace; the rows run from there, so `-jit` caches apart.
            option_dir = p.work / f"bench_{option}"
            try:
                option_entry = translate_option(p, option_dir, option_flags)
            except MatrixFailure as error:
                for mode in OPTION_MODES:
                    variants.append({"name": f"daslang {mode} + {option}", "mode": mode, "option": option,
                                     "build": "", "error": str(error).splitlines()[0]})
                continue
            for mode in OPTION_MODES:
                daslang_row(mode, option_entry, f"bench_{option}", option_dir, option, option_flags)
        return {"case": case, "variants": variants, "frames": len(reference_frames),
                "fixture_bytes": (p.source_root / p.corpus["fixture"]).stat().st_size}
    finally:
        if keep:
            print(f"kept workspace: {p.work}")
        else:
            shutil.rmtree(p.work, ignore_errors=True)


# The benchmark document's reading order: the C row every ratio is against
# first, then the portable and unoptimized C rows, then the daslang modes from
# slowest to what ships (the headline table's column order).
BENCH_ROW_ORDER = (C_NATIVE_VARIANT, C_O2_VARIANT, "C clang-18 -O0",
                   "daslang interp", "daslang jit", "daslang exe", "daslang aot")
HEADLINE_MODES = ("interp", "jit", "exe", "aot")
# A non-headline case whose C -O2 loop runs under this many milliseconds is a
# micro fixture: timer resolution and cache state dominate its ratios.
MICRO_MS = 5.0


def case_unit(case: dict[str, Any]) -> str:
    """What one checked output line is: `frames` for the decoders (the default),
    `checked values` for a program that prints numbered results (`corpus.unit`)."""
    return case["corpus"].get("unit", "frames")


def case_timed(case: dict[str, Any]) -> str:
    """What the program times around (`corpus.timed`, default `decode loop`)."""
    return case["corpus"].get("timed", "decode loop")


def variant_by_name(result: dict[str, Any], name: str) -> dict[str, Any] | None:
    return next((v for v in result["variants"] if v["name"] == name and "error" not in v), None)


def ratio_to(reference: dict[str, Any] | None, value: float) -> str:
    if reference is None or reference["decode_median"] <= 0:
        return "—"
    return f"{value / reference['decode_median']:.2f}×"


def ordered_variants(result: dict[str, Any]) -> list[dict[str, Any]]:
    """BENCH_ROW_ORDER, each option row (`daslang jit + unsafe_deref`) right
    after the default row of its mode."""
    rank = {name: index for index, name in enumerate(BENCH_ROW_ORDER)}

    def key(v: dict[str, Any]) -> tuple[int, int]:
        base = v["name"].split(" + ", 1)[0]
        return (rank.get(base, len(rank)), 0 if base == v["name"] else 1)

    return sorted(result["variants"], key=key)


def mode_variant(result: dict[str, Any], mode: str, option: str | None = None) -> dict[str, Any] | None:
    """The daslang row of `mode` (and benchmark option), failed or not."""
    return next((v for v in result["variants"] if v.get("mode") == mode and v.get("option") == option), None)


def option_labels(results: list[dict[str, Any]]) -> list[str]:
    labels: list[str] = []
    for r in results:
        for label in optional_translator_flags(r["case"]):
            if label not in labels:
                labels.append(label)
    return labels


def approx_ms(values: list[float]) -> str:
    """One process-start figure over the headline programs: a single rounded
    value when they agree within 25 %, the measured range when they do not."""
    if not values:
        return "—"
    low, high = min(values), max(values)
    if high <= low * 1.25:
        return f"≈ {statistics.median(values):.0f} ms"
    return f"≈ {low:.0f}–{high:.0f} ms"


def render_benchmark(results: list[dict[str, Any]], facts: dict[str, str], runs: int) -> str:
    """One question at a glance — which daslang mode, how many times slower than
    C — then every number behind it in an appendix of reference data."""
    headline = [r for r in results if "headline" in r["case"]["corpus"]]
    out: list[str] = []
    out.append("# Corpus benchmark: how much slower than C is c2das-translated C, per daslang run mode\n")
    out.append(
        "Each program below is a C code base translated whole by c2das (`c2dascript-transpile --strict`) and run in "
        "each daslang mode. The time compared is what the program itself measures around its work loop (the decode "
        "loop of the video decoders, the call loop of wasm3), after one warm-up run, as the median of "
        f"{runs} runs; every mode's per-frame (per-value) hashes are checked against C's on every run, and a mode "
        "that ever differs is reported as failed, never timed. Cells are the ratio to C built with `clang-18 -O3 "
        "-march=native`; lower is better, 1.00× is C speed.\n"
    )
    out.append("| program | C, ms | " + " | ".join(HEADLINE_MODES) + " |")
    out.append("|---|---|" + "---|" * len(HEADLINE_MODES))
    starts: dict[str, list[float]] = {"exe": [], "jit": []}
    for r in headline:
        case = r["case"]
        native = variant_by_name(r, C_NATIVE_VARIANT)
        label = f"{case['corpus']['headline']}, {r['frames']} {case_unit(case)}"
        if case.get("libc") == "std":
            label += " — entire C translated"
        cells = [label, "—" if native is None else f"{native['decode_median']:.2f}"]
        for mode in HEADLINE_MODES:
            variant = mode_variant(r, mode)
            if variant is None or "error" in variant:
                cell = "failed"
            else:
                cell = ratio_to(native, variant["decode_median"])
                if mode in starts:
                    starts[mode].append(variant["startup_median"])
            cells.append(cell + ("\\*" if mode == "aot" else ""))
        out.append("| " + " | ".join(cells) + " |")
    out.append("")
    out.append(
        f"Baseline: `clang-18 -O3 -march=native` on {facts['cpu']}; hashes match C in all modes; median of {runs} runs.\n"
    )
    out.append(
        f"Process start (wall − timed work, median over these programs): exe {approx_ms(starts['exe'])}, "
        f"jit {approx_ms(starts['jit'])}.\n"
    )
    notes = " ".join(r["case"]["corpus"]["note"] for r in headline if "note" in r["case"]["corpus"])
    out.append(
        "\\* AOT is built without `solid_context` and without daslang's auto-inliner (`--no-solid-context "
        "--das-option disable_auto_inline`), because daslang's AOT refuses the h264bsd program with "
        "`solid_context` on and its inliner produces C++ that does not compile; every other mode runs the "
        "default translation. " + notes + "\n"
    )
    for option in option_labels(headline):
        cases = [r for r in headline if option in optional_translator_flags(r["case"])]
        flags = " ".join(optional_translator_flags(cases[0]["case"])[option])
        out.append(
            f"**Option: `{flags}`.** The table above is the translator's default output. "
            + OPTION_TEXT.get(option, f"These rows come from a second translation of each program with `{flags}`.")
            + " Cells are the ratio to the same `clang-18 -O3 -march=native` build, and in parentheses the change "
            "against the same mode without the option (negative = faster).\n"
        )
        out.append("| program | " + " | ".join(f"{mode} + {option}" for mode in OPTION_MODES) + " |")
        out.append("|---|" + "---|" * len(OPTION_MODES))
        for r in cases:
            native = variant_by_name(r, C_NATIVE_VARIANT)
            cells = [r["case"]["corpus"]["headline"]]
            for mode in OPTION_MODES:
                variant = mode_variant(r, mode, option)
                default = mode_variant(r, mode)
                if variant is None or "error" in variant:
                    cells.append("failed")
                    continue
                cell = ratio_to(native, variant["decode_median"])
                if default is not None and "error" not in default and default["decode_median"] > 0:
                    change = (variant["decode_median"] / default["decode_median"] - 1.0) * 100.0
                    cell += f" ({change:+.0f} %)".replace("-", "−")
                cells.append(cell + ("\\*" if mode == "aot" else ""))
            out.append("| " + " | ".join(cells) + " |")
        out.append("")
    out.append("---\n")
    out.append("## Appendix: full measurements\n")
    out.append(
        "Reference data behind the table above. "
        "Generated by `python3 scripts/corpus_matrix.py bench` "
        f"on {facts['date']} at commit `{facts['commit']}` "
        f"(daslang {facts['daslang']}; {facts['clang']}; {facts['cpu']}; {facts['os']}, kernel {facts['kernel']}). "
        "Every build and run command is written out in `docs/corpus-build-recipe.md`.\n"
    )
    out.append(
        "Columns: **ms (median / min)** is the program's own timer around its work loop (`decode_us`; C "
        "`clock_gettime(CLOCK_MONOTONIC)`, daslang `ref_time_ticks`), excluding process start, script "
        "compilation, JIT codegen and setup. **setup** is the timed `frames_begin_bytes()` call (runtime reset, "
        "working copy of the input, decoder creation). **wall** is the whole process as the driver sees it and "
        "**startup** = wall − work − setup (loading the runtime, compiling the script, JIT codegen, teardown); "
        "the aot host compiles the script again on every launch, so its startup is not shown. **× C native** "
        "is the ratio to `clang-18 -O3 -march=native`, the headline; **× C -O2** to the portable `clang-18 -O2` "
        "build (generic x86-64, SSE2), shown for reference because daslang's LLVM backend compiles `-jit` for the "
        "host CPU. The translated modules are the translator's defaults: `options solid_context = true` in the "
        "header and daslang's null checks on every pointer dereference (no `--unsafe-deref`). A row named "
        "`daslang <mode> + unsafe_deref` is the option: a separate translation of the same case with "
        "`--unsafe-deref`, `[unsafe_deref]` on every function, measured the same way; see "
        "`docs/followups/hot_path_levers.md`. The aot rows are the exception named in each case's build list. "
        "Cases that repeat a headline program through a hand-written daslang entry (no `--libc std`) and the "
        "embedded micro fixtures are here only.\n"
    )
    for r in results:
        case = r["case"]
        rw = case["corpus"]
        timed = case_timed(case)
        base = variant_by_name(r, C_O2_VARIANT)
        native = variant_by_name(r, C_NATIVE_VARIANT)
        marks: list[str] = []
        if "headline" in rw:
            marks.append("in the headline table")
        elif base is not None and base["decode_median"] < MICRO_MS:
            marks.append(f"micro fixture: C -O2 runs under {MICRO_MS:.0f} ms, noise-dominated")
        mark = f" — {'; '.join(marks)}" if marks else ""
        out.append(
            f"### {rw['label']} — `{case['id']}`, {r['frames']} {case_unit(case)} of `{rw['fixture']}` "
            f"({r['fixture_bytes']} bytes){mark}\n"
        )
        out.append(
            f"| variant | × C native | × C -O2 | {timed} ms (median) | {timed} ms (min) | setup ms | wall ms | "
            "startup ms |"
        )
        out.append("|---|---|---|---|---|---|---|---|")
        variants = ordered_variants(r)
        for v in variants:
            if "error" in v:
                out.append(f"| {v['name']} | failed | | | | | | {v['error']} |")
                continue
            startup = v.get("startup_note", f"{v['startup_median']:.1f}")
            out.append(
                f"| {v['name']} | {ratio_to(native, v['decode_median'])} | {ratio_to(base, v['decode_median'])} | "
                f"{v['decode_median']:.3f} | {v['decode_min']:.3f} | {v['setup_median']:.3f} | "
                f"{v['wall_median']:.1f} | {startup} |"
            )
        out.append("")
        if "note" in rw:
            out.append(rw["note"] + "\n")
        out.append("Builds:\n")
        for v in variants:
            if v.get("build"):
                out.append(f"- {v['name']}: {v['build']}")
        out.append("")
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
    for case in cases:
        optional_translator_flags(case)  # malformed options fail before any build
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
    bench.add_argument("--output", type=Path, default=None,
                       help=f"write the document here instead of {BENCHMARK_DOC.relative_to(ROOT)} "
                            "(with --case, instead of printing it)")
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
        if args.output is not None:
            args.output.write_text(document, encoding="utf-8")
            print(f"wrote {args.output}")
        elif args.case:
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
