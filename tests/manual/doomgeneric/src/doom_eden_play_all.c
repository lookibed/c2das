/* Translation input for the interactive EdenSpark player
 * (`eden/c2das_doom_player.das`): the c2das target graph (`all.c`) without
 * its headless benchmark platform layer, plus the interactive platform layer
 * `dg_eden_play.c`, in one translation unit.  It has no `main`: the host
 * calls the `dge_*` functions of `dg_eden_play.c` once per frame. */
#define DG_NO_BENCH_PLATFORM 1
#include "all.c"
#include "dg_eden_play.c"
