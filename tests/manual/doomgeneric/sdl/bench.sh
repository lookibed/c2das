#!/usr/bin/env bash
# Measure the SDL3 harness on Windows from WSL: every variant in every presentation mode,
# REPS runs each, hashes checked on every run, median FPS reported.
#
#   bench.sh [--markdown <path>] <work-dir> [variant ...]
#
# <work-dir> is the Windows scratch directory (as a WSL path, e.g. /mnt/d/...) where
# build_c.bat and build_aot.bat ran; every run executes there (`.savegame\`, `.jitted_scripts\`).
# Variants: c:msvc_O2 c:msvc_avx2 c:clang_O2 c:clang_native interp jit aot
# (default: the C builds present in <work-dir>, plus interp/jit when DOOM_SDL_GEN is set and aot
# when <work-dir>/aot-proj exists).
#
# Checks: the first 70 frame hashes of every run must equal the corpus oracle (`cases.json`,
# `doomgeneric-demo1-std`), and all frames must equal the first C build's run in the same mode.
# A run that differs, or exits without `fps=`, is reported FAIL and gets no number.
#
# `--markdown <path>` (or MD_OUT=<path>) additionally writes the run as a dasProfile-style
# Markdown snapshot (bench_markdown.py: platform information, FPS `median ±spread%` per
# variant × mode with the fastest in bold, the slowdown against `clang_native`, start-up).
# The platform facts are collected best-effort — Windows version (`ver`), CPU
# (/proc/cpuinfo, the same machine), `daslang --version` plus the daScript checkout's commit
# (DASLANG_COMMIT, else `git rev-parse` in DASROOT or DASLANG's grandparent), SDL
# (SDL3_DIR/include/SDL3/SDL_version.h), `cl` and `clang-cl --version` through vcvars — and
# a fact that cannot be found renders as `unavailable`; the numbers never depend on them.
#
# Environment (Windows paths, handed to run.bat):
#   DOOM_SDL_GEN      translate.sh's <out-dir> as a Windows path (interp/jit use <out>\default,
#                     aot uses <out>\aot)
#   DASLANG, DASSDL3_PROJ, DASSDL3_AOT_PROJ, VCVARS, DOOM_WAD   see run.bat
#   REPS (default 3), FRAMES (default 1000), MODES (default "window dummy nopresent")
#   CASES_JSON (default: this checkout's tests/canonical/cases.json), CMD_EXE (default
#   /mnt/c/Windows/System32/cmd.exe)
#   MD_OUT, DASLANG_COMMIT, DASROOT, SDL3_DIR, CLANG_CL   the Markdown snapshot (see above)
set -euo pipefail

md_out="${MD_OUT:-}"
while [ $# -gt 0 ]; do
    case "$1" in
        --markdown) [ $# -ge 2 ] || { echo "--markdown needs a path" >&2; exit 2; }; md_out="$2"; shift 2 ;;
        --markdown=*) md_out="${1#--markdown=}"; shift ;;
        --) shift; break ;;
        -*) echo "unknown option $1" >&2; exit 2 ;;
        *) break ;;
    esac
done
if [ $# -lt 1 ]; then
    echo "usage: $0 [--markdown <path>] <work-dir> [variant ...]" >&2
    exit 2
fi
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
corpus="$(cd "$here/.." && pwd)"
repo="$(cd "$corpus/../../.." && pwd)"
work="$(cd "$1" && pwd)"
shift
reps="${REPS:-3}"
frames="${FRAMES:-1000}"
modes="${MODES:-window dummy nopresent}"
cmd_exe="${CMD_EXE:-/mnt/c/Windows/System32/cmd.exe}"
run_bat="$(wslpath -w "$here/run.bat")"

variants=("$@")
if [ ${#variants[@]} -eq 0 ]; then
    for b in msvc_O2 msvc_avx2 clang_O2 clang_native; do
        [ -f "$work/doom_sdl_$b.exe" ] && variants+=("c:$b")
    done
    if [ -n "${DOOM_SDL_GEN:-}" ]; then
        variants+=(interp jit)
        [ -d "$work/aot-proj" ] && variants+=(aot)
    fi
fi

oracle="$(mktemp)"
trap 'rm -f "$oracle" "$oracle".*' EXIT
samples="$oracle.samples"   # one line per variant × mode, bench_markdown.py's input
: > "$samples"
python3 - "${CASES_JSON:-$repo/tests/canonical/cases.json}" > "$oracle" <<'EOF'
import json, sys
cases = json.load(open(sys.argv[1]))
cases = cases if isinstance(cases, list) else cases.get("cases", cases)
case = next(c for c in cases if c.get("id") == "doomgeneric-demo1-std")
sys.stdout.write("".join(l + "\n" for l in case["expected"]["stdout"].splitlines() if l.startswith("frame[")))
EOF

envs=""
for v in DASLANG DASSDL3_PROJ DASSDL3_AOT_PROJ VCVARS DOOM_WAD; do
    if [ -n "${!v:-}" ]; then envs+="set $v=${!v}&& "; fi
done

run_one() { # <variant> <mode> -> stdout of one run
    local variant="$1" mode="$2" args="--frames $frames" env="$envs" target
    [ "$mode" = "nopresent" ] && args="--no-present $args"
    [ "$mode" = "dummy" ] && env+="set SDL_VIDEODRIVER=dummy&& "
    case "$variant" in
        c:*) target="c ${variant#c:}" ;;
        interp|jit) target="$variant ${DOOM_SDL_GEN}\\default" ;;
        aot) target="aot ${DOOM_SDL_GEN}\\aot" ;;
        *) echo "unknown variant $variant" >&2; return 1 ;;
    esac
    (cd "$work" && "$cmd_exe" /c "${env}${run_bat} $target $args" 2>/dev/null | tr -d '\r')
}

