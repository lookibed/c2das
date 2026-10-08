# Translator ownership contract

The translator produces daScript AST, not repaired text.  C rvalues, C places, and raw addresses
must stay explicit in API names and result types.

| Owner | Charter |
|---|---|
| `abi.rs` | raw address ↔ typed pointer/null and storage-byte ABI conversions |
| `layout.rs` | canonical Clang-backed size, alignment, record offsets and diagnostics |
| `runtime.rs` | the complete `c2da_rt_*` declaration registry and raw-memory calls |
| `libc.rs` | the `--libc std` replacement table: `c2da_std_*` helpers, the standard streams, the `errno` cell and numbering, the std `FILE`'s own state, and the `main` entry wrapper; under `--libc eden` the `c2da_eden_*` stand-ins for `daslib/fio` |
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

A storage-backed record *field* — a union, a packed or bitfield struct embedded by value —
does not make its record storage-backed.  It lies inline, as the unsigned integer of its
alignment (`uint8`, `uint16`, `uint`, `uint64`), or a fixed array of it when the record is
wider (`layout.rs inline_record_storage`; a record aligned beyond eight bytes, or an array of
storage-backed records, has no inline storage and keeps the record storage-backed).  The
record stays natural, its layout proof covers the inline field, and its other fields are
`p.field`.  The embedded record keeps its wrapper for every object that names it on its own
(a local, a global, a parameter, an object behind a pointer to it): its place inside a
natural record is bytes at the field's address, exactly as an object reached through a
pointer is.  A member is read and written through its own type at that address
(`p->function.acp1` is `reinterpret<actionf_p1?>(p)[k]`, `s.bits.f` is
`reinterpret<float?>(addr(s.bits))[0]`, a bitfield member goes through its unit there;
`object_memory.rs storage_object_address` / `structs_unions.rs inline_record_place_address`);
a member whose daScript type is the storage type is the field itself (`p->bits.u` is
`p.bits`, `field_address`).  The field read as a value is a fresh wrapper over a copy of its
bytes (`convert_member_expr`), assigned a value it takes the value's bytes (`operators.rs
address_backed_member_place`), and a braced initializer or cast reaches it as the storage
read out of the wrapper it builds (`inline_record_field_initializer`).  Doom's `thinker_t`
with its `actionf_t` union, `mobj_t` with its packed `mapthing_t spawnpoint`, and every
record that embeds them are natural on this rule.  `p176-inline-union-fields` is the
fixture.  (A member of an rvalue record's inline field, `f().u.m`, binds the storage to a
temporary first.)

A struct with bitfields is natural too when its bitfields group into the storage units the
System V ABI allocates them in (`layout.rs natural_members`): each run of bitfields sharing a
unit — the field's declared type, aligned to its size, holding the field whole — is one
unsigned integer of the unit's size (`c2da_bits_<n>`, `NaturalMember::BitfieldUnit`), the
ordinary fields are themselves, and the natural daScript layout of those members is checked
against Clang's offsets, size and alignment exactly as for any other record.  The layout
proof asserts each unit's offset once (`register_layout_proof`).  A bitfield read is a shift
and a mask on the unit, a write a read-modify-write of it, spelled by name below the record
object (`s.c2da_bits_0`, `a[i].c2da_bits_0`; `structs_unions.rs natural_bitfield_place`,
`object_memory.rs object_member_address`, the by-name root with `base_is_object`) or below a
typed record pointer (`p.c2da_bits_0`; `field_address` pushes the unit name,
`bitfield_storage` picks the word).  A one- or two-byte unit computes in `uint` and is
narrowed back (daslang has no operators on `uint8`/`uint16`); a signed field is sign-extended
in the field's type or `int`; a field as wide as its unit is the unit.  A braced initializer
composes each unit from its fields' values, constants folded into one literal
(`bitfield_unit_value`); a copy of the record is a value copy.  A bitfield that straddles its
unit (packed), two units of different sizes at the same bytes (`uint8_t a:4; uint32_t b:4`),
a unit an ordinary field shares (`char tag; int v:8`), an unnamed or zero-width bitfield, or
a width over 63 keeps the record storage-backed, and a natural bitfield record reached
through raw bytes (inside a union, through `char *`) keeps the byte path at the unit's
offset.  Doom's `struct color` read per pixel in `dg_hash_frame` is the motivating case.
`p177-natural-bitfield-records` is the fixture; `p151` keeps the storage-backed cases.

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
whole-record and whole-array copies, bitfields, union members of a type other than the union
field's storage, and every storage-backed record.  `p104-field-by-name`,
`p105-field-by-offset-kept` and the source invariant
`named_field_access_requires_a_layout_proof` are the fixtures.

## Subscripts of declared arrays

A subscript of a declared array *variable* — a global, a static, a local, a row of an array
of arrays — is daslang's fixed-array index of that object (`mod.rs convert_subscript`,
`object_memory.rs direct_array_object`, `direct_array_lvalue`): `ceilingclip[x]`,
`grid[i][j]`, `players[i].health`.  The former form, the decayed address indexed as a pointer
(`addr(a[0])[x]`), was a bounds-checked element load plus an address plus a pointer index per
access; the direct index measured −21% in the interpreter
(`docs/followups/translated_output_critique.md`, finding 2).  C forms and reads an element
only inside the array (C11 6.5.6p8), so the index check daslang keeps is a check on undefined
behaviour: an index past a declared array raises daslang's located exception in the
interpreter, and `--unsafe-deref` drops it as it drops the null checks — `apply_unsafe_deref`
adds `hint(unsafe_range_check)` beside `unsafe_deref` (`ast_bound_check_elision.cpp`), so that
build reads the neighbouring bytes exactly as C does.

An array *field* of a natural record (`p->arr[i]`, `s.arr[i]`) is the separate decision the
previous section deferred, and the corpus decided it against the by-name index in both builds.
C programs index past a field array into the fields declared beside it on purpose: Doom's
`pl->top[pl->maxx + 1] = 0xffff` and `pl->top[pl->minx - 1] = 0xffff` write the `pad2` and
`pad1` that bracket `top` (`r_plane.c`).  The checked build threw `index out of range, 320 of
320` there, and the `--unsafe-deref` build with `hint(unsafe_range_check)` segfaulted on the
`-1`: daslang's unchecked fixed-array index scales the index in `uint32`
(`SimNode_AtT::compute`, `pValue + uint32_t(idx)*stride`), so the element before the array is
four gigabytes away instead of two bytes back.  A field array therefore keeps its bytes at the
Clang offset — a fresh typed pointer at the offset, then a pointer index, whose arithmetic is
C's — until daslang's unchecked index computes in pointer width (finding 4 stays open).  Three
more shapes keep the pointer form because C's own rules let them leave the array:

- **The address of an element.**  `&a[i]` is the decayed pointer stepped by the index
  (`operators.rs`, `AddressOf`): `&a[N]` is the legal one-past-the-end pointer
  (`end = &table[5]`, Doom's `&vissprites[MAXVISSPRITES]`), which a fixed-array index refuses.
- **The struct hack.**  A trailing array field of one element (or none) is memory allocated
  past the record (wasm3's `code[1]`): a field array, bytes at the Clang offset.
- **Not an object.**  A decayed pointer (`int a[]` parameter, a pointer variable), an array
  member of a union (bytes of the union field's storage), an array of storage-backed records
  (`wrapper_array_base`) and an array of arrays whose row is one of these.

What the hint changes for a declared variable is undefined behaviour only: an index past the
array reads the neighbouring bytes as C does, and a negative index — undefined in C for a
variable array — faults on the same `uint32` scaling instead of reading before the array.
`p178-direct-array-subscripts` is the fixture, in both builds.

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

## Target switches (`--float-compare`, `--dialect`, `--no-unsafe`)

`crate::target::TargetOptions` holds the switches for a runtime other than master daslang
(`docs/eden-flags.md`); its default is master daslang and changes nothing.  A switch whose
lowering does not exist yet is refused by name in `main.rs` before translation.

- `float_compare.rs` owns `--float-compare nan-safe`.  Every floating comparison an owner
  builds goes through `Translation::compare_or_binary_op` (`operators.rs`): the arithmetic
  binary path, the generic binary path, truthiness (`convert_condition`) and `!x`.  A new
  owner that writes a floating `==`/`<`/… must call it too, or the comparison is not IEEE
  in the EdenSpark editor.  The guarded call counts as a boolean expression
  (`is_boolean_expression`, `infer_type`).
- `target_check.rs` owns `--dialect eden-0.6.4` and `--no-unsafe`.  They are checkers over the
  finished `DaModule` parts (options, requires, declarations) called once from `mod.rs`, after
  every module pass; they never rewrite the module.  `das_ast` nodes have no C location, so a
  site is located at the C declaration that owns it, or named as translator-generated.  The
  `--runtime-module`/`--module-layout source` shared module goes through the same checkers
  (`check_shared_module`, called by `shared_module_source`), its sites named by declaration
  and the module's file name.
- `libc.rs` owns `--libc eden` as well.  It is the `--libc std` table with every helper built
  as under `std`, except that each `daslib/fio` (or console) name a helper calls goes through
  `fio()`, which answers an emitted `c2da_eden_*` stand-in: a `FILE *` is a `uint64` handle
  (1/2/3 the standard streams); stdout and stderr are line buffers written with `print` and
  `to_log(LOG_ERROR, …)`; files are read-only byte arrays the host registers with
  `c2da_eden_add_file(name, bytes)`; `exit` records the status and panics, and the `main`
  wrapper recovers it (`eden_entry_body`, the `DaExpr::TryRecover` node); `getenv` answers
  NULL; `remove`/`rename` fail.  The module requires only `strings`.  A C `memmove` and an
  overlapping object copy use the `c2da_rt_memmove` byte loop instead of the `memmove`
  builtin (`functions.rs`, `object_memory.rs`).  A new std helper that calls a `fio` name must
  route it through `fio()`, or `--libc eden` output requires nothing but still names it.
- `linear.rs` owns `--memory-model linear` (core; `docs/eden-flags.md` flag 1).
  - **Representation.** C memory is one module global `c2da_mem : array<uint8>`. A data
    pointer's daScript type is `int`, an offset into it (`convert_type`); NULL is 0
    (`null_for_type`) and offsets 0–15 are never handed out. A pointer to a function keeps
    today's function value. In memory a pointer takes Clang's 8 bytes: the offset in the low
    4, zero in the high 4.
  - **Integers and comparisons.** A pointer cast to an integer (`uintptr_t`, `intptr_t`,
    `long`) is the offset converted to that type, so it is small and non-negative. An integer
    cast to a pointer is `int(x)`. Pointer comparisons compare offsets. A difference is the
    offset difference divided by Clang's pointee size.
  - **Hooks.** The lowering runs before the ordinary one at three points: the top of
    `convert_expr` (`linear_expr`: loads, casts, `&`, calls), `convert_binary_expr`
    (`linear_binary`: stores, compound assignment, pointer `+`/`-`/compare/difference) and
    `convert_increment` (`linear_incdec`). Each answers `None` when no C memory is involved.
    A conditional or `for` step that calls `convert_binary_expr` directly is covered by the
    same hook. `cfg/structured.rs` adds no pointer inductions under the model.
  - **Places.** `heap_place` gives the address of an lvalue in the heap: `*p`, `p[i]`, `i[p]`,
    `p->f`, and `.f` of any of these. A field adds Clang's offset (`layout.rs field_offset`).
    A subscript of a declared array is the heap only when the array itself is (a field
    array reached through a pointer, a string literal); otherwise the ordinary
    fixed-array index applies.
  - **Loads and stores** are written in place, with no helper call. A byte is
    `c2da_mem[a]`. A wider integer is assembled little-endian from bytes with shifts, or
    stored as `uint8(bits >> 8k)`. `float`/`double` go through `math_bits`
    (`uint_bits_to_float`, `uint64_bits_to_double` and their inverses). An address that is
    not a variable or a constant sum is bound to a `let` first. A compound assignment reads
    the old value, computes in Clang's computation type, and narrows back.
  - **Static data.** A string literal whose address is taken goes into a static block from
    offset 16, deduplicated. Its address is a constant. The block is a
    `fixed_array<uint8>` that `[init] c2da_lin_init` copies into the heap after
    `reserve(c2da_mem, --heap-reserve)`.
  - **Runtime.** `runtime_source` is appended to the module text as hand-written daslang.
    `c2da_lin_malloc`/`calloc`/`realloc`/`free` use 16-byte headers, a first-fit free list
    and `resize` within the reservation. An allocation past it returns 0. `memcpy`,
    `memmove`, `memset`, `memcmp` and `strlen` are byte loops over `c2da_mem`.
    `prune_raw_runtime` drops the `c2da_rt_*` raw prelude when nothing names it.
  - **Fails closed.** These are refused with a located "not supported under --memory-model
    linear yet: …" error: `&` of a local or global, a declared array used as a pointer
    (step 4), a record or array value read through a pointer, a bitfield through a pointer,
    a wide string literal, a data↔function pointer cast, and any other library function
    that takes or returns C memory. A string-literal argument does not count. As a net,
    `target_check.rs check_linear` refuses any `unsafe` construct left in the finished
    module, located at its C owner. That covers, for example, the `--libc std` formatter
    behind `printf`, which reads C strings through raw pointers. A module split
    (`--runtime-module`, `--module-layout source`) is refused, because the heap is one
    module global. Layout proofs are not emitted under the model, since a daScript struct
    only ever holds a record by value.

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

The same pass is the one decision point for two interpreter-speed spellings of a statement
(`fold.rs value_store`, `increment`; `das_ast::fold`, "Value stores" and "Increments").
daslang's `sv_makeCopy` stores a *reference* right-hand side — a name, a field, an element,
a dereference — with `CopyRefValue`, a memcpy of a runtime size, and a *value* with the typed
`Set_TT<T>`; a same-type `T(x)` of a reference `x` is simulated as `x` read as a value and
costs no node.  The interpreter fuses `CopyRefValue` with a local on either side into nodes as
fast as `Set_TT`, so a scalar store `place = value` of a builtin number is written
`place = T(value)` (`CastKind::Value`, which the identity fold never removes and the printer
spells like the conversion) only when `value` is a reference expression of exactly `T` and
neither side is a local name or a field of a local structure — `*dest = uint8(colormap[i])`,
`g = int(p[i])`, `p.a = int(q.b)` through pointers, `garr[0] = int(param)` — while
`loc = p[i]`, `*p = loc`, `g = lp.a` and every local initialiser keep the plain copy
(measured 20 M-iteration stores: `*p = q[i]` 7.6 → 6.1 ns, `p.f = q.f` 4.5 → 3.5,
`g = param` 9.5 → 8.3; `*p = loc` would go 3.2 → 4.0).  Pointers, `bool` and enumerations
are left alone.  A statement `x += 1` / `x -= 1` on a builtin integer is `x++` / `x--`
(`DaExpr::IncDec`): daslang's fused `Inc_TT`/`Dec_TT` against `SetAdd_TT` over a constant node
(6.9 → 4.9 ns on a global, 4.0 → 3.0 through a pointer, equal on a local), and its linter
flags the `+= 1` form (PERF013).  `p180-value-stores` is the fixture.

The printer renders a declaration's annotations as one bracketed, comma-separated block
(`[export, unsafe_deref]`).  daScript's grammar accepts exactly one block per declaration;
two consecutive `[...]` lines are a syntax error.

### `--module-layout source`: clusters and fragments

`lib.rs link_units` owns the program-level layout; `translate_impl` lowers one unit as before
and is told what the rest of the program is through `UnitLink`.  Units on a reference cycle
(Tarjan's strongly connected components of unit → owner of a referenced external symbol) are
one daslang module, because daslang refuses a cyclic `require`: each member is a *fragment*
(`UnitLink::fragment`), whose `UnitOutput` carries its module-level declarations and its
`require`s instead of a module text, and `lib.rs` writes `<stem>.das.inc` (declarations only)
and the cluster file (`translator::cluster_module_source`: header, options, the union of the
`require`s, one `include` per fragment).  The cluster is `<lexically first stem>_cluster`, or
the entry unit's stem — anonymous — when it holds `main`.  The fragment extension
(`lib.rs FRAGMENT_EXTENSION`, `das.inc`) keeps fragments away from a tool that compiles every
`.das` file standalone.

The fragments share one module scope, and every rule that makes a name unique is the
renamer's, never a text rewrite:

- `UnitLink::reserved_values` — the external symbols the other members define, plus every
  module-level name the earlier members (compilation-database order) declared — are reserved
  on the value renamer right after the unit's own external names are claimed, so a static,
  a hoisted function-scope static or a layout-proof function that would take one is renamed.
- String-literal arrays are named `c2da_str_<stem>_<n>` in a fragment
  (`literals::reset_string_literals`).
- `UnitLink::reserved_types` (every source-layout unit, not only fragments): a C type name
  defined at two places is two C types sharing one shared module; the lexically first place
  keeps the name, the others reserve it so the type renamer picks `<name>_<k>`.  An anonymous
  record is `Unnamed_<file>_<line>` (`Translation::anonymous_record_name`), so the same record
  reached through a header is one shared type and two units' records are two.
- A fixed-name generated helper two fragments emit identically is declared once; a different
  one fails closed (`TranspileError::Layout`).

daslang's global-initialization check is module-wide and follows calls and `@@` into bodies,
so a fragment's `global_order::order_value_declarations` gets the other members' functions and
objects (`UnitLink::foreign_refs`, name → the names a body or initializer reads; the cluster
is translated once more first to learn them) and routes a cycle through another fragment to
`[init]` like a local one.  Object order across fragments is the include order
(`lib.rs include_order`: a fragment whose initializers reach another's objects comes after
it), and every fragment object without an initializer except an array is given C's zero
(`default<T>`), which daslang requires of an object another initializer names.  A block-scope
`extern T x;` of an object another unit defines emits nothing (the name resolves to the
owner), and the designator of a function another unit defines, declared here without a
prototype, is always converted to the C pointer type (`functions.rs
function_designator_value`): the definition's prototype is not visible in this unit.

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

## Control-flow back ends: structured first, flat label/goto as the fallback

A function body has one of two back ends (`cfg::convert_function_body`), chosen per function
on the C AST before anything is converted (`cfg/structured.rs fallback_reason`; conversion has
effects that must happen once — a function-scope `static` is hoisted to module scope, `musttail`
reports itself — so a body is never converted twice):

- **structured** (`cfg/structured.rs`): the C statements are walked directly and become daslang
  `while`/`if`/`elif`/`else`/`break`/`continue`/`return`.  A `for` continues through its step,
  written again before each `continue` (a fresh conversion of the same C expression, which C
  evaluates exactly there); a `do`/`while` tests its condition at the bottom of `while true`
  and again before each `continue`; `do … while (0)` is its body, or `while true { …; break }`
  when it has a `break`/`continue`, whose `continue` is that `break`; a condition with
  statements of its own (`while ((c = next()) != 0)`) is tested at the top of `while true`.
  A `switch` whose arms never fall into each other and that has at most eight case values is
  an `if`/`elif`/`else` chain with the arms inline (`switch_chain`): the scrutinee (a hoisted
  temporary unless it is a plain read) compared in the promoted type against each arm's values
  (`x == 1 || x == 2`), `default` the final `else` wherever it stands, a `break` at the end
  of an arm dropped and one that ends a branch of an `if` folded (`if (c) { a; break; } b` is
  `if c { a } else { b }`, `lift_breaks`); a `continue` of the enclosing loop stays what it is.
  A `break` deeper in an `if` that statements follow (it would need those statements twice)
  keeps the region.  The limit of eight is measured in the interpreter (2026-10-08, 20 M
  passes of a dense switch hit uniformly, `acc += k` per arm): with a statement after the
  switch, chain 314 ms against table 397 ms at 8 values, 410 against 396 at 12, 520 against
  377 at 16, 910 against 370 at 32; with the switch ending the loop body (the table's `break`
  is `continue`), 280 against 271 at 8, 380 against 283 at 12.  A median split with the arms
  inline (304/350/370/440 ms at 8/12/16/32 with the statement) would copy the `default` arm
  into every half and is not emitted.  `p179-structured-switch-chain` is the fixture.
  Any other `switch` keeps the flat dispatch (below:
  tests, median split or computed-`goto` table) and is a *label region* in the statement list
  that holds it — dispatch, `label` per arm in source order, end label; a `break` of the
  `switch` is `goto` the end, fall-through is fall-through.  Every jump of a region stays in
  that list, because the interpreter's label table belongs to one block
  (`SimNode_BlockWithLabels::eval`); a `break`/`continue` of the enclosing loop and a `return`
  are daslang's own.  Three repairs keep a region exact, all on the intermediate tree, and a
  checker re-verifies the result (a violation is an internal `TranslationError`, never output):
  a label with nothing after it is resolved by what falling off its list means (`continue` in
  a loop body, `return` at the end of a void function — jump-table entries to it land on a
  trampoline behind the dispatch), or, at the end of an `if` arm with statements after the
  `if`, that one `if` is spliced into labels in its parent; an early exit a jump crosses moves
  out of line (as `move_crossed_early_exits`, below, for `break`/`continue` too); a site
  temporary at the top level of a list with labels is hoisted for AOT (below).  C locals are
  hoisted exactly as in the flat back end; other site temporaries stay where the lowering put
  them.  A function with a value whose only exit is a `return` inside an endless loop gets the
  trap and a `return` of the type's default after it, for daslang's `exprReturns`.
- **flat** (`cfg/labels.rs`): the CFG rendered as `label`/`goto`, total over every graph.  It
  takes a body with a `goto` (its labels can form any graph, irreducible ones included), a
  `case` label below the top level of its `switch` (Duff's device), statements before the
  first `case`, or statements nested deeper than 64 levels (AOT's C++ nests each `elif`).

**Counted loops** (`cfg/structured.rs counted_do_while` / `counted_for`, decided on the C AST;
the flat back end keeps its CFG rendering) are daslang's `for` over a range, one fused
`ForRange` interpreter node instead of a counter copy, a decrement and a test per pass:

- `do { body } while (count--)`, `count` an `int` local (not static, not address-taken, not
  `volatile`) the body never names and that is dead after the loop, is
  `for (c2da_iter in urange64(0, uint64(uint(count)) + 1))`.  C runs the body `count + 1`
  times for `count >= 0` and, by the two's-complement wrap the `while` fallback performs
  too, `2^32 + count + 1` times for `count < 0`; that `uint64` is the number in both cases,
  `INT_MAX` included, so no guard and no second copy of the body.  `continue` is daslang's
  own (the range steps the counter).  An `unsigned` counter keeps the `while`.
- `for (init; i < b; i++)` (`++i`), `i` an `int`/`unsigned` local as above that the body
  never writes, compared in its own type, `b` invariant over the body (constants, enumeration
  constants, `sizeof`, such locals the body does not write, under conversions and
  arithmetic; a memory read, a global or a call is not shown), `init` absent, `i = a` or
  `int i = a`, is `for (i in range(a, b))` / `urange`.  `i` is the loop variable under its C
  name, with no hoisted `var`, when nothing outside the loop names it; when something before
  the loop does and `i` is dead after it, a fresh `c2da_<i>` iterates from `i`'s value.  Live
  after the loop (its final value would be `b`, or less with a `break`) keeps the `while`.
- Dead after: on every path from the loop's exit `i`/`count` is assigned (`x = e`, `e` not
  naming `x`) before it is read, walking the function's statements in order, back around an
  enclosing loop's condition, step and body top; a `break`/`continue` after the loop or any
  other read counts as live.

`das_ast::fold` types a `range`/`urange`/`range64`/`urange64` loop variable, so `t = t + i`
in the body is still `t += i`.  `p175-counted-loops` is the fixture (every fallback has a
function).

**Pointer inductions** (`cfg/structured.rs pointer_inductions`, decided on the C AST per
loop; the flat back end keeps its form): a pointer local a loop steps by compile-time
constants and otherwise only reads through is mirrored in a `uint64` address for that loop —
`var c2da_p_addr : uint64 = reinterpret<uint64>(p)` before it, every read of `p` inside
`reinterpret<T?>(c2da_p_addr)` (a decl-level binding in the DeclRef lowering,
`Translation::pointer_inductions`, like an inlined parameter's), each step
`c2da_p_addr += C * sizeof(T)` (Clang's size from `layout.rs`; a negative step subtracts),
and `p = reinterpret<T?>(c2da_p_addr)` after the loop unless `p` is dead after it
(`dead_after`, the counted loops' walk: on every path from the exit `p` is assigned before
it is read, an enclosing loop's next pass included — a pointer named only inside the inner
loop is read again there by that loop's own mirror, h264bsd's
`Intra16x16HorizontalPrediction`).  The mirror is stepped in place wherever `p` would be, so a
`break`, a `continue` or an early `return` leave the address `p` would hold.  daslang's
pointer `+=` is an `i_das_ptr_set_add` call node with three operand nodes; the mirror's step
is one fused `SetAddLocConst<uint64>` (`++` for one byte), and its dereference
`Ptr2Ref(GetLocalR2V<uint64>)` is the two nodes a dereference of the pointer itself costs
(`materialize_place_once` counts a `reinterpret` of a variable as stable, so no temporary is
bound).  Measured in the interpreter (2026-10-08, Doom's column loop shape, 20 M pixels,
per-process runs): 18.3–18.7 ns per pixel for today's form, 15.9 for the mirror, 16.3–16.9
for an `int` index over the base pointer (`base[k]`, `k += 320`, the critique's proposal),
16.8 for an `int64` index, 18.9 for `base[iter * 320]`, 20.7 for `p = p + 320`; the span
loop (stride 1) 25.6 → 23.8.  `p` qualifies when it is a block-scope local (not static, not
thread, not `volatile`, address never taken), typed pointer to a complete scalar or record
type, named before the loop (a `for`-init declaration is not), and every reference to it in
the loop statement — init, condition, step and body — is the operand of `*`, the base of
`[]` or `->`, or a step.  A step is an expression statement at the body's top level or an
operand of the `for` step (through commas): `p++`, `p--`, `++p`, `--p`, `p += C`, `p -= C`
with `C` an integer literal (negated or cast), or `*p++` / `*++p` (and `--`) anywhere in such
a statement that references `p` nowhere else — emitted as the statement with `p++` read as
`p` (`Translation::expr_overrides`) and the step after it (before it for the prefix forms;
`*d++ = *s++` steps both).  A step under an `if` or inside a nested loop, a comparison of
`p`, `p` passed to a call, assigned, read as a value or stepped by a variable keeps today's
`unsafe { p += n }`; a nested loop stepping `p` at its own top level is that loop's induction,
stored back for the outer body.  Doom (`doom_bench_all.c`): 121 loops, 278 mirrored steps,
the `unsafe { p += n }` blocks 558 → 262.  `p181-pointer-inductions` is the fixture (every
fallback has a function; `*d++ = (uint8_t)(*s++)` is there because the C AST walk reaches
the `s++` under the cast twice and the step is taken once); `p174`'s in-loop stores are
inductions now.

**Single-use temporaries** (`cfg/structured.rs plan_substitutions`, decided on the C AST per
statement list, in source order; the flat back end keeps its form): a scalar local assigned an
expression and read exactly once, straight after, in the same statement list is written as that
expression at the read and the assignment is dropped — the interpreter's `SetLocAny` and
`GetLocal` of the local (about a node each, ~1.1 ns) go away.  Doom's `R_DrawSpan` computes
`ytemp`, `xtemp` and `spot` that way per pixel; in order the three fold into
`*dest = uint8(ds_colormap[int(ds_source[int(position >> 26u | position >> 4u & 0xfc0u)])])`
(−5.7 % of Doom's interpreter time, measured by hand before the mapping; `docs/followups/
interpreter_hot_loops.md`, "Profile 2").  The pass lives in the structured back end because
every fact it needs is a C fact already decided there: `dead_after` (the counted loops' liveness
walk), address-taken and `volatile` locals, `writes`; the value is placed through the same
decl-level hook as a pointer induction's `*p++` (`Translation::expr_overrides`), in `t`'s own type,
so the C conversions around the read are untouched.  A substitution needs all of: `t` a
block-scope local (not a parameter, not static, not thread, not `volatile`, address never taken)
of integer, `float`/`double` or pointer type, assigned by an expression statement `t = E` or
declared `T t = E` on its own; `E` without effect, call or `volatile` read (literals, `sizeof`,
enumeration constants, locals, memory reads — globals, elements, fields, `*p` — conversions,
arithmetic, comparisons, `&&`/`||`, `?:`); the first statement after that names `t` reads it
once, in a position evaluated exactly once at the statement's start (an expression statement,
a `return` value, an `if`/`switch` scrutinee, a lone declaration's initializer, a `for` init —
not an arm of `?:`, the right of `&&`/`||`, a callee, a loop test or body: a read under a branch
or inside a nested loop keeps the local, so a `/` or `%` in `E` runs exactly where C's did);
nothing between the assignment and the read — the statements between, and the reading
statement up to its own top-level assignment, whose store is sequenced after its operands
(C11 6.5.16p3) — writes a local `E` reads or, when `E` reads memory, stores to memory, calls or
is inline assembly; no `case`, `default` or label between; and `t` dead after the reading
statement (`dead_after`, whose answer for a loop body that re-assigns the local before reading
it is now the loop's exit path, not "dead": the pointer-induction store-back shares the fix).
A chain (`spot = xtemp | ytemp`, each read once) folds because a temporary planned into the
assignment contributes what its own expression reads.  The substitution is applied only when
the assignment lowers to the one statement `t = E'`; a local every reference of which was
substituted loses its declaration when the declaration has no initializer, a literal one or the
consumed one.  Doom (`doom_bench_all.c`): see `-Wcontrol-flow` below.
`p182-single-use-temporaries` is the fixture (the `R_DrawSpan` chain; pointer, `float` and
index temporaries; scrutinee, initializer and `x = x + 1` reads; and every kept case: read
twice, live through a loop's exit or back edge, an operand written between, a store or a call
between a memory read and its use, a read inside a nested loop, a division read under an `if`,
a read on one arm of `?:`).

