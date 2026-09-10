/* Byte-model acceptance: global and static aggregates have C layout, static
 * storage, initialisers and addresses. Returns 0 on success. */

#include <stddef.h>

struct rec {
    char tag;
    short count;
    int values[3];
    double weight;
};

union word {
    unsigned u;
    unsigned char bytes[4];
};

struct rec g_rec = { 'g', 2, { 10, 20, 30 }, 1.5 };
struct rec g_zero;
struct rec g_table[3] = { { 'a', 1, { 1 }, 0.5 }, { 'b', 2, { 2, 2 }, 1.0 } };
union word g_word = { 0x01020304u };
static int g_ints[5] = { 1, 2, 3 };
struct rec *g_ptr = &g_table[1];

static int initialised_global(void) {
    return g_rec.tag == 'g' && g_rec.count == 2 && g_rec.values[2] == 30 && g_rec.weight == 1.5;
}

static int zero_global(void) {
    return g_zero.tag == 0 && g_zero.count == 0 && g_zero.values[1] == 0 && g_zero.weight == 0.0;
}

static int table(void) {
    return g_table[0].values[0] == 1 && g_table[0].values[2] == 0 && g_table[1].values[1] == 2 &&
           g_table[2].tag == 0 && g_ptr->tag == 'b' && g_ptr == &g_table[1];
}

static int union_global(void) {
    return g_word.bytes[0] == 4 && g_word.bytes[3] == 1;
}

static int mutate_global(void) {
    g_rec.values[0] += 5;
    struct rec *p = &g_rec;
    p->count = 9;
    struct rec copy = g_rec;
    copy.tag = 'x';
    return g_rec.values[0] == 15 && g_rec.count == 9 && g_rec.tag == 'g' && copy.tag == 'x';
}

static int layout(void) {
    return sizeof(struct rec) == 24 && offsetof(struct rec, count) == 2 && offsetof(struct rec, values) == 4 &&
           offsetof(struct rec, weight) == 16 && sizeof g_table == 72 && sizeof g_ints == 20;
}

static int static_aggregate(void) {
    static struct rec s = { 's', 1, { 7 }, 0.25 };
    static int hits[2];
    s.count++;
    hits[1]++;
    return s.count * 10 + hits[1];
}

static int statics_persist(void) {
    static_aggregate();
    return static_aggregate() == 32;
}

static int global_int_array(void) {
    int *p = g_ints + 1;
    p[2] = 44;
    return g_ints[3] == 44 && g_ints[4] == 0 && g_ints[0] == 1;
}

int globals_aggregate_runtime(void) {
    if (!initialised_global()) return 1;
    if (!zero_global()) return 2;
    if (!table()) return 3;
    if (!union_global()) return 4;
    if (!mutate_global()) return 5;
    if (!layout()) return 6;
    if (!statics_persist()) return 7;
    if (!global_int_array()) return 8;
    return 0;
}
