/* `--memory-model linear`: the <string.h> string functions over the heap.
 *
 * strchr, strrchr, strcmp, strncmp, strcpy, strncpy, strcat and strstr read
 * and write C strings in the heap: string literals in the static block and
 * malloc'd buffers.  Characters compare as unsigned char; strchr/strrchr
 * find the terminator; strncpy pads with zeros.  The same program compiled
 * by clang and translated with the flag must both return 0, or the number
 * of the first failed check. */
#include <stdlib.h>
#include <string.h>

static int sign(int v)
{
	return v < 0 ? -1 : v > 0 ? 1 : 0;
}

int linear_strings(void)
{
	const char *path = "dir/sub/name.gbc";
	const char *dot = strrchr(path, '.');
	if (!dot || dot - path != 12) return 1;
	if (strrchr(path, '/') - path != 7) return 2;
	if (strrchr(path, 'z') != NULL) return 3;
	if (strrchr(path, 0) != path + 16) return 4;
	if (strchr(path, '/') - path != 3) return 5;
	if (strchr(path, 0) != path + 16) return 6;
	if (strchr(path, 'q') != NULL) return 7;

	if (strcmp("abc", "abc") != 0) return 10;
	if (sign(strcmp("abc", "abd")) != -1) return 11;
	if (sign(strcmp("abc", "ab")) != 1) return 12;
	if (sign(strcmp("a\xff", "a\x01")) != 1) return 13; /* unsigned char */
	if (strncmp("abcdef", "abcxyz", 3) != 0) return 14;
	if (sign(strncmp("abcdef", "abcxyz", 4)) != -1) return 15;
	if (strncmp("ab", "ab", 10) != 0) return 16;
	if (strncmp("x", "y", 0) != 0) return 17;

	char *buf = malloc(32);
	if (!buf) return 100;
	memset(buf, 'Z', 32);
	if (strcpy(buf, "hello") != buf || strlen(buf) != 5) return 20;
	if (strcat(buf, ", world") != buf || strcmp(buf, "hello, world") != 0) return 21;
	if (strstr(buf, "world") - buf != 7) return 22;
	if (strstr(buf, "") != buf) return 23;
	if (strstr(buf, "worlds") != NULL) return 24;
	if (strstr(buf, "o") - buf != 4) return 25;

	memset(buf, 'Z', 32);
	strncpy(buf, "abc", 6);
	if (memcmp(buf, "abc\0\0\0Z", 7) != 0) return 30;
	strncpy(buf, "abcdefgh", 4);
	if (memcmp(buf, "abcd\0\0Z", 7) != 0) return 31;

	/* a file name rewritten as replace_extension does */
	strcpy(buf, path);
	char *ext = strrchr(buf, '.');
	strcpy(ext, ".sav");
	if (strcmp(buf, "dir/sub/name.sav") != 0) return 40;
	free(buf);
	return 0;
}
