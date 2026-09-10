/* Byte-model acceptance: locals whose address is taken keep one identity,
 * across calls, recursion and pointer arithmetic. Returns 0 on success. */

static void set_int(int *p, int v) { *p = v; }
static void bump(int *p) { (*p)++; }

static int scalar_address(void) {
    int x = 1;
    int *p = &x;
    set_int(p, 41);
    bump(&x);
    return x == 42 && *p == 42;
}

static int two_locals(void) {
    int a = 1, b = 2;
    int *pa = &a, *pb = &b;
    *pa = 10;
    *pb = 20;
    int c = 3; /* declared after the pointers exist */
    return a == 10 && b == 20 && c == 3 && pa != pb;
}

static int depth_sum(int n) {
    int local = n;
    int *p = &local;
    if (n == 0) return *p;
    int below = depth_sum(n - 1);
    return *p + below; /* each frame keeps its own `local` */
}

static int recursion(void) { return depth_sum(4) == 10; }

static int fill(int *arr, int n) {
    int i = 0;
    while (i < n) {
        arr[i] = i * i;
        i++;
    }
    return arr[n - 1];
}

static int local_array_to_callee(void) {
    int a[5];
    int last = fill(a, 5);
    return last == 16 && a[0] == 0 && a[3] == 9;
}

struct pt {
    int x;
    int y;
};

static void move_pt(struct pt *p, int dx) { p->x += dx; }

static int pointer_into_local_array(void) {
    struct pt ps[3] = { { 1, 1 }, { 2, 2 }, { 3, 3 } };
    struct pt *q = &ps[1];
    move_pt(q, 40);
    move_pt(ps + 2, 100);
    return ps[1].x == 42 && ps[2].x == 103 && (q + 1)->y == 3 && q - ps == 1;
}

static int *keep;

static int stored_pointer(void) {
    int v = 5;
    keep = &v;
    *keep = 6;
    return v == 6;
}

static int swap_via_pointers(void) {
    int a = 1, b = 2;
    int *pa = &a, *pb = &b;
    int t = *pa;
    *pa = *pb;
    *pb = t;
    return a == 2 && b == 1;
}

static int char_buffer(void) {
    char buf[8];
    char *p = buf;
    *p++ = 'h';
    *p++ = 'i';
    *p = 0;
    int n = 0;
    while (buf[n]) n++;
    return n == 2 && buf[0] == 'h';
}

static int nested_scope_address(void) {
    int total = 0;
    int i = 0;
    while (i < 3) {
        int k = i;
        int *pk = &k;
        *pk += 10;
        total += k;
        i++;
    }
    return total == 33;
}

int address_taken_runtime(void) {
    if (!scalar_address()) return 1;
    if (!two_locals()) return 2;
    if (!recursion()) return 3;
    if (!local_array_to_callee()) return 4;
    if (!pointer_into_local_array()) return 5;
    if (!stored_pointer()) return 6;
    if (!swap_via_pointers()) return 7;
    if (!char_buffer()) return 8;
    if (!nested_scope_address()) return 9;
    return 0;
}
