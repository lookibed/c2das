# Corpus status ledger

| Corpus | Source revision | Status | Canonical case | Oracle | Acceptance gate |
|---|---|---|---|---|---|
| PLMPEG stream | `tests/manual/plmpeg-stream/UPSTREAM.md`: pl_mpeg `c871f2be` (byte-identical to the vendored header) | ready | `plmpeg-stream` in `tests/canonical/cases.json`, graph `plmpeg-target`, entry `src/all.c` | header probes + RGB hash of every decoded frame of `fixtures/sample.m1v` (11 frames, 96×64), pinned in `plmpeg_reference.expected` and `cases.json` | C reference == fresh daScript in every run mode: `docs/corpus-convergence.md` |
| h264bsd + minimp4 | `tests/manual/h264bsd-mp4/UPSTREAM.md`: h264bsd `42bcb5d7`, minimp4 `4575afb4` | ready | `h264bsd-mp4` in `tests/canonical/cases.json`, graph `h264bsd-mp4`, entry `src/all.c` | demuxer/decoder probes + YUV hash of every decoded picture of `fixtures/sample.mp4` (12 frames, 96×64), pinned in `h264_reference.expected` and `cases.json` | C reference == fresh daScript in every run mode: `docs/corpus-convergence.md` |
| PLMPEG stream, 320×240 | same pl_mpeg revision; `fixtures/testsrc2_320x240.m1v` synthesized with ffmpeg (command and sha256 in `UPSTREAM.md`) | ready | `plmpeg-stream-320x240`, same graph, file entries `src/plmpeg_file_*` reading the fixture at run time | RGB hash of every decoded frame (59 frames, 320×240, GOP 12, no B-frames), pinned in `cases.json` | same: `docs/corpus-convergence.md`, timed in `docs/corpus-benchmark.md` |
| wasm3 (interpreter core, no WASI) | `tests/manual/wasm3/UPSTREAM.md`: wasm3 `deeaca9ce` (MIT); `fixtures/fib32.wasm`, `fib64.wasm` are upstream's own test vectors | ready | `wasm3-fib32-std`: `src/all_host.c` (graph + C host over the `.wasm` named by the last argument) translated under `--libc std` with `das_options: ["stack = 4194304"]`, `program_args: fixtures/fib32.wasm` | `fib[n]=` for n in 1,2,5,10,15,20,24 plus `bytes=62` and `count=7`, pinned in `cases.json`; C reference == fresh daslang in every run mode | same: `docs/corpus-convergence.md`, timed in `docs/corpus-benchmark.md`; `docs/followups/translator_gaps_wasm3.md` has the first per-mode measurement and the story; both daslang-side issues are avoided translator-side — record order in `global_order.rs` ([#2](https://github.com/lookibed/daScript/issues/2), case `p84-struct-definition-order`) and the named pointer value in `abi.rs` ([#3](https://github.com/lookibed/daScript/issues/3), case `p85-pointer-sum-compare`); decisions on the four translator gaps still due |
| h264bsd + minimp4, 640×360 | same revisions; `fixtures/test_640x360.mp4` is upstream's `test/test_640x360.h264` muxed without re-encoding (`UPSTREAM.md`) | ready | `h264bsd-mp4-640x360`, same graph, file entries `src/h264_file_*` reading the fixture at run time | YUV hash of every decoded picture (73 pictures, 640×368 output, constrained baseline), pinned in `cases.json` | same: `docs/corpus-convergence.md`, timed in `docs/corpus-benchmark.md` |
| binjgb (Game Boy Color emulator core) | `tests/manual/binjgb/UPSTREAM.md`: binjgb `8191a5d6` (MIT); `fixtures/cgb-acid2.gbc` is Matt Currie's cgb-acid2 `v1.1` (MIT) | ready | `binjgb-cgb-acid2-std`: `src/binjgb_all.c` (graph + platform layer + C entry over the ROM named by the last argument) translated under `--libc std`, `program_args: fixtures/cgb-acid2.gbc` | cartridge header lines, RGB555 FNV-1a hash of each of 60 emulated frames (A held on frames 8–9), `frames=60`, `ticks=5378896`, pinned in `cases.json` from the clang-18 C reference | C reference == fresh daslang in every run mode: `docs/corpus-convergence.md` (last verified 2026-10-02 on top of `d2e5d6f33`); not yet timed in `docs/corpus-benchmark.md` |
| doomgeneric (Doom engine) | `tests/manual/doomgeneric/UPSTREAM.md`: doomgeneric `dcb7a8dbc` (GPL-2.0); `fixtures/doom1.wad` is the unmodified shareware 1.9 IWAD | known-red | `doomgeneric-demo1-std`: `src/doom_all.c` (engine + platform layer + C entry) under `--libc std`, `program_args: fixtures/doom1.wad`; no `corpus` block yet (see below) | RGB hash of each of the first 70 frames of `-timedemo demo1` (320×200, palette applied), pinned in `cases.json`; C `-O0` == `-O2` == `-O3 -march=native` | `-jit` matches all 70 pinned frames; the interpreter stops on a daslang defect (`jump to label 0 failed`, if-return folding moves labels into a nested block), so the case stays known-red; `corpus` block added (run only under `--case` while known-red); "doomgeneric: translation gaps" below, "Status 2026-10-02" |

