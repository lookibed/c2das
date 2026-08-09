int local_const_var(void) {
    const long long size_limit = 0x7fffffffLL;
    return (int)(size_limit & 255);
}

int main(void) {
    return local_const_var();
}
