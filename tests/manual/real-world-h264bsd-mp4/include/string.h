#ifndef REAL_WORLD_PLMPEG_STRING_H
#define REAL_WORLD_PLMPEG_STRING_H

#include <stddef.h>

void *memcpy(void *dest, const void *src, size_t count);
void *memmove(void *dest, const void *src, size_t count);
void *memset(void *dest, int value, size_t count);
int memcmp(const void *lhs, const void *rhs, size_t count);
void *memchr(const void *src, int value, size_t count);
size_t strlen(const char *src);
char *strdup(const char *src);

#endif