The two 320×240 / 640×360 rows exist twice in `cases.json`: once over a fixture-owned
daslang entry (`plmpeg-stream-320x240`, `h264bsd-mp4-640x360`) and once as
`plmpeg-stream-320x240-std` / `h264bsd-mp4-640x360-std`, where the C entry itself
(`src/plmpeg_file_reference_entry.c`, `src/h264_file_reference_entry.c`, amalgamated with the
graph in `src/*_file_all.c`) is the translation input under `--libc std`: the translator
replaces `printf`/`fopen`/`fread`/`clock_gettime`/`argv` with daslib-backed helpers, so the
same C source is the C reference and, after translation, the daslang program, with nothing
written by hand in between.  The `-std` rows are the ones the benchmark and convergence
documents call "no hand-written entry".

Where the numbers live:

- `docs/corpus-convergence.md` — per-frame equality of every daslang run mode
  (interpreter, `-jit`, AOT, `-exe`) with the C reference, regenerated by
  `python3 scripts/corpus_matrix.py converge`; `converge --check` is the
  extended preflight gate and fails when a fresh run no longer matches the
  committed document.
- `docs/corpus-benchmark.md` — decode-loop timing of the same variants against
  the C build at `-O2` and `-O0`, regenerated by
  `python3 scripts/corpus_matrix.py bench` (5 measured runs after a warm-up).
- `docs/corpus-build-recipe.md` — every build and run command behind the benchmark
  rows (translation, C `-O2`/`-O0`, interp, jit, exe, the two-stage AOT build).
- `scripts/run_c2das_cases.py --case <id>` — the canonical runner, interpreter only.

History. Both corpora were already `ready` in the `c2das-v0.1.0` release
(2026-09-10); its notes record pl_mpeg decoding all five streams from 96×64 to
1920×1080 with identical RGB hashes and h264bsd + minimp4 decoding 8 frames at 96×64
with all nine probes equal to C. Until 2026-09-18 the repository's own oracle for
pl_mpeg was two header probes and never decoded a frame, and both graphs handed
pl_mpeg the embedded `static const` sample as its working buffer: `plm_video_decode`
memmoves consumed bytes inside that buffer, so the C reference segfaulted on the first
frame (write to read-only storage) and the daScript graph decoded once and then read
a shifted stream. `src/module.c` now copies the sample per decode session, and the
per-frame streaming probes are the oracle. The version of this ledger before that
(PLMPEG "known red" on `abi::null_pointer`, h264bsd "inventory only") predated the
promotions and was never updated.

`--all-ready` stops at the first failing case.  Until 2026-09-25 `p56-heap-churn` (a
synthetic 200 MiB heap-churn test, red in the release too) failed ahead of both corpora
in registry order, so a full-registry run never reached them; the raw heap now reuses
freed blocks inside a 1 GiB reserve (`translator/ARCHITECTURE.md`, "The raw heap"),
the case passes, and `--all-ready` runs the corpora too.

Known-red entries are never counted as successful validation or readiness. A `ready`
row is only as current as its "Last verified" cell: re-run the case and update the
cell whenever the translator, the runtime prelude or the vendored sources change.

## binjgb: translation blockers

Measured 2026-09-26 at `1173131c4`, daslang 0.6.4, clang-18.  `tests/manual/binjgb`
(`README.md` there) vendors the binjgb core unmodified; the case `binjgb-cgb-acid2-std` is
`known-red`.  `scripts/corpus_matrix.py` runs a known-red corpus case only under `--case`; the
whole-matrix runs, the committed documents and `converge --check` cover the ready cases.

