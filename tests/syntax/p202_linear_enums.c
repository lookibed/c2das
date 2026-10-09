/* `--memory-model linear`: enumerations are their compatible integer type.
 *
 * Enumeration fields of records in the heap are read, written, compared and
 * switched on; an enumeration local takes ++ and a value outside its
 * enumerators (legal C); a one-byte enumeration (`: unsigned char` is C23,
 * so a packed field of a narrow integer type is used instead) round-trips.
 * The same program compiled by clang and translated with the flag must both
 * return 0, or the number of the first failed check. */
#include <stdlib.h>

typedef enum { FLAG_NONE = 0, FLAG_SUPPORTED = 0x80, FLAG_REQUIRED = 0xc0 } CgbFlag;
typedef enum { MODE_A = -1, MODE_B = 7, MODE_C } Mode;

typedef struct {
	unsigned char tag;
	CgbFlag cgb_flag;
	Mode mode;
} Info;

static const char *flag_name(CgbFlag f)
{
	switch (f) {
	case FLAG_NONE: return "none";
	case FLAG_SUPPORTED: return "supported";
	case FLAG_REQUIRED: return "required";
	}
	return "unknown";
}

int linear_enums(void)
{
	Info *info = calloc(2, sizeof(Info));
	info[0].cgb_flag = FLAG_REQUIRED;
	info[1].cgb_flag = (CgbFlag)0x80;
	info[0].mode = MODE_A;
	info[1].mode = MODE_C;
	int is_cgb = info[0].cgb_flag == FLAG_SUPPORTED || info[0].cgb_flag == FLAG_REQUIRED;
	if (!is_cgb) return 1;
	if (flag_name(info[1].cgb_flag)[0] != 's') return 2;
	if (info[0].mode != -1 || info[1].mode != 8) return 3;
	Mode m = info[1].mode;
	m++;
	if (m != 9) return 4;
	info[1].mode = m;
	if ((int)info[1].mode != 9) return 5;
	CgbFlag *pf = &info[0].cgb_flag;
	*pf = FLAG_NONE;
	if (info[0].cgb_flag != FLAG_NONE) return 6;
	if (flag_name((CgbFlag)7)[0] != 'u') return 7;
	free(info);
	return 0;
}
