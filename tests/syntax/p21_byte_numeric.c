int byte_numeric_edges(void) {
    unsigned char source[2] = { 3, 5 };
    unsigned char left = source[0];
    unsigned char right = source[1];
    unsigned int value = 0;

    if (left < right) {
        value = left + right;
    }
    return (int)(value + (left & right)) != 9;
}