The C reference (`clang-18`, `-O0`/`-O2`/`-O3 -march=native`, and `-O0` with
`-fsanitize=address,undefined`) prints the pinned oracle.  `c2dascript-transpile --strict
--libc std` translates `src/binjgb_all.c` with no error (14,613 lines, 833 KB of daslang).
daslang then rejects the module at compile time — interpreter, `-jit`, `-exe` and `daslang -aot`
alike (exit 1 / 255) — with five errors in two families.  Both are translator gaps: the C is
valid and the generated text is what daslang refuses.

**Status 2026-10-02: ready.**  B2 is fixed: reading a record object drops the place's
qualifiers (C11 6.3.2.1p2), so a record with pointer members read from a `const` place or a
read-only record parameter is read through its address converted to the unqualified record
(`abi.rs unqualified_record_value`; `*unsafe(reinterpret<FileData?>(file_data))`,
`*unsafe(addr<JoypadStateIter?>(incoming))`), fixture `p133-const-record-copy`.  The unmodified
graph matches the pinned oracle in `run_c2das_cases.py --case binjgb-cgb-acid2-std` and in all
four modes of `corpus_matrix.py converge --case binjgb-cgb-acid2-std`; the case is `ready`.

**Status 2026-10-01: B1 and B3 are fixed; B2 is the only blocker.**  After the two fixes below,
`run_c2das_cases.py --case binjgb-cgb-acid2-std` fails on exactly the three B2 errors
(`error[30915]` at `c2da_fresh368 = *file_data_3`, `error[30344]` twice for `iter` /
`iter_0`) and nothing else.  In a scratch copy with only the B2 statements rewritten (as in
"Past the two gaps" below), the interpreter and the AOT build (`daslang -aot` + `aot_host`, the
`corpus_matrix.py` recipe) both print output byte-identical to the C reference.

**Gap B1 — fixed.**  `enums.rs object_value_as_arith` / `arith_result_to_object`: every
compound assignment and `++`/`--` on an enum-typed object, plain or address-backed, reads the
enum as a conversion to the computation type and narrows the result to the enumeration's
integer type before re-reading it as the `enum` (`s.speed = unsafe(reinterpret<Speed>(uint(s.speed) ^ 1u))`).
Fixture `p120-enum-compound-assignment`.  The original gap:

**Gap B1 — compound assignment on an enum-typed lvalue.**  `lvalue ^= 1` where the lvalue has
enum type is lowered as `reinterpret<E>(lvalue ^ 1u)`: the operator is applied to the enum
value, not to its integer value.

```
error[30341]: no matching functions or generics: _::^(Speed&, uint const)
    ... = unsafe(reinterpret<Speed>(unsafe(unsafe(reinterpret<Speed?>(unsafe(reinterpret<uint64>(e_118))))[52956]) ^ 1u))
while compiling: execute_instruction(e_118: Emulator? -const): void
error[30341]: no matching functions or generics: _::^(Bool&, uint const)
    ... = unsafe(reinterpret<Bool>(unsafe(unsafe(reinterpret<Bool?>(unsafe(reinterpret<uint64>(e_118))))[3120]) ^ 1u))
```

Sites: `upstream/binjgb/src/emulator.c:4369` (`CPU_SPEED.speed ^= 1;`, `Speed`) and
`emulator.c:4144` (`#define CCF FC ^= 1; ...`, the `F.C` flag of type `Bool`, expanded in
`execute_instruction`).  Minimal reproducer (with `#include <stdio.h>`; C prints `speed=1`):

```c
typedef enum Speed { SPEED_NORMAL = 0, SPEED_DOUBLE = 1 } Speed;
typedef struct CpuSpeed { Speed speed; } CpuSpeed;
int main(void) { CpuSpeed s = {SPEED_NORMAL}; s.speed ^= 1; printf("speed=%d\n", (int)s.speed); return 0; }
```

→ `s.speed = unsafe(reinterpret<Speed>(s.speed ^ 1u))`, the same `error[30341]`.  Owner: the
compound-assignment lowering in `translator/operators.rs` with the enum conversions of
`translator/enums.rs` (C11 6.5.16.2: `E1 op= E2` is `E1 = E1 op (E2)` after the usual
arithmetic conversions, so the enum operand must be converted to its integer type first).

**Gap B2 — copying a record with pointer fields from a const source.**  The copy is emitted as a
plain daslang copy/initialization, and daslang refuses to copy a `T? const` field into a `T?`.

