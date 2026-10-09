/* `--memory-model linear`: a record with pointer fields passed by value.
 *
 * binjgb's joypad buffer walks its chunks with an iterator record passed and
 * returned by value whose fields point into the heap: the callee's copy is a
 * plain record copy (pointer fields are offsets), `++iter.state` steps the
 * copy's field, `(void)p` discards a pointer, and `setvbuf(stdout, NULL,
 * _IONBF, 0)` turns buffering off.  The same program compiled by clang and
 * translated with the flag must print the same text and return 0, or the
 * number of the first failed check. */
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct Chunk {
	struct Chunk *next;
	size_t size;
	int data[3];
} Chunk;

typedef struct {
	Chunk *chunk;
	int *state;
} Iter;

static Iter next_state(Iter iter)
{
	size_t index = iter.state - iter.chunk->data;
	if (index + 1 < iter.chunk->size) {
		++iter.state;
		return iter;
	}
	iter.chunk = iter.chunk->next;
	iter.state = iter.chunk && iter.chunk->size != 0 ? iter.chunk->data : NULL;
	return iter;
}

static void ignore(void *user_data)
{
	(void)user_data;
}

int linear_record_iterators(void)
{
	setvbuf(stdout, NULL, _IONBF, 0);
	Chunk *a = calloc(1, sizeof(Chunk));
	Chunk *b = calloc(1, sizeof(Chunk));
	a->next = b;
	a->size = 2;
	a->data[0] = 10;
	a->data[1] = 11;
	b->size = 1;
	b->data[0] = 20;
	Iter it = {a, a->data};
	int sum = 0;
	int steps = 0;
	while (it.state) {
		sum = sum * 100 + *it.state;
		it = next_state(it);
		steps++;
	}
	ignore(a);
	printf("steps=%d sum=%d\n", steps, sum);
	if (steps != 3 || sum != 101120) return 1;
	if (it.chunk != NULL) return 2;
	free(a);
	free(b);
	return 0;
}
