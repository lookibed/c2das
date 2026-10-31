/* Host API of the SDL3 harness: the entry points a host outside the engine
 * (the daslang host `quake_sdl.das`) needs to drive quakegeneric, feed it
 * input and show its frames.
 *
 * It is a translation unit of its own beside the corpus's units (the case
 * `quakegeneric-demo1-std`'s units, platform layer `../src/qg_platform.c`
 * included; dasQUAKE's per-file layout, `scripts/export_dasquake.py`).  It
 * reads the platform layer's frame record and palette and changes nothing in
 * it, so a timedemo run records exactly the corpus oracle's hashes.
 *
 * Two ways to run the engine:
 * - `qg_host_start_timedemo` + `qg_host_tick_timedemo`: the corpus entry
 *   `../src/quake_entry.c` (`quake -basedir <dir> +timedemo demo1`, the
 *   virtual 1/64 s tick), for the oracle check and the frame-rate figure.
 * - `qg_host_start_play` + `qg_host_tick(seconds)`: `quake -basedir <dir>`,
 *   the pak's attract loop (`startdemos demo1 demo2 demo3`) driven by the
 *   host's real clock; any key opens the menu and the game is playable.
 *
 * Input goes straight to the engine.  The platform layer's `QG_GetKey` and
 * `QG_GetMouseMove` report nothing (the corpus runs are input-free), so
 * `qg_host_key` calls `Key_Event` itself, which is what `in_null.c`'s
 * `IN_Commands` does with a key `QG_GetKey` returns, and `qg_host_mouse`
 * turns the view the way `in_null.c`'s `IN_MouseMove` does under `+mlook`.
 *
 * What it adds is the frame as pixels a window can show:
 * `qg_host_frame_argb` converts the 8-bit screen `vid.buffer` through the
 * palette last given to `QG_SetPalette` into 32-bit ARGB8888 (`0xAARRGGBB`,
 * alpha opaque), the format of the host's SDL streaming texture. */
#include <stdint.h>

#include "quakedef.h"
#include "quakegeneric.h"

#define QG_HOST_PIXELS (QUAKEGENERIC_RES_X * QUAKEGENERIC_RES_Y)

/* The platform layer's frame record, frame duration and palette
 * (`qg_platform.c`), declared here as `quake_entry.c` declares them. */
#define QG_MAX_FRAMES 4096
extern int qg_frame_count;
extern int32_t qg_frame_hash[];
extern const double qg_frame_seconds;
extern unsigned char qg_palette[768];

static char *qg_host_argv[6];
static uint32_t qg_host_pixels[QG_HOST_PIXELS];

int qg_host_width(void)
{
    return QUAKEGENERIC_RES_X;
}

int qg_host_height(void)
{
    return QUAKEGENERIC_RES_Y;
}

/* The engine keeps `basedir` (through `com_argv`), so it must stay valid for
 * the whole run. */
void qg_host_start_timedemo(char *basedir)
{
    qg_host_argv[0] = "quake";
    qg_host_argv[1] = "-basedir";
    qg_host_argv[2] = basedir;
    qg_host_argv[3] = "+timedemo";
    qg_host_argv[4] = "demo1";
    qg_host_argv[5] = NULL;
    QG_Create(5, qg_host_argv);
}

void qg_host_start_play(char *basedir)
{
    qg_host_argv[0] = "quake";
    qg_host_argv[1] = "-basedir";
    qg_host_argv[2] = basedir;
    qg_host_argv[3] = NULL;
    QG_Create(3, qg_host_argv);
}

/* One engine frame of the corpus entry's loop. */
void qg_host_tick_timedemo(void)
{
    QG_Tick(qg_frame_seconds);
}

/* One engine frame `seconds` of host time after the previous one.  The
 * engine renders nothing when less than 1/72 s has passed in total
 * (`Host_FilterTime`) and integrates at most 0.1 s per frame. */
void qg_host_tick(double seconds)
{
    QG_Tick(seconds);
}

/* Frames recorded so far: rendered frames that show none of the console
 * (`qg_platform.c`, `QG_DrawFrame`). */
int qg_host_frame_count(void)
{
    return qg_frame_count;
}

/* The platform layer's FNV-1a hash of recorded frame `index`, or 0 outside
 * the recorded range. */
int qg_host_frame_hash(int index)
{
    if (index < 0 || index >= QG_MAX_FRAMES || index >= qg_frame_count) {
        return 0;
    }
    return qg_frame_hash[index];
}

/* A key went down or up: `key` is a `quakekeys.h` code (lower-case ASCII for
 * printable keys). */
void qg_host_key(int down, int key)
{
    Key_Event(key, down ? true : false);
}

/* A relative mouse movement in pixels: mouse look, as `IN_MouseMove` with
 * `+mlook` held (yaw and pitch, `sensitivity`, `m_yaw`, `m_pitch`). */
void qg_host_mouse(int dx, int dy)
{
    if (key_dest != key_game) {
        return;
    }
    cl.viewangles[YAW] -= m_yaw.value * sensitivity.value * (float)dx;
    cl.viewangles[PITCH] += m_pitch.value * sensitivity.value * (float)dy;
    if (cl.viewangles[PITCH] > 80) {
        cl.viewangles[PITCH] = 80;
    }
    if (cl.viewangles[PITCH] < -70) {
        cl.viewangles[PITCH] = -70;
    }
    V_StopPitchDrift();
}

/* 1 while a game (not a demo) is being played with no menu or console up:
 * the host captures the mouse only then. */
int qg_host_in_game(void)
{
    return key_dest == key_game && cls.state == ca_connected && !cls.demoplayback;
}

/* The last rendered screen as QUAKEGENERIC_RES_X x QUAKEGENERIC_RES_Y
 * ARGB8888 pixels, row-major, pitch QUAKEGENERIC_RES_X * 4 bytes.  The
 * buffer is the host API's own and is overwritten by the next call. */
uint32_t *qg_host_frame_argb(void)
{
    int i = 0;
    uint32_t palette[256];
    const unsigned char *screen = vid.buffer;

    for (i = 0; i < 256; i++) {
        palette[i] = 0xff000000u | ((uint32_t)qg_palette[i * 3] << 16)
            | ((uint32_t)qg_palette[i * 3 + 1] << 8) | (uint32_t)qg_palette[i * 3 + 2];
    }
    for (i = 0; i < QG_HOST_PIXELS; i++) {
        qg_host_pixels[i] = palette[screen[i]];
    }
    return qg_host_pixels;
}
