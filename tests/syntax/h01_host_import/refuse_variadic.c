/* Host imports refuse a variadic declaration: the promoted tail has no
 * host-import mapping. */
int eden_gpu_log(const char *format, ...);

int main(void) { return eden_gpu_log("frame %d", 1); }
