/* Translation input for the `--libc std` benchmark: the c2das target graph
 * (`all.c`, the doomgeneric engine and its platform layer) and the C
 * benchmark entry in one translation unit, so the translated module carries
 * the program's `main` and runs as is. */
#include "all.c"
#include "doom_bench_entry.c"
