/* Boolean-context lowering, enumeration truth, discarded values and pointee
 * const.  C has no boolean operand type and no truthiness for daScript to
 * borrow: an enumeration in a condition tests its integer value, a comparison
 * yields an int that another comparison may consume, `(void)x` discards a
 * value rather than converting it, and `T *` reaches a `const T *` parameter
 * without a conversion.  Returns 0 on success, N for the failed check. */

typedef enum {
    ST_UNUSED = 0,
    ST_SHORT,
    ST_LONG
} status_e;

/* An enumeration whose enumerators never include 0: every value is true, and a
 * condition on one must still compare against the integer zero. */
typedef enum {
    LV_LOW = 1,
    LV_MID = 4,
    LV_HIGH = 9
} level_e;

struct slot {
    status_e status;
    level_e level;
    int payload;
};

static struct slot g_slots[4];
static int g_effects;

static unsigned bump(unsigned by) {
    g_effects += (int)by;
    return by * 2u;
}

/* ---- enumerations in every boolean context ---------------------------- */

static int enum_if(status_e s) {
    if (s) {
        return 1;
    }
    return 0;
}

static int enum_not(status_e s) {
    return !s;
}

static int enum_while(status_e s) {
    int spins = 0;
    while (s) {
        s = (status_e)(s - 1);
        spins += 1;
    }
    return spins;
}

static int enum_for(status_e s) {
    int spins = 0;
    for (; s; s = (status_e)(s - 1)) {
        spins += 1;
    }
    return spins;
}

static int enum_logical(status_e a, level_e b) {
    int both = a && b;
    int either = a || b;
    int negated = !a && !!b;
    return both * 100 + either * 10 + negated;
}

static int enum_ternary(status_e s) {
    return s ? 7 : 3;
}

/* A never-zero enumeration is always true, whichever context reads it. */
static int level_truth(level_e l) {
    int in_if = 0;
    int in_ternary = l ? 1 : 0;
    if (l) {
        in_if = 1;
    }
    return in_if * 100 + in_ternary * 10 + (!l);
}

/* An enum field read through a pointer to a struct inside an array — the shape
 * `if (dpb->buffer[i].status)` has. */
static int enum_through_pointer(struct slot *slots, int index) {
    if (slots[index].status) {
        return 1 + (slots[index].level ? 10 : 0);
    }
    return 0;
}

/* ---- enum <-> int conversions ----------------------------------------- */

static int enum_round_trip(int raw) {
    status_e s = (status_e)raw;
    int back = (int)s;
    unsigned wide = (unsigned)s;
    return back * 10 + (int)wide;
}

/* ---- `(void)` casts ---------------------------------------------------- */

static int void_casts(unsigned seed) {
    unsigned local = seed;
    int compared = 0;

    (void)local;              /* a pure variable: nothing to evaluate */
    (void)(local + 1u);       /* a pure expression */
    (void)bump(local);        /* a call: the effect must survive */
    (void)bump(local + 1u);
    compared = (int)(local != 0u);
    (void)(local == seed);    /* a comparison, discarded */
    (void)compared;
    return compared;
}

/* ---- comparisons whose operands are comparison results ----------------- */

static int comparison_operands(int a, int b, int c, int d) {
    int agree = (a < b) == (c < d);
    int flipped = !a == 0;
    int mixed = (a == b) != c;
    int chained = ((a < b) == 1) + ((a > b) == 0);
    int negated_pair = (!a) == (!b);
    return agree * 10000 + flipped * 1000 + mixed * 100 + chained * 10 + negated_pair;
}

/* ---- pointee const ----------------------------------------------------- */

static unsigned char sum_const(const unsigned char *bytes, int count) {
    unsigned char total = 0;
    int i = 0;
    for (i = 0; i < count; i++) {
        total = (unsigned char)(total + bytes[i]);
    }
    return total;
}

static int pointee_const(void) {
    unsigned char buffer[4];
    unsigned char *writable = buffer;
    const unsigned char *readable = 0;
    unsigned char *back = 0;
    int i = 0;

    for (i = 0; i < 4; i++) {
        buffer[i] = (unsigned char)(i + 1);
    }

    /* `unsigned char *` reaching a `const unsigned char *` parameter, and the
     * same value assigned to a const-qualified pointer variable. */
    if (sum_const(writable, 4) != 10) return 1;
    if (sum_const(buffer, 4) != 10) return 2;
    readable = writable;
    if (sum_const(readable, 4) != 10) return 3;

    /* And the reverse, which C spells with an explicit cast. */
    back = (unsigned char *)readable;
    back[0] = 5;
    if (buffer[0] != 5) return 4;
    if (sum_const(back, 4) != 14) return 5;
    return 0;
}

int bool_context_enum_void_runtime(void) {
    int i = 0;
    int pointer_rc = 0;

    for (i = 0; i < 4; i++) {
        g_slots[i].status = ST_UNUSED;
        g_slots[i].level = LV_LOW;
        g_slots[i].payload = i;
    }
    g_slots[2].status = ST_LONG;
    g_slots[2].level = LV_HIGH;

    if (enum_if(ST_UNUSED) != 0) return 1;
    if (enum_if(ST_SHORT) != 1) return 2;
    if (enum_not(ST_UNUSED) != 1) return 3;
    if (enum_not(ST_LONG) != 0) return 4;
    if (enum_while(ST_LONG) != 2) return 5;
    if (enum_while(ST_UNUSED) != 0) return 6;
    if (enum_for(ST_LONG) != 2) return 7;
    if (enum_for(ST_UNUSED) != 0) return 8;
    if (enum_logical(ST_UNUSED, LV_LOW) != 11) return 9;
    if (enum_logical(ST_SHORT, LV_MID) != 110) return 10;
    if (enum_ternary(ST_UNUSED) != 3) return 11;
    if (enum_ternary(ST_SHORT) != 7) return 12;
    if (level_truth(LV_LOW) != 110) return 13;
    if (level_truth(LV_HIGH) != 110) return 14;
    if (enum_through_pointer(g_slots, 0) != 0) return 15;
    if (enum_through_pointer(g_slots, 2) != 11) return 16;
    if (enum_round_trip(0) != 0) return 17;
    if (enum_round_trip(2) != 22) return 18;

    g_effects = 0;
    if (void_casts(3u) != 1) return 19;
    if (g_effects != 7) return 20;
    g_effects = 0;
    if (void_casts(0u) != 0) return 21;
    if (g_effects != 1) return 22;

    if (comparison_operands(1, 2, 3, 4) != 11121) return 23;
    if (comparison_operands(2, 1, 3, 4) != 1101) return 24;
    if (comparison_operands(0, 0, 0, 0) != 10111) return 25;

    pointer_rc = pointee_const();
    if (pointer_rc != 0) return 26 + pointer_rc;
    return 0;
}
