# Translator ownership contract

The translator produces daScript AST, not repaired text.  C rvalues, C places, and raw addresses
must stay explicit in API names and result types.

| Owner | Charter |
|---|---|
| `abi.rs` | raw address ↔ typed pointer/null and storage-byte ABI conversions |
| `layout.rs` | canonical Clang-backed size, alignment, record offsets and diagnostics |
| `runtime.rs` | the complete `c2da_rt_*` declaration registry and raw-memory calls |
| `libc.rs` | the `--libc std` replacement table: `c2da_std_*` helpers, the standard streams, the `errno` cell and numbering, the std `FILE`'s own state, and the `main` entry wrapper |
| `object_memory.rs` | raw object addresses, field addresses, aligned/misaligned load/store |
| `functions.rs` | C call classification and ABI-facing argument/result lowering |
| `operators.rs` | typed C operators, including shifts and numeric coercion |
| `value_lowering.rs` | expected-type values and statement-producing coercions |
| CFG owners | C control-flow reconstruction, declaration dominance and exits |
| printer | daScript AST rendering only; no C semantic repair |

Clang facts are canonical for C layout.  Unsupported aggregate-by-value, foreign ABI,
volatile/atomic, callback, inline-asm/SIMD, and unfinished bitfield corners must produce a
source-located `TranslationError`, never an identity or daScript-value fallback.

