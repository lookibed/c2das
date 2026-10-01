/* `--libc std`: a literal sscanf format with a field width is refused at
 * translation time, at the format's own source location.  `%5d` consumes at
 * most five bytes; no conversion the std engine implements is equivalent. */
#include <stdio.h>

int main(void) {
    int x = 0;
    int r = sscanf("1234567", "%5d", &x);
    printf("%d %d\n", r, x);
    return 0;
}
