/* `x++` / `x--` whose value is discarded — an expression statement, a `for`
 * step, either operand of a statement-level comma — is `++x` / `--x`: the
 * old value is never read, so no copy of it is made.  A postfix operator
 * whose value is used (`a[i++]`, `y = i--`, `while (n--)`, `*p++ = v`, the
 * operand of a dereference statement) still yields the old value. */
#include <stdio.h>

struct counter {
    int n;
    unsigned int bits : 5;
};

union cell {
    int i;
    float f;
};

enum phase { PHASE_A, PHASE_B, PHASE_C };

static union cell cells[3] = {{1}, {2}, {3}};

int main(void) {
    int a[6] = {0, 0, 0, 0, 0, 0};
    int i = 0;
    int j = 10;
    int y;
    int n = 3;
    int total = 0;
    unsigned char small = 254;
    double d = 0.5;
    int *p = a;
    int *q;
    union cell *cp = cells;
    struct counter c = {0, 30};
    struct counter *pc = &c;
    enum phase ph = PHASE_A;

    for (i = 0; i < 3; i++) {
        total += i;
    }
    for (i = 0, j = 10; i < j; i++, j--) {
        total += 1;
    }
    i++;
    (j--);
    small++;
    small++;
    d++;
    p++;
    cp++;
    c.n++;
    pc->n++;
    c.bits++;
    c.bits++;
    ph++;
    printf("total %d i %d j %d small %u d %.1f p %d cp %d n %d bits %u phase %d\n", total, i, j,
           small, d, (int)(p - a), cp->i, c.n, c.bits, (int)ph);

    i = 0;
    a[i++] = 7;
    a[i++] = 8;
    y = i--;
    q = a;
    *q++ = 5;
    *q++;
    while (n--) {
        total += 100;
    }
    printf("a %d %d %d i %d y %d q %d n %d total %d\n", a[0], a[1], a[2], i, y, (int)(q - a), n,
           total);
    return 0;
}
