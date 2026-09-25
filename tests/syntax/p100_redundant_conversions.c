/* Conversions of values whose daslang type already is the target type.  The
 * translator builds the conversion C asks for (`i` indexing an array is
 * converted to the index type, a `u32` result stored to a `u32` is converted
 * to `u32`); the module fold drops it only where the operand's declared
 * daslang type proves it is the identity, and keeps every conversion that
 * changes the type: int -> unsigned, a uint8 load widened to int, a
 * comparison's bool materialized as int, int64 -> int, a pointer's pointee
 * const.  Every value is checked against its C result. */

typedef unsigned int u32;

static const unsigned char BYTES[8] = {1, 2, 3, 250, 255, 7, 128, 9};
static int table[8] = {10, 20, 30, 40, 50, 60, 70, 80};

/* The helpers have external linkage so that they stay calls (a tiny `static`
 * helper is inlined).  A `u32` function called with `u32` arguments: its
 * result is a `u32`. */
u32 get_bits(u32 word, u32 n) {
    return word >> (32u - n);
}

/* A load through a `const` pointer is already the element type. */
unsigned char load(const unsigned char *in, int i) {
    return in[i];
}

static int sum_indexed(int n) {
    int i;
    int total = 0;
    for (i = 0; i < n; i++) {
        total += table[i];
    }
    return total;
}

/* Both arms are `unsigned char` promoted to `int`: the conversion back to
 * `unsigned char` is exact, so the arms are the result. */
unsigned char pick(unsigned char t1, unsigned char t2) {
    return t2 == 255 ? t1 : t2;
}

long long seconds(long long ns) {
    return ns / 1000000000LL;
}

static int check(long long got, long long want) {
    return got == want ? 0 : 1;
}

int redundant_conversions_runtime(void) {
    int failures = 0;
    int i = 3;
    int negative = -2;
    long long big = 5000000001LL;
    u32 word = 0xdeadbeefu;
    unsigned char b = load(BYTES, i);
    u32 bits = get_bits(word, 8u);
    u32 more = 16u * get_bits(word, 4u);
    unsigned u = (unsigned)negative;
    int widened = b;
    int less = i < negative;
    int narrowed = (int)big;
    const unsigned char *cp = BYTES;
    const int ci = i + 1;
    int from_const = table[ci];
    unsigned from_const_unsigned = ci;

    failures += check(sum_indexed(8), 360);
    failures += check(table[i], 40);
    failures += check(b, 250);
    failures += check(bits, 0xde);
    failures += check(more, 16 * 0xd);
    failures += check(pick(7, 255), 7);
    failures += check(pick(7, 9), 9);
    failures += check(seconds(big), 5);
    failures += check(u, 4294967294LL);
    failures += check(widened + 1, 251);
    failures += check(less, 0);
    failures += check(narrowed, 705032705);
    failures += check(load(cp, 4), 255);
    failures += check(from_const, 50);
    failures += check(from_const_unsigned, 4);
    return failures;
}
