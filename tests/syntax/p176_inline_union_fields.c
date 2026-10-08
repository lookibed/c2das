/* A union that is a field of a struct lies inline, as the unsigned integer
 * of its own size and alignment, and the struct stays a natural daslang
 * record: its other fields are reached by name (`p.x`), and the union's
 * members are read and written through their own types at the field's
 * address.  The union keeps its wrapper for every object named on its own.
 *
 * Doom's shape: a thinker whose `function` is a union of three function
 * pointers, embedded by value in a map object, linked through pointers,
 * called through the union and marked removed with `(actionf_v)(-1)`. */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef void (*actionf_v)();
typedef void (*actionf_p1)(void *);
typedef void (*actionf_p2)(void *, void *);

typedef union {
    actionf_v acv;
    actionf_p1 acp1;
    actionf_p2 acp2;
} actionf_t;

typedef struct thinker_s {
    struct thinker_s *prev;
    struct thinker_s *next;
    actionf_t function;
} thinker_t;

typedef struct mobj_s {
    thinker_t thinker;
    int x, y;
    int health;
    struct mobj_s *target;
} mobj_t;

/* int/float punning, and a member narrower than the word. */
union bits {
    float f;
    uint32_t u;
    uint8_t b;
};

struct sample {
    int id;
    union bits bits;
    int tail;
};

/* Members of different sizes: the union is its widest member's word. */
struct mixed {
    char tag;
    union {
        uint8_t b;
        uint16_t h;
        uint64_t q;
        double d;
    } w;
};

/* A three-byte union of alignment 1: a byte array. */
struct bytes3 {
    union {
        char c[3];
        uint8_t raw[3];
    } u;
    char end;
};

/* A packed record and a bitfield record embedded by value are inline
 * storage too (Doom's `mobj_t` holds a packed `mapthing_t spawnpoint`); the
 * embedding record stays natural. */
struct __attribute__((packed)) mapthing {
    short x, y, angle, type, options;
};

struct color {
    uint32_t b : 8, g : 8, r : 8, a : 8;
};

struct actor {
    int id;
    struct mapthing spawn;
    struct color tint;
    int after;
};

/* Aligned beyond eight bytes: no inline storage, the record stays
 * storage-backed. */
struct wide {
    union {
        uint64_t q __attribute__((aligned(16)));
        uint32_t w;
    } u;
    int after;
};

static thinker_t thinkercap;
static int ticks;

static void think_mobj(void *p) {
    mobj_t *mo = p;
    mo->x += 2;
    mo->y -= 1;
    ticks++;
}

static void think_pair(void *a, void *b) {
    mobj_t *mo = a;
    mobj_t *other = b;
    mo->health -= other->health / 2;
    ticks += 10;
}

static void add_thinker(thinker_t *t) {
    thinkercap.prev->next = t;
    t->next = &thinkercap;
    t->prev = thinkercap.prev;
    thinkercap.prev = t;
}

static void run_thinkers(mobj_t *other) {
    thinker_t *t = thinkercap.next;
    while (t != &thinkercap) {
        if (t->function.acv == (actionf_v)(-1)) {
            thinker_t *next = t->next;
            t->prev->next = t->next;
            t->next->prev = t->prev;
            free(t);
            t = next;
            continue;
        }
        if (t->function.acp1 == (actionf_p1)think_mobj)
            t->function.acp1(t);
        else if (t->function.acp2)
            t->function.acp2(t, other);
        t = t->next;
    }
}

static mobj_t *spawn(int x, int y, int health) {
    mobj_t *mo = calloc(1, sizeof(*mo));
    mo->x = x;
    mo->y = y;
    mo->health = health;
    mo->thinker.function.acp1 = think_mobj;
    add_thinker(&mo->thinker);
    return mo;
}

static uint32_t sample_bits(struct sample s) {
    return s.bits.u + (uint32_t)s.id;
}

static struct sample make_sample(int id, float f) {
    struct sample s = { id, { f }, id * 2 };
    return s;
}

static mobj_t pool[3];

