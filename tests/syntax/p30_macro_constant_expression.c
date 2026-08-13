#define SCALE 4
#define ADD_SCALE(x) ((x) + SCALE)

int macro_constant_expression_runtime(void) {
    return ADD_SCALE(3) != 7;
}
