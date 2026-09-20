#ifndef PLMPEG_STDIO_H
#define PLMPEG_STDIO_H

/* Fixture stdio: the subset the corpus entries use, declared with the
 * glibc ABI so the C build links against the real libc, and small enough
 * for the translator's `--libc std` table (printf, fopen, fread, fclose,
 * fflush, fseek, ftell, setvbuf, stdout/stderr).  `FILE` stays opaque. */
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

int printf(const char *format, ...);
FILE *fopen(const char *path, const char *mode);
size_t fread(void *buffer, size_t size, size_t count, FILE *stream);
int fclose(FILE *stream);
int fflush(FILE *stream);
int fseek(FILE *stream, long offset, int whence);
long ftell(FILE *stream);
int setvbuf(FILE *stream, char *buffer, int mode, size_t size);

#endif
