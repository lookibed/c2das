/* `--memory-model linear`: locals whose address is taken live in a C stack
 * frame in the heap.
 *
 * `&x`, `&s`, `&s.f`, `&a[i]` and a declared array passed as a pointer give
 * the local a slot in the function's frame; reads and writes of it are heap
 * loads and stores.  A function with a frame is a wrapper that pushes the
 * frame, calls the body and pops it, so early returns, returns from loops
 * and recursion all restore the stack pointer.  Locals whose address is
 * never taken stay daScript locals.  The same program compiled by clang and
 * translated with the flag must both return 0, or the number of the first
 * failed check. */
#include <stdlib.h>
#include <string.h>

struct pt {
	int x;
	double y;
};

static void bump(int *p) { *p += 1; }

static void scale(struct pt *p, int k)
{
	p->x *= k;
	p->y *= k;
}

static int fill(char *dst, int n)
{
	for (int i = 0; i < n; i++) dst[i] = (char)('a' + i);
	dst[n] = 0;
	return n;
}

/* recursion: every level's local has its own slot */
static int depth_sum(int n, int **seen)
{
	int here = n * 10;
	seen[n] = &here;
	if (n == 0) return here;
	int below = depth_sum(n - 1, seen);
	if (*seen[n] != n * 10) return -1000;
	return here + below;
}

/* early return from inside a loop of a function with a frame */
static int find(int want)
{
	int vals[5] = {3, 1, 4, 1, 5};
	int *p = vals;
	for (int i = 0; i < 5; i++) {
		if (p[i] == want) return i;
	}
	return -1;
}

static void void_frame(int *out)
{
	int t = 41;
	bump(&t);
	*out = t;
}

int linear_locals_in_heap(void)
{
	int x = 1;
	bump(&x);
	bump(&x);
	if (x != 3) return 1;
	x += 4;
	if (x != 7) return 2;

	struct pt s = {2, 1.5};
	scale(&s, 3);
	if (s.x != 6 || s.y != 4.5) return 3;
	int *px = &s.x;
	*px = -1;
	if (s.x != -1) return 4;

	char buf[16] = "zz";
	if (strlen(buf) != 2) return 5;
	if (fill(buf, 5) != 5 || strcmp(buf, "abcde") != 0) return 6;
	if (buf[4] != 'e') return 7;
	buf[0] = 'Q';
	if (strcmp(buf, "Qbcde") != 0) return 8;

	int arr[4] = {10, 20, 30, 40};
	int *pa = &arr[2];
	pa[1] += 2;
	if (arr[3] != 42 || *pa != 30) return 9;

	int *seen[6];
	if (depth_sum(5, seen) != 150) return 10;
	if (find(4) != 2 || find(9) != -1) return 11;
	/* the frames above are popped: a later frame reuses the space */
	if (depth_sum(3, seen) != 60) return 12;

	int out = 0;
	void_frame(&out);
	if (out != 42) return 13;

	int plain = 5; /* address never taken: a daScript local */
	for (int i = 0; i < 3; i++) plain += i;
	if (plain != 8) return 14;
	return 0;
}
