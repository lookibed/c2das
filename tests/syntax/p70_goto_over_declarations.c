/* Audit acceptance: `goto` whose target sits at the very end of a function,
 * and jumps that cross local declarations.
 *
 * The shape that motivated this case comes from h264bsd's
 * h264bsdGetNeighbourPels: a void function that opens with `if (!n) return;`
 * and then runs several `if (x) { for (i = 21; i--;) *p++ = *q++; }` blocks.
 * Lowered to flat labels that becomes `goto <exit>` where `<exit>` is the last
 * label of the body with nothing but `return` under it — a label daScript
 * cannot jump to, because it folds that trailing `return` away and the label
 * is then left pointing past the end of the block.
 *
 * Returns 0 on success, or the number of the first failed check. */

/* --- 1. Early exit to a label at the very end of a void function. --------- */

/* `if (!n) return;` followed by copy loops driven by post-increment. */
static void neighbour_pels(unsigned char *above, unsigned char *left,
                           const unsigned char *src, unsigned n,
                           unsigned row, unsigned col) {
    unsigned i;
    const unsigned char *ptr;

    if (!n) return;

    ptr = src;
    if (row) {
        for (i = 21; i--;) *above++ = *ptr++;
    }
    if (col) {
        for (i = 13; i--;) *left++ = *ptr++;
    }
}

/* Every non-trivial path ends by jumping to a label that is the last thing in
 * the function, so the label carries only the implicit `return`. */
static void tail_label(int *out, int n) {
    if (n < 0) goto done;
    *out += 1;
    if (n == 0) goto done;
    *out += 10;
    if (n > 100) goto done;
    *out += 100;
done:
    return;
}

/* --- 2. Forward goto over several initialised declarations. --------------- */

static int skip_declarations(int take) {
    int total = 0;
    if (take) goto after;
    {
        int a = 1;
        int b = a + 1;
        int c = b + 1;
        int d = c + 1;
        total = a + b + c + d; /* 1+2+3+4 == 10 */
        goto out;
    }
after:
    /* Jumped over a, b, c, d above; they are out of scope here. */
    total = 7;
out:
    return total;
}

/* Forward goto that lands *after* declarations in the same block, so the
 * objects exist but were never initialised by their declarators. C gives them
 * storage for the whole block; the transpiler hoists them, so reading them
 * after the jump must see the assignment done below, not the declarator. */
static int jump_past_initialisers(int skip) {
    int r = 0;
    if (skip) goto land;
    {
        int p = 11;
        int q = 22;
        int s = 33;
        r = p + q + s; /* 66 */
        goto fin;
    }
land:
    r = 5;
fin:
    return r;
}

/* --- 3. Backward goto into a loop, and goto out of nested loops. ---------- */

static int backward_into_loop(int n) {
    int i = 0;
    int sum = 0;

    if (n <= 0) goto stop;

top:
    sum += i;
    i++;
    if (i < n) goto top;

stop:
    return sum;
}

static int escape_nested(int limit) {
    int i, j;
    int hits = 0;

    for (i = 0; i < 8; i++) {
        for (j = 0; j < 8; j++) {
            hits++;
            if (i * j >= limit) goto escaped;
        }
    }
    return -1;

escaped:
    return hits;
}

/* --- 4. Post-increment temporaries around labels. ------------------------- */

/* `while (n--)` and `*p++ = *q++` both need a temporary for the old value;
 * those temporaries are declared between labels in the lowered body. */
static unsigned copy_down(unsigned char *dst, const unsigned char *src,
                          unsigned n, int early) {
    unsigned moved = 0;

    if (early) goto finish;

    while (n--) {
        *dst++ = *src++;
        moved++;
    }

finish:
    return moved;
}

/* --- entry point --------------------------------------------------------- */

int goto_over_declarations_runtime(void) {
    unsigned char src[64];
    unsigned char above[64];
    unsigned char left[64];
    unsigned char dst[64];
    int out;
    unsigned i;

    for (i = 0; i < 64; i++) {
        src[i] = (unsigned char)(i + 1);
        above[i] = 0;
        left[i] = 0;
        dst[i] = 0;
    }

    /* 1. void function with an early return and copy loops. */
    neighbour_pels(above, left, src, 0u, 1u, 1u);
    if (above[0] != 0 || left[0] != 0) return 1; /* early return took effect */

    neighbour_pels(above, left, src, 3u, 1u, 1u);
    if (above[0] != 1 || above[20] != 21) return 2;
    if (left[0] != 22 || left[12] != 34) return 3;
    if (above[21] != 0 || left[13] != 0) return 4;

    for (i = 0; i < 64; i++) { above[i] = 0; left[i] = 0; }
    neighbour_pels(above, left, src, 3u, 0u, 1u);
    if (above[0] != 0) return 5;
    if (left[0] != 1 || left[12] != 13) return 6;

    /* 2. label at the very end, reached from several places. */
    out = 0; tail_label(&out, -1);  if (out != 0) return 7;
    out = 0; tail_label(&out, 0);   if (out != 1) return 8;
    out = 0; tail_label(&out, 50);  if (out != 111) return 9;
    out = 0; tail_label(&out, 500); if (out != 11) return 10;

    /* 3. forward goto over declarations. */
    if (skip_declarations(0) != 10) return 11;
    if (skip_declarations(1) != 7) return 12;
    if (jump_past_initialisers(0) != 66) return 13;
    if (jump_past_initialisers(1) != 5) return 14;

    /* 4. backward goto into a loop. */
    if (backward_into_loop(0) != 0) return 15;
    if (backward_into_loop(1) != 0) return 16;
    if (backward_into_loop(5) != 10) return 17;

    /* 5. goto out of nested loops. */
    if (escape_nested(0) != 1) return 18;
    if (escape_nested(4) != 13) return 19;
    if (escape_nested(1000) != -1) return 20;

    /* 6. post-increment temporaries declared between labels. */
    if (copy_down(dst, src, 6u, 1) != 0) return 21;
    if (dst[0] != 0) return 22;
    if (copy_down(dst, src, 6u, 0) != 6) return 23;
    if (dst[0] != 1 || dst[5] != 6 || dst[6] != 0) return 24;

    return 0;
}
