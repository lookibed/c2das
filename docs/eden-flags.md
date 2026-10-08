# Translator flags for an EdenSpark target

**What this is.** A plan of the switches c2das needs so its output compiles and runs in the
EdenSpark editor's daslang. Written 2026-10-09; nothing here is implemented yet.

**Sources.**

- [`eden-target.md`](eden-target.md): the measured sandbox rules of EdenSpark 1.0.
- The wasm3das Eden port in the EdenSpark project
  `launcher/projects/01a0d5aa-8f9a-77c4-ab6c-0f56f3921a0e/modules/wasm3das`, branch `eden`,
  commit `b854781`. In particular:
  - `docs/eden-port/DESIGN.md`, `RESULT.md`, `BENCH_EDITOR.md`;
  - `docs/eden-abi/PLAN.md`;
  - `source/m3_exec_defs.das`;
  - `scripts/eden/sandbox.das_project`.

**How the wasm3das port differs from c2das.** The port is a hand re-expression of the
pointer port: arenas, handles and byte loads. A translator target has to produce the same
kind of code mechanically.

## Why an Eden target matters, and why interpreter speed is the whole game

- **The editor only interprets.** It runs scripts with `llvm_jit_enabled:b=no` (not
  overridable) and `aot lib size=0`. This holds in the editor and in exported builds alike
  (`eden-target.md` §3). The JIT and AOT columns of the README do not exist there; only the
  interpreter column does.
- **Running C today means interpreting wasm inside the interpreter.** The executor is
  wasm3das: C is compiled to wasm and then interpreted by wasm3das, itself interpreted by
  daslang.
  - binjgb runs at about 1 250 ms/frame in the editor, 75× over the 16.7 ms budget
    (`docs/eden-abi/PLAN.md` §2).
  - That plan names a direct translator ("Tier C") as the way out.
- **A c2das translation of the same C would be much closer to real time** (estimate, not
  measured in the editor).
  - binjgb runs at 13.5 ms/frame in the master interpreter: 4 044 ms for 300 frames, README
    snapshot at `712474e26`.
  - wasm3das paid about 1.8× for the move from raw pointers to array memory
    (`BENCH_EDITOR.md`).
  - So about 25 ms/frame is a plausible order for binjgb under an Eden memory model.
  - This is the case for doing the target at all.

## The flags

The current defaults are the master-daslang model. Every Eden switch is opt-in. A preset
`--target eden` turns on the whole set, and each switch also works alone so it can be tested
on master daslang first. In the table, a reference like "§2" points to a section of
`eden-target.md`.

