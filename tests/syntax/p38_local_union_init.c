#include <stdint.h>

union local_overlay {
    uint32_t word;
    uint8_t byte;
};

int local_union_init_runtime(void) {
    union local_overlay value = { 0x11223344u };
    if (value.byte != 0x44u) return 1;
    value.word = 0;
    return value.byte;
}
