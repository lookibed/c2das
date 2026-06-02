int main() {
    int i = 0;
    int s = 0;
    do {
        if (i == 3) {
            break;
        }
        s = s + i;
        i = i + 1;
    } while (i < 10);
    return s;
}
