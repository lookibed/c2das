/* A `switch` in a structured function is a label region inside the
 * statement list that holds it (`cfg/structured.rs`): the dispatch, one
 * label per arm in source order, and a label after the last arm.
 *
 * Covered: fall-through, `default` in the middle, a `break` of the switch
 * next to a `break`/`continue` of the enclosing loop, an early exit inside
 * an arm (moved out of line: daslang's if-return folding would otherwise
 * carry the following arm labels into a nested block), a switch that ends
 * a loop body (its end is `continue`), a void function (`return`) and an
 * `if` arm with statements after the `if` (the `if` is spliced into
 * labels), a jump table whose holes end the loop, nested switches, site
 * temporaries in an arm (hoisted for AOT), and a switch without cases. */
#include <stdio.h>

enum op { OP_ADD, OP_SUB, OP_MUL, OP_SKIP, OP_STOP, OP_NEG, OP_DUP, OP_HALVE };

static int run(const unsigned char *code, int n) {
    int acc = 1, i = 0;
    while (i < n) {
        unsigned char op = code[i++];
        switch (op) {
        case OP_ADD:
            acc += 3;
            break;
        case OP_SUB:
            acc -= 1;
            /* fall through */
        case OP_MUL:
            acc *= 2;
            break;
        default:
            acc ^= 0x55;
            break;
        case OP_SKIP:
            if (i < n && code[i] == OP_STOP)
                continue; /* the loop's continue */
            i++;
            break;
        case OP_STOP:
            if (acc > 1000)
                return -acc; /* an early exit inside an arm */
            n = 0;
            break;
        case OP_NEG:
            acc = -acc;
            continue;
        case OP_DUP:
            acc += acc;
            /* fall through */
        case OP_HALVE:
            acc /= 2;
        }
        acc += 1;
    }
    return acc;
}

/* The switch ends the loop body: every `break` of it is `continue`, and a
 * jump table's holes (5 and 6 here) land on a `continue` trampoline. */
static int tally(const int *v, int n) {
    int counts[4] = {0, 0, 0, 0};
    for (int i = 0; i < n; i++) {
        switch (v[i]) {
        case 0: counts[0]++; break;
        case 1: counts[1]++; break;
        case 2: counts[2] += 2; break;
        case 3: counts[3]++; break;
        case 4: counts[3] += 4; break;
        case 7: counts[0] += 7; break;
        }
    }
    return counts[0] * 1000 + counts[1] * 100 + counts[2] * 10 + counts[3];
}

static int out_value;

/* The switch ends a void function: a `break` is `return`. */
static void store(int x) {
    switch (x) {
    case 1:
        out_value = 10;
        break;
    case 2:
        out_value = 20;
        break;
    case 3: case 4: case 5: case 6: case 8:
        out_value = 30 + x;
        break;
    case 9: /* an empty last arm: its label would end the body */
        break;
    }
}

/* The switch ends an `if` arm that a statement follows. */
static int in_arm(int a, int b) {
    int r = 0;
    if (a) {
        switch (b) {
        case 1: r = 1; break;
        case 2: r = 2; break;
        }
    } else {
        r = 50;
    }
    r += 10;
    return r;
}

static int nested(int a, int b) {
    int r = 0;
    switch (a) {
    case 0:
        switch (b) {
        case 0: r = 1; break;
        case 1: r = 2; /* fall through */
        default: r += 10; break;
        }
        r += 100;
        break;
    case 1:
        r = 7;
        break;
    }
    return r;
}

/* The outer switch's `break` next to an inner switch region in one `if`
 * arm: the arm's labels would trap that jump, so the `if` is spliced. */
static int break_past_region(int a, int b, int c) {
    int r = 0;
    switch (a) {
    case 1:
        if (b) {
            switch (c) {
            case 1: r = 1; /* fall through */
            case 2: r += 2;
            }
            break;
        }
        r = 9;
        break;
    case 2:
        r = 5;
        break;
    }
    return r;
}

static int counter;
static int bump(void) { return ++counter; }

/* Temporaries of `&&`, post-increments and conditionals inside arms. */
static int temporaries(int x, int y) {
    int r = 0;
    for (int k = 0; k < 3; k++) {
        switch (x + k) {
        case 0:
            r += (y > 0 && bump() > 1) ? 5 : 6;
            break;
        case 1:
            r += y++ * 2;
            break;
        case 2:
            r += (bump() > 2 || y > 10) ? 7 : 8;
            break;
        default:
            r += y-- + bump();
        }
    }
    return r * 100 + y;
}

static int no_cases(int x) {
    switch (x) {
    default:
        x += 1;
    }
    switch (x) {
    }
    return x;
}

int main(void) {
    unsigned char prog1[] = {OP_ADD, OP_SUB, OP_MUL, 9, OP_NEG, OP_DUP, OP_HALVE, OP_ADD};
    unsigned char prog2[] = {OP_ADD, OP_SKIP, OP_STOP, OP_SKIP, OP_ADD, OP_MUL, OP_STOP, OP_ADD};
    unsigned char prog3[] = {OP_MUL, OP_MUL, OP_MUL, OP_MUL, OP_MUL, OP_MUL, OP_MUL, OP_MUL,
                             OP_MUL, OP_MUL, OP_STOP};
    printf("run %d %d %d\n", run(prog1, 8), run(prog2, 8), run(prog3, 11));
    int values[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, -1, 2, 2, 7};
    printf("tally %d\n", tally(values, 13));
    for (int x = 0; x < 10; x++) {
        out_value = -1;
        store(x);
        printf("%d ", out_value);
    }
    printf("\narm %d %d %d %d\n", in_arm(1, 1), in_arm(1, 2), in_arm(1, 3), in_arm(0, 1));
    printf("nested %d %d %d %d\n", nested(0, 0), nested(0, 1), nested(0, 5), nested(1, 0));
    printf("temporaries %d %d", temporaries(0, 1), temporaries(-1, 3));
    printf(" counter %d\n", counter);
    printf("no cases %d\n", no_cases(4));
    printf("past %d %d %d %d %d\n", break_past_region(1, 1, 1), break_past_region(1, 1, 2),
           break_past_region(1, 1, 3), break_past_region(1, 0, 1), break_past_region(2, 0, 0));
    return 0;
}
