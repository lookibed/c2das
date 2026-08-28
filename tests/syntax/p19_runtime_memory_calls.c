void *malloc(unsigned long long size);
void *realloc(void *address, unsigned long long size);
void free(void *address);
void *memset(void *destination, int value, unsigned long long count);
void *memcpy(void *destination, const void *source, unsigned long long count);
void *memmove(void *destination, const void *source, unsigned long long count);
int memcmp(const void *left, const void *right, unsigned long long count);
void *memchr(const void *source, int value, unsigned long long count);

int runtime_memory_calls_lower_to_runtime(void) {
    unsigned char *left = (unsigned char *)malloc(8);
    unsigned char *right = (unsigned char *)malloc(8);
    if (left == 0 || right == 0) {
        free(left);
        free(right);
        return 1;
    }
    memset(left, 0x11, 8);
    memset(right, 0x5a, 8);
    memcpy(left, right, 8);
    memset(left, 0x11, 1);
    /* Identical source and destination are valid overlapping memmove ranges. */
    memmove(left, left, 8);
    int comparison = memcmp(left, right, 8);
    unsigned char *found = (unsigned char *)memchr(left, 0x5a, 8);
    int failed = comparison == 0 || found == 0;
    unsigned char *resized = (unsigned char *)realloc(left, 16);
    if (resized == 0) {
        free(left);
        free(right);
        return 1;
    }
    left = resized;
    free(right);
    free(left);
    return failed;
}
