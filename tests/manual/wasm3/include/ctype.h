#ifndef WASM3_FIXTURE_CTYPE_H
#define WASM3_FIXTURE_CTYPE_H

/* Fixture ctype.h: `isspace` as a plain function with the glibc ABI, which is
 * what the C build links against.  glibc's own header expands it to a lookup
 * through `__ctype_b_loc()` into a locale table; shadowing it keeps the
 * graph's dependency at the libc entry point wasm3 actually names, the way
 * the other corpora shadow the system headers they use. */

int isspace(int c);
int isdigit(int c);
int isalpha(int c);
int isprint(int c);
int tolower(int c);
int toupper(int c);

#endif
