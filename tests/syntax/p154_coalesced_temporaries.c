/* Site temporaries whose lives cannot overlap share one hoisted variable.
 *
 * A function with jumps hoists every temporary the statement lowering makes
 * to its top, and daslang's interpreter initialises each hoisted `var` on
 * every call.  `step` below makes many temporaries of one type in different
 * `switch` arms — chain assignments of an enumeration, used post-increments,
 * a stored value read back — and their lives (store, then the uses of the
 * same C statement) are disjoint, so they become a few variables.  What must
 * stay separate: a temporary whose life spans a label (control can enter its
 * middle), and a compound literal whose address outlives its statement. */
#include <stdio.h>

typedef enum { NO, YES, MAYBE } answer_t;

struct state {
    answer_t a;
    answer_t b;
    answer_t c;
    int n;
    int log[8];
};

static int step(struct state *s, int op) {
    int r = 0;
    int *keep;
    switch (op) {
    case 0:
        s->a = s->b = NO;
        break;
    case 1:
        s->a = s->b = s->c = YES;
        r = s->n++;
        break;
    case 2:
        s->c = s->a = s->n > 3 ? YES : NO;
        r = s->log[s->n++ & 7] = op;
        break;
    case 3:
        s->b = s->c = s->a;
        r = s->n-- + s->n++;
        break;
    case 4:
        keep = (int[]){s->n, op, 7};
        s->log[0] = keep[0] + keep[2];
        r = keep[1];
        break;
    default:
        s->a = s->c = NO;
        r = -1;
        break;
    }
    if (s->n > 100) {
        goto done;
    }
    r += (int)s->a * 100 + (int)s->b * 10 + (int)s->c;
done:
    return r;
}

int main(void) {
    struct state s = {NO, NO, NO, 0, {0}};
    int total = 0;
    int i;
    for (i = 0; i < 24; i += 1) {
        int r = step(&s, (i * 7) % 6);
        total = total * 31 + r;
        printf("%d:%d ", i, r);
    }
    printf("\nn %d log0 %d total %d\n", s.n, s.log[0], total);
    return 0;
}
