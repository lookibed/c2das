/* Allocation: every object is made here. */
#include <stdlib.h>
#include "records.h"

struct node *list_head = NULL;

void list_build(int n) {
    for (int i = 0; i < n; i++) {
        struct node *p = (struct node *)malloc(sizeof(struct node));
        p->value = i * i;
        p->next = list_head;
        list_head = p;
    }
}

struct tree *tree_insert(struct tree *t, int key) {
    if (!t) {
        struct tree *fresh = calloc(1, sizeof(struct tree));
        fresh->key = key;
        fresh->count = 1;
        return fresh;
    }
    if (key == t->key) {
        t->count++;
    } else if (key < t->key) {
        t->left = tree_insert(t->left, key);
    } else {
        t->right = tree_insert(t->right, key);
    }
    return t;
}

struct cell *cells_build(int n) {
    struct cell *head = NULL;
    for (int i = 1; i <= n; i++) {
        struct cell *c = malloc(sizeof(struct cell));
        c->value = i * 7;
        c->next = head;
        head = c;
    }
    return head;
}
