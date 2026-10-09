/* The entry unit: writes another unit's objects through pointers and reads
 * them back by name. */
#include <stdio.h>
#include "shared.h"

static void bump(int *p, int by) { *p += by; }

int main(void) {
    bump(&counter, 3);
    bump(cursor, 2);
    int *last = values + 3;
    *last = counter;
    printf("counter=%d values=%d,%d,%d,%d cursor=%d run=%d\n", counter, values[0], values[1],
           values[2], values[3], *cursor, run_states(counter));
    return 0;
}
