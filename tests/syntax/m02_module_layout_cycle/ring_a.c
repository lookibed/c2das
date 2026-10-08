/* The entry unit; it calls into `ring_b.c` and is called back by `ring_c.c`,
 * so the module holding `main` is itself part of the cycle. */
#include <stdio.h>
#include "ring.h"

int ring_calls = 0;

int a_fn(int v) {
    ring_calls++;
    return v > 0 ? b_fn(v - 1) + 1 : 0;
}

int main(void) {
    int result = a_fn(7);
    printf("result=%d calls=%d\n", result, ring_calls);
    return result == 7 ? 0 : 1;
}
