/* `--memory-model linear`: records with bitfields in the heap.
 *
 * A bitfield record in the heap is its bytes at Clang's layout: each run of
 * bitfields is a storage unit at Clang's offset.  A bitfield through a
 * pointer loads the unit, shifts and masks (sign-extending a signed field);
 * a store is a read-modify-write of the unit.  Whole-record copies move the
 * units.  Covered: a global array whose address is taken and a malloc'd
 * array, signed and unsigned fields, a field as wide as its unit, 1-bit
 * flags, two units (one of 2 bytes, one of 8), compound assignment and `++`
 * through a pointer, record copies between heap and daScript values, a
 * static initializer, and Doom's `struct color colors[256]` with
 * `&colors[i]` passed to a function.  The same program compiled by clang
 * and translated with the flags must both return 0, or the number of the
 * first failed check. */
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

struct color {
	uint32_t b:8;
	uint32_t g:8;
	uint32_t r:8;
	uint32_t a:8;
};

static struct color colors[256];

struct mixed {
	unsigned short on : 1;
	unsigned short mode : 3;
	signed short delta : 5;
	unsigned short dirty : 1;
	int tag;
	long long big : 40;
	unsigned long long small : 7;
	unsigned long long flag : 1;
};

struct switches {
	_Bool on : 1;
	_Bool off : 1;
	unsigned char level : 6;
};

static struct mixed table[3] = {
	{1, 5, -3, 0, 77, -123456789012LL, 100, 1},
	{0, 2, 9, 1, -1, 5, 3, 0},
};

static void set_color(struct color *c, int i)
{
	c->r = i;
	c->g = 255 - i;
	c->b = i * 3;
	c->a = 0xff;
}

static unsigned color_word(const struct color *c)
{
	unsigned w;
	memcpy(&w, c, sizeof w);
	return w;
}

static int check_mixed(struct mixed *m)
{
	if (m->on != 1 || m->mode != 5 || m->delta != -3 || m->dirty != 0) return 1;
	if (m->tag != 77 || m->big != -123456789012LL || m->small != 100 || !m->flag) return 2;
	m->delta = -16;
	if (m->delta != -16 || m->mode != 5 || m->dirty != 0) return 3;
	m->delta += 31;
	if (m->delta != 15) return 4;
	m->delta++;
	if (m->delta != -16) return 5;
	++m->mode;
	m->mode += 2;
	if (m->mode != 0 || m->on != 1) return 6;
	m->dirty = 1;
	m->on = 0;
	if (m->dirty != 1 || m->on != 0 || m->delta != -16) return 7;
	m->big -= 1;
	m->small |= 0x7f;
	m->small++;
	if (m->big != -123456789013LL || m->small != 0 || m->tag != 77) return 8;
	m->flag = 0;
	if (m->flag || m->small != 0) return 9;
	int v = (m->mode = 9);
	if (v != 1 || m->mode != 1) return 10;
	return 0;
}

int linear_heap_bitfields(void)
{
	for (int i = 0; i < 256; i++)
		set_color(&colors[i], i);
	struct color *pal = colors;
	if (pal[7].r != 7 || pal[7].g != 248 || pal[7].b != 21 || pal[7].a != 255) return 11;
	if (colors[100].b != (300 & 0xff)) return 12;
	if (color_word(&colors[1]) != 0xff01fe03u) return 13;
	if (sizeof(struct color) != 4) return 14;

	int r = check_mixed(&table[0]);
	if (r) return 20 + r;
	if (table[1].mode != 2 || table[1].delta != 9 || table[1].tag != -1 || table[1].big != 5) return 40;
	if (table[2].on || table[2].mode || table[2].tag || table[2].big || table[2].flag) return 41;

	struct mixed *h = malloc(4 * sizeof *h);
	memset(h, 0, 4 * sizeof *h);
	h[1] = table[1];
	if (h[1].mode != 2 || h[1].delta != 9 || h[1].dirty != 1 || h[1].small != 3) return 42;
	struct mixed local = h[1];
	if (local.delta != 9 || local.tag != -1 || local.dirty != 1) return 43;
	local.delta = -7;
	local.small = 99;
	h[2] = local;
	if (h[2].delta != -7 || h[2].small != 99 || h[2].mode != 2) return 44;
	*(h + 3) = *(h + 2);
	h[3].mode = 7;
	if (h[3].delta != -7 || h[3].mode != 7 || h[2].mode != 2) return 45;
	for (int i = 0; i < 4; i++)
		h[i].on = i & 1;
	if (h[0].on || !h[1].on || h[2].on || !h[3].on) return 46;
	if (h[3].delta != -7 || h[3].small != 99) return 47;
	free(h);

	struct color *cs = malloc(2 * sizeof *cs);
	cs[0] = colors[9];
	cs[1] = cs[0];
	cs[1].a -= 15;
	if (cs[1].r != 9 || cs[1].g != 246 || cs[1].b != 27 || cs[1].a != 240 || cs[0].a != 255) return 50;
	free(cs);

	struct switches *sw = calloc(2, sizeof *sw);
	sw[1].on = 1;
	sw[1].level = 63;
	sw[1].off = 5;
	sw[1].level -= 1;
	if (!sw[1].on || !sw[1].off || sw[1].level != 62 || sw[0].on || sw[0].level) return 51;
	sw[1].on = 0;
	if (sw[1].on || !sw[1].off || sw[1].level != 62) return 52;
	free(sw);
	return 0;
}
