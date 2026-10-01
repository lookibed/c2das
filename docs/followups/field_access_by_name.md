# Field access by name through proven records: `p.field` instead of byte offsets

Recorded 2026-09-26 at `1173131c4` (daslang `69a589623`, clang 18.1.8, AMD Ryzen 7 7435HS,
WSL2).  Research note plus a throwaway prototype measurement.

**Status: implemented** as the default lowering (no switch), per section 7's conditions:
`LAWS.md` 2026-09, `translator/ARCHITECTURE.md` "Field access by name under a layout proof",
fixtures `p104-field-by-name`, `p105-field-by-offset-kept` and the source invariant
`architecture_tests::named_field_access_requires_a_layout_proof`.  The empty-struct and
dropped-field conditions were met before it, on master (zero-sized fields make a record
storage-backed; one natural-record field builder).  The proof covers every complete natural
struct the module declares, not only the ones accessed by name.  The numbers below are the
prototype's.

## The question

Every C field access through a pointer is lowered today by byte offset.  pl_mpeg's
`self->bit_index` (`self : plm_buffer_t *`) becomes

```das
unsafe(unsafe(reinterpret<uint64?>(unsafe(reinterpret<uint64>(self_4))))[0])
```

although `plm_buffer_t` is emitted as a daslang `struct` with a `bit_index : uint64`
field.  `LAWS.md` (2026-08, "C ABI facts are Clang-backed") says a daScript struct does
not automatically prove a C struct layout, and `layout.rs` owns C layout.  The proposal:
spell the access `self_4.bit_index` **only** for records whose daslang layout is *proven*
equal to Clang's, with the proof checked by daslang at compile time, so that a mismatch
fails compilation instead of reading the wrong bytes.  Unions, bitfields,
packed/over-aligned records, storage-backed records and flexible array members keep the
offset path.

**Recommendation: go, with conditions** (last section).  The proof is cheap and real in
all four modes; about 90 % of the pointer field loads/stores of the three corpus programs
qualify; the output shrinks by 4–8 %; and the proof also exposes a silent miscompile
that exists on master today.  Speed changes little, so the case rests on readability and
on the proof, not on a speed-up.

## 1. How daslang lays out a struct, against Clang

Read from `src/ast/ast.cpp` (`Structure::getSizeOf64`, `getAlignOf`) and
`src/ast/ast_infer_type.cpp` (field offsets), and confirmed by a probe that prints
`typeinfo sizeof / alignof / offsetof<f>` next to a C program's `sizeof / _Alignof /
offsetof` for the same record (`bool, int16, int8, uint8?, enum, uint8 enum, function<>,
int16[3], nested {int8; double}, uint8`):

- daslang's rule is C's: fields in declaration order, each at the next multiple of its
  own alignment, the record's alignment the maximum of its fields', its size rounded up
  to that alignment.  A fixed array has its element's alignment; a nested struct is
  inline; a pointer, a `function<>` and `int64`/`double` are 8/8; an `enum` has its base
  type's size (the translator gives each C enum Clang's integral type,
  `enums.rs enum_integral_type`); `bool` is 1 byte like `_Bool`; `int8/int16` are 1/2.
  Every offset, the size (64) and the alignment (8) of the mixed probe record matched
  Clang exactly.
- `[cpp_layout]` changes only how a *derived* structure reuses its parent's tail
  (`findFieldParent`); the translator emits no inheritance, so it is irrelevant here.

Where they differ:

| case | Clang | daslang | today |
|---|---|---|---|
| empty struct field (GNU C `struct E {}`) | 0 bytes | at least 1 byte (`max(1, size)`, "an empty struct field is 0 bytes in daScript but occupies >=1 byte in C++") | **silent miscompile**, see below |
| `float4`-style vector types | — | align 4 | not produced by the translator |
| `long double`, `__int128` | 16/16 | no type | the translator refuses the field (`unsupported record field type LongDouble`) |
| union, bitfield, packed, `alignas`, `#pragma pack`, flexible array | — | no daslang record | storage-backed (`layout.rs compute_storage_backed`) |

**A latent bug the proof would catch.**  `layout.rs natural_layout_of` models daslang's
layout from Clang's own field sizes, so it takes a record containing an empty struct for
a natural one; daslang then lays it out 4 bytes longer.  With

