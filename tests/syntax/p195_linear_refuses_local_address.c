/* `--memory-model linear` fails closed: a local whose address is taken lives
 * in the C stack frame (p199) and a global in the static block (p203), but a
 * parameter's address is not placed in the heap yet, so `&v` is refused
 * with a located error rather than written as `addr(v)`. */
static void bump(int *p) { *p += 1; }

static int bumped(int v)
{
	bump(&v);
	return v;
}

int linear_refuses_local_address(void)
{
	return bumped(1);
}
