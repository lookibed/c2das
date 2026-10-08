/* `*p++ = v` as a statement is a store through `p` followed by the step,
 * `*p = v; p += 1`, when `v` can neither read nor write `p`
 * (`operators.rs post_step_store`).  C leaves the order of the step and the
 * evaluation of `v` unspecified only when `v` cannot observe `p`; the
 * translator proves that or keeps the copy of `p` it takes today:
 *
 *   - `v` names `p` itself (`*mark++ = (byte)(mark != 0)`): a copy.  C
 *     leaves the step unsequenced against that read (undefined when it is
 *     a direct read, unspecified through a call), so the fixture reads only
 *     what both orders agree on;
 *   - `v` reads memory through another pointer while `p` is a global
 *     (`*out++ = *in++`, `out` global): a copy, `in` could point at `out`;
 *   - `v` calls a function: a copy, the call could reach `p` (`out_is_set`
 *     does read `out`).
 *
 * `v` a plain global read, `p` a global with `v` a pure value, and
 * `*p-- = v` take the direct form. */
#include <stdio.h>

typedef unsigned char byte;

static byte buffer[64];
static byte *out;
static int level;
static byte table[16];

static byte next_level(void) {
    level += 10;
    return (byte)level;
}

static byte out_is_set(void) {
    return (byte)(out != 0);
}

int main(void) {
    for (int i = 0; i < 16; i++) table[i] = (byte)(i * 7);

    /* local pointer, pure value: direct store then step */
    byte *dest = buffer;
    for (int i = 0; i < 4; i++) *dest++ = table[i & 15];

    /* local pointer, value reads memory through another pointer */
    const byte *src = table + 8;
    for (int i = 0; i < 4; i++) *dest++ = *src++;

    /* value names the pointer itself: the copy stays */
    byte *mark = buffer + 8;
    *mark++ = (byte)(mark != 0);
    *mark++ = (byte)(mark != buffer);

    /* value is a global read, pointer local */
    level = 5;
    *mark++ = (byte)level;

    /* global pointer, pure value */
    out = buffer + 11;
    *out++ = 42;
    *out++ = (byte)(level + 1);

    /* global pointer, value reads memory: copy kept */
    const byte *in = table;
    *out++ = *in++;
    *out++ = *in++;

    /* value is a call: copy kept, the call runs once */
    *out++ = next_level();
    *out++ = out_is_set();
    *dest = next_level();

    /* post-decrement store */
    byte *back = buffer + 20;
    *back-- = 1;
    *back-- = 2;
    *back = 3;

    for (int i = 0; i < 21; i++) printf("%d ", buffer[i]);
    printf("\nout %d dest %d back %d level %d\n", (int)(out - buffer),
           (int)(dest - buffer), (int)(back - buffer), level);
    return 0;
}
