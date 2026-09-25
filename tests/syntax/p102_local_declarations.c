/* C locals: declared once at the top of the translated function, initialised
 * where C writes the initializer.  A hoisted `var` of a type daslang
 * zero-fills (numbers, pointers, pointer aliases, plain structs of them,
 * arrays of those) carries no initializer of its own; a union (storage-backed)
 * and a daslang `enum` keep their explicit value.  Every case below computes a
 * value that changes if an initializer runs too often, too rarely, or at the
 * wrong point, or if a jump past a declaration loses the object. */

struct point {
    int x;
    int y;
    int *tag;
};

struct wrapped {
    struct point p;
    double w[2];
};

union bits {
    unsigned u;
    float f;
};

enum colour { NONE, RED, GREEN };

typedef const unsigned char *cursor_t;

static int g_state;

static int check(long long got, long long want) {
    return got == want ? 0 : 1;
}

/* An initializer inside a loop runs on every iteration. */
static int loop_reinit(int n) {
    int total = 0;
    for (int i = 0; i < n; i++) {
        int acc = 10;
        struct point pt = {i, i * 2, 0};
        acc += pt.x + pt.y;
        total += acc;
    }
    return total;
}

/* A `goto` past declarations enters their scope: the objects exist, and are
 * assigned before they are read. */
static int jump_past(int k) {
    if (k > 0) {
        goto skip;
    }
    int x = 5;
    struct point p = {1, 2, 0};
    int *q = &x;
    return x + p.x + *q;
skip:
    x = k;
    p.x = k;
    q = &x;
    return x * 10 + p.x + *q;
}

/* A `switch` dispatch past a declaration in the middle of a case. */
static int switch_past(int sel) {
    int r = 0;
    switch (sel) {
    case 0: {
        int v = 7;
        r = v;
        break;
    }
    case 1:;
        int w = 3;
        r = w;
        /* fall through */
    case 2:
        w = 40;
        r += w;
        break;
    default:
        r = -1;
    }
    return r;
}

/* A computed `switch` scrutinee that opens the function: its temporary is
 * declared with its value. */
static int classify(unsigned short op) {
    switch ((int)op + 1) {
    case 2:
        return 20;
    case 3:
        return 30;
    default:
        return 0;
    }
}

/* Locals without an initializer, every one assigned before it is read. */
static int uninit_then_assign(int k) {
    int a;
    unsigned long long b;
    double d;
    int *p;
    struct point pt;
    cursor_t cur;
    if (k) {
        a = 1;
        b = 2;
        d = 0.5;
        p = &a;
        pt.x = 3;
        cur = 0;
    } else {
        a = 4;
        b = 5;
        d = 1.5;
        p = &a;
        pt.x = 6;
        cur = (cursor_t) "z";
    }
    return a + (int)b + (int)(d * 2) + *p + pt.x + (cur ? 100 : 0);
}

static void bump(int *p) {
    (*p)++;
}

/* Address-taken locals: one re-initialised in a loop, one accumulated. */
static int address_taken(int n) {
    int count = 0;
    for (int i = 0; i < n; i++) {
        int local = i;
        bump(&local);
        bump(&count);
        count += local;
    }
    return count;
}

/* A union, a daslang `enum` and a nested plain struct. */
static int aggregates(int k) {
    union bits b;
    enum colour c;
    struct wrapped wr;
    b.u = 0x3f800000u;
    c = k ? GREEN : RED;
    wr.p.x = 2;
    wr.w[1] = 1.5;
    return (b.f == 1.0f) + (int)c * 10 + wr.p.x * 100 + (int)(wr.w[1] * 2) * 1000;
}

/* A post-increment of a pointer alias in a loop: its old-value temporary is
 * hoisted, of a named (alias) type. */
static int length_of(cursor_t s) {
    int n = 0;
    cursor_t cur = s;
    while (*cur++) {
        n++;
    }
    return n;
}

/* A `void` function whose early `return` is laid out after the closing one. */
static void early_return(int a, int b) {
    if (a < 0) {
        return;
    }
    g_state = a;
    g_state += b;
}

/* A first store that names its own object stays an assignment. */
static int self_reference(void) {
    void *self = &self;
    return self == (void *)&self;
}

/* A store that opens the body becomes the last declaration's value; a
 * `const` local is hoisted writable. */
static int first_store(int k) {
    const int bias = k + 1;
    return bias * 2;
}

/* Only the declaration right above the first store is given its value. */
static int two_stores(int k) {
    int doubled = k * 2;
    int bias = 1;
    return doubled + bias;
}

int local_declarations_runtime(void) {
    int failures = 0;
    failures += check(loop_reinit(3), 10 + 13 + 16);
    failures += check(jump_past(0), 5 + 1 + 5);
    failures += check(jump_past(4), 40 + 4 + 4);
    failures += check(switch_past(0), 7);
    failures += check(switch_past(1), 43);
    failures += check(switch_past(2), 40);
    failures += check(switch_past(9), -1);
    failures += check(classify(1), 20);
    failures += check(classify(2), 30);
    failures += check(classify(7), 0);
    failures += check(uninit_then_assign(1), 1 + 2 + 1 + 1 + 3);
    failures += check(uninit_then_assign(0), 4 + 5 + 3 + 4 + 6 + 100);
    failures += check(address_taken(3), 9);
    failures += check(aggregates(1), 1 + 20 + 200 + 3000);
    failures += check(aggregates(0), 1 + 10 + 200 + 3000);
    failures += check(length_of((cursor_t) "abcd"), 4);
    g_state = 0;
    early_return(-1, 5);
    failures += check(g_state, 0);
    early_return(2, 5);
    failures += check(g_state, 7);
    failures += check(self_reference(), 1);
    failures += check(first_store(20), 42);
    failures += check(two_stores(20), 41);
    return failures;
}
