/* Host imports refuse a function-pointer parameter: it has no mapping to a
 * host function (docs/eden-flags.md, "Host imports (experimental)"). */
typedef void (*eden_gpu_callback)(int);

void eden_gpu_on_frame(eden_gpu_callback callback);

static void on_frame(int frame) { (void)frame; }

int main(void) {
    eden_gpu_on_frame(on_frame);
    return 0;
}
