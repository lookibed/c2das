/* A file-scope object another file-scope initializer reads.
 *
 * C zero-initialises every object of static storage duration before the
 * program starts (C11 6.7.9p10), so `static int *px = &x;` may name an `x`
 * declared without an initializer.  daslang counts a module-level `var`
 * without an initializer as never initialised, wherever it is declared, and
 * rejects the reader (`error[30173]: global variable x is initialized after
 * px`); the translation spells C's zero as `default<T>` for exactly those
 * objects.  (Doom's `intercepts_overrun[]` table of addresses of
 * `lowfloor`, `openrange`, `bulletslope`, ...; `joybuttons = &joyarray[1]`.) */
#include <stdio.h>

static int x;
static int arr[4];
static double d;
static int untouched;

static int *px = &x;
static int *pa = &arr[1];
static double *pd = &d;

struct overrun {
    int len;
    void *addr;
};

static struct overrun table[3] = {{4, &x}, {8, &d}, {0, 0}};

int main(void) {
    *px = 5;
    *pa = 6;
    *pd = 1.5;
    *(int *)table[0].addr += 1;
    printf("%d %d %.1f %d %d %d\n", x, arr[1], d, untouched, table[1].len, *(int *)table[0].addr);
    return 0;
}
