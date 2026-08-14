#include <stdint.h>
#include <stdlib.h>

struct padded_object {
    uint32_t first;
    uint8_t tag;
    uint32_t value;
};

int pointer_backed_struct_runtime(void) {
    struct padded_object *object = calloc(1, sizeof(struct padded_object));
    object->first = 7u;
    object->value = 0x10203040u;
    int failed = object->first != 7u || object->value != 0x10203040u;
    free(object);
    return failed;
}
