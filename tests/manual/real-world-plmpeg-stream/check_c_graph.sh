#!/usr/bin/env bash
# Verify the separate target and C-reference PLMPEG graphs.
set -euo pipefail

root="$(cd "$(dirname "$0")/../../.." && pwd)"
fixture="$root/tests/manual/real-world-plmpeg-stream"
src="$fixture/src"

test "$(grep -c '^#define PL_MPEG_IMPLEMENTATION$' "$src/pl_mpeg.c")" -eq 1
test "$(grep -c 'PL_MPEG_IMPLEMENTATION' "$src/shim.c")" -eq 0
test "$(grep -c 'PL_MPEG_IMPLEMENTATION' "$src/module.c")" -eq 0

grep -q '^#include "pl_mpeg.c"$' "$src/all.c"
grep -q '^#undef PL_MPEG_IMPLEMENTATION$' "$src/all.c"
grep -q '^#include "module.c"$' "$src/all.c"
! grep -q '^#include "shim.c"$' "$src/all.c"

grep -q '^#include "shim.c"$' "$src/all_reference.c"
grep -q '^#include "pl_mpeg.c"$' "$src/all_reference.c"
grep -q '^#undef PL_MPEG_IMPLEMENTATION$' "$src/all_reference.c"
grep -q '^#include "module.c"$' "$src/all_reference.c"

grep -q '^void c2da_rt_reset(void);$' "$src/module.c"
grep -q '^void c2da_rt_reset(void)' "$src/shim.c"

clang-18 -fsyntax-only -DPLM_NO_STDIO \
    -I"$fixture/include" \
    -I"$fixture/upstream" \
    -I"$fixture/fixtures" \
    -I"$src" \
    "$src/all.c"

clang-18 -fsyntax-only -DPLM_NO_STDIO \
    -I"$fixture/include" \
    -I"$fixture/upstream" \
    -I"$fixture/fixtures" \
    -I"$src" \
    "$src/all_reference.c"
