int take_int(int value) {
    return value;
}

int bool_return(int left, int right) {
    return left < right;
}

int bool_numeric(int left, int right) {
    int assigned = left < right;
    int from_call = take_int(left == right);
    return assigned + from_call + (left != right);
}

int bool_numeric_runtime(void) {
    return bool_return(1, 2) != 1 || bool_numeric(1, 2) != 2;
}
