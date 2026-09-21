/* Audit acceptance: a local variable-length array.
 *
 * C99 sizes a VLA by an expression evaluated where the declaration stands,
 * and the object lives until the enclosing block ends.  The translation used
 * to give the daScript `array<T>` that holds it the type's default value —
 * an *empty* array — and never size it, so every element access was silently
 * out of range.  wasm3's type-section parser is one line of it:
 *
 *     m3type_t argTypes[numArgs + 1]; // make ubsan happy
 *     for (u32 a = 0; a < numArgs; ++a)
 *         (ParseValueType(io_module, &argTypes[a], &i_bytes, i_end));
 *
 * which ran as far as `EXCEPTION: array index out of range` on the first
 * element.  A VLA whose element type is itself a VLA has no single extent and
 * still fails closed with a source-located diagnostic.
 *
 * Returns 0 on success, or the number of the first failed check. */

static int g_extents;

/* The size expression is evaluated exactly once, where the declaration is. */
static int extent(int n) {
	g_extents = g_extents + 1;
	return n;
}

/* The classic shape: size from a parameter, written and read back. */
static int sum_squares(int n) {
	int values[n];
	int i;
	int total = 0;
	for (i = 0; i < n; i++) {
		values[i] = i * i;
	}
	for (i = 0; i < n; i++) {
		total += values[i];
	}
	return total;
}

/* `n + 1`, the "make ubsan happy" spelling, with the array address taken. */
static void fill_from(unsigned char *out, const unsigned char *in, int n) {
	int i;
	for (i = 0; i < n; i++) {
		out[i] = in[i];
	}
}

static int copy_through_vla(const unsigned char *src, int n) {
	unsigned char scratch[n + 1];
	int i;
	int total = 0;
	fill_from(scratch, src, n);
	scratch[n] = 0;
	for (i = 0; i <= n; i++) {
		total = total * 2 + (int)scratch[i];
	}
	return total;
}

/* The address of one element, passed on, is how wasm3 uses its VLA. */
static void store_at(int *slot, int value) {
	*slot = value;
}

static int addressed_elements(int n) {
	int cells[n];
	int i;
	int total = 0;
	for (i = 0; i < n; i++) {
		store_at(&cells[i], i + 1);
	}
	for (i = 0; i < n; i++) {
		total += cells[i];
	}
	return total;
}

/* A VLA declared inside a loop body is a fresh object each round. */
static int per_iteration(int rounds) {
	int r;
	int total = 0;
	for (r = 1; r <= rounds; r++) {
		int room[r];
		int i;
		for (i = 0; i < r; i++) {
			room[i] = r;
		}
		total += room[r - 1];
	}
	return total;
}

int variable_length_array_runtime(void) {
	static const unsigned char source[3] = {1, 0, 1};

	/* 1. the plain shape. */
	if (sum_squares(4) != 0 + 1 + 4 + 9) return 1;
	if (sum_squares(1) != 0) return 2;

	/* 2. `n + 1` with a terminator the loop reads back. */
	if (copy_through_vla(source, 3) != 0xA) return 3;

	/* 3. the address of an element handed to another function. */
	if (addressed_elements(5) != 1 + 2 + 3 + 4 + 5) return 4;

	/* 4. a fresh object per loop iteration. */
	if (per_iteration(4) != 1 + 2 + 3 + 4) return 5;

	/* 5. the size expression runs exactly once, at the declaration. */
	{
		g_extents = 0;
		{
			int sized[extent(6)];
			int i;
			for (i = 0; i < 6; i++) {
				sized[i] = i;
			}
			if (sized[5] != 5) return 6;
		}
		if (g_extents != 1) return 7;
	}

	/* 6. a VLA the program never indexes still has to exist. */
	{
		int unused[3 + 1];
		(void)unused;
	}

	return 0;
}
