int sum(const int* arr, int n) {
    int s = 0;
    int i = 0;
    while (i < n) {
        s = s + arr[i];
        i = i + 1;
    }
    return s;
}

int main() {
    int a[3];
    a[0] = 1;
    a[1] = 2;
    a[2] = 3;
    return sum(a, 3);
}
