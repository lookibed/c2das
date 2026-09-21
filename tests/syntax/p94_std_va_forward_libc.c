/*
 * p94: forwarding a `va_list` to a libc v-function shares the cursor.
 *
 * glibc's x86-64 `va_list` is `struct __va_list_tag[1]`, so the callee
 * advances the *caller's* object, and a program that reads on after
 * `vsnprintf` sees the arguments the conversion consumed already gone.
 * Forwarding to a translated C function has always worked that way here (the
 * cursor is a `var` parameter, `variadic.rs`); these three shapes pin that
 * forwarding to the std shims is the same ABI and not a second one.
 *
 * The three are the gap-3 idioms i10 (straight forward), i18 (the callee
 * consumes, the caller reads on) and i19 (the same `ap` handed over twice).
 */
#include <stdarg.h>
#include <stdio.h>

static int forward(char *out, unsigned long n, const char *fmt, ...)
{
	va_list ap;
	int written;
	va_start(ap, fmt);
	written = vsnprintf(out, n, fmt, ap);
	va_end(ap);
	return written;
}

static void consume_then_read(const char *fmt, ...)
{
	va_list ap;
	char buf[32];
	int tail;
	va_start(ap, fmt);
	vsnprintf(buf, sizeof buf, fmt, ap);
	tail = va_arg(ap, int);
	va_end(ap);
	printf("buf=[%s] tail=%d\n", buf, tail);
}

static void twice(const char *fmt, ...)
{
	va_list ap;
	char a[32];
	char b[32];
	va_start(ap, fmt);
	vsnprintf(a, sizeof a, fmt, ap);
	vsnprintf(b, sizeof b, fmt, ap);
	va_end(ap);
	printf("a=[%s] b=[%s]\n", a, b);
}

static void rest_after_copy(const char *fmt, ...)
{
	va_list ap;
	va_list copy;
	char one[32];
	char two[32];
	va_start(ap, fmt);
	va_copy(copy, ap);
	vsnprintf(one, sizeof one, fmt, ap);
	vsnprintf(two, sizeof two, fmt, copy);
	va_end(copy);
	va_end(ap);
	printf("one=[%s] two=[%s]\n", one, two);
}

int main(void)
{
	char buf[32];
	int written = forward(buf, sizeof buf, "%d/%s/%d", 7, "mid", 9);
	printf("n=%d buf=[%s]\n", written, buf);
	consume_then_read("%d", 11, 22);
	twice("%d", 11, 22);
	rest_after_copy("%d", 31, 32);
	return 0;
}
