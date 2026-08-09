void *calloc(unsigned long long count, unsigned long long size);
void *memset(void *destination, int value, unsigned long long count);

int runtime_calloc_and_memset_lower_to_runtime(void) {
    unsigned char *bytes = (unsigned char *)calloc(4, 1);
    memset(bytes, 0xab, 4);
    return bytes == 0;
}
