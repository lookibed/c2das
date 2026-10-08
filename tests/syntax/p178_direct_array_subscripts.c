/* A subscript of a declared array variable — a global, a local, a static,
 * an element of an array of arrays — is daslang's own fixed-array index
 * `a[i]`, never the decayed address `addr(a[0])` indexed as a pointer.  An
 * element of an array of natural records is `a[i].field`.  Compound
 * assignment and `++`/`--` work on the element in place.  C indexes a
 * declared array only inside it (C11 6.5.6p8): an index past the end raises
 * daslang's located exception; `--unsafe-deref` drops that check too
 * (`hint(unsafe_range_check)`) and reads the neighbouring bytes as C does.
 *
 * An array *field* of a natural record (`plane->top[x]`, `plane.top[x]`)
 * keeps its bytes at the Clang offset in both builds, because C code
 * indexes past a field array into the fields declared beside it on purpose
 * (Doom's visplane `pad` fields, `top[minx - 1]` among them), which the
 * checked index refuses and daslang's unchecked index scales in `uint32`.
 *
 * What else keeps the pointer form: the address of an element (`&a[i]`;
 * `&a[N]` is the legal one-past-the-end pointer C allows and a fixed-array
 * index refuses), a subscript of a decayed pointer (a parameter `int a[]`,
 * a pointer variable), an array member of a union (bytes at a Clang
 * offset), and the struct hack — a trailing one-element array field indexed
 * into memory allocated past the record (`pg->code[i]`). */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ROWS 3
#define COLS 4

struct point {
    int x;
    int y;
};

struct plane {
    int id;
    unsigned short top[8];
    unsigned short bottom[8];
    struct point corners[2];
};

union word {
    uint32_t u;
    uint8_t bytes[4];
};

struct tagged {
    int kind;
    union word w;
};

static short ceilingclip[16];
static short floorclip[16];
static int grid[ROWS][COLS];
static struct point points[4];
static struct plane planes[2];
static const int table[5] = {10, 20, 30, 40, 50};

static int sum_decayed(const int a[], int n) {
    int s = 0;
    for (int i = 0; i < n; i++)
        s += a[i];
    return s;
}

static int fill_plane(struct plane *plane, int x, int v) {
    plane->top[x] = (unsigned short)v;
    plane->bottom[x] += (unsigned short)(v * 2);
    plane->top[x]++;
    plane->corners[x & 1].x = v;
    plane->corners[x & 1].y += v;
    return plane->top[x] + plane->bottom[x] + plane->corners[x & 1].y;
}

static int read_plane(const struct plane *plane, int x) {
    return plane->top[x] - plane->bottom[x] + plane->corners[x & 1].x;
}

static int by_value(struct plane plane, int x) {
    plane.top[x] = 7;
    plane.top[x] += 1;
    return plane.top[x] + plane.corners[1].y;
}

static int row_sum(int row) {
    int s = 0;
    for (int j = 0; j < COLS; j++)
        s += grid[row][j];
    return s;
}

static unsigned tagged_bytes(struct tagged *t, int i) {
    t->w.bytes[i] = (uint8_t)(i + 1);
    return t->w.u;
}

/* The struct hack: `code[1]` is indexed into the bytes malloc'd past the
 * record, so the subscript stays a pointer index at the field's offset. */
struct page {
    int count;
    int code[1];
};

static int fill_page(struct page *pg, int n) {
    int s = 0;
    pg->count = n;
    for (int i = 0; i < n; i++)
        pg->code[i] = i * 3;
    for (int i = 0; i < pg->count; i++)
        s += pg->code[i];
    return s;
}

int main(void) {
    int local[6] = {1, 2, 3, 4, 5, 6};
    static int counter[3];
    int rw_x = 5;
    int mid = 3;
    int *p;
    const int *end;

    ceilingclip[rw_x] = (short)mid;
    floorclip[rw_x] = (short)(ceilingclip[rw_x] + 1);
    floorclip[rw_x] += 2;
    ceilingclip[rw_x]--;
    counter[1]++;
    counter[1] += local[2];
    local[rw_x] = local[rw_x - 1] * 2;
    local[0] <<= 3;

    for (int i = 0; i < ROWS; i++)
        for (int j = 0; j < COLS; j++)
            grid[i][j] = i * 10 + j;
    grid[1][2] += grid[2][3];
    grid[2][0]++;

    for (int i = 0; i < 4; i++) {
        points[i].x = i;
        points[i].y = i * i;
    }
    points[2].y += points[3].x;
    points[1].x++;

    planes[0].id = 1;
    planes[1].id = 2;
    int f = fill_plane(&planes[1], 3, 9);
    int r = read_plane(&planes[1], 3);
    int v = by_value(planes[1], 2);

    p = &local[2];
    end = &table[5];
    int steps = (int)(end - &table[0]);
    *p += 100;
    p[1] = 55;

    struct tagged t;
    memset(&t, 0, sizeof t);
    unsigned w = tagged_bytes(&t, 1) + tagged_bytes(&t, 2);

    struct page *pg = malloc(sizeof(struct page) + 4 * sizeof(int));
    int hack = fill_page(pg, 5);
    free(pg);

    printf("clip %d %d counter %d local %d %d %d %d\n", ceilingclip[rw_x],
           floorclip[rw_x], counter[1], local[0], local[2], local[3], local[5]);
    printf("grid %d %d %d rows %d %d %d\n", grid[1][2], grid[2][0], grid[0][3],
           row_sum(0), row_sum(1), row_sum(2));
    printf("points %d %d %d %d\n", points[1].x, points[2].y, points[3].y,
           points[0].x);
    printf("plane %d %d %d top %u bottom %u corner %d %d\n", f, r, v,
           planes[1].top[3], planes[1].bottom[3], planes[1].corners[1].x,
           planes[1].corners[1].y);
    printf("decayed %d %d steps %d word %u hack %d\n", sum_decayed(local, 6),
           sum_decayed(table, 5), steps, w, hack);
    return 0;
}
