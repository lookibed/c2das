/* Benchmark entrypoint over a stream file named by the last argument.
 *
 * Prints every decoded frame's RGB hash plus the time spent in
 * `frames_begin_bytes()` (setup_us) and in the `frames_next()` loop
 * (decode_us).  It is both the C benchmark program of the file cases and,
 * through `src/plmpeg_file_bench_all.c`, a translation input under
 * `--libc std`: the fixture's `include/stdio.h` and `include/time.h` declare
 * the libc subset with the glibc ABI, so the same source links against the
 * real libc and translates to daslang without edits.  Hashes are collected
 * first and printed after the timed loop; reading the file happens before any
 * timer starts; the bytes live in a static buffer, never in the fixture's
 * bump heap (see plmpeg_file_reference_entry.c).
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <time.h>

int32_t plmpeg_frames_begin_bytes(const uint8_t *bytes, int32_t length);
int32_t plmpeg_frames_next(void);
int32_t plmpeg_frames_hash(void);
int32_t plmpeg_frames_width(void);
int32_t plmpeg_frames_height(void);
int32_t plmpeg_frames_end(void);

#define MAX_FRAMES 4096
#define MAX_FILE_BYTES (4 * 1024 * 1024)
static uint8_t file_bytes[MAX_FILE_BYTES];
static int32_t hashes[MAX_FRAMES];

static int64_t now_us(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (int64_t)ts.tv_sec * 1000000 + ts.tv_nsec / 1000;
}

static int32_t load_last_argument(int argc, char **argv) {
    FILE *f = 0;
    size_t got = 0;

    if (argc < 2) {
        return 0;
    }
    f = fopen(argv[argc - 1], "rb");
    if (!f) {
        return 0;
    }
    got = fread(file_bytes, 1, MAX_FILE_BYTES, f);
    fclose(f);
    return (int32_t)got;
}

int main(int argc, char **argv) {
    int frames = 0;
    int i = 0;
    int32_t length = 0;
    int64_t t0 = 0;
    int64_t t1 = 0;
    int64_t t2 = 0;

    setvbuf(stdout, NULL, _IONBF, 0);
    length = load_last_argument(argc, argv);
    if (length <= 0) {
        printf("load=0\n");
        return 2;
    }
    t0 = now_us();
    if (!plmpeg_frames_begin_bytes(file_bytes, length)) {
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
        printf("frame[%d]=%d\n", i, (int)hashes[i]);
    }
    printf("frames=%d\n", frames);
    printf("width=%d\n", (int)plmpeg_frames_width());
    printf("height=%d\n", (int)plmpeg_frames_height());
    plmpeg_frames_end();
    printf("setup_us=%lld\n", (long long)(t1 - t0));
    printf("decode_us=%lld\n", (long long)(t2 - t1));
    return frames > 0 ? 0 : 1;
}
