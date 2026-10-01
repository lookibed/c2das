/* `switch` dispatch shapes.
 *
 * A dense range of cases is one bounds test and a computed `goto` into a run
 * of label numbers (holes go to the default arm), a sparse set is split at its
 * median value, and a run of at most four cases is an `if`/`elif` chain.  None
 * of them nests one level per case, which a 256-case `switch` needs for
 * daslang's AOT C++ to stay inside clang's bracket-nesting limit (binjgb's
 * CB-prefixed opcode `switch`).  Every function checks the arm each value
 * reaches, fall-through, a `default` in the middle, holes, wrapped case
 * constants and 64-bit scrutinees. */
#include <stdio.h>

#define C(k) case (k): acc = acc * 31u + (unsigned)(k) + 1u; break;
#define C4(k) C(k) C((k) + 1) C((k) + 2) C((k) + 3)
#define C16(k) C4(k) C4((k) + 4) C4((k) + 8) C4((k) + 12)
#define C64(k) C16(k) C16((k) + 16) C16((k) + 32) C16((k) + 48)

/* All 256 values of a byte, no default. */
static unsigned dense256(unsigned char op, unsigned acc) {
    switch (op) {
        C64(0) C64(64) C64(128) C64(192)
    }
    return acc;
}

/* Holes and a `default` in the middle that falls through into a case. */
static int holes(int x) {
    int r = 0;
    switch (x) {
    case 10: r += 1;
    case 11: r += 2; break;
    case 13: r += 4; break;
    default: r += 100;
    case 14: r += 8; break;
    case 16: r += 16;
    case 17: r += 32; break;
    case 18: return -18;
    }
    return r;
}

/* A sparse set of negative and positive values: split at the median. */
static int sparse(long v) {
    switch (v) {
    case -1000000: return 1;
    case -5000: return 2;
    case -7: return 3;
    case 0: return 4;
    case 9: return 5;
    case 300: return 6;
    case 70000: return 7;
    case 2000000000: return 8;
    default: return 0;
    }
}

/* An unsigned scrutinee: `case -1` is UINT_MAX, and a table starting at 0
 * needs no lower bound. */
static int unsigned_cases(unsigned u) {
    switch (u) {
    case 0: return 10;
    case 1: return 11;
    case 2: return 12;
    case 4: return 14;
    case 5: return 15;
    case -1: return 99;
    default: return -1;
    }
}

/* 64-bit scrutinees far from zero. */
static int wide(unsigned long long w, long long s) {
    int r = 0;
    switch (w) {
    case 0xFFFFFFFF00000000ull: r = 1; break;
    case 0xFFFFFFFF00000001ull: r = 2; break;
    case 0xFFFFFFFF00000002ull: r = 3; break;
    case 0xFFFFFFFF00000004ull: r = 4; break;
    case 0xFFFFFFFF00000005ull: r = 5; break;
    }
    switch (s) {
    case -9000000000ll: r += 10; break;
    case -8999999999ll: r += 20; break;
    case -8999999998ll: r += 30; break;
    case -8999999997ll: r += 40; break;
    case -8999999996ll: r += 50; break;
    }
    return r;
}

static int g_seen;

/* A `void` function ending in a dense `switch`: a hole and an empty case
 * fall off the end of the function. */
static void record(int k) {
    switch (k) {
    case 1: g_seen += 1; break;
    case 2: g_seen += 2; break;
    case 3: break;
    case 5: g_seen += 5; break;
    case 6: g_seen += 6; break;
    }
}

/* A `void` function whose last laid-out arm is a bare `return`: that arm is
 * reached through the jump table, and a label above nothing but the closing
 * `return` cannot be jumped to, so the table sends it to a `return` at the
 * top of the body. */
static void early_out(int k) {
    switch (k) {
    case 1: g_seen += 10; break;
    case 2: g_seen += 20; break;
    case 3: g_seen += 30; break;
    case 4: g_seen += 40; break;
    case 5: return;
    }
    g_seen += 1000;
}

/* Duff's device: the cases sit inside a loop body. */
static int duff(int count) {
    int n = (count + 3) / 4, copied = 0;
    switch (count % 4) {
    case 0: do { copied++;
    case 3:      copied++;
    case 2:      copied++;
    case 1:      copied++;
            } while (--n > 0);
    }
    return copied;
}

int main(void) {
    unsigned acc = 7u;
    for (int i = 0; i < 1000; i++) {
        acc = dense256((unsigned char)(acc >> 3), acc);
    }
    printf("dense256=%u\n", acc);

    printf("holes");
    for (int x = 8; x <= 20; x++) {
        printf(" %d", holes(x));
    }
    printf("\n");

    long probes[] = {-1000000, -999999, -5000, -7, -6, 0, 9, 10, 300, 70000, 2000000000, -2000000000};
    printf("sparse");
    for (unsigned i = 0; i < sizeof probes / sizeof probes[0]; i++) {
        printf(" %d", sparse(probes[i]));
    }
    printf("\n");

    printf("unsigned %d %d %d %d %d %d %d\n", unsigned_cases(0), unsigned_cases(2),
           unsigned_cases(3), unsigned_cases(5), unsigned_cases(6), unsigned_cases(0xFFFFFFFFu),
           unsigned_cases(0xFFFFFFFEu));

    printf("wide %d %d %d %d\n", wide(0xFFFFFFFF00000000ull, -9000000000ll),
           wide(0xFFFFFFFF00000005ull, -8999999996ll), wide(0xFFFFFFFF00000003ull, -8999999995ll),
           wide(5ull, -8999999998ll));

    for (int k = 0; k <= 7; k++) {
        record(k);
    }
    printf("record=%d\n", g_seen);
    g_seen = 0;
    for (int k = 0; k <= 6; k++) {
        early_out(k);
    }
    printf("early_out=%d\n", g_seen);

    printf("duff %d %d %d %d %d\n", duff(1), duff(4), duff(5), duff(7), duff(8));
    return 0;
}
