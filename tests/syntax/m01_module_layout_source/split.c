/* Unit 2: reads and writes the shared object another unit owns, calls into
 * that unit, takes a function value from a caller, and has its own `static
 * helper`. */
#include "fixture.h"

static int helper(int x) { return x + 100; }

struct pair split(int v) {
    struct pair p;
    p.lo = helper(v) - shared_counter;
    p.hi = bump(v);
    return p;
}

int apply(int (*fn)(int), int v) { return fn(v); }
