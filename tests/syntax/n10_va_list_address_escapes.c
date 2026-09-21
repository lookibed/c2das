/* Audit negative case: the address of a `va_list` object may not outlive the
 * frame the object lives in.
 *
 * The canonical variadic ABI models a `va_list` as a `C2daVaCursor` record and
 * hands it to a callee as the `var` parameter it is declared to be, i.e. by
 * reference (see `p87-va-list-shared-cursor`).  daScript has no way to keep
 * such a reference alive past the call, so a `va_list` address that is *stored*
 * — into a global, a struct field, the heap, or returned — is a dangling
 * reference the model cannot represent.  It used to be accepted silently, and
 * rendered a four-byte cursor reinterpreted as a pointer to a 24-byte
 * `struct __va_list_tag`.  It is now a source-located `TranslationError`.
 *
 * This is a lifetime check, not an address-taken check: `&ap` handed *directly*
 * to a callee — musl's `printf_core(…, va_list *ap, …)`, picolibc's struct
 * wrapper — names storage that is alive for the whole call and is the one
 * forwarding shape C99 7.15.1p1 itself exempts, so it is not what this case
 * rejects.  (A `va_list *` parameter is diagnosed on its own, where the callee
 * dereferences it, as "unsupported va_arg cursor".)
 *
 * The program below is undefined in C too — the argument area dies with the
 * variadic frame — which is exactly why it must fail closed instead of
 * rendering. */

#include <stdarg.h>

static va_list *g_saved;

static int stash(va_list ap) {
	g_saved = &ap;
	return va_arg(ap, int);
}

int va_list_address_escapes(int n, ...) {
	va_list ap;
	int first;
	va_start(ap, n);
	first = stash(ap);
	va_end(ap);
	return first;
}
