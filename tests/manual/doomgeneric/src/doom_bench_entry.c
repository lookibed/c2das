/* C benchmark entry of the doomgeneric corpus: the workload of
 * `doom_entry.c` (`-timedemo demo1` of the IWAD named by the last argument,
 * one hash per rendered frame) over more frames, timed.
 *
 * `setup_us` is `doomgeneric_Create`: the engine's whole startup, reading
 * and indexing the IWAD, building the renderer's tables and composite
 * textures, loading the demo and rendering the first 41 frames (the screen
 * wipe into E1M5).  `decode_us` is the tick loop that renders the other 959,
 * one demo tic per frame, the per-frame hash of `dg_platform.c` included.  Both are measured with `clock_gettime(CLOCK_MONOTONIC)`, and
 * everything is printed after the timed loop.
 *
 * It is the C side of the benchmark and, through `doom_bench_all.c`, the
 * translation input the benchmark translates under `--libc std`. */
#include <stdint.h>
#include <stdio.h>
#include <time.h>

#include "doomgeneric.h"

/* Frames recorded: the wipe, then 959 of DEMO1's 5026 tics (about 27
 * seconds of play). */
#define FRAME_LIMIT 1000

static char *doom_argv[8];

static int64_t now_us(void)
{
    struct timespec ts;

    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (int64_t)ts.tv_sec * 1000000 + (int64_t)ts.tv_nsec / 1000;
}

int main(int argc, char **argv)
{
    int64_t t0 = 0;
    int64_t t1 = 0;
    int64_t t2 = 0;
    int i = 0;

    setvbuf(stdout, NULL, _IONBF, 0);

    if (argc < 2) {
        printf("load=0\n");
        return 2;
    }
    doom_argv[0] = "doom";
    doom_argv[1] = "-iwad";
    doom_argv[2] = argv[argc - 1];
    doom_argv[3] = "-nosound";
    doom_argv[4] = "-nomusic";
    doom_argv[5] = "-timedemo";
    doom_argv[6] = "demo1";
    doom_argv[7] = NULL;

    t0 = now_us();
    doomgeneric_Create(7, doom_argv);
    t1 = now_us();
    while (dg_frame_count < FRAME_LIMIT) {
        dg_advance_clock();
        doomgeneric_Tick();
    }
    t2 = now_us();

    for (i = 0; i < FRAME_LIMIT; i++) {
        printf("frame[%d]=%d\n", i, (int)dg_frame_hash[i]);
    }
    printf("frames=%d\n", FRAME_LIMIT);
    printf("setup_us=%lld\n", (long long)(t1 - t0));
    printf("decode_us=%lld\n", (long long)(t2 - t1));
    return 0;
}
