/* Byte-model acceptance: every anonymous record and enumeration a program can
 * name must reach the module with exactly one declaration, whatever scope
 * introduced it. Returns 0 on success, N for the N-th failed check. */

/* File-scope typedef of an anonymous struct. */
typedef struct {
    int a;
    int b;
} anon_pair;

/* Anonymous struct and anonymous union nested inside a named struct. */
struct holder {
    struct {
        int x;
        int y;
    } point;
    union {
        int as_int;
        unsigned as_uint;
    } pun;
    int tail;
};

/* File-scope anonymous enum: only its enumerators are nameable. */
enum { FILE_ANON_LOW = 3, FILE_ANON_HIGH = 40 };

static anon_pair g_pair = { 1, 2 };
static struct holder g_holder = { { 0, 0 }, { 0 }, 0 };

/* Anonymous struct declared inside a function body. */
static int local_anon_struct(void) {
    struct { int a; int b; } e;
    e.a = 1;
    e.b = 2;
    e.a += e.b;
    return e.a * 10 + e.b;
}

/* Typedef of an anonymous struct inside a function body, plus a copy. */
static int local_anon_typedef(void) {
    typedef struct { int p; int q; } local_anon;
    local_anon v;
    local_anon w;
    v.p = 10;
    v.q = 20;
    w = v;
    w.q = 5;
    return v.q == 20 && w.p == 10 && w.q == 5;
}

/* Function-scope `static` of an anonymous struct type: one module-level
 * object, and one declaration of its type. */
static int local_static_anon(void) {
    static struct { int c; } s = { 7 };
    s.c += 1;
    return s.c;
}

/* Two anonymous structs of identical shape in different functions. Each C
 * declaration is a distinct type; both must be declared. */
static int same_shape_one(void) {
    struct { int a; int b; } e;
    e.a = 5;
    e.b = 6;
    return e.a * e.b;
}

static int same_shape_two(void) {
    struct { int a; int b; } e;
    e.a = 2;
    e.b = 3;
    return e.a * e.b;
}

/* Function-scope anonymous enum with an object of that type: the shape that
 * used to name a type the module never declared. */
static int local_anon_enum(void) {
    enum { LOCAL_DURATION = 0x8, LOCAL_FLAGS = 0x20 } e;
    e = LOCAL_DURATION;
    return (int) e + LOCAL_FLAGS;
}

/* Function-scope anonymous union, written through one member and read
 * through the other. */
static int local_anon_union(void) {
    union { int i; unsigned u; } uu;
    uu.i = -1;
    return uu.u == 0xFFFFFFFFu;
}

/* Anonymous struct passed and returned by value. */
static anon_pair swapped(anon_pair in) {
    anon_pair out;
    out.a = in.b;
    out.b = in.a;
    return out;
}

static int by_value_roundtrip(void) {
    anon_pair p;
    anon_pair q;
    p.a = 11;
    p.b = 22;
    q = swapped(p);
    return p.a == 11 && p.b == 22 && q.a == 22 && q.b == 11;
}

int anonymous_records_runtime(void) {
    anon_pair copy;

    if (g_pair.a + g_pair.b != 3) return 1;
    copy = g_pair;
    copy.a = 100;
    if (g_pair.a != 1 || copy.b != 2) return 2;

    g_holder.point.x = 4;
    g_holder.point.y = 5;
    g_holder.pun.as_int = 9;
    g_holder.tail = 11;
    if (g_holder.point.x + g_holder.point.y != 9) return 3;
    if (g_holder.pun.as_uint != 9u) return 4;
    if (g_holder.tail != 11) return 5;

    if (local_anon_struct() != 32) return 6;
    if (!local_anon_typedef()) return 7;
    if (local_static_anon() != 8) return 8;
    if (local_static_anon() != 9) return 9;
    if (same_shape_one() != 30) return 10;
    if (same_shape_two() != 6) return 11;
    if (local_anon_enum() != 0x28) return 12;
    if (!local_anon_union()) return 13;
    if (!by_value_roundtrip()) return 14;
    if (FILE_ANON_LOW + FILE_ANON_HIGH != 43) return 15;

    return 0;
}