Clang facts are canonical for the *target* too, not only for layout.  `errno`'s numbering is a
target fact next to `StdLayout`'s pointer width: it is read off the exported triple
(`TypedAstContext::target`), one numbering is implemented (Linux `asm-generic`), and a `std`
helper that would have to write a code for a target with no numbering is refused with a
source-located diagnostic rather than given another target's integers.  A `std` helper that
carries C library *text* — `strerror`'s catalogue — ships that text as one named implementation's
(glibc's), spelled out in this module, never derived.

Where a `std` entry point cannot be both exact and hosted on daslib, its behaviour is a
documented choice ISO C or POSIX permits, never an approximation.  `system` is a hosted
implementation without a command processor (C11 7.22.4.8): `system(NULL)` is 0 and any
command runs nothing and returns -1 with `ENOSYS`.  `mkdir` never touches the file system
(daslib's `mkdir` ignores the mode and reports no `errno`): it returns -1 with `EPERM`.
`fabs` clears the sign bit, so `-0.0` and NaN come out exact (the non-std builtin
`c2da_fabs_double` in `builtins.rs` is `x < 0 ? -x : x`, which keeps `-0.0`).  `sscanf`
implements C11 7.21.6.2 for white-space directives, ordinary bytes, `%%` and `%d %i %o %u
%x %X` without width, `*` or length modifier, reading the integer subject as glibc does
(`0x` consumed for `%x`/`%i` even with no digit after it, the value `strtol`/`strtoul`'s,
saturated with `ERANGE`, stored as its low 32 bits).  Every other directive fails closed: a
literal format is a source-located translation error (`unsupported_scan_conversion`), a
computed one panics in the helper.  `p110-std-string-extras`, `p111-std-sscanf` and
`p112-std-sscanf-unsupported` are the fixtures.

## Natural records and storage-backed records

A C struct is emitted as a daScript struct with its fields only when `layout.rs`
(`is_storage_backed_record`) finds daScript's layout of those fields equal to Clang's;
otherwise it is a storage-backed wrapper owning Clang's bytes, and every field is a Clang
offset.  A zero-sized field (GNU empty struct, zero-length array, or an array of either) makes
the record storage-backed: Clang gives it no bytes, daScript gives every record field at least
one, so every later offset would differ.  An empty struct on its own is 0 bytes in both and
stays a daScript struct.  Natural record fields have one builder
(`structs_unions.rs natural_record_fields`), shared by `convert_struct` and the
typedef-of-anonymous-struct path; a field whose type does not convert is a source-located
error, never a dropped field.  `p103-zero-sized-fields` and
`n12-typedef-record-field-unsupported` are the fixtures.

## Storage-backed objects: one wrapper, one block, one identity

A storage-backed wrapper is named once, by its record (`storage_record_name`), and every C
declaration that reaches the record — the record itself, its `typedef`, a `typedef` of that
`typedef` — lowers to the same `DaStructure`; module assembly emits one declaration per
daScript type name (`claim_type_declaration`).  `p130-typedef-storage-records`.

The object's address is its storage: a C pointer to a storage-backed record is the byte
address typed `T?`, never the address of a wrapper.  Everything follows from keeping that one
address valid and C's layout around it:

- **Zero value.**  A file-scope object of such a type, or an array of them, is declared with
  its zeroed storage (C11 6.7.9p10); daslang refuses the bare declaration (`error[31014]`).
- **Contiguous arrays.**  An array (of arrays) of storage-backed records is one zeroed block
  of Clang's size, each wrapper naming its slice (`structs_unions.rs contiguous_record_array`,
  helpers `c2da_records_<T>_<dims>(base)`), whether it is a global, a static or a hoisted local.
  The array decays to its first element's byte address; a subscript of the array names the
  element wrapper (`object_memory.rs is_wrapper_array_decay`, `wrapper_array_base`), while a
  subscript of a pointer or of an array *field* of a record — bytes inside that record — is a
  Clang offset.  A decay of any other array of storage-backed records is refused.
- **Pointer arithmetic** on such a pointer runs on the raw address, scaled by Clang's object
  size, not the wrapper's eight bytes: `p ± n`, `p - q`, `++p`, `p += n`
  (`abi.rs storage_pointee_size`, `storage_pointer_offset`, `storage_pointer_distance`).
- **No replacement.**  `s = t` and `a[i] = t` copy t's bytes into s's storage; a block-scope
  declaration's initializer copies into the object the hoisted declaration already holds, each
  time control passes it, with no allocation per pass; a file-scope array with an initializer
  is declared over its block and its `[init]` copies the initializer's bytes in
  (`storage_in_place_copy`).  A hoisted storage-backed local still allocates its storage once
  per function activation and never releases it (`c2da_rt_frame_enter`/`leave` exist in the
  runtime but are not used yet).

`p131-storage-record-arrays` and `p132-storage-object-identity` are the fixtures.

## Values: the lvalue conversion, pointers to integers, integers to enumerations

- Reading a natural record object drops the place's qualifiers (C11 6.3.2.1p2).  daslang keeps
  the place's `const` on every field of a copy and refuses `T? const` into `T?`, so a record
  with a pointer member read from a `const` place, or from a read-only record parameter, is read
  through its address converted to the unqualified record (`abi.rs unqualified_record_value`,
  `structs_unions.rs record_lvalue_conversion`); daslang compiles the `reinterpret` to nothing.
  `p133-const-record-copy`.
- A pointer converted to an integer narrower than `uint64` is the raw address converted
  (`abi.rs pointer_to_integer`): an eight-byte `reinterpret` into `int` is not a conversion,
  and daslang's LLVM back end rejects it (`trunc ptr`).
- An integer converted to a pointer or a function pointer is first widened to the 64-bit
  address the way GCC and Clang do — sign-extended from a signed type, zero-extended from an
  unsigned one — and only then reinterpreted (`abi.rs integer_to_raw_address`, used by both
  cast paths of `mod.rs`).  Clang's `IntegralToPointer` takes an `int` directly, and a
  `reinterpret` of four bytes into an eight-byte pointer or function value reads four bytes C
  never defined: the interpreter and the LLVM JIT read different ones, and Doom's "removed
  thinker" mark `(actionf_v)(-1)` equalled the null function under `-jit`.  A pointer ↔ integer
  or bit cast translates its operand with no expected type, in the explicit-cast path as in the
  implicit one; told to expect the cast's type, a call converted its own pointer result
  (`(uintptr_t)f()` became `uint64(f())`).  `p141-integer-to-pointer-width`.
- A read of an enumeration constant is its value, the typed literal of `enums.rs
  enum_constant_literal` (C11 6.4.4.3: an integer constant, not an object).  The module still
  names every constant, as a `let` of the same type and value (`DaVariable::is_let`), for a
  hand-written daScript caller; no translated body reads those names.  A module global — a
  `var`, and a `let` too wherever daslang does not fold it (the right-hand side of `=`, a store
  through a pointer) — is a load from the context's global data that, under `-jit`, LLVM cannot
  keep across a store through a translated C pointer: binjgb's `TRUE`/`FALSE` flags, loop bounds
  and `switch` states were reloaded on every iteration (binjgb `-jit` 1.37× → 1.03× C
  `-O3 -march=native`).  `p170-enum-constant-literals`.
- An integer converted to a daslang `enum` is converted to the enumeration's integer type first
  and then re-read as the `enum` (`enums.rs value_to_enum`): a `reinterpret<E>` of a `uint8`
  reads bytes C never defined.  `p134-pointer-integer-enum-conversions`.

## Field access by name under a layout proof

`is_storage_backed_record` models daScript's layout from Clang's field facts; daslang checks
that model.  Every complete natural struct the module declares registers, from both builders,
`static_assert(typeinfo sizeof/alignof(type<S>) == ..)` and one
`static_assert(typeinfo offsetof<f>(type<S>) == ..)` per field with Clang's numbers
(`layout.rs register_layout_proof`).  daslang has no module-scope `static_assert`, but it infers
every function, an uncalled private one included, so `mod.rs` emits them once as the body of
`c2da_layout_proofs` after every owner has contributed (`take_layout_proof_declaration`).  A
mismatch stops `daslang`, `-jit`, `-exe` and `-aot` at compile time; the assertions compile to
nothing, and daslang's AOT C++ in turn asserts daslang's layout against the C++ compiler's.

On that proof, a C pointer field access whose leaf is a scalar or pointer and whose every record
on the path is proven (`record_has_proven_layout`) is spelled `p.field` / `p.inner.field`
(`object_memory.rs`: `CObjectAddress::named`, extended by `field_address`, spelled only by
`named_field_lvalue`, which notes each record; assembly refuses a noted record without a proof).
A read-modify-write binds the typed `S?` base once (`materialize_address`).  A `const S *` base
is reinterpreted once to `S?` (`abi.rs named_field_base_type` / `named_field_base`): daslang
makes a field read through `S const?` const, and `T? const` does not copy into `T?`; the
reinterpret compiles to its operand.  A null base raises daslang's located exception in the
interpreter (the indexed load faulted) and is unchanged elsewhere; `unsafe_deref` drops the
check as it drops the index check.  What stays on byte offsets: addresses of fields (`&p->f`),
fixed-array fields (`p->arr[i]` — daslang bounds-checks a fixed-array index and C indexes past
field arrays; a separate decision), whole-record and whole-array copies, bitfields, unions and
every storage-backed record.  `p104-field-by-name`, `p105-field-by-offset-kept` and the source
invariant `named_field_access_requires_a_layout_proof` are the fixtures.

## Bitfield storage units

A bitfield is loaded and stored through one object of its declared type (`layout.rs
bitfield_unit`): the object aligned to that type's size that holds the field, when the field
lies wholly inside it and it lies wholly inside the record — the storage unit the System V ABI
allocates a bitfield of a non-packed record in.  `object_memory.rs` reads it with one aligned
typed load, extracts the field from its bit offset in the unit, and a store is a
read-modify-write of the unit that keeps every other bit.  Only a field of a packed record that
straddles that object keeps the former place, the object of the declared type starting at the
byte with the field's first bit, read and written byte-wise; that object can reach past the
record's last byte (as before).  The former place for every bitfield read `struct color`'s `r`
(bits 16..23) as four bytes from byte 2, through a misaligned copy and past the record's end.
`p151-bitfield-storage-units` is the fixture.  (`unsigned short` and `_Bool` bitfields produce
storage-type arithmetic daslang rejects, before and after this rule — an open gap.)

## Module-wide policy

Facts that hold for the whole output rather than for one lowering — the `options` header and
the per-function `unsafe_deref` policy — are applied once where `mod.rs` assembles `DaModule`,
after every owner has contributed its declarations.  Nothing else may push them: the
`c2da_rt_*` registry, the `--libc std` prelude and the generated global initializers are
functions of this module too, and a per-owner push silently omits whichever builder is added
next.  The order of the header is fixed (`gen2`, `solid_context`, then the caller's
`--das-option` lines) so a given command line always writes the same header.

`options solid_context = true` is the translator's default, not a caller option: the emitted
module declares all of its own globals and never has another module splice more in, so baking
their offsets is always correct for what this translator writes.  `unsafe_deref` is opt-in
(`--unsafe-deref`) because it is a *policy* trade, not a correctness one: a C null dereference
is undefined behaviour, so dropping the check is faithful, but the program then faults instead
of raising daslang's located exception.

Constant numeric conversions are folded once there too (`das_ast::fold`, called from `mod.rs`
after every owner has contributed): owners keep building the conversion C asks for — a C `8`
reaching a `size_t` use-site is `uint64(int(8))` in the AST — and the module pass replaces a
conversion of an integer constant by the constant of the target type that daScript's own
conversion (`static_cast`, modulo 2^width) produces, a conversion to the type its operand
already has by that operand, and `-c` by a negative constant where it cannot overflow.  The
result is a *typed integer literal* (`Cast` of an in-range constant), which the printer spells
as `2`, `8u`, `8l`, `8ul`, `8u8`, or `int16(4464)` for the three types without a literal; the
constant's variant carries only the spelling (`ConstUInt`: a C hex/octal constant, printed in
hex once unsigned).  What stays a conversion: anything whose operand is not a constant or a
same-type conversion, real → integer (truncation), integer → real that rounds, and targets
that are aliases or qualified.  `p97-constant-conversions` is the runtime fixture.

