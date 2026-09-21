/*
 * p92: `feof`, `ferror` and `clearerr` around `fread`, including the two
 * shapes real programs use.
 *
 * Lua opens a file with `clearerr(f); errno = 0;` before it reads, and
 * samples `ferror(f)` *before* `fclose` because the handle is gone
 * afterwards; lz4 tells a short read from a failed one the same way.  The
 * stream's error indicator is the module's own sticky flag, and end-of-file
 * is the host's — `clearerr` has to put both back.
 *
 * The file the case reads is written by the case itself, in the working
 * directory the runner gives both programs.
 */
#include <stdio.h>
#include <errno.h>

static char buffer[8];

int main(void)
{
	FILE *f;
	size_t got;

	f = fopen("p92_stream.tmp", "wb");
	if (f == NULL)
		return 1;
	fwrite("0123456789", 1, 10, f);
	printf("write_err=%d\n", ferror(f));
	fclose(f);

	f = fopen("p92_stream.tmp", "rb");
	if (f == NULL)
		return 1;

	/* Lua's prologue. */
	clearerr(f);
	errno = 0;
	printf("fresh eof=%d err=%d errno=%d\n", feof(f) != 0, ferror(f) != 0,
	       errno);

	got = fread(buffer, 1, sizeof buffer, f);
	printf("got=%d eof=%d err=%d\n", (int)got, feof(f) != 0, ferror(f) != 0);

	got = fread(buffer, 1, sizeof buffer, f);
	printf("got=%d eof=%d err=%d\n", (int)got, feof(f) != 0, ferror(f) != 0);

	got = fread(buffer, 1, sizeof buffer, f);
	printf("got=%d eof=%d err=%d\n", (int)got, feof(f) != 0, ferror(f) != 0);

	clearerr(f);
	printf("cleared eof=%d err=%d\n", feof(f) != 0, ferror(f) != 0);

	/* The sample lz4 and Lua take while the handle is still alive. */
	printf("before_close err=%d\n", ferror(f) != 0);
	fclose(f);

	/* A stream the program never opened still answers. */
	printf("stdout eof=%d err=%d\n", feof(stdout) != 0, ferror(stdout) != 0);
	remove("p92_stream.tmp");
	return 0;
}
