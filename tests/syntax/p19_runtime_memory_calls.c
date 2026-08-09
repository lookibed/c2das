void *malloc(unsigned long long size);
void *realloc(void *address, unsigned long long size);
void free(void *address);
void *memcpy(void *destination, const void *source, unsigned long long count);
void *memmove(void *destination, const void *source, unsigned long long count);
int memcmp(const void *left, const void *right, unsigned long long count);
void *memchr(const void *source, int value, unsigned long long count);

int runtime_memory_calls_lower_to_runtime(void) {
    unsigned char *left = (unsigned char *)malloc(8);
    unsigned char *right = (unsigned char *)malloc(8);
    memcpy(left, right, 8);
    memmove(left + 1, left, 7);
    int comparison = memcmp(left, right, 8);
    unsigned char *found = (unsigned char *)memchr(left, 0, 8);
    int failed = comparison != 0 || found == 0;
    left = (unsigned char *)realloc(left, 16);
    free(right);
    free(left);
    return failed;
}
