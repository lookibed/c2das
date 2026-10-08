/* `ring_c.c` calls back into `ring_a.c`, closing the cycle. */
#include "ring.h"

int c_fn(int v) {
    ring_calls++;
    return a_fn(v);
}
