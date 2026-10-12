/* `strerror` over C memory: the text is a C string the program reads byte by
 * byte, as Quake's `Sys_FileOpenWrite` passes `strerror(errno)` to `%s`. */
#include <errno.h>
#include <stdio.h>
#include <string.h>

int main(void) {
    const char *a = strerror(ENOENT);
    printf("%s|%d\n", a, (int)strlen(a));
    printf("%s\n", strerror(EINVAL));
    printf("%s\n", strerror(ERANGE));
    printf("%s\n", strerror(9999));
    printf("%s\n", strerror(-7));
    char copy[64];
    strcpy(copy, strerror(EACCES));
    printf("%s %c\n", copy, strerror(EPERM)[0]);
    return 0;
}
