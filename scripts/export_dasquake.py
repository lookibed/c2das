#!/usr/bin/env python3
"""Regenerate the dasQUAKE repository tree from this c2das checkout.

usage: python3 scripts/export_dasquake.py <out-dir>

dasQUAKE is quakegeneric (the WinQuake software-rendered engine) translated to
daslang by c2das, shaped like dasDOOM (scripts/export_dasdoom.py).  The tree is
generated; nothing in it is edited by hand except through this script and the
c2das sources it copies.  Existing content of <out-dir> is kept except the
generated directories `quake/`, `eden/` and `harness/` and the generated
top-level files, which are rewritten (a `.git` directory there is left alone).

- `quake/`: the `--libc std` timedemo program translated exactly like the case
  `quakegeneric-demo1-std` of tests/canonical/cases.json (its units, clang
  flags, libc and das_options) with `--module-layout source`.  `run.sh` runs it
  on a base directory holding `id1/pak0.pak` and compares the 100 frame hashes
  with `expected_frames.txt` (the case's expected stdout).
- `eden/`: the EdenSpark play build: the engine units of the case
  `quakegeneric-demo1-eden-linear` plus the play harness `src/qg_eden_play.c`
  (instead of `qg_platform.c` and `quake_entry.c`), translated with
  `--module-layout source` and the case's flags plus `--public-module`; the
  hand-written host `eden/c2das_quake_player.das`, whose require of the module
  holding `qge_*` is rewritten to the module the translation put them in, and
  an example project `main.das`.
- `harness/`: the c2das-authored C harness files.
- `tools/get_pak.sh`, `LICENSE`, `NOTICE`, `README.md`, `GENERATED.json`.

The translator is `$C2DAS_TRANSPILE` when set, otherwise this checkout's
release build (`cargo build --release -p c2dascript-transpile` is run first).
A translation the translator refuses stops the export with the translator's
first `translation failed:` diagnostic; nothing is written into <out-dir>.
"""
from __future__ import annotations

import datetime
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parent.parent
TEMPLATES = ROOT / "scripts" / "dasquake"
CASES = ROOT / "tests" / "canonical" / "cases.json"
QUAKE = ROOT / "tests" / "manual" / "quakegeneric"
STD_CASE = "quakegeneric-demo1-std"
EDEN_CASE = "quakegeneric-demo1-eden-linear"
PLAY_UNIT = "src/qg_eden_play.c"
HOST = QUAKE / "eden" / "c2das_quake_player.das"
# The host is written for the c2das editor install (modules/c2das/quake/); in a
# dasQUAKE install the translated modules sit next to it in modules/dasquake/.
HOST_REQUIRE_FROM = "require modules/c2das/quake/"
HOST_REQUIRE_TO = "require modules/dasquake/"
# The host's require of the module holding `qge_*` (the engine's cluster module).
HOST_PLAY_MODULE = re.compile(r"^require modules/c2das/quake/(\w+_cluster)$", re.MULTILINE)
HARNESS = ["engine_config.h", "qg_platform.c", "quake_entry.c", "qg_eden.h", "qg_eden_play.c"]


def fail(message: str) -> None:
    sys.exit(f"export_dasquake: {message}")


def run(command: list[str], cwd: Path, what: str) -> None:
    result = subprocess.run(command, cwd=cwd, text=True, capture_output=True)
    if result.returncode != 0:
        output = result.stdout + "\n" + result.stderr
        refusal = re.search(r"^.*translation failed:.*$", output, re.MULTILINE)
        if refusal:
            fail(f"{what}: the translator refused the C (a translator gap, see "
                 f"tests/manual/quakegeneric/UPSTREAM.md, \"Translation status\"):\n"
                 f"{refusal.group(0).strip()}")
        fail(f"{what}: command failed ({result.returncode}): {' '.join(command)}\n"
             f"{result.stdout[-3000:]}\n{result.stderr[-3000:]}")


def git(*args: str) -> str:
    return subprocess.run(["git", *args], cwd=ROOT, text=True, capture_output=True).stdout.strip()


