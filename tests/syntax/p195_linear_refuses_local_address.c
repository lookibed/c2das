/* `--memory-model linear` fails closed: a scalar parameter whose address is
 * taken is spilled to the C stack (p216), but a by-value record parameter is
 * not, so `&v.x` is refused with a located error, never `addr(v)`. */
struct box { int x; };
static void bump(int *p) { *p += 1; }
static int bumped(struct box v)
{
	int r = 0;
	bump(&v.x);
	return v.x + r;
}

int linear_refuses_local_address(void)
{
	struct box b = { 1 };
	return bumped(b);
}
