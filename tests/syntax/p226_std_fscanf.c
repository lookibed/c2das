/* `--libc std`: `fscanf` over a file, with the directives Quake's savegame,
 * menu and point-file readers use (`%i`, `%s`, `%79s`, `%f`, `"%f %f %f"`)
 * and their neighbours: the stream is left at the first byte no directive
 * consumed, so `fgetc` after a scan sees the pushed-back byte.
 */

typedef struct FILE FILE;

int printf(const char *format, ...);
FILE *fopen(const char *path, const char *mode);
int fclose(FILE *stream);
int fscanf(FILE *stream, const char *format, ...);
int fgetc(FILE *stream);

int main(int argc, char **argv) {
    FILE *f = fopen(argv[1], "rb");
    if (!f) {
        printf("cannot open %s\n", argv[1]);
        return 1;
    }
    int version = -1;
    int r = fscanf(f, "%i\n", &version);
    printf("%%i: %d version=%d\n", r, version);

    char word[80];
    char small[8];
    r = fscanf(f, "%s\n", word);
    printf("%%s: %d word=%s\n", r, word);
    r = fscanf(f, "%4s", small);
    printf("%%4s: %d small=%s\n", r, small);
    r = fscanf(f, "%79s\n", word);
    printf("%%79s: %d word=%s\n", r, word);

    int a = 0, b = 0, c = 0;
    unsigned x = 0;
    r = fscanf(f, "%d %i %i %x", &a, &b, &c, &x);
    printf("ints: %d a=%d b=%d c=%d x=%u\n", r, a, b, c, x);

    float org[3];
    r = fscanf(f, "%f %f %f\n", &org[0], &org[1], &org[2]);
    printf("floats: %d %.9g %.9g %.9g\n", r, org[0], org[1], org[2]);
    r = fscanf(f, "%f %f %f\n", &org[0], &org[1], &org[2]);
    printf("floats: %d %.9g %.9g %.9g\n", r, org[0], org[1], org[2]);

    double d = 0;
    float g = 0;
    r = fscanf(f, "%lf %g", &d, &g);
    printf("lf g: %d %.17g %.9g\n", r, d, g);

    r = fscanf(f, "%d", &a);
    printf("%%d before letters: %d a=%d\n", r, a);
    r = fscanf(f, "%d", &a);
    printf("%%d on letters: %d a=%d next=%c\n", r, a, fgetc(f));
    r = fscanf(f, "%2s", small);
    printf("%%2s: %d small=%s next=%c\n", r, small, fgetc(f));
    r = fscanf(f, "!%d", &a);
    printf("mismatch: %d next=%d\n", r, fgetc(f));
    r = fscanf(f, "%s", word);
    printf("last: %d word=%s\n", r, word);
    r = fscanf(f, "%s", word);
    printf("at end: %d\n", r);
    fclose(f);
    return 0;
}
