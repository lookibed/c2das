/* Static initializers of globals in the linear heap: constant expressions
 * (sizeof, arithmetic), string literals into char arrays inside records. */
#include <stdio.h>
#include <stddef.h>

#define SEQ(value, params) { value, sizeof(value) - 1, params, 0, 0, "" }

typedef struct {
    char sequence[25];
    size_t sequence_len;
    int parameter_chars;
    size_t chars_read;
    int param_chars_read;
    char parameter_buf[5];
} seq_t;

seq_t seq_a = SEQ("idmus", 2);
seq_t seq_b[2] = { SEQ("iddqd", 0), SEQ("idclip", 1 << 2) };
static int scaled[3] = { 3 * 4, (10 + 2) / 3, -(7 % 4) + -9 / 2 - -9 % 4 };

typedef struct node_s node_t;
struct node_s {
    char *name;
    int value;
    node_t *link;
    int *slot;
};

#define NODE(name, value) { name, value, NULL, NULL }
#define NODE_LINK(name, value, k) { name, value, &nodes[k], &scaled[k] }

node_t nodes[] = {
    NODE(NULL, 0),
    NODE("one", 1),
    NODE_LINK("two", 2, 1),
};
int *first_scaled = scaled;
node_t *last_node = &nodes[2];

/* Fixed point from double arithmetic, and float/double globals. */
#define ONE (1 << 16)
typedef struct { int x, y; } vec_t;
vec_t shape[2] = { { (int)(-.5 * ONE), (int)(.7 * ONE) }, { (int)(ONE), (int)(-.867 * ONE) } };
float ratios[2] = { 1.5f, -0.25f * 3 };
double scale = 2.5 * 4;

/* A union of function pointers of different types, initialized through a
 * cast and called back through its own type (as Doom's actionf_t). */
typedef void (*act_v)();
typedef void (*act_p1)(void *);
typedef union { act_v acv; act_p1 acp1; } act_t;
typedef struct { int sprite; act_t action; } state_t;
static int hits;
static void bump(void *p) { hits += *(int *)p; }
state_t states[2] = { { 1, { NULL } }, { 2, { (act_v)bump } } };

static int check(seq_t *s) {
    return (int)s->sequence_len * 100 + s->parameter_chars * 10 + (int)s->chars_read;
}

int main(void) {
    seq_t *p = &seq_a;
    seq_t *q = seq_b;
    int *r = scaled;
    printf("%s %d\n", p->sequence, check(p));
    printf("%s %d %s %d\n", q[0].sequence, check(&q[0]), q[1].sequence, check(&q[1]));
    printf("%d %d %d\n", r[0], r[1], r[2]);
    for (int i = 0; i < 3; i++) {
        node_t *n = &nodes[i];
        printf("%s %d %s %d\n", n->name ? n->name : "-", n->value, n->link ? n->link->name : "-",
               n->slot ? *n->slot : -1);
    }
    printf("%d %s\n", first_scaled[1], last_node->link->name);
    vec_t *v = shape;
    float *f = ratios;
    double *d = &scale;
    printf("%d %d %d %d\n", v[0].x, v[0].y, v[1].x, v[1].y);
    printf("%d %d %d\n", (int)(f[0] * 100), (int)(f[1] * 100), (int)*d);
    int amount = 5;
    for (int i = 0; i < 2; i++) {
        state_t *st = &states[i];
        if (st->action.acv != NULL)
            st->action.acp1(&amount);
    }
    printf("hits=%d\n", hits);
    void *routine = (void *)bump;
    act_p1 back = (act_p1)routine;
    back(&amount);
    printf("hits=%d\n", hits);
    return 0;
}
