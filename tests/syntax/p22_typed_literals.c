unsigned char take_byte(unsigned char value) {
    return value;
}

unsigned long long take_u64(unsigned long long value) {
    return value;
}

int take_int(int value) {
    return value;
}

unsigned char return_byte_literal(void) {
    return 0xab;
}

unsigned long long return_u64_literal(void) {
    return 0x100000000ULL;
}

int return_int_literal(void) {
    return 42;
}

int typed_literals(void) {
    unsigned char byte = 0xab;
    unsigned long long wide = 0x100000000ULL;
    int signed_value = 42;
    return take_int(signed_value) + (int)take_byte(byte) + (int)take_u64(wide)
        + return_int_literal() + (int)return_byte_literal() + (int)return_u64_literal() != 426;
}
