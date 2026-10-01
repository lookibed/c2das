/* A C `_Bool` in a condition, and an integer constant where a `_Bool` or a
 * condition is wanted.
 *
 * `b && x`, `b || x`, `!b` and `if (b)` test the `_Bool` itself: C converts it
 * to `int` (0 or 1, C11 6.3.1.2) only to compare that against zero, so the
 * translation uses the daslang `bool` directly instead of `(b == true ? 1 : 0)
 * != 0`.  `return 0` / `return 1` from a function returning `_Bool`, and a
 * constant loop condition, are the `bool` constants `false` / `true`.  The
 * explicit casts `(int)b` and `(unsigned char)256` keep C's value. */
#include <stdbool.h>
#include <stdio.h>

static bool is_even(int x) {
    if (x % 2) {
        return 0;
    }
    return 1;
}

static bool never(void) { return false; }

static int count_true(const bool *flags, int n) {
    int count = 0;
    for (int i = 0; i < n; i++) {
        if (flags[i] && i >= 0) {
            count++;
        }
        if (!flags[i] || i < 0) {
            count += 10;
        }
    }
    return count;
}

struct opts {
    bool verbose;
    bool strict;
    int level;
};

int main(void) {
    bool a = true, b = false;
    struct opts o = {true, false, 3};
    int r = 0;
    if (a && o.level > 2) r += 1;
    if (b || o.verbose) r += 2;
    if (o.strict || b) r += 100;
    if (!(a && b)) r += 4;
    r += (a && !b) ? 8 : 0;
    r += (int)a + (int)b;
    printf("r=%d even=%d,%d never=%d\n", r, is_even(4), is_even(7), never());

    bool flags[5] = {true, false, true, true, false};
    printf("count=%d\n", count_true(flags, 5));

    int loops = 0;
    while (1) {
        if (++loops == 3) break;
    }
    if ((unsigned char)256) loops += 100;
    if ((int)a) loops += 10;
    printf("loops=%d\n", loops);
    return 0;
}
