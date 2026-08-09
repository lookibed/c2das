int read_byte(void) {
    return 7;
}

int assignment_expr_rhs(void) {
    unsigned int v = 0;
    int last = 0;
    v = (v << 8) | (unsigned int)(last = read_byte());
    return last + (int)v;
}

int main(void) {
    return assignment_expr_rhs();
}
