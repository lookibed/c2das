const int* min_ptr(const int* a, const int* b) {
    if (*a < *b) {
        return a;
    } else {
        return b;
    }
}

int main() {
    int x = 10;
    int y = 20;
    const int* p = min_ptr(&x, &y);
    return *p;
}
