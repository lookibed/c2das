unsigned char *identity_byte(unsigned char *value) {
    return value;
}

void *identity_void(void *value) {
    return value;
}

int consume_byte(unsigned char *value) {
    return value != 0;
}

int nonruntime_pointer_call(void) {
    unsigned char byte = 0;
    unsigned char *typed = &byte;
    void *erased = identity_void(typed);
    unsigned char *restored = identity_byte(erased);
    return consume_byte(restored) + (identity_void(restored) == erased) != 2;
}
