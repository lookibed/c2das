int main() {
    int arr[3];
    arr[0] = 10;
    arr[1] = 20;
    arr[2] = 30;
    int* p = arr;
    return p[0] + p[1] + p[2];
}
