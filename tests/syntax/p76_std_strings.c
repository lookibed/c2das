/* `--libc std`: the NUL-terminated string family, string -> integer
 * conversion, `errno`, the ctype predicates and the remaining stream and
 * formatting entry points.
 *
 * Like `p72-std-file-io`, the fixture declares every libc entry point it uses
 * itself, so the translation unit never sees a system header: what the
 * translator has to replace is exactly this list of body-less external
 * declarations.  glibc reaches `errno` through `__errno_location()` — its
 * `errno` data symbol is `GLIBC_PRIVATE` — so that function, not a variable,
 * is the ABI a C program actually names, and it is what the table replaces.
 *
 * `abort` is declared and called on a path this program never takes: the
 * helper is emitted and type-checked, but a C reference that really aborted
 * would die of SIGABRT while the daslang module can only exit, and the two
 * process statuses are not comparable.
 */

typedef unsigned long size_t;
typedef struct FILE FILE;
typedef __builtin_va_list va_list;
#define va_start(ap, last) __builtin_va_start(ap, last)
#define va_end(ap) __builtin_va_end(ap)

extern FILE *stdout;
extern FILE *stderr;

int printf(const char *format, ...);
int fprintf(FILE *stream, const char *format, ...);
int snprintf(char *buffer, size_t size, const char *format, ...);
int vsnprintf(char *buffer, size_t size, const char *format, va_list ap);
int puts(const char *s);
int fputs(const char *s, FILE *stream);
int putchar(int c);
size_t fwrite(const void *buffer, size_t size, size_t count, FILE *stream);
void abort(void);

size_t strlen(const char *s);
int strcmp(const char *a, const char *b);
int strncmp(const char *a, const char *b, size_t n);
char *strcpy(char *dst, const char *src);
char *strncpy(char *dst, const char *src, size_t n);
char *strcat(char *dst, const char *src);
char *strchr(const char *s, int c);
char *strrchr(const char *s, int c);
char *strstr(const char *haystack, const char *needle);

long strtol(const char *nptr, char **endptr, int base);
long long strtoll(const char *nptr, char **endptr, int base);
unsigned long strtoul(const char *nptr, char **endptr, int base);
unsigned long long strtoull(const char *nptr, char **endptr, int base);
int atoi(const char *nptr);

int isspace(int c);
int isdigit(int c);
int isalpha(int c);
int isalnum(int c);
int isupper(int c);
int islower(int c);
int isprint(int c);
int isxdigit(int c);
int tolower(int c);
int toupper(int c);

int *__errno_location(void);
#define errno (*__errno_location())
#define ERANGE 34
#define EINVAL 22

static char buffer[64];
static char scratch[16];
static int never;

/* `strcmp` only promises the sign of its answer. */
static int sign_of(int v) {
	if (v < 0) return -1;
	if (v > 0) return 1;
	return 0;
}

/* A found pointer as an offset, so the comparison never prints an address. */
static int offset_of(const char *base, const char *found) {
	if (found == 0) return -1;
	return (int)(found - base);
}

/* The ctype predicates return "nonzero", not "1". */
static int truth_of(int v) {
	return v != 0;
}

/* The `v*printf` half of the format engine, reached through a `va_list`
 * parameter (see `p75-va-list-parameter`). */
static int format_into(char *dst, size_t size, const char *format, ...) {
	va_list ap;
	int n;
	va_start(ap, format);
	n = vsnprintf(dst, size, format, ap);
	va_end(ap);
	return n;
}

