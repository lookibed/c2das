/* Benchmark entrypoint for the PLMPEG graph (C build).
 *
 * Prints exactly what `src/plmpeg_bench_entry.das` prints so the benchmark
 * driver can verify the per-frame hashes against the C build before it
 * records a timing:
 *
 *   frame[i]=<hash>      one line per decoded frame
 *   frames=<n>
 *   width=<w>
 *   height=<h>
 *   setup_us=<n>         plmpeg_frames_begin(): runtime reset, sample copy, decoder
 *   decode_us=<n>        the plmpeg_frames_next() loop only ("hot" decode time)
 *
 * Hashes are collected first and printed after the timed loop, so printing
 * never lands inside decode_us.  `_POSIX_C_SOURCE` exposes clock_gettime under
 * the graph's strict -std=c11.
 */
#define _POSIX_C_SOURCE 200809L
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <time.h>

int32_t plmpeg_frames_begin(void);
int32_t plmpeg_frames_next(void);
int32_t plmpeg_frames_hash(void);
int32_t plmpeg_frames_width(void);
int32_t plmpeg_frames_height(void);
int32_t plmpeg_frames_end(void);

#define MAX_FRAMES 4096

static int64_t now_us(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (int64_t)ts.tv_sec * 1000000 + ts.tv_nsec / 1000;
}

int main(void) {
    static int32_t hashes[MAX_FRAMES];
    int frames = 0;
    int i = 0;
    int64_t t0 = 0;
    int64_t t1 = 0;
    int64_t t2 = 0;

    setvbuf(stdout, NULL, _IONBF, 0);
    t0 = now_us();
    if (!plmpeg_frames_begin()) {
        printf("frames_begin=0\n");
        return 1;
    }
    t1 = now_us();
    while (plmpeg_frames_next()) {
        if (frames < MAX_FRAMES) {
            hashes[frames] = plmpeg_frames_hash();
        }
        frames += 1;
    }
    t2 = now_us();
    for (i = 0; i < frames && i < MAX_FRAMES; i++) {
        printf("frame[%d]=%" PRId32 "\n", i, hashes[i]);
    }
    printf("frames=%d\n", frames);
    printf("width=%" PRId32 "\n", plmpeg_frames_width());
    printf("height=%" PRId32 "\n", plmpeg_frames_height());
    plmpeg_frames_end();
    printf("setup_us=%" PRId64 "\n", t1 - t0);
    printf("decode_us=%" PRId64 "\n", t2 - t1);
    return frames > 0 ? 0 : 1;
}
