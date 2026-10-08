/* `right.c`: its own static `total`, static `bump` and a different
 * file-local `entry_t`, plus a static `left_only` named like an external
 * object `left.c` defines (and this unit never references). */
#include "cycle.h"

static int left_only = 9;

typedef struct {
    long long value;
} entry_t;

static int total = 100;
static entry_t last = {7};
static int left_total_seen = 0;

static int bump(int v) { return v + 3; }

int right_step(int v) {
    shared_count++;
    total -= bump(v) + left_only;
    last.value += v;
    left_total_seen = left_total();
    return v > 0 ? left_step(v - 1) : total;
}

int right_total(void) { return total + (int)last.value + left_total_seen; }
