extern void *memchr(const void *s, int c, unsigned long n);
extern void *memset(void *s, int c, unsigned long n);
extern char *strdup(const char *s);
extern unsigned long strlen(const char *s);

int libc_runtime_calls(char *buf) {
    void *found = memchr(buf, 0, 4);
    memset(buf, 0, 4);
    char *dup = strdup(buf);
    if (found != 0) {
        return 1;
    }
    if (dup != 0) {
        return 2;
    }
    return (int)strlen(buf);
}

int main(void) {
    char buf[4] = {1, 2, 3, 0};
    return libc_runtime_calls(buf);
}
