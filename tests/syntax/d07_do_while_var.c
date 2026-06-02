int main() {
    int n = 5;
    int f = 1;
    do {
        f = f * n;
        n = n - 1;
    } while (n > 1);
    return f;
}
