/* Audit acceptance: pointer-offset typing.  A C pointer-offset expression is
 * `(p + a) + b`, two separate pointer/integer additions, and each offset keeps
 * its own C type and C arithmetic (unsigned wraps in the operand's type)
 * before it becomes a pointer offset.  Every check returns 0 on success and a
 * distinct non-zero number on failure. */

#include <stddef.h>
#include <stdint.h>

static unsigned char bytes[64];
static int words[32];

static void fill(void) {
    unsigned i;
    for (i = 0; i < 64; i++) {
        bytes[i] = (unsigned char)(i * 3u + 1u);
    }
    for (i = 0; i < 32; i++) {
        words[i] = (int)i * 7 - 5;
    }
}

/* pointer + size_t + size_t, the pl_mpeg shape. */
static unsigned char *byte_at_sizes(unsigned char *base, size_t a, size_t b) {
    return base + a + b;
}

/* pointer + unsigned*unsigned + unsigned, the h264bsd shape. */
static unsigned char *byte_at_row(unsigned char *data, unsigned y, unsigned x) {
    return data + y * 8u + x;
}

/* pointer + int + size_t on a wider element type. */
static int *word_at_mixed(int *p, int a, size_t b) {
    return p + a + b;
}

/* pointer - unsigned, and a chained pointer subtraction. */
static unsigned char *byte_back(unsigned char *p, unsigned a, unsigned b) {
    return p - a - b;
}

static int check_size_t_chain(void) {
    size_t luma = 20;
    size_t chroma = 7;
    unsigned char *p = byte_at_sizes(bytes, luma, chroma);
    if (*p != bytes[27]) {
        return 1;
    }
    if (p != bytes + 27) {
        return 2;
    }
    return 0;
}

static int check_unsigned_chain(void) {
    unsigned y = 5;
    unsigned x = 3;
    unsigned char *p = byte_at_row(bytes, y, x);
    if (*p != bytes[43]) {
        return 3;
    }
    return 0;
}

static int check_mixed_int_size_t(void) {
    int a = 4;
    size_t b = 9;
    int *p = word_at_mixed(words, a, b);
    if (*p != words[13]) {
        return 4;
    }
    /* Element scaling: the distance is in elements, not bytes. */
    if ((p - words) != 13) {
        return 5;
    }
    return 0;
}

static int check_pointer_subtraction(void) {
    unsigned char *p = byte_back(bytes + 40, 6u, 4u);
    if (p != bytes + 30) {
        return 6;
    }
    if (*p != bytes[30]) {
        return 7;
    }
    return 0;
}

/* The offset is computed in `unsigned`, where C defines the wrap-around, and
 * only the wrapped result becomes a pointer offset.  `u - 1u` with `u == 0` is
 * UINT_MAX, so the division below yields 4 in unsigned arithmetic and would
 * yield 0 if the subtraction were (wrongly) performed in int64. */
static int check_unsigned_wrap_offset(void) {
    unsigned u = 0;
    unsigned offset = (u - 1u) / 1000000000u; /* 4294967295u / 1e9 == 4 */
    unsigned char *p = bytes + offset;
    if (offset != 4u) {
        return 8;
    }
    if (*p != bytes[4]) {
        return 9;
    }
    /* Same wrap inside the pointer expression itself. */
    if (bytes + (u - 1u) / 1000000000u + 1u != bytes + 5) {
        return 10;
    }
    return 0;
}

/* unsigned char and int64_t offsets, plus a subscript whose index is a whole
 * unsigned expression. */
static int check_narrow_and_wide_offsets(void) {
    unsigned char small = 12;
    int64_t wide = 9;
    unsigned char *p = bytes + small + wide;
    if (p != bytes + 21) {
        return 11;
    }
    if (*p != bytes[21]) {
        return 12;
    }
    {
        unsigned a = 6;
        unsigned b = 11;
        if (bytes[a + b] != bytes[17]) {
            return 13;
        }
    }
    {
        int s = 20;
        unsigned t = 3;
        /* `s - t` is unsigned: 17, then used as a pointer offset. */
        if (*(bytes + (s - t)) != bytes[17]) {
            return 14;
        }
    }
    return 0;
}

/* Compound assignment and increment on pointers. */
static int check_compound_and_increment(void) {
    unsigned a = 5;
    unsigned b = 6;
    size_t wide = 6;
    unsigned char *p = bytes;
    int *w = words;

    p += a + b;
    if (p != bytes + 11) {
        return 15;
    }
    p -= a;
    if (p != bytes + 6) {
        return 16;
    }
    p++;
    if (*p != bytes[7]) {
        return 17;
    }
    --p;
    if (p != bytes + 6) {
        return 18;
    }
    w += wide;
    if (*w != words[6]) {
        return 19;
    }
    w -= (int)a;
    if (w != words + 1) {
        return 20;
    }
    return 0;
}

static int check_two_pointer_distance(void) {
    int *a = words + 3;
    int *b = words + 28;
    ptrdiff_t d = b - a;
    if (d != 25) {
        return 21;
    }
    if (d / 5 != 5) {
        return 22;
    }
    if ((a - b) != -25) {
        return 23;
    }
    return 0;
}

int pointer_offset_types_runtime(void) {
    int rc;
    fill();
    rc = check_size_t_chain();
    if (rc) {
        return rc;
    }
    rc = check_unsigned_chain();
    if (rc) {
        return rc;
    }
    rc = check_mixed_int_size_t();
    if (rc) {
        return rc;
    }
    rc = check_pointer_subtraction();
    if (rc) {
        return rc;
    }
    rc = check_unsigned_wrap_offset();
    if (rc) {
        return rc;
    }
    rc = check_narrow_and_wide_offsets();
    if (rc) {
        return rc;
    }
    rc = check_compound_and_increment();
    if (rc) {
        return rc;
    }
    rc = check_two_pointer_distance();
    if (rc) {
        return rc;
    }
    return 0;
}
