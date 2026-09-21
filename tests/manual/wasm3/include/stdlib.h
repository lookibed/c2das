#ifndef WASM3_FIXTURE_STDLIB_H
#define WASM3_FIXTURE_STDLIB_H

/* Fixture stdlib: allocation plus the two entry points wasm3's core reaches
 * (`abort` from m3_Abort, `strtod` from the text-format value parser).  The
 * allocators are what the translator's raw-memory runtime lowers in every
 * mode; the other two are declared so the C build links, and the translation
 * attempt reports on them. */
#include <stddef.h>

void *malloc(size_t size);
void *calloc(size_t count, size_t size);
void *realloc(void *ptr, size_t size);
void free(void *ptr);

void abort(void);
void exit(int status);

long long strtoll(const char *text, char **end, int base);
unsigned long long strtoull(const char *text, char **end, int base);
double strtod(const char *text, char **end);

#endif
