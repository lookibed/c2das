/* Traversal: reads objects another unit made. */
#include <stddef.h>
#include "records.h"

int list_sum(const struct node *p) {
    int sum = 0;
    for (; p != NULL; p = p->next) {
        sum += p->value;
    }
    return sum;
}

int list_count(void) {
    int n = 0;
    for (struct node *p = list_head; p; p = p->next) {
        n++;
    }
    return n;
}

long tree_walk(const struct tree *t, int depth) {
    if (t == NULL) {
        return 0;
    }
    return (long)t->key * t->count * depth + tree_walk(t->left, depth + 1) +
           tree_walk(t->right, depth + 1);
}

/* The one interior address of a `cell` in the program: it keeps `cell` in
   the byte heap in every unit. */
int cells_sum(struct cell *c) {
    int sum = 0;
    while (c) {
        int *v = &c->value;
        sum += *v;
        c = c->next;
    }
    return sum;
}