printf '%-16s %-10s %-6s %10s %10s %10s  %s\n' variant mode hashes "fps_med" "fps_min" "fps_max" "setup_ms_med"
for mode in $modes; do
    ref=""
    for variant in "${variants[@]}"; do
        fps=()
        setups=()
        status=ok
        for _ in $(seq "$reps"); do
            out="$(run_one "$variant" "$mode" || true)"
            grep '^frame\[' <<<"$out" > "$oracle.run" || true
            if ! head -n 70 "$oracle.run" | cmp -s - "$oracle"; then status=FAIL-oracle; break; fi
            if [ -z "$ref" ]; then ref="$(cat "$oracle.run")"
            elif [ "$ref" != "$(cat "$oracle.run")" ]; then status=FAIL-vs-C; break; fi
            f="$(sed -n 's/^fps=//p' <<<"$out")"
            [ -z "$f" ] && { status=FAIL-nofps; break; }
            fps+=("$f")
            setups+=("$(sed -n 's/^setup_us=//p' <<<"$out")")
        done
        if [ "$status" != ok ]; then
            printf '%-16s %-10s %-6s\n' "$variant" "$mode" "$status"
            printf '%s\t%s\t%s\n' "$variant" "$mode" "$status" >> "$samples"
            continue
        fi
        printf '%s\t%s\tok\t%s\t%s\n' "$variant" "$mode" "${fps[*]}" "${setups[*]}" >> "$samples"
        printf '%s\n' "${fps[@]}" | sort -g > "$oracle.f"
        printf '%s\n' "${setups[@]}" | sort -g > "$oracle.s"
        n=${#fps[@]}
        med="$(sed -n "$(( (n + 1) / 2 ))p" "$oracle.f")"
        smed="$(sed -n "$(( (n + 1) / 2 ))p" "$oracle.s")"
        printf '%-16s %-10s %-6s %10s %10s %10s  %s\n' "$variant" "$mode" ok "$med" \
            "$(head -n 1 "$oracle.f")" "$(tail -n 1 "$oracle.f")" "$(awk -v s="$smed" 'BEGIN{printf "%.1f", s/1000}')"
    done
done

[ -n "$md_out" ] || exit 0

# --- the Markdown snapshot: platform facts (best-effort), then bench_markdown.py ---
win() { # <cmd.exe command line> -> its first non-empty stdout line, or nothing
    (cd "$work" && "$cmd_exe" /c "$1" 2>/dev/null | tr -d '\r' | sed -n '/[^[:space:]]/{p;q}') || true
}
facts="$oracle.facts"
{
    echo "date=$(date +%F)"
    echo "commit=$(git -C "$repo" rev-parse --short=9 HEAD 2>/dev/null || echo unknown)"
    echo "cpu=$(sed -n 's/^model name[[:space:]]*: //p' /proc/cpuinfo 2>/dev/null | head -n 1)"
    echo "os=$(win ver)"
    daslang_exe="${DASLANG:-daslang.exe}"
    daslang_version="$(win "\"$daslang_exe\" --version")"
    daslang_commit="${DASLANG_COMMIT:-}"
    if [ -z "$daslang_commit" ]; then
        das_root="${DASROOT:-}"
        if [ -z "$das_root" ] && [ -n "${DASLANG:-}" ]; then
            das_root="$(dirname "$(dirname "$DASLANG")")"
        fi
        if [ -n "$das_root" ]; then
            das_root_wsl="$(wslpath -u "$das_root" 2>/dev/null || echo "$das_root")"
            daslang_commit="$(git -C "$das_root_wsl" rev-parse --short=9 HEAD 2>/dev/null || true)"
        fi
    fi
    echo "daslang=${daslang_version:-unavailable}${daslang_commit:+ ($daslang_commit)}"
    if [ -n "${SDL3_DIR:-}" ]; then
        sdl_h="$(wslpath -u "$SDL3_DIR" 2>/dev/null || echo "$SDL3_DIR")/include/SDL3/SDL_version.h"
        if [ -f "$sdl_h" ]; then
            echo "sdl=$(awk '/#define SDL_(MAJOR|MINOR|MICRO)_VERSION[[:space:]]/ {v[++n]=$3} END {if (n==3) printf "%s.%s.%s", v[1], v[2], v[3]}' "$sdl_h")"
        fi
    fi
    vcvars_call=""
    if [ -n "${VCVARS:-}" ]; then
        vcvars_call="call \"$VCVARS\" >nul 2>nul && "
    fi
    # `cl` prints its banner ("Microsoft (R) C/C++ Optimizing Compiler Version 19.44...") on stderr
    echo "msvc=$(win "${vcvars_call}cl 2>&1" | sed -n 's/.*Version \([0-9.]*\).*/\1/p')"
    echo "clang_cl=$(win "${vcvars_call}\"${CLANG_CL:-clang-cl}\" --version" | sed -n 's/.*clang version \([0-9.]*\).*/\1/p')"
} > "$facts"
python3 "$here/bench_markdown.py" --samples "$samples" --facts "$facts" --reps "$reps" --frames "$frames" \
    --output "$md_out"
