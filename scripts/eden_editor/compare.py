#!/usr/bin/env python3
"""Compare the C2DAS BEGIN/END blocks of an EdenSpark editor log with the cases' expected stdout.

usage: compare.py <log> <expected-dir>

The editor console carries, after every printed line, a `file:line (function)` line, and shows
the program's stderr (to_log at LOG_ERROR) prefixed with `[E]`; both are dropped, so what is
compared is the program's stdout, as the canonical runner compares it.  Lines a program writes to
stderr through a stdio redirect still reach the console without the prefix; a case whose stdout
lines all appear in order with only such extra lines between them is reported `PASS (+N extra)`.
"""
import re
import sys
from pathlib import Path

log, exp_dir = Path(sys.argv[1]), Path(sys.argv[2])
lines = [l for l in log.read_text(errors="replace").splitlines()
         if l.strip() and not re.match(r"^\S.*\.das(\.inc)?:\d+(:\d+)? \(", l) and not l.startswith("[E]")]
blocks, cur, buf = {}, None, []
for l in lines:
    m = re.match(r"C2DAS BEGIN (\S+)", l)
    if m:
        cur, buf = m.group(1), []
        continue
    m = re.match(r"C2DAS END (\S+) ret=(-?\d+)(?: ms=(\d+))?", l)
    if m and cur == m.group(1):
        blocks[cur] = (buf, m.group(2), m.group(3))
        cur = None
        continue
    if cur:
        buf.append(l)
ok = True
for f in sorted(exp_dir.glob("*.expected.txt")):
    cid = f.name[: -len(".expected.txt")]
    if cid not in blocks:
        print(f"MISSING {cid}")
        ok = False
        continue
    got, ret, ms = blocks[cid]
    want = f.read_text().splitlines()
    timing = f" ms={ms}" if ms else ""
    if got == want:
        print(f"PASS {cid} ret={ret}{timing}")
        continue
    it = iter(got)
    if all(any(g == w for g in it) for w in want):
        print(f"PASS {cid} ret={ret}{timing} (+{len(got) - len(want)} extra lines, stderr)")
        continue
    ok = False
    print(f"FAIL {cid} ret={ret}{timing}")
    for i, (a, b) in enumerate(zip(got + [""] * len(want), want + [""] * len(got))):
        if a != b:
            print(f"   line {i}: got {a!r}\n           want {b!r}")
            break
sys.exit(0 if ok else 1)
