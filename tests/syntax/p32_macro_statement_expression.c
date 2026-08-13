#define MARK_ONCE(x) ({ (x) = (x) + 1; 0; })

int macro_statement_expression_runtime(void) {
    int value = 3;
    MARK_ONCE(value);
    return value != 4;
}
