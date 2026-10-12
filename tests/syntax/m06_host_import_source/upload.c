/* Host imports under --module-layout source: this unit calls the imported
 * upload, so its module `require`s the host module and passes the heap that
 * lives in the shared `c2da_runtime` module. */
void eden_gpu_upload(const unsigned char *data, int len);

static unsigned char pixels[64];

void upload_pixels(void) {
    for (int i = 0; i < 64; i++) {
        pixels[i] = (unsigned char)(i * 7 + 3);
    }
    eden_gpu_upload(pixels, 64);
    eden_gpu_upload(pixels + 16, 8);
}

void upload_patch(void) {
    pixels[5] = 200;
    eden_gpu_upload(&pixels[5], 1);
}
