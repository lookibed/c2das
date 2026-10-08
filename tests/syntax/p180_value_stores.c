/* A scalar store whose right-hand side is a reference expression that is
 * not rooted at a local (an element `p[i]`, a dereference `*q`, a global, a
 * parameter, a field through a pointer) is written `place = T(value)` with a
 * value-read cast (`das_ast::fold`, "Value stores"): daslang then stores it
 * with the typed `Set_TT<T>` instead of the runtime-sized `CopyRefValue`
 * memcpy.  A store into a local, or of a local (or a field of a local
 * structure), keeps the plain form: the interpreter fuses those copies
 * already.  A statement `x += 1` / `x -= 1` on a builtin integer is `x++` /
 * `x--` ("Increments").
 *
 * Covered: store through a pointer of an element, a global, a parameter;
 * global of an element and of a parameter; element of element; field of
 * field through pointers; `unsigned char` and `float` elements; locals on
 * either side left alone; local initialisers left alone; a pointer store;
 * increments and decrements of a global, through a pointer, of a field and
 * of a local; a `long` step. */
#include <stdio.h>

struct pair {
    int a;
    int b;
};

static int g;
static int garr[4] = {10, 20, 30, 40};
static int *gp;
static long gl;

static void through_pointer(int *dest, int *src, int i, int param) {
    *dest = src[i];       /* *dest = int(unsafe(src[i])) */
    dest[1] = src[i + 1]; /* element of element */
    dest[2] = g;          /* of a global */
    dest[3] = param;      /* of a parameter */
}

static void into_global(int *src, int i, int param) {
    g = src[i];           /* g = int(unsafe(src[i])) */
    garr[0] = param;      /* element of a parameter */
    garr[1] = *src;       /* element of a dereference */
}

static void fields(struct pair *p, struct pair *q) {
    p->a = q->b;          /* field of field through pointers */
    q->a = p->b;
}

static void narrow(unsigned char *dest, const unsigned char *src, float *fd, const float *fs, int i) {
    *dest = src[i];       /* uint8 */
    *fd = fs[i];          /* float */
}

static int locals(int *src, int i) {
    int loc = src[i];     /* initialiser: left alone */
    int other = 0;
    struct pair lp = {1, 2};
    other = loc;          /* local of local: left alone */
    *src = loc;           /* of a local: left alone */
    g = lp.a;             /* of a local structure field: left alone */
    loc = g;              /* into a local: left alone */
    other = src[i];       /* into a local: left alone */
    return loc + other;
}

static void pointers(int **slots, int i) {
    gp = slots[i];        /* pointer: left alone */
}

static void steps(int *p, struct pair *q) {
    g += 1;               /* g++ */
    g -= 1;               /* g-- */
    *p += 1;              /* (*p)++ */
    p[1] -= 1;            /* p[1]-- */
    q->a += 1;            /* q.a++ */
    q->b -= 1;
    gl += 1;              /* gl++ (long) */
    g += 2;               /* stays a compound assignment */
}

int main(void) {
    int buf[4] = {1, 2, 3, 4};
    int out[4] = {0, 0, 0, 0};
    unsigned char bytes[2] = {7, 0};
    float reals[2] = {1.5f, 0.0f};
    struct pair x = {1, 2};
    struct pair y = {3, 4};
    int *slots[2] = {&buf[0], &buf[1]};
    int local = 5;
    g = 9;
    through_pointer(out, buf, 1, 77);
    printf("pointer %d %d %d %d\n", out[0], out[1], out[2], out[3]);
    into_global(buf, 2, 88);
    printf("global %d %d %d\n", g, garr[0], garr[1]);
    fields(&x, &y);
    printf("fields %d %d %d %d\n", x.a, x.b, y.a, y.b);
    narrow(&bytes[1], bytes, &reals[1], reals, 0);
    printf("narrow %d %.1f\n", bytes[1], reals[1]);
    local = locals(buf, 3);
    printf("locals %d %d %d\n", local, buf[0], g);
    pointers(slots, 1);
    printf("pointers %d\n", *gp);
    local += 1;
    local -= 1;
    local += 1;
    steps(out, &x);
    printf("steps %d %d %d %d %d %ld %d\n", g, out[0], out[1], x.a, x.b, gl, local);
    return 0;
}
