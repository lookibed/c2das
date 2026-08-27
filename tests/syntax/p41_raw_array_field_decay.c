#include <stdint.h>
#include <stdlib.h>

struct byte_payload {
    uint8_t prefix;
    uint8_t bytes[4];
};

int raw_array_field_decay_runtime(void) {
    struct byte_payload *payload = calloc(1, sizeof(struct byte_payload));
    uint8_t *bytes = payload->bytes;
    int failed = bytes == 0 || payload->bytes[0] != 0u || payload->bytes[3] != 0u;
    free(payload);
    return failed;
}
