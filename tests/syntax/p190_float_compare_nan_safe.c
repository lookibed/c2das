/* `--float-compare nan-safe`: every C floating comparison keeps its IEEE
 * result when an operand is NaN.
 *
 * The EdenSpark editor's daslang compares NaN wrongly (`NaN == NaN` true,
 * `NaN < 1` true; docs/eden-target.md §3), so under the flag the translator
 * routes each float/double `==`, `!=`, `<`, `<=`, `>`, `>=` — and the
 * `x != 0` / `x == 0` of C truthiness and `!x` — through a helper that
 * decides NaN by a bit test first.  On master daslang the plain comparison is
 * already IEEE, so this fixture proves the guarded form computes exactly C's
 * answer: the same program compiled by clang and translated with the flag
 * must both return 0.  The NaNs are made at run time (0/0, and its negation,
 * which sets the sign bit) so no constant folding decides a comparison.
 *
 * Returns 0 on success, or the number of the first failed check. */

static double dzero(void) { return 0.0; }
static float fzero(void) { return 0.0f; }

static int check_double(double a, double b, int eq, int ne, int lt, int le, int gt, int ge)
{
	if ((a == b) != eq) return 1;
	if ((a != b) != ne) return 2;
	if ((a < b) != lt) return 3;
	if ((a <= b) != le) return 4;
	if ((a > b) != gt) return 5;
	if ((a >= b) != ge) return 6;
	return 0;
}

static int check_float(float a, float b, int eq, int ne, int lt, int le, int gt, int ge)
{
	if ((a == b) != eq) return 1;
	if ((a != b) != ne) return 2;
	if ((a < b) != lt) return 3;
	if ((a <= b) != le) return 4;
	if ((a > b) != gt) return 5;
	if ((a >= b) != ge) return 6;
	return 0;
}

int float_compare_nan_safe(void)
{
	double dnan = dzero() / dzero();
	double dneg = -dnan;
	double dinf = 1.0 / dzero();
	float fnan = fzero() / fzero();
	float finf = 1.0f / fzero();
	int r;

	/*                         a     b      ==  !=  <   <=  >   >= */
	if ((r = check_double(dnan, dnan, 0, 1, 0, 0, 0, 0))) return 10 + r;
	if ((r = check_double(dnan, 1.0, 0, 1, 0, 0, 0, 0))) return 20 + r;
	if ((r = check_double(1.0, dnan, 0, 1, 0, 0, 0, 0))) return 30 + r;
	if ((r = check_double(dneg, 0.0, 0, 1, 0, 0, 0, 0))) return 40 + r;
	if ((r = check_double(dnan, dinf, 0, 1, 0, 0, 0, 0))) return 50 + r;
	if ((r = check_double(1.0, 2.0, 0, 1, 1, 1, 0, 0))) return 60 + r;
	if ((r = check_double(2.0, 2.0, 1, 0, 0, 1, 0, 1))) return 70 + r;
	if ((r = check_double(-0.0, 0.0, 1, 0, 0, 1, 0, 1))) return 80 + r;
	if ((r = check_double(dinf, 1.0, 0, 1, 0, 0, 1, 1))) return 90 + r;
	if ((r = check_float(fnan, fnan, 0, 1, 0, 0, 0, 0))) return 110 + r;
	if ((r = check_float(fnan, 1.0f, 0, 1, 0, 0, 0, 0))) return 120 + r;
	if ((r = check_float(-fnan, 0.0f, 0, 1, 0, 0, 0, 0))) return 130 + r;
	if ((r = check_float(1.5f, 0.5f, 0, 1, 0, 0, 1, 1))) return 140 + r;
	if ((r = check_float(finf, finf, 1, 0, 0, 1, 0, 1))) return 150 + r;

	/* C truthiness: a NaN is non-zero, so it is true and `!nan` is false. */
	if (!dnan) return 200;
	if (dnan) { } else return 201;
	if (!fnan) return 202;
	if (!(fnan ? 1 : 0)) return 203;
	if (!dzero() == 0) return 204;
	{
		/* A loop whose condition is a NaN-sensitive compare: it must not
		 * run, since `nan < 3.0` is false. */
		int iterations = 0;
		for (double x = dnan; x < 3.0; x += 1.0) {
			if (++iterations > 5) break;
		}
		if (iterations != 0) return 205;
	}
	return 0;
}
