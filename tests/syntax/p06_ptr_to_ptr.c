int main() {
    int x = 7;
    int* p = &x;
    int** pp = &p;
    return **pp;
}
