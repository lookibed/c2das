/* Benchmark entrypoint over an MP4 file named by the last argument (C build).
 *
 * Prints exactly what `src/h264_file_bench_entry.das` prints; see
 * `h264_bench_entry.c` for the line contract.  Reading the file is outside
 * every timed region; the bytes live in a static buffer, never in the
 * fixture's bump heap (see h264_file_reference_entry.c).  `-Iinclude` shadows
 * <stdio.h> with the fixture's stub, so the libc entrypoints are declared
 * locally; <time.h> is real.
 */
#define _POSIX_C_SOURCE 200809L
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <time.h>

extern FILE *stdout;

int printf(const char *format, ...);
int setvbuf(FILE *stream, char *buffer, int mode, size_t size);
FILE *fopen(const char *path, const char *mode);
size_t fread(void *buffer, size_t size, size_t count, FILE *stream);
int fclose(FILE *stream);

int32_t h264mp4_frames_begin_bytes(const uint8_t *bytes, int32_t length);
int32_t h264mp4_frames_next(void);
int32_t h264mp4_frames_hash(void);
int32_t h264mp4_frames_width(void);
int32_t h264mp4_frames_height(void);
int32_t h264mp4_frames_end(void);

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

    setvbuf(stdout, NULL, 2 /* _IONBF */, 0);
    length = load_last_argument(argc, argv);
    if (length <= 0) {
        printf("load=0\n");
        return 2;
    }
    t0 = now_us();
    if (!h264mp4_frames_begin_bytes(file_bytes, length)) {
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
