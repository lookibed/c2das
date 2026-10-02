/* Translation input of the SDL3 harness, and its C reference's engine
 * translation unit: the corpus graph (`../src/all.c`: the engine and the
 * headless platform layer `dg_platform.c`) plus the host API `dg_host.c`, in
 * one translation unit and without a `main`.  The hosts (`doom_sdl.das`, which
 * `require`s the translated module, and `doom_sdl_host.c`, linked against the
 * compiled one) own the program's entry, the window and the timing.
 *
 * Compiled with the corpus's include path plus `../src`:
 * `-Iinclude -Iupstream/doomgeneric/doomgeneric -Isrc`.
 *
 * Windows (the C reference of the harness is built there with cl and
 * clang-cl): under `_WIN32` the engine includes `<windows.h>`
 * (`i_system.c`, `m_misc.c`), whose `LoadMenu` macro (`LoadMenuA`) then
 * renames `m_menu.c`'s load-game menu in the unity build.  Separate
 * compilation never sees both; here `<windows.h>` is included first, the same
 * way the engine includes it, and the macro is dropped, so the engine's later
 * includes are no-ops and `m_menu.c` keeps its own name.  The translation runs
 * on Linux, where none of this is compiled. */
#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#undef LoadMenu
#endif

#include "all.c"
#include "dg_host.c"
