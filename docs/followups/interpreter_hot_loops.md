# Doom's hot loops in the interpreter: translator fixes and interpreter nodes

Recorded 2026-10-08 from the daslang author's reading of the Doom renderer and the
translator's current output (`--libc std`, unity layout, commit `376cd991c`).  Nothing here
is measured yet; the measurement comes with each change.

## The loops

Three inner loops carry most of Doom's frame time: the wall/sprite column
(`R_DrawColumn`), the floor span (`R_DrawSpan`), and their variants (fuzz, translated
colours).  The translator writes `R_DrawColumn` as:

```das
while (true) {
    *dest_8 = unsafe(unsafe(reinterpret<uint8?>(dc_colormap))[int(unsafe(unsafe(reinterpret<uint8?>(dc_source))[frac_7 >> 16 & 127]))])
    unsafe { dest_8 += 320 }
    frac_7 += fracstep
    var c2da_postinc_67 : int = count_9
    count_9 -= 1
    if (c2da_postinc_67 == 0) { break }
}
```

The other drawers have the same shape:

- `R_DrawSpan`: `*dest++ = ds_colormap[ds_source[spot]]`.
- `R_DrawFuzzColumn`: `colormaps[6 * 256 + dest[fuzzoffset[fuzzpos]]]`.
- `R_DrawTranslatedColumn`: `dc_colormap[dc_translation[dc_source[..]]]`.

## Translator fixes (c2das)

1. **Counted `do { } while (count--)` → `for`.**
   - When the counter is not read inside the body or after the loop, the loop runs exactly
     `count + 1` times (for `count >= 0`). The translator can emit
     `for (_ in range(count + 1))` instead of `while (true)` with a counter copy and a `break`.
   - It must fail back to today's form when `count` can be negative, is read in the body, or
     is live after the loop.
   - This belongs to the C-idiom recognition ("shapes") work.
2. **`*p++ = v` without a temporary.**
   - Today the post-increment becomes a counter copy, an `unsafe` add, and a store.
   - Emit the store through `p`, then advance `p`. This needs no evaluation-order change,
     because `v` does not read `p`.
3. **Loop-invariant global reads.**
   - `dc_colormap`, `dc_source`, `ds_colormap` and `ds_source` are re-read on every iteration.
   - They can be read once before the loop into locals, but only when nothing in the loop can
     write them.
   - The proof needs whole-program facts: the global's address is never taken, and no call
     in the loop writes it. The link pass of `--module-layout source` collects
     per-symbol facts and is where to build this.
   - Unproven cases keep today's form.

## Interpreter nodes (daslang; proposals, not c2das code)

c2das does not modify daslang.  These go to the daslang author / the `lookibed/daScript`
fork as proposals with repros taken from `.c2das-out/latest/doomgeneric-demo1-std/`:

1. **`a[b[i]]` with byte elements through pointers.**
   - One fused node: a load through a pointer indexed by a load through a pointer, with an
     `int` index and `uint8` elements.
   - The daslang author's "one node".
   - Variants worth covering:
     - a constant added to the outer index (fuzz);
     - triple nesting (translated sprites, rare).
2. **Store and advance: `*p = v; p += k`.**
   - Present in all three loops.
   - Fix 2 above makes this shape regular enough for one node to match it.

The `for x in a` vs `for x in range(n) b += a[x]` gap (three times, per the daslang author)
has no pointer equivalent in daslang today.  Whether to add a pointer range iterator is the
author's call; fix 1 produces the `range` form either way.

## Order

1. Fixes 1 and 2 in the translator.
2. Re-profile Doom in the interpreter.
3. Send the generated loops to the daslang author for the nodes.
4. Fix 3 once the link pass exists.
