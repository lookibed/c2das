/* Host API of the SDL3 harness: the few entry points a host outside the
 * engine (the C host `doom_sdl_host.c`, the daslang host `doom_sdl.das`)
 * needs to drive the headless doomgeneric build and show its frames.
 *
 * It is included by `doom_host_all.c` after `../src/all.c`, i.e. in the same
 * translation unit as the platform layer `dg_platform.c`, so it reads that
 * layer's file-scope state (`dg_frame_count`, `dg_frame_hash`,
 * `dg_advance_clock`) directly and changes nothing in it: the engine, its
 * virtual clock and its per-frame hash are exactly those of the headless
 * corpus entries, and the hashes it reports are the corpus oracle's.
 *
 * What it adds is the frame as pixels a window can show: `dg_host_frame_argb`
 * converts the 8-bit `DG_ScreenBuffer` through the current palette `colors[]`
 * into 32-bit ARGB8888 (`0xAARRGGBB`, alpha opaque), the format of the hosts'
 * SDL streaming texture.  It is plain C, so the C host runs it natively and
 * the daslang host runs its translation. */
#include <stdint.h>

#include "doomgeneric.h"
#include "i_video.h"

#define DG_HOST_PIXELS (DOOMGENERIC_RESX * DOOMGENERIC_RESY)

static char *dg_host_argv[8];
static uint32_t dg_host_palette[256];
static uint32_t dg_host_pixels[DG_HOST_PIXELS];

int dg_host_width(void)
{
    return DOOMGENERIC_RESX;
}

int dg_host_height(void)
{
    return DOOMGENERIC_RESY;
}

/* The engine's start-up, as the corpus entries run it:
 * `doom -iwad <iwad> -nosound -nomusic -timedemo demo1`.  The engine keeps
 * `iwad` (through `myargv`), so it must stay valid for the whole run.  It
 * returns after the first 41 frames (the screen wipe into E1M5). */
void dg_host_start(char *iwad)
{
    dg_host_argv[0] = "doom";
    dg_host_argv[1] = "-iwad";
    dg_host_argv[2] = iwad;
    dg_host_argv[3] = "-nosound";
    dg_host_argv[4] = "-nomusic";
    dg_host_argv[5] = "-timedemo";
    dg_host_argv[6] = "demo1";
    dg_host_argv[7] = NULL;
    doomgeneric_Create(7, dg_host_argv);
}

/* One engine tic and, under `-timedemo`, exactly one rendered frame, as the
 * corpus entries' loop body. */
void dg_host_tick(void)
{
    dg_advance_clock();
    doomgeneric_Tick();
}

/* Frames rendered so far (the platform layer's `dg_frame_count`). */
int dg_host_frame_count(void)
{
    return dg_frame_count;
}

/* The platform layer's FNV-1a hash of frame `index`, or 0 outside the
 * recorded range. */
int dg_host_frame_hash(int index)
{
    if (index < 0 || index >= DG_MAX_FRAMES || index >= dg_frame_count) {
        return 0;
    }
    return dg_frame_hash[index];
}

/* The last rendered frame as DOOMGENERIC_RESX x DOOMGENERIC_RESY ARGB8888
 * pixels, row-major, pitch DOOMGENERIC_RESX * 4 bytes.  The palette is
 * converted once per call (256 entries), then every pixel is one table
 * lookup.  The buffer is the host API's own and is overwritten by the next
 * call. */
uint32_t *dg_host_frame_argb(void)
{
    int i = 0;

    for (i = 0; i < 256; i++) {
        dg_host_palette[i] = 0xff000000u | ((uint32_t)colors[i].r << 16)
            | ((uint32_t)colors[i].g << 8) | (uint32_t)colors[i].b;
    }
    for (i = 0; i < DG_HOST_PIXELS; i++) {
        dg_host_pixels[i] = dg_host_palette[DG_ScreenBuffer[i]];
    }
    return dg_host_pixels;
}
