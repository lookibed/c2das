/* Records with zero-sized fields.  A GNU empty struct and a zero-length array
 * take no bytes in Clang's layout, while daslang gives every record field at
 * least one byte, so a daslang struct with the same fields would put every
 * later field (and the size) somewhere else.  `layout.rs` makes such a record
 * storage-backed: its bytes are Clang's and every access, by name or through
 * a pointer, uses Clang's offsets.  Each line below reads a field written
 * through the other path (by name vs through a pointer or raw ints), so a
 * daslang layout that disagrees with Clang's prints a different value. */
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

struct Empty {};

struct WithEmpty {
    int a;
    struct Empty e;
    int b;
};

struct TrailingEmpty {
    int a;
    struct Empty e;
};

struct EmptyArray {
    short s;
    struct Empty es[4];
    short t;
};

struct MidZero {
    int a;
    int z[0];
    int b;
};

struct Tail {
    int n;
    int d[0];
};

/* The typedef-of-anonymous-struct path decides the record the same way. */
typedef struct {
    char c;
    struct Empty e;
    char d;
} AnonWithEmpty;

struct Outer {
    struct WithEmpty inner;
    int after;
};

static int read_b(struct WithEmpty *p) { return p->b; }

static void write_b(struct WithEmpty *p, int v) { p->b = v; }

static struct WithEmpty make(int a, int b) {
    struct WithEmpty w = {a, {}, b};
    return w;
}

static int sum_tail(const struct Tail *t) {
    int s = 0;
    for (int i = 0; i < t->n; i++) s += t->d[i];
    return s;
}

int main(void) {
    printf("sizes %d %d %d %d %d %d %d %d\n", (int)sizeof(struct Empty),
           (int)sizeof(struct WithEmpty), (int)sizeof(struct TrailingEmpty),
           (int)sizeof(struct EmptyArray), (int)sizeof(struct MidZero),
           (int)sizeof(struct Tail), (int)sizeof(AnonWithEmpty), (int)sizeof(struct Outer));
    printf("offsets %d %d %d %d %d\n", (int)offsetof(struct WithEmpty, b),
           (int)offsetof(struct EmptyArray, t), (int)offsetof(struct MidZero, b),
           (int)offsetof(AnonWithEmpty, d), (int)offsetof(struct Outer, after));

    /* A local stored by name, read through a pointer at Clang's offset. */
    struct WithEmpty w;
    w.a = 1;
    w.b = 42;
    printf("local b=%d\n", read_b(&w));

    /* A store through the pointer, read back by name. */
    write_b(&w, 7);
    printf("stored b=%d a=%d\n", w.b, w.a);

    /* The bytes after `a` are `b`. */
    int *raw = (int *)&w;
    printf("raw[1]=%d\n", raw[1]);

    /* Initializer, by-value return and whole-record copy. */
    struct WithEmpty m = make(3, 4);
    struct WithEmpty copy = m;
    copy.b += 10;
    printf("make a=%d b=%d copy b=%d\n", m.a, m.b, copy.b);

    /* Heap objects filled through raw ints, read by element and field. */
    struct WithEmpty *h = calloc(2, sizeof(struct WithEmpty));
    int *hr = (int *)h;
    hr[1] = 11;
    hr[3] = 22;
    printf("heap %d %d\n", h[0].b, h[1].b);
    free(h);

    /* An empty member copied in and out changes no neighbour. */
    struct Empty e0;
    w.e = e0;
    e0 = w.e;
    printf("after empty copy a=%d b=%d\n", w.a, w.b);

    struct EmptyArray ea;
    ea.s = 5;
    ea.t = 6;
    struct EmptyArray *pea = &ea;
    printf("empty array s=%d t=%d\n", pea->s, pea->t);

    /* A zero-length array in the middle aliases the next field. */
    struct MidZero mz;
    mz.a = 8;
    mz.b = 9;
    struct MidZero *pmz = &mz;
    printf("mid zero b=%d via z=%d\n", pmz->b, pmz->z[0]);

    /* The pre-C99 flexible-array idiom. */
    struct Tail *t = malloc(sizeof(struct Tail) + 3 * sizeof(int));
    t->n = 3;
    for (int i = 0; i < 3; i++) t->d[i] = (i + 1) * 100;
    printf("tail sum=%d\n", sum_tail(t));
    free(t);

    AnonWithEmpty an;
    an.c = 'x';
    an.d = 'y';
    AnonWithEmpty *pan = &an;
    printf("anon %c%c\n", pan->c, pan->d);

    /* A record containing such a record. */
    struct Outer o;
    o.inner.a = 1;
    o.inner.b = 2;
    o.after = 3;
    struct Outer *po = &o;
    printf("outer %d %d\n", read_b(&po->inner), po->after);
    return 0;
}