The pass runs over the whole module (`fold_module_conversions`), so it also drops a
conversion of a *non-constant* operand whose daScript type provably is the target: a local,
parameter or global of that declared type, a load `p[i]`/`*p` through a `T?`, a field of a
module structure, a call of a function the module declares once whose arguments are exactly
its parameter types, a conversion or `reinterpret` to `T`, and `+ - * / %`, bitwise and
shift operators on two operands of one `int`/`uint`/`int64`/`uint64` (daScript demands the
same type on both sides and defines none of them on the storage types).  The type is read off
the daScript AST, never off C: a C comparison is `int`, its daScript value `bool`.
`T(U(x))` with `U` holding every value of `x`'s integer type is `T(x)`, and
`c ? T(a) : T(b)` with `a`, `b` of one type is `T(c ? a : b)`.  Anything the rule cannot type
— an unknown name, a builtin or overloaded call, a `null` argument, a `for` variable — keeps
its conversion.  `p100-redundant-conversions` is the runtime fixture.

The same pass writes an assignment statement `a = a op b` as daslang's `a op= b`
(`fold.rs compound_assignment`) when the operation is daslang's own `+ - * / % & | ^ << >>` on
one builtin `int`/`uint`/`int64`/`uint64` (or `float`/`double` for the arithmetic operators) —
the operator typing rule above — the two `a` are the same expression, and `a` and `b` contain
no call and no assignment, so evaluating `a` once instead of twice reads and writes the same
memory.  C's `x += y`, `x++` and the runtime's loop counters reach it as `x = x + y`; the
interpreter runs `x += y` as one node (a loop updating eight variables measured 29.8 → 18.9 ns
per iteration; `-jit` is identical).  A narrow storage type (`uint8(int(b) + 1)`), a call in the
value and the place on the right keep the assignment.  A typed pointer stepped by an `int` or
`int64`, `p = unsafe(p + n)` (C's `p++`, `p += n`), is `unsafe { p += n }` under the same
conditions — daslang's pointer `+=` moves by the same `n` elements, and the call-shaped
`unsafe(…)` takes no assignment (Doom's column and span loops: 32.0 → 28.6 ns per pixel in a
probe).  `p153-compound-assignment-spelling` is the fixture.  The one
non-constant elision made in a lowering is where the type is known by construction: a compound assignment or
`++`/`--` computes in the promoted C type `CArith` (`promote_operand`), so storing it back to an
object whose storage is that same daScript type writes no conversion
(`abi::narrow_arith_to_storage`).

The printer renders a declaration's annotations as one bracketed, comma-separated block
(`[export, unsafe_deref]`).  daScript's grammar accepts exactly one block per declaration;
two consecutive `[...]` lines are a syntax error.

## One `unsafe` per node

daslang's call-shaped `unsafe(expr)` is shallow: it marks only the root node of `expr`
(`ds2_parser.ypp` sets `alwaysSafe` on the subexpression; `InferTypes::safeExpression`
reads only that flag or an enclosing `unsafe { }` block).  So every node that needs it —
a `reinterpret`, a pointer index, pointer arithmetic, `addr` — carries its own wrapper,
and `unsafe(reinterpret<T?>(unsafe(reinterpret<uint64>(p)))[k])` is the minimal form of a
field load, not a nesting to collapse.  What is removed is only what marks nothing:

- the AST holds each `reinterpret` as `DaExpr::reinterpret` (`unsafe` included) and the
  printer adds none of its own; `DaExpr::unsafe_of` never wraps an `unsafe(...)` again;
- `reinterpret<T?>(addr(x))` is built as daslang's `addr<T?>(x)` — the parser's own
  desugaring of that sugar, whose one `unsafe` covers the generated `addr`;
- `*p` and a pointer `==`/`!=` get no wrapper (daslang's deref is checked and needs none);
- a call argument whose C type (below the casts lowered to nothing) converts to exactly the
  parameter's daScript type gets no `reinterpret` (`abi.rs abi_pointer_cast_from`); an
  array decay is not trusted, because `addr(a[0])` of a `const` array is a `const` value
  that only the `reinterpret` lets reach a `var` pointer parameter.

## Conditions and C's 0/1

C types a comparison, `&&`, `||` and `!` as `int`; daslang types them `bool` and has no
`int(bool)`.  Two rules keep the translation direct:

- **A condition takes the `bool`.**  `convert_condition` recognises these operators
  (`c_boolean_operator`, through parentheses) and uses the operator's own `bool` for an `if`,
  a loop, the selector of `?:`, an operand of `&&`/`||`/`!` or a `_Bool` conversion; C's 0/1
  is never built only to be tested against 0 again.
- **A value gets C's 0/1 once, in place**: `b ? 1 : 0` in the use-site's type
  (`abi::materialize_bool_as_number` / `bool_to_integer_cast`, whose statement list is now
  always empty).

- **A `_Bool` converted to an integer only to be tested is tested as itself**
  (`convert_condition`, `bool_operand_of_integer_conversion`): `b && x` is `b && x`, never
  `(b == true ? 1 : 0) != 0`.  **An integer literal condition is a `bool` constant**
  (`integer_constant_condition`): `return 0` from a `_Bool` function is `return false`;
  through an integer conversion only 0 and 1 qualify (a narrowing can turn another literal into
  zero).  The flat label back end takes the one edge of a constant branch (`while (1)`,
  `do … while (0)`) without a test, and emits no jump after a block that already returned.
  `p122-bool-conditions` is the fixture.

`&&`/`||` lower to daslang's short-circuit operators and `?:` to daslang's `c ? a : b` when
the right operand (or both arms) is one expression — daslang evaluates it only when C would,
calls included.  An operand that had to hoist statements (`i++`, an assignment, a copy)
keeps the guarded lowering: `&&`/`||` an `int` flag set inside `if (lhs)`, `?:` a temporary
assigned in each arm's block, so the statements run only when C evaluates that operand.
The expression `?:` is limited to arithmetic results and to pointer results whose arms are
provably of the result's daslang type (`conditional_pointer_arm_is_exact`: a qualification
or decay the lowering spells as nothing would give the arms two types, which daslang's `?:`
rejects while an assignment accepts it); records, arrays and function values keep the
temporary.  GNU `a ?: b` keeps its temporary (it names `a` once).  `p99-direct-conditionals`
is the runtime fixture.  The former `a < b ? a : b` → `c2da_min_*`/`c2da_max_*` rewrite and
its helpers are gone: it was unreachable while conditions were flags, and it guessed `int`
for operands of unknown daslang type.

## Compound assignment on an enumeration

C11 6.5.16.2 makes `E1 op= E2` the operation `E1 op (E2)` after the usual arithmetic
conversions, and `++`/`--` are `+= 1`/`-= 1`.  A daslang `enum` accepts no arithmetic operator,
so an enum-typed object is read as a numeric conversion to the computation type and the result
is narrowed to the enumeration's compatible integer type and re-read as the `enum`
(`enums.rs object_value_as_arith` / `arith_result_to_object`, used by every compound-assignment
and increment path in `operators.rs`, plain and address-backed).  `p120-enum-compound-assignment`
is the fixture.

## Switch dispatch

A `switch` terminator of the flat label back end (`cfg/labels.rs DispatchTree`) is shaped for
the daslang interpreter, which pays one node per comparison:

- a range of at least five cases with at most twice as many values as cases is a **jump table**:
  one bounds test and daslang's computed `goto <int expr>`, whose operand is the scrutinee's
  offset into a run of consecutive label numbers placed on the arms (holes on the default
  arm) after the named labels;
- at most four cases are an `if`/`elif` chain of equality tests;
- anything else is split at its median value (`if x < pivot`), O(log n) comparisons.

None nests deeper than log n, so daslang's AOT (which prints each `elif` as a nested
`else { if … }`) stays inside clang's bracket-nesting limit of 256 for any `switch`.  Case
values are read back as the constants `CfgBuilder` built (the C case constant converted to the
promoted scrutinee type); anything else is an error, not a fallback.  A jump-table alias left
above nothing but a void function's closing `return` cannot be jumped to (see
`dead_tail_labels`) and a computed jump cannot be rewritten to `return`, so such arms are
re-rendered onto a `return` trampoline at the top of the body.  Measured in the interpreter on a
256-case byte switch: 4× faster than the linear chain (the median split alone: 3×).
`p121-switch-dispatch` is the fixture; computed `goto` is `DaExpr::GotoComputed`.

