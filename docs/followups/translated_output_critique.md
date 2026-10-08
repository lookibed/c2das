# What the translated daslang could do better: interpreter first

## Method

- Recorded 2026-10-08.
- Inputs:
  - `.c2das-out/latest/*/canonical/*.das`, translated at `a7a7045a2`;
  - daslang `c4e4906eb`: its node emitter `src/ast/ast_simulate.cpp`, `daslib/`, `examples/`.
- Micro-benchmarks in the interpreter: 20 M iterations, two runs each, nodes read with
  `options log_nodes = true`.
- Anything without a measured number is an estimate.
- Not repeated here: the mappings in [`interpreter_hot_loops.md`](interpreter_hot_loops.md)
  (range loops, bitfield structs by value, typed stores).

## Ranked findings

| # | C shape | today | proposed | sites (Doom) | measured |
|---|---|---|---|---|---|
| 1 | a field of a storage-backed record (`mo->momx`) | `reinterpret<int?>(reinterpret<uint64>(mo))[28]`, 3 nodes | `mo.momx`, one fused `PtrFieldDerefR2V` | 2 399 accesses; 32 of 132 structs | reads −46%, writes −56% |
| 2 | a subscript of a declared global array (`ceilingclip[x]`) | `addr(ceilingclip[0])[x]`: a bounds-checked `AtGlobAny` plus `PtrAt` | `ceilingclip[x]` | ≈ 1 500 | −21% |
| 3 | a small `switch` | computed `goto` into a labelled block | an `if/elif` chain; the table stays for large dense switches | 517 `goto label` | −30 to −35% |
| 4 | an array field through a pointer (`plane->top[x]`) | a fresh `uint8?` temporary at a byte offset | `plane.top[x]` | ≈ 470 temporaries | −11%, −14% with `[unsafe_deref]` |
| 5 | a pointer stepped by constants (`dest += 320`) | an `i_das_ptr_set_add` call node | an `int` index over one base | the draw loops | −17% |
| 6 | `a = b = c = v`; `x--` as a statement; `if (!--x)` | `CopyRefValue` temporaries | direct stores of `v`; `x -= 1` | 498 `c2da_postinc` | node count (estimate) |
| 7 | `__builtin_expect(!!(c), 0)` | `(!(!(c)) ? 1l : 0l) != 0` | `c` | wasm3 871, binjgb 33 | 3–4 nodes per guard (estimate) |
| 8 | `[sideeffects]` on every function | opaque to daslang's inliner, CSE and const folding | let daslang infer the effects; keep the annotation only where inference cannot see an effect | 1 082 of 1 102 | estimate: small in the interpreter, larger under JIT/AOT |
| 9 | runtime `memcpy`/`memmove`/`memcmp` | per-byte loops; `c2da_rt_take_free` scans linearly | daslang `memcpy` builtins | prelude | estimate |

## Notes

1. **Why Doom's records are storage-backed.** The one 8-byte union `actionf_t` (three function
   pointers, `d_think.h`) sits inside `thinker_t`. That drags `mobj_s`, `state_t`, `sector_t`
   and every thinker struct into storage-backed form.
   - **Proposal:** a union whose members share one size and alignment becomes a natural
     record with one storage field. The record stays byte-identical to Clang's layout, and
     the static layout proofs still apply.
   - **Leak:** `c2da_ginit_states` builds 967 `state_t` temporaries with `c2da_rt_calloc` and
     never frees them.
2. **Global array subscripts.** Applies only to the declared array object, never to a decayed
   pointer. An out-of-range index throws a located exception; `--unsafe-deref` keeps C
   semantics.  Landed (`translator/ARCHITECTURE.md`, "Subscripts of declared arrays";
   `p178-direct-array-subscripts`): `&a[i]` keeps the pointer form (`&a[N]` is one past
   the end), `--unsafe-deref` adds `hint(unsafe_range_check)`.  What Doom still indexes
   through `addr(a[0])`: element addresses (`&players[i]`, `&vissprites[128]`) and arrays
   of storage-backed records (`states`, `mobjinfo`, `playerstarts`), see note 1.
3. **Why the labelled switch is slow.** `SimNode_BlockWithLabels::eval`
   (`src/simulate/simulate.cpp:611`) tests `stopFlags` after every statement. A label directly
   before a void function's final `return` fails at run time (`jump to label 0 failed`). This
   is why the translator emits the double `return`; it is a candidate issue for the
   `lookibed/daScript` fork.  Landed (`translator/ARCHITECTURE.md`, "Control-flow back
   ends"; `p179-structured-switch-chain`): a `switch` of at most eight values without
   fall-through is an inline `if`/`elif`/`else` chain, a `break` under an `if` folded into
   the chain; the limit is measured (chain 314 ms against table 397 ms at 8 values, 520
   against 377 at 16).  Fall-through, more than eight values and a `break` the chain would
   have to copy statements for keep the label region.  Doom (`doom_bench_all.c`): 70 chains,
   22 regions; wasm3: 8 and 7.
4. **Array fields through a pointer.** C may index past a field array. The bounds check fails
   closed; `--unsafe-deref` keeps C semantics.  **Open; refuted by the corpus.**  "Fails
   closed" fails Doom itself: `pl->top[pl->maxx + 1]` and `pl->top[pl->minx - 1]` write the
   `pad2`/`pad1` fields declared around `top` for exactly that (`index out of range, 320 of
   320` in `R_DrawPlanes`), and `--unsafe-deref` with `hint(unsafe_range_check)` does not
   keep C semantics either: daslang's unchecked index scales in `uint32`
   (`SimNode_AtT::compute`), so `top[-1]` segfaults.  wasm3's `code[1]` (the struct hack)
   is the same shape.  Array fields stay on offsets; the finding waits for an unchecked
   index that computes in pointer width (a candidate issue for the `lookibed/daScript`
   fork).
6. **`CopyRefValue` stores.**  Landed in part (`das_ast::fold`, "Value stores" and
   "Increments"; `p180-value-stores`): a scalar store whose right-hand side is a reference
   not rooted at a local is `place = T(value)`, which daslang stores with `Set_TT<T>`; a
   statement `x += 1` / `x -= 1` is the fused `x++` / `x--`.  What stays: the
   `c2da_postinc`/`c2da_fresh` temporaries themselves — a local initialised from a
   reference measures the same as the value form (`CopyRefValueLocAny` is fused), so the
   remaining cost is the temporary's existence, not its copy (see
   `interpreter_hot_loops.md`, mapping 4, for the numbers).
8. **`[sideeffects]`** was added for daScript#10, where a call was wrongly treated as pure and
   dropped. Removing it needs proof that a store through a `uint64`-reinterpreted address is
   seen as a side effect.

## Readability

- **Nested wrappers:** 11 387 `unsafe(unsafe(…))` in Doom. Many `reinterpret` calls target
  the operand's own type, for example around the result of a call.
- **`var` parameters:** `var` on every parameter, even scalars never written.
- **Returns:** `return` as the last statement of every void function, plus the double `return`.
- **Loop conditions:** temporaries declared inside `while (true)` instead of a direct condition.
- **Constants:** unfolded expressions such as `uint(48 - 1)` and `12 * 35`.
- **Unused helpers:** `c2da_bool_to_uint`, `c2da_clip_uint` and the like are emitted into every
  module whether used or not.
