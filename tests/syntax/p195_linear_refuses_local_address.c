/* `--memory-model linear` fails closed: the address of a local lives on a C
 * stack in the heap only under step 4 (`--locals-in-heap`), so until then
 * `&x` is refused with a located error rather than written as `addr(x)`. */
static void bump(int *p) { *p += 1; }

int linear_refuses_local_address(void)
{
	int x = 1;
	bump(&x);
	return x;
}
