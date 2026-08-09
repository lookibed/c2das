int local_struct_stack(void) {
    struct {
        unsigned long long bytes;
        unsigned int format;
    } stack[2] = {{0, 1}, {2, 3}};

    return (int)(stack[0].format + stack[1].bytes);
}

int main(void) {
    return local_struct_stack();
}
