#ifndef BINJGB_FIXTURE_STDIO_H
#define BINJGB_FIXTURE_STDIO_H

/* Fixture stdio: the subset the binjgb core and the corpus entries name,
 * declared with the glibc ABI so the C build links against the real libc.
 * binjgb's `common.c` reads and writes whole files (`fopen`, `fseek`,
 * `ftell`, `fread`, `fwrite`, `fclose`) and reports errors through
 * `fprintf(stderr, ...)`; `snprintf` builds a file name.  The corpus entries
 * add `printf` and `setvbuf`.  `FILE` stays opaque. */
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
FILE *fopen(const char *path, const char *mode);
size_t fread(void *buffer, size_t size, size_t count, FILE *stream);
size_t fwrite(const void *buffer, size_t size, size_t count, FILE *stream);
int fclose(FILE *stream);
int fseek(FILE *stream, long offset, int whence);
long ftell(FILE *stream);
int setvbuf(FILE *stream, char *buffer, int mode, size_t size);

#endif
