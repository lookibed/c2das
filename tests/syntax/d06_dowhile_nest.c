int main() {
    int i = 0;
    int s = 0;
    do {
        int j = 0;
        do {
            s = s + 1;
            j = j + 1;
        } while (j < 3);
        i = i + 1;
    } while (i < 2);
    return s;
}
