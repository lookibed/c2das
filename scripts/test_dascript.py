#!/usr/bin/env python3
"""c2dascript unit test runner — адаптация c2rust test_translator.py.
Transpile .c → .das via WSL, verify via daslang.exe.
"""

import argparse, os, re, subprocess, sys, tempfile, json, platform
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

ROOT = Path(__file__).resolve().parent.parent
UNIT_DIR = ROOT / "tests" / "unit"

class C:
    GREEN = "\033[92m"; RED = "\033[91m"; BLUE = "\033[94m"
    YELLOW = "\033[93m"; NC = "\033[0m"

TRANSPILER = DASLANG = None; JOBS = 4

def find_bin(name):
    ext = ".exe" if platform.system() == "Windows" else ""
    for d in ["release", "debug"]:
        p = ROOT / "target" / d / f"{name}{ext}"
        if p.is_file(): return p
    return None

def find_daslang():
    for c in [ROOT.parent / "daScript" / "bin" / "Release" / "daslang.exe",
              Path("X:") / "daScript" / "bin" / "Release" / "daslang.exe"]:
        if c.exists(): return c
    return None

def transpile_one(c_path, das_path):
    """Transpile via WSL (works from both Windows and WSL)."""
    is_win = platform.system() == "Windows"
    is_wsl = "microsoft" in platform.uname().release.lower() if not is_win else False
    wsl_root = "/mnt/d/Backups/с2daslang/c2dascript"

    if is_win:
        wsl_c = str(c_path).replace("D:\\","/mnt/d/").replace("\\","/")
        wsl_tp = str(TRANSPILER).replace("D:\\","/mnt/d/").replace("\\","/")
        cc = json.dumps([{"arguments":["clang",wsl_c],"directory":".","file":wsl_c}])
        cmd = f'cd {wsl_root} && echo \'{cc}\' > /tmp/cc_.json && {wsl_tp} /tmp/cc_.json -w 2>/dev/null; rm -f /tmp/cc_.json'
        subprocess.run(["wsl","bash","-c",cmd], timeout=120)
    elif is_wsl:
        cc = [{"arguments":["clang",str(c_path)],"directory":".","file":str(c_path)}]
        with tempfile.NamedTemporaryFile(mode="w",suffix=".json",delete=False) as f:
            json.dump(cc,f); cp = f.name
        subprocess.run([str(TRANSPILER),cp,"-w"], capture_output=True, timeout=120)
        os.unlink(cp)
    else:
        return False
    if not das_path.exists(): return False
    t = das_path.read_text()
    return any(kw in t for kw in ["\ndef ","\nstruct ","\nenum ","\nvar ","\n[export]"])

def verify_daslang(das_path):
    if DASLANG is None: return True
    r = subprocess.run([str(DASLANG), str(das_path)], capture_output=True, timeout=30)
    return r.returncode == 0

def discover(path):
    s = path / "src"
    if not s.is_dir(): return
    for f in sorted(s.iterdir()):
        if f.suffix == ".c": yield f.stem, f

def run_one(name, c_path):
    das = c_path.with_suffix(".das")
    ok = transpile_one(c_path, das)
    if not ok: return name, "FAIL_TRANSPILE"
    if DASLANG:
        return name, "PASS" if verify_daslang(das) else "FAIL_DASLANG"
    return name, "PASS"

def main():
    global TRANSPILER, DASLANG, JOBS
    p = argparse.ArgumentParser()
    p.add_argument("--dir", default=str(UNIT_DIR))
    p.add_argument("--jobs", type=int, default=4)
    p.add_argument("--filter", default=".*")
    p.add_argument("--daslang", default=None)
    p.add_argument("--no-daslang", action="store_true")
    args = p.parse_args(); JOBS = args.jobs
    filt = re.compile(args.filter)

    TRANSPILER = find_bin("c2dascript-transpile")
    if not TRANSPILER:
        print(f"{C.RED}Build c2dascript-transpile first: cargo build --release -p c2dascript-transpile{C.NC}")
        sys.exit(1)
    print(f"{C.BLUE}TRANSPILER:{C.NC} {TRANSPILER}")

    if args.daslang: DASLANG = Path(args.daslang)
    elif not args.no_daslang: DASLANG = find_daslang()
    print(f"{C.BLUE}DASLANG:{C.NC} {DASLANG or '(not found, skipping verification)'}{C.YELLOW if not DASLANG else ''}{C.NC}")

    tests = [(n,c) for e in sorted(Path(args.dir).iterdir()) if e.is_dir() and filt.search(e.name)
             for n,c in discover(e)]
    if not tests: print(f"{C.YELLOW}No tests{C.NC}"); return

    print(f"\nRunning {len(tests)} tests x{JOBS}...\n")
    res = {}
    with ThreadPoolExecutor(max_workers=JOBS) as ex:
        for f in as_completed({ex.submit(run_one,n,c):n for n,c in tests}):
            n,s = f.result(); res[s] = res.get(s,0)+1
            col = C.GREEN if s=="PASS" else C.RED
            print(f"  {col}[{s:14s}]{C.NC} {n}")

    print(f"\n=== {res.get('PASS',0)} PASS, {res.get('FAIL_TRANSPILE',0)} FAIL_TRANSPILE, "
          f"{res.get('FAIL_DASLANG',0)} FAIL_DASLANG / {len(tests)} total ===")
    if res.get("FAIL_TRANSPILE",0) > 0 or res.get("FAIL_DASLANG",0) > 0: sys.exit(1)

if __name__ == "__main__":
    main()