```
error[30915]: can only copy compatible type; FileData const&
    c2da_fresh368 = *file_data_3
	can't assign 'FileData const&.data: uint8? = uint8? const'
error[30344]: local variable iter initialization type mismatch; JoypadStateIter const
    var iter : JoypadStateIter = c2da_fresh551
	can't assign 'JoypadStateIter const.chunk: JoypadChunk? = JoypadChunk? const'
	can't assign 'JoypadStateIter const.state: JoypadState? = JoypadState? const'
error[30344]: local variable iter_0 initialization type mismatch; JoypadStateIter const
    var iter_0 : JoypadStateIter = c2da_fresh554
```

Sites: `emulator.c:4910` (`e->file_data = *file_data;` in `set_rom_file_data`, through
`const FileData *`), and the callee-side copy of a by-value record parameter at `joypad.c:140`
(`joypad_truncate_to(JoypadBuffer*, JoypadStateIter iter)`) and `joypad.c:156`
(`joypad_get_next_state(JoypadStateIter iter)`); `JoypadStateIter` holds two pointers.  Minimal
reproducer (with `#include <stdio.h>`; C prints `size=3 first=2`):

```c
typedef struct FileData { unsigned char *data; unsigned long size; } FileData;
typedef struct Holder { int tag; FileData file_data; } Holder;
static void set_file(Holder *h, const FileData *file_data) { h->file_data = *file_data; }
static FileData advance(FileData iter) { iter.data += 1; iter.size -= 1; return iter; }
int main(void) {
    static unsigned char bytes[4] = {1, 2, 3, 4};
    FileData f = {bytes, 4}; Holder h = {0, {0, 0}};
    set_file(&h, &f);
    FileData g = advance(h.file_data);
    printf("size=%lu first=%d\n", g.size, (int)g.data[0]);
    return 0;
}
```

→ `var c2da_fresh0 : FileData = *file_data` and `var iter : FileData = c2da_fresh1`, the same two
errors.  Owner: record value copies — the by-value parameter copy in `translator/functions.rs`
("C passes a record by value: the parameter is a local object") and the record assignment
through a const pointer (the temporary that is then `c2da_rt_memcpy`'d into the pointer-backed
field; not yet traced to its owner, `translator/object_memory.rs` is the candidate).  C's `const`
on the source object does not make the copied pointer members point to const.

**Past the two gaps (diagnostic, not validation).**  A scratch copy of the corpus with the three
statements rewritten (`FC = FC ? FALSE : TRUE`, the `speed` toggle as a conditional,
`set_rom_file_data` copying `data` and `size` field by field) and `joypad.c` left out of the graph
translates, and `corpus_matrix`'s own `converge_case` / `bench_case` run over it give:

| mode | 60-frame run vs C | 300-frame bench, × C `-O3 -march=native` (59.8–60.4 ms) |
|---|---|---|
| interp | byte-identical | 145× (8.78 s) |
| jit | byte-identical | 1.38× |
| exe | byte-identical | 1.41× |
| aot | C++ does not compile | — |

**Gap B3 (AOT) — a 256-case `switch` exceeds clang's bracket depth.**  `switch (cb)` at
`emulator.c:4556` (the CB-prefixed opcodes, all 256 values) becomes a flat
`if/elif` chain of 256 arms in the daslang module (maximum indentation 8); daslang's AOT prints
each `elif` as a nested `else { if ... }`, and `clang++-18` stops on the generated C++:

```
binjgb_all.das.cpp:26600:1017: fatal error: bracket nesting level exceeded maximum of 256
```

The 245-arm `switch (opcode)` at `emulator.c:4453` stays under the limit.  (The owner was the
`switch` terminator of the flat label back end, `cfg/labels.rs`; `build_switch_arm` in
`translator/mod.rs` is the statement-expression path and dead code.)

