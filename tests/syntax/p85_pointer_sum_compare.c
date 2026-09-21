/* Audit acceptance: a pointer *sum* as a comparison operand.
 *
 * C compares pointers by address.  The translator keeps C pointers typed
 * (`T?`), so anything but `==`/`!=` between two pointers of the same daScript
 * type crosses to the raw-address ABI: `reinterpret<uint64>(p) < reinterpret
 * <uint64>(end)`.  When the operand is pointer arithmetic, daslang lowers it
 * to the bound extern `i_das_ptr_add`, and reading that extern's result
 * through an integer slot is a binding the daslang *interpreter* does not
 * have:
 *
 *     var a : uint64 = unsafe(reinterpret<uint64>(unsafe(p + int(4))))
 *     EXCEPTION: internal binding error: typed eval on wrong extern return
 *                kind, i_das_ptr_add
 *
 * The JIT, `-exe` and the AOT C++ run the same text.  (Reported as
 * https://github.com/lookibed/daScript/issues/3.)  The translator names the
 * pointer before reading its address — `var t : T? = unsafe(p + int(4))` —
 * which runs in every mode and needs nothing known about the pointee.
 *
 * The shape is the bounds check every parser writes, and wasm3 has five of
 * them (`m3_parse.c`, `m3_compile.c`, `m3_bind.c`).  Pinned here over both a
 * byte buffer and an `int` array, because the element size decides the offset
 * daslang's extern applies, and in loops, because the comparison then sits in
 * a block the CFG re-enters — a temporary hoisted out of the loop instead of
 * re-evaluated inside it would give the wrong answer from the second
 * iteration on.
 *
 * Returns 0 on success, or the number of the first failed check. */

static char g_bytes[16];
static int g_ints[8];

/* `p + i < end`: the sum on the left, a plain pointer on the right. */
static int count_while_in_bounds(const char *p, const char *end) {
	int i = 0;
	while (p + i < end) {
		i++;
	}
	return i;
}

/* `q - 1 >= base`: a pointer difference on the left, walking backwards. */
static int count_back_to_base(const int *q, const int *base) {
	int n = 0;
	while (q - 1 >= base) {
		q = q - 1;
		n++;
	}
	return n;
}

/* Both operands are sums. */
static int overlap(const char *a, int ia, const char *b, int ib) {
	return a + ia <= b + ib;
}

int pointer_sum_compare_runtime(void) {
	const char *base = g_bytes;
	const char *end = g_bytes + 16;
	const int *ibase = g_ints;
	const int *iend = g_ints + 8;
	int i;
	int seen;

	for (i = 0; i < 16; i++) g_bytes[i] = (char)i;
	for (i = 0; i < 8; i++) g_ints[i] = i * 10;

	/* 1. the sum as a comparison operand, straight-line. */
	if (!(base + 4 < end)) return 1;
	if (base + 16 < end) return 2;
	if (!(base + 16 <= end)) return 3;
	if (!(end - 1 >= base)) return 4;
	if (end - 16 > base) return 5;
	if (!(end - 16 == base)) return 6;
	if (base + 3 != g_bytes + 3) return 7;

	/* 2. the same over an `int` array, where the element size is 4. */
	if (!(ibase + 7 < iend)) return 8;
	if (ibase + 8 < iend) return 9;
	if (!(iend - 8 >= ibase)) return 10;
	if (!(ibase + 2 > ibase)) return 11;

	/* 3. in a loop, where the operand is re-evaluated every iteration. */
	if (count_while_in_bounds(base, end) != 16) return 12;
	if (count_while_in_bounds(base + 10, end) != 6) return 13;
	if (count_while_in_bounds(end, end) != 0) return 14;
	if (count_back_to_base(iend, ibase) != 8) return 15;
	if (count_back_to_base(ibase + 3, ibase) != 3) return 16;

	/* 4. both operands are sums. */
	if (!overlap(base, 2, base, 5)) return 17;
	if (overlap(base, 9, base, 5)) return 18;
	if (!overlap(base, 5, base, 5)) return 19;

	/* 5. the comparison inside a condition that also reads through the
	 *    pointer, so the named operand and the load share a statement. */
	seen = 0;
	for (i = 0; i < 20; i++) {
		if (base + i < end && g_bytes[i] == (char)i) {
			seen++;
		}
	}
	if (seen != 16) return 20;

	/* 6. a sum compared against a raw integer address, the mixed
	 *    pointer/integer form of the same crossing. */
	{
		unsigned long limit = (unsigned long)(end);
		if (!((unsigned long)(base + 4) < limit)) return 21;
		if ((unsigned long)(base + 16) < limit) return 22;
	}

	return 0;
}
