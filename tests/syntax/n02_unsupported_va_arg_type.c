#include <stdarg.h>

struct unsupported_va_arg_payload {
    int value;
};

int unsupported_va_arg_type(int count, ...) {
    va_list args;
    va_start(args, count);
    struct unsupported_va_arg_payload value = va_arg(args, struct unsupported_va_arg_payload);
    va_end(args);
    return value.value;
}
