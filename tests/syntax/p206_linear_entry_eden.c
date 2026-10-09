/* `--entry eden`: the host calls c2da_eden_start(args) instead of a `main`
 * wrapper reading the command line.  argv is built in the linear heap
 * (argv[argc] is NULL) and `exit` from a nested call is the answered status. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void finish(int code) {
    printf("finishing with %d\n", code);
    exit(code);
}

int main(int argc, char **argv) {
    printf("argc=%d\n", argc);
    printf("argv[argc] is %s\n", argv[argc] == NULL ? "NULL" : "set");
    for (int i = 1; i < argc; i++) {
        size_t n = strlen(argv[i]);
        const char *tail = n >= 2 ? argv[i] + n - 2 : argv[i];
        printf("argv[%d] ends with %s\n", i, tail);
    }
    finish(argc + 5);
    return 0;
}
