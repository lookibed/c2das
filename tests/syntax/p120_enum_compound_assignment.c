/* Compound assignment and ++/-- on an object of enumeration type.
 *
 * C11 6.5.16.2 makes `E1 op= E2` the operation `E1 op (E2)` after the usual
 * arithmetic conversions, and ++/-- are `E1 += 1` / `E1 -= 1`: the enumerated
 * value takes part as its compatible integer type, and the result is
 * converted back to the enumeration type.  daslang's `enum` accepts no
 * arithmetic operator, so the operand is converted to the enumeration's
 * integer type first (binjgb's `CPU_SPEED.speed ^= 1` and `FC ^= 1`).
 *
 * The objects below are a local, a field of a daslang struct, a field of a
 * storage-backed (packed) record, and an enumeration whose compatible type is
 * `unsigned char` (a packed enum), where the result wraps modulo 256. */
#include <stdio.h>

typedef enum Speed { SPEED_NORMAL = 0, SPEED_DOUBLE = 1 } Speed;
typedef enum Bool { FALSE = 0, TRUE = 1 } Bool;
typedef struct CpuSpeed { Speed speed; } CpuSpeed;
typedef struct Flags { Bool Z, N, H, C; } Flags;

typedef enum __attribute__((packed)) Small { S0, S1, S2 } Small;
typedef struct __attribute__((packed)) Packed {
    char pad[3];
    Speed speed;
    Small small;
} Packed;

typedef enum Signed { NEG = -2, ZERO = 0, POS = 3 } Signed;

int main(void) {
    CpuSpeed s = {SPEED_NORMAL};
    s.speed ^= 1;
    printf("speed=%d\n", (int)s.speed);
    s.speed ^= 1;
    printf("speed=%d\n", (int)s.speed);

    Flags f = {FALSE, FALSE, FALSE, TRUE};
    f.C ^= 1;
    f.Z |= 1;
    f.N += 1;
    printf("flags Z=%d N=%d H=%d C=%d\n", (int)f.Z, (int)f.N, (int)f.H, (int)f.C);

    /* The value of the assignment expression is the stored enumerated value. */
    Speed t = SPEED_DOUBLE;
    int was = (t ^= 1);
    printf("was=%d t=%d\n", was, (int)t);

    /* Unsigned compatible type: 0 - 1 wraps to UINT_MAX. */
    t -= 1;
    printf("wrapped=%u\n", (unsigned)t);
    t++;
    printf("t=%d\n", (int)t);
    t <<= 1;
    t += SPEED_DOUBLE;
    printf("t=%d\n", (int)t);

    /* A storage-backed record: the field is loaded, computed, stored. */
    Packed p = {{0}, SPEED_NORMAL, S2};
    p.speed ^= 1;
    p.small -= 1;
    p.small++;
    ++p.small;
    printf("packed speed=%d small=%d size=%zu\n", (int)p.speed, (int)p.small, sizeof p);

    /* `unsigned char` compatible type: 0 - 1 is 255. */
    Small m = S0;
    m -= 1;
    printf("small=%d\n", (int)m);
    m += 2;
    printf("small=%d\n", (int)m);

    /* Signed compatible type. */
    Signed g = NEG;
    g *= 3;
    printf("signed=%d\n", (int)g);
    g--;
    g /= 7;
    printf("signed=%d\n", (int)g);
    return 0;
}
