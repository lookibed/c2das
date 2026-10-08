/* `--memory-model linear`: every scalar width through a pointer into the
 * heap, pointer arithmetic, differences and comparisons.
 *
 * Under the flag C memory is one `array<uint8>` and a pointer is an `int`
 * offset into it; a load or store of a wider scalar is assembled from bytes
 * in place, and `float`/`double` go through their bit patterns.  The same
 * program compiled by clang and translated with the flag must both return
 * 0, or the number of the first failed check. */
#include <stdint.h>
#include <stdlib.h>

static int scalars(void)
{
	unsigned char *b = malloc(64);
	if (!b) return 100;
	signed char *sc = (signed char *)b;
	sc[0] = -5;
	if (sc[0] != -5) return 1;
	if (b[0] != 251) return 2;

	int16_t *s16 = (int16_t *)(b + 2);
	*s16 = -12345;
	if (*s16 != -12345) return 3;
	uint16_t *u16 = (uint16_t *)(b + 2);
	if (*u16 != 53191) return 4;

	int32_t *s32 = (int32_t *)(b + 4);
	*s32 = -123456789;
	if (*s32 != -123456789) return 5;
	if (b[4] != 0xeb || b[7] != 0xf8) return 6;
	uint32_t *u32 = (uint32_t *)(b + 4);
	*u32 = 0xdeadbeefu;
	if (*u32 != 0xdeadbeefu) return 7;

	int64_t *s64 = (int64_t *)(b + 8);
	*s64 = -1234567890123456789ll;
	if (*s64 != -1234567890123456789ll) return 8;
	uint64_t *u64 = (uint64_t *)(b + 16);
	*u64 = 0xfedcba9876543210ull;
	if (*u64 != 0xfedcba9876543210ull) return 9;
	if (b[16] != 0x10 || b[23] != 0xfe) return 10;

	float *f = (float *)(b + 24);
	*f = -1.5f;
	if (*f != -1.5f) return 11;
	if (*(uint32_t *)(b + 24) != 0xbfc00000u) return 12;
	double *d = (double *)(b + 32);
	*d = 3.141592653589793;
	if (*d != 3.141592653589793) return 13;
	if (*(uint64_t *)(b + 32) != 0x400921fb54442d18ull) return 14;

	/* compound assignment and increments in the heap */
	*s32 = 10;
	*s32 += 5;
	*s32 *= -3;
	if (*s32 != -45) return 15;
	b[0] = 250;
	b[0] += 10; /* wraps */
	if (b[0] != 4) return 16;
	(*u16)++;
	++*u16;
	if (*u16 != 53193) return 17;
	*d -= 1.0;
	if (*d != 3.141592653589793 - 1.0) return 18;
	*u64 >>= 4;
	if (*u64 != 0x0fedcba987654321ull) return 19;
	int old = (*s32)--;
	if (old != -45 || *s32 != -46) return 20;
	free(b);
	return 0;
}

static int arithmetic(void)
{
	int *a = malloc(10 * sizeof(int));
	if (!a) return 100;
	for (int i = 0; i < 10; i++)
		a[i] = i * i - 20;
	int *p = a + 3;
	int *q = &a[8];
	if (*p != -11) return 30;
	if (q - p != 5) return 31;
	if (p - q != -5) return 32;
	if (!(p < q) || p >= q || p == q) return 33;
	p++;
	--q;
	if (*p != -4 || *q != 29) return 34;
	p += 2;
	q -= 1;
	if (p != q) return 35;
	if (p[-1] != 5 || 2[p] != 44) return 36;
	long sum = 0;
	for (int *r = a; r < a + 10; r++)
		sum += *r;
	if (sum != 85) return 37;
	char *c = (char *)a;
	if ((int *)(c + 4) != a + 1) return 38;
	uintptr_t ua = (uintptr_t)a, ub = (uintptr_t)(a + 2);
	if (ub - ua != 8) return 39;
	int *none = NULL;
	if (none) return 40;
	if (none != 0) return 41;
	free(a);
	return 0;
}

int linear_scalars(void)
{
	int r = scalars();
	if (r) return r;
	return arithmetic();
}
