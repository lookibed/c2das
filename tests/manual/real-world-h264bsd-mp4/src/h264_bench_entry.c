/* Benchmark entrypoint for the H264BSD + minimp4 graph (C build).
 *
 * Prints exactly what `src/h264_bench_entry.das` prints so the benchmark
 * driver can verify the per-frame hashes against the C build before it
 * records a timing:
 *
 *   frame[i]=<hash>      one line per decoded picture
 *   frames=<n>
 *   width=<w>
 *   height=<h>
 *   setup_us=<n>         h264mp4_frames_begin(): heap reset, demuxer open, decoder init
 *   decode_us=<n>        the h264mp4_frames_next() loop only ("hot" decode time)
 *
 * Hashes are collected first and printed after the timed loop, so printing
 * never lands inside decode_us.  `-Iinclude` shadows <stdio.h> with the
 * fixture's stub, so printf/setvbuf are declared locally; <time.h> is real.
 */
#define _POSIX_C_SOURCE 200809L
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <time.h>

extern FILE *stdout;

int printf(const char *format, ...);
int setvbuf(FILE *stream, char *buffer, int mode, size_t size);

int32_t h264mp4_frames_begin(void);
int32_t h264mp4_frames_next(void);
int32_t h264mp4_frames_hash(void);
int32_t h264mp4_frames_width(void);
int32_t h264mp4_frames_height(void);
int32_t h264mp4_frames_end(void);

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

    /* Unbuffered: see h264_reference_entry.c for why a buffered stdout and the
     * bump allocator do not mix. */
    setvbuf(stdout, NULL, 2 /* _IONBF */, 0);
    t0 = now_us();
    if (!h264mp4_frames_begin()) {
        printf("frames_begin=0\n");
        return 1;
    }
    t1 = now_us();
    while (h264mp4_frames_next()) {
        if (frames < MAX_FRAMES) {
            hashes[frames] = h264mp4_frames_hash();
        }
        frames += 1;
    }
    t2 = now_us();
    for (i = 0; i < frames && i < MAX_FRAMES; i++) {
        printf("frame[%d]=%d\n", i, (int)hashes[i]);
    }
    printf("frames=%d\n", frames);
    printf("width=%d\n", (int)h264mp4_frames_width());
    printf("height=%d\n", (int)h264mp4_frames_height());
    h264mp4_frames_end();
    printf("setup_us=%lld\n", (long long)(t1 - t0));
    printf("decode_us=%lld\n", (long long)(t2 - t1));
    return frames > 0 ? 0 : 1;
}
