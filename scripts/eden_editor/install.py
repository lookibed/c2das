#!/usr/bin/env python3
"""Translate c2das eden cases into an EdenSpark project and write a main.das with one cheat per case.

usage: install.py <project-dir> <case-id> ...   (normally called by run.sh)

Each case is translated with its cases.json flags (plus C2DAS_EXTRA, and `--public-module`) into a
scratch dir, then its files are written into <project>/modules/c2das/<module>/: the editor holds
open files, so files are rewritten in place, never renamed.  A single-unit case's module is renamed
`c2das_<n>_<stem>` so several cases can share one program; a multi-unit case keeps its module
names, so only one multi-unit case can be installed at a time (they all have `c2da_runtime`).
Under `--entry eden` the case's `program_args` files are copied to <project>/assets/c2das/*.data;
the cheat `c2das_load` requests them, and the case's cheat registers them with
`c2da_eden_add_file` and calls `c2da_eden_start`.  main.das gets `[cheat] def c2das_<n>()` printing
`C2DAS BEGIN/END <id> ret=<r> ms=<t>`, and `c2das_all` runs every case.  The project's original
main.das is kept as main.das.orig (written once).  The editor keeps every `.das` of the project in
one context, so remove earlier installs from modules/c2das/ to stay under its 100 MiB heap.
"""
import json, os, re, shutil, subprocess, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
TRANSPILE = Path(os.environ.get("C2DAS_TRANSPILE", str(ROOT / "target/debug/c2dascript-transpile")))
proj = Path(sys.argv[1])
ids = sys.argv[2:]
cases = json.load(open(ROOT / "tests/canonical/cases.json"))
cases = cases if isinstance(cases, list) else cases.get("cases", cases)
by_id = {c["id"]: c for c in cases}

dest_root = proj / "modules" / "c2das"
dest_root.mkdir(parents=True, exist_ok=True)
scratch = Path(os.environ.get("C2DAS_EXPECTED_DIR", "/tmp")).parent / "gen"
if scratch.exists():
    shutil.rmtree(scratch)

