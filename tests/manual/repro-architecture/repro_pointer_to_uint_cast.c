struct reader {
    unsigned int *buf;
    unsigned int *origin;
};

unsigned int pointer_to_uint_cast(struct reader *bs) {
    unsigned int pos = 0;
    pos = (unsigned int)(bs->buf - bs->origin);
    return pos;
}

int main(void) {
    unsigned int data[4] = {0, 1, 2, 3};
    struct reader bs = {data + 3, data};
    return (int)pointer_to_uint_cast(&bs);
}
