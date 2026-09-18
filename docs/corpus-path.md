# Path to running h264bsd and pl_mpeg under the daslang interpreter

Decision (2026-09-10): this repository's goal is to run two concrete C code bases,
`tests/manual/h264bsd-mp4` (h264bsd + minimp4) and
`tests/manual/plmpeg-stream` (pl_mpeg), in an environment that has only the
daslang interpreter, by translating them to `.das`. The current raw-byte memory model
(`c2da_rt_*` heap, storage-backed records, Clang offsets) stays. The full C-To-DAS plan
(native daScript memory model, C-IR interchange format, daslang-side backend with
`[c_union]` / `[c_bitfields]` / `[c_function]` macros, see
https://github.com/lookibed/C-To-DAS) is a future project, probably in another repository;
it is not pursued here.

## Measured starting point

Both targets already pass the translator in strict mode with zero lowering errors:

| target | C lines | generated `.das` | translator errors | first daslang error |
|---|---|---|---|---|
| pl_mpeg.h | 4.4k | 6.4k | 0 | `T const?[2][32]`: daslang lexes `?[` as the safe-index operator |
| h264bsd + minimp4 | 23k + 3.5k | 39.7k | 0 | same, 12 occurrences |

Feature profile of the targets: no bitfields, no varargs, no `long double`; minimp4 has two
unions, one packed struct and four `goto`; floating point only in pl_mpeg; a handful of
function pointers. All of that is covered by the canonical case runner (110/112 ready
cases green at the time of writing).

The only runner-level blocker for `plmpeg-stream` is the fixture harness: `module.c`
declares and calls `c2da_rt_reset()` directly and the external-call classifier does not
recognise runtime names that the C source declares itself.

## The five steps

1. **Printer: array of pointers.** Emit `T? [N]` with a space between `?` and `[`. The
   printer currently writes `T?[N]`, which daslang parses as a safe-index expression. One
   change in `das_ast/src/type.rs` (`Display` for `DaTypeKind::Pointer` inside
   `FixedArray`); unblocks the first compile error of both targets.
2. **External-call classifier: runtime names.** A C declaration without a body whose name
   is a `c2da_rt_*` function that `runtime::declarations()` actually emits must be accepted
   as a direct call to the runtime (`reject_unknown_external_call` in
   `translator/functions.rs`). Unknown `c2da_rt_*` names stay an error.
3. **Iterate to green on the fixture oracles.** Loop: transpile, compile with daslang, fix
   the next printer/translator defect, repeat. Oracles already exist:
   `tests/manual/plmpeg-stream/run_end_to_end.sh` with
   `plmpeg_reference.expected`, and `tests/manual/h264bsd-mp4/src/test_decode.das`
   (width, height, frame_count of `fixtures/sample.mp4`). Every defect found here becomes a
   small canonical case in `tests/syntax` + `tests/canonical/cases.json` so it stays fixed.
4. **Allocator, only when it bites.** `c2da_rt_malloc` is a bump arena inside a 64 MiB
   `array<uint8>` that never reuses freed blocks (that is what `p56-heap-churn` measures).
   h264bsd and pl_mpeg allocate their picture buffers at initialisation, so this may be
   enough for the fixtures. If it is not, the interpreter has builtin `malloc`, `free` and
   `memcpy` (`module_builtin_runtime.cpp`), so the allocator can be swapped locally in
   `translator/runtime.rs` without changing the address model.
5. **Both targets in the canonical manifest.** Done for both. `plmpeg-stream` is promoted to
   `ready` (C reference `src/all_reference.c` + `src/plmpeg_reference_entry.c`, preserved
   entry `src/plmpeg_entry.das`). `h264bsd-mp4` is now wired the same way — C reference
   `src/all_reference.c` + `src/h264_reference_entry.c` recorded in `h264_reference.expected`,
   preserved entry `src/h264_entry.das` replacing the stale `test_decode.das` (which still
   requires the obsolete module name `c2da_module`) — and pins nine probes: the two
   memory-read probes, two minimp4 box names, `track_index`, `sample_count`, then `width`,
   `height` and `frame_count` at frame limit 8. It is registered as `known-red` because it
   was failing on `EXCEPTION: jump to label 20 failed` when it was added; with the `cfg`
   label fix in the tree it passes end to end (`--all-known-red` reports 1/1), so promote it
   to `ready` once that fix is committed. Both cases are now caught by
   `scripts/run_c2das_cases.py` rather than by hand.

Out of the path for now: `p56-heap-churn` (allocator, see step 4) and
`p59-nested-aggregates` (`addr()` without `unsafe` in 2-D array pointer subtraction); neither
blocks the two targets.

## What to borrow from C-To-DAS without pivoting

- The `?[` lexer trap and the `T? [N]` spelling (its feature matrix documents it).
- The "layout law": daslang's natural struct layout equals Clang's for unpacked shapes.
  We already use the comparison to decide when a record needs raw storage
  (`is_storage_backed_record` in `translator/layout.rs`).
- The callee-side copy for by-value record parameters (already implemented the same way).

## Remaining risk

Interpreter speed on h264 decoding. Measure it once the decode runs; do not optimise
before that.

## Status (2026-09-18)

Both targets decode every frame of their repository fixture with hashes identical to
the C reference in all four daslang run modes; the oracles are per frame
(`plmpeg_reference.expected`, `h264_reference.expected`, pinned again in
`tests/canonical/cases.json`), and `docs/corpus-convergence.md` and
`docs/corpus-benchmark.md` hold the current numbers. `test_decode.das` named
above is gone; `src/h264_entry.das` is the entry. Two things this path did not
foresee: the pl_mpeg harness had to stop feeding the decoder the read-only embedded
sample (`plm_video_decode` shifts its input buffer in place), and AOT needed the
translator to hoist its site temporaries above the first `goto` (`cfg/labels.rs`)
because daslang's AOT prints them as C++ declarations that a forward jump may not
bypass.
