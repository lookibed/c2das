/*
 * p91: `strerror` and `perror`, the two errno consumers a C error path
 * reaches for first.
 *
 * The catalogue is glibc's, spelled out in the translator rather than
 * derived, so the text a translated program prints is the text the C
 * reference prints.  `perror` writes to stderr, which the runner does not
 * compare: the case therefore prints the descriptions it checks to stdout and
 * calls `perror` once, so the stderr path is exercised without its wording
 * being part of the oracle.
 */
#include <errno.h>
#include <stdio.h>
#include <string.h>

int main(void)
{
	static const int codes[] = {EPERM,   ENOENT, EINTR,  EIO,    EBADF,
	                            EAGAIN,  ENOMEM, EACCES, EBUSY,  EEXIST,
	                            EISDIR,  EINVAL, ENOSPC, ESPIPE, ERANGE,
	                            EOVERFLOW};
	unsigned i;
	int saved;
	FILE *missing;

	for (i = 0; i < sizeof codes / sizeof codes[0]; i++)
		printf("%d=[%s]\n", codes[i], strerror(codes[i]));
	printf("unknown=[%s]\n", strerror(4242));

	/* The idiom itself: fail, save, report, and find errno unchanged. */
	errno = 0;
	missing = fopen("p91-no-such-file", "rb");
	saved = errno;
	printf("failed=%d saved=%d text=[%s]\n", missing == NULL, saved,
	       strerror(saved));
	/*
	 * The one call whose wording goes to stderr, which the runner does
	 * not compare.  Its effect on errno is deliberately not asserted:
	 * glibc's `perror` writes, and a write of its own may set errno, so
	 * "unchanged" is a property of the stream it happens to be given, not
	 * of `perror`.  What is asserted is that it *reads* the cell — the
	 * description above came from the same value.
	 */
	perror("p91");

	/* strerror must not disturb the cell. */
	errno = EBUSY;
	(void)strerror(ENOENT);
	printf("after_strerror=%d\n", errno == EBUSY);
	return 0;
}
