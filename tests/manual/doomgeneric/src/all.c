/* The c2das target graph of the doomgeneric corpus: the engine configuration
 * followed by every engine translation unit upstream's own Makefile builds
 * (minus its platform backend `doomgeneric_xlib.c`), then the corpus's
 * platform layer `dg_platform.c`, in one translation unit.
 *
 * The configuration is the one `upstream/doomgeneric/doomgeneric/Makefile`
 * and every doomgeneric port use for a 320x200 paletted framebuffer:
 * `CMAP256` makes `DG_ScreenBuffer` one palette index per pixel with the
 * palette in `colors[256]`, and `NORMALUNIX`/`LINUX` select the POSIX
 * branches of the engine.  `_DEFAULT_SOURCE` is the Makefile's too: it makes
 * glibc's headers declare `strdup`/`strcasecmp` under `-std=c11`.  They are defined here rather than on the command
 * line so the graph is the same whichever tool compiles it.
 *
 * The list and order are upstream's Makefile `SRC_DOOM` without its last
 * entry, the X11 backend `doomgeneric_xlib.c`.  The files that list never
 * names (the SDL/Allegro sound and music modules, `gusconf.c`, `mus2mid.c`,
 * `icon.c` and the other `doomgeneric_*.c` backends) are vendored but not
 * compiled. */
#define _DEFAULT_SOURCE 1
#define CMAP256 1
#define DOOMGENERIC_RESX 320
#define DOOMGENERIC_RESY 200
#define NORMALUNIX 1
#define LINUX 1

/* The engine's console goes to stderr.  Its startup log names the IWAD path
 * and prints the zone heap's address (`i_system.c`, "zone memory: %p"), so
 * it differs between two runs of the same binary; stdout is the corpus's
 * oracle (one line per frame, from the entry) and must not carry it.  These
 * three are the only ways the compiled engine writes to stdout.  The macros
 * end at the bottom of this file, before the platform layer and the entry. */
#include <stdio.h>
#define printf(...) fprintf(stderr, __VA_ARGS__)
#define puts(text) fprintf(stderr, "%s\n", (text))
#define putchar(ch) fputc((ch), stderr)

#include "dummy.c"
#include "am_map.c"
#include "doomdef.c"
#include "doomstat.c"
#include "dstrings.c"
#include "d_event.c"
#include "d_items.c"
#include "d_iwad.c"
#include "d_loop.c"
#include "d_main.c"
#include "d_mode.c"
#include "d_net.c"
#include "f_finale.c"
#include "f_wipe.c"
#include "g_game.c"
#include "hu_lib.c"
#include "hu_stuff.c"
#include "info.c"
#include "i_cdmus.c"
#include "i_endoom.c"
#include "i_joystick.c"
#include "i_scale.c"
#include "i_sound.c"
#include "i_system.c"
#include "i_timer.c"
#include "memio.c"
#include "m_argv.c"
#include "m_bbox.c"
#include "m_cheat.c"
#include "m_config.c"
#include "m_controls.c"
#include "m_fixed.c"
#include "m_menu.c"
#include "m_misc.c"
#include "m_random.c"
#include "p_ceilng.c"
#include "p_doors.c"
#include "p_enemy.c"
#include "p_floor.c"
#include "p_inter.c"
#include "p_lights.c"
#include "p_map.c"
#include "p_maputl.c"
#include "p_mobj.c"
#include "p_plats.c"
#include "p_pspr.c"
#include "p_saveg.c"
#include "p_setup.c"
#include "p_sight.c"
#include "p_spec.c"
#include "p_switch.c"
#include "p_telept.c"
#include "p_tick.c"
#include "p_user.c"
#include "r_bsp.c"
#include "r_data.c"
#include "r_draw.c"
#include "r_main.c"
#include "r_plane.c"
#include "r_segs.c"
#include "r_sky.c"
#include "r_things.c"
#include "sha1.c"
#include "sounds.c"
#include "statdump.c"
#include "st_lib.c"
#include "st_stuff.c"
#include "s_sound.c"
#include "tables.c"
#include "v_video.c"
/* The one name clash of the unity build: `p_spec.c` (flat and texture
 * animations) and `wi_stuff.c` (intermission animations) each define a
 * file-scope `anim_t` type and an `anims` table, which separate compilation
 * keeps apart.  Renaming them for `wi_stuff.c` alone restores that; nothing
 * outside `wi_stuff.c` names its two. */
#define anim_t wi_anim_t
#define anims wi_anims
#include "wi_stuff.c"
#undef anims
#undef anim_t
#include "w_checksum.c"
#include "w_file.c"
#include "w_main.c"
#include "w_wad.c"
#include "z_zone.c"
#include "w_file_stdc.c"
#include "i_input.c"
#include "i_video.c"
#include "doomgeneric.c"

#undef putchar
#undef puts
#undef printf

#include "dg_platform.c"
