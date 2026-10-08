/* The corpus's doomgeneric platform layer: the six `DG_*` functions
 * `doomgeneric.h` asks a port to implement, for a headless, deterministic
 * run.
 *
 * - Time is virtual.  `DG_GetTicksMs` answers a counter that only
 *   `DG_SleepMs` and `dg_advance_clock` move, so no run ever reads the host
 *   clock and two runs of the same program see the same times.  It starts at
 *   1000 ms rather than 0 because `i_timer.c` treats a zero first reading as
 *   "no base time yet".
 * - There is no input: `DG_GetKey` never reports a key.
 * - `DG_DrawFrame` is the one observation point.  `i_video.c` calls it once
 *   per rendered frame, after it has copied the 8-bit screen into
 *   `DG_ScreenBuffer` (one palette index per pixel under `CMAP256`); the
 *   layer hashes the RGB colour of every pixel through the current palette
 *   `colors[]`, so the hash covers both the indexed image and the palette
 *   (damage and pickup flashes are palette changes), and records it.
 *
 * The entries (`doom_entry.c`, `doom_bench_entry.c`) drive the engine and
 * print what this layer recorded. */
#include <stdint.h>

#include "doomgeneric.h"
#include "i_video.h"

/* The most frames a run may record; the entries ask for far fewer. */
#define DG_MAX_FRAMES 4096

static uint32_t dg_virtual_ms = 1000;
/* Read by the entries, which `doom_entry.c` declares for itself when it is
 * compiled on its own (the `--module-layout source` case). */
int dg_frame_count = 0;
int32_t dg_frame_hash[DG_MAX_FRAMES];

/* 32-bit FNV-1a over the frame's pixels, one 24-bit RGB word per pixel. */
static uint32_t dg_hash_frame(void)
{
    uint32_t hash = 2166136261u;
    int i = 0;

    for (i = 0; i < DOOMGENERIC_RESX * DOOMGENERIC_RESY; i++) {
        struct color c = colors[DG_ScreenBuffer[i]];
        uint32_t rgb = ((uint32_t)c.r << 16) | ((uint32_t)c.g << 8) | (uint32_t)c.b;
        hash = (hash ^ rgb) * 16777619u;
    }
    return hash;
}

void DG_Init(void)
{
}

void DG_DrawFrame(void)
{
    if (dg_frame_count < DG_MAX_FRAMES) {
        dg_frame_hash[dg_frame_count] = (int32_t)dg_hash_frame();
    }
    dg_frame_count += 1;
}

void DG_SleepMs(uint32_t ms)
{
    dg_virtual_ms += ms;
}

uint32_t DG_GetTicksMs(void)
{
    return dg_virtual_ms;
}

int DG_GetKey(int *pressed, unsigned char *key)
{
    (void)pressed;
    (void)key;
    return 0;
}

void DG_SetWindowTitle(const char *title)
{
    (void)title;
}

/* One engine tic of virtual time (1000 / 35 ms, rounded down), advanced by
 * the entries between two `doomgeneric_Tick` calls. */
void dg_advance_clock(void)
{
    dg_virtual_ms += 28;
}