def translator() -> Path:
    explicit = os.environ.get("C2DAS_TRANSPILE")
    if explicit:
        return Path(explicit).resolve()
    run(["cargo", "build", "-q", "--release", "-p", "c2dascript-transpile"], ROOT, "cargo build")
    return ROOT / "target" / "release" / "c2dascript-transpile"


def case(cases: list[dict], identifier: str) -> dict:
    for candidate in cases:
        if candidate["id"] == identifier:
            return candidate
    fail(f"case {identifier} not in {CASES.relative_to(ROOT)}")


def policy_flags(c: dict) -> list[str]:
    flags = ["--libc", c["libc"]] if c.get("libc") else []
    for option in c.get("das_options", []):
        flags += ["--das-option", option]
    return flags + list(c.get("translator_flags", []))


def check_no_local_paths(directory: Path) -> None:
    """Generated text must not carry this machine's paths."""
    needles = [str(ROOT), str(Path.home()), tempfile.gettempdir() + "/"]
    for path in directory.rglob("*"):
        if path.is_file():
            text = path.read_text(errors="replace")
            for needle in needles:
                if needle in text:
                    fail(f"{path} contains the local path {needle}")


def copy_generated(source: Path, destination: Path) -> list[str]:
    if destination.exists():
        shutil.rmtree(destination)
    destination.mkdir(parents=True)
    names = sorted(p.name for p in source.iterdir() if p.name.endswith((".das", ".das.inc")))
    for name in names:
        shutil.copyfile(source / name, destination / name)
    return names


def translate_source(tool: Path, c: dict, name: str, units: list[str], clang_flags: list[str],
                     options: list[str], work: Path) -> tuple[Path, list[str]]:
    """Translates `units` with `--module-layout source` into work/<name>."""
    src = ROOT / c["source_root"]
    compiler = c["clang"].get("compiler", "clang-18")
    database = work / (name + "-db") / "compile_commands.json"
    database.parent.mkdir()
    database.write_text(json.dumps([
        {"directory": str(src), "file": str(src / unit), "arguments": [compiler, *clang_flags, str(src / unit)]}
        for unit in units], indent=2))
    out = work / name
    out.mkdir()
    command = [str(tool), "--strict", *options, "--output-dir", str(out),
               "--module-layout", "source", str(database)]
    run(command, src, f"translating {name}/ ({c['id']})")
    shown = ["c2dascript-transpile", "--strict", *options, "--output-dir", name,
             "--module-layout", "source", "compile_commands.json"]
    return out, shown


def play_units(eden: dict) -> list[str]:
    """The play build: the case's engine units, then the play harness."""
    engine = [u for u in eden["translation_units"] if not u.startswith("src/")]
    if not engine:
        fail(f"{EDEN_CASE} has no engine units")
    return [*engine, PLAY_UNIT]


def play_module(directory: Path, names: list[str]) -> str:
    """The generated module that defines `qge_init`, directly or through the
    `include` of a `.das.inc` (a cluster module includes its units' bodies)."""
    defines = [n for n in names
               if re.search(r"^def (public )?qge_init\b", (directory / n).read_text(), re.MULTILINE)]
    found = sorted({n[:-len(".das")] for n in names if n.endswith(".das")
                    for d in defines
                    if n == d or re.search(rf"^include {re.escape(d)}$",
                                           (directory / n).read_text(), re.MULTILINE)})
    if len(found) != 1:
        fail(f"expected one eden/ module defining qge_init, found {found}")
    return found[0]


def write_template(name: str, destination: Path, values: dict[str, str]) -> None:
    text = (TEMPLATES / name).read_text()
    for key, value in values.items():
        text = text.replace("@" + key + "@", value)
    if re.search(r"@[A-Z_]+@", text):
        fail(f"template {name} has an unfilled placeholder")
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(text)


