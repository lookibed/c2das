/* A pointer local a loop steps by compile-time constants and otherwise only
 * reads through (`*p`, `p[i]`, `p->f`) is mirrored in a `uint64` address for
 * that loop (`cfg/structured.rs`, "Pointer inductions"): `var c2da_p_addr =
 * reinterpret<uint64>(p)` before the loop, each read `reinterpret<T?>(
 * c2da_p_addr)`, each step `c2da_p_addr += C * sizeof(T)` (one fused
 * interpreter node where daslang's pointer `+=` is a call node), and `p =
 * reinterpret<T?>(c2da_p_addr)` after the loop when `p` is read again.
 *
 * Covered: a column loop with a stride (`dest += 320`); a span loop
 * (`*dest++ = v`); a pointer live after the loop (`while (*s) s++`); an
 * early `break` with the pointer read after; a negative stride (`p -= 2`,
 * `p--`); two pointers in one statement (`*d++ = *s++`); an `int` pointee
 * (the step scales by the element size); a field through the pointer
 * (`p->v`); a `for` step with a comma.  Fallbacks that keep today's form: a
 * pointer passed to a call in the loop, compared in the loop, stepped under
 * an `if`, stepped by a variable, assigned in the loop.  Nested loops: the
 * inner loop's own step is its induction (stored back for the outer body),
 * an outer pointer read in the inner body is mirrored across both. */
#include <stdio.h>
#include <stdint.h>

struct cell {
    int v;
    int pad;
};

static uint8_t screen[320 * 8];
static uint8_t src[16] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
static int ints[8] = {10, 20, 30, 40, 50, 60, 70, 80};
static struct cell cells[4] = {{1, 0}, {2, 0}, {3, 0}, {4, 0}};
static char text[] = "hello";

/* do { … } while (count--), stride 320 */
static void column(uint8_t *dest, int count, int x) {
    do {
        *dest = (uint8_t)(x + count);
        dest += 320;
    } while (count--);
}

/* *dest++ = v */
static void span(uint8_t *dest, int count) {
    do {
        *dest++ = (uint8_t)count;
    } while (count--);
}

/* live after the loop: the pointer is stored back */
static int strlen_like(const char *s) {
    const char *start = s;
    while (*s) {
        s++;
    }
    return (int)(s - start);
}

/* early break, pointer read after */
static int find_zero(uint8_t *p) {
    int steps = 0;
    for (;;) {
        if (*p == 0) {
            break;
        }
        p++;
        steps++;
    }
    return steps + (int)(p - screen);
}

/* negative strides */
static int backwards(int *p) {
    int acc = 0;
    int n = 3;
    while (n > 0) {
        acc += *p;
        p -= 2;
        n--;
    }
    p--;
    return acc + *p;
}

/* two pointers in one statement, an int pointee, a field */
static int copy_pairs(int *d, const int *s, int n) {
    int sum = 0;
    struct cell *c = cells;
    while (n-- > 0) {
        *d++ = *s++;
        sum += c->v;
        c++;
    }
    return sum + d[-1];
}

/* `*d++ = (uint8_t)(*s++)`: the cast walks the `s++` node twice; one step */
static int narrowed(uint8_t *d, const int *s, int n) {
    uint8_t *start = d;
    while (n-- > 0) {
        *d++ = (uint8_t)(*s++);
    }
    return (int)(d - start) + s[-1];
}

/* named only inside the inner loop, read again on the outer loop's next
 * pass (h264bsd's Intra16x16HorizontalPrediction): stored back */
static void rows(uint8_t *data, const uint8_t *left) {
    unsigned i, j;
    for (i = 0; i < 4; i++) {
        for (j = 0; j < 4; j++) {
            *data++ = left[i];
        }
    }
}

/* a for step with a comma */
static int comma_step(const uint8_t *p, int n) {
    int sum = 0;
    int i;
    for (i = 0; i < n; i++, p += 2) {
        sum += p[0] + p[1];
    }
    return sum;
}

static int consume(const uint8_t *p) {
    return *p;
}

/* fallback: the pointer is passed to a call */
static int passed(const uint8_t *p, int n) {
    int sum = 0;
    while (n-- > 0) {
        sum += consume(p);
        p++;
    }
    return sum;
}

/* fallback: the pointer is compared */
static int compared(const uint8_t *p, const uint8_t *end) {
    int sum = 0;
    while (p < end) {
        sum += *p++;
    }
    return sum;
}

/* fallback: stepped under an if */
static int conditional(const uint8_t *p, int n) {
    int sum = 0;
    while (n-- > 0) {
        sum += *p;
        if (sum & 1) {
            p++;
        }
    }
    return sum;
}

/* fallback: stepped by a variable, assigned in the loop */
static int variable_step(const uint8_t *p, int n, int stride) {
    int sum = 0;
    while (n-- > 0) {
        sum += *p;
        p += stride;
    }
    const uint8_t *q = p;
    while (n < 2) {
        sum += *q;
        q = p;
        n++;
    }
    return sum;
}

/* nested: the inner loop owns p, the outer owns q */
static int nested(uint8_t *p, const uint8_t *q, int h) {
    do {
        int n = 2;
        do {
            *p = (uint8_t)(*q + 1);
            p++;
        } while (--n);
        q++;
    } while (--h);
    return p[-1] + q[0];
}

int main(void) {
    int i;
    column(screen + 5, 7, 3);
    span(screen + 1, 4);
    printf("column %d %d %d span %d %d %d\n", screen[5], screen[5 + 320], screen[5 + 320 * 7],
           screen[1], screen[2], screen[5]);
    screen[9] = 0;
    printf("live %d break %d\n", strlen_like(text), find_zero(screen + 6));
    printf("backwards %d\n", backwards(ints + 7));
    {
        int dst[4] = {0, 0, 0, 0};
        int r = copy_pairs(dst, ints, 4);
        printf("pairs %d %d %d\n", r, dst[0], dst[3]);
    }
    {
        uint8_t narrow[4] = {0, 0, 0, 0};
        uint8_t grid[16] = {0};
        int r = narrowed(narrow, ints, 4);
        rows(grid, src + 4);
        printf("narrowed %d %d %d rows %d %d %d %d\n", r, narrow[0], narrow[3], grid[0], grid[5],
               grid[10], grid[15]);
    }
    printf("comma %d passed %d compared %d\n", comma_step(src, 3), passed(src, 4),
           compared(src, src + 5));
    printf("conditional %d variable %d\n", conditional(src, 4), variable_step(src, 4, 3));
    for (i = 0; i < 8; i++) {
        screen[i] = 0;
    }
    printf("nested %d %d %d %d\n", nested(screen, src, 3), screen[0], screen[3], screen[5]);
    return 0;
}
