#ifndef WASM3_FIXTURE_STDIO_H
#define WASM3_FIXTURE_STDIO_H

/* Fixture stdio: the subset the wasm3 core and the corpus entries use,
 * declared with the glibc ABI so the C build links against the real libc.
 * `printf`, `fopen`, `fread`, `fclose`, `fflush`, `fseek`, `ftell` and
 * `setvbuf` are what the translator's `--libc std` table knows; the rest
 * (`fprintf`, `snprintf`, `vsnprintf`, `puts`) are declared because wasm3's
 * own sources reference them, and whether they survive the configuration is
 * exactly what the translation attempt measures.  `FILE` stays opaque.
 */
#include <stdarg.h>
#include <stddef.h>

typedef struct FILE FILE;

extern FILE *stdout;
extern FILE *stderr;
extern FILE *stdin;

#define _IOFBF 0
#define _IOLBF 1
#define _IONBF 2

#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2

#ifndef EOF
#define EOF (-1)
#endif

int printf(const char *format, ...);
int fprintf(FILE *stream, const char *format, ...);
int snprintf(char *buffer, size_t size, const char *format, ...);
int vsnprintf(char *buffer, size_t size, const char *format, va_list args);
int puts(const char *text);
FILE *fopen(const char *path, const char *mode);
size_t fread(void *buffer, size_t size, size_t count, FILE *stream);
int fclose(FILE *stream);
int fflush(FILE *stream);
int fseek(FILE *stream, long offset, int whence);
long ftell(FILE *stream);
int setvbuf(FILE *stream, char *buffer, int mode, size_t size);

#endif
