/*
 * p89: the ten `errno` idioms real C programs use, against the std table.
 *
 * `errno` is declared the way glibc declares it — the macro expands to
 * `(*__errno_location())`, and that function is the ABI, because glibc's
 * `errno` data symbol is `GLIBC_PRIVATE`.  The same source builds natively
 * and translates, so the C program is its own oracle.
 *
 * What this pins: the cell is one stable object for the whole run, a helper
 * that succeeds never clears it, a pointer into it stays valid across calls,
 * and the codes the conversions report are the target's own.
 */
typedef unsigned long size_t;

int printf(const char *format, ...);
long long strtoll(const char *nptr, char **endptr, int base);
unsigned long long strtoull(const char *nptr, char **endptr, int base);
size_t strlen(const char *s);
int snprintf(char *s, size_t n, const char *format, ...);
int strcmp(const char *a, const char *b);
int isdigit(int c);

int *__errno_location(void);
#define errno (*__errno_location())
#define ERANGE 34
#define EINVAL 22

static char scratch[32];

int main(void)
{
	long long converted;
	unsigned long long unsigned_converted;
	int *slot_a;
	int *slot_b;
	int saved;
	int after;

	/* 1. errno = 0; convert; check ERANGE — the canonical strtol idiom. */
	errno = 0;
	converted = strtoll("99999999999999999999", 0, 10);
	printf("over=%lld erange=%d\n", converted, errno == ERANGE);

	/* 2. errno unchanged (still 0) after a conversion that succeeds. */
	errno = 0;
	converted = strtoll("42", 0, 10);
	printf("ok=%lld errno=%d\n", converted, errno);

	/* 3. errno set by one helper survives calls to others that succeed:
	 *    C only forbids a library function from *clearing* errno. */
	errno = 0;
	converted = strtoll("99999999999999999999", 0, 10);
	saved = errno;
	(void)strlen("abcdef");
	(void)snprintf(scratch, sizeof scratch, "%d", 7);
	(void)strcmp("a", "b");
	(void)isdigit('7');
	converted = strtoll("1", 0, 10);
	printf("sticky=%d same=%d\n", errno, errno == saved);

	/* 4. save and restore around a call that clobbers it. */
	errno = 0;
	converted = strtoll("7", 0, 10);
	saved = errno;
	errno = 0;
	(void)strtoll("99999999999999999999", 0, 10);
	after = errno;
	errno = saved;
	printf("saved=%d clobbered=%d restored=%d\n", saved, after, errno);

	/* 5. __errno_location() called explicitly: one stable cell. */
	slot_a = __errno_location();
	slot_b = __errno_location();
	printf("stable=%d\n", slot_a == slot_b);

	/* 6. writing through the pointer is seen by the macro and back. */
	*slot_a = 13;
	printf("through_ptr=%d\n", errno);
	errno = 21;
	printf("through_macro=%d\n", *slot_b);

	/* 7. EINVAL from a base outside 2..36. */
	errno = 0;
	converted = strtoll("10", 0, 37);
	printf("base37=%lld einval=%d\n", converted, errno == EINVAL);

	/* 8. the unsigned conversion reports ERANGE the same way. */
	errno = 0;
	unsigned_converted = strtoull("99999999999999999999999", 0, 10);
	printf("uover=%llu erange=%d\n", unsigned_converted, errno == ERANGE);

	/* 9. errno is never reset by the program's own reads. */
	errno = 5;
	(void)errno;
	(void)errno;
	printf("reread=%d\n", errno);

	/* 10. a pointer to errno kept across a helper call stays valid. */
	slot_a = __errno_location();
	errno = 0;
	(void)strtoll("99999999999999999999", 0, 10);
	printf("kept_ptr=%d\n", *slot_a == ERANGE);

	return 0;
}
