/* A file-scope object whose initializer takes the address of its own
 * elements, as Doom's `S_sfx` table links a sound to another entry of the same
 * table (`sounds.c`, `SOUND_LINK`).  `&table[i]` is an address constant
 * (C11 6.6p9) and the program sees the finished object before `main`.
 * daScript refuses a module-level `var` whose initializer names itself, so the
 * object is written by the module's `[init]` function instead, together with
 * the objects whose initializers depend on it. */

#include <stddef.h>

typedef struct sfx_s {
    const char *name;
    struct sfx_s *link;
    int pitch;
} sfx_t;

static sfx_t sounds[] = {
    {"none", NULL, 0},
    {"pistol", NULL, 64},
    {"shotgn", &sounds[1], 32},
    {"sgcock", &sounds[2], 16},
};

struct node {
    struct node *next;
    int value;
};

/* A one-element ring: the object points at itself. */
static struct node ring = {&ring, 7};

/* Depends on the self-referencing table. */
static sfx_t *loudest = &sounds[1];

/* A dispatch table whose entry reads the table: daslang follows `@@op_self`
 * into its body and finds the table again. */
static int op_self(int k);
static int (*ops[])(int) = {op_self};
static int op_self(int k) { return ops[0] == op_self ? k + 1 : -1; }

static int check(int got, int want) { return got == want ? 0 : 1; }

int self_referencing_initializer_runtime(void) {
    int failures = 0;
    failures += check(sounds[0].link == NULL, 1);
    failures += check(sounds[2].link == &sounds[1], 1);
    failures += check(sounds[3].link->link->pitch, 64);
    failures += check(sounds[3].link->link->name[1], 'i');
    failures += check(ring.next == &ring, 1);
    failures += check(ring.next->next->value, 7);
    failures += check(loudest->pitch, 64);
    loudest->pitch = 80;
    failures += check(sounds[2].link->pitch, 80);
    failures += check(ops[0](41), 42);
    return failures;
}
