/* `--memory-model linear` fails closed: a local whose address is taken lives
 * in the C stack frame (p199), but a global's address is not placed in the
 * heap yet, so `&counter` is refused with a located error rather than
 * written as `addr(counter)`. */
static void bump(int *p) { *p += 1; }

static int counter = 1;

int linear_refuses_local_address(void)
{
	bump(&counter);
	return counter;
}