## Early exits and the interpreter's label tables

daslang's optimizer (`CondFolding::visit(ExprBlock*)`, `src/ast/ast_block_folding.cpp`)
rewrites `if (c) { … return } rest` — an `if` without `else` whose arm is a block ending in
`return`/`break`/`continue` — into `if (c) { … return } else { rest }`, and `rest` keeps its
labels.  The interpreter gives every block with labels its own label table covering only its
own statements (`sv_simulateLabels`, `src/ast/ast_simulate.cpp`), so a jump across the `if`
breaks once `rest` holds a label: a jump from `rest` to a label above the `if` (a loop head)
raises `jump to label N failed` (`SimNode_BlockWithLabels::eval`, `src/simulate/simulate.cpp`),
and a jump from above the `if` to a label in `rest`, when nothing above has a label, leaves the
function silently.  The JIT, AOT and `-exe` run the same folded tree correctly, and so does the
interpreter under `options optimize = false`.  daslang issue:
[lookibed/daScript#8](https://github.com/lookibed/daScript/issues/8).

The flat back end produces exactly that shape when `dead_tail_labels` rewrites a jump to the
function's end into `return` inside an `if` (Doom's `Z_CheckHeap`: `break` out of an endless
`for` that is also the end of the void function, with the error reports' back edges below).
`move_crossed_early_exits` (`cfg/labels.rs`), run after that repair, rewrites each such `if`
that some jump crosses with labels below it into `if (c) { goto label X }`, which the folding
leaves alone, and moves the arm's statements verbatim behind `label X:` into a slot nothing
falls into: after a top-level `goto`/`return` and before the next label — or, when the body has
no such slot, onto a skipped prologue at its top (`goto label R; label X: …; label R:`).  The
taken exit costs one `goto` more; the untaken path is the same `if`, now without the nested
`else` block.  An exit no jump crosses (Doom's `R_DrawColumn`: nothing above it jumps or is
jumped to) stays `if (c) { return }`.  `p140-early-exit-jump-targets` is the fixture.

## Local declarations

The flat `label`/`goto` back end (`cfg/labels.rs`) hoists every C local and every site
temporary to the top of the function: C gives a block-scope object storage for the whole
block however control enters it, and daslang's AOT prints each `var` as an initialised C++
declaration (`int32_t x = 0;`, `das_zero(x)`), past which C++ forbids a forward `goto`.  The C
initializer is an assignment at the C declaration point, so it runs every time control passes
it (a loop body re-initialises).

The hoisted `var` is bare when daslang's zero-fill of `var x : T` is the value the translator
would otherwise spell out (`Translation::declaration_zero_fills` on the C type,
`da_type_zero_fills` on a temporary's daScript type): numbers, `bool`, pointers, function
values, aliases of them, and plain structs and fixed arrays of those.  daslang documents and
performs this zero-fill in every run mode.  A C local without an initializer is indeterminate,
so the zero is daslang's, not a store the program relies on.  Explicit values stay where
zero-fill differs or is refused: a storage-backed record wrapper (its field initializer
allocates the bytes; daslang rejects a bare `var` of a struct with field initializers), a
daslang `enum` (daslang does not zero-fill an enumeration with no zero member), a VLA's
`array<T>`.
When the body's first statement stores the last hoisted declaration, and the value does not
name it, the value moves into the declaration.  `p102-local-declarations` is the fixture.

daslang's interpreter initialises every hoisted `var` on each call (one node per variable,
3–4 ns), so hoisted *site temporaries* whose lives cannot overlap share one variable
(`cfg/labels.rs coalesce_site_temporaries`): a temporary whose run of top-level statements opens
with the store its site declaration left, has no label after that store up to its last use (so
control enters it only at its start), and is never under an `addr`, takes over the variable of
an earlier temporary of the same type whose run has ended.  Each temporary is read only after its
own store, so the values read are the same.  binjgb's `execute_instruction` (a 3500-line opcode
`switch` called per emulated instruction) went from 155 hoisted variables to 25, and the
interpreted emulator 25 % faster; C declarations are not coalesced (their C scopes are not tracked
here).  `p154-coalesced-temporaries` is the fixture.  (A hoisted temporary of an enumeration with
no zero member is declared `E()`, which daslang rejects — `error[30305]` — before and after this
rule: an open gap.)

