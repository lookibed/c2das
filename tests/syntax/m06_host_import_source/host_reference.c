/* The C reference of the fixture's host module `eden_gpu.das`. */
static unsigned int sum = 0;

void eden_gpu_upload(const unsigned char *data, int len) {
    for (int i = 0; i < len; i++) {
        sum = sum * 31u + data[i];
    }
}

int eden_gpu_frame(int w, int h) {
    return (int)(sum ^ (unsigned int)(w * h));
}
