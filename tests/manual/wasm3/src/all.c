/* The c2das target graph: the wasm3 interpreter core in one translation unit.
 *
 * Only the core is here.  WASI (`m3_api_wasi.c`, `m3_api_uvwasi.c`,
 * `m3_api_meta_wasi.c`), the tracer and the libc import module are left out:
 * `fixtures/fib32.wasm` imports nothing, so the module needs no host imports
 * at all and the graph stays the interpreter proper.
 *
 * The configuration below is set before any wasm3 header is seen, because
 * `m3_config.h` and `m3_config_platforms.h` only fill in what is still
 * undefined:
 *
 *   d_m3HasPosixHost / d_m3HasWin32Host 0
 *       selects `m3_host_none.h` in `m3_core.c`, the implementation of
 *       `m3_host.h` for a system with neither face.  It costs nothing here and
 *       keeps `mmap`, `flock`, `pthread_getattr_np` and `sigaction` out of the
 *       graph: `m3_HostStackBase()` answers NULL, so the native-stack budget
 *       is the compile-time `d_m3MaxNativeStack` rather than a measured one,
 *       and a file is read with stdio rather than mapped.
 *   d_m3GuardedMemory 0
 *       there is no address space to reserve without a host layer;
 *       `m3_host_none.h` refuses to build with it on.
 *   d_m3VerboseErrorMessages 0
 *       drops the `snprintf` formatting of error text into the runtime's
 *       error buffer.
 *   d_m3HasFloat 0, d_m3NoFloatDynamic 1
 *       fib32/fib64 execute no float operation.  Note that
 *       `d_m3ImplementFloat` is `(d_m3HasFloat || d_m3NoFloatDynamic)`, so
 *       this pair still *implements* the float ops and makes them trap at
 *       execution instead of at compile time.  `-Dd_m3NoFloatDynamic=0` on top
 *       of this is what removes them from the graph entirely.
 *   d_m3Log* 0, d_m3EnableOpProfiling / OpTracing / Strace 0
 *       the defaults, pinned explicitly so a stray `-DDEBUG` cannot pull the
 *       logging `printf`s into the graph.
 */

/* `wasm3.h` turns the m3Err_* table into definitions rather than extern
 * declarations only where this is set, and `m3_core.c` sets it just before its
 * own include.  In a unity build `wasm3.h` has already been seen and guarded
 * by then, so the table would have no definition anywhere; setting it here,
 * ahead of the first include, is what a single translation unit needs. */
#define M3_IMPLEMENT_ERROR_STRINGS

#define d_m3HasPosixHost 0
#define d_m3HasWin32Host 0
#define d_m3GuardedMemory 0

/* No native-stack budget: with `m3_host_none.h` the stack base is unknown
 * anyway (`m3_HostStackBase()` answers NULL, so the probe measured against
 * an unmeasured 8 MiB compile-time budget), and the probe itself is
 * `__builtin_frame_address(0)`, a machine-stack read that has no meaning in
 * a translated module.  Setting the budget to 0 is wasm3's own switch for
 * hosts without a measurable stack: `m3_core.h` and `m3_env.h` compile the
 * probe out under `#if d_m3MaxNativeStack > 0`. */
#define d_m3MaxNativeStack 0

#define d_m3VerboseErrorMessages 0
#define d_m3HasFloat 0
#ifndef d_m3NoFloatDynamic
#define d_m3NoFloatDynamic 1
#endif

#define d_m3RecordBacktraces 0
#define d_m3EnableExceptionBreakpoint 0
#define d_m3EnableOpProfiling 0
#define d_m3EnableOpTracing 0
#define d_m3EnableWasiTracing 0
#define d_m3EnableStrace 0

#define d_m3LogParse 0
#define d_m3LogModule 0
#define d_m3LogCompile 0
#define d_m3LogWasmStack 0
#define d_m3LogEmit 0
#define d_m3LogCodePages 0
#define d_m3LogRuntime 0
#define d_m3LogNativeStack 0
#define d_m3LogHeapOps 0
#define d_m3LogTimestamps 0

#include "m3_bind.c"
#include "m3_code.c"
#include "m3_compile.c"
#include "m3_core.c"
#include "m3_env.c"
#include "m3_exec.c"
#include "m3_function.c"
#include "m3_info.c"
#include "m3_module.c"
#include "m3_parse.c"
#include "m3_validate.c"
