#include <stdint.h>

union cast_overlay {
    uint32_t word;
    uint8_t byte;
};

int union_cast_runtime(void) {
    union cast_overlay value = (union cast_overlay)0x11223344u;
    return value.byte != 0x44u;
}
