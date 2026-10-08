/* `--memory-model linear`: the printf family over the heap.
 *
 * printf, fprintf, sprintf, snprintf and vsnprintf read the format and every
 * %s argument from C memory (string literals in the static block, malloc'd
 * and stack buffers) and write buffers there with snprintf's truncation
 * rule.  Flags, width, precision (also `*`), length modifiers, %d %i %u %x
 * %X %o %c %s %%.  The same program compiled by clang and translated with
 * the flag must print the same text and return 0, or the number of the
 * first failed check. */
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int format_into(char *dst, size_t size, const char *fmt, ...)
{
	va_list ap;
	va_start(ap, fmt);
	int n = vsnprintf(dst, size, fmt, ap);
	va_end(ap);
	return n;
}

int linear_printf(void)
{
	char buf[64];
	const char *name = "cgb-acid2.gbc";
	const char *dot = strrchr(name, '.');

	int n = snprintf(buf, sizeof buf, "%s%s", "rom", ".sav");
	if (n != 7 || strcmp(buf, "rom.sav") != 0) return 1;
	n = snprintf(buf, sizeof buf, "%.*s%s", (int)(dot - name), name, ".sav");
	if (n != 13 || strcmp(buf, "cgb-acid2.sav") != 0) return 2;
	n = snprintf(buf, 5, "%d-%d", 1234, 5678);
	if (n != 9 || strcmp(buf, "1234") != 0) return 3;
	n = snprintf(NULL, 0, "%u", 4000000000u);
	if (n != 10) return 4;

	char *heap = malloc(32);
	n = sprintf(heap, "[%5d|%-5d|%05d|%+d|% d]", 42, 42, -42, 7, 7);
	if (n != 25 || strcmp(heap, "[   42|42   |-0042|+7| 7]") != 0) return 5;
	n = sprintf(heap, "%x %X %#x %o %#o %c%%", 255u, 255u, 255u, 8u, 8u, 'z');
	if (strcmp(heap, "ff FF 0xff 10 010 z%") != 0) return 6;
	n = sprintf(heap, "%hhd %hd %ld %lld %zu", 300, 70000, -5L, -6LL, (size_t)9);
	if (strcmp(heap, "44 4464 -5 -6 9") != 0) return 7;
	n = format_into(heap, 32, "<%*s|%-*s|%.2s>", 4, "ab", 3, "c", "xyz");
	if (n != 13 || strcmp(heap, "<  ab|c  |xy>") != 0) return 8;
	n = sprintf(heap, "%.3d|%.0d|%3c", 5, 0, 'q');
	if (strcmp(heap, "005||  q") != 0) return 9;

	printf("title: \"%s\"\n", heap);
	printf("header checksum: 0x%02x [%s]\n", 0xeb, "OK");
	fprintf(stdout, "%s=%d\n", buf, -2147483647 - 1);
	free(heap);
	return 0;
}
