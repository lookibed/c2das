/* The entry unit: outside the cycle, it `require`s the cluster module. */
#include <stdio.h>
#include "cycle.h"

extern int left_only;

static int total = 5;

int main(void) {
    int end = left_step(6);
    printf("end=%d left=%d right=%d count=%d own=%d left_only=%d\n", end, left_total(),
           right_total(), shared_count, total, left_only);
    return 0;
}
