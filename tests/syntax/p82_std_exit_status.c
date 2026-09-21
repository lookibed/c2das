/* `--libc std`: `exit(n)` really ends the process with status `n`.
 *
 * A C program's exit status is observable, and a translated one has to leave
 * the same one behind: daslib's `exit` prints a diagnostic and a stack walk
 * and ends the process with status 1, so the replacement stands on `exit_now`
 * instead.  The output before the call has to survive too, which is why the
 * line is printed first.
 *
 * The case is also the argument-less half of the `argv` contract: with no
 * arguments a C program sees `argc == 1` and `argv[1] == NULL`, whichever
 * launcher started the translated module.
 */

typedef struct FILE FILE;

int printf(const char *format, ...);
int fflush(FILE *stream);
void exit(int status);

int main(int argc, char **argv) {
    printf("argc=%d argv_end=%d\n", argc, argv[argc] == 0);
    fflush(0);
    exit(7);
    return 0;
}
