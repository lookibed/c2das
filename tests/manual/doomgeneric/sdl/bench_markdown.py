#!/usr/bin/env python3
"""Render bench.sh's samples as a dasProfile-style Markdown snapshot.

    bench_markdown.py --samples <file> --facts <file> --output <path> [--reps N] [--frames N]

`--samples` is what bench.sh collects while it runs, one line per variant × mode:

    <variant>\t<mode>\t<status>\t<fps samples, space-separated>\t<setup_us samples>

(`status` is `ok` or a `FAIL-*` word; a failed line has no samples and renders as `-`).
`--facts` is a `key=value` file of platform information (`date`, `commit`, `cpu`, `os`,
`daslang`, `sdl`, `msvc`, `clang_cl`); a missing key renders as `unavailable`.

The snapshot: platform bullets, one legend sentence, then three tables — frames per
second (higher is better), the slowdown against the `clang_native` C build (lower is
better) and the engine's start-up — with `median ±spread%` cells, where `±` is half the
sample range as a share of the median, and the best cell of every row in bold.  It is the
same layout as `docs/corpus-benchmark.md`'s Linux snapshot (`scripts/corpus_matrix.py`), so
the two sit side by side in the README.  This script only formats; every number comes from
the samples file.
"""

from __future__ import annotations

import argparse
import statistics
import sys
from pathlib import Path

MODES = ("window", "dummy", "nopresent")
# variant key -> (row label, build or run command), the C builds as build_c.bat names them
VARIANTS = {
    "c:msvc_O2": ("C msvc_O2", "`cl /O2 /MD`"),
    "c:msvc_avx2": ("C msvc_avx2", "`cl /O2 /arch:AVX2 /MD`"),
    "c:clang_O2": ("C clang_O2", "`clang-cl /O2 /MD` (generic x86-64)"),
    "c:clang_native": ("C clang_native", "`clang-cl /O2 /clang:-march=native /MD`"),
    "interp": ("DAS interpreter", "`daslang doom_sdl.das`"),
    "jit": ("DAS JIT", "`daslang -jit doom_sdl.das`"),
    "aot": ("DAS AOT\\*", "`daslang -use-aot doom_sdl.das`, generated C++ built by MSVC `/O2 /arch:AVX2`"),
}
REFERENCE = "c:clang_native"
NO_VALUE = "-"


def spread(values: list[float]) -> str:
    med = statistics.median(values)
    if len(values) < 2 or med <= 0:
        return "±0%"
    return f"±{(max(values) - min(values)) / 2.0 / med * 100.0:.0f}%"


def read_samples(path: Path) -> dict[tuple[str, str], dict[str, list[float]]]:
    samples: dict[tuple[str, str], dict[str, list[float]]] = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        fields = line.split("\t")
        variant, mode, status = fields[0], fields[1], fields[2]
        if status != "ok" or len(fields) < 5:
            samples[(variant, mode)] = {"fps": [], "setup_ms": []}
            continue
        samples[(variant, mode)] = {
            "fps": [float(v) for v in fields[3].split()],
            "setup_ms": [float(v) / 1000.0 for v in fields[4].split()],
        }
    return samples


def read_facts(path: Path | None) -> dict[str, str]:
    facts: dict[str, str] = {}
    if path is None or not path.is_file():
        return facts
    for line in path.read_text(encoding="utf-8").splitlines():
        key, sep, value = line.partition("=")
        if sep and value.strip():
            facts[key.strip()] = value.strip()
    return facts


def table(headings: list[str], rows: list[list[str]]) -> list[str]:
    out = ["| " + " | ".join(headings) + " |", "| --- |" + " ---: |" * (len(headings) - 1)]
    out.extend("| " + " | ".join(row) + " |" for row in rows)
    out.append("")
    return out


def bold_best(cells: list[tuple[float | None, str]], *, higher: bool) -> list[str]:
    valid = [key for key, _ in cells if key is not None]
    best = (max(valid) if higher else min(valid)) if valid else None
    out: list[str] = []
    for key, text in cells:
        if key is not None and key == best:
            head, sep, tail = text.partition(" ")
            text = f"**{head}**{sep}{tail}"
        out.append(text)
    return out


