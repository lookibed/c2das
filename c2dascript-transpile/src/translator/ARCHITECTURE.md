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
its conversion.  `p100-redundant-conversions` is the runtime fixture.  The one
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
`memchr` stay on the runtime helpers.  Because the builtins are named unqualified, a C
translation unit that defines its own `memcpy`/`memmove` (a decoder's shim does) would
shadow them; `renamer.rs DASCRIPT_BUILTIN_COPY_NAMESPACE` reserves the two names, so such a
definition is emitted as `memcpy_0`.  With a daslang that lowers the builtins to LLVM
intrinsics (upstream #4089) the constant-size copies inline under `-jit`; on a toolchain
without it they are libc calls, and the measured gain is the interpreter's (6–27 %).

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
