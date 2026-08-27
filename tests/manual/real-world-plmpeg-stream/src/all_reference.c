/* C-reference graph only.  The fixture allocator/libc bodies live here, not
 * in the C input that c2das translates to daScript. */
#include "shim.c"
#include "pl_mpeg.c"
#undef PL_MPEG_IMPLEMENTATION
#include "module.c"
