/* printf's float conversions (`%f %e %g` with flags, width and precision),
 * as Quake's `Cvar_SetValue` and console use them. */
#include <stdio.h>

int main(void) {
    float v = 2.5f;
    double d = -1234.5678;
    char val[32];
    sprintf(val, "%f", v);
    printf("[%s]\n", val);
    printf("[%f] [%.0f] [%10.3f] [%-10.2f] [%+.1f] [% f] [%08.2f]\n", d, d, d, d, 3.25, 0.5, -2.75);
    printf("[%e] [%E] [%.2e] [%g] [%G] [%g] [%#g] [%.3g]\n", d, d, 1e-5, d, 1e20, 100000.0, 1.0, 3.14159);
    printf("[%5.1f fps] [%*.*f]\n", 72.25f, 8, 2, 1.0 / 3.0);
    return 0;
}