int std_strings_runtime(void) {
	const char *hello = "hello";
	const char *empty = "";
	const char *sentence = "the quick brown fox";
	char *end;
	long long signed_value;
	unsigned long long unsigned_value;
	int i;
	int n;

	/* 1. lengths and comparisons. */
	printf("strlen=%d,%d,%d\n", (int)strlen(hello), (int)strlen(empty),
	       (int)strlen("hello world"));
	printf("strcmp=%d,%d,%d,%d\n", sign_of(strcmp(hello, "hello")),
	       sign_of(strcmp("abc", "abd")), sign_of(strcmp("abd", "abc")),
	       sign_of(strcmp("abc", "abcd")));
	printf("strncmp=%d,%d,%d\n", sign_of(strncmp("abcdef", "abcxyz", 3u)),
	       sign_of(strncmp("abcdef", "abcxyz", 4u)),
	       sign_of(strncmp("abc", "abc", 10u)));

	/* 2. copies. */
	strcpy(buffer, "hello");
	printf("strcpy=[%s] len=%d\n", buffer, (int)strlen(buffer));
	strcat(buffer, ", world");
	printf("strcat=[%s] len=%d\n", buffer, (int)strlen(buffer));

	/* `strncpy` pads with NUL and does not terminate a truncated copy. */
	for (i = 0; i < 8; i++) {
		scratch[i] = 'Z';
	}
	strncpy(scratch, "abc", 6u);
	printf("strncpy=");
	for (i = 0; i < 8; i++) {
		putchar(scratch[i] == 0 ? '.' : scratch[i]);
	}
	printf("\n");
	strncpy(scratch, "abcdefgh", 4u);
	scratch[4] = 0;
	printf("strncpy_trunc=[%s]\n", scratch);

	/* 3. searches, as offsets. */
	printf("strchr=%d,%d,%d\n", offset_of(sentence, strchr(sentence, 'q')),
	       offset_of(sentence, strchr(sentence, 'Z')),
	       offset_of(sentence, strchr(sentence, 0)));
	printf("strrchr=%d,%d,%d\n", offset_of(sentence, strrchr(sentence, 'o')),
	       offset_of(sentence, strrchr(sentence, 't')),
	       offset_of(sentence, strrchr(sentence, 'Z')));
	printf("strstr=%d,%d,%d,%d\n", offset_of(sentence, strstr(sentence, "brown")),
	       offset_of(sentence, strstr(sentence, "the")),
	       offset_of(sentence, strstr(sentence, "cat")),
	       offset_of(sentence, strstr(sentence, "")));

	/* 4. string -> integer, with the end pointer and the base prefix. */
	errno = 0;
	signed_value = strtoll("  -0x1f", &end, 0);
	printf("strtoll_hex=%lld end=%d errno=%d\n", signed_value,
	       offset_of("  -0x1f", end), errno);

	errno = 0;
	signed_value = strtoll("123abc", &end, 0);
	printf("strtoll_tail=%lld end=%d errno=%d\n", signed_value,
	       offset_of("123abc", end), errno);

	errno = 0;
	signed_value = strtoll("  zz", &end, 0);
	printf("strtoll_none=%lld end=%d errno=%d\n", signed_value,
	       offset_of("  zz", end), errno);

	errno = 0;
	signed_value = strtoll("0xzz", &end, 16);
	printf("strtoll_bare=%lld end=%d errno=%d\n", signed_value,
	       offset_of("0xzz", end), errno);

	printf("strtoll_bases=%lld,%lld,%lld,%lld\n", strtoll("0755", 0, 0),
	       strtoll("ff", 0, 16), strtoll("z", 0, 36), strtoll("+2024", 0, 10));

	/* Overflow saturates and reports ERANGE. */
	errno = 0;
	signed_value = strtoll("99999999999999999999", &end, 10);
	printf("strtoll_over=%lld erange=%d\n", signed_value, errno == ERANGE);

	errno = 0;
	signed_value = strtoll("-99999999999999999999", 0, 10);
	printf("strtoll_under=%lld erange=%d\n", signed_value, errno == ERANGE);

	errno = 0;
	unsigned_value = strtoull("99999999999999999999", 0, 10);
	printf("strtoull_over=%llu erange=%d\n", unsigned_value, errno == ERANGE);

	errno = 0;
	unsigned_value = strtoull("18446744073709551615", 0, 10);
	printf("strtoull_max=%llu errno=%d\n", unsigned_value, errno);

	/* An invalid base converts nothing and reports EINVAL.  glibc leaves the
	 * end pointer untouched in this case, so it is not printed. */
	errno = 0;
	signed_value = strtoll("10", &end, 37);
	printf("strtoll_base37=%lld einval=%d\n", signed_value, errno == EINVAL);

	printf("strtol=%ld,%lu,%d\n", strtol("-2147483648", 0, 10),
	       strtoul("4294967296", 0, 10), atoi("  -42xyz"));

	/* 5. ctype, in the C locale. */
	printf("isspace=%d%d%d%d\n", truth_of(isspace(' ')), truth_of(isspace('\t')),
	       truth_of(isspace('\n')), truth_of(isspace('x')));
	printf("isdigit=%d%d isalpha=%d%d isalnum=%d%d\n", truth_of(isdigit('7')),
	       truth_of(isdigit('a')), truth_of(isalpha('Q')), truth_of(isalpha('7')),
	       truth_of(isalnum('7')), truth_of(isalnum('-')));
	printf("isupper=%d%d islower=%d%d isprint=%d%d isxdigit=%d%d%d\n",
	       truth_of(isupper('Q')), truth_of(isupper('q')), truth_of(islower('q')),
	       truth_of(islower('Q')), truth_of(isprint('~')), truth_of(isprint(7)),
	       truth_of(isxdigit('F')), truth_of(isxdigit('f')), truth_of(isxdigit('g')));
	printf("case=%c%c%c%c\n", tolower('Q'), tolower('q'), toupper('q'), toupper('7'));

	/* 6. formatting into a buffer, with C's truncation rule. */
	n = snprintf(buffer, sizeof buffer, "%s=%d/%s", "n", 42, "ok");
	printf("snprintf=[%s] n=%d\n", buffer, n);

	for (i = 0; i < 8; i++) {
		buffer[i] = 'Z';
	}
	n = snprintf(buffer, 4u, "abcdefgh");
	printf("snprintf_trunc=[%s] n=%d tail=%c\n", buffer, n, buffer[4]);

	n = snprintf(0, 0u, "%d-%d", 1, 22);
	printf("snprintf_size0=%d\n", n);

	n = format_into(buffer, sizeof buffer, "[%s|%d|%05d]", "v", -7, 42);
	printf("vsnprintf=[%s] n=%d\n", buffer, n);

	/* 7. the remaining stream entry points. */
	puts("puts-line");
	fputs("fputs-no-newline", stdout);
	putchar('|');
	putchar('\n');
	fprintf(stdout, "fprintf=%s/%d\n", "out", 5);
	printf("fwrite=%d\n", (int)fwrite("abcd\n", 1u, 5u, stdout));

	/* stderr is not part of the compared output. */
	fprintf(stderr, "diagnostic %d\n", 1);
	fputs("stderr-line\n", stderr);

	/* 8. `abort` is emitted but never reached. */
	if (never) {
		abort();
	}

	return 0;
}
