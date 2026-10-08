/* A `switch` of at most eight case values whose arms never fall into each
 * other is an inline `if`/`elif` chain of the structured back end
 * (`cfg/structured.rs switch_chain`): no label, no jump, `default` the
 * final `else` wherever it stands.  A `break` of the switch inside a nested
 * `if` folds into the chain (`if (c) { a; break; } b` is `if c { a } else
 * { b }`, `lift_breaks`).
 *
 * Covered: several labels on one arm; `default` first, in the middle and
 * last; a `break` in the middle of an arm (nested `if`, with and without
 * `else`, two deep); a `return` in an arm; `continue` of the enclosing loop
 * inside an arm; nested switches; enum, char, unsigned and negative
 * scrutinees compared in the promoted type; loops inside an arm with their
 * own `break`.  What keeps the label region: fall-through, Duff's device
 * (flat), nine values, and a `break` deeper in an `if` that statements
 * follow. */
#include <stdio.h>

enum colour { RED, GREEN, BLUE, BLACK };

static const char *name(enum colour c) {
    switch (c) {
    case RED:
    case GREEN:
        return "warm";
    case BLUE:
        return "cold";
    default:
        return "none";
    }
}

static int default_first(int x) {
    int r = 0;
    switch (x) {
    default:
        r = 100;
        break;
    case 1:
        r = 1;
        break;
    case 2:
        r = 2;
        break;
    }
    return r + 1000;
}

static int default_middle(int x) {
    int r = 0;
    switch (x) {
    case 1:
        r = 1;
        break;
    default:
        r = 100;
        break;
    case 2:
    case 3:
        r = 23;
        break;
    }
    return r + 1000;
}

static int default_last(int x) {
    int r = 0;
    switch (x) {
    case 1:
        r = 1;
        break;
    case 2:
        r = 2;
        break;
    default:
        r = 100;
    }
    return r + 1000;
}

/* A `break` in the middle of an arm, under an `if` with and without `else`,
 * and two deep. */
static int mid_break(int x, int y) {
    int r = 0;
    switch (x) {
    case 1:
        r = 10;
        if (y > 0)
            break;
        r += 1;
        if (y < -5) {
            r += 2;
            break;
        } else {
            r += 4;
        }
        r += 8;
        break;
    case 2:
        if (y > 0) {
            r = 20;
            if (y > 10)
                break;
            r += 1;
            break;
        }
        r += 2;
        break;
    case 3:
        if (y)
            return -3;
        r = 30;
        break;
    }
    return r;
}

/* `continue` inside the switch targets the loop; the chain is no loop. */
static int loop_continue(const int *v, int n) {
    int acc = 0;
    for (int i = 0; i < n; i++) {
        switch (v[i]) {
        case 0:
            continue;
        case 1:
            acc += 1;
            if (acc > 5)
                continue;
            acc += 10;
            break;
        case 2:
            acc += 100;
            break;
        default:
            acc += 1000;
        }
        acc += 1;
    }
    return acc;
}

static int nested(int a, int b) {
    int r = 0;
    switch (a) {
    case 0:
        switch (b) {
        case 0:
            r = 1;
            break;
        case 1:
            r = 2;
            if (a == 0)
                break;
            r = 3;
            break;
        default:
            r = 10;
        }
        r += 100;
        break;
    case 1:
        r = 7;
        break;
    }
    return r;
}

static int on_char(char c) {
    switch (c) {
    case 'a':
    case 'e':
        return 1;
    case 'z':
        return 26;
    case '\0':
        return -1;
    default:
        return 0;
    }
}

static int on_unsigned(unsigned u) {
    switch (u) {
    case 0u:
        return 0;
    case 0xFFFFFFFFu: /* -1 converted to the promoted type */
        return 1;
    case 7u:
        return 7;
    }
    return 99;
}

static int on_negative(int x) {
    switch (x) {
    case -1:
        return 1;
    case -100:
        return 100;
    case 5:
        return 5;
    default:
        return 0;
    }
}

