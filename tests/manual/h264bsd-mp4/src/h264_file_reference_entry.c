/* C-reference entrypoint over an MP4 file named by the last argument.
 *
 * Prints exactly what `src/h264_file_entry.das` prints: every decoded
 * picture's YUV hash.  `-Iinclude` shadows <stdio.h> with the fixture's stub
 * (an opaque `FILE`), so the libc entrypoints used here are declared locally.
 * The file goes into a static buffer, never into the fixture's bump heap:
 * `h264mp4_frames_begin_bytes` rewinds that heap and then demuxes the buffer
 * in place.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

extern FILE *stdout;

int printf(const char *format, ...);
int setvbuf(FILE *stream, char *buffer, int mode, size_t size);
FILE *fopen(const char *path, const char *mode);
size_t fread(void *buffer, size_t size, size_t count, FILE *stream);
int fclose(FILE *stream);

int32_t h264mp4_frames_begin_bytes(const uint8_t *bytes, int32_t length);
int32_t h264mp4_frames_next(void);
int32_t h264mp4_frames_hash(void);
int32_t h264mp4_frames_index(void);
int32_t h264mp4_frames_width(void);
int32_t h264mp4_frames_height(void);
int32_t h264mp4_frames_end(void);

#define MAX_FILE_BYTES (16 * 1024 * 1024)
static uint8_t file_bytes[MAX_FILE_BYTES];

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
    int32_t length = 0;

    setvbuf(stdout, NULL, 2 /* _IONBF */, 0);
    length = load_last_argument(argc, argv);
    if (length <= 0) {
        printf("load=0\n");
        return 2;
    }
    printf("bytes=%d\n", (int)length);
    if (!h264mp4_frames_begin_bytes(file_bytes, length)) {
        printf("frames_begin=0\n");
        return 1;
    }
    while (h264mp4_frames_next()) {
        printf("frame[%d]=%d\n", (int)h264mp4_frames_index(), (int)h264mp4_frames_hash());
        frames += 1;
    }
    printf("width=%d\n", (int)h264mp4_frames_width());
    printf("height=%d\n", (int)h264mp4_frames_height());
    h264mp4_frames_end();
    printf("frames=%d\n", frames);
    return frames > 0 ? 0 : 1;
}
