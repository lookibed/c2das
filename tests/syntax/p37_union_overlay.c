#include <stdint.h>
#include <stdlib.h>

union overlay_word {
    uint32_t word;
    uint8_t byte;
};

int union_overlay_runtime(void) {
    union overlay_word *value = calloc(1, sizeof(union overlay_word));
    value->word = 0x11223344u;
    int failed = value->byte != 0x44u;
    free(value);
    return failed;
}
