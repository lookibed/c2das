/* `--varargs-model heap` (docs/eden-flags.md flag 6) under
 * `--memory-model linear`: variadic arguments are 8-byte slots in the C
 * stack of the heap and a va_list is the address of the next slot.  Covers
 * va_arg of int, long long, double and pointers, va_copy, a va_list handed to
 * a helper and to vsnprintf, nested variadic calls in argument position,
 * recursion, and printf with many arguments. */
#include <stdarg.h>
#include <stdio.h>

static long long sum_ints(int n, ...)
{
	va_list ap;
	long long total = 0;
	va_start(ap, n);
	for (int i = 0; i < n; i++)
		total += va_arg(ap, int);
	va_end(ap);
	return total;
}

static double mixed(const char *kinds, ...)
{
	va_list ap, again;
	double total = 0;
	va_start(ap, kinds);
	va_copy(again, ap);
	for (const char *k = kinds; *k; k++) {
		if (*k == 'i')
			total += va_arg(ap, int);
		else if (*k == 'l')
			total += (double)va_arg(ap, long long);
		else if (*k == 'd')
			total += va_arg(ap, double);
		else if (*k == 's')
			total += (double)(*va_arg(ap, const char *) - 'a');
		else if (*k == 'p')
			total += (double)*va_arg(ap, int *);
	}
	/* The copy still starts at the first argument. */
	if (*kinds == 'i')
		total += 1000.0 * va_arg(again, int);
	va_end(again);
	va_end(ap);
	return total;
}

static int weighted(int n, va_list ap)
{
	int total = 0;
	for (int i = 1; i <= n; i++)
		total += i * va_arg(ap, int);
	return total;
}

static int forward(int n, ...)
{
	va_list ap;
	va_start(ap, n);
	int total = weighted(n, ap);
	va_end(ap);
	return total;
}

static int describe(char *out, int size, const char *fmt, ...)
{
	va_list ap;
	va_start(ap, fmt);
	int n = vsnprintf(out, (size_t)size, fmt, ap);
	va_end(ap);
	return n;
}

static int depth(int n, ...)
{
	va_list ap;
	va_start(ap, n);
	int v = va_arg(ap, int);
	va_end(ap);
	if (n == 0)
		return v;
	return v + depth(n - 1, v * 2);
}

int linear_varargs_heap(void)
{
	int seven = 7;
	char buf[64];
	printf("sum=%lld\n", sum_ints(5, 1, 2, 3, 4, sum_ints(2, 10, 20)));
	printf("mixed=%lld\n", (long long)mixed("ildsp", 3, 4000000000LL, 2.5, "e", &seven));
	printf("forward=%d\n", forward(5, 1, 2, 3, 4, 5));
	int n = describe(buf, (int)sizeof buf, "%s:%d:%x:%c", "tag", -12, 255, 'z');
	printf("describe=%s len=%d\n", buf, n);
	printf("depth=%d\n", depth(4, 1));
	for (int i = 0; i < 3; i++)
		printf("loop %d %d %d %d %d %d %d %d %d %d %s %u %ld %5.2s|\n", i, i + 1, i + 2,
		       i + 3, i + 4, i + 5, i + 6, i + 7, i + 8, i + 9, "abcdef", 4000000000u,
		       -1234567890123L, "xyz");
	return 0;
}
