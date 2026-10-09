/* `--memory-model linear`: a scalar parameter whose address is taken is
 * spilled to the C stack on entry; reads and writes go through its slot. */
#include <stdio.h>

static void clamp(int *v, int *s) {
    if (*v > 100) *v = 100;
    if (*s < 0) *s = 0;
}

static int start(int vol, int sep, double gain) {
    clamp(&vol, &sep);
    double *g = &gain;
    *g *= 2;
    vol += 1;
    return vol * 1000 + sep + (int)gain;
}

static int depth(int n) {
    int *p = &n;
    if (*p == 0) return 0;
    return n + depth(n - 1);
}

int main(void) {
    printf("%d %d\n", start(150, -3, 1.5), start(7, 9, 0.25));
    printf("%d\n", depth(10));
    return 0;
}
