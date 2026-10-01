/* Field accesses that stay on Clang's byte offsets although a pointer to a
 * record reaches them: a union, a record containing a union, a bitfield
 * record, a packed and an over-aligned record, a flexible array member (all
 * storage-backed), and, in a record whose layout is proven, the address of a
 * field and an element of a fixed-array field.  Each line reads back what
 * the other spelling wrote, so a wrong offset prints a different value. */
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

union Word {
    unsigned int u;
    unsigned char b[4];
};

struct HasUnion {
    int tag;
    union Word w;
};

struct Bits {
    unsigned lo : 3;
    unsigned hi : 5;
    int whole;
};

struct __attribute__((packed)) Packed {
    char c;
    int i;
};

struct Aligned {
    char c;
    _Alignas(16) int i;
};

struct Flex {
    int n;
    int items[];
};

/* A proven record: its scalar fields go by name, the array field's elements
 * and the address of a field by offset. */
struct Buf {
    int len;
    unsigned char data[8];
    int tail;
};

static unsigned word_of(union Word *w) { return w->u; }
static int tag_and_byte(struct HasUnion *h) { return h->tag + h->w.b[0]; }
static unsigned bits_of(struct Bits *b) { return b->lo + 10 * b->hi + 100 * (unsigned)b->whole; }
static int packed_of(struct Packed *p) { return p->c + p->i; }
static int aligned_of(struct Aligned *a) { return a->c + a->i; }
static int flex_sum(struct Flex *f) {
    int s = 0;
    for (int k = 0; k < f->n; k++) s += f->items[k];
    return s;
}
static void put(int *slot, int v) { *slot = v; }
static int buf_sum(struct Buf *b) {
    put(&b->tail, 9);
    int s = b->len + b->tail;
    for (int k = 0; k < 8; k++) {
        b->data[k] = (unsigned char)(k + 1);
        s += b->data[k];
    }
    return s;
}

int main(void) {
    union Word w;
    w.u = 0x01020304u;
    struct HasUnion h;
    h.tag = 10;
    h.w.u = 0x05u;
    struct Bits bits;
    bits.lo = 5;
    bits.hi = 17;
    bits.whole = 3;
    struct Packed p;
    p.c = 1;
    p.i = 20;
    struct Aligned a;
    a.c = 2;
    a.i = 30;
    struct Flex *f = malloc(sizeof(struct Flex) + 3 * sizeof(int));
    f->n = 3;
    f->items[0] = 4;
    f->items[1] = 5;
    f->items[2] = 6;
    struct Buf b;
    b.len = 100;
    printf("word=%x tag+byte=%d bits=%u packed=%d aligned=%d flex=%d buf=%d\n", word_of(&w),
           tag_and_byte(&h), bits_of(&bits), packed_of(&p), aligned_of(&a), flex_sum(f),
           buf_sum(&b));
    printf("data[7]=%d tail=%d offsets %zu %zu %zu\n", b.data[7], b.tail, offsetof(struct Packed, i),
           offsetof(struct Aligned, i), offsetof(struct Buf, tail));
    free(f);
    return 0;
}
