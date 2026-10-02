#!/usr/bin/env bash
# Translate the SDL3 harness's engine module and stage the daslang host beside it.
#
#   translate.sh <out-dir>
#
# Writes two ready-to-run directories (the translation runs on Linux/WSL, the
# result runs wherever daslang and dasSDL3 do):
#   <out-dir>/default/  doom_host_all.das (c2das --strict --libc std) + doom_sdl.das
#                       for the interpreter and -jit
#   <out-dir>/aot/      doom_host_all.das translated again with the AOT header of
#                       docs/corpus-build-recipe.md step 6a (--public-module
#                       --no-solid-context --das-option disable_auto_inline) and a copy of
#                       doom_sdl.das with `options disable_auto_inline` prepended
#
# Environment: C2DAS_TRANSPILE  translator command (default: `cargo run -q -p
# c2dascript-transpile --` in this checkout); CARGO_BUILD_JOBS is honoured (default 4).
set -euo pipefail

if [ $# -ne 1 ]; then
    echo "usage: $0 <out-dir>" >&2
    exit 2
fi
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
corpus="$(cd "$here/.." && pwd)"
repo="$(cd "$corpus/../../.." && pwd)"
mkdir -p "$1"
out="$(cd "$1" && pwd)"
case "$out/" in
    "$repo"/*) echo "refusing to write generated .das inside the checkout: $out" >&2; exit 2 ;;
esac
export CARGO_BUILD_JOBS="${CARGO_BUILD_JOBS:-4}"

flags=(-std=c11 "-I$corpus/include" "-I$corpus/upstream/doomgeneric/doomgeneric" "-I$corpus/src")

# The corpus case's daslang module options (`das_options` of doomgeneric-demo1-std in
# tests/canonical/cases.json, e.g. the larger stack the `states` initializer needs), so this
# translation is configured exactly as the converged one.
das_options=()
host_options=""
while IFS= read -r option; do
    [ -n "$option" ] && das_options+=(--das-option "$option") && host_options+="options $option"$'\n'
done < <(python3 - "$repo/tests/canonical/cases.json" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
cases = data if isinstance(data, list) else data["cases"]
case = next(c for c in cases if c.get("id") == "doomgeneric-demo1-std")
for option in case.get("das_options", []):
    print(option)
PY
)

transpile() {
    if [ -n "${C2DAS_TRANSPILE:-}" ]; then
        # shellcheck disable=SC2086
        $C2DAS_TRANSPILE "$@"
    else
        (cd "$repo" && cargo run -q -p c2dascript-transpile -- "$@")
    fi
}

mkdir -p "$out/default" "$out/aot"
transpile --strict --libc std "${das_options[@]}" --output-dir "$out/default" \
    --file "$here/doom_host_all.c" "${flags[@]}"
# A context option such as the stack size belongs to the program, whose root is the host
# script here (in the corpus case the translated module is the root), so the host copies carry
# the case's options too.
{ printf '%s' "$host_options"; cat "$here/doom_sdl.das"; } > "$out/default/doom_sdl.das"

transpile --strict --libc std "${das_options[@]}" --public-module --no-solid-context \
    --das-option disable_auto_inline --output-dir "$out/aot" \
    --file "$here/doom_host_all.c" "${flags[@]}"
{ printf '%s' "$host_options"; echo "options disable_auto_inline"; cat "$here/doom_sdl.das"; } \
    > "$out/aot/doom_sdl.das"

echo "translated: $out/default/doom_host_all.das, $out/aot/doom_host_all.das"