| # | Flag | What it changes in the output | Eden rule it answers | c2das today |
|---|---|---|---|---|
| 1 | `--memory-model linear` | An address is an `int`/`uint` offset into one `array<uint8>` heap; NULL is 0, with the first bytes reserved. Loads and stores are `[inline]` byte helpers (`load_u32`, `store_u32`, …), shaped like wasm3das `m3_exec_defs.das`. Floats go through `math_bits`. Pointer-backed records become an offset plus Clang's field offsets. | `unsafe`, `addr`, `reinterpret`, pointer arithmetic and `intptr` are refused in every form (§2) | Raw host addresses: `c2da_rt_heap` plus `reinterpret<T?>(address)[i]`; 16 675 `unsafe` across the generated files (§5). The biggest piece of work. |
| 2 | `--locals-in-heap` (part of 1) | A local whose address is taken lives in a C stack region of the heap, with a stack pointer global, as clang's wasm lowering does. Other locals stay daslang locals. | No `addr(local)` (§2) | Uses `addr(local)` |
| 3 | `--fnptr-model table` | A function pointer is an index into a per-signature global `array<function<…>>`, filled by an init function. `c2da_relink()` refills the tables after a hot reload. Calls are `invoke(table[i], …)`. | Function values whose type mentions a struct become null on hot reload (§3; wasm3das rebuilds its op tables in `m3_NewRuntime`) | `@@f` values stored as host function values |
| 4 | `--float-compare nan-safe` | Every float comparison is guarded by a bit-test `isnan` from `math_bits`: `eq = !isnan(a) && !isnan(b) && a == b`, and so on. | NaN comparisons are not IEEE in the editor: `NaN == NaN` is true, `NaN < 1` is true (§3) | Plain `==`, `<` |
| 5 | `--libc eden` | A libc prelude with:<ul><li>no `fio`; stdout and stderr go to `print` line buffers;</li><li>files read from project assets through a host callback (`request_text` plus `get_binary_asset`); no writes;</li><li>no `exit` (the program ends by returning);</li><li>`memcpy`/`memset`/`memmove`/`memcmp` as byte loops over the heap.</li></ul> | `fio`, `network` and `jobque_boost` are refused; `memmove` is missing; `memcpy` on pointers needs `unsafe` (§2, §4, §6) | `--libc std` uses `fio` and the `memcpy`/`memmove` builtins |
| 6 | `--varargs-model heap` | Variadic arguments are written into the C stack region of the heap, as clang's wasm ABI does, instead of a daslang array literal per call. | Garbage is collected only between engine frames; a long call that allocates an array per `printf` grows towards the 100 MiB cap (§3) | `[C2daVaArg(…), …]`, an array per call |
| 7 | `--heap-reserve <bytes>` | The heap is reserved at its final size before `resize`, and the translator refuses a program whose static data plus heap exceed a set limit (default about 80 MB). | `max_unreserved_size` panics past 64 MB; the per-context heap cap is 100 MiB (§3) | Grows on demand |
| 8 | `--dialect eden-0.6.4` | Emitted syntax limited to what the editor's 0.6.4 parses, with located errors otherwise. Excluded:<ul><li>no `!` original operators;</li><li>no `@` metadata on locals;</li><li>no `memmove`;</li><li>options limited to the sandbox list: `gen2`, `indenting`, `stack`, `rtti`, `no_global_variables`, `no_aot`, `solid_context`, `strict_smart_pointers`;</li><li>no `heap_size_limit`.</li></ul> | The editor's daslang is older than master v0.6.4-481 (§1, §4) | Emits only `options gen2`, `solid_context` and case options; uses no `!` operators today, but nothing enforces it |
| 9 | `--entry eden` | No `[export] def main` with an `argv` wrapper. Instead a module API the project's `main.das` calls from `on_initialize`/`on_update` or a `[cheat]`. A frame-driven program (Doom, binjgb) exposes `init`/`tick`/framebuffer access, like wasm3das `eden/abi_*_player.das`. | Entry points are `[export] on_initialize/on_update` and `[cheat]` in the project's `main.das` (DESIGN §1) | `main` wrapper with a C `argv` |
| 10 | `--module-layout source` (exists) plus project placement | One `.das` per C file under a non-dot folder of the project. Generated scratch goes under dot-folders, which the editor skips. | The editor compiles every non-hidden `.das` in the project tree and reports only the first error of the first failing file (DESIGN §1) | `--module-layout source` exists (acyclic programs); the cyclic case is still open |
| 11 | `--no-unsafe` (check, implied by the preset) | The translator fails closed, with a source-located diagnostic, on any construct that would need `unsafe` under the other flags. The output is then also checked locally under `sandbox.das_project`. | A sandbox refusal in the editor names only the first error | No such check |

### Already compatible, no flag needed

- `goto label N` / `label N:`, including jumps out of loops.
- `try`/`recover` for traps.
- Fixed arrays as globals.
- Wrapping integer arithmetic.
- Widening of narrow integer types: c2das already never does arithmetic on `uint8`/`int16`.
- `static_let`.
- `[inline]`.

Things the target cannot fix and has to document:

- Denormals are flushed to zero in every script context (§3).
- The array length limit of 2³¹ elements.

## Order of work

1. **`--dialect eden-0.6.4` checks and `--no-unsafe` as a report only.** Translate the corpora
   and list every construct that would be refused. This gives the size of the rest of the
   work per corpus.
