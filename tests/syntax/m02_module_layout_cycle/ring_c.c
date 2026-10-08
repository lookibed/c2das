/* `ring_c.c` calls back into `ring_b.c`, closing the cycle. */
#include "ring.h"

int c_fn(int v) { return b_fn(b_helper(v)); }
