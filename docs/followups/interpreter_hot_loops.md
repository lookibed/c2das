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
  Landed on the translator side (`das_ast::fold`, "Value stores"; `translator/ARCHITECTURE.md`,
  "Module-wide policy"; `p180-value-stores`): a scalar store of a reference not rooted at a
  local is `place = T(value)` (`CastKind::Value`), so `*dest = uint8(dc_colormap[…])`,
  `ds_xstep = int(cachedxstep[y])`, `p.a = int(q.b)`.  Micro-benchmarks (20 M stores, two
  runs): `*p = q[i]` 7.6 → 6.1 ns, `*p = g` 6.5 → 5.1, `*p = param` 5.4 → 4.0,
  `g = param` 9.5 → 8.3, `p.f = q.f` through pointers 4.5 → 3.5, `p[i] = q[j]` 8.6 → 7.2.
  Not rewritten because the interpreter already fuses the copy with the local
  (`CopyRefValueLocAny`, `…_AnyPtr_Local`): `loc = q[i]`, `var x = q[i]`, `loc = g`
  (equal) and `*p = loc` 3.2 → 4.0, `g = loc` 7.3 → 8.5, `loc = s.f` 1.3 → 2.1 (worse).
  Pointers (`p = addr(*q[i])` is a wash), `bool` (no `bool(x)`) and enumerations stay.
  Statement `x += 1` / `x -= 1` is `x++` / `x--` (fused `Inc_TT`: 6.9 → 4.9 ns on a
  global, 4.0 → 3.0 through a pointer, equal on a local).  Doom's `R_MapPlane` now has its
  nine stores typed; `R_DrawColumn`/`R_DrawSpan` the two from the profile.
- **Benchmark honesty.** The C build hashes every frame too, so the ratio to C stays fair.
  But 44% of the translated `decode_us` is the harness hash, so engine gains show at about
  half their size. Time the hash separately before Doom is a headline.

## Status after the first round (commit `712474e26`)

Mappings 1–4 and pointer inductions landed. Same-batch measurement of the first and the
current translation: Doom's interpreter `decode_us` went from 6.16 s to 4.16 s (−32%).

| step | interpreter, Doom |
|---|---|
| range loops (`8b14fdbfc`) | −12% |
| bitfield structs as unit words (`4b9f032b9`) | −16% |
| direct fixed-array subscripts (`7601b22f0`) | −4% |
| typed scalar stores, `x++` (`491557d52`) | −3% |
| pointer inductions as `uint64` address mirrors (`712474e26`) | −6% |
| inline union fields, `switch` chains | 0 (readability) |

The snapshot at `712474e26` puts Doom at 35.1× C `-O3 -march=native` (was 54.8×).

## Profile 2 (2026-10-09, translator at `0fb93dde8`)

### Hash and engine measured separately

Stubbing the per-frame hash down to one pixel (`DG_NO_HASH`) on both sides separates the
harness from the engine. Medians of 3 runs:

| build | with hash | engine only | hash alone |
|---|---|---|---|
| C `-O3 -march=native` | 105.0 ms | 54.8 ms | 50.2 ms |
| daslang interpreter | 3 903 ms | 2 397 ms | 1 506 ms |
| ratio | 37× | **44×** | 30× |

- The hash is 48% of C's time and 39% of the interpreter's. The 35–37× headline blends a 44×
  engine with a 30× hash.
- The benchmark should report the engine and the hash separately before the ratio is quoted
  as Doom's.

### Where the engine's time goes

- **Cost per node:** about 1.1 ns per node evaluation, measured by removing 9 nodes per pixel
  over 64 M pixels.
- **Draw loops:**
  - `R_DrawColumn` runs about 12 nodes per pixel.
  - `R_DrawSpan` runs about 20 nodes per pixel; three single-use temporaries account for
    about 5 of them.
  - Apart from the null check (`Ptr2Ref`) and two global pointer reads, nothing in these
    loops is left unfused.
- **Rest of the engine:** a long tail, each function at 6% or less.

### Next mappings, measured on copies

| # | C shape → daslang | measured |
|---|---|---|
| 1 | single-use scalar temporaries substituted into their use (`spot = xtemp \| ytemp`) | −5.7% from `R_DrawSpan` alone |
| 2 | re-pack of a unit word (`(w>>16&0xff)<<16 \| (w>>8&0xff)<<8 \| w&0xff` → `w & 0xffffff`) | −16.9% overall, but it speeds up the harness hash only |
| 3 | libc string shims reading bytes by index | −1.2% (noise) |
| — | `--unsafe-deref` (no `Ptr2Ref`), `math::abs`, reading the word of a bitfield struct | no gain |

### What this says about the 20× target

- Engine-only Doom is at 44×.
- Even with zero nodes per pixel in the draw loops, the rest of the engine sits at about
  20×. So translator mappings alone cannot bring the interpreter to 20× engine-only on Doom
  (estimate).
- The remaining levers are on daslang's side, for example a fused node family for
  `*p = a[b[i]]` with a local address and global base pointers.
