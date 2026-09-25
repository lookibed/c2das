/* `--libc std`: the helpers that build daslang text out of C bytes.
 *
 * The printf engine, the C-string readers (`%s`, `puts`, `strtod`'s digits)
 * and the `%.Ns` read limit each assemble a daslang string from bytes one at
 * a time.  This fixture pins the bytes they produce against glibc for the
 * shapes the other std fixtures leave out:
 *
 * - a *computed* format with `%%`, plain text and conversions, so the engine
 *   (not the translation-time format check) walks it;
 * - `strtod`, whose digits are re-read from the C string, and the end pointer
 *   it stores;
 * - `puts`, `%s` and `%.Ns` of a string with bytes above 127, which pass
 *   through unchanged, the read limit counting bytes;
 * - `isalpha` on the bytes either side of each letter range, and on `EOF`.
 *
 * Like `p81-std-printf-edge`, every libc entry point is declared here, so the
 * translation unit sees no system header.
 */

typedef unsigned long size_t;

int printf(const char *format, ...);
int snprintf(char *buffer, size_t size, const char *format, ...);
int puts(const char *s);
double strtod(const char *nptr, char **endptr);
int isalpha(int c);

static void copy_text(char *dst, const char *src) {
    while ((*dst++ = *src++) != 0) {
    }
}

int main(void) {
    char format[32];
    char buffer[32];
    char *end;
    double value;
    int count;
    static const int probes[] = {'@', 'A', 'Z', '[', '`', 'a', 'z', '{', 200, -1};
    unsigned i;

    /* A format the translator cannot see: text, `%%`, flags, width,
     * precision and a length modifier all read by the engine at run time. */
    copy_text(format, "b%%c[%+07.3ld][%-4s]\n");
    count = printf(format, 42L, "xy");
    printf("count=%d\n", count);
    copy_text(format, "[%s]%5.1f%%");
    count = snprintf(buffer, sizeof buffer, format, "xyz", 2.5);
    printf("%s|%d\n", buffer, count);

    /* The digits `strtod` converts, and where it stops. */
    copy_text(buffer, "  12.5e1xyz");
    value = strtod(buffer, &end);
    printf("strtod=%g end=%d\n", value, (int)(end - buffer));
    copy_text(buffer, "-0.25");
    value = strtod(buffer, &end);
    printf("strtod=%g end=%d\n", value, (int)(end - buffer));
    copy_text(buffer, "e5");
    value = strtod(buffer, &end);
    printf("strtod=%g end=%d\n", value, (int)(end - buffer));

    /* Bytes above 127 pass through `puts` and `%s` unchanged, and `%.5s`
     * counts bytes, not characters. */
    copy_text(buffer, "caf\xc3\xa9 \xe2\x82\xac!");
    puts(buffer);
    printf("[%s][%.5s]\n", buffer, buffer);

    /* The C locale's letters, and nothing either side of them. */
    for (i = 0; i < sizeof probes / sizeof probes[0]; i++) {
        printf("%d", isalpha(probes[i]) != 0);
    }
    printf("\n");
    return 0;
}
