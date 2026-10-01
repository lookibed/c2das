/* `--libc std`: strdup, strcasecmp/strncasecmp, atof, abs, fabs, and the
 * process entry points system and mkdir.
 *
 * Everything printed here is what clang-18 + glibc prints too.  system and
 * mkdir are called but their results are not printed: the std helpers are a
 * hosted implementation without a command processor and without directory
 * creation, which real glibc is not (see the ptr_tests assertions on the
 * generated helpers). */
#include <errno.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <sys/stat.h>
#include <sys/types.h>

/* Bytes outside printable ASCII are printed as `\xNN`, so the output is text. */
static void put_text(const char *s) {
    for (; *s != '\0'; ++s) {
        unsigned char c = (unsigned char)*s;
        if (c < 0x20 || c >= 0x7f) {
            printf("\\x%02x", c);
        } else {
            printf("%c", c);
        }
    }
}

static void show_case(const char *a, const char *b) {
    printf("strcasecmp(\"");
    put_text(a);
    printf("\", \"");
    put_text(b);
    printf("\") = %d\n", strcasecmp(a, b));
}

static void show_ncase(const char *a, const char *b, size_t n) {
    printf("strncasecmp(\"");
    put_text(a);
    printf("\", \"");
    put_text(b);
    printf("\", %d) = %d\n", (int)n, strncasecmp(a, b, n));
}

static void show_atof(const char *s) {
    printf("atof(\"%s\") = %.17g\n", s, atof(s));
}

static void show_fabs(double x) {
    double y = fabs(x);
    printf("fabs(%g) = %g signbit=%d inverse=%g\n", x, y, signbit(y) != 0, 1.0 / y);
}

int main(void) {
    const char *original = "Doom II: Hell on Earth";
    char *copy = strdup(original);
    printf("strdup: \"%s\" len=%d distinct=%d\n", copy, (int)strlen(copy), copy != original);
    copy[0] = 'd';
    printf("after edit: copy=\"%s\" original=\"%s\"\n", copy, original);
    free(copy);
    char *empty = strdup("");
    printf("strdup(\"\"): len=%d first=%d\n", (int)strlen(empty), empty[0]);
    free(empty);

    show_case("doom", "DOOM");
    show_case("abc", "ABD");
    show_case("Z", "a");
    show_case("[", "a");
    show_case("", "x");
    show_case("x", "");
    show_case("a\x80", "A\x01");
    show_case("\xff", "\xfe");
    show_case("IWAD", "iwadx");
    show_ncase("abcX", "ABCy", 3);
    show_ncase("abcX", "ABCy", 4);
    show_ncase("a", "b", 0);
    show_ncase("same", "SAME", 100);
    show_ncase("aB", "Ab\x90", 3);

    show_atof("  1.5e3xyz");
    show_atof("-0.25");
    show_atof("junk");
    show_atof("\t+42");
    show_atof("7e-3");
    show_atof("");
    printf("atof literal = %g\n", atof("  -3.75e1"));

    printf("abs: %d %d %d %d\n", abs(-5), abs(0), abs(17), abs(-2147483647));
    show_fabs(-2.5);
    show_fabs(2.5);
    show_fabs(-0.0);
    show_fabs(0.0);
    show_fabs(-1e300);

    /* Called for their helpers; their results differ from real glibc's. */
    (void)system(NULL);
    (void)system("true");
    (void)mkdir("p110_never_created", 0755);
    errno = 0;
    printf("done\n");
    return 0;
}
