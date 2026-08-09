static int plus_one(int x) {
    return x + 1;
}

int call_cb(int x) {
    int (*fp)(int) = plus_one;
    return fp(x);
}
