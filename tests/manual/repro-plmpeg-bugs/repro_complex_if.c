typedef unsigned long size_t;

typedef struct buffer_t {
    size_t total_size;
    size_t length;
    int has_ended;
} buffer_t;

int repro_complex_if(buffer_t *self) {
    if ((size_t)self->total_size != 0 && (size_t)self->length == (size_t)self->total_size) {
        self->has_ended = 1;
    }
    return 0;
}
