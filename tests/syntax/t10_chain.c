int max(int a, int b) {
    if (a > b) {
        return a;
    } else {
        return b;
    }
}

int min(int a, int b) {
    if (a < b) {
        return a;
    } else {
        return b;
    }
}

int clamp(int v, int lo, int hi) {
    int r = v;
    if (r < lo) {
        r = lo;
    } else if (r > hi) {
        r = hi;
    }
    return r;
}

int main() {
    int m = max(10, 20);
    int n = min(10, 20);
    int c = clamp(15, 0, 10);
    return m + n + c;
}
