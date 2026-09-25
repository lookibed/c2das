/* Translation input of the canonical `--libc std` case and the C reference
 * program: the c2das target graph (`all.c`, the binjgb core), the platform
 * layer and the canonical C entry in one translation unit, so the translated
 * module carries the program's `main` and runs as is. */
#include "all.c"
#include "platform.c"
#include "entry.c"
