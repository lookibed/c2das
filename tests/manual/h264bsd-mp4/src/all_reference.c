/* C-reference graph for the H264BSD + minimp4 target.
 *
 * It is pinned separately from `all.c` (the c2das translation graph) so that
 * the reference program keeps its own libc bodies even if the target graph
 * later stops shipping `shim.c` -- the way the PLMPEG fixture already does.
 * The fixture's bump allocator and mem* replacements are what make the probe
 * results deterministic, so the reference build must use them too.
 */
#include "shim.c"
#include "h264bsd.c"
#include "minimp4.c"
#include "module.c"
