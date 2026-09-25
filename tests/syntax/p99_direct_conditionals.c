/* C `?:`, `&&`, `||` and `!` as daslang expressions.  An operand that is one
 * expression (a comparison, a call, a pointer test) is lowered to daslang's own
 * short-circuit `&&`/`||` and `c ? a : b`, which evaluate operands exactly as C
 * does; an operand that needs statements of its own (`i++`, an assignment)
 * keeps the guarded lowering.  Every call below appends to a trace, so an arm
 * or right operand evaluated when C would skip it, or in another order, changes
 * the trace and the result. */

static int trace[32];
static int trace_len;

static int note(int id, int value) {
    trace[trace_len++] = id;
    return value;
}

static int *pick(int id, int *p) {
    trace[trace_len++] = id;
    return p;
}

static int check_trace(const int *want, int n) {
    int i;
    if (trace_len != n) {
        return 1;
    }
    for (i = 0; i < n; i++) {
        if (trace[i] != want[i]) {
            return 1;
        }
    }
    trace_len = 0;
    return 0;
}

static int check(long long got, long long want) {
    return got == want ? 0 : 1;
}

/* The int value of `&&`/`||` stored and summed: C's 0/1. */
static int logical_values(int a, int b) {
    int both = a && b;
    int either = a || b;
    int neither = !(a || b);
    int not_less = !(a < b);
    return both * 1000 + either * 100 + neither * 10 + not_less + (a < b) + (a == b);
}

/* Pointer arms whose C conversion to the result type is a qualification or an
 * array decay: the lowering writes no conversion for either, so the daslang
 * arm is not yet of the result's type and the temporary stays. */
static const char *name_or_default(const char *name, char *spare) {
    return name ? name : spare ? spare : "unnamed";
}

/* `?:` with arms of different C types: the result type is the usual
 * arithmetic conversion of the two, applied to the chosen arm only. */
static int mixed_arms(int sel) {
    int failures = 0;
    int negative = -1;
    unsigned int big = 4000000000u;
    double half = 0.5;
    unsigned int as_unsigned = sel ? negative : big;
    long long widened = sel ? negative : 7ll;
    double real = sel ? half : negative;
    failures += check(as_unsigned, sel ? 4294967295ll : 4000000000ll);
    failures += check(widened, sel ? -1 : 7);
    failures += check((long long)(real * 4), sel ? 2 : -4);
    /* unsigned compare after conversion: -1 becomes UINT_MAX */
    failures += check((sel ? negative : 0u) > 5u, sel ? 1 : 0);
    return failures;
}

int direct_conditionals_runtime(void) {
    int failures = 0;
    int x = 3;
    int y = 5;
    int i = 0;
    int value;
    int cell = 9;
    int *p = &cell;
    int *null_p = 0;

    /* Calls in both arms: only the chosen one runs. */
    value = x < y ? note(1, 10) : note(2, 20);
    failures += check(value, 10);
    {
        static const int want[] = {1};
        failures += check_trace(want, 1);
    }
    value = x > y ? note(1, 10) : note(2, 20);
    failures += check(value, 20);
    {
        static const int want[] = {2};
        failures += check_trace(want, 1);
    }

    /* Short-circuit with calls: the right operand runs only when needed. */
    value = note(3, 0) && note(4, 1);
    failures += check(value, 0);
    value = note(5, 1) || note(6, 1);
    failures += check(value, 1);
    value = note(7, 2) && note(8, 3);
    failures += check(value, 1);
    {
        static const int want[] = {3, 5, 7, 8};
        failures += check_trace(want, 4);
    }

    /* A right operand with a side effect that needs a statement. */
    value = x > y && i++;
    failures += check(value, 0);
    failures += check(i, 0);
    value = x < y && i++;
    failures += check(value, 0);
    failures += check(i, 1);
    value = x < y || i++;
    failures += check(i, 1);
    value = x > y || (i += 2);
    failures += check(value, 1);
    failures += check(i, 3);
    value = i++ && note(9, 1);
    failures += check(value, 1);
    failures += check(i, 4);
    {
        static const int want[] = {9};
        failures += check_trace(want, 1);
    }

    /* An arm with a side effect that needs a statement. */
    value = x < y ? (i = 40) : (i = 50);
    failures += check(value, 40);
    failures += check(i, 40);
    value = x > y ? i++ : note(10, i);
    failures += check(value, 40);
    failures += check(i, 40);
    {
        static const int want[] = {10};
        failures += check_trace(want, 1);
    }

    /* Nested mixes, as values and as conditions. */
    value = (x < y && y < 10) ? (x == 3 || note(11, 0) ? 7 : 8) : note(12, 9);
    failures += check(value, 7);
    if ((x > y || note(13, 1)) && !(x == y) && (p ? *p == 9 : 0)) {
        value = 1;
    } else {
        value = 2;
    }
    failures += check(value, 1);
    while (x < y && note(14, 1)) {
        x++;
    }
    failures += check(x, 5);
    {
        static const int want[] = {13, 14, 14};
        failures += check_trace(want, 3);
    }
    x = 3;

    /* Pointer operands: tested against null, selected by `?:`. */
    value = p && *p == 9;
    failures += check(value, 1);
    value = null_p && *null_p == 9;
    failures += check(value, 0);
    value = !null_p || *null_p;
    failures += check(value, 1);
    value = *(null_p ? null_p : p);
    failures += check(value, 9);
    value = *(x < y ? pick(15, p) : pick(16, null_p));
    failures += check(value, 9);
    {
        static const int want[] = {15};
        failures += check_trace(want, 1);
    }

    failures += check(logical_values(3, 5), 1000 + 100 + 0 + 0 + 1 + 0);
    failures += check(logical_values(0, 0), 0 + 0 + 10 + 1 + 0 + 1);
    failures += check(logical_values(2, 2), 1000 + 100 + 0 + 1 + 0 + 1);
    {
        char spare[2] = {'s', 0};
        failures += check(name_or_default("given", spare)[0], 'g');
        failures += check(name_or_default(0, spare)[0], 's');
        failures += check(name_or_default(0, 0)[0], 'u');
    }
    failures += mixed_arms(1);
    failures += mixed_arms(0);
    return failures;
}
