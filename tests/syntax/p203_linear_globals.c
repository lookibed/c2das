/* `--memory-model linear`: objects of static duration in the heap.
 *
 * A global or function-scope `static` whose address is taken, or whose
 * array decays to a pointer, lives in the static block with its initial
 * bytes: integer scalars and arrays, records of them (designated and partial
 * initializers), string-literal pointer tables.  Direct reads and writes of
 * the name and accesses through pointers see the same bytes.  The same
 * program compiled by clang and translated with the flag must both return 0,
 * or the number of the first failed check. */
#include <string.h>

typedef struct { unsigned color[4]; } Pal;
typedef struct { Pal bgp, obp0; short tag; } Palettes;

static const Palettes s_palettes[] = {
	{{{0xFFFFFFFF, 0xFFAAAAAA, 0xFF555555, 0xFF000000}}, {{1, 2, 3, 4}}, -7},
	{{{5, 6}}, {{7}}},
};

static int counter = 1;
static unsigned char table[8] = {9, 8, 7};

static void bump(int *p) { *p += 1; }

static const char *result_string(int value)
{
	static const char *s_strings[] = {[0] = "OK", [2] = "ERROR"};
	if (value < 0 || value >= 3 || !s_strings[value]) return "?";
	return s_strings[value];
}

static int next_id(void)
{
	static int id = 100;
	int *p = &id;
	return (*p)++;
}

int linear_globals(void)
{
	bump(&counter);
	bump(&counter);
	if (counter != 3) return 1;
	counter = 10;
	int *pc = &counter;
	if (*pc != 10) return 2;

	unsigned char buf[8];
	memcpy(buf, table, sizeof table);
	if (buf[0] != 9 || buf[2] != 7 || buf[7] != 0) return 3;
	table[3] = 42;
	unsigned char *pt = table;
	if (pt[3] != 42) return 4;

	const Palettes *pal = &s_palettes[0];
	if (pal->bgp.color[1] != 0xFFAAAAAAu || pal->obp0.color[3] != 4 || pal->tag != -7) return 5;
	if (s_palettes[1].bgp.color[1] != 6 || s_palettes[1].bgp.color[2] != 0) return 6;
	if (s_palettes[1].obp0.color[0] != 7 || s_palettes[1].tag != 0) return 7;

	if (strcmp(result_string(0), "OK") != 0) return 8;
	if (strcmp(result_string(1), "?") != 0) return 9;
	if (strcmp(result_string(2), "ERROR") != 0) return 10;

	if (next_id() != 100 || next_id() != 101) return 11;
	return 0;
}
