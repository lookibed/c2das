#!/usr/bin/env python3
"""Regenerate the dasDOOM repository tree from this c2das checkout.

usage: python3 scripts/export_dasdoom.py <out-dir>

dasDOOM is doomgeneric (the Doom engine) translated to daslang by c2das.  The
tree is generated; nothing in it is edited by hand except through this script
and the c2das sources it copies.  Existing content of <out-dir> is kept except
the generated directories `doom/` and `eden/` and the generated top-level
files, which are rewritten (a `.git` directory there is left alone).

- `doom/`: the `--libc std` timedemo program translated exactly like the case
  `doomgeneric-demo1-std-source` of tests/canonical/cases.json (its units,
  clang flags, libc and das_options, `--module-layout source`): one daslang
  module per C file or cluster, the `.das.inc` fragments and `c2da_runtime.das`.
  `run.sh` runs it on doom1.wad and compares the 70 frame hashes with
  `expected_frames.txt` (the case's expected stdout).
- `eden/`: the EdenSpark play build, `src/doom_eden_play_all.c` translated with
  the flags of the case `doomgeneric-demo1-eden-linear` plus `--public-module`
  and `-Isrc/eden_play_include` (docs/eden-flags.md, "Doom played interactively
  in the editor"), the hand-written host `eden/c2das_doom_player.das` and an
  example project `main.das`.  The play build is one translation unit: the
  harness `dg_eden_play.c` calls `dg_eden_sound.c`'s file-static functions, so
  it has no `--module-layout source` form yet.
- `harness/`: the c2das-authored C harness files the translations include.
- `tools/get_wad.sh`, `LICENSE`, `NOTICE`, `README.md`, `GENERATED.json`.

The translator is `$C2DAS_TRANSPILE` when set, otherwise this checkout's
release build (`cargo build --release -p c2dascript-transpile` is run first).
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
TEMPLATES = ROOT / "scripts" / "dasdoom"
CASES = ROOT / "tests" / "canonical" / "cases.json"
DOOM = ROOT / "tests" / "manual" / "doomgeneric"
STD_CASE = "doomgeneric-demo1-std-source"
EDEN_CASE = "doomgeneric-demo1-eden-linear"
PLAY_ENTRY = "src/doom_eden_play_all.c"
PLAY_EXTRA_FLAGS = ["-Isrc/eden_play_include"]
HOST = DOOM / "eden" / "c2das_doom_player.das"
# The host is written for the c2das editor install (modules/c2das/doom/); in a
# dasDOOM install the translated module sits next to it in modules/dasdoom/.
HOST_REQUIRE_FROM = "require modules/c2das/doom/doom_eden_play_all"
HOST_REQUIRE_TO = "require modules/dasdoom/doom_eden_play_all"
HARNESS = ["engine_config.h", "all.c", "doom_entry.c", "dg_platform.c",
           "doom_eden_play_all.c", "dg_eden_play.c", "dg_eden_sound.c",
           "eden_play_include/SDL_mixer.h"]


def fail(message: str) -> None:
    sys.exit(f"export_dasdoom: {message}")


def run(command: list[str], cwd: Path) -> None:
    result = subprocess.run(command, cwd=cwd, text=True, capture_output=True)
    if result.returncode != 0:
        fail(f"command failed ({result.returncode}): {' '.join(command)}\n"
             f"{result.stdout[-3000:]}\n{result.stderr[-3000:]}")


def git(*args: str) -> str:
    return subprocess.run(["git", *args], cwd=ROOT, text=True, capture_output=True).stdout.strip()


def translator() -> Path:
    explicit = os.environ.get("C2DAS_TRANSPILE")
    if explicit:
        return Path(explicit).resolve()
    run(["cargo", "build", "-q", "--release", "-p", "c2dascript-transpile"], ROOT)
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


def translate_std(tool: Path, c: dict, work: Path) -> tuple[Path, list[str]]:
    src = ROOT / c["source_root"]
    compiler = c["clang"].get("compiler", "clang-18")
    flags = c["clang"]["flags"]
    database = work / "std-db" / "compile_commands.json"
    database.parent.mkdir()
    database.write_text(json.dumps([
        {"directory": str(src), "file": str(src / unit), "arguments": [compiler, *flags, str(src / unit)]}
        for unit in c["translation_units"]], indent=2))
    out = work / "std"
    out.mkdir()
    command = [str(tool), "--strict", *policy_flags(c), "--output-dir", str(out),
               "--module-layout", "source", str(database)]
    run(command, src)
    shown = ["c2dascript-transpile", "--strict", *policy_flags(c), "--output-dir", "doom",
             "--module-layout", "source", "compile_commands.json"]
    return out, shown


def translate_play(tool: Path, c: dict, work: Path) -> tuple[Path, list[str]]:
    src = ROOT / c["source_root"]
    clang_flags = [*c["clang"]["flags"], *PLAY_EXTRA_FLAGS]
    out = work / "eden"
    out.mkdir()
    tail = ["--strict", "--public-module", *policy_flags(c)]
    command = [str(tool), *tail, "--output-dir", str(out), "--file", PLAY_ENTRY, *clang_flags]
    run(command, src)
    shown = ["c2dascript-transpile", *tail, "--output-dir", "eden", "--file", PLAY_ENTRY, *clang_flags]
    return out, shown


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
        fail("usage: export_dasdoom.py <out-dir>")
    out = Path(sys.argv[1]).resolve()
    out.mkdir(parents=True, exist_ok=True)
    cases = json.loads(CASES.read_text())["cases"]
    std, eden = case(cases, STD_CASE), case(cases, EDEN_CASE)
    head = git("rev-parse", "HEAD")
    dirty = bool(git("status", "--porcelain", "--untracked-files=no"))
    tool = translator()

    with tempfile.TemporaryDirectory(prefix="dasdoom-") as scratch:
        work = Path(scratch)
        std_out, std_command = translate_std(tool, std, work)
        play_out, play_command = translate_play(tool, eden, work)
        check_no_local_paths(std_out)
        check_no_local_paths(play_out)
        doom_files = copy_generated(std_out, out / "doom")
        eden_files = copy_generated(play_out, out / "eden")

    expected = std["expected"]["stdout"]
    (out / "doom" / "expected_frames.txt").write_text(expected)
    shutil.copyfile(TEMPLATES / "run.sh", out / "doom" / "run.sh")
    (out / "doom" / "run.sh").chmod(0o755)

    host = HOST.read_text()
    if host.count(HOST_REQUIRE_FROM) != 1:
        fail(f"{HOST.relative_to(ROOT)}: expected one `{HOST_REQUIRE_FROM}`")
    (out / "eden" / HOST.name).write_text(host.replace(HOST_REQUIRE_FROM, HOST_REQUIRE_TO))
    shutil.copyfile(TEMPLATES / "main.das", out / "eden" / "main.das.example")

    harness = out / "harness"
    if harness.exists():
        shutil.rmtree(harness)
    for name in HARNESS:
        (harness / name).parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(DOOM / "src" / name, harness / name)

    (out / "tools").mkdir(exist_ok=True)
    shutil.copyfile(TEMPLATES / "get_wad.sh", out / "tools" / "get_wad.sh")
    (out / "tools" / "get_wad.sh").chmod(0o755)
    shutil.copyfile(DOOM / "upstream" / "doomgeneric" / "LICENSE", out / "LICENSE")
    shutil.copyfile(TEMPLATES / "gitignore", out / ".gitignore")

    short = head[:9] + ("-dirty" if dirty else "")
    upstream = re.search(r"`([0-9a-f]{40})`", (DOOM / "UPSTREAM.md").read_text()).group(1)
    values = {"C2DAS_COMMIT": head + ("-dirty" if dirty else ""), "C2DAS_SHORT": short,
              "UPSTREAM_COMMIT": upstream,
              "DOOM_MODULES": str(sum(n.endswith(".das") for n in doom_files)),
              "DOOM_INCS": str(sum(n.endswith(".das.inc") for n in doom_files))}
    write_template("NOTICE", out / "NOTICE", values)
    write_template("README.md", out / "README.md", values)

    generated = {
        "generator": "c2das scripts/export_dasdoom.py",
        "c2das_repository": "https://github.com/lookibed/c2das",
        "c2das_commit": head,
        "c2das_dirty": dirty,
        "doomgeneric_repository": "https://github.com/ozkl/doomgeneric",
        "doomgeneric_commit": upstream,
        "generated_at": datetime.datetime.now().astimezone().isoformat(timespec="seconds"),
        "translations": {
            "doom": {"case": STD_CASE, "source_root": std["source_root"],
                     "translation_units": std["translation_units"],
                     "clang": std["clang"], "command": std_command, "files": doom_files},
            "eden": {"case": EDEN_CASE, "source_root": eden["source_root"],
                     "entry": PLAY_ENTRY, "command": play_command, "files": eden_files},
        },
    }
    (out / "GENERATED.json").write_text(json.dumps(generated, indent=2) + "\n")
    print(f"dasDOOM exported to {out}: doom/ {len(doom_files)} files, eden/ {len(eden_files)} translated files")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
