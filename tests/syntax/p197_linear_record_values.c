/* `--memory-model linear`: whole record and array values through pointers.
 *
 * A struct read through a pointer (`s = *p`, `return p[i]`, an argument
 * `f(*p)`) is copied out of the heap field by field at Clang's offsets; a
 * struct assigned through a pointer (`*p = s`) is copied in the same way;
 * heap to heap (`*p = *q`, `a->in = b->in`) is one byte copy.  Records hold
 * nested structs, arrays, pointers and floating values; an array field of a
 * record value is indexed as a daScript array.  (A record with bitfields is
 * refused: bitfields of a record value are not lowered under the model.)
 * The same program compiled by clang and translated with the flag must both
 * return 0, or the number of the first failed check. */
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

struct inner {
	short s;
	double d;
};

struct rec {
	char c;
	struct inner in;
	int arr[3];
	int64_t big;
	struct rec *next;
	float f;
};

struct triple {
	char c;
	int arr[3];
};

/* (A by-value parameter of a record with a pointer field is still
 * raw-memory lowered under the model, so the parameters here hold none.) */
static int sum(struct triple t, struct inner in)
{
	return t.c + in.s + t.arr[0] + t.arr[1] + t.arr[2];
}

static struct rec nth(struct rec *v, int i)
{
	return v[i];
}

int linear_record_values(void)
{
	struct rec *v = calloc(3, sizeof(struct rec));
	if (!v) return 100;
	struct rec local;
	local.c = -5;
	local.in.s = -300;
	local.in.d = 2.5;
	local.arr[0] = 1;
	local.arr[1] = -2;
	local.arr[2] = 70000;
	local.big = -9000000000ll;
	local.next = &v[1];
	local.f = 0.75f;

	v[0] = local; /* daScript value into the heap */
	if (v[0].c != -5 || v[0].in.s != -300 || v[0].in.d != 2.5) return 1;
	if (v[0].arr[2] != 70000 || v[0].big != -9000000000ll) return 2;
	if (v[0].next != &v[1] || v[0].f != 0.75f) return 3;

	v[1] = v[0]; /* heap to heap */
	v[1].arr[1] = 9;
	if (v[1].arr[1] != 9 || v[0].arr[1] != -2 || v[1].in.d != 2.5) return 5;

	struct rec back = v[1]; /* heap into a daScript value */
	if (back.c != -5 || back.arr[1] != 9 || back.next != &v[1] || back.f != 0.75f) return 6;
	back.arr[2] += 5;
	if (back.arr[2] != 70005 || v[1].arr[2] != 70000) return 7;
	struct triple *t = malloc(sizeof *t);
	if (!t) return 100;
	t->c = -5;
	t->arr[0] = 1;
	t->arr[1] = -2;
	t->arr[2] = 70000;
	if (sum(*t, v[0].in) != -5 - 300 + 1 - 2 + 70000) return 8;
	free(t);
	struct rec got = nth(v, 1);
	if (got.arr[1] != 9) return 9;

	v[2].in = v[0].in; /* a nested struct, heap to heap */
	if (v[2].in.s != -300 || v[2].c != 0) return 10;
	struct inner in = { 7, -1.25 };
	struct rec *p = &v[2];
	p->in = in;
	if (v[2].in.d != -1.25 || v[2].in.s != 7) return 11;
	in.s = 0;
	in = p->in;
	if (in.s != 7) return 12;
	struct rec copy = (v[2] = v[0]); /* the value of a heap assignment */
	if (copy.big != -9000000000ll || v[2].big != -9000000000ll) return 13;
	free(v);
	return 0;
}
