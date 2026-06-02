int main() {
    int a = 1;
    int b = 2;
    if (a < b) {
        goto end;
    }
    a = 99;
end:
    return a;
}
