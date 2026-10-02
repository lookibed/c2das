/* Copying a record with pointer members out of a `const` object.
 *
 * C11 6.3.2.1p2: the value of an lvalue has the unqualified type, so
 * `*file_data` through a `const FileData *` is a `FileData` whose `data`
 * member is a plain `unsigned char *`.  daslang keeps the place's `const` on
 * every field of the copy and refuses `uint8? const` into `uint8?`; the
 * place is read through its address converted to the unqualified record.
 * A record parameter is a read-only daslang reference copied into the
 * callee's own object the same way.  (binjgb: `e->file_data = *file_data`
 * in `set_rom_file_data`, `JoypadStateIter` by value in `joypad.c`.) */
#include <stdio.h>

typedef struct FileData {
    unsigned char *data;
    unsigned long size;
} FileData;

typedef struct Holder {
    int tag;
    FileData file_data;
} Holder;

typedef struct Nested {
    FileData inner[2];
    int count;
} Nested;

typedef struct Plain {
    int a;
    int b;
} Plain;

static const FileData empty = {0, 0};

static void set_file(Holder *h, const FileData *file_data) { h->file_data = *file_data; }

static FileData advance(FileData iter) {
    iter.data += 1;
    iter.size -= 1;
    return iter;
}

static Nested shift(Nested n) {
    n.inner[1].data += 2;
    n.count += 1;
    return n;
}

static int plain_sum(const Plain *p) {
    Plain copy = *p;
    copy.a += 1;
    return copy.a + copy.b;
}

int main(void) {
    static unsigned char bytes[4] = {1, 2, 3, 4};
    FileData f = {bytes, 4};
    Holder h = {0, {0, 0}};
    const Nested cn = {{{bytes, 4}, {bytes + 1, 3}}, 1};
    const Plain pl = {3, 4};
    FileData g;
    FileData e;
    Nested n;

    set_file(&h, &f);
    g = advance(h.file_data);
    e = empty;
    n = shift(cn);
    printf("size=%lu first=%d\n", g.size, (int)g.data[0]);
    printf("empty=%lu nested=%d count=%d orig=%d\n", e.size, (int)n.inner[1].data[0], n.count,
           (int)cn.inner[1].data[0]);
    printf("plain=%d\n", plain_sum(&pl));
    return 0;
}
