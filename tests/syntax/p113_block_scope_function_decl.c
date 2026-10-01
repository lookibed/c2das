/* A function declared at block scope before any file-scope declaration of it
 * (`void later(void);` inside a body, as Doom's `WI_End` declares
 * `WI_unloadData`).  The block-scope declaration is the function's first, and
 * so its canonical, declaration; the definition further down is the same
 * file-scope function (C11 6.2.2p4-5).  The declaration produces nothing in the
 * body, and the function is still emitted, once, at module scope. */

static int calls;

int run_twice(void) {
    int later(int);
    return later(1) + later(2);
}

int nested_blocks(int k) {
    if (k > 0) {
        extern int counter_value(void);
        return counter_value() + k;
    }
    return -1;
}

/* A block-scope redeclaration of a function that already has a file-scope
 * prototype and a definition above the use. */
static int twice(int v) { return v * 2; }

int redeclared(void) {
    int twice(int);
    return twice(21);
}

int later(int k) {
    calls += k;
    return k * 10;
}

int counter_value(void) { return calls; }

static int check(int got, int want) { return got == want ? 0 : 1; }

int block_scope_function_runtime(void) {
    int failures = 0;
    failures += check(run_twice(), 30);
    failures += check(calls, 3);
    failures += check(nested_blocks(4), 7);
    failures += check(nested_blocks(0), -1);
    failures += check(redeclared(), 42);
    failures += check(later(5), 50);
    failures += check(counter_value(), 8);
    return failures;
}
