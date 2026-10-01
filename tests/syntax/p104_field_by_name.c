/* Pointer field access by name.  A record whose daslang layout is proven equal
 * to Clang's (a complete struct that is not storage-backed) has its scalar and
 * pointer fields read and written as `p.field` through the typed record
 * pointer, and the module carries the compile-time proof.  Every line below
 * reads through one spelling what the other wrote (by-value struct copies,
 * memcpy of the bytes, raw `unsigned char` views at Clang's offsets), so a
 * field path that named the wrong daslang field, or a layout that disagreed
 * with Clang's, prints a different value. */
#include <stddef.h>
#include <stdio.h>
#include <string.h>

struct Inner {
    short tag;
    double weight;
};

struct Node {
    char kind;
    int count;
    struct Inner inner;
    struct Node *next;
    const char *label;
    unsigned long long big;
    _Bool flag;
};

/* A typedef of an anonymous struct is a natural record too. */
typedef struct {
    unsigned char lo;
    unsigned int hi;
    struct Node *owner;
} Pair;

static int calls = 0;

static struct Node *pick(struct Node *n) {
    calls++;
    return n;
}

/* Loads and stores of scalar and pointer fields, one level and nested. */
static void fill(struct Node *n, struct Node *next) {
    n->kind = 'k';
    n->count = 40;
    n->inner.tag = -3;
    n->inner.weight = 2.5;
    n->next = next;
    n->label = "node";
    n->big = 0x123456789abcdefULL;
    n->flag = 1;
}

/* A `const S *` base: a pointer field is copied out as a plain pointer. */
static const char *label_of(const struct Node *n) { return n->label; }

static struct Node *next_of(const struct Node *n) { return n->next; }

static double weight_of(const struct Node *n) { return n->inner.weight; }

/* Read-modify-write through a base produced by a call: the call runs once. */
static void bump(struct Node *n) {
    pick(n)->count += 2;
    pick(n)->inner.tag++;
    pick(n)->big <<= 4;
}

/* A chain of `->` through records accessed by name. */
static int second_count(struct Node *n) { return n->next->count; }

static unsigned sum_pair(Pair *p) { return p->lo + p->hi + (unsigned)p->owner->count; }

int main(void) {
    struct Node b = {0};
    struct Node a;
    memset(&a, 0, sizeof a);
    b.count = 7;
    fill(&a, &b);
    printf("kind=%c count=%d tag=%d weight=%.1f label=%s flag=%d\n", a.kind, a.count,
           a.inner.tag, a.inner.weight, a.label, a.flag);
    printf("const label=%s next=%d weight=%.2f\n", label_of(&a), next_of(&a)->count,
           weight_of(&a));
    bump(&a);
    printf("bump count=%d tag=%d big=%llx calls=%d\n", a.count, a.inner.tag, a.big, calls);
    printf("chain=%d\n", second_count(&a));

    /* The bytes at Clang's offsets are what the named stores wrote. */
    unsigned char raw[sizeof(struct Node)];
    memcpy(raw, &a, sizeof a);
    int count;
    memcpy(&count, raw + offsetof(struct Node, count), sizeof count);
    short tag;
    memcpy(&tag, raw + offsetof(struct Node, inner) + offsetof(struct Inner, tag), sizeof tag);
    printf("raw count=%d tag=%d kind=%c\n", count, tag, raw[offsetof(struct Node, kind)]);

    /* A by-value copy of the object reads what the pointer stores wrote. */
    struct Node copy = a;
    printf("copy count=%d weight=%.1f next=%d\n", copy.count, copy.inner.weight, copy.next->count);

    Pair pair = {0};
    Pair *pp = &pair;
    pp->lo = 200;
    pp->hi = 1000;
    pp->owner = &a;
    printf("pair=%u lo=%u\n", sum_pair(pp), pair.lo);
    printf("sizes %zu %zu %zu\n", sizeof(struct Inner), sizeof(struct Node), sizeof(Pair));
    return 0;
}
