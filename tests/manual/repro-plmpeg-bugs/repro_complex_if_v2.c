typedef unsigned long size_t;

typedef struct buffer_t {
    size_t bit_index;
    size_t capacity;
    size_t length;
    size_t total_size;
    int has_ended;
} buffer_t;

int plm_buffer_has(buffer_t *self, size_t count) {
    if (((self->length << 3) - self->bit_index) >= count) {
        return 1;
    }
    if (self->total_size != 0 && self->length == self->total_size) {
        self->has_ended = 1;
    }
    return 0;
}