`-Wcontrol-flow` (off by default) reports each function's back end and, for a flat one, why,
each `switch` of a structured body as an inline chain or a label region (with why), and the
number of single-use temporaries a structured body substituted.  On
2026-10-08: doomgeneric (`doom_bench_all.c`) 70 chains / 22 regions (11 with more than eight
values, 10 fall-through, 1 nested region), wasm3 8 / 7 (all more than eight values).
On the corpora (2026-10): pl_mpeg 169 structured / 0 flat, h264bsd 378 / 2, wasm3 688 / 131
(the module loader and compiler's `_Catch`/`_Throw` gotos; the opcode handlers are
structured), binjgb 207 / 18, doomgeneric 975 / 8.  Reason: daslang's interpreter pays a
block restart per taken `goto` (`SimNode_BlockWithLabels`, `stopFlags` `jumpToLabel`).
Interpreter medians, flat → structured (`corpus_matrix.py bench`, 2026-10-05): pl_mpeg
−14 %, binjgb −10 %, doomgeneric −9 %, wasm3 −5.5 %, h264bsd −5 %; `-jit`, `-exe` and AOT
within ±5 % (run-to-run spread).  A `break`/`continue`/`goto` inside a GNU statement expression is refused
(`convert_gnu_statement_expression`, `n13-statement-expression-jump`): its statements are
lowered without the loop or `switch` they belong to.  `p160-structured-loops`,
`p161-structured-switch` and `p162-structured-fallback` are the fixtures.

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
