typedef unsigned char uint8_t;
typedef unsigned int uint32_t;

static uint32_t fold_bytes(const uint8_t *bytes, int length) {
    uint32_t hash = 0x811c9dc5u;
    int index = 0;

    for (index = 0; index < length; index++) {
        hash ^= bytes[index];
        hash *= 0x01000193u;
    }

    return hash;
}

int main(void) {
    static const uint8_t data[3] = {1, 2, 3};
    return (int)fold_bytes(data, 3);
}
