/* `sprintf`/`vsprintf`: `snprintf` without a limit, as Quake's `va()` and
 * console code use them. */
#include <stdarg.h>
#include <stdio.h>

static char text[128];

static char *va(const char *format, ...) {
    va_list ap;
    va_start(ap, format);
    vsprintf(text, format, ap);
    va_end(ap);
    return text;
}

int main(void) {
    char buf[64];
    int n = sprintf(buf, "map %s skill %d %5.2f", "e1m1", 2, 0.5);
    printf("[%s] %d\n", buf, n);
    printf("[%s]\n", va("%s/%s.%03d", "id1", "demo", 7));
    n = sprintf(buf, "%c%c", 'o', 'k');
    printf("[%s] %d\n", buf, n);
    return 0;
}
