/* A struct whose bitfields group into the storage units Clang allocates
 * them in is a natural daslang record: one unsigned integer per unit
 * (`c2da_bits_<n>`), the ordinary fields as themselves, and the layout proof
 * asserts each unit's offset.  A bitfield read is a shift and a mask on the
 * unit, a write a read-modify-write of it, directly on the object (`s.f`)
 * or by name through a pointer (`p->f`); a copy of the struct is a value
 * copy, with no storage allocated and no bytes moved.
 *
 * Doom's shape: `struct color { b:8; g:8; r:8; a:8 }` read by value out of
 * a palette for every pixel.  A record whose bitfields do not group exactly
 * — a field straddling its unit, a packed record — keeps the storage-backed
 * form. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct color {
    uint32_t b : 8;
    uint32_t g : 8;
    uint32_t r : 8;
    uint32_t a : 8;
};

/* Signed fields, 1-bit flags, a field as wide as its unit, two units, and
 * ordinary fields between them. */
struct packet {
    int kind;
    int delta : 6;
    unsigned int flag : 1;
    unsigned int ready : 1;
    int level : 24;
    uint16_t whole : 16;
    uint8_t lo : 4;
    uint8_t hi : 4;
    short tail;
};

/* A natural bitfield record embedded in another natural record. */
struct pixel {
    int x;
    struct color c;
    int y;
};

/* A packed record: `w` straddles the four-byte unit (bits 28..40 of a
 * record 5 bytes long) and `v`'s unit would overlap `c`; storage-backed. */
struct __attribute__((packed)) tight {
    char c;
    unsigned int v : 20;
    unsigned int w : 12;
};

/* Units of different sizes at the same bytes overlap: storage-backed. */
struct mixed_units {
    uint8_t a : 4;
    uint32_t b : 4;
};

/* An ordinary field sharing a unit's bytes: storage-backed. */
struct tagged {
    char tag;
    int v : 8;
    int w : 12;
};

static struct color palette[4] = {
    {1, 2, 3, 255},
    {0, 0, 0, 0},
    {.r = 200, .a = 1},
    {7, 7, 7},
};

static const uint8_t screen[8] = {0, 2, 3, 1, 2, 2, 3, 0};

static uint32_t hash_frame(void)
{
    uint32_t hash = 2166136261u;
    int i;
    for (i = 0; i < 8; i++) {
        struct color c = palette[screen[i]];
        uint32_t rgb = ((uint32_t)c.r << 16) | ((uint32_t)c.g << 8) | (uint32_t)c.b;
        hash = (hash ^ rgb) * 16777619u;
    }
    return hash;
}

static void set_color(struct color *p, unsigned r, unsigned g, unsigned b)
{
    p->r = r;
    p->g = g;
    p->b = b;
    p->a += 1;
}

static int sum_packet(const struct packet *p)
{
    return p->kind + p->delta + (int)p->flag + (int)p->ready + p->level + p->whole + p->lo +
           p->hi + p->tail;
}

int main(void)
{
    struct color c = {10, 20, 30, 40};
    struct color d;
    struct color *heap;
    struct packet pk = {1, -5, 1, 0, -70000, 65535, 9, 12, -3};
    struct packet pks[2];
    struct pixel px = {4, {1, 2, 3, 4}, 5};
    struct tight t;
    struct mixed_units mu;
    struct tagged tg;
    uint8_t bytes[4];
    uint32_t word;
    int i;

    /* By value in a loop, as Doom hashes a frame. */
    printf("hash %u\n", hash_frame());

    /* Direct reads and writes, a copy, a compound assignment, increments. */
    d = c;
    d.r = 99;
    d.a -= 1;
    d.g++;
    ++d.b;
    printf("color %u %u %u %u | %u %u %u %u\n", c.b, c.g, c.r, c.a, d.b, d.g, d.r, d.a);

    /* Through a pointer, a malloc'd one, and an array element. */
    set_color(&c, 1, 2, 3);
    heap = malloc(sizeof(struct color));
    memset(heap, 0, sizeof *heap);
    set_color(heap, 7, 8, 9);
    heap->a = 255;
    palette[1].b = 100;
    palette[1].a++;
    for (i = 0; i < 4; i++) {
        palette[i].g += (unsigned)i;
    }
    printf("ptr %u %u %u %u | heap %u %u %u %u | pal %u %u %u %u\n", c.b, c.g, c.r, c.a, heap->b,
           heap->g, heap->r, heap->a, palette[1].b, palette[1].g, palette[1].r, palette[1].a);
    free(heap);

    /* The bytes are Clang's: memcpy, a uint8 view, a word view. */
    memcpy(bytes, &c, sizeof c);
    word = *(uint32_t *)&c;
    printf("bytes %u %u %u %u word %08x size %u\n", bytes[0], bytes[1], bytes[2], bytes[3], word,
           (unsigned)sizeof(struct color));
    ((uint8_t *)&c)[2] = 0xaa;
    printf("alias %u\n", c.r);

    /* Signed fields, flags, whole-unit and two-unit records. */
    printf("packet %d %d %u %u %d %u %u %u %d sum %d\n", pk.kind, pk.delta, pk.flag, pk.ready,
           pk.level, pk.whole, pk.lo, pk.hi, pk.tail, sum_packet(&pk));
    pk.delta = 31;
    pk.delta += 1;
    pk.level = 8388607;
    pk.level++;
    pk.flag = !pk.flag;
    pk.whole = 0;
    pk.whole -= 1;
    pk.lo = 15;
    pk.hi = pk.lo - 1;
    printf("packet %d %u %d %u %u %u size %u\n", pk.delta, pk.flag, pk.level, pk.whole, pk.lo,
           pk.hi, (unsigned)sizeof(struct packet));
    memset(pks, 0, sizeof pks);
    pks[1] = pk;
    pks[1].delta = -1;
    pks[0].ready = 1;
    printf("array %d %u %d | %d %u\n", pks[1].delta, pks[1].flag, pks[1].level, pks[0].delta,
           pks[0].ready);

    /* Embedded in another natural record. */
    px.c.r = 77;
    px.c.a += 2;
    printf("pixel %d %u %u %u %u %d size %u\n", px.x, px.c.b, px.c.g, px.c.r, px.c.a, px.y,
           (unsigned)sizeof(struct pixel));

    /* The storage-backed fallbacks keep their bytes and their values. */
    t.c = 'p';
    t.v = 0xabcde;
    t.w = 0xfed;
    t.w -= 1;
    mu.a = 5;
    mu.b = 9;
    tg.tag = 'T';
    tg.v = -100;
    tg.w = 2047;
    tg.v -= 20;
    printf("fallback %c %x %x %u | %u %u %u | %c %d %d %u\n", t.c, t.v, t.w,
           (unsigned)sizeof(struct tight), mu.a, mu.b, (unsigned)sizeof(struct mixed_units),
           tg.tag, tg.v, tg.w, (unsigned)sizeof(struct tagged));
    return 0;
}
