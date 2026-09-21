#ifndef WASM3_FIXTURE_STRING_H
#define WASM3_FIXTURE_STRING_H

/* Fixture string.h: the raw-memory subset the translator lowers in every mode
 * (`memcpy`, `memmove`, `memset`, `memcmp`, `memchr`) plus the NUL-terminated
 * string calls wasm3's core makes on export and import names. */
#include <stddef.h>

void *memcpy(void *dest, const void *src, size_t count);
void *memmove(void *dest, const void *src, size_t count);
void *memset(void *dest, int value, size_t count);
int memcmp(const void *lhs, const void *rhs, size_t count);
void *memchr(const void *block, int value, size_t count);

size_t strlen(const char *text);
int strcmp(const char *lhs, const char *rhs);
int strncmp(const char *lhs, const char *rhs, size_t count);
char *strcpy(char *dest, const char *src);
char *strcat(char *dest, const char *src);
char *strstr(const char *haystack, const char *needle);

#endif
