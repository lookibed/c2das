/* Global initialiser ordering: a file-scope initialiser is a link-time
 * constant in C, so it may name an object defined later in the translation
 * unit, and two objects may point at each other.  Returns 0 on success. */

struct entry {
    int index;
    int value;
};

/* A pointer table whose elements address two tables declared before it. */
static const struct entry LUMA[3] = { { 1, 10 }, { 2, 20 }, { 3, 30 } };
static const struct entry CHROMA[3] = { { 4, 40 }, { 5, 50 }, { 6, 60 } };
static const struct entry *const PLANES[3] = { LUMA, CHROMA, CHROMA };

/* A pointer global whose initialiser names a global defined *after* it. */
extern int late_counter;
int *early_pointer = &late_counter;
int late_counter = 77;

/* A struct global holding a pointer to another global defined later. */
struct holder {
    int tag;
    const struct entry *rows;
};
extern const struct entry TAIL[2];
struct holder g_holder = { 5, TAIL };
const struct entry TAIL[2] = { { 7, 70 }, { 8, 80 } };

/* A self-referential pair: each node points at the other. */
struct node {
    int id;
    struct node *peer;
};
extern struct node node_b;
struct node node_a = { 1, &node_b };
struct node node_b = { 2, &node_a };

/* A table of function pointers naming functions defined further down. */
static int plus_one(int x);
static int times_two(int x);
static int (*const OPS[2])(int) = { plus_one, times_two };

static int plus_one(int x) { return x + 1; }
static int times_two(int x) { return x * 2; }

/* Two functions whose hoisted `static` storage is in reverse dependency
 * order: each names a file-scope table defined further down, and the table
 * the first function needs is defined after the one the second needs. */
extern const int TAIL_ROWS[3];
extern const int HEAD_ROWS[3];

static const int *stage_one(void) {
    static const int *const slot = TAIL_ROWS;
    return slot;
}

static const int *stage_two(void) {
    static const int *const slot = HEAD_ROWS;
    return slot;
}

const int TAIL_ROWS[3] = { 100, 200, 300 };
const int HEAD_ROWS[3] = { 1, 2, 3 };

static int pointer_table(void) {
    return PLANES[0] == LUMA && PLANES[1] == CHROMA && PLANES[2] == CHROMA &&
           PLANES[0][2].value == 30 && PLANES[1][0].index == 4 && PLANES[2][2].value == 60;
}

static int forward_global(void) {
    return *early_pointer == 77 && early_pointer == &late_counter;
}

static int struct_pointer_global(void) {
    return g_holder.tag == 5 && g_holder.rows == TAIL && g_holder.rows[1].value == 80;
}

static int linked_pair(void) {
    return node_a.peer == &node_b && node_b.peer == &node_a && node_a.peer->id == 2 &&
           node_a.peer->peer->id == 1;
}

static int function_table(void) {
    return OPS[0](5) == 6 && OPS[1](5) == 10;
}

static int hoisted_statics(void) {
    const int *first = stage_one();
    const int *second = stage_two();
    return first == TAIL_ROWS && second == HEAD_ROWS && first[0] == 100 && first[2] == 300 &&
           second[0] == 1 && second[2] == 3;
}

int global_init_order_runtime(void) {
    if (!pointer_table()) return 1;
    if (!forward_global()) return 2;
    if (!struct_pointer_global()) return 3;
    if (!linked_pair()) return 4;
    if (!function_table()) return 5;
    if (!hoisted_statics()) return 6;
    return 0;
}
