int main() {
    int i = 0;
    int s = 0;
    while (i < 5) {
        i = i + 1;
        do {
            if (i == 3) {
                continue;
            }
            s = s + 1;
        } while (0);
    }
    return s;
}
