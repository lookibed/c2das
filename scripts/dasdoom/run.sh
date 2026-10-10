#!/usr/bin/env bash
# Run the translated Doom on the shareware IWAD (-timedemo demo1, 70 frames)
# and compare its frame hashes with expected_frames.txt.
#
# usage: doom/run.sh [path/to/doom1.wad]
#   WAD:     the argument, else $DOOM_WAD, else doom1.wad in the repository root
#   daslang: $DASLANG, else `daslang` on PATH
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
wad="${1:-${DOOM_WAD:-$here/../doom1.wad}}"
daslang="${DASLANG:-$(command -v daslang || true)}"

[[ -n "$daslang" && -x "$daslang" ]] || { echo "daslang not found: set DASLANG or add it to PATH" >&2; exit 127; }
[[ -f "$wad" ]] || { echo "no WAD at $wad: run tools/get_wad.sh or pass its path" >&2; exit 2; }
wad="$(cd "$(dirname "$wad")" && pwd)/$(basename "$wad")"

out="$(mktemp)"
trap 'rm -f "$out"' EXIT
start=$(date +%s)
# The engine's console goes to stderr; stdout carries one hash per frame.
(cd "$here" && "$daslang" doom_entry.das -- "$wad") >"$out" 2>/dev/null
echo "ran in $(( $(date +%s) - start )) s with $daslang"

if diff -u "$here/expected_frames.txt" "$out"; then
    echo "OK: $(grep -c '^frame\[' "$out") frame hashes match"
else
    echo "FAIL: frame hashes differ" >&2
    exit 1
fi
