#include "shim.c"
/* Single-header implementation must be expanded before any consumer that
 * includes pl_mpeg.h: its declaration guard ends before its implementation.
 */
#include "pl_mpeg.c"
#undef PL_MPEG_IMPLEMENTATION
#include "module.c"
