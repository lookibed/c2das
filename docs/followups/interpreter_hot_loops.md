# Doom in the interpreter: where the time goes and what the translator should emit

## Sources

- Recorded 2026-10-08 from the daslang author's reading of the Doom renderer.
- Interpreter profile of `doom_bench_all.das`:
  - `--libc std`, unity layout, commit `a7a7045a2`, 1000 frames;
  - `daslang --das-profiler` plus `options log_nodes = true`;
  - hand-edited copies of the generated module, medians of 3 interleaved runs, frame
    hashes checked. The baseline spread is about ±1.5%, so effects under ~3% are noise.

Every item below is a translator mapping: a C shape and the daslang form c2das writes for it.

## Where the time goes

| function | share of `decode_us` |
|---|---|
| `dg_hash_frame`: the harness's per-frame FNV hash, 64 000 pixels | ≈ 32% by profile, 44% by removal |
| `R_DrawColumn` | 14% |
| `R_DrawSpan` | 13% |
| `R_RenderSegLoop`, self | 4.5% |
| `FixedMul`, 1.7 M calls | 2.7% |

## What the nodes show

- **`do { … } while (count--)`.** Today it is `while (true)` with a counter copy, a decrement
  and `if (copy == 0) break`. That is four nodes plus a constant condition per iteration.
  `for (_ in range(n))` is one fused `ForRange` node.
- **`*dest = a[int(b[i])]`.** This becomes `SimNode_CopyRefValue`, a runtime-size memcpy of
  one byte, because the right-hand side is a reference. daslang's `sv_makeCopy` emits a typed
  `Set_TT<T>` only for a non-reference right-hand side; a same-type cast `uint8(…)` gets it.
  The same applies to `g = ptr[i]` and `g = param`.
- **Global reads are `GetGlobalR2V`.** They cost the same as a local read, so hoisting them
  into locals removes nothing.
- **The index chain is already fused.** `int(source[frac >> 16 & 127])` costs nothing extra.
- **Calls are cheap.** `FixedMul` is a `FastCall`; inlining it measured no gain.
- **A bitfield struct copied by value is expensive.** `struct color c = colors[k]` with four
  8-bit bitfields becomes:
  - a `c2da_rt_calloc` per call, never freed;
  - a `memmove` of the struct;
  - three re-reads of the same word per pixel;
  - about 36 nodes per pixel in total.

## Measured mappings

| # | C | target daslang form | measured on Doom |
|---|---|---|---|
| 1 | a small bitfield struct (≤ 8 bytes) copied into a local and only read | the word read once, fields by shift/mask; no heap storage, no `memmove` | −12% (harness hash) |
| 2 | `do { … } while (count--)`, `count` dead after the loop, `count >= 0` on entry | `for (_ in range(count + 1))` | −10.4% (two draw loops) |
| 3 | `for (i = 0; i < N; i++)`, `i` not written in the body, dead after | `for (i in range(N))` | ≈ −4.5% (estimate from the hash loop) |
| 4 | a scalar store whose right-hand side is a reference (`*p = a[i]`, `g = ptr[i]`, `g = param`) | a value right-hand side, so daslang emits `Set_TT<T>` | −4.6% from two statements (borderline); hundreds of sites |
| — | 1 + 2 + global hoist | | −20.7% |

## Not worth doing

- **Hoisting loop-invariant globals into locals:** −1.4%, within noise.
- **Inlining small functions such as `FixedMul`:** no gain.

## Notes

- **Mapping 2** keeps today's loop when it cannot see `count >= 0` on entry, or when it can
  only guard it.
- **Mapping 3:** daslang forbids shadowing, so the C local is either dropped or assigned its
  final value after the loop when it is live.
- **Mapping 4** has a cleaner fix on the daslang side: `sv_makeCopy` could use `Set_TT` with
  an R2V operand for POD references. That is a candidate for the `lookibed/daScript` fork.
- **Benchmark honesty.** The C build hashes every frame too, so the ratio to C stays fair.
  But 44% of the translated `decode_us` is the harness hash, so engine gains show at about
  half their size. Time the hash separately before Doom is a headline.

## Order

1. Mappings 2 and 3 (loops).
2. Mapping 1 (bitfield structs by value).
3. Mapping 4.
4. Re-profile after each step.
