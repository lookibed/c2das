/* Platform layer shared by the corpus entries: ROM loading, the emulator's
 * configuration, the scripted joypad input and the per-frame hash.
 *
 * Everything here is written against binjgb's public API (`emulator.h`,
 * `common.h`); nothing reaches into the emulator's internals.
 *
 * - The ROM is the file named by the last command-line argument, read with
 *   upstream's own `file_read_aligned` padded to `MINIMUM_ROM_SIZE`, the way
 *   binjgb's SDL host reads it.  The emulator takes ownership of that heap
 *   block (`emulator_delete` frees it and `emulator_new` may `realloc` it),
 *   so it can be neither static nor embedded.
 * - Game Boy Color mode (`force_dmg` off; cgb-acid2's header asks for CGB),
 *   `CGB_COLOR_CURVE_NONE`, a fixed random seed, 44100 Hz audio in
 *   2048-frame buffers.  Audio is generated and discarded: the loop only
 *   waits for `EMULATOR_EVENT_NEW_FRAME`.
 * - The scripted input holds A on frames 8 and 9 and nothing otherwise;
 *   cgb-acid2 shows its "press A" screen until then and the acid2 face after.
 * - A frame's hash is 32-bit FNV-1a over the framebuffer packed to RGB555,
 *   two bytes per pixel, low byte first: each channel of binjgb's RGBA
 *   framebuffer (R in the low byte) shifted right by 3, packed as
 *   `r << 10 | g << 5 | b`.  With `CGB_COLOR_CURVE_NONE` binjgb writes a
 *   5-bit CGB colour c as `c << 3`, so the packing recovers the CGB palette
 *   colour exactly.  It is the packing and hash of the Spider fixture this
 *   corpus comes from, so its frame hashes are comparable (`README.md`).
 */
#include <stddef.h>
#include <stdint.h>

#include "common.h"
#include "emulator.h"

#define GB_PRESS_A_FIRST 8
#define GB_PRESS_A_LAST 9

static JoypadButtons gb_live_buttons;

static void gb_joypad_callback(JoypadButtons *buttons, void *user_data) {
    (void)user_data;
    *buttons = gb_live_buttons;
}

static void gb_script_buttons(int frame_index, JoypadButtons *buttons) {
    ZERO_MEMORY(*buttons);
    if (frame_index >= GB_PRESS_A_FIRST && frame_index <= GB_PRESS_A_LAST) {
        buttons->A = TRUE;
    }
}

/* The ROM named by the last argument, padded to MINIMUM_ROM_SIZE.  Returns 0
 * when there is no argument or the file cannot be read. */
static int gb_load_rom(int argc, char **argv, FileData *out) {
    out->data = NULL;
    out->size = 0;
    if (argc < 2) {
        return 0;
    }
    if (!SUCCESS(file_read_aligned(argv[argc - 1], MINIMUM_ROM_SIZE, out))) {
        return 0;
    }
    return 1;
}

static Emulator *gb_create(const FileData *rom) {
    EmulatorInit init;
    Emulator *emulator = NULL;

    ZERO_MEMORY(init);
    init.rom = *rom;
    init.audio_frequency = 44100;
    init.audio_frames = 2048;
    init.random_seed = 0xcabba6e5u;
    init.builtin_palette = 0;
    init.force_dmg = FALSE;
    init.cgb_color_curve = CGB_COLOR_CURVE_NONE;
    emulator = emulator_new(&init);
    if (emulator) {
        ZERO_MEMORY(gb_live_buttons);
        emulator_set_joypad_callback(emulator, gb_joypad_callback, NULL);
    }
    return emulator;
}

/* Runs frame `frame_index` of the script: sets its buttons and emulates until
 * the PPU finishes the next frame.  Returns 0 on an invalid opcode. */
static int gb_run_frame(Emulator *emulator, int frame_index) {
    Ticks until_ticks = emulator_get_ticks(emulator) + PPU_FRAME_TICKS;

    gb_script_buttons(frame_index, &gb_live_buttons);
    for (;;) {
        EmulatorEvent event = emulator_run_until(emulator, until_ticks);
        if (event & EMULATOR_EVENT_NEW_FRAME) {
            return 1;
        }
        if (event & EMULATOR_EVENT_INVALID_OPCODE) {
            return 0;
        }
        if (event & EMULATOR_EVENT_UNTIL_TICKS) {
            until_ticks += PPU_FRAME_TICKS;
        }
    }
}

static int32_t gb_frame_hash(Emulator *emulator) {
    const RGBA *pixels = *emulator_get_frame_buffer(emulator);
    uint32_t hash = 2166136261u;
    int i = 0;

    for (i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++) {
        RGBA rgba = pixels[i];
        uint32_t r = ((rgba >> 0) & 0xffu) >> 3;
        uint32_t g = ((rgba >> 8) & 0xffu) >> 3;
        uint32_t b = ((rgba >> 16) & 0xffu) >> 3;
        uint32_t packed = (r << 10) | (g << 5) | b;
        hash ^= packed & 0xffu;
        hash *= 16777619u;
        hash ^= packed >> 8;
        hash *= 16777619u;
    }
    return (int32_t)hash;
}
