#define POST_INCREMENT(x) ((x)++)

int macro_side_effect_runtime(void) {
    int value = 3;
    int result = POST_INCREMENT(value);
    return value != 4 || result != 3;
}
