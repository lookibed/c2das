/* Unit 3, the entry: calls both other units, passes another unit's function
 * as a designator across modules, reads the shared enumeration, and prints
 * the shared object's final value. */
#include <stdio.h>
#include "fixture.h"

static int helper(int x) { return x - 1; }

int main(void) {
    struct pair p = split(3);
    printf("lo=%d hi=%d\n", p.lo, p.hi);
    printf("applied=%d\n", apply(bump, 4));
    printf("mode=%d helper=%d\n", (int)MODE_B, helper(MODE_A));
    printf("shared=%d\n", shared_counter);
    return 0;
}
