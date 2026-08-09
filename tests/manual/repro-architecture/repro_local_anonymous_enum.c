int use_local_enum(int x) {
    enum {
        local_a = 3,
        local_b = 7,
    } e;
    e = local_a;
    return x + e + local_b;
}

int main(void) {
    return use_local_enum(1);
}
