/* Audit negative case: a field of a typedef'd anonymous struct whose C type
 * has no daScript representation must fail strict translation.  The typedef
 * path once built its fields with its own loop that skipped such a field, so
 * `Anon` came out as `{ a, b }`: daScript then put `b` at offset 4 while every
 * pointer access read it at Clang's offset 32.  Both natural-record paths now
 * share one field builder, which diagnoses the field instead. */

typedef struct {
    int a;
    long double x;
    int b;
} Anon;

int read_b(Anon *p) { return p->b; }
