#include <stdarg.h>

typedef int (*variadic_fn)(int, ...);

int p29_variadic_function_pointer_unsupported(variadic_fn callback) {
    return callback(1, 7);
}
