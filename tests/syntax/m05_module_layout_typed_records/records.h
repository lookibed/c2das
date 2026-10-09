/* `--records typed` across units: the records every unit of the program
   sees.  `node` and `tree` qualify in every unit; `cell` loses in walk.c
   alone (`&c->value`) and stays in the byte heap everywhere. */
#ifndef RECORDS_H
#define RECORDS_H

struct node {
    int value;
    struct node *next;
};

struct tree {
    int key;
    int count;
    struct tree *left;
    struct tree *right;
};

struct cell {
    int value;
    struct cell *next;
};

/* build.c: allocation. */
extern struct node *list_head;
void list_build(int n);
struct tree *tree_insert(struct tree *t, int key);
struct cell *cells_build(int n);

/* walk.c: traversal. */
int list_sum(const struct node *p);
int list_count(void);
long tree_walk(const struct tree *t, int depth);
int cells_sum(struct cell *c);

#endif
