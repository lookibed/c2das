/* C-reference entrypoint over a stream file named by the last argument.
 *
 * Prints exactly what `src/plmpeg_file_entry.das` prints: every decoded
 * frame's RGB hash.  The file goes into a static buffer, never into the
 * fixture's bump heap: `plmpeg_frames_begin_bytes` rewinds that heap through
 * c2da_rt_reset() before it takes its working copy.
 */
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

int32_t plmpeg_frames_begin_bytes(const uint8_t *bytes, int32_t length);
int32_t plmpeg_frames_next(void);
int32_t plmpeg_frames_hash(void);
int32_t plmpeg_frames_index(void);
int32_t plmpeg_frames_width(void);
int32_t plmpeg_frames_height(void);
int32_t plmpeg_frames_end(void);

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

    setvbuf(stdout, NULL, _IONBF, 0);
    length = load_last_argument(argc, argv);
    if (length <= 0) {
        printf("load=0\n");
        return 2;
    }
    printf("bytes=%" PRId32 "\n", length);
    if (!plmpeg_frames_begin_bytes(file_bytes, length)) {
        printf("frames_begin=0\n");
        return 1;
    }
    printf("width=%" PRId32 "\n", plmpeg_frames_width());
    printf("height=%" PRId32 "\n", plmpeg_frames_height());
    while (plmpeg_frames_next()) {
        printf("frame[%" PRId32 "]=%" PRId32 "\n", plmpeg_frames_index(), plmpeg_frames_hash());
        frames += 1;
    }
    plmpeg_frames_end();
    printf("frames=%d\n", frames);
    return frames > 0 ? 0 : 1;
}
