#include <stdarg.h>

int sum(int count, ...) {
    va_list args;
    va_start(args, count);
    int total = 0;
    total += va_arg(args, int);
    total += va_arg(args, int);
    total += va_arg(args, int);
    va_end(args);
    return total;
}

int variadic_sum_runtime(void) {
    return sum(3, 10, 20, 30) != 60;
}
