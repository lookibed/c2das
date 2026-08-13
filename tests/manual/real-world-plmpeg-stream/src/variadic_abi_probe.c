/*
 * Real-world PLMPEG integration probe: it uses the same header/configuration
 * surface as the stream module, while isolating the variadic ABI so unrelated
 * multi-TU decoder failures cannot hide its runtime result.
 */
#include <stdarg.h>
#include <stddef.h>
#include <stdint.h>

#define PLM_NO_STDIO
#include "../upstream/pl_mpeg.h"

static int plmpeg_variadic_total(int count, ...) {
    va_list values;
    int first;
    int second;

    va_start(values, count);
    first = va_arg(values, int);
    second = va_arg(values, int);
    va_end(values);
    return first + second;
}

int plmpeg_variadic_abi_probe(void) {
    return plmpeg_variadic_total(2, (char)4, (short)6) != 10;
}
