/* Byte-model acceptance: unions are overlapping raw storage with value
 * semantics on copy. Returns 0 on success. */

#include <stdint.h>

union pun {
    uint32_t u;
    float f;
    unsigned char b[4];
    struct {
        uint16_t lo;
        uint16_t hi;
    } halves;
};

struct tagged {
    int tag;
    union {
        int i;
        double d;
    };
    struct {
        short a;
        short b;
    } pair;
};

static int copy_independent(void) {
    union pun a;
    a.u = 0x11223344u;
    union pun b = a;
    b.b[0] = 0xff;
    return a.u == 0x11223344u && b.u == 0x112233ffu && b.halves.lo == 0x33ff && a.halves.hi == 0x1122;
}

static int punning(void) {
    union pun p;
    p.f = 1.0f;
    return p.u == 0x3f800000u && p.b[3] == 0x3f && sizeof p == 4;
}

static int union_in_struct(void) {
    struct tagged t;
    t.tag = 1;
    t.i = 77;
    t.pair.a = 5;
    t.pair.b = 6;
    struct tagged u = t;
    u.d = 2.5;
    u.pair.a = 50;
    return t.i == 77 && u.d == 2.5 && t.pair.a == 5 && u.pair.a == 50 && u.pair.b == 6 && u.tag == 1;
}

static int union_array(void) {
    union pun arr[3];
    arr[0].u = 1;
    arr[1].u = 2;
    arr[2] = arr[0];
    arr[2].b[0] = 9;
    return arr[0].u == 1 && arr[2].u == 9 && arr[1].u == 2;
}

static int union_through_pointer(union pun *p) {
    p->halves.hi = 0xabcd;
    return p->b[2] == 0xcd && p->b[3] == 0xab;
}

static int pointer_access(void) {
    union pun p;
    p.u = 0;
    return union_through_pointer(&p) && p.u == 0xabcd0000u;
}

static int anonymous_union_offsets(void) {
    struct tagged t;
    t.d = 0.0;
    t.i = 3;
    return (char *)&t.i - (char *)&t == 8 && (char *)&t.pair - (char *)&t == 16 && sizeof t == 24;
}

int union_semantics_runtime(void) {
    if (!copy_independent()) return 1;
    if (!punning()) return 2;
    if (!union_in_struct()) return 3;
    if (!union_array()) return 4;
    if (!pointer_access()) return 5;
    if (!anonymous_union_offsets()) return 6;
    return 0;
}
