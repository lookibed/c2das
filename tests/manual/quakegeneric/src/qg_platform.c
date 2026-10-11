/* The corpus's quakegeneric platform layer: the seven `QG_*` functions
 * `quakegeneric.h` asks a port to implement, for a headless, deterministic
 * run.
 *
 * - Time is virtual.  The engine's own clock is `sys_null.c`'s
 *   `Sys_FloatTime`, a counter that adds 0.1 s per call and never reads the
 *   host; the frame time the engine integrates is the fixed duration the
 *   entry passes to `QG_Tick` (`qg_frame_seconds`).  Two runs of the same
 *   program therefore see the same times.
 * - There is no input: `QG_GetKey` never reports a key, the mouse never
 *   moves and every joystick axis reads zero.
 * - `QG_DrawFrame` is the one observation point.  `vid_null.c`'s
 *   `VID_Update` calls it once per rendered frame with the 8-bit 320x240
 *   screen (one palette index per pixel); the layer hashes the RGB colour
 *   of every pixel through the palette last given to `QG_SetPalette`, so
 *   the hash covers both the indexed image and the palette (damage and
 *   pickup flashes are palette changes), and records it.  The hash is the
 *   doomgeneric corpus's: 32-bit FNV-1a, one 24-bit RGB word per pixel.
 *
 * The entry (`quake_entry.c`) drives the engine and prints what this layer
 * recorded. */
#include <stdint.h>

#include "quakegeneric.h"

/* The console's visible height in lines (`screen.c`). */
extern float scr_con_current;

/* The most frames a run may record; the entry asks for far fewer. */
#define QG_MAX_FRAMES 4096

/* Read by the entry, which declares them for itself so that it can be
 * compiled on its own. */
int qg_frame_count = 0;
int32_t qg_frame_hash[QG_MAX_FRAMES];

/* The duration of one `QG_Tick`, in seconds: 1/64, exact in binary
 * floating point, so `realtime` sums without rounding. */
const double qg_frame_seconds = 1.0 / 64.0;

static unsigned char qg_palette[768];

/* 32-bit FNV-1a over the frame's pixels, one 24-bit RGB word per pixel. */
static uint32_t qg_hash_frame(const unsigned char *pixels)
{
    uint32_t hash = 2166136261u;
    int i = 0;

    for (i = 0; i < QUAKEGENERIC_RES_X * QUAKEGENERIC_RES_Y; i++) {
        const unsigned char *c = &qg_palette[pixels[i] * 3];
        uint32_t rgb = ((uint32_t)c[0] << 16) | ((uint32_t)c[1] << 8) | (uint32_t)c[2];
        hash = (hash ^ rgb) * 16777619u;
    }
    return hash;
}

void QG_Init(void)
{
}

void QG_Quit(void)
{
}

void QG_DrawFrame(void *pixels)
{
    /* Frames that show any of the console are not recorded.  The console
     * scrolls up over the first frames of the demo, and its startup log
     * holds the base directory's path ("Added packfile <dir>/id1/pak0.pak")
     * and the engine's build time (`host.c` prints `__DATE__`/`__TIME__`),
     * so those frames differ between two builds or two directories. */
    if (scr_con_current != 0.0f) {
        return;
    }
    if (qg_frame_count < QG_MAX_FRAMES) {
        qg_frame_hash[qg_frame_count] = (int32_t)qg_hash_frame((const unsigned char *)pixels);
    }
    qg_frame_count += 1;
}

void QG_SetPalette(unsigned char palette[768])
{
    int i = 0;

    for (i = 0; i < 768; i++) {
        qg_palette[i] = palette[i];
    }
}

int QG_GetKey(int *down, int *key)
{
    (void)down;
    (void)key;
    return 0;
}

void QG_GetMouseMove(int *x, int *y)
{
    *x = 0;
    *y = 0;
}

void QG_GetJoyAxes(float *axes)
{
    int i = 0;

    for (i = 0; i < QUAKEGENERIC_JOY_MAX_AXES; i++) {
        axes[i] = 0.0f;
    }
}
