/* `ring_b.c` calls `ring_c.c` and is called back by `ring_a.c`. */
#include "ring.h"

int b_helper(int v) { return v - 1; }

int b_fn(int v) {
    ring_calls++;
    return v > 0 ? c_fn(b_helper(v + 1)) : 0;
}
