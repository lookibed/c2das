/* Byte-model acceptance: aggregates passed and returned by value are copies.
 * Returns 0 on success. */

struct vec2 {
    short x;
    short y;
};

struct big {
    int id;
    int data[6];
    struct vec2 v;
};

union num {
    int i;
    float f;
    unsigned char b[4];
};

struct holder {
    int tag;
    union num u;
};

static int sum_vec(struct vec2 v) {
    v.x += 100; /* modifies the callee's copy only */
    return v.x + v.y;
}

static struct vec2 make_vec(short x, short y) {
    struct vec2 v;
    v.x = x;
    v.y = y;
    return v;
}

static struct vec2 add_vec(struct vec2 a, struct vec2 b) {
    struct vec2 r = { (short)(a.x + b.x), (short)(a.y + b.y) };
    return r;
}

static int by_value_scalar_fields(void) {
    struct vec2 v = { 3, 4 };
    int s = sum_vec(v);
    return s == 107 && v.x == 3;
}

static int returned_struct(void) {
    struct vec2 v = make_vec(5, 6);
    struct vec2 w = add_vec(v, make_vec(1, 1));
    return v.x == 5 && v.y == 6 && w.x == 6 && w.y == 7;
}

static int take_address_of_param(struct big b) {
    int *p = &b.data[2];
    *p = 99;
    b.v.x = -1;
    return b.data[2] + b.id;
}

static int big_by_value(void) {
    struct big b = { 7, { 1, 2, 3, 4, 5, 6 }, { 8, 9 } };
    int r = take_address_of_param(b);
    return r == 106 && b.data[2] == 3 && b.v.x == 8;
}

static struct big make_big(int id) {
    struct big b = { id, { id, id + 1, id + 2, id + 3, id + 4, id + 5 }, { (short)id, (short)-id } };
    return b;
}

static int returned_big(void) {
    struct big b = make_big(10);
    struct big c = make_big(20);
    return b.data[5] == 15 && c.data[0] == 20 && b.v.y == -10 && c.v.x == 20;
}

static int holder_tag(struct holder h) {
    h.u.i = 0;
    return h.tag;
}

static int union_by_value(void) {
    struct holder h = { 5, { 0x01020304 } };
    int t = holder_tag(h);
    return t == 5 && h.u.i == 0x01020304 && h.u.b[0] == 0x04;
}

static int chain(struct vec2 v, int depth) {
    if (depth == 0) return v.x * 10 + v.y;
    v.x++;
    v.y--;
    return chain(v, depth - 1);
}

static int recursive_by_value(void) {
    struct vec2 v = { 1, 9 };
    int r = chain(v, 4);
    return r == 55 && v.x == 1 && v.y == 9;
}

int struct_by_value_runtime(void) {
    if (!by_value_scalar_fields()) return 1;
    if (!returned_struct()) return 2;
    if (!big_by_value()) return 3;
    if (!returned_big()) return 4;
    if (!union_by_value()) return 5;
    if (!recursive_by_value()) return 6;
    return 0;
}
