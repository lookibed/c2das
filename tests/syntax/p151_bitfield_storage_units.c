/* Bitfields are loaded and stored through the storage unit the System V ABI
 * allocates them in: an object of the field's declared type, aligned to its
 * size, read with one aligned typed load.  A field of a packed record that
 * straddles such a unit keeps the byte-addressed path.
 *
 * The units differ from the byte holding the field's first bit: `color.r`
 * starts in byte 2 of a four-byte record, and a four-byte load from byte 2
 * reaches two bytes past the record (past the last element of `palette`).
 * Every store is a read-modify-write of the unit that keeps its neighbours:
 * `tagged.v` shares its unit with the ordinary field `tag`. */
#include <stdio.h>

struct color {
    unsigned int b : 8;
    unsigned int g : 8;
    unsigned int r : 8;
    unsigned int a : 8;
};

struct signed_bits {
    int lo : 5;
    int mid : 11;
    int hi : 16;
};

struct wide {
    unsigned long long x : 40;
    unsigned long long y : 24;
};

struct tagged {
    char tag;
    int v : 8;
    int w : 12;
};

struct __attribute__((packed)) tight {
    char c;
    unsigned int v : 20;
    unsigned int w : 12;
};

union either {
    unsigned int raw;
    struct {
        unsigned int low : 12;
        unsigned int high : 20;
    } parts;
};

static struct color palette[4];
static struct tight tights[2];

int main(void) {
    struct color *last = &palette[3];
    struct signed_bits s;
    struct wide w;
    struct tagged t;
    union either e;
    unsigned int hash = 2166136261u;
    int i;

    for (i = 0; i < 4; i += 1) {
        palette[i].b = (unsigned)(10 * i + 1);
        palette[i].g = (unsigned)(10 * i + 2);
        palette[i].r = (unsigned)(10 * i + 3);
        palette[i].a = 255u;
    }
    last->r += 200;
    last->g++;
    ++last->b;
    for (i = 0; i < 4; i += 1) {
        struct color c = palette[i];
        unsigned int rgb = ((unsigned int)c.r << 16) | ((unsigned int)c.g << 8) | (unsigned int)c.b;
        hash = (hash ^ rgb) * 16777619u;
    }
    printf("palette %u last %u %u %u %u\n", hash, last->r, last->g, last->b, last->a);

    s.lo = -3;
    s.mid = -1000;
    s.hi = 30000;
    s.mid += 1;
    printf("signed %d %d %d\n", s.lo, s.mid, s.hi);

    w.x = 0xffffffffffULL;
    w.y = 0x123456u;
    w.x += 2;
    printf("wide %llx %llx\n", (unsigned long long)w.x, (unsigned long long)w.y);

    t.tag = 'T';
    t.v = -100;
    t.w = 2047;
    t.v -= 20;
    printf("tagged %c %d %d\n", t.tag, t.v, t.w);

    tights[0].c = 'p';
    tights[0].v = 0xabcde;
    tights[0].w = 0xfed;
    tights[1].c = 'q';
    tights[0].w -= 1;
    printf("tight %c %x %x next %c size %u\n", tights[0].c, tights[0].v, tights[0].w, tights[1].c,
           (unsigned)sizeof(struct tight));

    e.raw = 0;
    e.parts.low = 0xabc;
    e.parts.high = 0x12345;
    printf("union %08x\n", e.raw);
    return 0;
}