def main() -> int:
    if len(sys.argv) != 2:
        fail("usage: export_dasquake.py <out-dir>")
    out = Path(sys.argv[1]).resolve()
    cases = json.loads(CASES.read_text())["cases"]
    std, eden = case(cases, STD_CASE), case(cases, EDEN_CASE)
    head = git("rev-parse", "HEAD")
    dirty = bool(git("status", "--porcelain", "--untracked-files=no"))
    tool = translator()
    host = HOST.read_text()
    if host.count(HOST_REQUIRE_FROM) == 0 or len(HOST_PLAY_MODULE.findall(host)) != 1:
        fail(f"{HOST.relative_to(ROOT)}: expected `{HOST_REQUIRE_FROM}…` requires, one of them `…_cluster`")

    with tempfile.TemporaryDirectory(prefix="dasquake-") as scratch:
        work = Path(scratch)
        # both translations first: a refusal leaves <out-dir> untouched
        std_out, std_command = translate_source(tool, std, "quake", std["translation_units"],
                                                std["clang"]["flags"], policy_flags(std), work)
        units = play_units(eden)
        play_flags = list(eden["clang"]["flags"])
        play_out, play_command = translate_source(tool, eden, "eden", units, play_flags,
                                                  ["--public-module", *policy_flags(eden)], work)
        check_no_local_paths(std_out)
        check_no_local_paths(play_out)
        out.mkdir(parents=True, exist_ok=True)
        quake_files = copy_generated(std_out, out / "quake")
        eden_files = copy_generated(play_out, out / "eden")
    module = play_module(out / "eden", eden_files)

    (out / "quake" / "expected_frames.txt").write_text(std["expected"]["stdout"])
    shutil.copyfile(TEMPLATES / "run.sh", out / "quake" / "run.sh")
    (out / "quake" / "run.sh").chmod(0o755)

    host = HOST_PLAY_MODULE.sub(f"require modules/c2das/quake/{module}", host)
    (out / "eden" / HOST.name).write_text(host.replace(HOST_REQUIRE_FROM, HOST_REQUIRE_TO))
    shutil.copyfile(TEMPLATES / "main.das", out / "eden" / "main.das.example")

    harness = out / "harness"
    if harness.exists():
        shutil.rmtree(harness)
    harness.mkdir()
    for name in HARNESS:
        shutil.copyfile(QUAKE / "src" / name, harness / name)

    (out / "tools").mkdir(exist_ok=True)
    shutil.copyfile(TEMPLATES / "get_pak.sh", out / "tools" / "get_pak.sh")
    (out / "tools" / "get_pak.sh").chmod(0o755)
    shutil.copyfile(QUAKE / "upstream" / "quakegeneric" / "LICENSE", out / "LICENSE")
    shutil.copyfile(TEMPLATES / "gitignore", out / ".gitignore")

    short = head[:9] + ("-dirty" if dirty else "")
    upstream = re.search(r"`([0-9a-f]{40})`", (QUAKE / "UPSTREAM.md").read_text()).group(1)
    values = {"C2DAS_COMMIT": head + ("-dirty" if dirty else ""), "C2DAS_SHORT": short,
              "UPSTREAM_COMMIT": upstream, "PLAY_MODULE": module,
              "QUAKE_MODULES": str(sum(n.endswith(".das") for n in quake_files)),
              "QUAKE_INCS": str(sum(n.endswith(".das.inc") for n in quake_files))}
    write_template("NOTICE", out / "NOTICE", values)
    write_template("README.md", out / "README.md", values)

    generated = {
        "generator": "c2das scripts/export_dasquake.py",
        "c2das_repository": "https://github.com/lookibed/c2das",
        "c2das_commit": head,
        "c2das_dirty": dirty,
        "quakegeneric_repository": "https://github.com/erysdren/quakegeneric",
        "quakegeneric_commit": upstream,
        "generated_at": datetime.datetime.now().astimezone().isoformat(timespec="seconds"),
        "translations": {
            "quake": {"case": STD_CASE, "source_root": std["source_root"],
                      "translation_units": std["translation_units"],
                      "clang": std["clang"], "command": std_command, "files": quake_files},
            "eden": {"case": EDEN_CASE, "source_root": eden["source_root"],
                     "translation_units": units, "play_module": module,
                     "clang": {**eden["clang"], "flags": play_flags},
                     "command": play_command, "files": eden_files},
        },
    }
    (out / "GENERATED.json").write_text(json.dumps(generated, indent=2) + "\n")
    print(f"dasQUAKE exported to {out}: quake/ {len(quake_files)} files, eden/ {len(eden_files)} translated files")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
