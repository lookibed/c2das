/* Two Quake shapes under --memory-model linear: a call with an argument
 * through an unprototyped function pointer held in the heap (`net_main.c`'s
 * `pp->procedure(pp->arg)`), and a heap array indexed by `!side`
 * (`r_bsp.c`'s `node->children[!side]`). */
#include <stdio.h>

typedef struct poll {
    struct poll *next;
    void (*procedure)();
    void *arg;
} poll_t;

static int total;

static void add_one(void *arg) {
    total += *(int *)arg;
}

typedef struct node {
    int value;
    struct node *children[2];
} node_t;

int main(void) {
    int amount = 7;
    poll_t p = {0, add_one, &amount};
    poll_t *pp = &p;
    pp->procedure(pp->arg);
    pp->procedure(pp->arg);
    node_t a = {1, {0, 0}}, b = {2, {0, 0}};
    node_t root = {0, {&a, &b}};
    node_t *n = &root;
    int side = 0;
    int front = n->children[side]->value;
    int back = n->children[!side]->value;
    side = n->value < 1;
    printf("total=%d front=%d back=%d other=%d\n", total, front, back, n->children[!side]->value);
    return 0;
}
