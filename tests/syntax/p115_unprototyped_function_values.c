/* Functions declared without a prototype (`void act();`) stored into a
 * `void (*)()` slot, the way Doom's `info.c` builds its `states[]` table of
 * `A_*` actions.  C types the designator by the unprototyped declaration in
 * scope, whose pointer type is compatible with the definition's and needs no
 * conversion (C11 6.7.6.3p15); the program later calls the slot through a
 * pointer of the callee's real type (6.5.2.2p6, 6.3.2.3p8).  daScript
 * function types are not compatible that way, so the stored value is
 * reinterpreted to the slot's type and back again at the call. */

typedef void (*action_v)();
typedef void (*action_p1)(int *);
typedef void (*action_p2)(int *, int);

struct state {
    int tics;
    action_v action;
};

union action_u {
    action_v acv;
    action_p1 acp1;
};

struct thinker {
    int id;
    union action_u function;
};

static int hits;

void bump();
void add();
void none();

/* Initializers name the unprototyped declarations; the definitions follow. */
static struct state states[] = {
    {1, bump},
    {2, add},
    {3, none},
    {4, 0},
};

static struct thinker thinkers[] = {
    {10, {bump}},
    {20, {0}},
};

void bump(int *value) {
    *value += 1;
    hits++;
}

void add(int *value, int amount) {
    *value += amount;
    hits++;
}

void none(void) { hits += 100; }

static int check(int got, int want) { return got == want ? 0 : 1; }

int unprototyped_function_values_runtime(void) {
    int failures = 0;
    int v = 5;
    ((action_p1) states[0].action)(&v);
    failures += check(v, 6);
    ((action_p2) states[1].action)(&v, 10);
    failures += check(v, 16);
    ((void (*)(void)) states[2].action)();
    failures += check(hits, 102);
    failures += check(states[3].action == 0, 1);
    failures += check(states[0].action != states[1].action, 1);

    /* A slot assigned at run time from an unprototyped designator. */
    action_v slot = add;
    ((action_p2) slot)(&v, 4);
    failures += check(v, 20);

    /* The union member, read back through the other member. */
    thinkers[0].function.acp1(&v);
    failures += check(v, 21);
    failures += check(thinkers[1].function.acv == 0, 1);
    failures += check(hits, 104);
    return failures;
}
