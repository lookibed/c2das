/* Audit acceptance: a typedef'd callback whose parameters are a record
 * pointer and an untyped `void *` user pointer.  The C function type, the
 * definitions that implement it, the struct field that stores it and the
 * indirect call must all agree on one daScript spelling: `void *` is one
 * pointer type, and a parameter's mutability is part of the function type.
 * Returns 0 on success, otherwise the index of the failed check. */

typedef struct sink sink_t;

typedef void (*sink_callback)(sink_t *self, void *user);

struct sink {
    sink_callback on_data;
    void *user;
    int total;
    int calls;
};

struct payload {
    int value;
    int seen;
};

/* Definition matching the typedef: a `void *` parameter converted back to a
 * typed pointer, which is what the callback contract is for. */
static void accumulate(sink_t *self, void *user) {
    struct payload *p = (struct payload *)user;
    self->total += p->value;
    self->calls += 1;
    p->seen += 1;
}

static void negate(sink_t *self, void *user) {
    struct payload *p = (struct payload *)user;
    self->total -= p->value;
    self->calls += 1;
    p->seen += 1;
}

/* Takes the callback as a parameter of the typedef'd type and stores it. */
static void sink_set_callback(sink_t *self, sink_callback fp, void *user) {
    self->on_data = fp;
    self->user = user;
}

/* Calls through the struct field with a record pointer and a `void *`. */
static void sink_fire(sink_t *self) {
    self->on_data(self, self->user);
}

int callback_typedef_runtime(void) {
    struct sink s;
    struct payload p;
    sink_callback direct;

    s.on_data = 0;
    s.user = 0;
    s.total = 0;
    s.calls = 0;
    p.value = 7;
    p.seen = 0;

    if (s.on_data != 0) return 1;

    /* `&p` is a local whose address travels through `void *` and comes back
     * as `struct payload *` inside the callback. */
    sink_set_callback(&s, accumulate, &p);
    if (s.on_data == 0) return 2;

    sink_fire(&s);
    if (s.total != 7) return 3;
    if (s.calls != 1) return 4;
    if (p.seen != 1) return 5;

    sink_fire(&s);
    if (s.total != 14) return 6;
    if (s.calls != 2) return 7;
    if (p.seen != 2) return 8;

    sink_set_callback(&s, negate, &p);
    sink_fire(&s);
    if (s.total != 7) return 9;
    if (s.calls != 3) return 10;
    if (p.seen != 3) return 11;

    /* The same value copied into a local of the typedef'd type and invoked
     * directly, then stored back into the field. */
    direct = s.on_data;
    direct(&s, &p);
    if (s.total != 0) return 12;
    if (s.calls != 4) return 13;
    if (p.seen != 4) return 14;

    direct = accumulate;
    s.on_data = direct;
    sink_fire(&s);
    if (s.total != 7) return 15;
    if (s.calls != 5) return 16;
    if (p.seen != 5) return 17;

    /* The stored user pointer must still be the address of `p`. */
    if ((struct payload *)s.user != &p) return 18;

    return 0;
}
