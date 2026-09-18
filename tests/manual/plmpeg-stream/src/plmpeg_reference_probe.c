/* Narrow C-reference diagnostic runner.  It lets the end-to-end oracle keep
 * a precise boundary when one decoder probe is not yet reference-safe. */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

int strcmp(const char *lhs, const char *rhs);

int32_t plmpeg_decode_hash(int32_t);
int32_t plmpeg_probe_width(void);
int32_t plmpeg_probe_height(void);
int32_t plmpeg_probe_frame_count(int32_t);
int32_t plmpeg_probe_first_frame_hash(void);
int32_t plmpeg_probe_last_frame_hash(int32_t);
int32_t plmpeg_probe_sequence_start_code(void);
int32_t plmpeg_probe_video_has_header(void);

int main(int argc, char **argv) {
    if (argc != 2) return 64;
    if (!strcmp(argv[1], "decode_hash")) return printf("%d\n", plmpeg_decode_hash(1)) < 0;
    if (!strcmp(argv[1], "width")) return printf("%d\n", plmpeg_probe_width()) < 0;
    if (!strcmp(argv[1], "height")) return printf("%d\n", plmpeg_probe_height()) < 0;
    if (!strcmp(argv[1], "frame_count")) return printf("%d\n", plmpeg_probe_frame_count(1)) < 0;
    if (!strcmp(argv[1], "first_hash")) return printf("%d\n", plmpeg_probe_first_frame_hash()) < 0;
    if (!strcmp(argv[1], "last_hash")) return printf("%d\n", plmpeg_probe_last_frame_hash(1)) < 0;
    if (!strcmp(argv[1], "start_code")) return printf("%d\n", plmpeg_probe_sequence_start_code()) < 0;
    if (!strcmp(argv[1], "has_header")) return printf("%d\n", plmpeg_probe_video_has_header()) < 0;
    return 64;
}
