/* Audit negative case: a statement attribute the translator does not model is
 * a source-located TranslationError, never a panic.
 *
 * `musttail` and `fallthrough` are the two the translation understands and
 * drops (see `p74-musttail-return`); everything else has to reach the user as
 * a diagnostic naming the attribute and the line it sits on. */

extern int compute(void);

int unknown_statement_attribute(void) {
    __attribute__((nomerge)) return compute();
}
