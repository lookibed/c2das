#ifndef DOOMGENERIC_FIXTURE_CTYPE_H
#define DOOMGENERIC_FIXTURE_CTYPE_H

/* Fixture ctype.h: the classification and case functions the engine calls,
 * as plain functions with the glibc ABI, which is what the C build links
 * against.  glibc's own header expands `isspace`/`isprint` to a lookup
 * through `__ctype_b_loc()` into a locale table; shadowing it keeps the
 * graph's dependency at the libc entry points the engine actually names, as
 * `tests/manual/wasm3/include/ctype.h` does for wasm3. */

int isspace(int c);
int isprint(int c);
int toupper(int c);
int tolower(int c);

#endif
