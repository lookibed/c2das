int sum_array(void) {
    int data[3] = {1, 2, 3};
    int i = 0;
    int sum = 0;
    for (i = 0; i < 3; i++) {
        sum += data[i];
    }
    return sum;
}
