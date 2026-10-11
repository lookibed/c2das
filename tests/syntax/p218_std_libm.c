/* `<math.h>` under `--libc std` / `--libc eden`: every result printed as its
 * IEEE bits, so the daslang run must equal C bit for bit.  `log10f` is left
 * out: the translation is the correctly rounded `float` of `log10`, and
 * glibc's `log10f(3.0f)` is one ulp off it (the documented exception in
 * `libc.rs libm_function`). */
#include <math.h>
#include <stdio.h>
#include <string.h>

static unsigned long long bits_d(double x) {
    unsigned long long u;
    memcpy(&u, &x, sizeof u);
    return u;
}

static unsigned bits_f(float x) {
    unsigned u;
    memcpy(&u, &x, sizeof u);
    return u;
}

static double vals[] = {0.0, -0.0, 0.5, -1.25, 2.0, 3.141592653589793, 100.75, -7.5};

int main(void) {
    unsigned long long hd = 1469598103934665603ULL;
    unsigned hf = 2166136261u;
    for (int i = 0; i < 8; i++) {
        double x = vals[i];
        float f = (float)x;
        double d[] = {sqrt(fabs(x)), sin(x), cos(x), tan(x), atan(x), atan2(x, 1.5), atan2(-1.0, x),
                      pow(fabs(x) + 1.0, 2.5), exp(x / 8.0), log(fabs(x) + 1.0),
                      log10(fabs(x) + 1.0), floor(x), ceil(x), fabs(x), fmod(x, 0.75),
                      asin(x / 128.0), acos(x / 128.0)};
        float g[] = {sqrtf(fabsf(f)), sinf(f), cosf(f), tanf(f), atanf(f), atan2f(f, 1.5f),
                     powf(fabsf(f) + 1.0f, 2.5f), expf(f / 8.0f), logf(fabsf(f) + 1.0f),
                     floorf(f), ceilf(f), fabsf(f), fmodf(f, 0.75f),
                     asinf(f / 128.0f), acosf(f / 128.0f)};
        for (unsigned k = 0; k < sizeof d / sizeof d[0]; k++) {
            hd = (hd ^ bits_d(d[k])) * 1099511628211ULL;
        }
        for (unsigned k = 0; k < sizeof g / sizeof g[0]; k++) {
            hf = (hf ^ bits_f(g[k])) * 16777619u;
        }
        printf("%d %llx %x\n", i, bits_d(d[i]), bits_f(g[i]));
    }
    printf("double=%llx float=%x\n", hd, hf);
    printf("fmod(-5.5,2)=%llx floor(-0.5)=%llx\n", bits_d(fmod(-5.5, 2.0)), bits_d(floor(-0.5)));
    return 0;
}
