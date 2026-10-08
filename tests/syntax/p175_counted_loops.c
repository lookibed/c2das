/* Counted C loops become daslang's `for` over a range
 * (`cfg/structured.rs counted_do_while` / `counted_for`), one fused
 * interpreter node instead of a counter copy, a decrement and a test:
 *
 *   - `do { body } while (count--)` with `count` an `int` local the body
 *     never names and that is dead after the loop runs the body
 *     `count + 1` times for `count >= 0` and, by two's-complement wrap,
 *     `2^32 + count + 1` times for `count < 0`; the loop is
 *     `for (_ in urange64(0, uint64(uint(count)) + 1))`, that number in
 *     both cases, so no guard and no second copy of the body;
 *   - `for (init; i < b; i++)` with `i` an `int`/`unsigned` local the body
 *     never writes and `b` invariant over the body is
 *     `for (i in range(a, b))`; `i` keeps its C name when nothing outside
 *     the loop names it (its hoisted `var` disappears), else a fresh
 *     variable iterates and `i` stays as it was, which is exact only when
 *     `i` is dead after the loop.
 *
 * Everything else keeps today's `while`: a counter the body reads, a
 * counter read after the loop (`count` is -1, `i` is its bound), an
 * `unsigned` do-while counter, a bound the body changes, a `break` with
 * the variable live after the loop, a bound read through a pointer. */
#include <stdio.h>

static int sink[64];

static int count_down(int count) {
    int total = 0;
    do {
        total += 2;
    } while (count--);
    return total;
}

static int count_down_negative(int count) {
    int total = 0;
    do {
        total += 1;
        if (total == 5)
            break;
    } while (count--);
    return total;
}

static int count_read_in_body(int count) {
    int total = 0;
    do {
        total += count;
    } while (count--);
    return total;
}

static int count_live_after(int count) {
    int total = 0;
    do {
        total += 3;
    } while (count--);
    return total * 100 + count;
}

static unsigned count_unsigned(unsigned count) {
    unsigned total = 0;
    do {
        total += 7;
    } while (count--);
    return total;
}

static int count_continue(int count) {
    int total = 0;
    do {
        total += 1;
        if (total & 1)
            continue;
        total += 10;
    } while (count--);
    return total;
}

static int count_in_outer_loop(int rows, int cols) {
    int total = 0;
    int count;
    for (int r = 0; r < rows; r++) {
        count = cols;
        do {
            total += r + 1;
        } while (count--);
    }
    return total;
}

static int index_sum(int n) {
    int total = 0;
    for (int i = 0; i < n; i++)
        total += i * i;
    return total;
}

static int index_declared_before(int n) {
    int i;
    int total = 0;
    for (i = 1; i < n; i++)
        if (i % 3)
            total += i;
    return total;
}

static int index_live_after(int n) {
    int i;
    for (i = 0; i < n; i++)
        sink[i] = i * 2;
    return i;
}

static int index_break_live_after(int n) {
    int i;
    for (i = 0; i < n; i++)
        if (sink[i] > 10)
            break;
    return i;
}

static int index_written_in_body(int n) {
    int total = 0;
    for (int i = 0; i < n; i++) {
        total += i;
        if (i == 3)
            i += 2;
    }
    return total;
}

static int bound_changes(int n) {
    int total = 0;
    for (int i = 0; i < n; i++) {
        total += 1;
        if (i == 2)
            n -= 1;
    }
    return total;
}

static int bound_through_pointer(const int *n) {
    int total = 0;
    for (int i = 0; i < *n; i++)
        total += 1;
    return total;
}

static unsigned index_unsigned(unsigned n) {
    unsigned total = 0;
    for (unsigned i = 2; i < n; i++)
        total += i;
    return total;
}

static int nested(int rows, int cols) {
    int total = 0;
    for (int r = 0; r < rows; r++)
        for (int c = 0; c < cols; c++) {
            if (c == r)
                continue;
            total += r * 10 + c;
        }
    return total;
}

static int index_continue_and_break(int n) {
    int total = 0;
    for (int i = 0; i < n; i++) {
        if (i & 1)
            continue;
        if (i > 6)
            break;
        total += i;
    }
    return total;
}

static int index_reused_before(int n) {
    int i = 100;
    int total = i;
    for (i = 0; i < n; i++)
        total += i;
    return total;
}

int main(void) {
    int bound = 5;
    printf("down %d %d %d\n", count_down(4), count_down(0), count_down_negative(-3));
    printf("read %d live %d unsigned %u continue %d outer %d\n",
           count_read_in_body(3), count_live_after(2), count_unsigned(3),
           count_continue(5), count_in_outer_loop(3, 2));
    printf("index %d %d before %d live %d %d break %d\n", index_sum(5),
           index_sum(0), index_declared_before(7), index_live_after(4),
           index_live_after(0), index_break_live_after(2));
    printf("written %d bound %d pointer %d unsigned %u nested %d cb %d reused %d\n",
           index_written_in_body(8), bound_changes(6), bound_through_pointer(&bound),
           index_unsigned(5), nested(2, 3), index_continue_and_break(20),
           index_reused_before(4));
    return 0;
}
