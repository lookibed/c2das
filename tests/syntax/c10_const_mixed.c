int apply(int* result, const int* input) {
    *result = *input * 2;
    return 0;
}

int main() {
    int x = 21;
    int r = 0;
    apply(&r, &x);
    return r;
}
