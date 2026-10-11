#!/usr/bin/env bash
# Run the translated Quake on the shareware pak (`+timedemo demo1`, 100 frames)
# and compare its frame hashes with expected_frames.txt (the C build's output).
#
# usage: quake/run.sh [base-dir]
#   base-dir: the directory holding id1/pak0.pak; the argument, else
#             $QUAKE_BASEDIR, else the repository root
#   daslang:  $DASLANG, else `daslang` on PATH
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base="${1:-${QUAKE_BASEDIR:-$here/..}}"
daslang="${DASLANG:-$(command -v daslang || true)}"

[[ -n "$daslang" && -x "$daslang" ]] || { echo "daslang not found: set DASLANG or add it to PATH" >&2; exit 127; }
[[ -f "$base/id1/pak0.pak" ]] || { echo "no $base/id1/pak0.pak: run tools/get_pak.sh or pass the base directory" >&2; exit 2; }
base="$(cd "$base" && pwd)"

out="$(mktemp)"
trap 'rm -f "$out"' EXIT
start=$(date +%s)
# The engine's console goes to stderr; stdout carries one hash per frame.
(cd "$here" && "$daslang" quake_entry.das -- "$base") >"$out" 2>/dev/null
echo "ran in $(( $(date +%s) - start )) s with $daslang"

if diff -u "$here/expected_frames.txt" "$out"; then
    echo "OK: $(grep -c '^frame\[' "$out") frame hashes match"
else
    echo "FAIL: frame hashes differ" >&2
    exit 1
fi
