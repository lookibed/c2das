int read_val(const int* p) {
    return *p;
}

int main() {
    int x = 99;
    return read_val(&x);
}
