int assignment_bitand_int_lhs(unsigned char *src) {
    int payload_type = 0;
    payload_type = ((unsigned int)src[0]) & 31u;
    return payload_type;
}

int main(void) {
    unsigned char data[1] = {0x65};
    return assignment_bitand_int_lhs(data);
}
