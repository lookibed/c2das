int main() {
    int x = 10;
    const int* p = &x;
    int y = *p;
    return y;
}
