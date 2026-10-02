/* File-scope objects of storage-backed record type, and arrays of them.
 *
 * C zero-initialises every object of static storage duration (C11 6.7.9p10),
 * and lays an array's elements out contiguously (6.2.5p20).  A pointer to a
 * storage-backed record is its byte address, so:
 *
 * - an uninitialised global of such a type has its zeroed storage (Doom's
 *   `colors`, `playerstarts`, `intercepts`, `thinkercap`; daslang refused the
 *   bare declaration, `error[31014]`);
 * - an array of them is one block, each element a slice of it, so `a + i`,
 *   `p - a`, `++p` and `memset(a, 0, sizeof a)` see C's layout;
 * - pointer arithmetic on such a pointer steps by Clang's object size, not by
 *   the eight bytes of the daScript wrapper (Doom's `filelump_t *` walk over
 *   the WAD directory in `W_AddFile`);
 * - an array *field* of a storage-backed record is bytes inside it
 *   (`&mtexture->patches[0]`, `R_InitTextures`). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct __attribute__((packed)) {
    unsigned char kind;
    int value;
    char name[7];
} entry_t;

typedef struct {
    unsigned r : 8;
    unsigned g : 8;
    unsigned b : 8;
} color_t;

typedef struct __attribute__((packed)) {
    short width;
    short count;
    entry_t entries[3];
} table_t;

static entry_t entries[4];
static color_t colors[3];
static entry_t single;
static table_t grid[2][2];

static int sum_values(const entry_t *first, const entry_t *end) {
    int sum = 0;
    for (; first < end; first++) {
        sum += first->value;
    }
    return sum;
}

int main(void) {
    entry_t *heap = malloc(sizeof(entry_t) * 5);
    entry_t *p;
    entry_t *q;
    table_t *t;
    int i;

    printf("zero %d %d %u %d %d\n", entries[3].value, single.value, colors[2].g, grid[1][1].entries[2].value,
           grid[1][0].count);

    for (i = 0; i < 4; i++) {
        entries[i].kind = (unsigned char)i;
        entries[i].value = 10 * (i + 1);
    }
    p = entries;
    q = entries + 3;
    printf("array %d %d %ld %d\n", sum_values(entries, entries + 4), (q - 1)->value, (long)(q - p),
           (p + 2)->kind);
    p++;
    p += 2;
    p -= 1;
    printf("step %d %ld\n", p->value, (long)(p - entries));
    memset(entries, 0, sizeof entries);
    printf("cleared %d %d\n", entries[0].value, entries[3].value);

    for (i = 0; i < 5; i++) {
        heap[i].value = i * i;
    }
    q = heap;
    for (i = 0; i < 5; i++) {
        q++;
    }
    printf("heap %d %d %ld\n", sum_values(heap, q), heap[4].value, (long)(q - heap));

    colors[1].g = 200;
    colors[2].b = 7;
    printf("colors %u %u\n", colors[1].g, (colors + 2)->b);

    t = &grid[1][0];
    t->count = 2;
    t->entries[1].value = 77;
    (&t->entries[0] + 2)->value = 88;
    printf("field %d %d %d %d\n", grid[1][0].entries[1].value, grid[1][0].entries[2].value,
           sum_values(&t->entries[0], &t->entries[3]), grid[1][0].count);
    free(heap);
    return 0;
}
