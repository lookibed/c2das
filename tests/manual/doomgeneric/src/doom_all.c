/* Translation input for the `--libc std` case: the c2das target graph
 * (`all.c`, the doomgeneric engine and its platform layer) and the C entry in
 * one translation unit, so the translated module carries the program's
 * `main` and runs as is. */
#include "all.c"
#include "doom_entry.c"
