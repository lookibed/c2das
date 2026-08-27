/* Single-header implementation must be expanded before any consumer that
 * includes pl_mpeg.h: its declaration guard ends before its implementation.
 *
 * This is the c2das target graph.  Its libc calls lower to the canonical
 * daScript raw-memory runtime, so it deliberately excludes shim.c's C
 * reference implementations.
 */
#include "pl_mpeg.c"
#undef PL_MPEG_IMPLEMENTATION
#include "module.c"
