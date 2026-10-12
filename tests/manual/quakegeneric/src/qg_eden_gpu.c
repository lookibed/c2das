/* The `eden_gpu` ABI v0 variant of the interactive platform layer
 * `qg_eden_play.c`: the same host API (`qg_eden.h`), but the engine hands
 * every frame and palette to the host itself through the host imports of
 * `qg_eden_gpu.h` instead of the host polling `qge_screen`/`qge_palette`.
 * `QG_DrawFrame` calls `eden_gpu_present(pixels, 320, 240)` and
 * `QG_SetPalette` calls `eden_gpu_palette(rgb768)`; both are bound to
 * `eden/eden_gpu.das` with `--host-import-prefix eden_gpu_=eden_gpu`.  The
 * rest (`qge_init`, `qge_tick`, `qge_key`, `qge_mouse`) is unchanged; see
 * `qg_eden_play.c` for what each function does. */
#include <stdint.h>

#include "qg_eden_gpu.h"
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
    eden_gpu_present(qge_screen_pixels, QUAKEGENERIC_RES_X, QUAKEGENERIC_RES_Y);
}

void QG_SetPalette(unsigned char palette[768])
{
    int i = 0;

    for (i = 0; i < 768; i++) {
        qge_palette_rgb[i] = palette[i];
    }
    eden_gpu_palette(qge_palette_rgb);
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
