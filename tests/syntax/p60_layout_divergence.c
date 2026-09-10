/* Byte-model acceptance: the audit's silent layout-divergence cases. Fields
 * whose daScript value type differs from the C type (short, char, packed,
 * arrays) must still be read and written at Clang offsets through &local.
 * Returns 0 on success. */

#include <string.h>

struct shorts {
    char c;
    short s;
    int i;
    char d;
    double x;
};

struct __attribute__((packed)) tight {
    char a;
    int b;
    short c;
    long d;
};

struct with_arr {
    int before;
    unsigned char data[6];
    int after;
};

static void poke_shorts(struct shorts *p) {
    p->s = 300;
    p->i = 33;
    p->d = 'D';
    p->x = 44.0;
}

static int short_fields(void) {
    struct shorts v = { 'c', 1, 2, 'd', 3.0 };
    poke_shorts(&v);
    return v.c == 'c' && v.s == 300 && v.i == 33 && v.d == 'D' && v.x == 44.0 && sizeof v == 24;
}

static int packed_fields(void) {
    struct tight t = { 'a', 1, 2, 3 };
    struct tight *p = &t;
    p->b = 0x7fffffff;
    p->c = -2;
    p->d = -3;
    struct tight u;
    memcpy(&u, &t, sizeof t);
    return sizeof t == 15 && t.b == 0x7fffffff && t.c == -2 && t.d == -3 && u.a == 'a' && u.d == -3;
}

static int array_then_scalar(void) {
    struct with_arr w = { 1, { 1, 2, 3, 4, 5, 6 }, 2 };
    struct with_arr *q = &w;
    q->after = 9;
    q->data[5] = 66;
    q->before = 8;
    return w.after == 9 && w.data[5] == 66 && w.before == 8 && w.data[0] == 1 && sizeof w == 16;
}

static int byte_view_of_local(void) {
    struct shorts v = { 1, 2, 3, 4, 5.0 };
    unsigned char *b = (unsigned char *)&v;
    b[2] = 0x10; /* low byte of s */
    b[3] = 0x00;
    return v.s == 0x10 && b[0] == 1 && v.i == 3;
}

int layout_divergence_runtime(void) {
    if (!short_fields()) return 1;
    if (!packed_fields()) return 2;
    if (!array_then_scalar()) return 3;
    if (!byte_view_of_local()) return 4;
    return 0;
}
