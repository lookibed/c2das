# daslang lint over the translated corpus, and what reading the output shows

Recorded 2026-09-25 at commit `e332a31a6` (daslang `69a589623`).  The three headline
programs of `docs/corpus-benchmark.md` were translated exactly as the benchmark driver
translates them, and each module was run through the daslang MCP `lint` tool (paranoid
lint, `perf_lint` and `style_lint` together).  Every module compiled; nothing below is a
compile error.

The generated `.das` is not checked in (see `AGENTS.md`); to reproduce, translate into a
scratch directory from each fixture root:

```sh
# from tests/manual/plmpeg-stream
cargo run -q -p c2dascript-transpile -- --strict --libc std --output-dir <scratch>/plmpeg \
    --file src/plmpeg_file_bench_all.c -std=c11 -DPLM_NO_STDIO -Iinclude -Iupstream -Ifixtures -Isrc
# from tests/manual/h264bsd-mp4
cargo run -q -p c2dascript-transpile -- --strict --libc std --output-dir <scratch>/h264bsd \
    --file src/h264_file_bench_all.c -std=c11 -w -Iinclude -Iupstream/h264bsd/src -Iupstream/minimp4 -Isrc
# from tests/manual/wasm3
cargo run -q -p c2dascript-transpile -- --strict --libc std --das-option "stack = 4194304" \
    --output-dir <scratch>/wasm3 --file src/all_host_bench.c -std=c11 -Iinclude -Iupstream/wasm3/source -Isrc
```

The translated pl_mpeg module was run under `-jit` on `testsrc2_320x240.m1v` and its frame
hashes matched `tests/canonical/cases.json`; the other two were only translated and linted.

| program | lines | functions | lint findings |
|---|---:|---:|---:|
| pl_mpeg (`plmpeg_file_bench_all.das`) | 8 728 | 230 | 28 324 |
| h264bsd + minimp4 (`h264_file_bench_all.das`) | 45 534 | 441 | 37 890 |
| wasm3 (`all_host_bench.das`) | 39 684 | 899 | 11 005 |

## Findings by rule

| rule | pl_mpeg | h264bsd | wasm3 | meaning |
|---|---:|---:|---:|---|
| PERF020 | 27 905 | 34 807 | 8 138 | redundant `int(...)` over an `int`, e.g. `var PLM_BUFFER_MODE_RING : int = int(2)` |
| LINT010 | 211 | 856 | 1 953 | dead store: a variable is overwritten without an intervening read |
| STYLE024 | 5 | 1 174 | 230 | redundant `unsafe(...)` wrap |
| STYLE034 | 32 | 677 | 496 | `reinterpret<T?>(addr(x))` collapses to `addr<T?>(x)` |
| LINT024 | 6 | 281 | 3 | a 32-bit product is widened after it has already wrapped |
| STYLE018 | 2 | 2 | 95 | `== false` |
| PERF015 | 76 | 0 | 0 | ternary max, `max(a, b)` exists |
| LINT003 | 45 | 44 | 46 | `var` that can be `let` |
| PERF001 | 17 | 17 | 17 | `string +=` in a loop |
| LINT018 | 5 | 5 | 5 | `int(...)` truncates a `resize` argument above 2^31 |
| PERF003 | 4 | 4 | 4 | `character_at(s, 0)` → `first_character(s)` |
| PERF017 | 4 | 4 | 4 | `length(x) == 0` → `empty(x)` |
| STYLE013 | 0 | 9 | 0 | default-initialized `var` followed by field assignments; use a named-argument constructor |
| PERF014 | 2 | 2 | 3 | `'0'..'9'` range check → `is_number` |
| STYLE011 | 0 | 2 | 5 | declaration immediately followed by assignment |
| LINT007 | 4 | 1 | 1 | both operands of a binary operator are the same |
| STYLE016 | 2 | 2 | 2 | adjacent guards with the same early exit |
| LINT001 | 3 | 0 | 0 | unreachable code |
| LINT017 | 1 | 1 | 1 | `uint64(length(...))` widens an already-32-bit length |
| LINT014 | 0 | 0 | 2 | `var` argument never written |
| LINT002 | 0 | 1 | 0 | unused variable |
| LINT009 | 0 | 1 | 0 | `then` branch equals `else` branch |

