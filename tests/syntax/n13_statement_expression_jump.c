/* A `continue` inside a GNU statement expression: the expression translator
 * lowers the statements without knowing the loop it belongs to (it would skip
 * the `for` step), so the translation is refused with the jump's location. */
int sum_nonzero(const int *a, int n) {
    int s = 0;
    for (int i = 0; i < n; i++) {
        int x = ({
            if (a[i] == 0)
                continue;
            a[i];
        });
        s += x;
    }
    return s;
}
