void swap(int* a, int* b) {
    int t = *a;
    *a = *b;
    *b = t;
}

int main() {
    int x = 10;
    int y = 20;
    swap(&x, &y);
    return x * 100 + y;
}
