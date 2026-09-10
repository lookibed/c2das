/* Runtime acceptance: the heap reuses freed memory, has no cumulative cap,
 * aligns blocks, and realloc/calloc behave. Returns 0 on success. */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define MIB (1024u * 1024u)

static int churn(void) {
    /* 200 x 1 MiB with free in between: far more than 64 MiB cumulative. */
    int i = 0;
    while (i < 200) {
        unsigned char *p = (unsigned char *)malloc(MIB);
        if (!p) return 0;
        p[0] = (unsigned char)i;
        p[MIB - 1] = (unsigned char)(i + 1);
        if (p[0] != (unsigned char)i || p[MIB - 1] != (unsigned char)(i + 1)) return 0;
        free(p);
        i++;
    }
    return 1;
}

static int large_live(void) {
    /* 96 MiB live at once. */
    unsigned char *a = (unsigned char *)malloc(48 * MIB);
    unsigned char *b = (unsigned char *)malloc(48 * MIB);
    if (!a || !b) return 0;
    a[48 * MIB - 1] = 1;
    b[48 * MIB - 1] = 2;
    int ok = a[48 * MIB - 1] == 1 && b[48 * MIB - 1] == 2;
    free(a);
    free(b);
    return ok;
}

static int alignment(void) {
    void *p1 = malloc(1);
    void *p2 = malloc(3);
    void *p3 = malloc(100);
    int ok = ((uintptr_t)p1 % 16) == 0 && ((uintptr_t)p2 % 16) == 0 && ((uintptr_t)p3 % 16) == 0;
    free(p1);
    free(p2);
    free(p3);
    return ok;
}

static int realloc_semantics(void) {
    int *p = (int *)malloc(4 * sizeof(int));
    p[0] = 1; p[1] = 2; p[2] = 3; p[3] = 4;
    p = (int *)realloc(p, 1000 * sizeof(int));
    if (!p) return 0;
    p[999] = 5;
    int ok = p[0] == 1 && p[3] == 4 && p[999] == 5;
    int *q = (int *)realloc(0, 2 * sizeof(int));
    q[1] = 9;
    ok = ok && q[1] == 9;
    free(q);
    free(realloc(p, 0) ? p : 0); /* realloc(p, 0) frees; free(NULL) is a no-op */
    return ok;
}

static int calloc_zero(void) {
    unsigned char *p = (unsigned char *)calloc(1000, 4);
    int i = 0;
    int sum = 0;
    while (i < 4000) sum += p[i++];
    free(p);
    return sum == 0;
}

static int reuse_after_free(void) {
    /* Freed memory must be reusable: 4000 x 16 KiB allocations with free
     * would otherwise burn 64 MiB of a non-reusing arena. */
    int i = 0;
    while (i < 4000) {
        char *p = (char *)malloc(16384);
        if (!p) return 0;
        p[16383] = 'x';
        free(p);
        i++;
    }
    return 1;
}

static int mem_functions(void) {
    char *a = (char *)malloc(MIB);
    char *b = (char *)malloc(MIB);
    memset(a, 0x5a, MIB);
    memcpy(b, a, MIB);
    int ok = memcmp(a, b, MIB) == 0 && (unsigned char)b[MIB - 1] == 0x5a;
    memmove(a + 1, a, MIB - 1);
    ok = ok && (unsigned char)a[MIB - 1] == 0x5a;
    a[10] = 0;
    ok = ok && memchr(a, 0, MIB) == a + 10;
    free(a);
    free(b);
    return ok;
}

static int many_small(void) {
    int **ptrs = (int **)malloc(1000 * sizeof(int *));
    int i = 0;
    while (i < 1000) {
        ptrs[i] = (int *)malloc(sizeof(int) * (1 + i % 7));
        *ptrs[i] = i;
        i++;
    }
    int ok = 1;
    i = 0;
    while (i < 1000) {
        if (*ptrs[i] != i) ok = 0;
        free(ptrs[i]);
        i++;
    }
    free(ptrs);
    return ok;
}

int heap_churn_runtime(void) {
    if (!churn()) return 1;
    if (!large_live()) return 2;
    if (!alignment()) return 3;
    if (!realloc_semantics()) return 4;
    if (!calloc_zero()) return 5;
    if (!reuse_after_free()) return 6;
    if (!mem_functions()) return 7;
    if (!many_small()) return 8;
    return 0;
}