2. **`--memory-model linear` with `--locals-in-heap`,** proved on master daslang first.
   - Every fixture and corpus must keep its frame hashes.
   - The interpreter cost has to be measured against today's model before the flag goes
     further. wasm3das saw about 1.8×. The recent interpreter mappings (range loops, unit
     words, typed stores, address mirrors) carry over: an address mirror becomes an `int`
     index.
3. **`--fnptr-model table`, `--float-compare nan-safe`, `--libc eden`, `--varargs-model heap`,
   `--heap-reserve`.**
4. **`--entry eden`,** then an Eden host for one corpus.
   - binjgb comes first: small, 5 units, acyclic for `--module-layout source`, and a
     wasm3das baseline exists to compare against.
   - Gates:
     - the local `sandbox.das_project`;
     - frame hashes equal to C;
     - the editor itself, through the EdenSpark MCP tools (`eden_build`, the console log).
     - ms/frame in the editor against the wasm3das Tier I number.
5. **Doom** once the cyclic `--module-layout source` lands.

## Measured on master daslang (2026-10-09)

Interpreter micro-benchmarks and the local sandbox model, master daslang `c4e4906eb`.

**Cost per memory access**, in ns, including about 7 ns of loop overhead:

| access | raw pointer (today) | byte heap `array<uint8>`, global | word heap `array<uint>` |
|---|---|---|---|
| u8 load / store | 12.1 / 13.6 | **9.1 / 8.3** | 12.4 / 24.8 (read-modify-write) |
| u32 load / store | 10.4 / 14.7 | 31.8 / 32.9 | **6.7 / 9.4** |
| f64 load | 10.4 | 78.3 | 25.4 |

**What the numbers show:**
- `[inline]` helpers do inline, but each argument becomes a local. Writing the access in place
  is 25% faster on Doom's column kernel.
- A fixed global array is no faster than a global `array`.
- A heap kept as a struct field (`rt.mem`, the wasm3das way) costs 10–35% more than a module
  global.

**Kernels, linear heap against today's raw pointers:**

| kernel | byte heap, accesses in place | word heap, accesses in place | typed `new T` object |
|---|---|---|---|
| Doom `R_DrawColumn` | **1.46×** | 3.9× | — |
| binjgb-like step: `e.state.*` fields, u64 ticks | 5.4–6.2× | 2.3× | **0.96×** |

**Sandbox model check:** the byte, word and in-place forms, `new T`, `[inline]` and
`options solid_context` are all accepted. `log_nodes` and `heap_size_limit` are refused.

### Decisions this changes

- **Flag 1 uses one module-global `array<uint8>` heap,** with accesses written in place: no
  helper calls, no struct-field heap. Static data (string literals, initialised globals whose
  address is taken) is placed into that heap at start.
- **New flag 12, `--records typed`.** An allocation of a known struct type whose interior
  addresses never escape as byte pointers becomes a `new T` daslang object. Its fields stay
  typed (`p.f`), at raw speed and legal in the sandbox. Records that escape into byte memory
  keep the heap form. Without this flag binjgb is estimated at 27–54 ms/frame in the
  interpreter, over the 16.7 ms budget.
- **The local sandbox model only checks the modules its name prefixes match,** so generated
  sub-modules need their own check.

## Open questions to measure before building

- **`options solid_context` in the editor.** It is in the local sandbox model's allowed list,
  but no editor probe is recorded in the port's docs.
- **Fused interpreter nodes for array memory.** What do `rt.mem[at]`-style byte loads cost in
  the 0.6.4 editor interpreter compared with master? Do `load_u32` helpers inline (`[inline]`
  exists in both)? Or does a `uint` word heap (`array<uint>`, 4 bytes per element, aligned
  loads in one read) beat byte assembly for aligned 32-bit access? The Spider measurements
  that `PLAN.md` cites suggest memory layout matters as much as translation.
- **Calls into engine modules.** A translated program that calls engine modules
  (`engine.core`) cannot be compiled locally. The host boundary has to stay a thin
  hand-written module.