```c
struct Empty {};
struct WithEmpty { int a; struct Empty e; int b; };
static int read_b(struct WithEmpty *p) { return p->b; }
/* main: struct WithEmpty w; w.a = 1; w.b = 42; printf(..., read_b(&w)); */
```

C prints `b=42`; the master translation prints `b=0` in the interpreter: `w.b` is stored
by name at daslang offset 8, `read_b` loads at Clang offset 4.  With the proof the same
module stops at compile time with `error[31403]: C layout of WithEmpty: sizeof` and
`...: offsetof b`.  The typedef-of-anonymous-struct path in `translator/mod.rs`
(`typedef struct { ... } T`) is another place a divergence could hide: it builds the
fields with `filter_map(|f| convert_type(..).ok()?)`, which silently drops a field whose
type does not convert.  Records reach both natural-record paths today with no check that
daslang agrees; the proof is that check.

## 2. The compile-time proof

Form (what the prototype emits; one uncalled function per module):

```das
def c2da_layout_proofs() {
    static_assert(typeinfo sizeof(type<plm_buffer_t>) == 96, "C layout of plm_buffer_t: sizeof")
    static_assert(typeinfo alignof(type<plm_buffer_t>) == 8, "C layout of plm_buffer_t: alignof")
    static_assert(typeinfo offsetof<bit_index>(type<plm_buffer_t>) == 0, "C layout of plm_buffer_t: offsetof bit_index")
    ...
}
```

- `static_assert` is compile-time only and removed from the program; `typeinfo sizeof`,
  `alignof` and `offsetof<field>` are constants.  daslang has no module-scope
  `static_assert`, but it infers every function, including an uncalled private one, so a
  function body is enough; no `[init]`, macro or runtime check is needed.
- Verified to **fail closed in all four modes** with a deliberately wrong offset:
  `daslang x.das` and `daslang -jit x.das` exit 1 with `error[31403]: C layout of S:
  offsetof b` at the source line; `daslang -exe` exits 1 before linking (no binary is
  written); `daslang -aot` prints the same error and `aot returned empty result`
  (exit 255), so no C++ is generated.  With the right numbers all four build and run.
- AOT closes the chain by itself: the C++ that `daslang -aot` emits for every struct
  carries `static_assert(sizeof(S)==..)` and `static_assert(offsetof(S,f)==..,
  "structure field offset mismatch with DAS")`, i.e. daslang's layout = the C++
  compiler's layout; the translator's proof adds Clang's layout = daslang's layout.
- Cost: 299 / 739 / 556 assertions (pl_mpeg / h264bsd / wasm3), one line each.  Their
  effect on compile time was not measured separately.
- `das_ast` needs one addition for a real implementation: `DaExpr::TypeInfo` has no
  subtrait, so the prototype abused `trait_name = "offsetof<f>"`; the real form is a
  `subtrait: Option<String>` printed as `typeinfo offsetof<f>(type<T>)`.

## 3. Census on the corpus

Translated exactly as the benchmark translates (`--strict --libc std`, the
`bench_translation_entry` of each case).  "Sites" are the translator's field-access
lowerings (a read-modify-write `p->f += x` counts its load and its store).

| program | structs emitted | storage-backed | proven (asserted) | records accessed by name | sites by name | sites left on offsets |
|---|---|---|---|---|---|---|
| pl_mpeg 320×240 | 18 | 0 | 15 | 10 | 945 (91 %) | 92 |
| h264bsd 640×360 | 85 | 5 | 77 | 53 | 2093 (68 %) | 978 |
| wasm3 fib32 | 42 | 8 | 31 | 30 | 1711 (78 %) | 475 |

(The structs neither storage-backed nor asserted are the translator's own
`C2daVaArg`/`C2daVaCursor` and libc-side records the program never reaches through a
pointer.)  What stays on offsets, by reason:

| reason | pl_mpeg | h264bsd | wasm3 |
|---|---|---|---|
| address of a field of a proven record: `&p->f` passed on, and **fixed-array fields** `p->arr[i]` (the array decays to a raw address, then an indexed load) | 86 | 739 | 216 |
| path through a storage-backed record (union / contains a union / flexible array member) or a bitfield | 0 | 180 | 187 |
| address of a field of a storage-backed record | 0 | 30 | 56 |
| raw-address base: a storage-backed object, `p[i]` of a storage-backed element | 0 | 28 | 8 |
| whole-record / whole-array copy (`x = p->inner`, memcpy through a typed temporary) | 6 | 1 | 8 |

