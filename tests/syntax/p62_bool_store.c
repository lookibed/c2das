/* Value-site acceptance: a C relational, equality or logical expression has
 * type int, and every site that stores or consumes its value sees 0 or 1 as an
 * integer — not a boolean. Returns 0 on success, N for the failed check. */

int g_flag = 0;
int g_flags[4];

struct flags {
    int eq;
    int lt;
    int both;
    unsigned char narrow;
};

static int take_int(int value) {
    return value * 3;
}

static int returned(int left, int right) {
    return left < right;
}

/* The declarator's initialiser is an assignment: the comparison is stored as
 * an int, exactly as a later `x = a == b` would store it. */
static int initialiser(int left, int right) {
    int eq = left == right;
    int ne = left != right;
    int negated = !left;
    int both = left < right && right < 10;
    int either = left > right || right == 2;
    return eq * 10000 + ne * 1000 + negated * 100 + both * 10 + either;
}

/* The same values reaching an int that was declared earlier. */
static int plain_assignment(int left, int right) {
    int eq = 7;
    int negated = 7;
    int chained = 7;
    eq = left == right;
    negated = !right;
    chained = (left <= right) == 1;
    return eq * 100 + negated * 10 + chained;
}

/* A cast on an operand must not hide the comparison's int-ness. */
static int cast_operand(unsigned value) {
    int zero = (int)value == 0;
    int wide = (long)value > 1L;
    int narrow = (unsigned char)value != 0u;
    return zero * 100 + wide * 10 + narrow;
}

static int arithmetic(int left, int right) {
    int sum = (left < right) + (left == right) + (left > right);
    int scaled = 5 * (left != right) - (left == right);
    int shifted = (left < right) << 3;
    return sum * 1000 + scaled * 10 + shifted;
}

static int struct_and_array_stores(int left, int right) {
    struct flags f;
    int local[3];
    f.eq = left == right;
    f.lt = left < right;
    f.both = f.eq || f.lt;
    f.narrow = left != right;
    local[0] = left >= right;
    local[1] = left <= right;
    local[2] = local[0] && local[1];
    g_flag = left != right;
    g_flags[0] = left < right;
    g_flags[1] = !g_flags[0];
    return f.eq * 1000000 + f.lt * 100000 + f.both * 10000 + (int)f.narrow * 1000 +
           local[0] * 100 + local[1] * 10 + local[2] + g_flag + g_flags[0] + g_flags[1];
}

static int passed_as_argument(int left, int right) {
    return take_int(left < right) + take_int(left == right);
}

static int compound_target(int left, int right) {
    int acc = 10;
    acc += left < right;
    acc -= left == right;
    acc *= left != right;
    return acc;
}

static int loop_accumulated(void) {
    int hits = 0;
    int i;
    for (i = 0; i < 6; i++) {
        int is_even = i % 2 == 0;
        hits += is_even;
    }
    return hits;
}

int bool_store_runtime(void) {
    if (initialiser(1, 2) != 1011) return 1;
    if (initialiser(2, 2) != 10001) return 2;
    if (plain_assignment(1, 2) != 1) return 3;
    if (plain_assignment(2, 2) != 101) return 4;
    if (cast_operand(0u) != 100) return 5;
    if (cast_operand(2u) != 11) return 6;
    if (arithmetic(1, 2) != 1058) return 7;
    if (arithmetic(2, 2) != 990) return 8;
    if (struct_and_array_stores(1, 2) != 111012) return 9;
    if (struct_and_array_stores(2, 2) != 1010112) return 10;
    if (passed_as_argument(1, 2) != 3) return 11;
    if (passed_as_argument(2, 2) != 3) return 12;
    if (returned(1, 2) != 1 || returned(2, 1) != 0) return 13;
    if (compound_target(1, 2) != 11) return 14;
    if (compound_target(2, 2) != 0) return 15;
    if (loop_accumulated() != 3) return 16;
    if (g_flag != 0 || g_flags[0] != 0 || g_flags[1] != 1) return 17;
    return 0;
}
