/*
 * p93: why `fopen` failed.
 *
 * daslib answers a bare null; C answers a null *and* a reason, and the reason
 * is the first thing a program's error path prints.  The three the module can
 * tell apart are synthesized from the path itself: the file is not there
 * (ENOENT), it is a directory (EISDIR), or the mode was never a C mode
 * (EINVAL).  A successful open must leave a previously set errno alone.
 *
 * argv[1] is a regular file that exists — this very source, handed over by
 * the runner — and the directory it lives in is derived from it, so the case
 * needs nothing it did not receive.
 */
#include <errno.h>
#include <stdio.h>
#include <string.h>

static char directory[4096];

int main(int argc, char **argv)
{
	FILE *f;
	char *slash;

	if (argc < 2)
		return 1;

	errno = 0;
	f = fopen("p93-no-such-file-anywhere", "rb");
	printf("missing null=%d enoent=%d\n", f == NULL, errno == ENOENT);

	errno = 0;
	f = fopen(argv[1], "q");
	printf("badmode null=%d einval=%d\n", f == NULL, errno == EINVAL);

	strcpy(directory, argv[1]);
	slash = strrchr(directory, '/');
	if (slash == NULL)
		return 1;
	*slash = '\0';
	errno = 0;
	f = fopen(directory, "wb");
	printf("dir_write null=%d eisdir=%d\n", f == NULL, errno == EISDIR);

	errno = 77;
	f = fopen(argv[1], "rb");
	printf("opened=%d kept=%d\n", f != NULL, errno == 77);
	if (f == NULL)
		return 1;

	/* A close that succeeds does not clear a set errno either. */
	errno = 55;
	printf("closed=%d kept=%d\n", fclose(f) == 0, errno == 55);
	return 0;
}
