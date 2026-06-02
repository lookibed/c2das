int sum_to(int n) {
    int s = 0;
    int i = 0;
    for (i = 0; i <= n; i = i + 1) {
        s = s + i;
    }
    return s;
}

int main() {
    return sum_to(10);
}
