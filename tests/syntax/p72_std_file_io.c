/* `--libc std`: file input, printf conversions and a monotonic clock.
 *
 * The fixture declares every libc entry point it uses itself, so the
 * translation unit never sees a system header: what the translator has to
 * replace is exactly this list of body-less external declarations.
 */

typedef unsigned long size_t;
typedef struct FILE FILE;

extern FILE *stdout;

int printf(const char *format, ...);
FILE *fopen(const char *path, const char *mode);
size_t fread(void *buffer, size_t size, size_t count, FILE *stream);
int fclose(FILE *stream);
int setvbuf(FILE *stream, char *buffer, int mode, size_t size);
void *malloc(size_t size);
void free(void *block);

struct timespec {
    long tv_sec;
    long tv_nsec;
};

int clock_gettime(int clock_id, struct timespec *ts);

#define CHUNK 64

int main(int argc, char **argv) {
    struct timespec first;
    struct timespec second;
    const char *path;
    FILE *stream;
    unsigned char *buffer;
    unsigned int sum;
    unsigned long total;
    size_t got;
    int i;

    setvbuf(stdout, 0, 0, 0);

    path = argv[argc - 1];
    stream = fopen(path, "rb");
    if (stream == 0) {
        printf("open_failed\n");
        return 1;
    }

    buffer = (unsigned char *)malloc(CHUNK);
    sum = 0u;
    total = 0ul;
    for (;;) {
        got = fread(buffer, 1, CHUNK, stream);
        if (got == 0) {
            break;
        }
        for (i = 0; i < (int)got; i++) {
            sum = sum * 31u + (unsigned int)buffer[i];
        }
        total = total + (unsigned long)got;
    }
    fclose(stream);
    free(buffer);

    printf("bytes=%d\n", (int)total);
    printf("sum=%u\n", sum);
    printf("[%s|%c|%ld|%lld|%x|%%|%8s|%-6d|%05d]\n", "sample", 'Z', -1234567L,
           9007199254740993LL, 48879u, "pad", 42, 7);

    clock_gettime(1, &first);
    clock_gettime(1, &second);
    if (second.tv_sec > first.tv_sec ||
        (second.tv_sec == first.tv_sec && second.tv_nsec >= first.tv_nsec)) {
        printf("clock_ok=1\n");
    }
    return 0;
}
