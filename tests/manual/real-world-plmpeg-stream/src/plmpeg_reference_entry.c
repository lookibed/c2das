/* C-reference entrypoint for the canonical PLMPEG graph.
 *
 * Scalar-only: every probe returns int32_t, so the oracle needs no
 * host-pointer transport ABI.  The lines printed here are the contract that
 * `src/plmpeg_entry.das` must reproduce, in this order: the two header
 * probes, then every decoded frame's RGB hash from the streaming API.
 */
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

int32_t plmpeg_probe_sequence_start_code(void);
int32_t plmpeg_probe_video_has_header(void);
int32_t plmpeg_frames_begin(void);
int32_t plmpeg_frames_next(void);
int32_t plmpeg_frames_hash(void);
int32_t plmpeg_frames_index(void);
int32_t plmpeg_frames_width(void);
int32_t plmpeg_frames_height(void);
int32_t plmpeg_frames_end(void);

int main(void) {
    int frames = 0;

    setvbuf(stdout, NULL, _IONBF, 0);
    printf("sequence_start_code=%" PRId32 "\n", plmpeg_probe_sequence_start_code());
    printf("video_has_header=%" PRId32 "\n", plmpeg_probe_video_has_header());
    if (!plmpeg_frames_begin()) {
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
