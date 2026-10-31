#!/usr/bin/env python3
"""Regenerate the dasDOOM repository tree from this c2das checkout.

usage: python3 scripts/export_dasdoom.py <out-dir>

dasDOOM is doomgeneric (the Doom engine) translated to daslang by c2das.  The
tree is generated; nothing in it is edited by hand except through this script
and the c2das sources it copies.  Existing content of <out-dir> is kept except
the generated directories `doom/`, `eden/`, `sdl/` and `harness/` and the generated top-level
files, which are rewritten (a `.git` directory there is left alone).

- `doom/`: the `--libc std` timedemo program translated exactly like the case
  `doomgeneric-demo1-std-source` of tests/canonical/cases.json (its units,
  clang flags, libc and das_options, `--module-layout source`): one daslang
  module per C file or cluster, the `.das.inc` fragments and the shared runtime
  `dasdoom_runtime.das` (`--runtime-module dasdoom_runtime`, also for `eden/`, so
  the runtime module does not collide with dasQUAKE's in one EdenSpark project).
  `run.sh` runs it on doom1.wad and compares the 70 frame hashes with
  `expected_frames.txt` (the case's expected stdout).  One unit is added to the
  case's: the SDL3 harness's host API `sdl/dg_host.c` (module `dg_host.das`,
  which no engine module requires, so the engine modules are the case's), and
  the harness's daslang host `sdl/doom_sdl.das` is staged as
  `doom/doom_sdl.das` with its `require` of the whole-unit module replaced by
  the runtime and `dg_host`.
- `sdl/run.bat`: runs that host with `daslang -jit` (or the interpreter)
  through dasSDL3 on Windows.
- `eden/`: the EdenSpark play build in the per-file layout: the translation
  units of `src/doom_eden_play_all.c` (the engine files `src/all.c` includes,
  then the harness files `dg_eden_sound.c` and `dg_eden_play.c`) translated
  with `--module-layout source` and the flags of the case
  `doomgeneric-demo1-eden-linear` plus `--public-module`,
  `-Isrc/eden_play_include`, `-include engine_config.h` (the configuration
  `all.c` sets) and `-DFEATURE_SOUND=1` (docs/eden-flags.md, "Doom played
  interactively in the editor"); the hand-written host
  `eden/c2das_doom_player.das` and an example project `main.das`.
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
# `doom_eden_play_all.c` sets these for the unity build before `#include "all.c"`;
# each separate unit gets them from the command line.
PLAY_EXTRA_FLAGS = ["-Isrc/eden_play_include", "-include", "engine_config.h", "-DFEATURE_SOUND=1"]
HOST = DOOM / "eden" / "c2das_doom_player.das"
# The host is written for the c2das editor install (modules/c2das/doom/); in a
# dasDOOM install the translated modules sit next to it in modules/dasdoom/.
HOST_REQUIRE_FROM = "require modules/c2das/doom/"
HOST_REQUIRE_TO = "require modules/dasdoom/"
# The shared runtime module is named per program (`--runtime-module`), so dasDOOM
# and dasQUAKE can be installed in one EdenSpark project: two modules named
# `c2da_runtime` are a module name collision there.  The host requires the c2das
# default name; the export rewrites that require.
RUNTIME_MODULE = "dasdoom_runtime"
HOST_RUNTIME_FROM = HOST_REQUIRE_FROM + "c2da_runtime\n"
HOST_RUNTIME_TO = HOST_REQUIRE_FROM + RUNTIME_MODULE + "\n"
# The desktop SDL3 host (tests/manual/doomgeneric/sdl/): its host API `dg_host.c`
# joins the `doom/` translation as one more unit (module `dg_host`, which no engine
# unit depends on), and the daslang host `doom_sdl.das` is staged beside it in
# `doom/`: daslang resolves a `require` from the requiring file's directory and
# has no `..`, so the host lives with the modules it requires.  `sdl/` holds the
# launchers.
SDL = DOOM / "sdl"
SDL_UNIT = "sdl/dg_host.c"
SDL_HOST = SDL / "doom_sdl.das"
SDL_REQUIRE_FROM = "require doom_host_all\n"
SDL_REQUIRE_TO = f"require {RUNTIME_MODULE}\nrequire dg_host\n"
HARNESS = ["engine_config.h", "all.c", "doom_entry.c", "dg_platform.c",
           "doom_eden_play_all.c", "dg_eden.h", "dg_eden_play.c", "dg_eden_sound.c",
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
    layout = ["--module-layout", "source", "--runtime-module", RUNTIME_MODULE]
    command = [str(tool), "--strict", *options, "--output-dir", str(out), *layout, str(database)]
    run(command, src)
    shown = ["c2dascript-transpile", "--strict", *options, "--output-dir", name,
             *layout, "compile_commands.json"]
    return out, shown


def included(path: Path) -> list[str]:
    """The `#include "…"` names of a C file, in order."""
    return re.findall(r'^#include "([^"]+)"', path.read_text(), re.MULTILINE)


def play_units(std: dict) -> list[str]:
    """The translation units of the play build: the files `doom_eden_play_all.c`
    includes, with `all.c` expanded to the engine units (the upstream units of
    the std case, checked against `all.c`'s includes)."""
    engine = [u for u in std["translation_units"] if not u.startswith("src/")]
    all_c = [n for n in included(DOOM / "src" / "all.c") if n != "dg_platform.c"]
    if [Path(u).name for u in engine] != all_c:
        fail(f"the engine units of {STD_CASE} differ from the includes of src/all.c")
    units: list[str] = []
    for name in included(DOOM / PLAY_ENTRY):
        units += engine if name == "all.c" else ["src/" + name]
    return units


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
        doom_units = [*std["translation_units"], SDL_UNIT]
        std_out, std_command = translate_source(tool, std, "doom", doom_units,
                                                std["clang"]["flags"], policy_flags(std), work)
        units = play_units(std)
        play_flags = [*eden["clang"]["flags"], *PLAY_EXTRA_FLAGS]
        play_out, play_command = translate_source(tool, eden, "eden", units, play_flags,
                                                  ["--public-module", *policy_flags(eden)], work)
        check_no_local_paths(std_out)
        check_no_local_paths(play_out)
        doom_files = copy_generated(std_out, out / "doom")
        eden_files = copy_generated(play_out, out / "eden")

    expected = std["expected"]["stdout"]
    (out / "doom" / "expected_frames.txt").write_text(expected)
    shutil.copyfile(TEMPLATES / "run.sh", out / "doom" / "run.sh")
    (out / "doom" / "run.sh").chmod(0o755)

    # The SDL3 host is written against the harness's whole-unit module
    # `doom_host_all`; here the runtime and the host API are separate modules.
    # A context option such as the stack size belongs to the program, whose root
    # is the host script (translate.sh prepends the case's options the same way).
    sdl_host = SDL_HOST.read_text()
    if sdl_host.count(SDL_REQUIRE_FROM) != 1 or not sdl_host.startswith("options gen2\n"):
        fail(f"{SDL_HOST.relative_to(ROOT)}: expected `options gen2` first and one `{SDL_REQUIRE_FROM.strip()}`")
    sdl_options = "".join(f"options {option}\n" for option in std.get("das_options", []))
    sdl_host = "options gen2\n" + sdl_options + sdl_host[len("options gen2\n"):]
    (out / "doom" / SDL_HOST.name).write_text(sdl_host.replace(SDL_REQUIRE_FROM, SDL_REQUIRE_TO))
    sdl_dir = out / "sdl"
    if sdl_dir.exists():
        shutil.rmtree(sdl_dir)
    sdl_dir.mkdir()
    # cmd.exe misreads labels in LF-only batch files: written with CRLF.
    bat = (TEMPLATES / "sdl" / "run.bat").read_text()
    (sdl_dir / "run.bat").write_text(bat, newline="\r\n")

    host = HOST.read_text()
    if host.count(HOST_REQUIRE_FROM) == 0 or host.count(HOST_RUNTIME_FROM) != 1:
        fail(f"{HOST.relative_to(ROOT)}: expected `{HOST_REQUIRE_FROM}…` requires, "
             f"one of them `{HOST_RUNTIME_FROM.strip()}`")
    host = host.replace(HOST_RUNTIME_FROM, HOST_RUNTIME_TO)
    (out / "eden" / HOST.name).write_text(host.replace(HOST_REQUIRE_FROM, HOST_REQUIRE_TO))
    shutil.copyfile(TEMPLATES / "main.das", out / "eden" / "main.das.example")

    harness = out / "harness"
    if harness.exists():
        shutil.rmtree(harness)
    for name in HARNESS:
        (harness / name).parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(DOOM / "src" / name, harness / name)
    (harness / "sdl").mkdir()
    shutil.copyfile(SDL / "dg_host.c", harness / "sdl" / "dg_host.c")

    (out / "tools").mkdir(exist_ok=True)
    shutil.copyfile(TEMPLATES / "get_wad.sh", out / "tools" / "get_wad.sh")
    (out / "tools" / "get_wad.sh").chmod(0o755)
    shutil.copyfile(DOOM / "upstream" / "doomgeneric" / "LICENSE", out / "LICENSE")
    shutil.copyfile(TEMPLATES / "gitignore", out / ".gitignore")
    shutil.copyfile(TEMPLATES / "gitattributes", out / ".gitattributes")

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
                     "translation_units": doom_units,
                     "sdl_host": {"source": str(SDL_HOST.relative_to(ROOT)),
                                  "staged_as": "doom/" + SDL_HOST.name},
                     "clang": std["clang"], "command": std_command, "files": doom_files},
            "eden": {"case": EDEN_CASE, "source_root": eden["source_root"],
                     "entry": PLAY_ENTRY, "translation_units": units,
                     "clang": {**eden["clang"], "flags": play_flags},
                     "command": play_command, "files": eden_files},
        },
    }
    (out / "GENERATED.json").write_text(json.dumps(generated, indent=2) + "\n")
    print(f"dasDOOM exported to {out}: doom/ {len(doom_files)} files, eden/ {len(eden_files)} translated files")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