Storage-backed records: h264bsd's minimp4 `MP4E_track_t`, `MP4D_track_t`, `track_t` and
two anonymous structs (a `union u` inside, or a member that is such a record); wasm3's
`M3FuncType` and `M3Exception` (flexible array members `types[]`, `args[]`),
`M3Global`, `M3TaggedValue`, `M3ValueUnion` and three anonymous records (unions).

The biggest remaining group is fixed-array fields.  `p.arr[i]` would be the next step,
but it is not the same operation: daslang bounds-checks a fixed-array index and C code
indexes past a field array (`arr[-1]`, a trailing `[1]` used as a flexible array), so it
needs its own decision (e.g. keep the decay but compute the base as `addr(p.arr[0])`), not
this proposal.

## 4. Null pointers: `p.field` vs the indexed load

Probed with a null `S?` in each mode (`p.b` against
`unsafe(reinterpret<uint64?>(unsafe(reinterpret<uint64>(p)))[1])`, loads and a store):

| access | interp | `-jit` | `-exe` | aot |
|---|---|---|---|---|
| offset load (today) | **no check**: SIGSEGV at address 0x8 | located exception `dereferencing null pointer` | located exception | no check: SIGSEGV (`das_index<T*>::at` is `value[index]`) |
| `p.field` load / store | located exception | located exception | located exception | no check: SIGSEGV (`p->b`) |
| either, in an `[unsafe_deref]` function | SIGSEGV | SIGSEGV | SIGSEGV | SIGSEGV |

C: a null dereference is undefined behaviour, so every row is a faithful translation;
the difference is diagnostics.  `p.field` is **strictly better in the interpreter** (a
located exception where the offset path segfaults) and identical elsewhere.  The AOT
column shows that "daslang's null check" is not a guarantee of the AOT build in either
spelling.  `--unsafe-deref` keeps its meaning: it removes the field-dereference check
exactly as it removes the `ExprAt` check today (`llvm_jit.das` handles both), so the
option's rows stay comparable.

Other semantic points checked:

