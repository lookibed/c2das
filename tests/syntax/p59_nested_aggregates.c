/* Byte-model acceptance: nested aggregates, arrays of arrays, char buffers,
 * heap-resident aggregates and byte views. Returns 0 on success. */

#include <stdlib.h>
#include <string.h>

struct inner {
    short id;
    int vals[2];
};

struct outer {
    char name[8];
    struct inner items[3];
    struct inner *ref;
};

static int build(struct outer *o) {
    o->name[0] = 'o';
    o->name[1] = 'k';
    o->name[2] = 0;
    int i = 0;
    while (i < 3) {
        o->items[i].id = (short)(i + 1);
        o->items[i].vals[0] = i * 10;
        o->items[i].vals[1] = i * 10 + 1;
        i++;
    }
    o->ref = &o->items[2];
    return o->ref->vals[1];
}

static int local_nested(void) {
    struct outer o;
    int last = build(&o);
    return last == 21 && o.items[1].id == 2 && o.name[1] == 'k' && o.ref == &o.items[2] && sizeof o == 56;
}

static int heap_nested(void) {
    struct outer *o = (struct outer *)malloc(sizeof *o);
    build(o);
    struct outer copy = *o;
    copy.items[0].vals[0] = 555;
    int ok = o->items[0].vals[0] == 0 && copy.items[0].vals[0] == 555 && copy.ref == &o->items[2];
    free(o);
    return ok;
}

static int matrix(void) {
    int m[3][4];
    int r = 0;
    while (r < 3) {
        int c = 0;
        while (c < 4) {
            m[r][c] = r * 4 + c;
            c++;
        }
        r++;
    }
    int *flat = &m[0][0];
    return m[2][3] == 11 && flat[7] == 7 && sizeof m == 48 && (&m[1][0] - &m[0][0]) == 4;
}

static int strcpy_loop(char *dst, const char *src) {
    int n = 0;
    while ((*dst++ = *src++)) n++;
    return n;
}

static int char_buffers(void) {
    char a[16] = "hello";
    char b[16];
    int n = strcpy_loop(b, a);
    b[0] = 'j';
    return n == 5 && a[0] == 'h' && b[0] == 'j' && b[4] == 'o' && b[5] == 0 && memcmp(a + 1, b + 1, 5) == 0;
}

static int struct_to_bytes(void) {
    struct inner in = { 0x0102, { 0x03040506, 0x0708090a } };
    unsigned char buf[sizeof in];
    memcpy(buf, &in, sizeof in);
    struct inner back;
    memcpy(&back, buf, sizeof back);
    return buf[0] == 0x02 && buf[4] == 0x06 && back.id == 0x0102 && back.vals[1] == 0x0708090a;
}

static int array_of_arrays_of_structs(void) {
    struct inner grid[2][2] = { { { 1, { 1, 1 } }, { 2, { 2, 2 } } }, { { 3, { 3, 3 } }, { 4, { 4, 4 } } } };
    struct inner *p = &grid[1][0];
    p[1].vals[0] = 40;
    return grid[1][1].vals[0] == 40 && grid[0][1].id == 2 && sizeof grid == 48;
}

int nested_aggregates_runtime(void) {
    if (!local_nested()) return 1;
    if (!heap_nested()) return 2;
    if (!matrix()) return 3;
    if (!char_buffers()) return 4;
    if (!struct_to_bytes()) return 5;
    if (!array_of_arrays_of_structs()) return 6;
    return 0;
}
