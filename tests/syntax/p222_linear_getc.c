/* `getc`/`fgetc` over a file: every byte as an unsigned char, then EOF, as
 * Quake's demo reader (`cl_demo.c`) reads its track line. */
#include <stdio.h>

int main(int argc, char **argv) {
    if (argc < 2) {
        return 2;
    }
    FILE *f = fopen(argv[1], "rb");
    if (!f) {
        return 3;
    }
    unsigned sum = 0;
    int count = 0;
    int c;
    int first = getc(f);
    count++;
    sum = first;
    while ((c = fgetc(f)) != EOF) {
        sum = sum * 31u + (unsigned)c;
        count++;
    }
    printf("first=%d count=%d sum=%u eof=%d again=%d\n", first, count, sum, feof(f) != 0, getc(f));
    fclose(f);
    return 0;
}
