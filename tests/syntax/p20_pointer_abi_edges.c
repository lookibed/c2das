int accepts_void(void *value) {
    return value != 0;
}

void *echo_void(void *value) {
    return value;
}

unsigned char *echo_byte(unsigned char *value) {
    return value;
}

int pointer_abi_edges(void) {
    unsigned char byte = 0;
    unsigned char *typed = &byte;
    void *erased = (void *)typed;
    unsigned char *restored = (unsigned char *)erased;
    unsigned char *nil = 0;

    if (nil != 0) {
        return 1;
    }
    return accepts_void(erased) + (echo_byte(restored) == typed) + (echo_void(typed) == erased) != 3;
}
