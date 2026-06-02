int main() {
    int arr[3];
    arr[0] = 1;
    arr[1] = 2;
    arr[2] = 3;
    int* p = arr;
    int a = *p;
    p = p + 1;
    int b = *p;
    p = p + 1;
    int c = *p;
    return a + b + c;
}
