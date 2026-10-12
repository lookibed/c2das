/* Host imports (docs/eden-flags.md, "Host imports (experimental)"): the two
 * `eden_gpu_*` functions are declared and defined nowhere in the program.
 * Translated with `--host-import-prefix eden_gpu_=eden_gpu` they call the
 * fixture's hand-written daslang module `host/<model>/eden_gpu.das`; the C
 * reference links `host_reference.c`, which implements them in C. */
#include <stdio.h>

void eden_gpu_upload(const unsigned char *data, int len);
int eden_gpu_frame(int w, int h);

static unsigned char pixels[64];

int main(void) {
    for (int i = 0; i < 64; i++) {
        pixels[i] = (unsigned char)(i * 7 + 3);
    }
    eden_gpu_upload(pixels, 64);
    eden_gpu_upload(pixels + 16, 8);
    int frame = eden_gpu_frame(320, 200);
    printf("frame=%d\n", frame);
    pixels[5] = 200;
    eden_gpu_upload(&pixels[5], 1);
    printf("frame=%d\n", eden_gpu_frame(640, 480));
    return 0;
}
