/* `--records typed` (docs/eden-flags.md flag 12) under `--memory-model
 * linear`: `struct node` (a list) and `struct tree` (a binary search tree)
 * qualify and are daslang `new T` objects reached through `T?`; `struct
 * cell` has a field whose address is taken (`&c->value`), so it stays in
 * the byte heap.  Covers malloc and calloc of one object, NULL, `==`/`!=`,
 * truthiness, a typed pointer field of a typed record, parameters, returns,
 * a global, and free. */
#include <stdio.h>
#include <stdlib.h>

struct node {
	int value;
	struct node *next;
};

struct tree {
	long long key;
	struct tree *left, *right;
};

struct cell {
	int value;
	struct cell *next;
};

static struct node *list_head;

static struct node *push(struct node *head, int value)
{
	struct node *n = (struct node *)malloc(sizeof(struct node));
	n->value = value;
	n->next = head;
	return n;
}

static struct tree *insert(struct tree *t, long long key)
{
	if (t == NULL) {
		struct tree *leaf = calloc(1, sizeof(struct tree));
		leaf->key = key;
		return leaf;
	}
	if (key < t->key)
		t->left = insert(t->left, key);
	else if (key > t->key)
		t->right = insert(t->right, key);
	return t;
}

static long long walk(const struct tree *t, int depth)
{
	if (!t)
		return 0;
	return walk(t->left, depth + 1) + t->key * depth + walk(t->right, depth + 1);
}

static void drop(struct tree *t)
{
	if (t != NULL) {
		drop(t->left);
		drop(t->right);
		free(t);
	}
}

static void bump(int *p)
{
	*p += 100;
}

int linear_records_typed(void)
{
	for (int i = 0; i < 10; i++)
		list_head = push(list_head, i * i);
	long long sum = 0;
	int count = 0;
	for (struct node *p = list_head; p; p = p->next) {
		sum += p->value;
		count++;
	}
	struct node *same = list_head;
	printf("list count=%d sum=%lld same=%d\n", count, sum, same == list_head);
	while (list_head != NULL) {
		struct node *next = list_head->next;
		free(list_head);
		list_head = next;
	}

	struct tree *root = NULL;
	long long seed = 12345;
	for (int i = 0; i < 200; i++) {
		seed = (seed * 1103515245 + 12345) % 2147483648LL;
		root = insert(root, seed % 1000);
	}
	printf("tree walk=%lld\n", walk(root, 1));
	drop(root);

	struct cell *cells = NULL;
	for (int i = 1; i <= 4; i++) {
		struct cell *c = malloc(sizeof(struct cell));
		c->value = i;
		bump(&c->value);
		c->next = cells;
		cells = c;
	}
	int total = 0;
	while (cells) {
		struct cell *next = cells->next;
		total += cells->value;
		free(cells);
		cells = next;
	}
	printf("cells=%d\n", total);
	return 0;
}
