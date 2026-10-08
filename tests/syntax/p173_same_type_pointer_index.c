/* A subscript of a pointer whose daScript type is already the subscript's
 * pointer type is indexed directly: `reinterpret<uint8?>` around a `uint8?`
 * operand is the identity and is not emitted (`abi.rs abi_pointer_cast_from`).
 * Doom's column and span loops read `dc_colormap[dc_source[i]]` with both
 * declared `lighttable_t *` (`lighttable_t` is `byte`).
 *
 * A pointer whose daScript type differs from the subscript's keeps its
 * conversion: `char *` read as `unsigned char *` (`int8?` to `uint8?`), a
 * `const` pointee read through a non-const pointer, and a `void *` cast. */
#include <stdio.h>

typedef unsigned char byte;
typedef byte lighttable_t;

lighttable_t *dc_colormap;
byte *dc_source;
static byte colormap[256];
static byte source[128];

static void fill(void) {
    for (int i = 0; i < 256; i++) colormap[i] = (byte)(255 - i);
    for (int i = 0; i < 128; i++) source[i] = (byte)(i * 3);
}

static unsigned sum_typedef_bytes(const lighttable_t *map, const byte *src, int n) {
    unsigned acc = 0;
    for (int i = 0; i < n; i++) acc += map[src[i]];
    return acc;
}

static int sum_signed_chars(char *text, int n) {
    int acc = 0;
    unsigned char *bytes = (unsigned char *)text;
    for (int i = 0; i < n; i++) acc += bytes[i] + text[i];
    return acc;
}

static unsigned sum_void(void *blob, int n) {
    unsigned acc = 0;
    for (int i = 0; i < n; i++) acc += ((unsigned char *)blob)[i];
    return acc;
}

int main(void) {
    fill();
    dc_colormap = colormap;
    dc_source = source;
    unsigned direct = 0;
    for (int i = 0; i < 128; i++) direct += dc_colormap[dc_source[i & 127]];
    char text[6] = {'a', 'b', (char)-3, 'z', (char)-128, 127};
    printf("direct %u typedef %u signed %d void %u\n", direct,
           sum_typedef_bytes(colormap, source, 128), sum_signed_chars(text, 6),
           sum_void(source, 128));
    return 0;
}
