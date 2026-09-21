/* Audit acceptance: `__attribute__((musttail)) return f(...);`.
 *
 * The attributed-statement converter used to accept `fallthrough` and
 * `panic!("Unknown statement attribute: …")` on everything else, which broke
 * the project's own rule that unsupported C fails closed with a source
 * location.  The shape that found it is wasm3's dispatch, `m3_exec_defs.h`:
 *
 *     #define nextOpDirect() M3_MUSTTAIL return nextOpImpl()
 *
 * where `M3_MUSTTAIL` is `__attribute__((musttail))`.
 *
 * What `musttail` promises is about the *machine* call sequence, never about
 * what the statement means: the `return` of a call returns that call either
 * way.  The translation therefore drops the attribute, and this case pins that
 * the program still computes what C computes.  The guarantee itself is **not**
 * preserved — the generated module recurses where the C program iterated — so
 * the recursion here is shallow on purpose; an interpreter that relies on
 * `musttail` to run an unbounded instruction stream in constant stack would
 * not survive translation, and that is a known limit, not a bug this case
 * hides.  Dropping the guarantee is therefore reported: each of the five
 * attributed statements below produces one `-Wmust-tail` warning carrying its
 * own source location, and `countdown`'s says that the tail call is
 * self-recursive.  `diagnostic_tests.rs` pins the wording and the
 * `-Wno-must-tail` spelling that silences it.
 *
 * An attribute the translator does not model is a source-located
 * `TranslationError` instead; `n09-unknown-statement-attribute` pins that.
 *
 * Returns 0 on success, or the number of the first failed check. */

static int odd_steps(int n, int acc);

/* Mutual recursion, each call in tail position under the attribute. */
static int even_steps(int n, int acc) {
	if (n == 0) {
		return acc;
	}
	__attribute__((musttail)) return odd_steps(n - 1, acc + 1);
}

static int odd_steps(int n, int acc) {
	if (n == 0) {
		return acc;
	}
	__attribute__((musttail)) return even_steps(n - 1, acc + 2);
}

/* The attribute on a self-recursive tail call. */
static int countdown(int n, int acc) {
	if (n <= 0) {
		return acc;
	}
	__attribute__((musttail)) return countdown(n - 1, acc + n);
}

/* The attribute on a call whose result the caller converts: `musttail`
 * requires matching types, so the conversion is the callee's own. */
static unsigned char clamp_byte(int n) {
	return (unsigned char)(n > 255 ? 255 : n);
}

static unsigned char saturate(int n) {
	__attribute__((musttail)) return clamp_byte(n);
}

/* The attribute inside a loop body, on the statement that leaves the loop. */
static int first_multiple(int start, int step) {
	int i;
	for (i = start; i < start + 100; i++) {
		if (i % step == 0) {
			__attribute__((musttail)) return countdown(0, i);
		}
	}
	return -1;
}

int musttail_return_runtime(void) {
	/* 1. the mutual recursion terminates with C's answer:
	 *    even(5) -> odd(4) -> even(3) -> odd(2) -> even(1) -> odd(0)
	 *    accumulating 1 + 2 + 1 + 2 + 1 = 7. */
	if (even_steps(5, 0) != 7) return 1;
	if (even_steps(0, 11) != 11) return 2;
	if (odd_steps(4, 0) != 6) return 3;
	if (odd_steps(1, 0) != 2) return 4;

	/* 2. self recursion. */
	if (countdown(4, 0) != 10) return 5;
	if (countdown(0, 3) != 3) return 6;

	/* 3. the callee's own return conversion still happens. */
	if (saturate(300) != 255) return 7;
	if (saturate(7) != 7) return 8;

	/* 4. the attributed statement really is the loop's exit. */
	if (first_multiple(10, 7) != 14) return 9;
	if (first_multiple(3, 3) != 3) return 10;

	return 0;
}