int main(void) {
    thinkercap.prev = thinkercap.next = &thinkercap;
    thinkercap.function.acv = (actionf_v)0;

    mobj_t *a = spawn(10, 20, 100);
    mobj_t *b = spawn(-5, 7, 50);
    mobj_t *c = spawn(1, 1, 9);
    b->thinker.function.acp2 = think_pair;
    run_thinkers(a);
    printf("tick %d a=%d,%d b=%d,%d,%d c=%d,%d\n", ticks, a->x, a->y, b->x, b->y, b->health,
           c->x, c->y);
    c->thinker.function.acv = (actionf_v)(-1);
    run_thinkers(a);
    printf("tick %d a=%d,%d removed=%d\n", ticks, a->x, a->y,
           thinkercap.next->next->next == &thinkercap);

    /* An array of records with the union inline, copied as a whole, and
     * memcpy'd. */
    pool[0] = *a;
    pool[1].thinker.function.acp1 = think_mobj;
    pool[1].x = 3;
    memcpy(&pool[2], b, sizeof(mobj_t));
    printf("pool %d %d %d %d\n", pool[0].x, pool[1].thinker.function.acp1 == think_mobj,
           pool[2].thinker.function.acp2 == think_pair, pool[2].health);
    /* The address of the union member and of the union itself. */
    actionf_p1 *slot = &pool[1].thinker.function.acp1;
    *slot = (actionf_p1)0;
    actionf_t *fnp = &pool[1].thinker.function;
    printf("slot %d %d\n", pool[1].thinker.function.acv == 0, fnp->acp1 == 0);

    /* Punning through a local, a pointer, a value copy and a union value. */
    struct sample s = { 7, { 1.5f }, 0 };
    struct sample *sp = &s;
    printf("pun %08x %d %d\n", s.bits.u, s.bits.b, sp->tail);
    sp->bits.u = 0x40490fdbu;
    printf("pun %.4f %d\n", s.bits.f, sample_bits(s) == 0x40490fdbu + 7u);
    struct sample t = s;
    t.bits.b = 0xff;
    union bits v = { 2.0f };
    s.bits = v;
    printf("copy %08x %08x %08x\n", s.bits.u, t.bits.u, make_sample(3, 0.5f).bits.u);
    sp->bits = t.bits;
    v.u = (*sp).bits.u;
    struct sample made = make_sample(1, 1.0f);
    printf("back %08x %d\n", v.u, made.tail);

    /* Different sizes: the word is exact, a byte store keeps the rest. */
    struct mixed m = { 'm', { .q = 0x1122334455667788ull } };
    m.w.b = 0x99;
    struct mixed *mp = malloc(sizeof *mp);
    *mp = m;
    mp->w.h = 0xaaaa;
    printf("mixed %c %016llx %016llx %d\n", m.tag, (unsigned long long)m.w.q,
           (unsigned long long)mp->w.q, (int)sizeof(struct mixed));
    free(mp);

    struct bytes3 b3 = { { "ab" }, 'z' };
    b3.u.raw[2] = 'c';
    printf("bytes %c%c%c %c %d\n", b3.u.c[0], b3.u.c[1], b3.u.c[2], b3.end, (int)sizeof b3);

    struct wide w = { { 0 }, 4 };
    w.u.q = 12;
    printf("wide %d %d %d\n", (int)w.u.q, w.after, (int)sizeof w);

    struct actor ac = { 5, { 10, -20, 90, 3001, 7 }, { 1, 2, 3, 4 }, 6 };
    struct actor *ap = malloc(sizeof *ap);
    *ap = ac;
    ap->spawn.angle += 180;
    ap->tint.r = 200;
    ac.spawn.type = ap->spawn.type + 1;
    ac.tint.a = ac.tint.b + ap->tint.g;
    struct mapthing mt = ap->spawn;
    mt.options = 9;
    ac.spawn = mt;
    printf("actor %d %d %d %d %d %d %d | %d %d %d %d | %d %d %d\n", ap->id, ap->spawn.x, ap->spawn.y,
           ap->spawn.angle, ac.spawn.type, ac.spawn.options, ap->spawn.options, ac.tint.b, ac.tint.a,
           ap->tint.r, ap->tint.a, ap->after, (int)sizeof(struct actor),
           (int)offsetof(struct actor, tint));
    free(ap);
    free(a);
    free(b);
    return 0;
}
