/* `--memory-model linear`: a scalar parameter whose address is taken is
 * spilled to the C stack on entry; reads and writes go through its slot. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>

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

/* String-to-number and case-insensitive library calls over the heap. */
static int to_int(const char *str, int *result) {
    return sscanf(str, " 0x%x", result) == 1 || sscanf(str, " 0%o", result) == 1 || sscanf(str, " %d", result) == 1;
}

int main(void) {
    printf("%d %d\n", start(150, -3, 1.5), start(7, 9, 0.25));
    printf("%d\n", depth(10));
    int a = 0, b = 0, c = 0;
    int ok = to_int("0x1F", &a) + to_int(" 017", &b) + to_int("-42", &c);
    printf("%d %d %d %d\n", ok, a, b, c);
    char *d = strdup("Hello");
    printf("%d %d %d %s\n", atoi("  -123x"), strcasecmp(d, "HELLO"), strncasecmp("abcX", "ABCy", 3), d);
    free(d);
    printf("%d\n", (int)(atof(" 2.75") * 100));
    return 0;
}
