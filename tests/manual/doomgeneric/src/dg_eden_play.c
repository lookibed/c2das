/* The interactive doomgeneric platform layer of the EdenSpark player
 * (`eden/c2das_doom_player.das`), and the host API it calls.
 *
 * - `dge_init` starts the engine on the IWAD `doom1.wad`, which the host has
 *   registered with `c2da_eden_add_file` beforehand.
 * - `dge_tick(ms)` sets the host part of the clock `DG_GetTicksMs` answers and runs one
 *   `doomgeneric_Tick`.  The host advances it by one game tic (1000 / 35 ms)
 *   per call, so a slow interpreter plays the game slowed down instead of
 *   running several tics per call to catch up.
 * - `dge_key(pressed, key)` queues a key event (`doomkeys.h` codes) for
 *   `DG_GetKey`.
 * - `dge_screen` and `dge_palette` answer the addresses of `DG_ScreenBuffer`
 *   (320x200 palette indices under `CMAP256`) and of Doom's palette
 *   `colors[256]` (`struct color`: one 4-byte bitfield unit per entry, bytes
 *   b, g, r, a) as integers: under
 *   `--memory-model linear` they are offsets into the heap `c2da_mem`.
 * - `dge_frames` counts `DG_DrawFrame` calls. */
#include <stdint.h>

#include "doomgeneric.h"
#include "i_video.h"

#define DGE_KEY_QUEUE 64

static uint32_t dge_clock_ms = 1000;
static int dge_frame_count = 0;
static int dge_key_pressed[DGE_KEY_QUEUE];
static unsigned char dge_key_code[DGE_KEY_QUEUE];
static int dge_key_head = 0;
static int dge_key_tail = 0;
static char *dge_argv[8];

void DG_Init(void)
{
}

void DG_DrawFrame(void)
{
    dge_frame_count += 1;
}

/* The screen wipe (`d_main.c`) and `TryRunTics` (`d_loop.c`) busy-wait on
 * `I_Sleep` until the clock moves, so a sleep advances the clock; the host's
 * clock in `dge_tick` is added on top of everything slept so far. */
static uint32_t dge_slept_ms = 0;
static uint32_t dge_host_ms = 0;

void DG_SleepMs(uint32_t ms)
{
    dge_slept_ms += ms;
    dge_clock_ms = 1000u + dge_host_ms + dge_slept_ms;
}

uint32_t DG_GetTicksMs(void)
{
    return dge_clock_ms;
}

int DG_GetKey(int *pressed, unsigned char *key)
{
    if (dge_key_head == dge_key_tail) {
        return 0;
    }
    *pressed = dge_key_pressed[dge_key_head];
    *key = dge_key_code[dge_key_head];
    dge_key_head = (dge_key_head + 1) % DGE_KEY_QUEUE;
    return 1;
}

void DG_SetWindowTitle(const char *title)
{
    (void)title;
}

int dge_init(void)
{
    dge_argv[0] = "doom";
    dge_argv[1] = "-iwad";
    dge_argv[2] = "doom1.wad";
    dge_argv[3] = "-nosound";
    dge_argv[4] = "-nomusic";
    dge_argv[5] = 0;
    doomgeneric_Create(5, dge_argv);
    return dge_frame_count;
}

void dge_tick(unsigned ms)
{
    /* i_timer.c treats a zero first reading as "no base time yet" */
    dge_host_ms = ms;
    dge_clock_ms = 1000u + dge_host_ms + dge_slept_ms;
    doomgeneric_Tick();
}

void dge_key(int pressed, int doomkey)
{
    int next = (dge_key_tail + 1) % DGE_KEY_QUEUE;

    if (next == dge_key_head) {
        return;
    }
    dge_key_pressed[dge_key_tail] = pressed ? 1 : 0;
    dge_key_code[dge_key_tail] = (unsigned char)doomkey;
    dge_key_tail = next;
}

unsigned dge_screen(void)
{
    return (unsigned)(uintptr_t)DG_ScreenBuffer;
}

unsigned dge_palette(void)
{
    return (unsigned)(uintptr_t)colors;
}

int dge_frames(void)
{
    return dge_frame_count;
}
