/* `left.c`: a static `total`, a static helper `bump` and a file-local
 * `entry_t` that `right.c` declares differently. */
#include "cycle.h"

typedef struct {
    int value;
    int weight;
} entry_t;

static int total = 0;
static entry_t last = {0, 2};

static int bump(int v) { return v * last.weight; }

int shared_count = 0;
int left_only = 3;

int left_step(int v) {
    shared_count++;
    total += bump(v);
    last.value = v;
    return v > 0 ? right_step(v - 1) : total;
}

int left_total(void) { return total * 10 + last.value; }
