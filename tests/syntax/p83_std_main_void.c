/* `--libc std`: a C `main(void)` is a process entry point too.
 *
 * daslang runs an exported zero-argument function, and C's `main` keeps the
 * name the renamer gave it, so the translator adds the wrapper whatever the C
 * parameter list is.  Without one this module has only `main_0()` and daslang
 * answers "function 'main' not found".
 *
 * The program also defines a function and a global of its own by names the std
 * prelude spells unqualified (`to_char`, `seek_set`): the renamer reserves the
 * daslib value namespace under `--libc std`, so these are the program's own
 * and the helpers still reach daslib's.
 */

int printf(const char *format, ...);

int seek_set = 99;

static int to_char(int b) { return b + 1; }

int main(void) {
    printf("main_void to_char=%d seek_set=%d\n", to_char(64), seek_set);
    return 0;
}
