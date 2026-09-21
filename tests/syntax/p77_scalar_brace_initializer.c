/* Audit acceptance: a scalar initialized with a brace-enclosed expression.
 *
 * C11 6.7.9p11: "The initializer for a scalar shall be a single expression,
 * optionally enclosed in braces."  The braces mean nothing — the object is
 * still a pointer, an integer or a floating value, never an aggregate.
 *
 * The shape that found this is wasm3's error table, `wasm3.h`:
 *
 *     #define d_m3ErrorConst(LABEL, STRING)  const M3Result m3Err_##LABEL = { STRING };
 *     d_m3ErrorConst(none, NULL)
 *     d_m3ErrorConst(mallocFailed, "memory allocation failed")
 *
 * with `M3Result` a `const char *`.  The translation used to lower the
 * initializer list to a daScript array literal whatever the target was, and
 * the module failed to parse with
 * `error[30344]: global variable 'm3Err_none' initialization type mismatch;
 * int8 const? aka M3Result const -const = array<void?>`.
 *
 * Returns 0 on success, or the number of the first failed check. */

/* File scope, which is where the braces are idiomatic. */
static const char *const message = {"braced"};
static const char *const nothing = {0};
static int counter = {7};
static double ratio = {0.25};
static unsigned long mask = {0xF0u};
static char letter = {'Q'};

/* An array of scalars still takes its own braces, one level out. */
static int triple[3] = {1, {2}, {3}};

/* A struct's scalar members, each braced in turn. */
struct Pair {
	int a;
	const char *b;
};

static struct Pair pair = {{5}, {"in-struct"}};

static int same_text(const char *left, const char *right) {
	while (*left && *left == *right) {
		left++;
		right++;
	}
	return *left == *right;
}

int scalar_brace_initializer_runtime(void) {
	/* Block scope takes the same initializer. */
	int local = {11};
	const char *text = {"local"};
	double half = {0.5};
	/* GNU C's empty braces on a scalar are its zero. */
	int blank = {};

	if (!same_text(message, "braced")) return 1;
	if (nothing != 0) return 2;
	if (counter != 7) return 3;
	if (ratio != 0.25) return 4;
	if (mask != 0xF0u) return 5;
	if (letter != 'Q') return 6;

	if (triple[0] != 1 || triple[1] != 2 || triple[2] != 3) return 7;

	if (pair.a != 5) return 8;
	if (!same_text(pair.b, "in-struct")) return 9;

	if (local != 11) return 10;
	if (!same_text(text, "local")) return 11;
	if (half != 0.5) return 12;
	if (blank != 0) return 13;

	/* The braced initializer is an ordinary value: it still converts. */
	{
		unsigned char narrow = {0x1FF};
		long wide = {counter};
		if (narrow != 0xFF) return 14;
		if (wide != 7) return 15;
	}

	return 0;
}
