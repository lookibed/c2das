/* Header of the cyclic `--module-layout source` fixture: `ring_a.c` (the
 * entry unit), `ring_b.c` and `ring_c.c` call each other in a ring, so no
 * acyclic `require` order exists and the three units become one daslang
 * module. */
#ifndef RING_H
#define RING_H
int a_fn(int v);
int b_fn(int v);
int b_helper(int v);
int c_fn(int v);
extern int ring_calls;
#endif
