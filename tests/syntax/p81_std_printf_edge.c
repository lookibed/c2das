/* `--libc std`: the printf conversion corners, the C `argv` shape and the
 * stream calls whose failure a C program is entitled to see.
 *
 * Like `p72-std-file-io`, the fixture declares every libc entry point it uses
 * itself, so the translation unit never sees a system header: what the
 * translator has to replace is exactly this list of body-less external
 * declarations.
 *
 * Every line here is pinned against glibc, because glibc is what a C program
 * that was written against `printf(3)` observed.  The corners are: a precision
 * on an integer conversion (minimum digits, zero-filled, and nothing at all
 * for `%.0d` of zero), `+`/space on an unsigned conversion (no sign, ever),
 * `%p`, `*` width and `.*` precision, `%.Ns` as a read limit, `%s` of a null
 * pointer, the byte count of a conversion that produces a NUL byte, the null
 * terminator C promises at `argv[argc]`, `fseek` past the front of a file,
 * `fflush(NULL)`, an `fopen` mode carrying a glibc extension letter, and
 * `errno` after a conversion that overflowed.
 *
 * The NUL byte of `%c` of `'\0'` is deliberately *counted* and not printed:
 * a daslang string is NUL-terminated storage and cannot carry the byte, so
 * `snprintf`'s return value is what both implementations agree on.  Printing
 * it would be comparing a byte the translated module cannot produce.
 */

typedef unsigned long size_t;
typedef struct FILE FILE;

extern FILE *stdout;

int printf(const char *format, ...);
int snprintf(char *buffer, size_t size, const char *format, ...);
int fflush(FILE *stream);
FILE *fopen(const char *path, const char *mode);
int fclose(FILE *stream);
int fseek(FILE *stream, long offset, int whence);
long ftell(FILE *stream);
long long strtoll(const char *nptr, char **endptr, int base);
int *__errno_location(void);

#define errno (*__errno_location())

int main(int argc, char **argv) {
    char buffer[16];
    FILE *stream;
    long long converted;
    int count;
    int seek_failed;
    long told;

    /* A precision on an integer conversion is a minimum digit count, and
     * `%.0d` of zero prints nothing at all. */
    printf("[%.5d][%5.2d][%.0d][%.0d]\n", 42, 7, 0, 5);
    printf("[%.8x][%.3u][%#.5x][%#.3o][%#.1o]\n", 255u, 7u, 1u, 8u, 8u);
    /* `+` and space say nothing about an unsigned conversion. */
    printf("[%+u][% x][%+x][%+o][% u]\n", 5u, 255u, 255u, 8u, 5u);
    /* A precision makes the `0` flag inoperative; `#` of zero adds nothing. */
    printf("[%05.2d][%-8.5d][%.20d][%#x][%#o]\n", 3, 42, -5, 0u, 0u);
    /* `%p` is `0x` and lowercase hexadecimal, `(nil)` for a null pointer. */
    printf("[%p][%p]\n", (void *)0x1234, (void *)0);
    /* `*` and `.*` each take an `int` of their own, ahead of the value; a
     * negative `*` width is a left-adjusted field. */
    printf("[%*d][%-*d][%*d]\n", 6, 42, 6, 42, -6, 42);
    printf("[%.*f][%.*s][%.*d][%d]\n", 3, 1.5, 2, "abcdef", 4, 7, 9);
    /* A string precision is a read limit, applied before the field width. */
    printf("[%.3s][%5.2s][%-5.2s][%.0s][%10s]\n", "abcdef", "abcdef", "abcdef",
           "abcdef", "ab");
    /* glibc prints `(null)`, or nothing when the precision cannot hold it. */
    printf("[%s][%.3s][%.6s][%10s]\n", (char *)0, (char *)0, (char *)0,
           (char *)0);

    /* `%c` of `'\0'` is one byte of output, and the return value counts it. */
    count = snprintf(buffer, sizeof buffer, "a%cb", 0);
    printf("nul_count=%d\n", count);

    /* C guarantees `argv[argc] == NULL`, and `argc` counts the program plus
     * the arguments the launcher was given. */
    printf("argc=%d argv_end=%d argv0=%d\n", argc, argv[argc] == 0,
           argv[0] != 0);

    /* `fflush(NULL)` flushes every output stream and reports success. */
    printf("fflush_all=%d\n", fflush(0));

    /* glibc accepts extension letters in the mode; `e` is close-on-exec. */
    stream = fopen(argv[argc - 1], "rbe");
    if (stream == 0) {
        printf("open_failed\n");
        return 1;
    }
    /* Seeking in front of the first byte fails, and the position is unmoved. */
    seek_failed = fseek(stream, -100L, 0) < 0;
    told = ftell(stream);
    printf("seek_failed=%d told=%ld\n", seek_failed, (long)told);
    fclose(stream);

    /* A conversion that overflowed leaves ERANGE behind. */
    errno = 0;
    converted = strtoll("99999999999999999999999", 0, 10);
    printf("strtoll=%lld errno=%d\n", converted, errno);
    errno = 0;
    converted = strtoll("10", 0, 37);
    printf("strtoll_base=%lld errno=%d\n", converted, errno);
    return 0;
}
