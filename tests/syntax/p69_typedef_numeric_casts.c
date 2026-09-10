/* Audit acceptance: casts whose target is a typedef'd scalar type.
 *
 * `(size_t)u` is a *conversion* — it reads the 4-byte `unsigned` and
 * produces the same number as a 64-bit value.  Spelling it as a bit
 * reinterpretation instead reads eight bytes out of a four-byte local and
 * returns whatever follows it in memory, which is silent corruption: the
 * program keeps running with a wrong number.  Every check below is written
 * so that a reinterpretation gives a visibly different answer.
 *
 * `(uintptr_t)p` is the one shape here that really is a reinterpretation:
 * it exposes a pointer's address as an integer.  It stays in the case so
 * that a fix which turns *every* cast into a conversion fails too.
 *
 * Returns 0 on success, N for the N-th failed check.
 */

#include <stddef.h>
#include <stdint.h>

typedef size_t my_size;          /* user alias of an alias */
typedef unsigned long my_ulong;  /* user alias of a builtin */

typedef enum {
    COLOR_NONE = 0,
    COLOR_RED = 1,
    COLOR_BLUE = 7
} color_t;

static size_t widen_unsigned(unsigned u) {
    return (size_t)u + 1;
}

static my_size widen_via_user_alias(unsigned u) {
    return (my_size)u;
}

static my_ulong widen_via_builtin_alias(unsigned u) {
    return (my_ulong)u;
}

static uint32_t narrow_from_int64(int64_t v) {
    return (uint32_t)v;
}

static int16_t narrow_to_int16(unsigned u) {
    return (int16_t)u;
}

static ptrdiff_t pointer_span(int *first, int *last) {
    return (ptrdiff_t)(last - first);
}

static uintptr_t expose_address(void *p) {
    return (uintptr_t)p;
}

static float size_to_float(size_t s) {
    return (float)s;
}

static size_t double_to_size(double d) {
    return (size_t)d;
}

/* An implicit `unsigned -> size_t` conversion happens at the argument. */
static size_t identity_size(size_t s) {
    return s;
}

/* `size_t` arithmetic narrowed back to `int` on the way out. */
static int size_sum_as_int(size_t a, size_t b) {
    return (int)(a + b);
}

static int color_as_int(color_t c) {
    return (int)c;
}

int typedef_numeric_casts_runtime(void) {
    unsigned u = 0xFFFFFFFFu;

    /* 4294967295 + 1, not a 64-bit read over a 32-bit local. */
    if (widen_unsigned(u) != 4294967296ull) return 1;
    if (widen_via_user_alias(u) != 4294967295ull) return 2;
    if (widen_via_builtin_alias(u) != 4294967295ull) return 3;

    if (narrow_from_int64(0x1122334455667788LL) != 0x55667788u) return 4;
    if (narrow_to_int16(0x1234FFFFu) != (int16_t)-1) return 5;

    int arr[8];
    for (int i = 0; i < 8; i++) arr[i] = i;
    if (pointer_span(&arr[1], &arr[5]) != 4) return 6;
    if (pointer_span(&arr[5], &arr[1]) != -4) return 7;

    /* A pointer exposed as an integer must round-trip to itself, and two
     * different elements must expose different addresses. */
    uintptr_t a0 = expose_address(&arr[0]);
    uintptr_t a0_again = expose_address(&arr[0]);
    uintptr_t a1 = expose_address(&arr[1]);
    if (a0 != a0_again) return 8;
    if (a0 == a1) return 9;
    if (a1 - a0 != sizeof(int)) return 10;

    if (size_to_float((size_t)3) != 3.0f) return 11;
    if (double_to_size(7.9) != 7) return 12;

    /* Implicit unsigned -> size_t at the call, then back down to int. */
    if (identity_size(u) != 4294967295ull) return 13;
    if (size_sum_as_int((size_t)10, (size_t)5) != 15) return 14;

    /* size_t arithmetic that overflows 32 bits must stay 64-bit. */
    size_t big = (size_t)u * (size_t)2;
    if (big != 8589934590ull) return 15;
    if ((int)(big & 0xFFFFu) != 0xFFFE) return 16;

    /* A typedef'd enumeration converted back to int. */
    color_t c = COLOR_BLUE;
    if (color_as_int(c) != 7) return 17;
    if (color_as_int(COLOR_NONE) != 0) return 18;

    /* size_t used as a loop counter, narrowed for the checksum. */
    size_t total = 0;
    for (size_t i = 0; i < 8; i++) total += (size_t)arr[i];
    if ((int)total != 28) return 19;

    return 0;
}
