/* Real PLMPEG header macro provenance, isolated from the decoder's multi-TU graph. */
#include <stddef.h>
#include <stdint.h>

#define PLM_NO_STDIO
#include "../upstream/pl_mpeg.h"

int plmpeg_macro_origin_probe(void) {
    size_t configured = PLM_BUFFER_DEFAULT_SIZE;
    int invalid_timestamp = PLM_PACKET_INVALID_TS;
    return configured != (128u * 1024u) || invalid_timestamp != -1;
}
