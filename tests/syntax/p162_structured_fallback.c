/* Function bodies the structured back end does not take stay on the flat
 * `label`/`goto` back end (`cfg/structured.rs fallback_reason`), decided per
 * function on the C AST: a `goto` (forward, backward, or into a loop, which
 * makes the graph irreducible), a `case` label below the top level of its
 * `switch` (Duff's device), and statements before the first `case`.  The
 * structured function next to them is unaffected. */
#include <stdio.h>

static int forward_goto(int x) {
    if (x < 0)
        goto fail;
    x *= 2;
    return x;
fail:
    return -1;
}

static int backward_goto(int n) {
    int total = 0;
again:
    total += n;
    if (--n > 0)
        goto again;
    return total;
}

/* Two entries into one loop: `goto` into its middle. */
static int irreducible(int start) {
    int i = 0, total = 0;
    if (start)
        goto middle;
    while (i < 5) {
        total += 10;
    middle:
        total += i;
        i++;
    }
    return total;
}

static void duff(char *to, const char *from, int count) {
    int n = (count + 3) / 4;
    switch (count % 4) {
    case 0: do { *to++ = *from++;
    case 3:      *to++ = *from++;
    case 2:      *to++ = *from++;
    case 1:      *to++ = *from++;
            } while (--n > 0);
    }
}

static int before_first_case(int x) {
    int r = 5;
    switch (x) {
        r = 99; /* never runs */
    case 1:
        r += 1;
        break;
    default:
        r += 2;
    }
    return r;
}

static int structured(int n) {
    int total = 0;
    for (int i = 0; i < n; i++)
        total += i;
    return total;
}

int main(void) {
    char buffer[16] = {0};
    duff(buffer, "abcdefghijk", 11);
    printf("%d %d %d %d %d %d\n", forward_goto(4), forward_goto(-4), backward_goto(4),
           irreducible(0), irreducible(1), structured(5));
    printf("%s %d %d\n", buffer, before_first_case(1), before_first_case(2));    return 0;
}
