void *malloc(unsigned long long size);

int runtime_malloc_returns_typed_pointer(void) {
    int *value = (int *)malloc(sizeof(int));
    return value == 0;
}
