/* A read of an enumeration constant is its value.
 *
 * C11 6.4.4.3: an enumeration constant is an integer constant, not an
 * object.  The module still names every constant (a `let` of the constant's
 * type, for a hand-written daScript caller), but the translated body spells
 * each read as the typed literal: a module global — even a `let` — stays a
 * load from the context's global data where daslang does not fold it (the
 * right-hand side of an assignment, a store through a pointer), and under
 * `-jit` a store through a C pointer may alias that load, so a loop bound or
 * a flag written from one is reloaded on every iteration.
 *
 * Covered: a loop bound, an assignment of an anonymous-enum `int` constant, a
 * store through a pointer, a store into a named-enum object, a `switch`, a
 * `static const` table and a file-scope initializer keyed by constants, a
 * negative constant, one above INT_MAX (Clang types it `unsigned int`), and
 * arithmetic with a constant. */
#include <stdio.h>

typedef enum { FALSE, TRUE } Bool;
enum { CHANNEL_COUNT = 4, SCALE = -3 };
enum big { BIG = 0xF0000000u };
typedef enum { STATE_IDLE, STATE_RUN = 5, STATE_DONE } state_t;

static const int weights[CHANNEL_COUNT] = { [0] = 1, [CHANNEL_COUNT - 1] = 7 };
static int bound = CHANNEL_COUNT * 2;

struct machine {
    state_t state;
    Bool ready;
    int acc[CHANNEL_COUNT];
};

static int wrapped(unsigned counter) {
    int flag = 0;
    if (counter >= 100u) {
        flag = TRUE;
    } else {
        flag = FALSE;
    }
    return flag;
}

static void step(struct machine *m, int *out) {
    int j;
    for (j = 0; j < CHANNEL_COUNT; j++) {
        m->acc[j] += weights[j] * SCALE + j;
    }
    switch (m->state) {
    case STATE_IDLE:
        m->state = STATE_RUN;
        *out = TRUE;
        break;
    case STATE_RUN:
        m->state = STATE_DONE;
        m->ready = TRUE;
        *out = STATE_DONE;
        break;
    default:
        m->state = STATE_IDLE;
        *out = FALSE;
        break;
    }
}

int main(void) {
    struct machine m = { STATE_IDLE, FALSE, { 0 } };
    unsigned big = BIG;
    int out = -1;
    int i;
    for (i = 0; i < bound; i++) {
        step(&m, &out);
        printf("%d:%d/%d/%d ", i, (int)m.state, (int)m.ready, out);
    }
    printf("\nacc %d %d %d %d\n", m.acc[0], m.acc[1], m.acc[2], m.acc[3]);
    printf("wrapped %d %d big %u %d size %d\n", wrapped(99u), wrapped(100u), big,
           BIG > 0, (int)sizeof(BIG));
    return 0;
}
