#include <stddef.h>

struct buffer_t {
    size_t bit_index;
    size_t capacity;
    size_t length;
    size_t total_size;
    int has_ended;
};

int plm_buffer_has(struct buffer_t *self, size_t count) {
    if (((self->length << 3) - self->bit_index) >= count) {
        return 1;
    }
    if (self->total_size != 0 && self->length == self->total_size) {
        self->has_ended = 1;
    }
    return 0;
}
