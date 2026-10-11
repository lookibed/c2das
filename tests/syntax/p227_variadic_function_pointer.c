/* A call through a pointer to a variadic function, as Quake's Host_Status_f
 * chooses between Con_Printf and SV_ClientPrintf: the pointer's function type
 * fixes where the promoted tail starts, and the tail crosses exactly as it
 * does in a direct call.
 */

#include <stdarg.h>
#include <stdio.h>

static void shout(char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    printf("SHOUT: ");
    vprintf(fmt, ap);
    va_end(ap);
}

static void whisper(char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    printf("whisper: ");
    vprintf(fmt, ap);
    va_end(ap);
}

static int sum(int count, ...) {
    va_list ap;
    int total = 0;
    va_start(ap, count);
    for (int i = 0; i < count; i++)
        total += va_arg(ap, int);
    va_end(ap);
    return total;
}

typedef int (*summer_t)(int, ...);

struct speaker {
    const char *name;
    void (*say)(char *fmt, ...);
};

int main(void) {
    void (*print)(char *fmt, ...);
    for (int loud = 0; loud < 2; loud++) {
        print = loud ? shout : whisper;
        print("host: %s\n", "quake");
        print("version: %4.2f %d%c\n", 1.09, 42, '!');
    }
    summer_t s = sum;
    printf("sum = %d %d\n", s(3, 1, 2, 3), (*s)(0));
    struct speaker sp = {"x", shout};
    sp.say("%s via a field\n", sp.name);
    return 0;
}
