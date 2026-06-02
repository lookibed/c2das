int sum_to(int n) {
    int i = 0;
    int s = 0;
    while (i <= n) {
        s = s + i;
        i = i + 1;
    }
    return s;
}

int main() {
    return sum_to(10);
}
