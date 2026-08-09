typedef int (*write_fn)(long long offset, void *buffer, unsigned long size, void *token);

int function_pointer_arg_coerce(write_fn write_callback, void *token) {
    unsigned char box[24];
    return write_callback(0, box, sizeof(box), token);
}
