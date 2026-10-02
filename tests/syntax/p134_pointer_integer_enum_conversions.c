/* Conversions into a narrower integer and into an enumeration.
 *
 * `(int)p` and `(unsigned)p` convert a pointer to an integer type narrower
 * than the address (C11 6.3.2.3p6; GCC and Clang keep the low bits).  The
 * raw address is converted, not reinterpreted: an eight-byte `reinterpret`
 * into `int` is not a conversion daslang's LLVM back end can emit (Doom's
 * `(int) intercept->d.thing` in `p_maputl.c`, an internal JIT error).  The
 * distance of two addresses inside one array, taken modulo 2^32, is the
 * same in every build.
 *
 * An integer converted to an enumeration takes the enumeration's integer
 * type first (C11 6.7.2.2p4, 6.3.1.3): a byte read through `*p++` assigned to
 * an `enum` is that byte's value, not four bytes of which C defined one
 * (Doom's `skill = *demo_p++` in `G_DoPlayDemo`, which played the demo on
 * the wrong skill). */
#include <stdio.h>

typedef enum { sk_baby, sk_easy, sk_medium, sk_hard, sk_nightmare } skill_t;
typedef enum { small_none, small_a = 1, small_b = 200 } small_t;

static int words[8];

static skill_t read_skill(const unsigned char **p) {
    skill_t skill;
    skill = *(*p)++;
    return skill;
}

int main(void) {
    static unsigned char demo[6] = {2, 4, 0, 255, 200, 1};
    const unsigned char *p = demo;
    unsigned short wide = 3;
    signed char negative = -1;
    skill_t a, b, c;
    small_t s;
    unsigned span;
    int low;

    span = (unsigned)&words[7] - (unsigned)&words[1];
    low = (int)(long)&words[3] - (int)&words[0];
    printf("span=%u low=%d\n", span, low);

    a = read_skill(&p);
    b = read_skill(&p);
    c = (skill_t)*p++;
    printf("skills %d %d %d %d\n", (int)a, (int)b, (int)c, a == sk_medium && b == sk_nightmare);
    s = (small_t)demo[4];
    printf("small %d %d\n", (int)s, s == small_b);
    a = (skill_t)wide;
    b = negative + 1;
    printf("more %d %d\n", (int)a, (int)b);
    return 0;
}
