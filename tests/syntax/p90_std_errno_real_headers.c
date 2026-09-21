/*
 * p90: the same `errno` idiom written the way a real program writes it — the
 * system's own <errno.h>/<stdlib.h>/<stdio.h>, no hand declarations.
 *
 * The constants the *program* compares against come from the unit's own
 * headers, macro-expanded by Clang before the AST; the integers the helpers
 * report come from the target's numbering (`ErrnoNumbering`).  This case is
 * what makes the two agree rather than agreeing by coincidence.
 */
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

int main(void)
{
	long long converted;

	errno = 0;
	converted = strtoll("99999999999999999999", 0, 10);
	printf("over=%lld erange=%d ERANGE=%d EINVAL=%d ENOMEM=%d\n", converted,
	       errno == ERANGE, ERANGE, EINVAL, ENOMEM);

	errno = 0;
	converted = strtoll("10", 0, 37);
	printf("base37=%lld einval=%d\n", converted, errno == EINVAL);
	return 0;
}
