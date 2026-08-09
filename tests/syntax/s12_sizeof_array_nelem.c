int sizeof_array_nelem(void) {
    int values[13];
    return (int)(sizeof(values) / sizeof(values[0]));
}
