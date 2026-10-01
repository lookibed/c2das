/* An assignment used as a call argument passes the assignment's value, the
 * value of the left operand after the store (C11 6.5.16p3), whether or not the
 * call's own result is used: Doom's `V_DrawPatch(x -= 8, y, patch)` is a call
 * statement.  The store is hoisted ahead of the call; every argument below is
 * a different object from the others, so C's unspecified argument order does
 * not change any result. */

static int last;

static void sink(int v, int *out) { *out = v; }

static int pair(int a, int b) { return a * 100 + b; }

static void note(unsigned v) { last = (int) v; }

static int check(int got, int want) { return got == want ? 0 : 1; }

int assignment_arguments_runtime(void) {
    int failures = 0;
    int x = 20;
    int y = 1;
    int out = 0;
    int cell = 0;
    int *p = &cell;
    unsigned bits = 3;

    /* A call statement: its result is not used, its arguments are. */
    sink(x -= 8, &out);
    failures += check(out, 12);
    failures += check(x, 12);

    sink(y = 5, &out);
    failures += check(out, 5);
    failures += check(y, 5);

    /* A call whose result is used. */
    failures += check(pair(y *= 2, x += 1), 1013);
    failures += check(y, 10);
    failures += check(x, 13);

    /* A store through a pointer, and compound shifts and bit operators. */
    sink(*p = 7, &out);
    failures += check(out, 7);
    failures += check(cell, 7);
    note(bits <<= 4);
    failures += check(last, 48);
    note(bits |= 1u);
    failures += check(last, 49);
    failures += check((int) bits, 49);

    /* Nested: the inner call's assignment argument, then the outer's. */
    failures += check(pair(pair(x = 1, 2), y -= 3), 10207);
    failures += check(x, 1);
    failures += check(y, 7);

    /* An assignment argument inside a loop runs once per iteration. */
    int total = 0;
    for (int i = 0; i < 3; i++) {
        sink(total += i, &out);
    }
    failures += check(total, 3);
    failures += check(out, 3);
    return failures;
}
