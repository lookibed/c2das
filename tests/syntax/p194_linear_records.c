/* `--memory-model linear`: records through pointers, arrays of records in
 * the heap, a linked list, string literals in the static block, and the
 * byte functions and allocator over the heap.
 *
 * A record reached through a pointer lives in the heap: `p->f` is the
 * pointer plus Clang's field offset.  A string literal whose address is
 * taken is placed in the heap when the module starts.  The same program
 * compiled by clang and translated with the flag must both return 0, or the
 * number of the first failed check. */
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

struct point {
	short x;
	double y;
	unsigned char tag;
};

struct node {
	int value;
	struct node *next;
};

struct inner {
	int a;
	float b;
};

struct outer {
	char c;
	struct inner in;
	int64_t big;
};

static int records(void)
{
	struct point *pts = calloc(4, sizeof(struct point));
	if (!pts) return 100;
	if (pts[3].x != 0 || pts[3].y != 0.0) return 1;
	for (int i = 0; i < 4; i++) {
		pts[i].x = (short)(i - 2);
		pts[i].y = i * 0.25;
		pts[i].tag = (unsigned char)(200 + i);
	}
	struct point *p = &pts[2];
	if (p->x != 0 || p->y != 0.5 || p->tag != 202) return 2;
	p++;
	if (p->x != 1 || (*p).tag != 203) return 3;
	p->y += 1.5;
	if (pts[3].y != 2.25) return 4;
	if ((char *)&pts[1] - (char *)pts != (long)sizeof(struct point)) return 5;

	struct outer *o = malloc(sizeof *o);
	if (!o) return 100;
	o->c = -3;
	o->in.a = -77;
	o->in.b = 0.125f;
	o->big = -5000000000ll;
	struct inner *ip = &o->in;
	if (ip->a != -77 || ip->b != 0.125f || o->c != -3 || o->big != -5000000000ll) return 6;
	free(o);
	free(pts);
	return 0;
}

static int list(void)
{
	struct node *head = NULL;
	for (int i = 1; i <= 10; i++) {
		struct node *n = malloc(sizeof(struct node));
		if (!n) return 100;
		n->value = i * 3;
		n->next = head;
		head = n;
	}
	int sum = 0, count = 0;
	for (struct node *n = head; n; n = n->next) {
		sum += n->value;
		count++;
	}
	if (sum != 165 || count != 10) return 20;
	/* remove the odd values */
	struct node *prev = NULL, *cur = head;
	while (cur) {
		struct node *next = cur->next;
		if (cur->value & 1) {
			if (prev) prev->next = next; else head = next;
			free(cur);
		} else {
			prev = cur;
		}
		cur = next;
	}
	sum = 0;
	while (head) {
		struct node *next = head->next;
		sum += head->value;
		free(head);
		head = next;
	}
	if (sum != 90) return 21;
	return 0;
}

static int strings(void)
{
	const char *hello = "hello, world";
	if (strlen(hello) != 12) return 40;
	if (hello[7] != 'w' || hello[12] != 0) return 41;
	const char *again = "hello, world";
	if (memcmp(hello, again, 13) != 0) return 42;
	char *buf = malloc(32);
	if (!buf) return 100;
	memset(buf, 'x', 31);
	buf[31] = 0;
	if (strlen(buf) != 31) return 43;
	memcpy(buf, hello, 6);
	buf[6] = 0;
	if (strlen(buf) != 6 || memcmp(buf, "hello,", 7) != 0) return 44;
	if (memcmp(buf, "hellp", 5) >= 0) return 45;
	memmove(buf + 1, buf, 6); /* overlapping */
	if (memcmp(buf, "hhello,", 7) != 0) return 46;
	unsigned sum = 0;
	for (const char *s = "abc"; *s; s++)
		sum = sum * 31 + (unsigned char)*s;
	if (sum != 96354) return 47;
	free(buf);
	return 0;
}

static int allocator(void)
{
	int *a = malloc(4 * sizeof(int));
	if (!a) return 100;
	for (int i = 0; i < 4; i++) a[i] = i + 1;
	a = realloc(a, 1000 * sizeof(int));
	if (!a) return 60;
	if (a[0] != 1 || a[3] != 4) return 61;
	a[999] = -1;
	int *b = malloc(16);
	if (!b || b == a) return 62;
	free(b);
	int *c = malloc(16);
	if (!c || c == a) return 63;
	free(c);
	free(a);
	free(NULL);
	/* more than any heap holds: C NULL, not a trap */
	volatile size_t too_big = (size_t)-1;
	void *huge = malloc(too_big);
	if (huge) {
		free(huge);
		return 64;
	}
	return 0;
}

int linear_records(void)
{
	int r;
	if ((r = records())) return r;
	if ((r = list())) return r;
	if ((r = strings())) return r;
	return allocator();
}
