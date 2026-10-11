/* `rand`/`srand` under `--libc std` / `--libc eden`: glibc's TYPE_3
 * generator, so the daslang run prints glibc's numbers. */
#include <stdio.h>
#include <stdlib.h>

static void run(const char *label) {
    unsigned sum = 0;
    printf("%s:", label);
    for (int i = 0; i < 5; i++) {
        printf(" %d", rand());
    }
    for (int i = 0; i < 1000; i++) {
        sum = sum * 31u + (unsigned)rand();
    }
    printf(" sum=%u\n", sum);
}

int main(void) {
    run("default");
    srand(42);
    run("42");
    srand(0);
    run("0");
    srand(1);
    run("1");
    srand(4294967295u);
    run("max");
    return 0;
}
