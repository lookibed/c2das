/* Benchmark entrypoint over a stream file named by the last argument (C build).
 *
 * Prints exactly what `src/plmpeg_file_bench_entry.das` prints; see
 * `plmpeg_bench_entry.c` for the line contract.  Reading the file is outside
 * every timed region, and the bytes live in a static buffer, never in the
 * fixture's bump heap (see plmpeg_file_reference_entry.c).
 */
#define _POSIX_C_SOURCE 200809L
#include <inttypes.h>
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
#define MAX_FILE_BYTES (16 * 1024 * 1024)
static uint8_t file_bytes[MAX_FILE_BYTES];

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
    static int32_t hashes[MAX_FRAMES];
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