A postfix `x++` / `x--` whose value is discarded — an expression statement, a `for` step, an
operand of a statement-level comma — is lowered as the prefix operator
(`cfg/mod.rs convert_expr_in_stmt_position`): C reads the old value nowhere, and copying it into
a `c2da_postinc` temporary cost the interpreter one dead store per execution (11 % of
pl_mpeg's executed statements).  Only the statement-level expression itself qualifies; a
postfix operator inside a larger expression keeps the copy.  `p152-discarded-postfix-increments`
is the fixture.

A block-scope *function* declaration (`void later(void);` inside a body) produces no statement:
it declares the file-scope function (C11 6.2.2p4–5).  When it is the function's first
declaration it is Clang's canonical declaration, which the exporter gives the body and the
definition's source range, while the file-scope definition arrives as a `NonCanonicalDecl`;
the C AST import (`c_ast/conversion.rs`) puts the canonical declaration in the top-level
list in that redeclaration's place, so the function is emitted once, at module scope.
`p113-block-scope-function-decl` is the fixture.

## Arguments, function designators and self-referencing globals

- A call argument is always lowered as a used value (`functions.rs convert_function_call`),
  whatever the call's own context: `show(x -= 8)` hoists the store and passes `x`.  Lowered
  in a call statement's unused context the argument was a bare daScript assignment.
  `p114-assignment-arguments`.
- A decayed function designator is `@@f` of the type of `f`'s defining declaration.  C types
  the designator by the declaration in scope, which may be unprototyped (`void f();`) and is
  then stored in a `void (*)()` slot with no conversion (C11 6.7.6.3p15).  When the two
  daScript types differ, `functions.rs function_designator_value` converts the value to the
  type C gave it through `abi.rs abi_pointer_cast` (a `reinterpret`); the call through the
  slot already converts back to the callee's type.
  `p115-unprototyped-function-values`.
- A module-level initializer that reaches its own object — naming it (`&table[1]` inside
  `table`, an address constant) or through a call or `@@f` whose body reads it — is a
  dependency cycle of one, which daslang rejects (`error[30177] ... can't be initialized with
  itself`, `error[31104]: global variable initialization loop`).  `global_order.rs` routes
  it, and every initializer that depends on it, through an `[init]` function
  `c2da_gset_<name>` (not `c2da_ginit_<name>`, the statement initializer `functions.rs`
  builds for a table of unions, which a cyclic object may also have).
  `p116-self-referencing-initializer`.  A cyclic object that owns storage-backed records keeps
  the zeroed storage its declaration gives it, and its `[init]` builds the value in a temporary
  and copies the bytes into that storage (`global_order.rs StorageGlobal`), so an address
  taken inside the initializer (`&ring[2].v` within `ring`) stays valid;
  `p132-storage-object-identity`.
- A module-level object an inline initializer reads — in C only ever its address — has its
  zero spelled `default<T>` when C gave it no initializer: daslang counts a `var` without one
  as never initialised, wherever it is declared (`ast_lint.cpp`, `error[30173]`), while C
  zero-initialises it before the program starts (C11 6.7.9p10).  `p135-static-zero-spelled`.

## Memory copies go to daslang's builtins

C `memcpy` and `memmove` are lowered to daslang's builtin `memcpy` / `memmove`
(`void?, void?, uint64`), not to the `c2da_rt_*` byte loops (`runtime.rs
CanonicalRuntimeFunction::builtin_copy`, `functions.rs lower_builtin_copy`): the two raw
addresses are converted to pointers by the same path every raw-address operand uses
(`abi::raw_address_to_pointer`), a constant non-zero size is passed as is, and any other size
is named first and guarded by `!= 0`, because the builtin checks neither the size nor the
pointers while C's `n == 0` is a no-op whatever the pointers hold.  All three operands are
evaluated before the guard so C's argument evaluation order is kept when the copy is skipped;
when the C result is used it is the named destination address.  `memset`, `memcmp` and
`memchr` stay on the runtime helpers; `c2da_rt_memset` itself (C `memset`, `calloc`'s clearing)
fills through daslang's builtin `memset8` in chunks of at most 2^30 bytes, since that builtin
counts in `int` (a 256-byte fill: 11 ns against 4.2 µs for the former byte loop).  Because the builtins are named unqualified, a C
translation unit that defines its own `memcpy`/`memmove` (a decoder's shim does) would
shadow them; `renamer.rs DASCRIPT_BUILTIN_COPY_NAMESPACE` reserves the two names, so such a
definition is emitted as `memcpy_0`.  With a daslang that lowers the builtins to LLVM
intrinsics (upstream #4089) the constant-size copies inline under `-jit`; on a toolchain
without it they are libc calls, and the measured gain is the interpreter's (6–27 %).

The copies the translation makes itself go to the same builtins
(`object_memory.rs object_byte_copy`): a storage-backed record read out of memory, assigned or
initialized, a natural record moved in or out of raw storage, and a misaligned scalar moved
through its typed temporary.  The size is the object's Clang size, a nonzero constant, and both
addresses are objects of that size, so no guard is needed (a zero-sized object copies nothing).
A copy into a temporary the lowering created is `memcpy`; an assignment between two C objects is
`memmove`, because C lets them overlap exactly (`*p = *q` with `p == q`, C11 6.5.16.1p3).  Before,
each was a call of the `c2da_rt_memcpy` byte loop, which the interpreter runs at about 65 ns for
four bytes against 10 ns for the builtin; Doom's per-frame hash copies a four-byte `struct color`
per pixel, and that loop alone was 81 % of the interpreted demo.  `c2da_rt_memcpy` remains for
the runtime's own `realloc`.  `p150-object-byte-copies` is the fixture.

## The raw heap

`runtime.rs` owns C's heap: one `array<uint8>` (`c2da_rt_heap`) plus a record table
(`c2da_rt_alloc_addrs` / `_sizes` / `_live`) and a free list (`c2da_rt_alloc_free`).

- **Addresses never move.** The array's capacity is reserved once (`HEAP_RESERVE_BYTES`,
  1 GiB) before the first address is handed out, and `resize` never passes it, so the
  array never reallocates.  Growing past the reserve would move every live block, so a
  request that does not fit returns `NULL`, as C's `malloc` may.  The reserve is address
  space only: daslang's `reserve` leaves the pages untouched (a program's maximum RSS
  measured the same with no reserve and with 64 MiB to 1.5 GiB), and only bytes below the
  high-water mark are `resize`d, i.e. committed.
- **Sizes are 64-bit.** Heap offsets, sizes and byte counts stay `uint64`: the arena and
  the record table grow through the `int64` `resize`/`reserve` overloads, lengths are read
  with `long_length`, and the heap and raw pointers are indexed with the `uint64` offset
  itself (daslang bounds-checks a 64-bit index as 64-bit).  Nothing is narrowed to `int`,
  so a size past 2^31 is refused or panics, never truncated.  Record and free-list
  indices are `int`; a compile-time assertion keeps the reserve's block count inside it.
- **Object storage fails closed.** `c2da_rt_local` / `c2da_rt_static` (addressable C
  locals and statics) panic when the reserve cannot hold the object: unlike `malloc`, C
  gives such an object no `NULL` to return.
- **Blocks.** A block's capacity is its request rounded up to 16 bytes and its start
  address is 16-aligned (`alignof(max_align_t)`); `malloc(0)` returns `NULL`.  Records are
  appended only when the bump pointer (`c2da_rt_next`) carves a new block, so the address
  column is sorted and `free`/`realloc` find a block by binary search.
- **Reuse.** `free` marks the record not live and pushes it on the free list; `free(NULL)`,
  a non-block pointer and a second free change nothing.  `malloc` first takes the
  best-fitting freed block whose capacity is at least the rounded request and at most twice
  it (blocks are never split or merged, so a small request cannot pin a large block), newest
  first, stopping at an exact fit; only then does the arena grow.
- **`realloc`** keeps the block when its capacity already holds the new size, grows the
  arena's last block in place, and otherwise allocates, copies the whole old block (every
  byte C preserves) and frees it.  `realloc(p, 0)` frees `p` and returns `NULL`.
- **`calloc`** clears what it returns: a reused block holds its previous owner's bytes.
- `c2da_rt_reset` forgets every block at once (records, free list, bump pointer), for
  harnesses that run several probes in one process.

`p56-heap-churn` is the acceptance case (cumulative allocation far beyond the reserve,
96 MiB live at once, alignment, `realloc`/`calloc`).
