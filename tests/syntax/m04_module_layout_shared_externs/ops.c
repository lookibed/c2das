/* `ops.c`: an initializer holding the address of an element of another
 * unit's array, and a walk over another unit's table through a pointer. */
#include "shared.h"

int *cursor = &values[1];

int twice(int v) { return v * 2; }

int plus_one(int v) { return v + 1; }

int negate(int v) { return -v; }

int run_states(int v) {
    const state_t *s = &states[0];
    for (;;) {
        v = s->step(v);
        if (s->next < 0) {
            return v;
        }
        s = &states[s->next];
    }
}
