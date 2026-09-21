/* Audit acceptance: C's `_Bool` where daScript's value is a `bool`.
 *
 * C counts `_Bool` among the integral types and gives `!x`, `a < b`, `a && b`
 * the type `int`; daScript's own operators yield a `bool` for every one of
 * them, and `bool == 0`, `int64(bool)` and `bool(x)` are not operations
 * daScript has at all.  The translation therefore has to decide from the
 * *value* it built, not only from the C type the construct carries.
 *
 * wasm3 found four spellings of the same gap:
 *
 *   * `if (AreFuncTypesEqual(a, b))` on a `bool`-returning function
 *     -> `if (bool(AreFuncTypesEqual(...)))`, and daScript has no `bool(...)`;
 *   * `i_runtime->skipValidation = not i_enable` on a `bool` parameter
 *     -> `... = i_enable == 0`;
 *   * `if (not validEnd)` under `_throwif`, which is `__builtin_expect(!!(x), 0)`
 *     -> `!(!validEnd == 0)` and then `int64(!(!(!validEnd)))`.
 *
 * Returns 0 on success, or the number of the first failed check. */

struct Flags {
	_Bool enabled;
	_Bool skip;
	int count;
};

static _Bool g_calls;

/* A `bool`-returning function: its result is a daScript `bool` already. */
static _Bool is_even(int n) {
	return (n % 2) == 0;
}

static _Bool always_true(void) {
	g_calls = 1;
	return 1;
}

/* A `_Bool` *parameter*, which C may negate with `!`. */
static _Bool negate(_Bool b) {
	return !b;
}

static int as_int(_Bool b) {
	return b;
}

/* `!!x` — the idiom every `likely`/`unlikely` macro is built from. */
static long normalize(_Bool b) {
	return __builtin_expect(!!(b), 0);
}

static void store_negated(struct Flags *f, _Bool enable) {
	f->skip = !enable;
}

int bool_value_semantics_runtime(void) {
	struct Flags flags;
	_Bool b;
	int n;

	/* 1. a bool-returning call in a condition. */
	if (is_even(4)) {
		n = 1;
	}
	else {
		n = 0;
	}
	if (n != 1) return 1;
	if (is_even(3)) return 2;
	if (!is_even(10)) return 3;

	/* 2. the call's result assigned to a `_Bool` object and to an `int`. */
	b = is_even(7);
	if (b) return 4;
	b = is_even(8);
	if (!b) return 5;
	n = is_even(8);
	if (n != 1) return 6;
	n = is_even(9);
	if (n != 0) return 7;

	/* 3. `!` on a `_Bool` parameter, and `!` of that again. */
	if (negate(1)) return 8;
	if (!negate(0)) return 9;
	if (negate(negate(1)) != 1) return 10;

	/* 4. a `_Bool` in arithmetic is C's 0 or 1. */
	if (as_int(1) != 1) return 11;
	if (as_int(0) != 0) return 12;
	if (as_int(is_even(2)) + as_int(is_even(3)) != 1) return 13;

	/* 5. `!!x` through `__builtin_expect`, the `unlikely()` shape. */
	if (normalize(1) != 1) return 14;
	if (normalize(0) != 0) return 15;

	/* 6. storing a negated `_Bool` into a `_Bool` field. */
	flags.enabled = 1;
	flags.skip = 0;
	flags.count = 0;
	store_negated(&flags, 1);
	if (flags.skip) return 16;
	store_negated(&flags, 0);
	if (!flags.skip) return 17;

	/* 7. a `_Bool` field read as a condition, and `!` of one. */
	flags.enabled = 0;
	if (flags.enabled) return 18;
	if (!!flags.enabled) return 19;
	flags.enabled = 1;
	if (!flags.enabled) return 20;

	/* 8. the short-circuit operators over `_Bool` operands. */
	g_calls = 0;
	if (!(flags.enabled && always_true())) return 21;
	if (!g_calls) return 22;
	g_calls = 0;
	flags.enabled = 0;
	if (flags.enabled && always_true()) return 23;
	if (g_calls) return 24;
	if (!(flags.enabled || is_even(2))) return 25;

	/* 9. a `_Bool` in a loop condition and in a ternary. */
	b = 1;
	n = 0;
	while (b) {
		n++;
		b = n < 3;
	}
	if (n != 3) return 26;
	if ((b ? 10 : 20) != 20) return 27;
	if ((is_even(2) ? 10 : 20) != 10) return 28;

	/* 10. C's conversion of an arbitrary integer to `_Bool` is `!= 0`. */
	b = 256;
	if (!b) return 29;
	b = 0;
	if (b) return 30;

	return 0;
}
