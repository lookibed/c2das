/* Audit acceptance: a call through a function-pointer *expression*.
 *
 * daScript calls a `function<…>` value only through `invoke(f, args…)`.  The
 * translator already routed a callee that was a local variable through that
 * operator, but a callee that was an expression — a cast, a conditional, the
 * value a dereference yields — came out as a call by juxtaposition, which
 * daScript cannot parse:
 *
 *     return unsafe(reinterpret<Op>(*pc_0))(unsafe(pc_0 + int(1)), acc_0)
 *                                          ^ error[30151]: syntax error
 *
 * The shape that motivated this case is wasm3's whole opcode dispatch,
 * `m3_exec_defs.h`:
 *
 *     #define nextOpImpl() ((IM3Operation)(*_pc))(_pc + 1, d_m3OpArgs)
 *
 * which is the single hottest construct an interpreter has and appeared at
 * 491 sites in one translation unit.  Every vtable, jump table and dispatch
 * loop in C has the same shape, so what has to hold is that *how* the callee
 * expression is spelled never decides whether the call is emitted at all: a
 * variable, a cast, a dereference, a struct field, an array element and a
 * conditional all name a function value, and all of them are called.
 *
 * Returns 0 on success, or the number of the first failed check. */

/* --- a threaded-code interpreter, dispatching through a cast -------------- */

/* Each op reads its successor out of the program counter and calls it.  The
 * callee is `(Op)(*pc)`: an explicit cast of a loaded `const void *`, with no
 * local to park it in. */
typedef int (*Op)(const void **pc, int acc);

static int op_add(const void **pc, int acc) {
	acc = acc + 1;
	return ((Op)(*pc))(pc + 1, acc);
}

static int op_double(const void **pc, int acc) {
	acc = acc * 2;
	return ((Op)(*pc))(pc + 1, acc);
}

static int op_negate(const void **pc, int acc) {
	acc = -acc;
	return ((Op)(*pc))(pc + 1, acc);
}

static int op_halt(const void **pc, int acc) {
	(void)pc;
	return acc;
}

/* The same dispatch with the callee parked in a local first: this form always
 * worked, and it must keep giving the same answer. */
static int step_through_variable(const void **pc, int acc) {
	Op op = (Op)(*pc);
	return op(pc + 1, acc);
}

/* --- the other callee expressions ---------------------------------------- */

typedef int (*Unary)(int);

struct Table {
	Unary fn;
	Unary others[2];
};

static int inc(int x) { return x + 1; }
static int dbl(int x) { return x * 2; }
static int sqr(int x) { return x * x; }

/* A struct field, reached by value and through a pointer. */
static int via_field(struct Table t, int x) { return t.fn(x); }
static int via_arrow(struct Table *t, int x) { return t->fn(x); }

/* An array element, both a bare array and a struct member array. */
static int via_element(Unary *table, int i, int x) { return table[i](x); }
static int via_member_element(struct Table *t, int i, int x) { return t->others[i](x); }

/* A conditional: neither arm is an lvalue, so nothing can be peeled off it. */
static int via_ternary(int flag, int x) { return (flag ? inc : dbl)(x); }

/* The same conditional in a function the relooper has to break into blocks.
 * A branch forces the conditional's temporary out of its expression and into
 * the declaration prologue, where a hoisted declaration needs the *type's*
 * default value: a daScript `function<…>` is a named type expression, not a
 * constructible record, so `function<…>()` is a syntax error and
 * `default<function<…>>` is the null function value. */
static int via_hoisted_ternary(int flag, int x) {
	Unary chosen;
	if (x < 0) {
		return -1;
	}
	chosen = flag ? sqr : inc;
	return chosen(x);
}

static int via_hoisted_ternary_call(int flag, int x) {
	if (x < 0) {
		return -1;
	}
	return (flag ? sqr : inc)(x);
}

/* A dereference of a pointer to a function pointer, and the double
 * dereference C also accepts on a function designator. */
static int via_deref(Unary *slot, int x) { return (*slot)(x); }
static int via_double_deref(Unary *slot, int x) { return (**slot)(x); }

/* A cast that changes nothing but the spelling. */
static int via_cast(Unary f, int x) { return ((Unary)f)(x); }

/* The callee expression may have a side effect, which C evaluates exactly
 * once, before the arguments. */
static int g_selects;

static Unary pick(Unary *table, int i) {
	g_selects = g_selects + 1;
	return table[i];
}

/* --- entry point --------------------------------------------------------- */

int indirect_call_expression_runtime(void) {
	const void *program[5];
	const void *single[2];
	struct Table t;
	Unary table[3];
	Unary slot;

	table[0] = inc;
	table[1] = dbl;
	table[2] = sqr;

	t.fn = sqr;
	t.others[0] = inc;
	t.others[1] = dbl;

	/* 1. the threaded interpreter: ((5 + 1) * 2) + 1 = 13, then negated. */
	program[0] = (const void *)op_add;
	program[1] = (const void *)op_double;
	program[2] = (const void *)op_add;
	program[3] = (const void *)op_negate;
	program[4] = (const void *)op_halt;
	if (((Op)(program[0]))(program + 1, 5) != -13) return 1;

	/* 2. one op, reached both ways, has to agree. */
	single[0] = (const void *)op_double;
	single[1] = (const void *)op_halt;
	if (((Op)(single[0]))(single + 1, 21) != 42) return 2;
	if (step_through_variable(single, 21) != 42) return 3;

	/* 3. an empty program halts immediately. */
	single[0] = (const void *)op_halt;
	if (((Op)(single[0]))(single + 1, 7) != 7) return 4;

	/* 4. a struct field. */
	if (via_field(t, 9) != 81) return 5;
	if (via_arrow(&t, 4) != 16) return 6;

	/* 5. an array element. */
	if (via_element(table, 0, 10) != 11) return 7;
	if (via_element(table, 1, 10) != 20) return 8;
	if (via_element(table, 2, 10) != 100) return 9;
	if (via_member_element(&t, 0, 6) != 7) return 10;
	if (via_member_element(&t, 1, 6) != 12) return 11;

	/* 6. a conditional, inline and hoisted out of a branching body. */
	if (via_ternary(1, 8) != 9) return 12;
	if (via_ternary(0, 8) != 16) return 13;
	if (via_hoisted_ternary(1, 6) != 36) return 20;
	if (via_hoisted_ternary(0, 6) != 7) return 21;
	if (via_hoisted_ternary(1, -1) != -1) return 22;
	if (via_hoisted_ternary_call(1, 6) != 36) return 23;
	if (via_hoisted_ternary_call(0, 6) != 7) return 24;
	if (via_hoisted_ternary_call(0, -2) != -1) return 25;

	/* 7. a dereference and a double dereference. */
	slot = sqr;
	if (via_deref(&slot, 5) != 25) return 14;
	if (via_double_deref(&slot, 5) != 25) return 15;

	/* 8. a cast that changes nothing. */
	if (via_cast(inc, 41) != 42) return 16;

	/* 9. the callee expression itself runs exactly once. */
	g_selects = 0;
	if (pick(table, 1)(20) != 40) return 17;
	if (g_selects != 1) return 18;

	/* 10. inside a loop, which is where a dispatch table lives. */
	{
		int i;
		int total = 0;
		for (i = 0; i < 3; i++) {
			total = total + table[i](3);
		}
		if (total != 4 + 6 + 9) return 19;
	}

	return 0;
}
