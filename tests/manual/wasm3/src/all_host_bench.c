/* Translation input for the `--libc std` benchmark: the c2das target graph
 * (`all.c`, the wasm3 interpreter core) and the C benchmark entry over a
 * .wasm module in one translation unit, so the translated module carries the
 * program's `main` and runs as is. */
#include "all.c"
#include "host_bench.c"
