/* `--memory-model linear`: function pointers stored in the heap.
 *
 * A record in malloc'd memory holds callbacks (a memory map's read/write
 * handlers, as binjgb's emulator does); they are stored, compared with each
 * other and with NULL, copied and called through the record.  In the heap a
 * function pointer is an index into its signature's function table.  The
 * same program compiled by clang and translated with the flag must both
 * return 0, or the number of the first failed check. */
#include <stdlib.h>

typedef struct Emu Emu;
typedef unsigned char (*ReadFn)(Emu *, int);
typedef void (*WriteFn)(Emu *, int, unsigned char);

typedef struct {
	ReadFn read_ext_ram;
	WriteFn write_ext_ram;
} MemoryMap;

struct Emu {
	int bank;
	MemoryMap memory_map;
	unsigned char ram[16];
};

static unsigned char read_plain(Emu *e, int addr) { return e->ram[addr & 15]; }
static unsigned char read_banked(Emu *e, int addr) { return (unsigned char)(e->ram[addr & 15] + e->bank); }
static void write_plain(Emu *e, int addr, unsigned char v) { e->ram[addr & 15] = v; }

static void set_map(Emu *e, int banked)
{
	e->memory_map.read_ext_ram = banked ? read_banked : read_plain;
	e->memory_map.write_ext_ram = write_plain;
}

int linear_function_pointers(void)
{
	Emu *e = calloc(1, sizeof(Emu));
	if (e->memory_map.read_ext_ram != NULL) return 1;
	set_map(e, 0);
	e->memory_map.write_ext_ram(e, 3, 40);
	if (e->memory_map.read_ext_ram(e, 3) != 40) return 2;
	if (e->memory_map.read_ext_ram != read_plain) return 3;
	e->bank = 2;
	set_map(e, 1);
	if (e->memory_map.read_ext_ram(e, 19) != 42) return 4;
	MemoryMap copy = e->memory_map;
	if (copy.read_ext_ram != read_banked) return 5;
	ReadFn f = e->memory_map.read_ext_ram;
	if (f(e, 3) != 42) return 6;
	e->memory_map.read_ext_ram = NULL;
	if (e->memory_map.read_ext_ram) return 7;
	free(e);
	return 0;
}
