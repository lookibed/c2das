/* Audit acceptance: a direct call to a tiny `static` helper is substituted
 * with the expression the helper stands for, instead of staying a call.
 *
 * The shape that motivated this case is pl_mpeg's
 *
 *     static inline uint8_t plm_clamp(int n) {
 *         if (n > 255) { n = 255; } else if (n < 0) { n = 0; }
 *         return n;
 *     }
 *
 * which `plm_frame_to_rgb` calls once per output RGB byte — 19.35 M times for
 * seven 720p frames.  The daslang interpreter pays one call dispatch per
 * invocation, and the translated body is worse still: a C function body
 * crosses through the CFG relooper and comes out as labels and `goto`s.
 *
 * What has to stay true after the substitution is C's own call semantics:
 * every argument is evaluated exactly once, in call order, at the call — even
 * when the substituted body reads its parameter three times, and even when the
 * call sits in a position C only sometimes evaluates.  The parameter's own
 * conversion and the function's return conversion both still happen.
 *
 * Returns 0 on success, or the number of the first failed check. */

static int g_calls;  /* how many times a side-effecting argument has run */

/* --- candidates ---------------------------------------------------------- */

/* The clamp shape: an `if`/`else` chain whose every arm assigns the parameter,
 * followed by `return <that parameter>`.  The substituted expression reads the
 * parameter three times. */
static int clamp255(int n) {
	if (n > 255) {
		n = 255;
	}
	else if (n < 0) {
		n = 0;
	}
	return n;
}

/* The same chain, but ending in a bare `else`: it never falls through to the
 * parameter. */
static int sign_of(int n) {
	if (n > 0) {
		n = 1;
	}
	else if (n < 0) {
		n = -1;
	}
	else {
		n = 0;
	}
	return n;
}

/* One `return`, and a candidate calling another candidate. */
static unsigned char sat(int v) {
	return (unsigned char)clamp255(v);
}

/* The return conversion belongs to the function, not to the argument: 0x1FF
 * has to come back as 0xFF. */
static unsigned char low_byte(int v) {
	return (unsigned char)v;
}

/* A narrow parameter type: C converts the argument to `short` at the call. */
static short half(short s) {
	return (short)(s / 2);
}

/* The parameter is read twice, so a side-effecting argument may not be
 * duplicated into the expression. */
static int square_plus(int x) {
	return x * x + x;
}

/* Floating parameters and results take the same path. */
static double scale_half(double x) {
	return x * 0.5;
}

/* Two parameters, both read, in the opposite order to the call. */
static int mix(int a, int b) {
	return b * 10 + a;
}

/* --- non-candidates ------------------------------------------------------ */

/* A loop: this one keeps its call. */
static int sum_to(int n) {
	int total = 0;
	int i;
	for (i = 1; i <= n; i++) {
		total += i;
	}
	return total;
}

/* Recursion: a function that reaches itself cannot be substituted into its own
 * expansion, so this one keeps its call too. */
static int fact(int n) {
	return n <= 1 ? 1 : n * fact(n - 1);
}

/* Reads a file-scope object, which a call site cannot reproduce. */
static int bump(int by) {
	return g_calls + by;
}

/* Two statements and a side effect: not a candidate, and the argument whose
 * evaluation the checks below count. */
static int next_value(void) {
	g_calls++;
	return 300;
}

/* --- entry point --------------------------------------------------------- */

int static_inline_calls_runtime(void) {
	int i;
	int r;
	int (*fp)(int);
	short sh;

	/* 1. the clamp shape itself. */
	if (clamp255(300) != 255) return 1;
	if (clamp255(-7) != 0) return 2;
	if (clamp255(42) != 42) return 3;
	if (clamp255(255) != 255) return 4;
	if (clamp255(0) != 0) return 5;

	/* 2. an argument with a side effect, read three times by the body. */
	g_calls = 0;
	if (clamp255(next_value()) != 255) return 6;
	if (g_calls != 1) return 7;

	i = 250;
	if (clamp255(i++) != 250) return 8;
	if (i != 251) return 9;

	i = -3;
	if (clamp255(i++) != 0) return 10;
	if (i != -2) return 11;

	/* 3. a parameter read twice, with a side-effecting argument. */
	g_calls = 0;
	if (square_plus(next_value()) != 300 * 300 + 300) return 12;
	if (g_calls != 1) return 13;

	i = 5;
	if (square_plus(i++) != 30) return 14;
	if (i != 6) return 15;

	/* 4. narrowing at the parameter and at the return. */
	if (sat(300) != 255) return 16;
	if (sat(-1) != 0) return 17;
	if (sat(7) != 7) return 18;
	if (low_byte(0x1FF) != 0xFF) return 19;
	if (low_byte(0x100) != 0) return 20;

	sh = 9;
	if (half(sh) != 4) return 21;
	sh = -9;
	if (half(sh) != -4) return 22;
	if (half(1000) != 500) return 23;

	/* 5. the chain with a trailing `else`. */
	if (sign_of(5) != 1) return 24;
	if (sign_of(-5) != -1) return 25;
	if (sign_of(0) != 0) return 26;

	/* 6. two parameters, evaluated in call order. */
	g_calls = 0;
	if (mix(1, next_value()) != 3001) return 27;
	if (g_calls != 1) return 28;

	/* 7. floating values. */
	if (scale_half(3.0) != 1.5) return 29;
	if (scale_half(-1.0) != -0.5) return 30;

	/* 8. a candidate calling a candidate. */
	if (sat(clamp255(1000)) != 255) return 31;
	if (sat(clamp255(-1000)) != 0) return 32;

	/* 9. the non-candidates still work, through their calls. */
	if (sum_to(5) != 15) return 33;
	if (fact(5) != 120) return 34;
	g_calls = 3;
	if (bump(4) != 7) return 35;

	/* 10. a candidate taken by address: the definition is still emitted, and
	 * a call through the pointer reaches it. */
	fp = clamp255;
	if (fp(300) != 255) return 36;
	if (fp(-3) != 0) return 37;
	if (fp(11) != 11) return 38;

	/* 11. a discarded result evaluates its argument exactly once. */
	g_calls = 0;
	(void)clamp255(next_value());
	if (g_calls != 1) return 39;

	/* 12. inside a loop, which is where the substitution pays. */
	r = 0;
	for (i = -2; i < 4; i++) {
		r += clamp255(i * 100);
	}
	if (r != 555) return 40;

	/* 13. positions C only sometimes evaluates: the argument must not be
	 * hoisted out of the guard that decides whether it runs at all. */
	i = 4;
	g_calls = 0;
	r = (i > 0 && clamp255(next_value()) == 255) ? 1 : 0;
	if (r != 1) return 41;
	if (g_calls != 1) return 42;

	g_calls = 0;
	r = (i < 0 && clamp255(next_value()) == 255) ? 1 : 0;
	if (r != 0) return 43;
	if (g_calls != 0) return 44;

	g_calls = 0;
	r = (i > 0) ? clamp255(next_value()) : 7;
	if (r != 255) return 45;
	if (g_calls != 1) return 46;

	g_calls = 0;
	r = (i < 0) ? clamp255(next_value()) : 7;
	if (r != 7) return 47;
	if (g_calls != 0) return 48;

	return 0;
}
