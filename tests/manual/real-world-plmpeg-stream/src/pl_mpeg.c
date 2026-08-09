#include <stddef.h>
#include <stdint.h>

void *malloc(size_t size);
void free(void *ptr);
void *realloc(void *ptr, size_t size);

#define PLM_NO_STDIO
#define PLM_MALLOC(sz) malloc(sz)
#define PLM_FREE(ptr) free(ptr)
#define PLM_REALLOC(ptr, sz) realloc(ptr, sz)
#define PL_MPEG_IMPLEMENTATION
#include "../upstream/pl_mpeg.h"
