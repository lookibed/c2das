/* A pointer argument that already has the parameter's type crosses as itself;
 * a decayed const table, a converted pointer and an address reinterpreted to
 * another pointer type still convert. */
typedef struct {
    int count;
    int total;
} counter_t;

typedef struct {
    short index;
    short value;
} entry_t;

static const entry_t TABLE[3] = {{1, 10}, {2, 20}, {-1, 30}};

static int counter_has(counter_t *self, int n) { return self->count >= n; }

static int table_value(const entry_t *table, int i) { return table[i].value; }

static int first_byte(const unsigned char *bytes) { return bytes[0]; }

static int counter_step(counter_t *self, void *opaque) {
    int word = 0x01020304;
    int got = 0;
    if (counter_has(self, 1)) {
        got += table_value(TABLE, 1);
    }
    got += first_byte((const unsigned char *)&word);
    got += opaque != 0;
    self->total += got;
    return self->total;
}

int pointer_arg_same_type_runtime(void) {
    counter_t c = {1, 0};
    return counter_step(&c, &c) == 25 ? 0 : 1;
}
