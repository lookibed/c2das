/* Host imports refuse a name the C program also defines: the program would
 * have two implementations of one function. */
int eden_gpu_frame(int w, int h) { return w * h; }

int main(void) { return eden_gpu_frame(2, 3) == 6 ? 0 : 1; }
