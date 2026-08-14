#include <stdint.h>
#include <stdlib.h>

struct __attribute__((packed)) packed_pair {
    uint8_t tag;
    uint32_t value;
};

int packed_scalar_runtime(void) {
    struct packed_pair *pair = calloc(1, sizeof(struct packed_pair));
    pair->value = 0x12345678u;
    int failed = pair->value != 0x12345678u;
    free(pair);
    return failed;
}
