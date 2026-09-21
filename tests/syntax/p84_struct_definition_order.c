/* Audit acceptance: records are declared before the records that embed them.
 *
 * daslang resolves a module-level `struct` name after the whole module is
 * parsed, so it takes the declarations in any order.  `daslang -aot` is a
 * fourth back end of the same text: it prints the module as C++, where a
 * member of a struct type needs that struct *complete*.  Its own emitter
 * sorts by-value members ahead of their container, but gives up as soon as
 * the embedded record also points back at the container — and the C++ then
 * fails to compile:
 *
 *     order_cycle.cpp:93:31: error: field has incomplete type 'struct Inner'
 *     order_cycle.cpp:96:15: error: static assertion failed due to requirement
 *                                   'sizeof(Outer) == 32'
 *
 * (Reported as https://github.com/lookibed/daScript/issues/2.)  The shape is
 * ordinary C: wasm3's `M3Module` embeds an `M3Memory` by value, and that
 * `M3Memory` carries an `M3Module *owner` back.  What made the translator
 * emit them the wrong way round is that its incoming declaration order is the
 * Clang export's, which is the order C *first names* a type — and a forward
 * `typedef struct Outer Outer;` names the container first.
 *
 * This case pins the three things that produce that order:
 *
 *   1. a forward `typedef` that names the container before either record is
 *      defined, plus a pointer alias built on it;
 *   2. a by-value member whose type also points back at the container, so a
 *      sorter that follows pointer edges too finds a cycle and gives up;
 *   3. a three-level chain, so one pass of "move the member ahead of its
 *      container" is not enough — `Leaf` has to precede `Middle`, which has
 *      to precede `Trunk`.
 *
 * The runtime check is ordinary reading and writing through those members;
 * the ordering property itself is asserted on the generated module by
 * `c2dascript-transpile/tests/record_order_tests.rs`.
 *
 * Returns 0 on success, or the number of the first failed check. */

/* 1. The container is named first, and a pointer alias is built on that name
 *    before either record has a definition. */
typedef struct Outer Outer;
typedef Outer *OuterRef;

typedef struct Inner {
	int a;
	int b;
	/* The back pointer: `Inner` needs `Outer` only as an incomplete type,
	 * which is what lets the two records reference each other at all. */
	Outer *owner;
} Inner;

struct Outer {
	OuterRef next;
	Inner embedded;
	int tag;
};

/* 3. Three levels, again named top-down before they are defined. */
typedef struct Trunk Trunk;
typedef struct Middle Middle;
typedef struct Leaf Leaf;

struct Leaf {
	int value;
	Middle *up;
};

struct Middle {
	Leaf leaf;
	Trunk *up;
	int weight;
};

struct Trunk {
	Middle middle;
	Trunk *self;
	int total;
};

/* An array of a record by value constrains the order the same way a plain
 * member does. */
struct Grove {
	Leaf leaves[3];
	int count;
};

static Outer g_outer;
static Trunk g_trunk;
static struct Grove g_grove;

int struct_definition_order_runtime(void) {
	int i;
	Inner local;
	struct Grove grove;

	/* 1. the container/embedded pair, including the cycle in both
	 *    directions. */
	g_outer.embedded.a = 3;
	g_outer.embedded.b = 4;
	g_outer.embedded.owner = &g_outer;
	g_outer.tag = 7;
	g_outer.next = 0;
	if (g_outer.embedded.a + g_outer.embedded.b + g_outer.tag != 14) return 1;
	if (g_outer.embedded.owner != &g_outer) return 2;
	if (g_outer.embedded.owner->tag != 7) return 3;
	if (g_outer.next != 0) return 4;

	/* A second object of the container type, linked to the first. */
	{
		Outer other;
		other.embedded.a = 10;
		other.embedded.b = 20;
		other.embedded.owner = &other;
		other.tag = 1;
		other.next = &g_outer;
		if (other.next->embedded.a != 3) return 5;
		if (other.next->embedded.owner->tag != 7) return 6;
		if (other.embedded.owner->embedded.b != 20) return 7;
	}

	/* The embedded record copied out by value. */
	local = g_outer.embedded;
	local.a = 100;
	if (local.a + local.b != 104) return 8;
	if (g_outer.embedded.a != 3) return 9;
	if (local.owner != &g_outer) return 10;

	/* 2. the three-level chain. */
	g_trunk.middle.leaf.value = 5;
	g_trunk.middle.leaf.up = &g_trunk.middle;
	g_trunk.middle.up = &g_trunk;
	g_trunk.middle.weight = 11;
	g_trunk.self = &g_trunk;
	g_trunk.total = g_trunk.middle.leaf.value + g_trunk.middle.weight;
	if (g_trunk.total != 16) return 11;
	if (g_trunk.middle.leaf.up->weight != 11) return 12;
	if (g_trunk.middle.up->total != 16) return 13;
	if (g_trunk.self->middle.leaf.value != 5) return 14;

	/* 3. an array of a record by value, at file scope and at block scope. */
	for (i = 0; i < 3; i++) {
		g_grove.leaves[i].value = i * 2;
		g_grove.leaves[i].up = 0;
	}
	g_grove.count = 3;
	if (g_grove.leaves[0].value != 0) return 15;
	if (g_grove.leaves[2].value != 4) return 16;
	if (g_grove.count != 3) return 17;

	grove.count = 0;
	for (i = 0; i < 3; i++) {
		grove.leaves[i].value = i + 1;
		grove.leaves[i].up = &g_trunk.middle;
		grove.count = grove.count + grove.leaves[i].value;
	}
	if (grove.count != 6) return 18;
	if (grove.leaves[1].up->weight != 11) return 19;

	return 0;
}
