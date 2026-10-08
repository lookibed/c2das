/* C entrypoint of the canonical case: emulates the ROM named by the last
 * argument for GB_FRAMES frames under the scripted input of `platform.c` and
 * prints one framebuffer hash per frame.
 *
 * It is the C reference program of the corpus and, through
 * `src/binjgb_all.c`, a translation input under `--libc std`: the fixture's
 * `include/` headers declare the libc subset with the glibc ABI, so the same
 * source links against the real libc and translates to daslang without
 * edits.  Output: `rom_bytes=`, the cartridge header lines binjgb itself
 * prints while loading the ROM, `width=`, `height=`, `frame[i]=<hash>` per
 * frame, `frames=`, then `ticks=`, the emulated CPU clock after the last
 * frame (a cycle-level check the static cgb-acid2 image alone would not
 * give).  A failure prints `error=<stage>` and exits non-zero. */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

#include "common.h"
#include "emulator.h"

/* The platform layer (`platform.c`), declared here for the case that
 * compiles every unit on its own (`binjgb-cgb-acid2-std-source`). */
int gb_load_rom(int argc, char **argv, FileData *out);
Emulator *gb_create(const FileData *rom);
int gb_run_frame(Emulator *emulator, int frame_index);
int32_t gb_frame_hash(Emulator *emulator);

#ifndef GB_FRAMES
#define GB_FRAMES 60
#endif

int main(int argc, char **argv) {
    FileData rom;
    Emulator *emulator = NULL;
    int frames = 0;
    int i = 0;

    setvbuf(stdout, NULL, _IONBF, 0);
    if (!gb_load_rom(argc, argv, &rom)) {
        printf("error=load\n");
        return 2;
    }
    printf("rom_bytes=%d\n", (int)rom.size);

    emulator = gb_create(&rom);
    if (!emulator) {
        printf("error=emulator\n");
        return 1;
    }
    printf("width=%d\n", SCREEN_WIDTH);
    printf("height=%d\n", SCREEN_HEIGHT);

    for (i = 0; i < GB_FRAMES; i++) {
        if (!gb_run_frame(emulator, i)) {
            printf("error=invalid_opcode frame=%d\n", i);
            emulator_delete(emulator);
            return 1;
        }
        printf("frame[%d]=%d\n", i, (int)gb_frame_hash(emulator));
        frames += 1;
    }
    printf("frames=%d\n", frames);
    printf("ticks=%lld\n", (long long)emulator_get_ticks(emulator));

    emulator_delete(emulator);
    return frames == GB_FRAMES ? 0 : 1;
}
