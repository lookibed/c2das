/* Translation input for the interactive EdenSpark player
 * (`eden/c2das_doom_player.das`): the c2das target graph (`all.c`) without
 * its headless benchmark platform layer, plus the interactive platform layer
 * `dg_eden_play.c`, in one translation unit.  It has no `main`: the host
 * calls the `dge_*` functions of `dg_eden_play.c` once per frame.
 *
 * Unlike the benchmark builds, the engine is compiled with `FEATURE_SOUND`,
 * upstream's switch for a sound backend (`doomfeatures.h`, `i_sound.c`): the
 * backend is the software mixer `dg_eden_sound.c`.  The switch makes
 * `i_sound.c` include `<SDL_mixer.h>`, which `src/eden_play_include/`
 * answers, so this build is translated with `-Isrc/eden_play_include` too. */
#define DG_NO_BENCH_PLATFORM 1
#define FEATURE_SOUND 1
#include "all.c"
#include "dg_eden_sound.c"
#include "dg_eden_play.c"
