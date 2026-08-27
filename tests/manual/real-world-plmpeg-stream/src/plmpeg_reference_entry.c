/* C-reference entrypoint for the canonical PLMPEG graph.
 *
 * Keep this deliberately small and scalar-only: it validates the decoder
 * vertical slice without introducing a second host-pointer transport ABI.
 */
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

int32_t plmpeg_probe_sequence_start_code(void);
int32_t plmpeg_probe_video_has_header(void);

int main(void) {
    setvbuf(stdout, NULL, _IONBF, 0);
    printf("sequence_start_code=%" PRId32 "\n", plmpeg_probe_sequence_start_code());
    printf("video_has_header=%" PRId32 "\n", plmpeg_probe_video_has_header());
    return 0;
}
