/* The engine configuration for compiling the corpus's units one by one
 * (`-include engine_config.h`): the console redirection `all.c` applies at
 * the top of the unity build, for the same reason (see `all.c`).  The entry
 * `quake_entry.c` ends the redirection after its includes. */
#include <stdio.h>
#define printf(...) fprintf(stderr, __VA_ARGS__)
#define vprintf(format, args) vfprintf(stderr, (format), (args))
#define puts(text) fprintf(stderr, "%s\n", (text))
#define putchar(ch) fputc((ch), stderr)
