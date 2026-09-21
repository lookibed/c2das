/*
 * n11: a `--libc std` unit that calls a C library function the table does not
 * replace fails closed, with the C source line that called it.
 *
 * `strerror_l` is the locale-aware sibling of a function the table *does*
 * have, which is exactly the shape that must not be answered with the nearest
 * neighbour: it takes a `locale_t` this policy has nothing to say about.
 * Growing the table is how a name becomes supported; never a fallback.
 */
typedef void *locale_t;

int printf(const char *format, ...);
char *strerror_l(int errnum, locale_t locale);

int main(void)
{
	printf("%s\n", strerror_l(2, (locale_t)0));
	return 0;
}
