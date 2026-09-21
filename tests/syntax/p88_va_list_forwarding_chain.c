/* Audit acceptance: a `va_list` forwarded down a chain, and a callee that
 * closes the list it received.
 *
 * `p75-va-list-parameter` pins one level of forwarding and `va_copy` on both
 * sides of it; this case pins the two shapes it does not reach.
 *
 *   * a three-level chain `f -> g -> h` where every level takes a `va_list`
 *     parameter, consumes one argument and forwards the rest.  Each level
 *     hands on the cursor it has already advanced, so the chain is
 *     model-independent: it reads the same under a shared cursor and under a
 *     private one.  It is wasm3's `m3_CallV -> m3_CallVL` shape, one level
 *     deeper.
 *   * a callee that calls `va_end` on a `va_list` *parameter*.  C99 7.15.1p1
 *     asks for `va_start`/`va_copy` and `va_end` to be paired inside one
 *     function, so this is not what the standard asks for, but real code does
 *     it and glibc's `va_end` is `(void)0`.  Under the canonical model
 *     `va_end` poisons the cursor, and the cursor is shared, so this pins that
 *     the caller's own `va_start`/`va_end` pairing still holds afterwards and
 *     that a caller which does not read on is unaffected.
 *
 * The `vprintf`-style wrapper — a format string walked by the callee, the
 * arguments taken off the caller's cursor as the format names them — is
 * pinned alongside as the shape all of this exists for.
 *
 * Returns 0 on success, or the number of the first failed check. */

#include <stdarg.h>

/* The innermost level: one argument. */
static int h(va_list ap) {
	return va_arg(ap, int);
}

/* The middle level: one argument of its own, then forwards. */
static int g(va_list ap) {
	int mine;
	mine = va_arg(ap, int);
	return mine * 10 + h(ap);
}

/* The outermost level: one argument of its own, then forwards. */
static int f(va_list ap) {
	int mine;
	mine = va_arg(ap, int);
	return mine * 100 + g(ap);
}

static int chain(int n, ...) {
	va_list ap;
	int r;
	va_start(ap, n);
	r = f(ap);
	va_end(ap);
	return r;
}

/* The callee closes the list it received. */
static int consume_and_end(int n, va_list ap) {
	int total = 0;
	int i;
	for (i = 0; i < n; i++) {
		total += va_arg(ap, int);
	}
	va_end(ap);
	return total;
}

static int callee_ends(int n, ...) {
	va_list ap;
	int r;
	va_start(ap, n);
	r = consume_and_end(n, ap);
	va_end(ap);
	return r;
}

/* The caller starts the same object again after the callee closed it: the
 * rewind reinitialises the cursor, so the second reading is complete. */
static int callee_ends_then_restart(int n, ...) {
	va_list ap;
	int a;
	int b;
	va_start(ap, n);
	a = consume_and_end(n, ap);
	va_end(ap);
	va_start(ap, n);
	b = consume_and_end(n, ap);
	va_end(ap);
	return a * 1000 + b;
}

/* The `vprintf` wrapper: the callee decides from the format which promoted
 * lane each argument arrives in. */
static int vlog(const char *fmt, va_list ap) {
	int total = 0;
	const char *p;
	for (p = fmt; *p; p++) {
		if (*p == 'i') {
			total += va_arg(ap, int);
		} else if (*p == 'd') {
			total += (int)va_arg(ap, double);
		} else if (*p == 'p') {
			total += *(const int *)va_arg(ap, const void *);
		}
	}
	return total;
}

static int logmsg(const char *fmt, ...) {
	va_list ap;
	int r;
	va_start(ap, fmt);
	r = vlog(fmt, ap);
	va_end(ap);
	return r;
}

int va_list_forwarding_chain_runtime(void) {
	static const int cell = 500;

	/* 1. three levels, one argument each. */
	if (chain(0, 1, 2, 3) != 123) return 1;
	if (chain(0, 7, 8, 9) != 789) return 2;

	/* 2. the callee closed the list; the caller only pairs its own. */
	if (callee_ends(3, 5, 6, 7) != 18) return 3;
	if (callee_ends(0) != 0) return 4;

	/* 3. a fresh `va_start` after the callee closed it reads everything
	 *    again. */
	if (callee_ends_then_restart(3, 5, 6, 7) != 18018) return 5;

	/* 4. the wrapper reads each promoted lane the format names. */
	if (logmsg("iii", 1, 2, 3) != 6) return 6;
	if (logmsg("idi", 10, 2.5, 30) != 42) return 7;
	if (logmsg("") != 0) return 8;
	if (logmsg("ip", 4, &cell) != 504) return 9;

	return 0;
}
