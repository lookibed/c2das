/* `data.c`: defines objects whose address only other units take, and a
 * table of function pointers to functions `ops.c` defines (a cycle: `ops.c`
 * reads `states`). */
#include "shared.h"

/* Unprototyped here (as Doom's `info.c` declares its actions): the table
 * slot must use the signature of `ops.c`'s definition. */
int negate();

int counter = 5;
int values[4] = {10, 20, 30, 40};
state_t states[4] = {{twice, 1}, {plus_one, 2}, {negate, 3}, {twice, -1}};
