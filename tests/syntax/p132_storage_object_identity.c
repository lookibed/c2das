/* A storage-backed record object keeps its storage for its whole lifetime.
 *
 * The object's address is its storage (a pointer to it, or into it, is a
 * byte address), so nothing may replace that storage while the object lives:
 *
 * - `s = t` and `a[i] = t` write t's bytes into s's storage;
 * - a block-scope declaration with an initializer writes the bytes into the
 *   object the function already holds, each time control passes it — no
 *   allocation per pass (Doom's `struct color c = colors[...]` runs 64,000
 *   times a frame in `dg_hash_frame`), and the same object every pass;
 * - a file-scope array with an initializer is built over its contiguous
 *   block, and the initializer's bytes are copied into it;
 * - a file-scope object whose initializer reaches the object itself (a cycle
 *   of one, assigned by `[init]`) keeps the storage an address taken inside
 *   that initializer points into (`&ring[2].v` within `ring`). */
#include <stdio.h>
#include <string.h>

typedef struct __attribute__((packed)) node {
    char tag;
    struct node *next;
    int v;
    int *pv;
} node_t;

static node_t ring[3] = {{'a', &ring[1], 1, &ring[2].v}, {'b', &ring[2], 2, &ring[0].v}, {'c', &ring[0], 3, &ring[1].v}};
static int *pv = &ring[1].v;

typedef union act {
    void (*f)(void);
    int n;
} act_t;
typedef struct st {
    int id;
    act_t a;
    int *mine;
} st_t;
static void bump(void);
static st_t states[2] = {{7, {bump}, &states[1].id}, {8, {bump}, &states[0].id}};
static void bump(void) { states[0].id += 100; }

typedef struct __attribute__((packed)) {
    unsigned char a;
    int b;
} pair_t;
typedef union {
    int i;
    float f;
} value_t;

static pair_t table[3] = {{1, 10}, {2, 20}, {3, 30}};
static value_t cell;

static pair_t make(int b) {
    pair_t p;
    memset(&p, 0, sizeof p);
    p.b = b;
    return p;
}

static int walk(void) {
    int total = 0;
    int *first = NULL;
    int i;
    for (i = 0; i < 3; i++) {
        pair_t local = table[i];
        if (first == NULL) {
            first = &local.b;
        }
        total += local.b + *first;
    }
    return total;
}

int main(void) {
    pair_t *p1 = &table[1];
    value_t *pc = &cell;
    value_t other;
    pair_t lt[2] = {{4, 40}, {5, 50}};
    pair_t *lp = lt;

    *pv = 20;
    *ring[0].pv += 30;
    printf("ring %d %d %d %c\n", ring[1].v, ring[0].next->v, ring[2].v, ring[2].next->next->tag);
    states[0].a.f();
    *states[1].mine += 1;
    printf("states %d %d %d\n", states[0].id, states[1].id, *states[0].mine);

    other.i = 42;
    table[1] = make(9);
    cell = other;
    printf("assign %d %d %d\n", p1->b, pc->i, (table + 2)->b);
    lt[0] = lt[1];
    printf("local %d %d %d\n", lp->b, (lp + 1)->a, walk());
    return 0;
}
