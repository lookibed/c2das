int max(int a, int b) {
    if (a > b) {
        return a;
    } else {
        return b;
    }
}

int sum_to_n(int n) {
    int i = 0;
    int s = 0;
    while (i <= n) {
        s = s + i;
        i = i + 1;
    }
    return s;
}

int main() {
    return sum_to_n(5);
}
