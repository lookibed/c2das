typedef int (*write_cb)(long pos, const void *data, unsigned long size, unsigned long token);

struct writer {
    write_cb write;
    unsigned long token;
};

int call_writer(struct writer *w, const void *data) {
    int rc = w->write(0, data, 4, w->token);
    return rc;
}

int main(void) {
    struct writer w = {0, 0};
    return call_writer(&w, 0);
}
