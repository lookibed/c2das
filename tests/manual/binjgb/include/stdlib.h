#ifndef BINJGB_FIXTURE_STDLIB_H
#define BINJGB_FIXTURE_STDLIB_H

/* Fixture stdlib: the allocators binjgb reaches through `memory.h`
 * (`xmalloc`, `xcalloc`, `xrealloc`, `xfree` are `#define`d to them there,
 * `xstrdup` to `strdup`, which the core never expands) and `exit`, which its
 * `UNREACHABLE` macro calls.  Declared with the glibc ABI so the C build
 * links against the real libc. */
#include <stddef.h>

void *malloc(size_t size);
void *calloc(size_t count, size_t size);
void *realloc(void *ptr, size_t size);
void free(void *ptr);

void abort(void);
void exit(int status);

#endif
