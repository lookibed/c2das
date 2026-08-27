#include <stdint.h>
#include <stdlib.h>

struct nested_inner {
    uint32_t count;
    uint16_t flags;
};

struct nested_outer {
    uint8_t tag;
    struct nested_inner inner;
};

int nested_raw_aggregate_place_runtime(void) {
    struct nested_outer *object = calloc(1, sizeof(struct nested_outer));
    object->inner.count = 0x10203040u;
    object->inner.flags = 7u;
    int failed = object->inner.count != 0x10203040u || object->inner.flags != 7u;
    free(object);
    return failed;
}
