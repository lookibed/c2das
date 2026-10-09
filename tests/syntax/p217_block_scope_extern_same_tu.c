/* A block-scope `extern` declaration of an object this translation unit
 * defines at file scope names that same object (C11 6.2.2p4): it is a
 * reference to the file-scope object, not a new one.  Doom's unity build has
 * this shape: g_game.c defines `fixed_t forwardmove[2] = {0x19, 0x32};` and
 * d_main.c declares `extern int forwardmove[2];` inside a function.
 *
 * - `bump_moves` declares `extern int moves[2];` before the file-scope
 *   definition (spelled with a typedef, `fixed`) appears, and writes to it.
 * - `read_scalar_block` reads the scalar `counter` through a block-scope
 *   `extern int counter;`; `read_scalar_file` reads it by its file-scope name.
 * - `sum_moves_block` reads the array through a second block-scope extern
 *   placed after the definition; `sum_moves_file` reads it directly.
 * All of them must see the one object each name denotes.
 */

#include <stdio.h>

typedef int fixed;

int bump_moves(int by) {
    extern int moves[2];
    moves[0] += by;
    moves[1] += by * 2;
    return moves[0] + moves[1];
}

void bump_counter(void) {
    extern int counter;
    counter += 3;
}

fixed moves[2] = {25, 50};
int counter = 7;

int read_scalar_block(void) {
    extern int counter;
    return counter;
}

int read_scalar_file(void) {
    return counter;
}

int sum_moves_block(void) {
    extern fixed moves[2];
    return moves[0] * 1000 + moves[1];
}

int sum_moves_file(void) {
    return moves[0] * 1000 + moves[1];
}

int main(void) {
    printf("%d %d %d\n", moves[0], moves[1], sum_moves_block());
    printf("%d\n", bump_moves(1));
    printf("%d %d\n", sum_moves_block(), sum_moves_file());
    bump_counter();
    printf("%d %d\n", read_scalar_block(), read_scalar_file());
    counter = 40;
    bump_counter();
    printf("%d %d\n", read_scalar_block(), read_scalar_file());
    return 0;
}