/* Fall-through keeps the label region. */
static int fallthrough(int x) {
    int r = 0;
    switch (x) {
    case 1:
        r += 1;
    case 2:
        r += 2;
        break;
    case 3:
        r += 3;
        break;
    }
    return r;
}

/* Nine values keep the label region (a jump table here). */
static int nine(int x) {
    switch (x) {
    case 0: return 10;
    case 1: return 11;
    case 2: return 12;
    case 3: return 13;
    case 4: return 14;
    case 5: return 15;
    case 6: return 16;
    case 7: return 17;
    case 8: return 18;
    }
    return -1;
}

/* Eight values: the chain's limit. */
static int eight(int x) {
    switch (x) {
    case 0: return 10;
    case 1: return 11;
    case 2: return 12;
    case 3: return 13;
    case 4: return 14;
    case 5: return 15;
    case 6: return 16;
    case 7: return 17;
    }
    return -1;
}

/* A loop inside an arm keeps its own `break`; the switch's follows it. */
static int break_in_loop(int x) {
    int r = 0;
    switch (x) {
    case 1:
        while (r < 10) {
            r++;
            if (r == 4)
                break; /* the loop's */
        }
        for (int i = 0; i < 10; i++) {
            r += i;
            if (r > 8)
                break; /* the loop's */
        }
        break;
    case 2:
        r = 2;
        break;
    }
    return r;
}

/* A `break` deeper in an `if` that statements follow keeps the region. */
static int deep_break(int x, int y) {
    int r = 0;
    switch (x) {
    case 1:
        if (y) {
            if (y > 2)
                break;
            r = 1;
        }
        r += 10;
        break;
    case 2:
        r = 2;
        break;
    }
    return r;
}

/* Duff's device stays on the flat back end. */
static int duff(int count) {
    int n = (count + 3) / 4, r = 0;
    switch (count % 4) {
    case 0: do { r += 1;
    case 3:      r += 2;
    case 2:      r += 4;
    case 1:      r += 8;
            } while (--n > 0);
    }
    return r;
}

int main(void) {
    printf("name %s %s %s %s\n", name(RED), name(GREEN), name(BLUE), name(BLACK));
    printf("default %d %d %d %d %d %d %d %d %d\n", default_first(1), default_first(2),
           default_first(3), default_middle(1), default_middle(2), default_middle(3),
           default_middle(4), default_last(2), default_last(5));
    printf("mid %d %d %d %d %d %d %d %d\n", mid_break(1, 1), mid_break(1, -9), mid_break(1, -1),
           mid_break(2, 20), mid_break(2, 5), mid_break(2, 0), mid_break(3, 1), mid_break(3, 0));
    int v[] = {1, 0, 2, 1, 1, 1, 1, 1, 7, 0};
    printf("continue %d\n", loop_continue(v, 10));
    printf("nested %d %d %d %d\n", nested(0, 0), nested(0, 1), nested(0, 5), nested(1, 0));
    printf("char %d %d %d %d %d\n", on_char('a'), on_char('e'), on_char('z'), on_char(0),
           on_char('q'));
    printf("unsigned %d %d %d %d\n", on_unsigned(0), on_unsigned(0xFFFFFFFFu), on_unsigned(7),
           on_unsigned(8));
    printf("negative %d %d %d %d\n", on_negative(-1), on_negative(-100), on_negative(5),
           on_negative(-5));
    printf("fallthrough %d %d %d %d\n", fallthrough(1), fallthrough(2), fallthrough(3),
           fallthrough(4));
    printf("nine %d %d %d eight %d %d %d\n", nine(0), nine(8), nine(9), eight(0), eight(7),
           eight(8));
    printf("loop %d %d deep %d %d %d %d duff %d %d\n", break_in_loop(1), break_in_loop(2),
           deep_break(1, 0), deep_break(1, 1), deep_break(1, 3), deep_break(2, 0), duff(1),
           duff(6));
    return 0;
}
