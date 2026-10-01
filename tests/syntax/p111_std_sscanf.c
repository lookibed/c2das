/* `--libc std`: sscanf's integer conversions, as Doom's m_misc.c and
 * m_config.c use them, compared byte for byte with clang-18 + glibc.
 *
 * Every call reports its return value and the target, which starts at a
 * sentinel so that a failed conversion is seen to leave it unwritten. */
#include <errno.h>
#include <stdio.h>
#include <string.h>

static void scan_one(const char *input, const char *format) {
    int value = 12345;
    int r = sscanf(input, format, &value);
    printf("sscanf(\"%s\", \"%s\") = %d value=%d\n", input, format, r, value);
}

/* m_misc.c's M_StrToInt: the four literal formats, tried in order. */
static int str_to_int(const char *str, int *result) {
    return sscanf(str, " 0x%x", result) == 1 || sscanf(str, " 0X%x", result) == 1 ||
           sscanf(str, " 0%o", result) == 1 || sscanf(str, " %d", result) == 1;
}

static void doom_int(const char *str) {
    int value = -7;
    int ok = str_to_int(str, &value);
    printf("M_StrToInt(\"%s\") = %d value=%d\n", str, ok, value);
}

static const char *const inputs[] = {
    "0x1F", "  0X2a", "017", " -42", "abc", "", "   ", "0x", "123abc", "+7", "-0x10",
    "0", "08", "0xg", "-", "+", "2147483647", "4294967295", "99999999999",
    "-2147483649", "0xfffffffff", "\t\n 12",
};

int main(void) {
    int n = (int)(sizeof inputs / sizeof inputs[0]);
    for (int k = 0; k < n; k++) {
        doom_int(inputs[k]);
    }
    /* m_config.c's two formats. */
    for (int k = 0; k < n; k++) {
        scan_one(inputs[k], "%x");
        scan_one(inputs[k], "%i");
    }
    scan_one("-1", "%u");
    scan_one("777", "%o");
    scan_one("0x0x5", " 0x%x");
    scan_one("0XAB", "%X");

    /* Ordinary bytes, `%%`, white space and several conversions. */
    int a = 1, b = 2;
    int r = sscanf("  %5", "%%%d", &a);
    printf("%%%%%%d on \"  %%5\": %d a=%d\n", r, a);
    r = sscanf("", "%%%d", &a);
    printf("%%%%%%d on \"\": %d\n", r);
    r = sscanf("a", "b%d", &a);
    printf("b%%d on \"a\": %d\n", r);
    r = sscanf("", "b%d", &a);
    printf("b%%d on \"\": %d\n", r);
    r = sscanf("", "", &a);
    printf("empty format: %d\n", r);
    a = 1;
    r = sscanf("1 z", "%d %d", &a, &b);
    printf("\"1 z\": %d a=%d b=%d\n", r, a, b);
    r = sscanf("1 ", "%d %d", &a, &b);
    printf("\"1 \": %d a=%d b=%d\n", r, a, b);
    r = sscanf("x=3,y=-4", "x=%d,y=%d", &a, &b);
    printf("\"x=3,y=-4\": %d a=%d b=%d\n", r, a, b);
    r = sscanf("10:20", "%d:%x", &a, &b);
    printf("\"10:20\": %d a=%d b=%d\n", r, a, b);

    /* Overflow saturates as strtol does, reports ERANGE, stores 32 bits. */
    errno = 0;
    r = sscanf("99999999999999999999999", "%d", &a);
    printf("overflow: %d a=%d erange=%d\n", r, a, errno == ERANGE);
    errno = 0;
    r = sscanf("99999999999", "%d", &a);
    printf("wide: %d a=%d errno=%d\n", r, a, errno);

    /* A computed format with the supported conversions. */
    char format[16];
    strcpy(format, "%d");
    strcat(format, " %i");
    r = sscanf("  21 0x15", format, &a, &b);
    printf("computed \"%s\": %d a=%d b=%d\n", format, r, a, b);
    return 0;
}