Findings that repeat with the same count in all three modules (PERF001, PERF003, PERF017,
LINT018, LINT017, most of LINT003) come from the shared runtime prelude the translator
emits (`c2dascript-transpile/src/translator/runtime.rs`: heap, allocation table, the
printf and string families of `--libc std`), not from the translated programs.

## Checked by hand: correctness-class findings

- **LINT018 / LINT017 — real, in the runtime prelude.**  `resize(c2da_rt_heap, int(end))`,
  `resize(c2da_rt_alloc_addrs, int(record + 0x1))` (and the two sibling tables) narrow a
  `uint64` to `int`, and `uint64(length(c2da_rt_alloc_addrs))` widens a 32-bit length.  With
  today's 1 GiB heap reserve nothing overflows, but a C program whose heap passes 2^31 bytes
  would have its heap silently truncated instead of failing closed.  Fix: `int64(...)` with
  the `int64` `resize` overload and `long_length(...)`.
- **LINT024 — faithful to C.**  Example: h264bsd `row * picWidth * 256` in
  `h264bsd_image.c:204`, a `u32` product that wraps the same way in C before it is added to
  the pointer.  The translation preserves C's arithmetic; not a translator defect.
- **LINT007 / LINT009 — faithful to C.**  h264bsd `if (payload_bytes < payload_bytes)` with
  identical branches is `SKIP(payload_bytes)` expanding to `MINIMP4_MIN(payload_bytes, n)`
  (`minimp4.h:2527`) with `n == payload_bytes`.  pl_mpeg `source_scan = int(8) - int(8)` is
  `PLM_BLOCK_SET(d, di, dw, si, 8, 8, ...)` (`pl_mpeg.h:3335`, `SOURCE_WIDTH - BLOCK_SIZE`).
  The C origin of wasm3's `if (int(8) == int(8))` (`all_host_bench.das:21304`) was not
  traced; it is a constant comparison either way.
- **LINT001** (pl_mpeg): a `return` printed directly after the function's final `return`
  (see below).
- **LINT014** (wasm3 `m3_CallVL`, `m3_GetResultsVL`): the variadic argument array
  `c2da_va_args` is declared `var` but only read.

The rest — PERF020, STYLE024, STYLE034, LINT010, STYLE018, PERF015 — is noise produced by
the way the translator prints, with no semantic effect.

## Observations from reading the output (not lint findings)

Counts are occurrences in the module text.

| pattern | pl_mpeg | h264bsd | wasm3 |
|---|---:|---:|---:|
| `unsafe(unsafe(` | 3 381 | 12 980 | 8 248 |
| `unsafe(unsafe(unsafe(` | 1 371 | 4 794 | 2 195 |
| `reinterpret<` | 3 182 | 12 071 | 8 554 |
| `goto label` | 620 | 3 380 | 3 848 |
| `var c2da_freshN` temporaries | 588 | 3 622 | 2 904 |
| `int(N)` on a literal | 27 118 | 29 646 | 6 562 |
| `uint(int(N))` | 21 | 2 990 | 285 |
| `return` directly followed by `return` | 78 | 109 | 52 |
| longest line, characters | 367 420 | 128 432 | 329 983 |

1. **Struct fields are declared by name but reached by offset.**  `struct plm_t` is emitted
   with its named fields, yet `self->audio_stream_index = stream_index` becomes
   `unsafe(unsafe(unsafe(reinterpret<int?>(unsafe(unsafe(reinterpret<uint64>(self_60))))))[15]) = stream_index`,
   field 15 counted in `int` slots from the object's address; `self->video_decoder` in
   `plm_get_width` is `reinterpret<plm_video_t??>(...)[6]`.  This is the designed `->`
   lowering (`pointer_member_lvalue` in `structs_unions.rs` / `object_memory.rs`: an object
   reached through a pointer is raw C bytes), not a bug, but it means the named layout is
   never used on the hot path and the output is unreadable as daslang.  Whether a typed
   `self.audio_stream_index` would be correct under the object model and faster was not
   investigated.
2. **Pointer casts to the pointer's own type.**  `reinterpret<plm_t?>(self_49)` where
   `self_49 : plm_t?` already (`plm_init_decoders(self)` in C, no cast in the source): a
   pointer passed as-is is printed through a `reinterpret` to its own type, inside two
   `unsafe`.  Together with the `reinterpret<uint64>` address step of item 1 this gives the
   nested `unsafe(unsafe(unsafe(...)))` in the examples; which share of STYLE024/STYLE034 it
   explains was not counted.
