/* The entry unit: drives the other two and frees every object. */
#include <stdio.h>
#include <stdlib.h>
#include "records.h"

static void tree_free(struct tree *t) {
    if (t) {
        tree_free(t->left);
        tree_free(t->right);
        free(t);
    }
}

int main(void) {
    list_build(10);
    int sum = list_sum(list_head);
    int count = list_count();
    printf("list count=%d sum=%d first=%d\n", count, sum, list_head->value);
    while (list_head) {
        struct node *next = list_head->next;
        free(list_head);
        list_head = next;
    }
    printf("list empty=%d\n", list_head == NULL);

    struct tree *root = NULL;
    unsigned seed = 12345;
    for (int i = 0; i < 200; i++) {
        seed = seed * 1103515245u + 12345u;
        root = tree_insert(root, (int)((seed >> 16) % 97));
    }
    printf("tree walk=%ld\n", tree_walk(root, 1));
    tree_free(root);

    struct cell *cells = cells_build(12);
    printf("cells=%d\n", cells_sum(cells));
    while (cells) {
        struct cell *next = cells->next;
        free(cells);
        cells = next;
    }
    return 0;
}
