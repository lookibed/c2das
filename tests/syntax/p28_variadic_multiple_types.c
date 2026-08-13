#include <stdarg.h>

int mixed_variadic(int count, ...) {
    va_list args;
    va_start(args, count);
    int number = va_arg(args, int);
    double fraction = va_arg(args, double);
    int *pointer = va_arg(args, int *);
    va_end(args);
    return number + (int)fraction + (*pointer == 7 ? 0 : 100);
}

int variadic_multiple_types_runtime(void) {
    int value = 7;
    return mixed_variadic(3, 2, 3.0, &value) != 5;
}
