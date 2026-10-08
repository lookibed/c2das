/* Header of the negative `--module-layout source` fixture: `ring_b.c` and
 * `ring_c.c` call each other, so no acyclic `require` order exists. */
#ifndef RING_H
#define RING_H
int b_fn(int v);
int b_helper(int v);
int c_fn(int v);
#endif
