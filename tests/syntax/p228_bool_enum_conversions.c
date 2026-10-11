/* Conversions Quake's QuakeC builtins and BSP walkers make: an enumeration
 * (`qboolean`) and a comparison or `!x` converted to `float`, `!side` as an
 * array index, `(qboolean)!x`, and a call through an unprototyped function
 * pointer (`void (*procedure)()`) with an argument, whose callee has the
 * promoted argument types (C11 6.5.2.2p6).
 */

#include <stdio.h>

typedef enum { false, true } qboolean;

static qboolean check(int v) { return v > 2 ? true : false; }

struct trace {
    qboolean allsolid;
    qboolean inwater;
};

static int calls;

static void poll_one(void *arg) {
    calls += *(int *)arg;
}

static void poll_two(int a, double b) {
    printf("poll_two %d %.2f\n", a, b);
}

struct procedure {
    void (*run)();
    void *arg;
};

static qboolean is_free(int f) { return (qboolean)!f; }

int main(void) {
    float g[4];
    struct trace t = {true, false};
    g[0] = check(5);
    g[1] = check(1);
    g[2] = t.allsolid;
    g[3] = t.inwater;
    printf("%.1f %.1f %.1f %.1f\n", g[0], g[1], g[2], g[3]);

    float a = 0.0f, b = 3.0f;
    float c = !a, d = !b, e = (a == 0.0f), h = (b < a);
    printf("%.1f %.1f %.1f %.1f\n", c, d, e, h);

    int children[2] = {10, 20};
    for (int side = 0; side < 2; side++)
        printf("child %d\n", children[!side]);
    printf("free %d %d\n", is_free(0), is_free(7));

    int step = 3;
    struct procedure p = {poll_one, &step};
    p.run(p.arg);
    p.run(p.arg);
    printf("calls %d\n", calls);
    void (*q)() = (void (*)())poll_two;
    float half = 0.5f;
    q(7, half);
    return 0;
}
