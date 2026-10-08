/* `--memory-model linear` with `--libc eden`: <stdio.h> files over the heap.
 *
 * The file named by argv[1] is opened (path and mode read from C memory),
 * sized with fseek/ftell, read into a malloc'd buffer with fread and closed;
 * fwrite sends heap bytes to stdout; a missing file and a write mode fail
 * under both the C library and the translation (EdenSpark files are read
 * only, so the fixture never creates one).  The same program compiled by
 * clang and translated with the flag must print the same text. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv)
{
	if (argc < 2) return 2;
	FILE *f = fopen(argv[1], "rb");
	if (!f) return 3;
	if (fseek(f, 0, SEEK_END) != 0) return 4;
	long size = ftell(f);
	if (fseek(f, 0, SEEK_SET) != 0) return 5;
	unsigned char *data = calloc(1, size + 1);
	if (fread(data, size, 1, f) != 1) return 6;
	if (fread(data, 1, 4, f) != 0 || !feof(f)) return 7;
	fclose(f);
	unsigned sum = 0;
	for (long i = 0; i < size; i++) sum = sum * 31u + data[i];
	printf("size=%ld sum=%u\n", size, sum);
	fwrite(data, 1, 15, stdout);
	fwrite("\n", 1, 1, stdout);
	free(data);
	if (fopen("p201-no-such-file.bin", "rb") != NULL) return 8;
	return 0;
}
