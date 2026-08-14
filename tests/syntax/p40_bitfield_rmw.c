#include <stdint.h>
#include <stdlib.h>

struct flags {
    uint32_t low : 3;
    uint32_t high : 5;
};

int bitfield_rmw_runtime(void) {
    struct flags *value = calloc(1, sizeof(struct flags));
    value->low = 5;
    value->high = 17;
    int failed = value->low != 5 || value->high != 17;
    free(value);
    return failed;
}
