/* Copies of whole C objects the translation moves as bytes.
 *
 * A storage-backed record (here a union and a packed struct) has no daScript
 * value: reading it out of memory, assigning it and initializing one copy
 * its bytes, and so does a misaligned scalar field (moved through a typed
 * temporary) and a natural struct stored inside raw storage.  Each copy is
 * daslang's builtin `memcpy`, or `memmove` where C lets the two objects
 * overlap exactly (an assignment `*p = *q` with `p == q`, C11 6.5.16.1p3),
 * never a `c2da_rt_memcpy` byte loop.  The checks below read every copied
 * byte back. */
#include <stdio.h>
#include <string.h>

union word {
    unsigned int u;
    float f;
    unsigned char bytes[4];
};

struct point {
    int x;
    int y;
};

union holder {
    struct point pt;
    long long raw;
};

struct __attribute__((packed)) packed {
    char tag;
    int value;
    short half;
};

static union word words[4];
static struct packed packs[3];

static unsigned sum_bytes(const unsigned char *p, int n) {
    unsigned s = 0;
    int i;
    for (i = 0; i < n; i += 1) {
        s = s * 31u + p[i];
    }
    return s;
}

int main(void) {
    union word *p = &words[0];
    union word *q = &words[2];
    union word local;
    union holder h;
    struct point pt;
    struct packed *pk = &packs[1];
    int i;

    for (i = 0; i < 4; i += 1) {
        words[i].u = 0x01020304u * (unsigned)(i + 1);
    }
    /* Assignment between two objects, and of an object to itself. */
    *p = *q;
    *q = *q;
    words[1] = words[1];
    /* Initialization of a local from an object behind a pointer. */
    local = words[3];
    printf("words %08x %08x %08x %08x local %08x\n", words[0].u, words[1].u, words[2].u,
           words[3].u, local.u);
    /* Assignment from a local into an element, and element to element. */
    local.u = 0xa0b0c0d0u;
    words[3] = local;
    words[1] = words[3];
    printf("after %08x %08x bytes %u\n", words[1].u, words[3].u,
           sum_bytes((const unsigned char *)words, (int)sizeof words));

    /* A natural struct read out of and written into union storage. */
    h.pt.x = 11;
    h.pt.y = -7;
    pt = h.pt;
    pt.x += 100;
    h.pt = pt;
    printf("point %d %d raw %lld\n", h.pt.x, h.pt.y, h.raw == ((long long)-7 << 32 | 111) ? 1LL : 0LL);

    /* Misaligned scalar fields of a packed record, read and written. */
    pk->tag = 'k';
    pk->value = 0x12345678;
    pk->half = -2;
    pk->value += 5;
    packs[2] = *pk;
    packs[2].half *= 3;
    printf("packed %c %08x %d copy %c %08x %d size %u\n", pk->tag, (unsigned)pk->value, pk->half,
           packs[2].tag, (unsigned)packs[2].value, packs[2].half, (unsigned)sizeof(struct packed));
    printf("packed bytes %u\n", sum_bytes((const unsigned char *)packs, (int)sizeof packs));
    return 0;
}
