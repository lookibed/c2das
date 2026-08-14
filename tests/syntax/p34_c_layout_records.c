#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>

struct padded_record {
    uint8_t tag;
    uint32_t value;
    uint16_t tail;
};

union sized_union {
    uint8_t byte;
    uint32_t word;
};

int c_layout_records_runtime(void) {
    struct padded_record *items = calloc(2, sizeof(struct padded_record));
    size_t answer = sizeof(struct padded_record)
        + _Alignof(struct padded_record)
        + offsetof(struct padded_record, value)
        + sizeof(union sized_union)
        + _Alignof(union sized_union);
    free(items);
    return answer != 28;
}
