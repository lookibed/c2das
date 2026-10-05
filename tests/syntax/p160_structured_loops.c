/* Loops of a function without `goto` lower to daslang's own `while`,
 * `break`, `continue` and `return` (`cfg/structured.rs`), not to labels.
 *
 * Every C loop kind, with `break` and `continue` where C gives them
 * different successors: a `for` continues through its step, a `do`/`while`
 * through its condition, a `while` through its condition.  Conditions and
 * steps with side effects run exactly as often as in C; declarations inside
 * a loop body are re-initialised on every pass; a local whose address is
 * taken inside a loop keeps one object. */
#include <stdio.h>

static int calls;

static int next_value(int *cursor) {
    calls++;
    return (*cursor)++ < 6 ? *cursor : 0;
}

static int for_loops(int n) {
    int total = 0;
    for (int i = 0; i < n; i++) {
        if (i % 3 == 0)
            continue; /* runs i++ first */
        if (i > 12)
            break;
        total += i;
    }
    /* a comma step and an empty condition */
    int a = 0, b = 100;
    for (;; a++, b -= 7) {
        if (b < a)
            break;
        if (a & 1)
            continue;
        total += b - a;
    }
    return total;
}

static int while_loops(void) {
    int cursor = 0, value, total = 0;
    /* a condition with a side effect: evaluated once per test */
    while ((value = next_value(&cursor)) != 0) {
        if (value == 2)
            continue;
        total = total * 10 + value;
    }
    int j = 0;
    while (1) {
        if (++j > 5)
            break;
        total += j;
    }
    return total;
}

static int do_loops(int limit) {
    int k = 0, total = 0, cursor = 0;
    do {
        k += 2;
        if (k == 6)
            continue; /* tests k < limit */
        total += k;
    } while (k < limit);
    /* a condition with a side effect and a continue */
    do {
        if (cursor == 3)
            continue;
        total += cursor;
    } while (next_value(&cursor) != 0);
    /* do-while(0): its body alone, or a loop that `break` leaves */
    do {
        total += 1000;
    } while (0);
    do {
        if (total > 5000)
            break;
        total *= 2;
        if (total > 3000)
            continue; /* leaves too */
        total += 1;
    } while (0);
    return total;
}

static int nested(int n) {
    int found = -1;
    for (int i = 0; i < n && found < 0; i++) {
        for (int j = 0; j < n; j++) {
            if (j > i)
                break; /* the inner loop only */
            if ((i * j) % 7 == 6) {
                found = i * 100 + j;
                break;
            }
            if (j == 2)
                continue;
        }
    }
    return found;
}

static int early_return(const int *values, int n, int key) {
    for (int i = 0; i < n; i++) {
        int v = values[i];
        while (v > 0) {
            if (v == key)
                return i;
            v /= 2;
        }
    }
    return -1;
}

static int fresh_per_pass(void) {
    int sum = 0;
    for (int i = 0; i < 4; i++) {
        int counter = 10; /* re-initialised on every pass */
        int scratch[3] = {i, i + 1, i + 2};
        counter += scratch[2];
        sum += counter;
    }
    return sum;
}

static void bump(int *p) { *p += 3; }

static int address_taken(void) {
    int total = 0;
    int *seen[3];
    for (int i = 0; i < 3; i++) {
        int cell = i;
        bump(&cell);
        seen[i] = &total;
        total += cell;
    }
    return *seen[0] + *seen[2];
}

static int forever(int x) {
    for (;;) {
        x = x * 3 + 1;
        if (x > 1000)
            return x;
    }
}

int main(void) {
    int values[5] = {9, 40, 33, 7, 64};
    printf("for %d\n", for_loops(20));
    printf("while %d calls %d\n", while_loops(), calls);
    printf("do %d calls %d\n", do_loops(11), calls);
    printf("nested %d %d\n", nested(10), nested(3));
    printf("early %d %d %d\n", early_return(values, 5, 5), early_return(values, 5, 16),
           early_return(values, 5, 99));
    printf("fresh %d address %d forever %d\n", fresh_per_pass(), address_taken(), forever(2));
    return 0;
}
