/* `setjmp`/`longjmp` under `--libc std` / `--libc eden`, in the one shape
 * the translator lowers — Quake's `Host_Frame` guard:
 * `if (setjmp(buf)) return;` at the top of a function body, with the
 * `longjmp` several calls below it. */
#include <setjmp.h>
#include <stdio.h>

static jmp_buf abort_frame;
static int frames;
static int depth_reached;

static void error(const char *what) {
    printf("error: %s\n", what);
    longjmp(abort_frame, 1);
}

static void think(int frame, int depth) {
    depth_reached = depth;
    if (depth < 3) {
        think(frame, depth + 1);
        return;
    }
    if (frame % 3 == 2) {
        error("frame aborted");
    }
}

static void frame(int n) {
    int local = n * 10;
    if (setjmp(abort_frame)) {
        printf("frame %d: recovered at depth %d\n", n, depth_reached);
        return;
    }
    think(n, 0);
    frames++;
    printf("frame %d: done local=%d\n", n, local);
}

static int value_frame(int n) {
    if (setjmp(abort_frame)) {
        return -1;
    }
    if (n > 1) {
        longjmp(abort_frame, 0);
    }
    return n * 2;
}

int main(void) {
    for (int i = 0; i < 6; i++) {
        frame(i);
    }
    printf("frames=%d\n", frames);
    printf("%d %d %d\n", value_frame(0), value_frame(1), value_frame(5));
    return 0;
}
