/* A scalar local assigned an expression and read exactly once, straight
 * after, in the same statement list is written as that expression at the
 * read and the assignment is dropped (`cfg/structured.rs`, "Single-use
 * temporaries"): the interpreter's store and load of the local go away.
 * Doom's `R_DrawSpan` computes `ytemp`, `xtemp` and `spot` that way per
 * pixel; the three fold into one subscript.
 *
 * Covered: the `R_DrawSpan` chain; a temporary of pointer and of `float`
 * type; one read as a store's index; one read in an `if` scrutinee, a
 * `return`, a declaration's initializer and the target of a store it also
 * reads (`x = x + 1`); a memory read with only local writes between.
 * Kept as locals: a temporary read twice; one live after the read (through
 * the loop's exit, and through its back edge); one whose operand is written
 * between; a memory read with a store, or a call, between; one read inside
 * a nested loop; a division read under an `if`; one read on one arm of a
 * `?:`. */
#include <stdio.h>
#include <stdint.h>

static uint8_t colormap[256];
static uint8_t source[4096];
static uint8_t screen[64];
static int values[8] = {3, 1, 4, 1, 5, 9, 2, 6};
static int g[4] = {10, 20, 30, 40};

/* R_DrawSpan: ytemp, xtemp and spot fold into the subscript */
static void span(uint8_t *dest, int count, unsigned position, unsigned step) {
    int spot;
    unsigned xtemp, ytemp;
    do {
        ytemp = (position >> 4) & 0x0fc0;
        xtemp = (position >> 26);
        spot = xtemp | ytemp;
        *dest++ = colormap[source[spot]];
        position += step;
    } while (count--);
}

/* a pointer temporary, a float temporary, a store's index */
static int pointer_temp(int *base, int i) {
    int *p;
    p = base + i;
    return *p;
}

static float float_temp(float x) {
    float half;
    half = x * 0.5f;
    return half + 1.0f;
}

static void index_temp(int *a, int i, int v) {
    int k;
    k = i + 1;
    a[k] = v;
}

/* read in an if scrutinee, a declaration's initializer, and `x = x + 1` */
static int scrutinee(int a, int b) {
    int t, x;
    t = a / b;
    if (t > 1) {
        return 1;
    }
    t = a + b;
    int doubled = t * 2;
    x = doubled;
    t = x + 1;
    x = t;
    return x;
}

/* a memory read with only local writes between: substituted */
static int local_writes_between(int i) {
    int t, j;
    t = g[i];
    j = i + 1;
    return t + j;
}

/* kept: read twice */
static int read_twice(int a, int b) {
    int t;
    t = a + b;
    return t * t;
}

/* kept: live through the loop's exit */
static int live_after_exit(int n) {
    int t = 0, s = 0;
    while (n-- > 0) {
        t = values[n];
        s += t;
    }
    return s + t;
}

/* kept: live through the loop's back edge */
static int live_on_back_edge(int n) {
    int t = 0, s = 0, x = 0;
    while (n-- > 0) {
        s += t;
        t = values[n] + 1;
        x = t;
    }
    return s + x;
}

/* kept: an operand written between */
static int operand_written(int a) {
    int t;
    t = a + 1;
    a = 5;
    return t + a;
}

static void bump(void) {
    g[0] += 1;
}

/* kept: a memory read with a store, or a call, between */
static int store_between(int i) {
    int t;
    t = g[i];
    g[i] = 7;
    return t;
}

static int call_between(int i) {
    int t;
    t = g[i];
    bump();
    return t;
}

/* kept: read inside a nested loop */
static int nested_loop(int a, int b, int n) {
    int t, s = 0, i = 0;
    t = a + b;
    while (i < n) {
        s += t;
        i++;
    }
    return s;
}

/* kept: a division read under an if, and on one arm of ?: */
static int division_under_if(int a, int b) {
    int t;
    t = a / b;
    if (b != 0) {
        return t;
    }
    return 0;
}

static int conditional_arm(int a, int b) {
    int t;
    t = a + b;
    return b ? t : 0;
}

int main(void) {
    int i;
    int arr[4] = {0, 0, 0, 0};
    for (i = 0; i < 256; i++) {
        colormap[i] = (uint8_t)(255 - i);
    }
    for (i = 0; i < 4096; i++) {
        source[i] = (uint8_t)(i * 7);
    }
    span(screen, 7, 0x12345678u, 0x04010000u);
    printf("span %d %d %d\n", screen[0], screen[3], screen[7]);
    index_temp(arr, 1, 9);
    printf("temps %d %.2f %d\n", pointer_temp(values, 5), (double)float_temp(3.0f), arr[2]);
    printf("reads %d %d %d\n", scrutinee(9, 2), scrutinee(1, 2), local_writes_between(2));
    printf("kept %d %d %d %d\n", read_twice(2, 3), live_after_exit(4), live_on_back_edge(3),
           operand_written(1));
    printf("memory %d %d\n", store_between(1), call_between(0));
    printf("control %d %d %d\n", nested_loop(1, 2, 3), division_under_if(8, 2),
           conditional_arm(1, 2));
    return 0;
}
