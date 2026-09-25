/* Constant conversions folded to literals of their daslang target type: each
 * value below is a C constant converted to another integer or real type, so
 * the translation prints it as one literal of that type.  The narrowing, sign
 * and wrap-around cases must keep the exact C result, and a size argument
 * narrowed by a cast must keep the narrowing (`(unsigned char)260` is 4). */
void *memset(void *destination, int value, unsigned long long count);

static int check(long long got, long long want) {
    return got == want ? 0 : 1;
}

int constant_conversions_runtime(void) {
    unsigned char narrowed = (unsigned char)300;
    signed char negative_byte = (signed char)0xff;
    unsigned int wrapped = (unsigned int)-1;
    unsigned long long wide = (unsigned long long)-1;
    unsigned long long from_int_min = (unsigned long long)(-2147483647 - 1);
    int int_min = -2147483647 - 1;
    int from_unsigned = (int)0x80000000u;
    long long ll_min = (long long)0x8000000000000000ull;
    short short_wrap = (short)70000;
    unsigned short ushort_wrap = (unsigned short)-2;
    unsigned char hex_byte = 0xab;
    unsigned int mask = 0xff000000u >> 24;
    unsigned long long shifted = 0xffull << 8;
    long long negative_wide = -5;
    double real = 3;
    float single = 16777217;
    char letter = 'A';
    signed char high_char = '\xff';
    unsigned char bytes[8] = {1, 1, 1, 1, 1, 1, 1, 1};
    int failures = 0;

    failures += check(narrowed, 44);
    failures += check(negative_byte, -1);
    failures += check(wrapped == 4294967295u, 1);
    failures += check(wide == 18446744073709551615ull, 1);
    failures += check(from_int_min == 18446744071562067968ull, 1);
    failures += check(int_min, -2147483647ll - 1);
    failures += check(from_unsigned, -2147483647ll - 1);
    failures += check(ll_min == -9223372036854775807ll - 1, 1);
    failures += check(short_wrap, 4464);
    failures += check(ushort_wrap, 65534);
    failures += check(hex_byte, 171);
    failures += check(mask, 255);
    failures += check(shifted == 65280ull, 1);
    failures += check(negative_wide, -5);
    failures += check(real == 3.0, 1);
    failures += check(single == 16777216.0f, 1);
    failures += check(letter, 65);
    failures += check(high_char, -1);

    memset(bytes, 0, (unsigned char)260);
    failures += check(bytes[3], 0);
    failures += check(bytes[4], 1);
    return failures;
}