**Gap B3 — fixed.**  `cfg/labels.rs DispatchTree` (`translator/ARCHITECTURE.md`, "Switch
dispatch"): a dense case range is one bounds test and a computed `goto` into a run of label
numbers, a short run an `elif` chain of at most four arms, anything else a median split; no
form nests deeper than log n.  Both opcode switches of `execute_instruction` are now jump tables
(`goto c2da_fresh398 + 69`, `goto c2da_fresh450 + 325`), and the AOT C++ compiles.  Fixture
`p121-switch-dispatch`.  Interpreter (the owner's priority): on a probe whose hot loop is a
256-case byte switch, 1.05 s → 0.27 s best of 7 (master's elif chain vs the jump table; a median
split alone measured 3× in place of 4×).  On binjgb's own 300-frame bench entry (scratch copy
with the B2 statements rewritten, interpreter, 5 interleaved runs) the frame loop takes
8.51 s with the elif chains and 8.54 s with the jump tables, a difference inside the run-to-run
noise: cgb-acid2 halts the CPU between frames, so opcode dispatch is a small share of the
time.

Acceptance gate for promotion to `ready`: the unmodified `src/binjgb_all.c` compiles and matches
the pinned oracle in `run_c2das_cases.py --case binjgb-cgb-acid2-std` and in all four modes of
`corpus_matrix.py converge --case binjgb-cgb-acid2-std`; each gap gets a canonical case of its
reproducer when it is fixed.

## doomgeneric: translation gaps (2026-09-26, at `1173131c4`)

`tests/manual/doomgeneric` (README there) is the Doom engine through doomgeneric: 80
engine translation units, 55,700 lines of C, plus an 85-line platform layer, as one
translation unit.  The C reference is green and deterministic: the pinned 70 frame hashes
come out the same at `-O0`, `-O2` and `-O3 -march=native`, and the 1000-frame benchmark
entry agrees with them on its first 70 frames.  The translation is not: the case is
registered `known-red` and translation stops, fail-closed, on the first item below.

(Superseded 2026-10-02: `corpus_matrix.py` now runs a known-red case only under `--case`, and
the block below is in `cases.json`.)  The case carried no `corpus` block at first, on purpose:
`scripts/corpus_matrix.py` then selected every case that had one, whatever its status, so a
known-red case with the block would have turned `converge --check` and the full `bench` red.
At promotion, add

```json
"corpus": {
  "label": "doomgeneric (Doom engine), -timedemo demo1 of the shareware IWAD, C entry translated under --libc std",
  "upstream": "UPSTREAM.md",
  "fixture": "fixtures/doom1.wad",
  "bench_c_entry": "src/doom_bench_all.c",
  "bench_translation_entry": "src/doom_bench_all.c",
  "optional_translator_flags": { "unsafe_deref": ["--unsafe-deref"] },
  "headline": "doomgeneric (Doom engine), 320×200",
  "timed": "demo tick loop"
}
```

The benchmark entry is ready: `src/doom_bench_entry.c` renders 1000 frames (the 41-frame
wipe inside `doomgeneric_Create`, timed as `setup_us`, then 959 demo tics as `decode_us`);
`clang-18 -O3 -march=native` runs the tick loop in about 113 ms on the benchmark machine.

How the list was obtained.  Strict translation stops at the first failure, so items 1–9 are
the external calls of the graph (`nm -u` of the C object) that neither the `--libc std`
table (`translator/libc.rs`) nor the raw-memory runtime (`translator/runtime.rs`) provides;
1, 8 and 9 were also observed as translator diagnostics, the others were not reached.  Items
10–15 were found in a scratch copy (never committed): the items 1–9 functions defined as
static C functions behind macros in front of `src/doom_all.c`, which lets the translation
finish (a 58,125-line, 3.2 MB module), and then, to see the next daslang stage, the items
10–12 output patched by hand in a copy of the generated `.das`.  Each item from 10 on has a
standalone reproducer of a few lines that fails the same way on its own.  What lies behind
item 15 (daslang's inference stopped there) and the runtime behaviour are unknown.

| # | Stage and diagnostic | C construct | Where in the engine |
|---|---|---|---|
| 1 | translator: `unsupported external call: system` (the case's first failure, `declaration=ZenityErrorBox`) | `system(...)` | `i_system.c:342:14` (`ZenityErrorBox`), `i_system.c:274` (`ZenityAvailable`); reached only from `I_Error` |
| 2 | not in the `std` table | `mkdir(path, 0755)` | `m_misc.c:60` (`M_MakeDirectory`), called at startup from `m_config.c:2079` and `:2114` |
| 3 | not in the `std` table | `strdup` | `d_iwad.c:417, 425, 530, 652`; `d_main.c:1131`; `m_config.c:1737, 2099`; `m_misc.c:296` |
| 4 | not in the `std` table | `strcasecmp` | `d_iwad.c:401, 501`; `d_main.c:582, 701`; `i_system.c:527, 531, 535`; `m_argv.c:49`; `w_wad.c:163` |
| 5 | not in the `std` table | `strncasecmp` | `d_main.c:736, 741`; `m_misc.c:278`; `r_things.c:211`; `w_wad.c:273, 287` (lump lookup, hot at startup) |
| 6 | not in the `std` table | `sscanf` (glibc links it as `__isoc99_sscanf`) | `m_config.c:1721, 1723`; `m_misc.c:192–195` |
| 7 | not in the `std` table | `atof` | `m_config.c:1766` |
| 8 | translator: `unsupported external call: abs` (`declaration=FixedDiv`) | `abs(int)` | `m_fixed.c:49`, and 27 more sites in `g_game.c`, `p_enemy.c`, `p_map.c`, `p_maputl.c`, `r_main.c`, `r_plane.c`, `r_segs.c`, `r_things.c`, `s_sound.c` |
| 9 | translator: `unsupported external call: fabs` (`declaration=V_DrawMouseSpeedBox`) | `fabs(double)` | `v_video.c:868` |
| 10 | daslang parse: `error[20512]: structure is already defined actionf_t` (also `thinker_s`, `mobj_s`, `column_t`) | a storage-backed record (union, packed, or containing one) named through a `typedef` is emitted once per typedef visit: `typedef union { ... } actionf_t; typedef actionf_t think_t;` prints `struct actionf_t` three times; the packed `typedef struct { ... } PACKEDATTR post_t; typedef post_t column_t;` prints `struct column_t` twice and no `post_t` | `d_think.h:39–54`, `d_think.h:58–64`, `p_mobj.h:201`, `v_patch.h:40–47`.  Reproducer: `typedef union { int i; float f; } value_t; static value_t cell;` → two `struct value_t` |
| 11 | daslang parse: `error[30151]: syntax error, unexpected def` | a block-scope function declaration, `void WI_unloadData(void);` inside `WI_End`, makes the translator print the whole definition of `WI_unloadData` inside `WI_End`'s body, and nowhere at top level | `wi_stuff.c:742` (definition at `wi_stuff.c:1741`).  Reproducer: `void run(void) { void later(void); later(); } void later(void) { ... }` |
| 12 | daslang parse: `error[30151]: syntax error, unexpected ',', expecting <- or := or '='` | a compound assignment used as a call argument, `V_DrawPatch(x-=8, y, wiminus)`, printed as `V_DrawPatch(x_81 = x_81 - 8, y_71, wiminus)` | `wi_stuff.c:678`.  Reproducer: `show(x -= 8, 1);` → `show(x = x - 8, 1)` |
| 13 | daslang inference: 448 × `error[30915]: can only copy compatible type; function<void> aka actionf_v& = function<(var player:player_s? -const;var psp:pspdef_t? -const):void>` | functions declared without a prototype (`void A_Light0();`) stored into the `void (*)()` member of the `actionf_t` union by the `states[]` initializer, `{A_Light0}`; C's unprototyped function type is compatible, the translation assigns `@@A_Light0` to a `function<():void>` slot with no conversion.  The engine later calls the slot through `acp1`/`acp2` | `info.c:51–124` (declarations), `info.c:127` (`states[NUMSTATES]`), `d_think.h:39–45`.  Reproducer: `typedef void (*action_v)(); void act(); static state_t states[] = {{1, act}};` → `can't initialize field action; function<void> aka action_v = function<(var value:int? -const):void>` |
| 14 | daslang inference: 6 × `error[31014]: Uninitialized variable <name> is unsafe. Use initializer syntax or @safe_when_uninitialized when intended.` | a file-scope object of a storage-backed record type with no initializer is printed as `var x : T[N]` with no initializer | `colors` (`i_video.c:83`, a bitfield struct), `itemrespawnque` (`p_mobj.c:566`) and `playerstarts`/`deathmatchstarts` (`p_setup.c:109`, `:107`; packed `mapthing_t`), `thinkercap` (`p_tick.c:40`, holds the union), `intercepts` (`p_maputl.c:539`, holds a union).  Reproducer: `union value_u { int i; float f; }; static union value_u cell;` |
| 15 | daslang inference: `error[30177]: global variable 'S_sfx' can't be initialized with itself` | a global array whose initializer takes the address of its own element, `&S_sfx[link_id]` (the `SOUND_LINK` macro) | `sounds.c:113–116` (macro and table), first use `sounds.c:205`.  Reproducer: `static sfx_t sounds[] = {{"a", NULL}, {"b", &sounds[0]}};` |

Items 1–9 are `std` table growth of the kind `docs/followups/translator_gaps_wasm3.md`
decided for wasm3 (daslang's `fio` module has a `mkdir`; `system` needs a decision of its
own, since the engine calls it only to show an error dialog).  Items 10–15 are translator
defects in record emission (`global_order.rs` / `structs_unions.rs`), block-scope
declarations, `WithStmts` hoisting of an assignment in argument position, function-pointer
conversion (`abi.rs`), global initialisation of storage-backed records and self-referential
global initialisers; none of 10–15 has a canonical case yet, and each reproducer above is
the natural one.  One more thing to watch once the module runs: `p_maputl.c:849` converts a
`mobj_t *` to `int` for vanilla's intercepts-overrun emulation, which writes that value into
other globals when a trace crosses more than 128 intercepts; a raw daslang address differs
from a C one, so if the demo ever triggers the emulation the frame hashes can diverge for a
reason that is not a translator defect.

### Status after the libc and translator fixes (2026-09-26)

Closed, each with a canonical case:

| # | Fix | Case |
|---|---|---|
| 1–9 | `--libc std` gains `strdup`, `strcasecmp`, `strncasecmp`, `atof`, `abs`, `fabs` (sign bit cleared: exact for `-0.0` and NaN), `sscanf` (`%d %i %o %u %x %X` without width/`*`/length modifier, white space, ordinary bytes, `%%`, glibc's reading of the subject; any other directive is a source-located translation error for a literal format, a panic for a computed one), and two documented choices ISO C / POSIX permit: `system` has no command processor (`system(NULL)` is 0, a command runs nothing and returns -1 with `ENOSYS`), `mkdir` creates nothing and returns -1 with `EPERM` (daslib's `mkdir` ignores the mode and reports no `errno`; the engine ignores the result, and no `./.savegame/` is created) | `p110-std-string-extras`, `p111-std-sscanf`, `p112-std-sscanf-unsupported` |
| 11 | a block-scope function declaration emits nothing in the body; when it is the function's first (canonical) declaration, the C AST import lists it at top level in place of its file-scope definition | `p113-block-scope-function-decl` |
| 12 | a call argument is always lowered as a used value, so `V_DrawPatch(x -= 8, …)` hoists the store and passes `x` | `p114-assignment-arguments` |
| 13 | a decayed function designator whose C type (an unprototyped declaration, `void A_Light0();`) differs from the emitted function's is converted to that type (`abi_pointer_cast`); the 448 `error[30915]` are gone | `p115-unprototyped-function-values` |
| 15 | an initializer that reaches its own object — by name (`S_sfx`'s `&S_sfx[i]`) or through a call or `@@f` whose body reads it — is a cycle of one and is assigned by `[init]` (`c2da_gset_<name>`); the former exclusion of the self edge let daslang reject it with `error[30177]`, or with `error[31104]` for a table of functions that read the table | `p116-self-referencing-initializer` |

Strict translation of `src/doom_all.c` under `--libc std` now succeeds (58,320 lines).  The
first daslang failure is gap 10, verbatim:

```
error[20512]: structure is already defined actionf_t
.../generated/doom_all.das:1604:7
struct actionf_t {
       ^^^^^^^^^
```

(also `mobj_s`, `thinker_s`, `actionf_t` again, `column_t`).  With those duplicates dropped
in a scratch copy of the output (never committed), daslang stops on gap 14 only: seven
`error[31014]: Uninitialized variable <name> is unsafe` — `colors`, `itemrespawnque`,
`playerstarts`, `deathmatchstarts`, `thinkercap`, `intercepts`, and now `states`: the
`states[]` table (storage-backed, `state_t` holds the `actionf_t` union) is a cycle of one
through its `A_*` actions, which read `states`, so it is assigned by `[init]` and declared
without an initializer.  `states`'s initializer takes no element address, so replacing it in
`[init]` is sound; the general hazard — the address of a storage-backed element is its
`c2da_storage` block, which `[init]` replaces — is written down in
`translator/ARCHITECTURE.md` ("Arguments, function designators and self-referencing
globals") for whoever gives uninitialised storage-backed globals their storage.  What lies
behind gap 14 is unknown.

### Status 2026-10-02: compiles, `-jit`/AOT/`-exe` converge, the interpreter is blocked by daslang

Closed in the translator (on top of `d2e5d6f33`), each with a canonical case; the storage-backed
object model is now written down in `translator/ARCHITECTURE.md`, "Storage-backed objects: one
wrapper, one block, one identity":

| # | Fix | Case |
|---|---|---|
| 10 | a storage-backed record reached through a `typedef` (or a `typedef` of one) is one wrapper, declared once (module assembly emits one declaration per daScript type name) | `p130-typedef-storage-records` |
| 14 | a file-scope object of storage-backed type, or array of them, is declared with its zeroed storage; an array is one contiguous block whose wrappers name slices of it (`c2da_records_<T>_<dims>`); an initialised array, and a cyclic object (`states`), keep that storage and `[init]` copies the initializer's bytes in, so addresses into the object stay valid | `p131-storage-record-arrays`, `p132-storage-object-identity` |
| 16 | pointer arithmetic on a pointer to a storage-backed record stepped by the eight-byte wrapper (`filerover++` over the packed `filelump_t` WAD directory: every lump name after the first was garbage, `W_GetNumForName: S_END not found!`); it now runs on the raw address scaled by Clang's size, for `±`, `-`, `++`, `+=`; an array decays to its first element's byte address | `p131-storage-record-arrays` |
| 17 | a subscript of an array *field* of a storage-backed record (`&mtexture->patches[0]`) was read as a wrapper array and memcpy'd 10 bytes over 8 (crash in `R_InitTextures`); it is a Clang offset into the record | `p131-storage-record-arrays` |
| 18 | `s = t`, `a[i] = t` and a block-scope declaration's initializer replaced the wrapper (fresh allocation, old addresses dangling); they copy bytes into the object's storage — `dg_hash_frame`'s `struct color c = colors[...]` no longer allocates per pixel | `p132-storage-object-identity` |
| 19 | a global another initializer takes the address of (`intercepts_overrun[]` → `lowfloor`, `joybuttons = &joyarray[1]`) had no initializer, which daslang counts as "initialized after" its reader (`error[30173]`); its C zero is spelled `default<T>` | `p135-static-zero-spelled` |
| 20 | `(int) intercept->d.thing` (`p_maputl.c:849`) was `reinterpret<int>` of an 8-byte pointer, an internal error of daslang's LLVM JIT (`trunc ptr to i32`); the raw address is converted | `p134-pointer-integer-enum-conversions` |
| 21 | `skill = *demo_p++` reinterpreted a `uint8` as the 4-byte `skill_t` (demo played on skill 4, extra monsters spawned, frame 12 on diverged); the byte is converted to the enum's integer type first, and an assignment `e = *p` is no longer re-read through `reinterpret<E?>(p)` when a value conversion stands between | `p134-pointer-integer-enum-conversions` |

The case also declares `das_options: ["stack = 4194304"]` (the generated `c2da_ginit_states`
for the 967-entry table overflows daslang's default stack, `stack overflow while calling
c2da_ginit_states`) and its `corpus` block.  `corpus_matrix.py converge --case
doomgeneric-demo1-std`: **jit, aot and exe print all 70 pinned frames byte-identically**; the
interpreter stops at startup:

```
EXCEPTION: jump to label 0 failed
 at generated/doom_all.das:<line of the second if in Z_CheckHeap>
```

**Blocker: a daslang interpreter defect, not worked around.**  daslang's if-return folding
(`src/ast/ast_block_folding.cpp`, the `if (cond) {... return} b` → `if (cond) {... return}
else {b}` rewrite in `visit(ExprBlock*)`) moves the statements after the `if` — `label`s
included — into a new nested block without checking for labels; a `goto` from that block to a
label left outside (`label 0`, the loop head) then fails in `SimNode_BlockWithLabels::eval`.
The JIT is unaffected.  Pure-daslang reproducer (daslang 0.6.4, `~/daScript/bin/daslang`;
prints `3` with `-jit`, raises the exception in the interpreter):

```das
options gen2

def f(n : int) : int {
    var i : int
    label 0:
    if (i >= 3) {
        return i
    }
    if (i == 7) {
        goto label 1
    }
    label 1:
    i = i + 1
    goto label 0
}

[export]
def main() {
    print("{f(1)}\n")
}
```

Still to file on `lookibed/daScript`.  Not every such shape fails (a loop whose `goto`-target
label is not right after the `if` passes), which is why the other corpora are unaffected.
`p_maputl.c:849`'s intercepts-overrun emulation does not affect the 70 pinned frames (the
compiled modes match C).

Known residue: a hoisted storage-backed local allocates its storage once per function
activation and never releases it (a few blocks per tic in Doom); the runtime's
`c2da_rt_frame_enter`/`leave` are the intended owner.
