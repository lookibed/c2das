#ifndef BINJGB_FIXTURE_STRING_H
#define BINJGB_FIXTURE_STRING_H

/* Fixture string.h: the raw-memory subset the translator lowers in every mode
 * (`memcpy`, `memmove`, `memset`, `memcmp`, `memchr`) plus the two
 * NUL-terminated string calls binjgb's `common.c` makes on file names. */
#include <stddef.h>

void *memcpy(void *dest, const void *src, size_t count);
void *memmove(void *dest, const void *src, size_t count);
void *memset(void *dest, int value, size_t count);
int memcmp(const void *lhs, const void *rhs, size_t count);
void *memchr(const void *block, int value, size_t count);

size_t strlen(const char *text);
char *strrchr(const char *text, int ch);

#endif
