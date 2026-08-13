int unsupported_inline_asm(void) {
    int value = 1;
    __asm__ volatile ("" : "+r"(value) : : "memory");
    return value;
}
