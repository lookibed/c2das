#!/usr/bin/env bash
# Run c2das eden cases inside the EdenSpark editor (docs/eden-flags.md, "In the editor").
#
#   EDEN_PROJECT=<project dir> EDENMCP=<edenmcp client> run.sh <cheat|-> case-id...
#
# Translates the cases into <project>/modules/c2das/ (install.py), regenerates the project's
# main.das with one [cheat] per case (the original is kept as main.das.orig), forces the editor
# to rescan its files, restarts the game, prints the status and, unless <cheat> is `-`, runs the
# cheat and compares each case's stdout with cases.json (compare.py).
#   EDENMCP: the editor's MCP command-line client, e.g. wasm3das scripts/eden/edenmcp.
#   C2DAS_EXTRA: extra translator flags (e.g. "--heap-reserve 2097152").
#   C2DAS_MAIN_OPTIONS: an `options` line for main.das (e.g. "options stack = 8388608").
#   WORK: scratch dir for generated files and logs (default: a temp dir).
set -u
here="$(cd "$(dirname "$0")" && pwd)"
P="${EDEN_PROJECT:?set EDEN_PROJECT to the EdenSpark project directory}"
E="${EDENMCP:?set EDENMCP to the editor MCP client}"
W="${WORK:-$(mktemp -d)}"
cheat="$1"; shift
export C2DAS_EXPECTED_DIR="$W/expected"
rm -rf "$C2DAS_EXPECTED_DIR"
python3 "$here/install.py" "$P" "$@" || exit 1
"$E" get_logs >/dev/null 2>&1
# The editor misses file-change notifications; a new file forces a rescan (as wasm3das eden_gate.sh does).
printf '// rescan\n' > "$P/modules/c2das/rescan_probe.das"; sleep 3; rm -f "$P/modules/c2das/rescan_probe.das"; sleep 2
"$E" game_restart >/dev/null 2>&1
sleep 5
for _ in $(seq 1 60); do s=$("$E" get_game_status 2>&1); case "$s" in Compiling*) sleep 3;; *) break;; esac; done
echo "STATUS: $s" | head -8
case "$s" in *failed*|*error*) "$E" get_logs 2>&1 | grep -E "^\[E\]|error\[" -A3 | head -30; exit 1;; esac
[ "$cheat" = "-" ] && exit 0
"$E" get_logs >/dev/null 2>&1
"$E" exec_cheat "{\"cmd\":\"$cheat\"}" 2>&1 | tail -2
: > "$W/last_logs.txt"
for _ in $(seq 1 "${POLLS:-60}"); do
    sleep 5
    "$E" get_logs >> "$W/last_logs.txt" 2>&1
    grep -q "C2DAS ALL DONE\|panic\|xception" "$W/last_logs.txt" && break
done
python3 "$here/compare.py" "$W/last_logs.txt" "$C2DAS_EXPECTED_DIR"