- **`const` record pointers.**  C's `const S *p` makes `p->q` of type `T *` (the pointer
  is copied); daslang makes a field read through `S const?` const, and `T? const` does not
  copy into a `T?` (`error[30915]` on h264bsd's `MP4D_frame_offset`).  The prototype
  reinterprets the base to `S?` once, which is what the offset path's
  `reinterpret<uint64>` does anyway.
- **Read-modify-write** (`p->f += x`, `p->f++`) evaluates the base once: when it is not a
  plain name, the prototype binds the typed pointer (`var t : S? = ...`) instead of the
  raw `uint64` address.
- **Aliasing.**  The daslang LLVM backend attaches no TBAA to field or index access (only
  the `noalias` hints), and the AOT C++ is built with `-fno-strict-aliasing`, so a C
  program that reaches the same bytes through two record types is compiled the same way
  in both spellings.

## 5. What would change in the owners

- `layout.rs`: a query `record_has_proven_layout(record)` = natural struct (today's
  `!is_storage_backed_record`) *and* no zero-sized field (fixing the empty-struct case in
  `natural_layout_of`), plus the per-record layout facts the proof prints.  It stays the
  sole owner of the numbers; the proof is its output, not a second model.
- `structs_unions.rs` and the typedef path in `mod.rs`: one struct builder instead of
  two, which never drops a field (`filter_map(.ok()?)` becomes a diagnostic), and which
  registers the record for the proof.
- `mod.rs` module assembly: emit the proof function once, with the other module-wide
  declarations (it is a module fact, like `unsafe_deref`).
- `object_memory.rs`: `CObjectAddress` carries an optional named path from a typed record
  pointer; `field_address` extends it while every record on the path is proven and the
  field is not a bitfield; `raw_load`/`raw_store` of a scalar or pointer leaf spell the
  path; `materialize_address` binds the typed base.  Addresses (`&p->f`, array decay),
  aggregate copies, storage-backed and bitfield paths keep the byte form.
- `abi.rs`: unchanged, apart from the `const`-stripping base reinterpret above (a pointer
  conversion, so it belongs there).  Follow-up it enables: a call argument or
  `reinterpret` of a field whose daslang type is now known (`reinterpret<uint8?>(self.bytes)`
  where `bytes : uint8?`) could be elided by `abi_pointer_cast_from`.
- `das_ast`: `TypeInfo` subtrait (section 2).

Fixtures (each a distinguishing C case, per `REVIEW.md`):

1. `p103-field-by-name`: loads, stores, RMW, `->` chains through nested proven records,
   `const S *`, a record pointer produced by a call (base evaluated once); Rust assertion
   that the output contains `p.f` and no byte offset for those sites, plus runtime
   equality with C.
2. `p104-field-by-offset-kept`: the same accesses on a union, a record containing a union,
   a bitfield record, `packed`, `alignas`, a flexible array member, `&p->f`, `p->arr[i]` —
   all still byte-addressed.
3. `n10-layout-proof-empty-struct`: the `WithEmpty` program above must not translate
   into something that runs with the wrong answer: either the translator refuses the
   record (source-located diagnostic) or daslang's proof fails compilation.
4. Architecture test: a source invariant that the proof function is emitted for every
   record the named path uses (no named access without an assertion).

Proposed amendment to `LAWS.md`:

> ## 2026-09 — Named field access requires a daslang-checked layout proof
>
> A daScript struct still does not prove a C layout by itself.  A pointer field access
> may be spelled `p.field` only for a record `layout.rs` reports as proven, and only
> when the module carries, for that record, `static_assert`s that daslang's `sizeof`,
> `alignof` and every field's `offsetof` equal Clang's; daslang evaluates them at
> compile time in every run mode, so a divergence fails the build.  Unions, bitfields,
> packed or over-aligned records, storage-backed records, flexible array members,
> addresses of fields and aggregate copies stay on `object_memory.rs` byte offsets.

## 6. Measurement

Prototype: the object-memory change of section 5 (named path, proof function, `const`
base) behind an environment switch, so baseline and prototype came from one translator
binary; with the switch off the output is byte-identical to master.  Driver:
`python3 scripts/corpus_matrix.py bench --case <id> --output <scratch>` (warm-up + 5
runs per variant, per-frame / per-value hashes checked against C on every run), three
rounds, each case run base→proto in rounds 1–2 and proto→base in round 3.  Every one of
the 18 documents reports "hashes match C in all modes", including the `+ unsafe_deref`
rows.  One translation per variant is shared by interp, jit and exe; aot is the recipe's
second translation (`--no-solid-context --das-option disable_auto_inline`), with the same
switch.

Machine: 16 threads, otherwise idle apart from other interactive sessions (load average
1.0–2.1 during the runs).  Round 1's h264bsd prototype document caught a load spike
(its C `-O3 -march=native` row read 98 ms against 76 ms in every other run), so the
C native reference below is the median of **all six** runs of that same C binary per
case, not each document's own row.  Cells: median of the three per-round medians; ratio
to C `-O3 -march=native`; change of the prototype against the baseline.

| mode | pl_mpeg 320×240 | h264bsd 640×360 | wasm3 fib32 (micro) |
|---|---|---|---|
| C `-O3 -march=native`, ms | 34.18 | 76.36 | 1.92 |
| interp | 1815.8 → 1758.1 ms, 53.1× → 51.4×, **−3.2 %** | 5729.7 → 5525.0 ms, 75.0× → 72.4×, **−3.6 %** | 138.4 → 132.7 ms, 72.1× → 69.1×, **−4.1 %** |
| jit | 36.54 → 36.52 ms, 1.07× → 1.07×, −0.0 % | 79.23 → 78.39 ms, 1.04× → 1.03×, −1.1 % | 4.60 → 4.55 ms, 2.40× → 2.37×, −1.1 % |
| exe | 38.48 → 38.44 ms, 1.13× → 1.12×, −0.1 % | 79.22 → 78.64 ms, 1.04× → 1.03×, −0.7 % | 4.40 → 4.33 ms, 2.29× → 2.25×, −1.6 % |
| aot\* | 40.58 → 40.20 ms, 1.19× → 1.18×, −0.9 % | 91.03 → 90.95 ms, 1.19× → 1.19×, −0.1 % | 2.85 → 2.73 ms, 1.49× → 1.42×, −4.3 % |
| jit + unsafe_deref | 37.10 → 36.35 ms, −2.0 % | 76.23 → 76.10 ms, −0.2 % | 4.48 → 4.44 ms, −0.8 % |
| exe + unsafe_deref | 38.59 → 38.16 ms, −1.1 % | 75.73 → 75.12 ms, −0.8 % | 4.42 → 4.39 ms, −0.7 % |
| aot + unsafe_deref\* | 40.39 → 40.14 ms, −0.6 % | 91.30 → 91.16 ms, −0.1 % | 2.53 → 2.39 ms, −5.5 % |

\* aot is a different translation from the other modes, as in `docs/corpus-benchmark.md`.
wasm3 fib32 is a micro-case (≈ 2 ms of work, a single interpreter dispatch loop); its
aot −4 % / −6 % is not a conclusion about programs.

Noise: the same C binary moved by up to 5.8 % between documents of one case, and single
daslang rows by up to 5 % between rounds (pl_mpeg `exe + unsafe_deref` 38.6 / 41.2 /
38.4 ms in the baseline).  To separate a real effect from that, a pinned, interleaved A/B
of the jit and exe decode loops (same two modules, `taskset -c 6`, 15 alternating runs
each, frame hashes identical in all 120 runs):

| | base median (min) | proto median (min) | change |
|---|---|---|---|
| pl_mpeg jit | 36.88 (36.62) ms | 36.85 (36.58) ms | −0.1 % |
| pl_mpeg exe | 39.08 (38.65) ms | 39.00 (38.64) ms | −0.2 % |
| h264bsd jit | 81.41 (79.72) ms | 80.70 (79.12) ms | −0.9 % |
| h264bsd exe | 80.36 (78.90) ms | 80.69 (79.46) ms | +0.4 % |

Reading: **the compiled modes do not change** (within ±1 %).  The likely reason, not
checked in the IR: LLVM reduces `reinterpret<T?>(reinterpret<uint64>(p))[k]` and `p.f`
to the same address arithmetic, and jit/exe null-check the base pointer in both.  **The
interpreter is 3–4 % faster** in the pooled medians of all three programs, but less
firmly than that suggests: 6 of the 9 case-rounds are faster (by 3–7 %), pl_mpeg round 2
and wasm3 round 3 are slower by 1.2 % and 0.3 %, and h264bsd round 1 by 4.7 % during the
load spike.  Treat it as a small interpreter gain, not a measured constant.  The
probable cause is one field-dereference node where there were two reinterpret nodes and
an index node, even though the named access adds a null check the interpreter's indexed
load does not have.

Translated module (`--libc std` bench entry, default header):

| | baseline | prototype | prototype without the proof function |
|---|---|---|---|
| pl_mpeg | 6 540 lines, 505 343 B | 6 841 lines, 486 367 B | 6 542 lines, 450 535 B (−10.8 %) |
| h264bsd | 30 947 lines, 1 401 357 B | 31 687 lines, 1 377 290 B | 30 948 lines, 1 284 672 B (−8.3 %) |
| wasm3 | 27 178 lines, 1 404 133 B | 27 736 lines, 1 366 318 B | 27 180 lines, 1 302 516 B (−7.2 %) |

`plm_buffer_read`, before:

```das
    current_byte = int(unsafe(unsafe(unsafe(reinterpret<uint8??>(unsafe(reinterpret<uint64>(self_4))))[10])[int(unsafe(unsafe(reinterpret<uint64?>(unsafe(reinterpret<uint64>(self_4))))[0]) >> 3ul)]))
    remaining = int(8ul - (unsafe(unsafe(reinterpret<uint64?>(unsafe(reinterpret<uint64>(self_4))))[0]) & 7ul))
    ...
    unsafe(unsafe(reinterpret<uint64?>(unsafe(reinterpret<uint64>(self_4))))[0]) = unsafe(unsafe(reinterpret<uint64?>(unsafe(reinterpret<uint64>(self_4))))[0]) + uint64(read)
```

after:

```das
    current_byte = int(unsafe(unsafe(reinterpret<uint8?>(self_4.bytes))[int(self_4.bit_index >> 3ul)]))
    remaining = int(8ul - (self_4.bit_index & 7ul))
    ...
    self_4.bit_index = self_4.bit_index + uint64(read)
```

(the remaining `reinterpret<uint8?>` of a `uint8?` field is the `abi.rs` follow-up of
section 5).  h264bsd `h264bsdFlushBits`, before:

```das
def h264bsdFlushBits(var pStrmData_0 : strmData_t?; var numBits_0 : uint) : uint {
    unsafe(unsafe(reinterpret<uint?>(unsafe(reinterpret<uint64>(pStrmData_0))))[6]) = unsafe(unsafe(reinterpret<uint?>(unsafe(reinterpret<uint64>(pStrmData_0))))[6]) + numBits_0
    unsafe(unsafe(reinterpret<uint?>(unsafe(reinterpret<uint64>(pStrmData_0))))[4]) = unsafe(unsafe(reinterpret<uint?>(unsafe(reinterpret<uint64>(pStrmData_0))))[6]) & 0x7u
    if (unsafe(unsafe(reinterpret<uint?>(unsafe(reinterpret<uint64>(pStrmData_0))))[6]) <= 8u * unsafe(unsafe(reinterpret<uint?>(unsafe(reinterpret<uint64>(pStrmData_0))))[5])) {
        goto label 0
    }
    return 0xffffffffu
    label 0:
    unsafe(unsafe(reinterpret<uint8??>(unsafe(reinterpret<uint64>(pStrmData_0))))[1]) = unsafe(unsafe(unsafe(reinterpret<uint8??>(unsafe(reinterpret<uint64>(pStrmData_0))))[0]) + int64(unsafe(unsafe(reinterpret<uint?>(unsafe(reinterpret<uint64>(pStrmData_0))))[6]) >> 3u))
    return 0u
}
```

after:

```das
def h264bsdFlushBits(var pStrmData_0 : strmData_t?; var numBits_0 : uint) : uint {
    pStrmData_0.strmBuffReadBits = pStrmData_0.strmBuffReadBits + numBits_0
    pStrmData_0.bitPosInWord = pStrmData_0.strmBuffReadBits & 0x7u
    if (pStrmData_0.strmBuffReadBits <= 8u * pStrmData_0.strmBuffSize) {
        goto label 0
    }
    return 0xffffffffu
    label 0:
    pStrmData_0.pStrmCurrPos = unsafe(pStrmData_0.pStrmBuffStart + int64(pStrmData_0.strmBuffReadBits >> 3u))
    return 0u
}
```

A remaining offset site, for contrast (an array field inside a proven record, h264bsd
`h264bsdDecodeVuiParameters`): `pVuiParameters.nalHrdParameters.cpbCnt = 1u` is by name,
while `pVuiParameters->nalHrdParameters.bitRateValue[0] = ...` is still
`unsafe(reinterpret<uint?>(unsafe(reinterpret<uint64>(pVuiParameters)) + 96ul))`.

## 7. Recommendation

**Go, with conditions.**  What it buys: the translated C reads as C (68–91 % of pointer
field accesses become `p.f`), modules shrink by 7–11 % before the proof lines, the
interpreter gets a little faster (3–4 % pooled, noisy) and gains a located null-pointer
exception, and — the
strongest argument — daslang is made to check the layout assumption the translator
already relies on for every natural record, which catches a silent miscompile that
exists on master (empty struct fields) and guards the typedef struct path that drops
unconvertible fields.  What it does not buy: speed in `-jit`/`-exe`/aot on the decoders
(±1 %, noise).  Nobody should sell it as a performance lever.

Conditions:

1. The proof is mandatory and complete: no named access to a record without its
   `sizeof`/`alignof`/every-`offsetof` assertions in the same module, enforced by a source
   invariant; `LAWS.md` amended as in section 5.
2. `layout.rs` owns the verdict and treats a zero-sized field as divergent; the two
   natural-struct builders become one that never drops a field.
3. Scope stays as prototyped: scalar and pointer leaves through a typed record pointer.
   Addresses of fields, fixed-array fields (`p->arr[i]`, bounds checks), aggregate copies,
   unions, bitfields, packed/aligned, storage-backed records and flexible arrays keep the
   byte path; fixed-array fields are a separate decision.
4. The `const S *` base is stripped once through `abi.rs`, and read-modify-write binds
   the typed base; both get a distinguishing fixture (section 5, fixtures 1–4).
5. Re-run `corpus_matrix.py converge` and `bench` on the real implementation; the
   prototype's numbers are this note's, not the implementation's.

Risks: the null-pointer behaviour change is visible only in the interpreter (crash →
exception) and is an improvement; a daslang change to struct layout (e.g. a new padding
rule) would now fail compilation of every translated module rather than go unnoticed,
which is the intended failure mode but makes the translator's output depend on daslang's
layout staying C-compatible; daslang's `typeinfo offsetof` has to stay available in all
modes (it is a compile-time constant today).
