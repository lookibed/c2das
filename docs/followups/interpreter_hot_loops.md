# Doom's hot loops in the interpreter: what the translator emits and what it should

Recorded 2026-10-08 from the daslang author's reading of the Doom renderer and the
translator's current output (`--libc std`, unity layout, commit `376cd991c`).  Every node
below is a translator mapping: a C shape and the daslang form c2das writes for it.  Nothing
here is measured yet; each mapping is measured in the interpreter before it is kept
(interpreter speed over beauty).

## The loops

Three inner loops carry most of Doom's frame time: the wall/sprite column
(`R_DrawColumn`), the floor span (`R_DrawSpan`) and their variants (fuzz, translated
colours).  Today `R_DrawColumn` comes out as:

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

`dc_colormap` and `dc_source` are already declared `uint8?` (`lighttable_t = uint8`), so the
`reinterpret<uint8?>` around them changes nothing in type and only adds work.

## Nodes: C shape → daslang form

| # | C | today | target |
|---|---|---|---|
| 1 | `do { … } while (count--);`, `count` not read in the body or after the loop | `while (true)` with a counter copy, a decrement and `if (copy == 0) break` | `for (_ in range(count + 1)) { … }` |
| 2 | `a[b[i]]`, `a` and `b` pointers to bytes | `unsafe(reinterpret<uint8?>(a))[int(unsafe(reinterpret<uint8?>(b))[i])]` | `a[int(b[i])]` with no reinterpret on an operand that already has the pointer type |
| 3 | `a[k + b[c[i]]]` (fuzz), `a[b[c[i]]]` (translated sprites) | the same wrappers, nested | node 2 applied at every level |
| 4 | `*p++ = v` | temporary copy of `p`, `unsafe { p += 1 }`, store through the copy | `*p = v` then `p += 1` |
| 5 | `*p = v; p += k` | already a store and an add | unchanged; node 4 makes 4 and 5 the same shape |
| 6 | a global pointer read in a loop that cannot write it (`dc_colormap`, `dc_source`, `ds_colormap`, `ds_source`) | read on every iteration | read once into a `let` local before the loop |

## Notes

- **Node 1 legality.** The `for` runs `count + 1` times, which matches C only when
  `count >= 0` on entry. Otherwise the C loop runs until the counter wraps. The translator
  emits the `for` only when it can see the bound is non-negative, or guards it
  (`if (count >= 0)` and keep today's loop in the else branch). Every other case keeps
  today's form.
- **Node 2 is a printer-level fact.**
  - A `reinterpret` whose source and target types are equal is dropped.
  - The `int(…)` on a byte index stays: daslang indexes with `int`.
- **Node 4** changes no evaluation order when `v` does not read or write `p`. When it does,
  today's form stays.
- **Node 6 needs whole-program facts.** The global's address is never taken, and no call
  in the loop writes it. The link pass of `--module-layout source` collects per-symbol
  facts, so that is where this is built. Unproven cases stay as they are.

## Order

1. Nodes 2 and 4: local, no analysis.
2. Node 1, then a Doom interpreter profile against today.
3. Node 6, once the link pass carries the facts.
