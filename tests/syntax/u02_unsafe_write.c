void set_val(int* p, int v) {
    *p = v;
}

int main() {
    int x = 10;
    set_val(&x, 99);
    return x;
}