requires, cheats, calls, asset_names = [], [], [], []
for n, cid in enumerate(ids):
    c = by_id[cid]
    src = ROOT / c["source_root"]
    entry = src / c["translation_entry"]
    stem = re.sub(r"\W", "_", entry.stem)
    mod = f"c2das_{n}_{stem}"
    out = scratch / mod
    out.mkdir(parents=True)
    flags = ["--strict", "--public-module"]
    extra = os.environ.get("C2DAS_EXTRA", "").split()
    own = c.get("translator_flags", [])
    i = 0
    while i < len(extra):
        tok = extra[i]
        takes = i + 1 < len(extra) and not extra[i + 1].startswith("--")
        if tok not in own:
            flags += extra[i:i + 2] if takes else [tok]
        i += 2 if takes else 1
    if c.get("libc"):
        flags += ["--libc", c["libc"]]
    for o in c.get("das_options", []):
        flags += ["--das-option", o]
    flags += c.get("translator_flags", [])
    cflags = [f if not f.startswith("-I") else "-I" + str(src / f[2:]) for f in c["clang"].get("flags", [])]
    cflags = [f if not (f.startswith("-include") and False) else f for f in cflags]
    units = c.get("translation_units")
    if units:
        db = [{"directory": str(src), "file": str(src / u),
               "arguments": [c["clang"].get("compiler", "clang-18"), *cflags, str(src / u)]} for u in units]
        dbf = out / "compile_commands.json"
        dbf.write_text(json.dumps(db))
        r = subprocess.run([str(TRANSPILE), *flags, "--module-layout", "source", "--output-dir", str(out), str(dbf)],
                           capture_output=True, text=True, cwd=src)
    else:
        r = subprocess.run([str(TRANSPILE), *flags, "--output-dir", str(out), "--file", str(entry), *cflags],
                           capture_output=True, text=True, cwd=src)
    if r.returncode != 0:
        sys.exit(f"{cid}: translation failed\n{r.stdout[-2000:]}\n{r.stderr[-2000:]}")
    (dest_root / mod).mkdir(exist_ok=True)
    if units:
        for g in out.iterdir():
            if g.suffix in (".das", ".inc"):
                (dest_root / mod / g.name).write_text(g.read_text())
        text = (out / (entry.stem + ".das")).read_text()
        m = re.search(r"^module (\S+)", text, flags=re.M)
        if not m:
            sys.exit(f"{cid}: entry module {entry.stem}.das has no module name")
        requires.append(f"require modules/c2das/{mod}/{entry.stem}")
        mod_name = m.group(1)
        rt_name = mod_name
        if (out / "c2da_runtime.das").exists():
            requires.append(f"require modules/c2das/{mod}/c2da_runtime")
            rt_name = "c2da_runtime"
    else:
        gen = out / (entry.stem + ".das")
        text = gen.read_text()
        text = re.sub(r"^module \S+", f"module {mod}", text, count=1, flags=re.M)
        (dest_root / mod / (mod + ".das")).write_text(text)
        requires.append(f"require modules/c2das/{mod}/{mod}")
        mod_name = mod
        rt_name = mod
    ep = c["das_entrypoint"]
    expected = c["expected"].get("stdout", "")
    args = c.get("program_args", [])
    if "def c2da_eden_start" in text:
        reg = ""
        for a in args:
            base = Path(a).name
            assets = proj / "assets" / "c2das"
            assets.mkdir(parents=True, exist_ok=True)
            dst = assets / (base + ".data")
            if not dst.exists():
                shutil.copy(src / a, dst)
            asset_names.append(base)
            reg += (f"    var b_{len(asset_names)} <- c2das_asset_bytes(\"{base}\")\n"
                    f"    if (length(b_{len(asset_names)}) == 0) {{\n        print(\"C2DAS asset not loaded: {base}\")\n        return\n    }}\n"
                    f"    {rt_name}::c2da_eden_add_file(\"{base}\", b_{len(asset_names)})\n")
        argv = ", ".join(['"prog"'] + [f'"{Path(a).name}"' for a in args])
        call = f"{mod_name}::c2da_eden_start([{argv}])"
    else:
        reg = ""
        call = f"{mod_name}::{ep}()"
    cheats.append(
        f"[cheat]\ndef c2das_{n}() {{\n{reg}    print(\"C2DAS BEGIN {cid}\")\n    let t0 = ref_time_ticks()\n"
        f"    let r = {call}\n"
        f"    print(\"C2DAS END {cid} ret={{r}} ms={{get_time_usec(t0) / 1000}}\")\n}}\n")
    calls.append(f"    c2das_{n}()")
    exp_dir = Path(os.environ.get("C2DAS_EXPECTED_DIR", "/tmp"))
    exp_dir.mkdir(parents=True, exist_ok=True)
    (exp_dir / f"{cid}.expected.txt").write_text(expected)

orig = proj / "main.das.orig"
if not orig.exists():
    shutil.copy(proj / "main.das", orig)
main = orig.read_text()
head, sep, rest = main.partition("\n")
body = "\n".join(requires) + "\n"
loader = (
    "var c2das_asset_ids : table<string; TextId>\n\n"
    "[cheat]\ndef c2das_load() {\n"
    + "".join(f"    c2das_asset_ids[\"{a}\"] = request_text(\"assets/c2das/{a}.data\")\n" for a in asset_names)
    + "    print(\"C2DAS requested {length(c2das_asset_ids)} assets\")\n}\n\n"
    "def c2das_asset_bytes(name : string) : array<uint8> {\n"
    "    var bytes : array<uint8>\n"
    "    if (key_exists(c2das_asset_ids, name)) {\n"
    "        get_binary_asset(c2das_asset_ids[name]) $(data) {\n"
    "            resize(bytes, length(data))\n"
    "            for (i in range(length(data))) {\n                bytes[i] = data[i]\n            }\n"
    "        }\n    }\n    return <- bytes\n}\n")
opts = os.environ.get("C2DAS_MAIN_OPTIONS", "")
main_new = (opts + "\n" if opts else "") + head + "\n" + body + rest + \
    "\n\n// --- c2das editor probes (generated) ---\n" + loader + "\n".join(cheats) + \
    "\n[cheat]\ndef c2das_all() {\n" + "\n".join(calls) + "\n    print(\"C2DAS ALL DONE\")\n}\n"
(proj / "main.das").write_text(main_new)
print("installed", len(ids), "cases into", dest_root)
