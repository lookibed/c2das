/* A storage-backed record (a union, a packed struct, or a struct holding
 * one) reached through a `typedef`, and through a `typedef` of that
 * `typedef`, is one daScript wrapper declared once.
 *
 * Doom names its action union `actionf_t` and again `think_t`, and its packed
 * patch post `post_t` and again `column_t` (`d_think.h`, `v_patch.h`); every
 * name reaching the record used to print its wrapper once more
 * (`error[20512]: structure is already defined`). */
#include <stdio.h>

typedef union {
    int i;
    float f;
} value_t;
typedef value_t alias_t;
typedef alias_t alias2_t;

typedef struct __attribute__((packed)) {
    unsigned char topdelta;
    int length;
} post_t;
typedef post_t column_t;

typedef struct holder_s {
    int tag;
    alias_t value;
} holder_t;
typedef holder_t holder_alias_t;

static value_t cell;
static alias2_t cell2;
static column_t column;
static post_t posts[3];

static int read_value(alias_t *v) { return v->i; }
static int post_length(const column_t *c) { return c->length; }

int main(void) {
    holder_alias_t h;
    cell.i = 3;
    cell2.i = 4;
    column.length = 5;
    posts[1].length = 6;
    h.tag = 7;
    h.value.i = 8;
    printf("%d %d %d %d %d %d\n", read_value(&cell), read_value(&cell2), post_length(&column),
           post_length(&posts[1]), h.tag, read_value(&h.value));
    printf("sizes %d %d %d\n", (int)sizeof(alias2_t), (int)sizeof(column_t), (int)sizeof(holder_alias_t));
    return 0;
}
