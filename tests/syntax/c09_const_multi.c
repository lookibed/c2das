int add(const int* a, const int* b) {
    return *a + *b;
}

int main() {
    int x = 5;
    int y = 7;
    return add(&x, &y);
}
