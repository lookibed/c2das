/* The interactive quakegeneric platform layer of the EdenSpark player
 * (`eden/c2das_quake_player.das`): the seven `QG_*` functions
 * `quakegeneric.h` asks a port to implement, and the host API (`qg_eden.h`)
 * the player calls.  It replaces `qg_platform.c` and `quake_entry.c` of the
 * timedemo cases; the play build has no `main`.
 *
 * - `qge_init` starts the engine as `quake -basedir quake`: the pak's
 *   `quake.rc` runs the attract loop (`startdemos demo1 demo2 demo3`), and
 *   the menu (Esc) starts a new game.  `qge_init_map` starts
 *   `quake -basedir quake +map start` instead, which runs QuakeC from the
 *   first frame.  The engine opens `quake/id1/pak0.pak` (`common.c`,
 *   `COM_AddGameDirectory`), which the host has registered with
 *   `c2da_eden_add_file` beforehand (`QGE_PAK_NAME`).
 * - `qge_tick(ms)` takes the host clock in milliseconds since `qge_init` and
 *   runs one `QG_Tick` with the time elapsed since the previous call.  The
 *   engine renders nothing when less than 1/72 s has passed
 *   (`Host_FilterTime`) and integrates at most 0.1 s per frame, so a slow
 *   interpreter plays slowed down instead of skipping.
 * - `qge_key(pressed, key)` queues a key event (`quakekeys.h` codes, lower-case
 *   ASCII for printable keys) that `QG_GetKey` hands to `Key_Event` in the
 *   next tick (`in_null.c`, `IN_Commands`).
 * - `qge_mouse(dx, dy)` adds a mouse movement, which `QG_GetMouseMove`
 *   reports and clears once per frame (`in_null.c`, `IN_MouseMove`).
 * - `qge_screen` answers the address of the 8-bit 320x240 screen
 *   `QG_DrawFrame` last received (`vid_null.c`'s `vid_buffer`, one palette
 *   index per pixel, row-major), as an integer: under
 *   `--memory-model linear` it is an offset into the heap `c2da_mem`.
 * - `qge_palette` answers the address of the 768-byte RGB palette last given
 *   to `QG_SetPalette`.  That one is a copy: the engine passes palettes that
 *   live on its stack (`V_UpdatePalette`'s `pal[768]` in `view.c`,
 *   `CL_ParseServerMessage`'s in `cl_main.c`), valid only during the call.
 * - `qge_frames` counts `QG_DrawFrame` calls.
 *
 * Sound: quakegeneric compiles the null sound driver (`snd_null.c`), so the
 * game is silent. */
#include <stdint.h>

#include "qg_eden.h"
#include "quakegeneric.h"

#define QGE_KEY_QUEUE 64

static int qge_frame_count = 0;
static unsigned char *qge_screen_pixels = 0;
static unsigned char qge_palette_rgb[768];
static unsigned qge_clock_ms = 0;
static int qge_key_down[QGE_KEY_QUEUE];
static int qge_key_code[QGE_KEY_QUEUE];
static int qge_key_head = 0;
static int qge_key_tail = 0;
static int qge_mouse_dx = 0;
static int qge_mouse_dy = 0;
static char *qge_argv[8];

void QG_Init(void)
{
}

void QG_Quit(void)
{
}

void QG_DrawFrame(void *pixels)
{
    qge_screen_pixels = (unsigned char *)pixels;
    qge_frame_count += 1;
}

void QG_SetPalette(unsigned char palette[768])
{
    int i = 0;

    for (i = 0; i < 768; i++) {
        qge_palette_rgb[i] = palette[i];
    }
}

int QG_GetKey(int *down, int *key)
{
    if (qge_key_head == qge_key_tail) {
        return 0;
    }
    *down = qge_key_down[qge_key_head];
    *key = qge_key_code[qge_key_head];
    qge_key_head = (qge_key_head + 1) % QGE_KEY_QUEUE;
    return 1;
}

void QG_GetMouseMove(int *x, int *y)
{
    *x = qge_mouse_dx;
    *y = qge_mouse_dy;
    qge_mouse_dx = 0;
    qge_mouse_dy = 0;
}

void QG_GetJoyAxes(float *axes)
{
    int i = 0;

    for (i = 0; i < QUAKEGENERIC_JOY_MAX_AXES; i++) {
        axes[i] = 0.0f;
    }
}

static int qge_start(int argc)
{
    qge_argv[0] = "quake";
    qge_argv[1] = "-basedir";
    qge_argv[2] = QGE_BASEDIR;
    qge_argv[argc] = 0;
    qge_clock_ms = 0;
    QG_Create(argc, qge_argv);
    return qge_frame_count;
}

int qge_init(void)
{
    return qge_start(3);
}

int qge_init_map(void)
{
    qge_argv[3] = "+map";
    qge_argv[4] = "start";
    return qge_start(5);
}

void qge_tick(unsigned ms)
{
    unsigned elapsed = ms - qge_clock_ms;

    qge_clock_ms = ms;
    QG_Tick((double)elapsed / 1000.0);
}

void qge_key(int pressed, int qkey)
{
    int next = (qge_key_tail + 1) % QGE_KEY_QUEUE;

    if (next == qge_key_head) {
        return;
    }
    qge_key_down[qge_key_tail] = pressed ? 1 : 0;
    qge_key_code[qge_key_tail] = qkey;
    qge_key_tail = next;
}

void qge_mouse(int dx, int dy)
{
    qge_mouse_dx += dx;
    qge_mouse_dy += dy;
}

unsigned qge_screen(void)
{
    return (unsigned)(uintptr_t)qge_screen_pixels;
}

unsigned qge_palette(void)
{
    return (unsigned)(uintptr_t)qge_palette_rgb;
}

int qge_frames(void)
{
    return qge_frame_count;
}

int qge_width(void)
{
    return QUAKEGENERIC_RES_X;
}

int qge_height(void)
{
    return QUAKEGENERIC_RES_Y;
}
