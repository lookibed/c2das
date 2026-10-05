/* An early exit that a loop jumps across (Doom's `Z_CheckHeap`).
 * `check_list_flat` keeps this on the flat back end with a `goto`; the
 * structured back end lowers `check_list` to a `while` with a `break`.
 *
 * The flat label back end renders the loop: each error report needs a jump
 * out of the body and back, and the `break` that ends both the loop and the
 * void function becomes `if (c) { return }` with the loop's labels after it.
 * daslang's if-return folding moves everything after such an `if` into a
 * nested `else` block, labels included, and the interpreter then fails the
 * loop's jump back to its head, above the `if`, with `jump to label 0
 * failed` (the JIT, AOT and `-exe` do not).  The translation moves that
 * arm out of line instead (`cfg/labels.rs`, `move_crossed_early_exits`). */
#include <stdio.h>

struct node {
    struct node *next;
    struct node *prev;
    int size;
    int tag;
};

static struct node ring[4];
static int errors;
static int visited;

static void report(const char *what) {
    errors++;
    printf("error: %s\n", what);
}

/* The flat back end takes a body with a `goto`; `goto done` is the `break`
 * of `check_list` below, whose body the structured back end takes. */
static void check_list_flat(struct node *head) {
    struct node *n;
    for (n = head->next;; n = n->next) {
        if (n->next == head)
            goto done;
        visited++;
        if (n->size <= 0)
            report("size");
        if (n->next->prev != n)
            report("back link");
        if (n->tag == 1 && n->next->tag == 1)
            report("two free");
    }
done:;
}

static void check_list(struct node *head) {
    struct node *n;
    for (n = head->next;; n = n->next) {
        if (n->next == head)
            break;
        visited++;
        if (n->size <= 0)
            report("size");
        if (n->next->prev != n)
            report("back link");
        if (n->tag == 1 && n->next->tag == 1)
            report("two free");
    }
}

int main(void) {
    for (int i = 0; i < 4; i++) {
        ring[i].next = &ring[(i + 1) % 4];
        ring[i].prev = &ring[(i + 3) % 4];
        ring[i].size = i;
        ring[i].tag = i >= 2;
    }
    check_list(&ring[0]);
    check_list_flat(&ring[0]);
    ring[1].size = 0;
    ring[3].prev = &ring[1];
    check_list(&ring[0]);
    check_list_flat(&ring[0]);
    printf("%d %d\n", errors, visited);
    return 0;
}
