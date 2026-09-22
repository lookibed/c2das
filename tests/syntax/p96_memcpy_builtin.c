/* C memcpy/memmove lowered to the daslang builtin copies: constant and
 * dynamic sizes, a zero-length copy from a null source, overlapping memmove
 * in both directions, copies into and out of struct fields and 2-D arrays,
 * and the `dst` result used as a value. */
void *memcpy(void *destination, const void *source, unsigned long long count);

/* A freestanding translation unit may define its own memmove, as the h264bsd
 * shim does; its calls still reach the builtin copy, never this body. */
void *memmove(void *destination, const void *source, unsigned long long count) {
    unsigned char *out = (unsigned char *)destination;
    const unsigned char *in = (const unsigned char *)source;
    if (out < in) {
        for (unsigned long long i = 0; i < count; i++) {
            out[i] = in[i];
        }
    } else {
        for (unsigned long long i = count; i > 0; i--) {
            out[i - 1] = in[i - 1];
        }
    }
    return destination;
}

#ifndef EXPECTED_TOTAL
#define EXPECTED_TOTAL 2138367151u
#endif

struct record {
    int tag;
    unsigned char bytes[21];
    long long wide;
};

static unsigned int checksum(const unsigned char *data, unsigned long long count) {
    unsigned int sum = 2166136261u;
    for (unsigned long long i = 0; i < count; i++) {
        sum = (sum ^ data[i]) * 16777619u;
    }
    return sum;
}

static void fill(unsigned char *data, unsigned long long count, unsigned char seed) {
    for (unsigned long long i = 0; i < count; i++) {
        data[i] = (unsigned char)(seed + i * 7u);
    }
}

static int equal(const unsigned char *left, const unsigned char *right, unsigned long long count) {
    for (unsigned long long i = 0; i < count; i++) {
        if (left[i] != right[i]) {
            return 0;
        }
    }
    return 1;
}

static unsigned long long dynamic_size(int k) {
    return (unsigned long long)(k * 5 + 3);
}

/* Nonzero small values are the failed check; otherwise the checksum. */
static unsigned int memcpy_builtin_total(void) {
    unsigned char src[256];
    unsigned char dst[256];
    unsigned int total = 0;
    fill(src, 256, 11);

    /* Constant sizes. */
    fill(dst, 256, 0);
    memcpy(dst, src, 1);
    memcpy(dst + 1, src + 3, 8);
    memcpy(dst + 9, src + 17, 9);
    memcpy(dst + 18, src + 40, 16);
    memcpy(dst + 34, src + 60, 21);
    memcpy(dst + 55, src + 90, 64);
    if (dst[0] != src[0] || !equal(dst + 1, src + 3, 8) || !equal(dst + 9, src + 17, 9)
        || !equal(dst + 18, src + 40, 16) || !equal(dst + 34, src + 60, 21)
        || !equal(dst + 55, src + 90, 64)) {
        return 1;
    }
    total ^= checksum(dst, 256);
    memcpy(dst, src, 256);
    if (!equal(dst, src, 256)) {
        return 2;
    }

    /* Dynamic sizes, including the value of the call. */
    for (int k = 0; k < 20; k++) {
        unsigned long long n = dynamic_size(k);
        fill(dst, 256, (unsigned char)k);
        unsigned char *back = (unsigned char *)memcpy(dst + k, src + 2 * k, n);
        if (back != dst + k || !equal(dst + k, src + 2 * k, n)) {
            return 3;
        }
        total = total * 31u + checksum(dst, 256);
    }

    /* A zero-length copy with a null source is a no-op. */
    unsigned long long zero = 0;
    const unsigned char *nothing = 0;
    fill(dst, 256, 5);
    unsigned int before = checksum(dst, 256);
    memcpy(dst, nothing, zero);
    memmove(dst + 4, nothing, zero);
    if ((unsigned char *)memcpy(dst + 2, nothing, zero) != dst + 2 || checksum(dst, 256) != before) {
        return 4;
    }

    /* Overlapping memmove, forward and backward. */
    unsigned char ring[64];
    fill(ring, 64, 1);
    memmove(ring + 5, ring, 40);
    for (int i = 0; i < 40; i++) {
        if (ring[5 + i] != (unsigned char)(1 + i * 7)) {
            return 5;
        }
    }
    total = total * 31u + checksum(ring, 64);
    fill(ring, 64, 2);
    unsigned long long span = dynamic_size(7);
    unsigned char *moved = (unsigned char *)memmove(ring, ring + 9, span);
    for (unsigned long long i = 0; i < span; i++) {
        if (moved[i] != (unsigned char)(2 + (i + 9) * 7)) {
            return 6;
        }
    }
    total = total * 31u + checksum(ring, 64);

    /* Struct fields and whole structs. */
    struct record a;
    struct record b;
    a.tag = 7;
    fill(a.bytes, 21, 40);
    a.wide = 0x1122334455667788ll;
    memcpy(&b, &a, sizeof a);
    if (b.tag != 7 || b.wide != a.wide || !equal(b.bytes, a.bytes, 21)) {
        return 7;
    }
    memcpy(b.bytes, src + 100, sizeof b.bytes);
    memcpy(&b.wide, src + 8, sizeof b.wide);
    memcpy(dst, &b.tag, sizeof b.tag);
    total = total * 31u + checksum(b.bytes, 21) + (unsigned int)b.wide + dst[0];

    /* 2-D arrays: rows in and out. */
    unsigned char grid[6][9];
    for (int r = 0; r < 6; r++) {
        memcpy(grid[r], src + r * 9, 9);
    }
    memmove(grid[1], grid[0], 4 * 9);
    unsigned char row[9];
    memcpy(row, grid[5], sizeof row);
    total = total * 31u + checksum(&grid[0][0], sizeof grid) + checksum(row, 9);

    /* A discarded result, and a copy that only a short circuit reaches. */
    (void)memcpy(row, src + 200, 9);
    unsigned long long skipped = 0;
    if (skipped && memcpy(row, src, 9) == row) {
        return 9;
    }
    if (zero == 0 && memmove(row + 1, row, dynamic_size(1)) != row + 1) {
        return 10;
    }
    total = total * 31u + checksum(row, 9);

    return total;
}

int memcpy_builtin_runtime(void) {
    unsigned int total = memcpy_builtin_total();
    if (total < 16u) {
        return (int)total;
    }
    return total == EXPECTED_TOTAL ? 0 : 99;
}
