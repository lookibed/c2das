/* Byte-model acceptance: bitfields on local, global and heap objects, signed
 * and unsigned, with copies. Returns 0 on success. */

#include <stdlib.h>

struct flags {
    unsigned a : 3;
    unsigned b : 5;
    int s : 4;
    unsigned c : 20;
    int wide : 12;
};

static int local_bitfields(void) {
    struct flags f;
    f.a = 5;
    f.b = 31;
    f.s = -1;
    f.c = 0xfffff;
    f.wide = -100;
    return f.a == 5 && f.b == 31 && f.s == -1 && f.c == 0xfffff && f.wide == -100 && sizeof f == 8;
}

static int rmw(void) {
    struct flags f = { 1, 2, 3, 4, 5 };
    f.a += 6; /* 7, fits */
    f.b <<= 2; /* 8 */
    f.s -= 5; /* -2 */
    f.c *= 1000; /* 4000 */
    f.wide = f.wide * -1;
    return f.a == 7 && f.b == 8 && f.s == -2 && f.c == 4000 && f.wide == -5;
}

static int wrap(void) {
    struct flags f = { 0 };
    f.a = 7;
    f.a++; /* wraps to 0 within 3 bits */
    f.s = 7;
    f.s++; /* 4-bit signed wraps to -8 */
    return f.a == 0 && f.s == -8;
}

static int through_pointer(struct flags *p) {
    p->b = 17;
    p->s = -3;
    return p->b == 17 && p->s == -3;
}

static int heap_bitfields(void) {
    struct flags *p = (struct flags *)calloc(1, sizeof *p);
    int ok = through_pointer(p) && p->a == 0 && p->c == 0;
    free(p);
    return ok;
}

static int copy_bitfields(void) {
    struct flags a = { 1, 2, -3, 4, -5 };
    struct flags b = a;
    b.s = 2;
    return a.s == -3 && b.s == 2 && b.wide == -5 && b.c == 4;
}

static struct flags g_flags = { 2, 3, -4, 5, 6 };

static int global_bitfields(void) {
    g_flags.wide = -6;
    return g_flags.a == 2 && g_flags.s == -4 && g_flags.wide == -6;
}

int bitfields_layout_runtime(void) {
    if (!local_bitfields()) return 1;
    if (!rmw()) return 2;
    if (!wrap()) return 3;
    if (!heap_bitfields()) return 4;
    if (!copy_bitfields()) return 5;
    if (!global_bitfields()) return 6;
    return 0;
}
