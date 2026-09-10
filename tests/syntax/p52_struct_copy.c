/* Byte-model acceptance: aggregate copies are byte copies of the C object,
 * whatever the field types and wherever the object lives. Returns 0 on success. */

#include <string.h>

struct mixed {
    char c;
    short s;
    int i;
    char d;
    double x;
};

struct with_array {
    int n;
    short v[4];
};

struct __attribute__((packed)) packed {
    char tag;
    int value;
    short extra;
};

struct outer {
    struct mixed m;
    struct with_array a;
};

static int assign_local(void) {
    struct mixed a = { 'a', -5, 100, 'z', 2.5 };
    struct mixed b = a;
    b.s = 7;
    b.x = 0.5;
    return a.s == -5 && a.x == 2.5 && b.s == 7 && b.c == 'a' && b.d == 'z' && b.i == 100;
}

static int assign_array_field(void) {
    struct with_array a = { 3, { 1, 2, 3, 4 } };
    struct with_array b = a;
    b.v[2] = 30;
    return a.v[2] == 3 && b.v[2] == 30 && b.v[3] == 4 && b.n == 3;
}

static int copy_through_pointers(struct mixed *dst, const struct mixed *src) {
    *dst = *src;
    return dst->s == src->s && dst->x == src->x && dst->d == src->d;
}

static int pointer_copy(void) {
    struct mixed a = { 'q', 300, -1, 'k', -4.25 };
    struct mixed b;
    struct mixed guard = { 'g', 1, 2, 'g', 1.0 };
    if (!copy_through_pointers(&b, &a)) return 0;
    return b.c == 'q' && b.s == 300 && b.i == -1 && guard.s == 1 && guard.x == 1.0;
}

static int packed_copy(void) {
    struct packed a = { 'p', 0x11223344, -2 };
    struct packed b;
    b = a;
    struct packed c;
    memcpy(&c, &a, sizeof a);
    return sizeof(struct packed) == 7 && b.value == 0x11223344 && b.extra == -2 && c.tag == 'p' &&
           c.value == a.value && memcmp(&a, &c, sizeof a) == 0;
}

static int nested_copy(void) {
    struct outer o = { { 'n', 1, 2, 'm', 3.0 }, { 2, { 9, 8, 7, 6 } } };
    struct outer p = o;
    p.m.s = 11;
    p.a.v[0] = 99;
    return o.m.s == 1 && o.a.v[0] == 9 && p.m.s == 11 && p.a.v[0] == 99 && p.a.v[3] == 6;
}

static int array_of_structs(void) {
    struct mixed arr[3] = { { 'a', 1, 1, 'a', 1.0 }, { 'b', 2, 2, 'b', 2.0 }, { 'c', 3, 3, 'c', 3.0 } };
    arr[0] = arr[2];
    struct mixed *p = &arr[1];
    struct mixed tmp = *p;
    tmp.i = 42;
    return arr[0].c == 'c' && arr[0].x == 3.0 && arr[1].i == 2 && tmp.i == 42 && arr[2].s == 3;
}

static int memset_struct(void) {
    struct mixed a = { 'a', 1, 2, 'b', 3.0 };
    memset(&a, 0, sizeof a);
    return a.c == 0 && a.s == 0 && a.i == 0 && a.d == 0 && a.x == 0.0;
}

static int bytes_of_struct(void) {
    struct with_array a = { 0x01020304, { 0x0506, 0x0708, 0x090a, 0x0b0c } };
    unsigned char *p = (unsigned char *)&a;
    return p[0] == 0x04 && p[3] == 0x01 && p[4] == 0x06 && p[5] == 0x05 && sizeof a == 12;
}

int struct_copy_runtime(void) {
    if (!assign_local()) return 1;
    if (!assign_array_field()) return 2;
    if (!pointer_copy()) return 3;
    if (!packed_copy()) return 4;
    if (!nested_copy()) return 5;
    if (!array_of_structs()) return 6;
    if (!memset_struct()) return 7;
    if (!bytes_of_struct()) return 8;
    return 0;
}
