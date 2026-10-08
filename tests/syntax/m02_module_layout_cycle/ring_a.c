/* The entry unit; it only calls into `ring_b.c`. */
#include "ring.h"

int main(void) { return b_fn(1) == 0 ? 0 : 1; }
