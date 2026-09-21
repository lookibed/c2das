/* Audit acceptance: two mutually recursive file-scope tables of function
 * pointers, over typedef'd function types with `const`-qualified parameters.
 *
 * This is the shape of wasm3's interpreter: `c_operations`, a table of
 * `@@op_*`, and `c_compilers`, a table of `@@Compile_*`, where the operations
 * reach the compilers and the compilers reach the operations.  Three separate
 * translator facts have to hold before such a pair can exist at all.
 *
 * 1. **Typedef order.**  A daScript `typedef` whose body names a *later*
 *    typedef resolves to a type that is structurally right but no longer
 *    compares equal to the same alias written the other way round:
 *
 *        error[30915]: can't initialize field ops;
 *          function<(var a:uint8? const?;…):uint8?> aka Fn[2]
 *        = function<(var a:pc_t -const;…):ret_t> aka Fn[2] — not the same type
 *
 *    C already requires a typedef to be declared before it is used, so the
 *    aliases are emitted in dependency order rather than in the Clang
 *    export's own order.
 *
 * 2. **A `const`-qualified parameter.**  C11 6.7.6.3p15 takes a parameter "as
 *    having the unqualified version of its declared type": the qualifier is
 *    no part of the function type.  Clang records it on the defining
 *    declaration and, inconsistently, on some function types — so a
 *    `const u8 *const` parameter came out as `cbytes_t const` in the
 *    definition and as plain `cbytes_t` in the callback typedef the
 *    definition implements, and neither could be assigned to the other.
 *
 * 3. **An initialization cycle through `@@`.**  daScript follows a function's
 *    address into its body and on to the globals that body reads, so two
 *    tables that reach each other are one cycle
 *    (`error[31104]: global variable initialization loop`).  C has no such
 *    rule — a file-scope initializer is a link-time constant — so one of the
 *    two is written by an `[init]` function instead, which runs after all
 *    module-level storage exists.
 *
 * Returns 0 on success, or the number of the first failed check. */

/* --- typedefs in an order the C compiler accepts and a translator may not -- */

typedef unsigned char u8;
typedef const u8 *cbytes_t;
typedef u8 *bytes_t;
typedef int (*Op)(cbytes_t pc, int acc);
typedef int (*Compiler)(bytes_t out, int value);

/* --- the two tables, each reached from the other's bodies ---------------- */

extern const Op c_operations[4];
extern const Compiler c_compilers[3];

/* An operation that reaches the compiler table. */
static int op_compile(cbytes_t pc, int acc) {
	u8 scratch[2];
	scratch[0] = 0;
	scratch[1] = 0;
	/* `pc[0]` selects which compiler runs. */
	return c_compilers[pc[0] % 3](scratch, acc) + scratch[0];
}

static int op_add(cbytes_t pc, int acc) {
	return acc + (int)pc[0];
}

static int op_double(cbytes_t pc, int acc) {
	(void)pc;
	return acc * 2;
}

static int op_halt(cbytes_t pc, int acc) {
	(void)pc;
	return acc;
}

/* A compiler that reaches the operation table, closing the cycle. */
static int compile_run(bytes_t out, int value) {
	/* Not `const`: daScript types the address of a `const` object as a
	 * *const pointer*, which `invoke` refuses to pass to a `var` pointer
	 * parameter ("pointer types can only add constness"), while a direct
	 * call of the same function accepts it.  That is a daScript constness
	 * rule about `addr`, not a fact about function types, and it is not what
	 * this case pins. */
	static u8 program[1] = {5};
	out[0] = 1;
	return c_operations[1](program, value);
}

static int compile_zero(bytes_t out, int value) {
	out[0] = 2;
	(void)value;
	return 0;
}

static int compile_negate(bytes_t out, int value) {
	out[0] = 3;
	return -value;
}

const Op c_operations[4] = {op_compile, op_add, op_double, op_halt};
const Compiler c_compilers[3] = {compile_run, compile_zero, compile_negate};

/* A `const`-qualified pointer parameter, whose top-level `const` C drops from
 * the function type: the definition still has to implement the typedef. */
typedef int (*Reader)(const u8 *const data, int index);

static int read_at(const u8 *const data, int index) {
	return (int)data[index];
}

static const Reader readers[1] = {read_at};

int dispatch_table_cycle_runtime(void) {
	static u8 bytes[4] = {10, 20, 30, 40};
	u8 out[2];
	int i;

	/* 1. each table entry, called through its table. */
	if (c_operations[1](bytes, 5) != 15) return 1;
	if (c_operations[2](bytes, 21) != 42) return 2;
	if (c_operations[3](bytes, 7) != 7) return 3;

	/* 2. the cycle in both directions: op_compile picks a compiler by the
	 *    byte at `pc`, and compile_run runs op_add over its own program. */
	out[0] = 0;
	out[1] = 0;
	if (c_compilers[0](out, 6) != 11) return 4;   /* op_add(5, 6) */
	if (out[0] != 1) return 5;
	if (c_compilers[1](out, 6) != 0) return 6;
	if (out[0] != 2) return 7;
	if (c_compilers[2](out, 6) != -6) return 8;
	if (out[0] != 3) return 9;

	/* bytes[0] is 10, 10 % 3 == 1, so compile_zero runs and writes 2. */
	if (c_operations[0](bytes, 6) != 2) return 10;
	/* bytes[1] is 20, 20 % 3 == 2, so compile_negate runs and writes 3. */
	if (c_operations[0](bytes + 1, 6) != -3) return 11;
	/* bytes[2] is 30, 30 % 3 == 0, so compile_run runs op_add(5, 6) and
	 * writes 1. */
	if (c_operations[0](bytes + 2, 6) != 12) return 12;

	/* 3. the `const`-qualified parameter through its own typedef. */
	if (readers[0](bytes, 0) != 10) return 13;
	if (readers[0](bytes, 3) != 40) return 14;
	if (read_at(bytes, 2) != 30) return 15;

	/* 4. the whole table walked in a loop. */
	{
		int total = 0;
		for (i = 1; i < 4; i++) {
			total += c_operations[i](bytes, 2);
		}
		if (total != 12 + 4 + 2) return 16;
	}

	return 0;
}
