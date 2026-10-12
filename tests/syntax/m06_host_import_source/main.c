/* Host imports under --module-layout source, bound one name at a time with
 * `--host-import <c_name>=<module>::<function>`; same oracle as
 * tests/syntax/h01_host_import. */
#include <stdio.h>

int eden_gpu_frame(int w, int h);
void upload_pixels(void);
void upload_patch(void);

int main(void) {
    upload_pixels();
    printf("frame=%d\n", eden_gpu_frame(320, 200));
    upload_patch();
    printf("frame=%d\n", eden_gpu_frame(640, 480));
    return 0;
}
