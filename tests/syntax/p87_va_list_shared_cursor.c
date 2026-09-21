/* Audit acceptance: a forwarded `va_list` is the caller's own cursor.
 *
 * This case pins the *by-reference* decision for `va_list` parameters (see
 * `docs/followups/translator_gaps_wasm3.md`, "Decisions" 3).  It is
 * ABI-dependent by design: what it asserts is faithfulness to the x86-64
 * System V ABI as glibc implements it, where `va_list` is
 * `struct __va_list_tag[1]` and a "by-value" parameter is therefore the
 * caller's own object, so every `va_arg` a callee performs moves the caller's
 * cursor.  On an ABI whose `va_list` is a struct passed by value — aarch64
 * AAPCS64, riscv64, i386, ppc64le — the same C program prints different
 * numbers.
 *
 * C99 7.15.1p1 is explicit that after a callee has read through a `va_list`
 * parameter the caller's own object is *indeterminate*, so no conforming
 * program can observe any of this: nothing here is a claim about what C
 * requires, only about which ABI the canonical variadic model reproduces.
 * The canonical model reproduces it exactly — the `C2daVaCursor` record
 * crosses as the `var` parameter it is declared to be, which daScript passes
 * by reference — and a program that wants an independent cursor writes
 * `va_copy`, which is pinned here too and is the one spelling that is
 * model-independent.
 *
 * Returns 0 on success, or the number of the first failed check. */

#include <stdarg.h>

/* Consumes exactly two arguments off a caller's cursor. */
static int take2(va_list ap) {
	int a;
	int b;
	a = va_arg(ap, int);
	b = va_arg(ap, int);
	return a * 10 + b;
}

/* The callee consumes part of the list and the caller reads on.
 *
 *   by-reference (glibc x86-64, and this translator): `take2` consumed 1 and
 *       2, so the caller's next `va_arg` yields 3      -> 12003
 *   by-value: the caller's cursor never moved, its next `va_arg` yields 1
 *                                                      -> 12001
 */
static int partial_then_caller_reads(int n, ...) {
	va_list ap;
	int consumed;
	int rest;
	va_start(ap, n);
	consumed = take2(ap);
	rest = va_arg(ap, int);
	va_end(ap);
	return consumed * 1000 + rest;
}

/* The classic "call the v-function twice with the same `ap`" defect.
 *
 *   by-reference: the second call continues where the first stopped, reading
 *       3 and 4                                        -> 12034
 *   by-value: both calls restart at the front          -> 12012
 */
static int reuse_without_copy(int n, ...) {
	va_list ap;
	int a;
	int b;
	va_start(ap, n);
	a = take2(ap);
	b = take2(ap);
	va_end(ap);
	return a * 1000 + b;
}

/* The portable way to write that intent: both readers get their own cursor,
 * and the answer is the same under either model. */
static int reuse_with_copy(int n, ...) {
	va_list ap;
	va_list copy;
	int a;
	int b;
	va_start(ap, n);
	va_copy(copy, ap);
	a = take2(ap);
	b = take2(copy);
	va_end(copy);
	va_end(ap);
	return a * 1000 + b;
}

/* The same sharing one level deeper: the forwarder consumes one argument and
 * hands its cursor on, and the callee continues from there rather than from
 * the front.  This half of the model is ABI-independent (a by-value cursor is
 * copied *after* the forwarder's own read), and it is what every `vprintf`
 * wrapper relies on. */
static int forwarder(va_list ap) {
	int mine;
	mine = va_arg(ap, int);
	return mine * 100 + take2(ap);
}

static int forward_after_partial_read(int n, ...) {
	va_list ap;
	int r;
	va_start(ap, n);
	r = forwarder(ap);
	va_end(ap);
	return r;
}

int va_list_shared_cursor_runtime(void) {
	/* 1. the callee consumed two, the caller sees the third. */
	if (partial_then_caller_reads(0, 1, 2, 3) != 12003) return 1;
	if (partial_then_caller_reads(0, 5, 6, 7, 8) != 56007) return 2;

	/* 2. the same cursor handed to the same consumer twice walks on. */
	if (reuse_without_copy(0, 1, 2, 3, 4) != 12034) return 3;

	/* 3. with `va_copy` both readers start at the front. */
	if (reuse_with_copy(0, 1, 2, 3, 4) != 12012) return 4;

	/* 4. a forwarder's own read is visible to the function it forwards to. */
	if (forward_after_partial_read(0, 9, 1, 2) != 912) return 5;

	return 0;
}
