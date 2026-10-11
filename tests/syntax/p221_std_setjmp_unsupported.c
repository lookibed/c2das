/* A `setjmp` whose result is kept is not the guard shape the translator
 * lowers: translation fails at the call. */
#include <setjmp.h>

static jmp_buf env;

int main(void) {
    int r = setjmp(env);
    if (r == 0) {
        longjmp(env, 2);
    }
    return r;
}
