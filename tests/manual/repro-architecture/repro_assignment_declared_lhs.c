int assignment_declared_lhs(int bit_count, unsigned int cb) {
    bit_count = bit_count - cb;
    return bit_count;
}

int main(void) {
    return assignment_declared_lhs(12, 5);
}
