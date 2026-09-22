/* Audit acceptance: `--unsafe-deref` keeps C dereference semantics.
 *
 * daScript emits a null check in front of every `ExprAt`, `ExprPtr2Ref` and
 * field dereference unless the *enclosing function* carries `unsafe_deref`;
 * the expression-level `unsafe(...)` the translator writes does not suppress
 * it.  `--unsafe-deref` puts that annotation on every function the translator
 * emits, which is faithful to C — dereferencing a null pointer is undefined
 * behaviour there, so the check is not a semantic the C program had — at the
 * price of a SIGSEGV where daslang would otherwise raise a located exception.
 *
 * What has to be proved here is the other half: that removing the checks
 * changes *nothing* about a program that never dereferences null.  So this
 * fixture is all the dereference shapes the check sits on — a pointer read
 * and a pointer write, `p[i]`, `p->field`, a field of a pointed-to struct
 * that is itself a pointer, a 2-D table walk, and a pointer stepped through
 * an array — each inside a loop, because a loop is where the check's side
 * exit is measurable (`docs/followups/hot_path_levers.md` lever 2) and where
 * a wrongly hoisted or wrongly folded access would change the answer from the
 * second iteration on.
 *
 * The case runs under `"translator_flags": ["--unsafe-deref"]` and its C
 * reference is the same program compiled by clang: both must return 0.
 *
 * Returns 0 on success, or the number of the first failed check. */

#define ROWS 6
#define COLS 5

struct cell {
	int value;
	int weight;
};

struct row {
	struct cell *cells;
	int count;
};

static struct cell g_cells[ROWS * COLS];
static struct row g_rows[ROWS];
static int g_table[ROWS][COLS];
static int g_scratch[ROWS * COLS];

/* `*p` read and `*p` written, the plainest dereference, in a loop. */
static int sum_through_pointer(const int *p, int n) {
	int total = 0;
	int i;
	for (i = 0; i < n; i++) {
		total += *p;
		p++;
	}
	return total;
}

static void scale_through_pointer(int *p, int n, int factor) {
	int i;
	for (i = 0; i < n; i++) {
		*p = *p * factor;
		p++;
	}
}

/* `p[i]`: the indexed form, which daScript lowers to `ExprAt`. */
static int sum_indexed(const int *p, int n) {
	int total = 0;
	int i;
	for (i = 0; i < n; i++) {
		total += p[i];
	}
	return total;
}

/* `p->field` in a loop over an array of structs. */
static int weighted_sum(const struct cell *cells, int n) {
	int total = 0;
	int i;
	for (i = 0; i < n; i++) {
		total += cells[i].value * cells[i].weight;
	}
	return total;
}

/* A field that is itself a pointer, dereferenced one level deeper. */
static int walk_rows(const struct row *rows, int n) {
	int total = 0;
	int i;
	int j;
	for (i = 0; i < n; i++) {
		const struct cell *cells = rows[i].cells;
		for (j = 0; j < rows[i].count; j++) {
			total += cells[j].value;
		}
	}
	return total;
}

/* The 2-D table walk: two `ExprAt`s per read, in a nested loop. */
static int table_trace(int rows, int cols) {
	int total = 0;
	int i;
	int j;
	for (i = 0; i < rows; i++) {
		for (j = 0; j < cols; j++) {
			total += g_table[i][j];
		}
	}
	return total;
}

/* A pointer walked to the end of the array and read backwards, so the
 * dereference sits behind pointer arithmetic in both directions. */
static int reverse_sum(const int *begin, const int *end) {
	int total = 0;
	const int *q = end;
	while (q > begin) {
		q--;
		total += *q;
	}
	return total;
}

int unsafe_deref_flag_runtime(void) {
	int i;
	int j;
	int n = ROWS * COLS;

	for (i = 0; i < n; i++) {
		g_cells[i].value = i + 1;
		g_cells[i].weight = (i % 3) + 1;
		g_scratch[i] = i;
	}
	for (i = 0; i < ROWS; i++) {
		g_rows[i].cells = &g_cells[i * COLS];
		g_rows[i].count = COLS;
		for (j = 0; j < COLS; j++) {
			g_table[i][j] = (i * COLS) + j;
		}
	}

	/* 1. `*p` in a loop, over the whole array and over a suffix. */
	if (sum_through_pointer(g_scratch, n) != (n * (n - 1)) / 2) return 1;
	if (sum_through_pointer(g_scratch + 10, 5) != 10 + 11 + 12 + 13 + 14) return 2;
	if (sum_through_pointer(g_scratch, 0) != 0) return 3;

	/* 2. `p[i]` must agree with `*p` over the same range. */
	if (sum_indexed(g_scratch, n) != sum_through_pointer(g_scratch, n)) return 4;
	if (sum_indexed(g_scratch + 3, 4) != 3 + 4 + 5 + 6) return 5;

	/* 3. a write through a pointer in a loop, observed by a later read. */
	scale_through_pointer(g_scratch, n, 2);
	if (sum_indexed(g_scratch, n) != n * (n - 1)) return 6;
	scale_through_pointer(g_scratch + 2, 3, 0);
	if (g_scratch[1] != 2 || g_scratch[2] != 0 || g_scratch[4] != 0 || g_scratch[5] != 10) return 7;

	/* 4. `p->field` over an array of structs. */
	{
		int expect = 0;
		for (i = 0; i < n; i++) expect += (i + 1) * ((i % 3) + 1);
		if (weighted_sum(g_cells, n) != expect) return 8;
		if (weighted_sum(g_cells + 4, 2) != 5 * 2 + 6 * 3) return 9;
	}

	/* 5. a pointer field dereferenced one level deeper, nested loop. */
	if (walk_rows(g_rows, ROWS) != (n * (n + 1)) / 2) return 10;
	if (walk_rows(g_rows + 1, 1) != 6 + 7 + 8 + 9 + 10) return 11;

	/* 6. the 2-D table walk. */
	if (table_trace(ROWS, COLS) != (n * (n - 1)) / 2) return 12;
	if (table_trace(1, COLS) != 0 + 1 + 2 + 3 + 4) return 13;
	if (table_trace(0, COLS) != 0) return 14;

	/* 7. read backwards through a pointer that starts past the end. */
	for (i = 0; i < n; i++) g_scratch[i] = i + 1;
	if (reverse_sum(g_scratch, g_scratch + n) != (n * (n + 1)) / 2) return 15;
	if (reverse_sum(g_scratch, g_scratch) != 0) return 16;
	if (reverse_sum(g_scratch + 20, g_scratch + 23) != 21 + 22 + 23) return 17;

	/* 8. the dereference and its guard in one condition, the shape a C
	 *    loop over a NUL-terminated or sentinel-terminated run writes. */
	{
		int seen = 0;
		const int *p = g_scratch;
		while (p < g_scratch + n && *p != 13) {
			seen++;
			p++;
		}
		if (seen != 12) return 18;
		if (*p != 13) return 19;
	}

	/* 9. a struct field written through a pointer inside a loop. */
	for (i = 0; i < ROWS; i++) {
		struct cell *cells = g_rows[i].cells;
		for (j = 0; j < g_rows[i].count; j++) {
			cells[j].weight = cells[j].value + i;
		}
	}
	{
		int expect = 0;
		for (i = 0; i < ROWS; i++) {
			for (j = 0; j < COLS; j++) {
				int index = (i * COLS) + j;
				expect += (index + 1) * (index + 1 + i);
			}
		}
		if (weighted_sum(g_cells, n) != expect) return 20;
	}

	return 0;
}
