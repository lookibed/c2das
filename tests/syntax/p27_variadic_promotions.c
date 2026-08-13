#include <stdarg.h>

double promoted_sum(int count, ...) {
    va_list args;
    va_start(args, count);
    int from_char = va_arg(args, int);
    int from_short = va_arg(args, int);
    double from_float = va_arg(args, double);
    va_end(args);
    return from_char + from_short + from_float;
}

int variadic_promotions_runtime(void) {
    return promoted_sum(3, (char)2, (short)3, 5.0f) != 10.0;
}
