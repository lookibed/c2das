/* `ring_b.c` calls `ring_c.c` and is called back by it: a reference cycle. */
#include "ring.h"

int b_helper(int v) { return v - 1; }

int b_fn(int v) { return v > 0 ? c_fn(v) : 0; }
