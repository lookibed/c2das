/* Audit acceptance: `va_start` rewinds a `va_list` that has already been
 * started.
 *
 * C99 7.15.1.4p1 says `va_start` *initialises* the object for subsequent use,
 * so a second `va_start` on the same `va_list` puts the cursor back on the
 * first variadic argument.  The canonical variadic ABI (see
 * `translator/variadic.rs`) models a `va_list` as a `C2daVaCursor` index into
 * the call's `array<C2daVaArg>`, and it used to zero that index only at the
 * cursor's *declaration*: `va_start` itself emitted nothing.  A second
 * `va_start` therefore continued where the first walk had stopped — the
 * "measure, then format" two-pass shape every `printf` implementation has read
 * the wrong arguments, or ran off the end of the argument array.  `va_start`
 * now writes `<cursor>.index = 0`, so every one of them rewinds.
 *
 * `va_end` closes the object (C99 7.15.1.3p2: no further use before a new
 * `va_start`/`va_copy`), and the cursor is poisoned there, so a case that
 * re-reads after `va_end` would fail loudly rather than silently — every read
 * below is between its own `va_start`/`va_end` pair.
 *
 * The conforming spelling of the same intent, `va_copy` of a pristine cursor,
 * is pinned alongside it: both must agree.
 *
 * Returns 0 on success, or the number of the first failed check. */

#include <stdarg.h>

/* Reads `n` integers off a caller's cursor. */
static int walk(int n, va_list ap) {
	int total = 0;
	int i;
	for (i = 0; i < n; i++) {
		total += va_arg(ap, int);
	}
	return total;
}

/* Reads `n` integers off a private copy of a caller's cursor. */
static int walk_via_copy(int n, va_list ap) {
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

/* The bare rewind: two arguments are consumed, then a second `va_start` puts
 * the cursor back and the next `va_arg` yields the first argument again. */
static int restart(int n, ...) {
	va_list ap;
	int first_pass;
	int second_pass;
	va_start(ap, n);
	first_pass = va_arg(ap, int);
	first_pass = first_pass * 10 + va_arg(ap, int);
	va_end(ap);
	va_start(ap, n);
	second_pass = va_arg(ap, int);
	va_end(ap);
	return first_pass * 100 + second_pass;
}

/* A full second walk after a full first walk: without the rewind the second
 * walk would index past the end of the argument array. */
static int walk_twice(int n, ...) {
	va_list ap;
	int a;
	int b;
	va_start(ap, n);
	a = walk(n, ap);
	va_end(ap);
	va_start(ap, n);
	b = walk(n, ap);
	va_end(ap);
	return a * 1000 + b;
}

/* The same rewind written conformingly, with `va_copy` of a cursor that has
 * not been read yet.  This is what musl, picolibc and SQLite do. */
static int rewind_via_copy(int n, ...) {
	va_list ap;
	va_list pass2;
	int a;
	int b;
	va_start(ap, n);
	va_copy(pass2, ap);
	a = walk(n, ap);
	b = walk(n, pass2);
	va_end(pass2);
	va_end(ap);
	return a * 100 + b;
}

/* `va_copy` plus two independent walks in the caller, then a second
 * `va_start` and a walk whose callee copies the parameter it received: three
 * readings of the same arguments, none of them disturbing another. */
static int copy_then_restart(int n, ...) {
	va_list ap;
	va_list copy;
	int a;
	int b;
	int c;
	va_start(ap, n);
	va_copy(copy, ap);
	a = walk(n, ap);
	b = walk(n, copy);
	va_end(copy);
	va_end(ap);
	va_start(ap, n);
	c = walk_via_copy(n, ap);
	va_end(ap);
	return a * 10000 + b * 100 + c;
}

/* The number of decimal digits a non-negative value prints as. */
static int width_of(int value) {
	int digits = 1;
	while (value >= 10) {
		value /= 10;
		digits++;
	}
	return digits;
}

/* The two-pass `printf` idiom with the formatting taken out: the first walk
 * measures the arguments the format names, the second walk consumes the very
 * same arguments to build the result.  The second pass is only correct if
 * `va_start` rewound. */
static int measure_then_format(const char *fmt, ...) {
	va_list ap;
	const char *p;
	int needed;
	int value;
	needed = 0;
	va_start(ap, fmt);
	for (p = fmt; *p; p++) {
		needed += width_of(va_arg(ap, int));
	}
	va_end(ap);
	value = 0;
	va_start(ap, fmt);
	for (p = fmt; *p; p++) {
		value = value * 10 + va_arg(ap, int);
	}
	va_end(ap);
	return needed * 10000 + value;
}

int va_start_rewind_runtime(void) {
	/* 1. the bare rewind: 1, 2 consumed, then 1 again. */
	if (restart(0, 1, 2, 3) != 1201) return 1;
	if (restart(0, 7, 8) != 7807) return 2;

	/* 2. a whole walk replayed through a forwarded cursor. */
	if (walk_twice(3, 1, 2, 3) != 6006) return 3;
	if (walk_twice(0) != 0) return 4;
	if (walk_twice(5, 10, 20, 30, 40, 50) != 150150) return 5;

	/* 3. the conforming `va_copy` spelling agrees. */
	if (rewind_via_copy(3, 1, 2, 3) != 606) return 6;
	if (rewind_via_copy(2, 4, 5) != 909) return 7;

	/* 4. `va_copy` and a later `va_start` on the same object. */
	if (copy_then_restart(3, 1, 2, 3) != 60606) return 8;
	if (copy_then_restart(2, 4, 5) != 90909) return 9;

	/* 5. measure, then format. */
	if (measure_then_format("iii", 1, 2, 3) != 30123) return 10;
	if (measure_then_format("ii", 40, 5) != 30405) return 11;
	if (measure_then_format("") != 0) return 12;

	return 0;
}
