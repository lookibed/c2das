int predefined_sizeof_builtin_runtime(void) {
    int values[3] = { 1, 2, 3 };
    int expected = __builtin_expect(values[0], 1);
    return sizeof(values) != 12 || expected != 1;
}
