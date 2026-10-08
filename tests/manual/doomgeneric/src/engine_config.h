/* The engine configuration of the `--module-layout source` case
 * (`doomgeneric-demo1-std-source`), force-included (`-include`) into every
 * unit because each engine `.c` file is compiled on its own there.  It is
 * the configuration `all.c` defines at the top of the unity build, for the
 * same reasons (see `all.c`):
 *
 * - `_DEFAULT_SOURCE`, `CMAP256`, the 320x200 framebuffer, `NORMALUNIX` and
 *   `LINUX` are upstream's Makefile configuration;
 * - the engine's console goes to stderr, because its startup log prints the
 *   zone heap's address and stdout is the corpus's oracle.  The entry
 *   `doom_entry.c` ends the redirection after its includes.
 *
 * The unity build's third workaround, renaming `wi_stuff.c`'s file-scope
 * `anim_t` and `anims`, is not here: separately compiled units keep their
 * statics apart, and the translator renames them where the units share one
 * daslang module. */
#define _DEFAULT_SOURCE 1
#define CMAP256 1
#define DOOMGENERIC_RESX 320
#define DOOMGENERIC_RESY 200
#define NORMALUNIX 1
#define LINUX 1

#include <stdio.h>
#define printf(...) fprintf(stderr, __VA_ARGS__)
#define puts(text) fprintf(stderr, "%s\n", (text))
#define putchar(ch) fputc((ch), stderr)
