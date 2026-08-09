int array_initializers_runtime(void) {
    unsigned char values[3] = { 3, 5 };
    unsigned char zeros[2] = { 0 };

    return values[0] != 3 || values[1] != 5 || values[2] != 0
        || zeros[0] != 0 || zeros[1] != 0;
}
