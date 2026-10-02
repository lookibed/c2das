/* An integer converted to a pointer or to a function pointer.
 *
 * The mapping is implementation-defined (C11 6.3.2.3p5); GCC and Clang widen
 * the integer to the pointer's 64 bits first — sign-extending a signed type,
 * zero-extending an unsigned one — and use those bits as the address.  Clang
 * converts an `int` operand directly (`IntegralToPointer`, no widening cast
 * below it), so the translation has to widen it: a bare `reinterpret` of a
 * four-byte value into an eight-byte pointer or function value reads four
 * bytes C never defined, and the interpreter and the LLVM JIT read different
 * ones.
 *
 * Doom marks a removed thinker with `(actionf_v)(-1)` and later compares the
 * stored mark with a fresh `(actionf_v)(-1)`; a thinker whose function is
 * null is a different, live state.  With the bare `reinterpret` the mark was
 * the null function under `-jit`, so live thinkers were freed. */
#include <stdint.h>
#include <stdio.h>

typedef void (*action_t)(void);

typedef struct thinker {
    action_t function;
    int id;
} thinker_t;

static int calls;

static void tick(void) { calls += 1; }

static void *from_int(int n) { return (void *)n; }

static void *from_unsigned(unsigned n) { return (void *)n; }

static action_t mark_removed(void) { return (action_t)(-1); }

static action_t mark_from(int n) { return (action_t)n; }

int main(void) {
    thinker_t list[4] = {{tick, 0}, {0, 1}, {tick, 2}, {tick, 3}};
    int removed = 0;
    int idle = 0;
    int i;

    printf("int -1 -> %llx\n", (unsigned long long)(uintptr_t)from_int(-1));
    printf("int 7 -> %llx\n", (unsigned long long)(uintptr_t)from_int(7));
    printf("unsigned max -> %llx\n", (unsigned long long)(uintptr_t)from_unsigned(0xffffffffu));
    printf("mark -> %llx\n", (unsigned long long)(uintptr_t)mark_removed());
    printf("mark equal %d, mark null %d, from -1 equal %d\n",
           mark_removed() == mark_removed(), mark_removed() == 0, mark_from(-1) == mark_removed());

    list[2].function = mark_removed();
    for (i = 0; i < 4; i++) {
        if (list[i].function == (action_t)(-1)) {
            removed += 1;
        } else if (list[i].function) {
            list[i].function();
        } else {
            idle += 1;
        }
    }
    printf("removed=%d idle=%d calls=%d\n", removed, idle, calls);
    return 0;
}
