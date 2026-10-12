/* Heap load reuse under --memory-model linear (translator/linear/reuse.rs):
 * repeated loads of one address reuse the first, a stored float is forwarded
 * to the next load of its address, and every case where C may see a different
 * value reloads: a store through another (aliasing) pointer, a call, a write
 * to the address's variable, a volatile object. */
#include <stdio.h>
#include <stdlib.h>

typedef float vec3_t[3];
#define DotProduct(x, y) ((x)[0] * (y)[0] + (x)[1] * (y)[1] + (x)[2] * (y)[2])
#define VectorMA(veca, scale, vecb, vecc)                                   \
    ((vecc)[0] = (veca)[0] + (scale) * (vecb)[0],                           \
     (vecc)[1] = (veca)[1] + (scale) * (vecb)[1],                           \
     (vecc)[2] = (veca)[2] + (scale) * (vecb)[2])

typedef struct {
    vec3_t v;
    float st[2];
    int flags;
    struct node *next;
} vert_t;

struct node {
    int value;
    struct node *next;
};

static int g_calls;

static void bump(float *p) {
    g_calls++;
    *p += 1.0f;
}

static float xf[3][4] = {{1, 2, 3, 4}, {5, 6, 7, 8}, {9, 10, 11, 12}};

/* Same field read three times per statement, and again in the next ones. */
static void xform(vert_t *in, float *out) {
    float x = in->v[0] * xf[0][0] + in->v[1] * xf[0][1] + in->v[2] * xf[0][2] + xf[0][3];
    float y = in->v[0] * xf[1][0] + in->v[1] * xf[1][1] + in->v[2] * xf[1][2] + xf[1][3];
    float z = in->v[0] * in->v[0] + in->v[1] * in->v[1] + in->v[2] * in->v[2];
    out[0] = x;
    out[1] = y + out[0];  /* forwarded store */
    out[2] = z * out[1] + out[0];
}

/* `out` may alias `in`: the store through `out` must be seen by the
 * following load through `in`. */
static float alias_store(float *in, float *out) {
    float a = in[0] * 2.0f;
    out[0] = 7.5f;
    float b = in[0] * 2.0f;
    return a + b;
}

/* Forwarded store, then a store through an aliasing pointer: reload. */
static float alias_forward(float *p, float *q) {
    p[1] = 3.25f;
    q[1] = -1.5f;
    return p[1];
}

/* A call between two loads of one address may change it. */
static float call_between(float *p) {
    float a = p[0];
    bump(p);
    float b = p[0];
    return a * 10.0f + b;
}

/* The pointer variable changes between two loads with the same text. */
static float pointer_moves(float *p) {
    float a = p[0] + p[0];
    p = p + 1;
    float b = p[0] + p[0];
    return a * 100.0f + b;
}

/* A volatile heap object is read every time it is named. */
static int volatile_reads(volatile int *p) {
    int a = *p + *p;
    *p = 5;
    int b = *p + *p;
    return a * 100 + b;
}

/* First load only under `&&`: never hoisted, yet correct. */
static int conditional_first(vert_t *v) {
    int r = 0;
    if (v != 0 && v->flags > 2) {
        r = v->flags * 3 + v->flags;
    }
    r += (v != 0 && v->flags > 0) ? v->flags + v->flags : -1;
    return r;
}

/* Integer and pointer loads in a loop body, list traversal. */
static int walk(struct node *n) {
    int sum = 0;
    while (n) {
        sum += n->value * n->value + (n->next ? n->next->value : 0);
        n = n->next;
    }
    return sum;
}

static void vector_ma(void) {
    vec3_t *a = malloc(sizeof(vec3_t) * 2);
    a[0][0] = 1; a[0][1] = 2; a[0][2] = 3;
    a[1][0] = 0.5f; a[1][1] = 0.25f; a[1][2] = 0.125f;
    /* vecc aliases veca: each component reads the freshly stored one. */
    VectorMA(a[0], 2.0f, a[1], a[0]);
    VectorMA(a[0], 2.0f, a[0], a[0]);
    printf("ma %g %g %g dot %g\n", a[0][0], a[0][1], a[0][2], DotProduct(a[0], a[1]));
    free(a);
}

int main(void) {
    vert_t *v = calloc(2, sizeof(vert_t));
    v->v[0] = 1.5f; v->v[1] = -2.0f; v->v[2] = 0.25f;
    v->flags = 3;
    float *out = calloc(4, sizeof(float));
    xform(v, out);
    printf("xform %g %g %g\n", out[0], out[1], out[2]);

    float *f = calloc(4, sizeof(float));
    f[0] = 2.0f;
    printf("alias_store same %g\n", alias_store(f, f));
    f[0] = 2.0f;
    printf("alias_store diff %g\n", alias_store(f, f + 2));
    printf("alias_forward same %g\n", alias_forward(f, f));
    printf("alias_forward diff %g\n", alias_forward(f, f + 2));
    f[0] = 4.0f;
    printf("call_between %g calls %d\n", call_between(f), g_calls);
    f[0] = 1.0f; f[1] = 3.0f;
    printf("pointer_moves %g\n", pointer_moves(f));

    int *iv = calloc(1, sizeof(int));
    *iv = 2;
    printf("volatile %d\n", volatile_reads(iv));
    printf("conditional %d %d\n", conditional_first(v), conditional_first(0));
    v->flags = 1;
    printf("conditional %d\n", conditional_first(v));

    struct node *head = 0;
    for (int i = 1; i <= 5; i++) {
        struct node *n = malloc(sizeof(struct node));
        n->value = i;
        n->next = head;
        head = n;
    }
    printf("walk %d\n", walk(head));
    vector_ma();
    return 0;
}
