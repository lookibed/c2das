/* `--fnptr-model table`: every function pointer is an index into the table
 * of its signature — in locals, parameters, record values, global arrays and
 * the heap alike; NULL is 0; calls go through the table. */
#include <stdio.h>
#include <stdlib.h>

typedef int (*binop)(int, int);

static int add(int a, int b) { return a + b; }
static int sub(int a, int b) { return a - b; }
static int mul(int a, int b) { return a * b; }

struct op {
    const char *name;
    binop fn;
};

static binop table[3] = { add, sub, mul };

static int apply(binop f, int a, int b) {
    if (!f) {
        return -1;
    }
    return f(a, b);
}

static int fold(int (*f)(int, int), const int *xs, int n) {
    int acc = xs[0];
    for (int i = 1; i < n; i++) {
        acc = (*f)(acc, xs[i]);
    }
    return acc;
}

static binop pick(int which) {
    return which == 0 ? add : which == 1 ? &sub : NULL;
}

int linear_fnptr_table(void) {
    binop local = mul;
    int total = 0;
    total += local(6, 7);
    total += apply(sub, 10, 3);
    total += apply(NULL, 1, 2);
    struct op ops[2] = { { "add", add }, { "mul", mul } };
    for (int i = 0; i < 2; i++) {
        total += ops[i].fn(2, 5);
    }
    struct op *heap = malloc(sizeof(struct op) * 3);
    heap[0].fn = table[2];
    heap[1].fn = pick(1);
    heap[2].fn = pick(7);
    int xs[4] = { 1, 2, 3, 4 };
    total += fold(heap[0].fn, xs, 4);
    total += fold(heap[1].fn, xs, 4);
    printf("null=%d same=%d differ=%d\n", heap[2].fn == NULL, heap[0].fn == mul,
           heap[0].fn != heap[1].fn);
    binop copy = heap[1].fn;
    printf("copy(9,4)=%d\n", copy(9, 4));
    free(heap);
    printf("total=%d\n", total);
    return 0;
}
