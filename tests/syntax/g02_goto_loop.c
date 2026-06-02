int main() {
    int i = 0;
    int s = 0;
loop:
    s = s + i;
    i = i + 1;
    if (i <= 5) {
        goto loop;
    }
    return s;
}
