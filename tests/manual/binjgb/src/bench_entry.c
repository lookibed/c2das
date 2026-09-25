/* C entrypoint of the benchmark: the canonical program over GB_BENCH_FRAMES
 * frames, plus the time of emulator creation (`setup_us`) and of the frame
 * loop (`decode_us`), measured with `clock_gettime(CLOCK_MONOTONIC)`.
 *
 * The ROM is read before any timer starts.  The frame loop emulates and
 * hashes each frame; the hashes are collected first and printed after the
 * timed loop, so no output is inside it.  Through `src/binjgb_bench_all.c`
 * it is also the benchmark's translation input under `--libc std`. */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <time.h>

#ifndef GB_BENCH_FRAMES
#define GB_BENCH_FRAMES 300
#endif

static int32_t bench_hashes[GB_BENCH_FRAMES];

static int64_t now_us(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (int64_t)ts.tv_sec * 1000000 + (int64_t)(ts.tv_nsec / 1000);
}

int main(int argc, char **argv) {
    FileData rom;
    Emulator *emulator = NULL;
    int64_t setup_start = 0;
    int64_t decode_start = 0;
    int64_t setup_us = 0;
    int64_t decode_us = 0;
    int frames = 0;
    int i = 0;

    setvbuf(stdout, NULL, _IONBF, 0);
    if (!gb_load_rom(argc, argv, &rom)) {
        printf("error=load\n");
        return 2;
    }
    printf("rom_bytes=%d\n", (int)rom.size);

    setup_start = now_us();
    emulator = gb_create(&rom);
    setup_us = now_us() - setup_start;
    if (!emulator) {
        printf("error=emulator\n");
        return 1;
    }

    decode_start = now_us();
    for (i = 0; i < GB_BENCH_FRAMES; i++) {
        if (!gb_run_frame(emulator, i)) {
            break;
        }
        bench_hashes[i] = gb_frame_hash(emulator);
        frames += 1;
    }
    decode_us = now_us() - decode_start;

    for (i = 0; i < frames; i++) {
        printf("frame[%d]=%d\n", i, (int)bench_hashes[i]);
    }
    printf("frames=%d\n", frames);
    printf("setup_us=%lld\n", (long long)setup_us);
    printf("decode_us=%lld\n", (long long)decode_us);

    emulator_delete(emulator);
    return frames == GB_BENCH_FRAMES ? 0 : 1;
}