def render(samples: dict[tuple[str, str], dict[str, list[float]]], facts: dict[str, str],
           reps: int | None, frames: int | None) -> str:
    variants = [v for v in VARIANTS if any((v, m) in samples for m in MODES)]
    modes = [m for m in MODES if any((v, m) in samples for v in variants)]
    fact = lambda key: facts.get(key, "unavailable")  # noqa: E731
    out: list[str] = []
    out.append(f"### Windows — {fact('cpu')}\n")
    out.append("Platform information:\n")
    settings = " ".join(s for s in (f"`REPS={reps}`" if reps else "", f"`FRAMES={frames}`" if frames else "") if s)
    out.append(
        f"- Captured by `tests/manual/doomgeneric/sdl/bench.sh` on {fact('date')} at commit `{fact('commit')}`"
        + (f" ({settings})" if settings else "")
    )
    out.append(f"- OS: {fact('os')}")
    out.append(f"- Toolchain: MSVC {fact('msvc')}; clang-cl {fact('clang_cl')}; daslang {fact('daslang')}; SDL {fact('sdl')}")
    out.append(
        "- Program: the doomgeneric corpus (`-timedemo demo1`, 320×200) as an SDL3 window application, the engine "
        "translated whole by c2das (`c2dascript-transpile --strict --libc std`) and the same C built natively\n"
    )
    out.append(
        "A cell is the median of the runs, each its own process, of the frame rate the program itself measures over "
        "its loop (`fps` = frames / loop seconds from SDL's performance counter; the engine's start-up and the "
        "first 41 frames of the screen wipe are outside it). `±` is half the sample range as a share of the "
        "median. **Higher is better** in the frames-per-second table; lower is better in the slowdown and "
        "start-up tables. Rows are the presentation modes and columns the variants, so the best result in each "
        "row (in bold) is the fastest variant in that mode. "
        f"`{NO_VALUE}` means no value: the run failed its hash check (the first 70 frame hashes against the corpus "
        "oracle, all frames against the C build's) or printed no `fps=`. **window** uses SDL's default video "
        "driver and renderer; **dummy** is `SDL_VIDEODRIVER=dummy`, headless, SDL's software renderer scaling to "
        "960×600; **nopresent** is `--no-present`, the engine plus palette conversion alone.\n"
    )
    out.append("#### Frames per second (higher is better)\n")
    headings = ["Mode", *(VARIANTS[v][0] for v in variants)]
    rows: list[list[str]] = []
    for m in modes:
        cells: list[tuple[float | None, str]] = []
        for v in variants:
            fps = samples.get((v, m), {}).get("fps", [])
            if not fps:
                cells.append((None, NO_VALUE))
            else:
                cells.append((statistics.median(fps), f"{statistics.median(fps):.1f} {spread(fps)}"))
        rows.append([m, *bold_best(cells, higher=True)])
    out.extend(table(headings, rows))
    out.append(f"#### Slowdown against `{VARIANTS[REFERENCE][0]}` (lower is better)\n")
    out.append(
        f"`{VARIANTS[REFERENCE][0]}` frames per second divided by the variant's, per mode; 1.00× is the speed of "
        "the C build compiled for this CPU, the fair ceiling for `-jit`, which compiles for the host CPU too.\n"
    )
    rows = []
    for m in modes:
        cells = []
        for v in variants:
            fps = samples.get((v, m), {}).get("fps", [])
            ref = samples.get((REFERENCE, m), {}).get("fps", [])
            if not fps or not ref or statistics.median(fps) <= 0:
                cells.append((None, NO_VALUE))
            else:
                ratio = statistics.median(ref) / statistics.median(fps)
                cells.append((ratio, f"{ratio:.2f}× {spread(fps)}"))
        rows.append([m, *bold_best(cells, higher=False)])
    out.extend(table(headings, rows))
    out.append("#### Startup (lower is better)\n")
    out.append(
        "`setup_us` as the program prints it: the engine's whole start-up including the first 41 frames, in "
        "milliseconds. It does not include process start, script compilation or JIT codegen, which the harness "
        "does not time.\n"
    )
    rows = []
    for m in modes:
        cells = []
        for v in variants:
            setup = samples.get((v, m), {}).get("setup_ms", [])
            if not setup:
                cells.append((None, NO_VALUE))
            else:
                cells.append((statistics.median(setup), f"{statistics.median(setup):.1f}ms {spread(setup)}"))
        rows.append([m, *bold_best(cells, higher=False)])
    out.extend(table(headings, rows))
    out.append("Builds: " + "; ".join(f"{VARIANTS[v][0]}: {VARIANTS[v][1]}" for v in variants) + ".\n")
    out.append(
        "\\* AOT is built from a second translation without `solid_context` and without daslang's auto-inliner "
        "(`--public-module --no-solid-context --das-option disable_auto_inline`, `translate.sh`), as in the "
        "corpus benchmark; the interpreter and `-jit` run the default translation (`options solid_context = true`, "
        "null checks on every pointer dereference).\n"
    )
    return "\n".join(out).rstrip() + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--samples", type=Path, required=True)
    parser.add_argument("--facts", type=Path, default=None)
    parser.add_argument("--output", type=Path, default=None, help="write here (default: stdout)")
    parser.add_argument("--reps", type=int, default=None)
    parser.add_argument("--frames", type=int, default=None)
    args = parser.parse_args()
    document = render(read_samples(args.samples), read_facts(args.facts), args.reps, args.frames)
    if args.output is None:
        sys.stdout.write(document)
    else:
        args.output.write_text(document, encoding="utf-8")
        print(f"wrote {args.output}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
