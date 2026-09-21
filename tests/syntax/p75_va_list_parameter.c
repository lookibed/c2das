/* Audit acceptance: a `va_list` received as a *parameter*.
 *
 * The canonical variadic ABI (see `translator/variadic.rs`) models a C
 * variadic call as an explicit `array<C2daVaArg>` of promoted values and a
 * `va_list` as a cursor into it.  Only a cursor created by `va_start` in the
 * same function was supported, so the classic pair
 *
 *     int vfoo(const char *fmt, va_list ap);
 *     int  foo(const char *fmt, ...) { va_list ap; va_start(ap, fmt);
 *                                      r = vfoo(fmt, ap); va_end(ap); … }
 *
 * failed with `va_arg uses a va_list without va_start`.  It is the shape every
 * C library with a `printf` has, and wasm3 has it twice on the path a host
 * uses to call into Wasm (`m3_CallV` -> `m3_CallVL`).
 *
 * A cursor indexes exactly one argument array, so a function that receives a
 * `va_list` receives that array too: the callee's parameter list gains the
 * same `array<C2daVaArg>` a variadic function has.  The cursor itself crosses
 * as the record it is, by reference, which is what C's own `va_list` does on
 * every ABI whose `va_list` is an array type — so what the callee consumed,
 * the caller sees consumed, and a caller that wants an independent cursor
 * writes `va_copy`.
 *
 * Returns 0 on success, or the number of the first failed check. */

#include <stdarg.h>

/* The classic forwarded list: reads `n` arguments off a caller's cursor. */
static int vsum(int n, va_list ap) {
	int total = 0;
	int i;
	for (i = 0; i < n; i++) {
		total += va_arg(ap, int);
	}
	return total;
}

/* Forwarding a forwarded list: `ap` is a parameter here too.  C leaves `ap`
 * indeterminate once a callee has read through it, so the first read goes
 * through a `va_copy` and only the second consumes the parameter itself. */
static int vsum_twice(int n, va_list ap) {
	va_list copy;
	int first;
	int second;
	va_copy(copy, ap);
	first = vsum(n, copy);
	va_end(copy);
	second = vsum(n, ap);
	return first * 1000 + second;
}

/* A forwarded list of mixed types, to pin that the promoted payload is read
 * with the right tag through a parameter as well. */
static double vmix(int n, va_list ap) {
	double total = 0.0;
	int i;
	for (i = 0; i < n; i++) {
		total += va_arg(ap, double);
	}
	return total + (double)va_arg(ap, int);
}

/* `va_copy` of a parameter: the copy walks the same arguments again without
 * disturbing the caller's cursor. */
static int vsum_copy(int n, va_list ap) {
	va_list mine;
	int total = 0;
	int i;
	va_copy(mine, ap);
	for (i = 0; i < n; i++) {
		total += va_arg(mine, int);
	}
	va_end(mine);
	return total;
}

/* The caller side: `va_start` here, the reading elsewhere. */
static int sum(int n, ...) {
	va_list ap;
	int r;
	va_start(ap, n);
	r = vsum(n, ap);
	va_end(ap);
	return r;
}

/* The same, reading the first argument itself and forwarding the rest: the
 * callee has to continue at the cursor, not restart at the front. */
static int head_then_sum(int n, ...) {
	va_list ap;
	int head;
	int rest;
	va_start(ap, n);
	head = va_arg(ap, int);
	rest = vsum(n - 1, ap);
	va_end(ap);
	return head * 100 + rest;
}

/* `va_copy` in the caller, so both cursors are handed on separately. */
static int sum_twice(int n, ...) {
	va_list ap;
	va_list copy;
	int a;
	int b;
	va_start(ap, n);
	va_copy(copy, ap);
	a = vsum(n, ap);
	b = vsum_copy(n, copy);
	va_end(copy);
	va_end(ap);
	return a * 1000 + b;
}

static int sum_forwarded_twice(int n, ...) {
	va_list ap;
	int r;
	va_start(ap, n);
	r = vsum_twice(n, ap);
	va_end(ap);
	return r;
}

static double mix(int n, ...) {
	va_list ap;
	double r;
	va_start(ap, n);
	r = vmix(n, ap);
	va_end(ap);
	return r;
}

int va_list_parameter_runtime(void) {
	/* 1. the plain forward. */
	if (sum(3, 1, 2, 3) != 6) return 1;
	if (sum(1, 42) != 42) return 2;
	if (sum(0) != 0) return 3;
	if (sum(5, 10, 20, 30, 40, 50) != 150) return 4;

	/* 2. the caller consumed one argument before forwarding. */
	if (head_then_sum(4, 7, 1, 2, 3) != 706) return 5;
	if (head_then_sum(1, 9) != 900) return 6;

	/* 3. `va_copy` gives an independent cursor, in the caller and in the
	 *    callee: both readers see all three arguments. */
	if (sum_twice(3, 4, 5, 6) != 15015) return 7;

	/* 4. the callee forwards its own parameter onward, twice, the second
	 *    time through a `va_copy` of it: both reads see all four. */
	if (sum_forwarded_twice(4, 1, 2, 3, 4) != 10010) return 8;

	/* 5. mixed promoted types through a parameter. */
	if (mix(2, 1.5, 2.25, 4) != 7.75) return 9;

	return 0;
}
