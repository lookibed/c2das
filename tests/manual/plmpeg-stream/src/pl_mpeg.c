#include <stddef.h>
#include <stdint.h>

void *malloc(size_t size);
void free(void *ptr);
void *realloc(void *ptr, size_t size);

#ifndef PLM_NO_STDIO
#define PLM_NO_STDIO
#endif

/* `abs` is ordinary decoder arithmetic, not part of the raw-memory runtime.
 * Bind the single-header implementation to a local C helper so the target
 * graph never depends on shim.c's reference-side libc implementation. */
int plmpeg_abs(int value) {
    return value < 0 ? -value : value;
}

#define abs plmpeg_abs
#define PLM_MALLOC(sz) malloc(sz)
#define PLM_FREE(ptr) free(ptr)
#define PLM_REALLOC(ptr, sz) realloc(ptr, sz)
#define PL_MPEG_IMPLEMENTATION
#include "../upstream/pl_mpeg.h"