3. **Literal casts.**  C integer literals are printed as `int(N)` even where the context is
   already `int` (PERF020), and as `uint(int(N))` for an unsigned context instead of `Nu`.
   *Addressed:* literals print in their target type, and the module fold also drops a
   conversion of a non-constant operand whose daslang type provably is the target
   (`translator/ARCHITECTURE.md`, `das_ast::fold`; fixture `p100-redundant-conversions`).
   PERF020 383 / 1 589 / 959 → 0 / 9 / 0 (the 9 are calls with a `null` argument, whose
   type the rule does not claim), PERF021 0 / 0 / 7 → 0 / 0 / 0.
4. **Condition temporaries.**  C `&&`/`||`/`?:` are lowered to a `c2da_freshN` flag set to
   0, then conditionally to 1, then tested (`plm_get_width`), and `?:` to a temporary set in
   both branches (the h264bsd `payload_bytes` case above).  These initial stores are the
   likely source of most LINT010 dead stores; the split between them and other dead stores
   was not counted.
   *Addressed:* every C comparison/`&&`/`||`/`!` was materialized as such a flag, even in a
   plain `if`.  Conditions now take the daslang `bool`, a value gets `b ? 1 : 0`, and
   `&&`/`||`/`?:` whose operands need no statements are daslang's own operators
   (`translator/ARCHITECTURE.md`, "Conditions and C's 0/1"; fixture
   `p99-direct-conditionals`).  `var c2da_freshN` 588 / 3 622 / 2 904 → 201 / 962 / 517,
   LINT010 211 / 856 / 1 953 → 171 / 585 / 1 414; `goto label` unchanged.
5. **Double `return`.**  `void` functions end in `return` directly followed by `return`
   (pl_mpeg `plm_set_audio_stream`); lint reports it as LINT001 in 3 of the 78 pl_mpeg
   places.  Where in the translator the second one is emitted was not traced.
6. **Embedded fixture data on one line.**  `sample_mpg_bytes : uint8[22929]` (pl_mpeg),
   `sample_mp4_bytes` (h264bsd) are a single `fixed_array<uint8>(uint8(0), uint8(int(1)), …)`
   line of up to 367 K characters, every byte cast twice; wasm3's longest line is one
   `M3Compilation(...)` struct literal.  Editors and diff tools choke on these.

## Order worth considering

1. Runtime prelude: 64-bit `resize` / `long_length` (LINT018/017) — the only finding that can
   change behaviour, and it should fail closed rather than truncate.  The PERF001/003/017
   fixes in the same prelude are cheap alongside it.
   *Addressed:* the prelude (`runtime.rs`, `libc.rs`, the `mod.rs` helpers) is lint-clean
   in all three modules and in a module that pulls in every `--libc std` helper.  Locals
   that are never reassigned are typed `let` (`DaStmt::Let` carries an optional type);
   text built byte by byte goes through one `build_string` builder (`DaExpr::MakeBlock`,
   `write`/`write_char`) instead of `string +=`, and printf's spelling of a specification
   is read back out of the format rather than accumulated; `repeat`, `is_alpha`,
   `is_number` and `unsafe(character_uat(...))` under the existing bound replace the
   hand-written loops, range checks and `character_at`.  The variadic argument array is a
   read-only parameter (LINT014), and a payload value already of the lane's type is not
   converted again.  Runtime fixture `p101-std-text-builders`.  Per module
   703 / 2 383 / 2 556 → 633 / 2 313 / 2 482 findings; what remains is program code.  The
   93 wasm3 STYLE018 are not prelude: a C `_Bool` operand of `&&`/`||`/`if` becomes
   `(b == true ? 1 : 0) != 0` (`abi.rs materialize_bool_as_number` →
   `mod.rs as_bool_condition`); the condition lowering could take the `_Bool` itself.
2. Printing hygiene: drop same-type `reinterpret`, collapse nested `unsafe` to one per
   expression, print literals in their target type.  This removes ≈ 95 % of all findings and
   most of the bulk of the modules.
3. Condition temporaries and the trailing `return`: emit `&&`/`||` directly where no side
   effect needs sequencing.
4. Wrap long initializer lists.

None of these is measured for performance; the JIT likely folds most of the casts already,
so the case for (2)–(4) is readability and reviewability of the output, and any change has
to keep the corpus hashes and the benchmark as gates.
