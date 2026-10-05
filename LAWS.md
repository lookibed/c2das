# Laws and architectural decisions

## 2026-08 — Render boundary is terminal

`DaModule::to_string()` is terminal output.  String rewrites of generated `.das`, fixture-only
function-body replacement, and automatic entrypoint injection are not lowering and are banned.
Each former workaround is recorded in `docs/post-render-inventory.md` with an owner or an exact
diagnostic boundary.

## 2026-08 — C ABI facts are Clang-backed

`layout.rs` is the sole owner of `sizeof`, `alignof`, and field offsets.  `abi.rs` is the sole
owner of raw-address/pointer/null conversions.  A daScript struct does not automatically prove a
C struct layout.

## 2026-09 — Named field access requires a daslang-checked layout proof

A daScript struct still does not prove a C layout by itself.  A pointer field access may be
spelled `p.field` only for a record `layout.rs` reports as proven, and only when the module
carries, for that record, `static_assert`s that daslang's `sizeof`, `alignof` and every field's
`offsetof` equal Clang's; daslang evaluates them at compile time in every run mode, so a
divergence fails the build.  Unions, bitfields, packed or over-aligned records, storage-backed
records, flexible array members, addresses of fields, fixed-array fields and aggregate copies
stay on `object_memory.rs` byte offsets.

## 2026-10 — Structured control flow first, flat label/goto as the exact fallback

A C function body without `goto` (and without `case` labels nested below their `switch`, or
statements before the first `case`) is lowered to daslang `while`/`if`/`break`/`continue`/`return`
by `cfg/structured.rs`, straight from the C statements; every other body keeps the flat
`label`/`goto` back end (`cfg/labels.rs`), which is total.  daslang's interpreter — the only
mode on consoles — pays a block restart per taken `goto`, and the daslang author rejects flat
jump sheets as more than a proof of concept.  The choice is made per function on the C AST,
never after conversion, and the structured output is re-checked against daslang's label rules
(a jump lands in the innermost labelled block, every label has a statement after it, no early
exit is crossed); a violation is a `TranslationError`, never a guess.  The c2rust relooper
(`cfg/relooper.rs`, `cfg/structures.rs`) stays off the path: it was removed in `81e67f8d9`
for dropping edges, and this back end does not reconstruct structure from a graph at all.

## 2026-08 — Canonical runtime and object memory

Raw allocation and memory calls are declared by `runtime.rs`.  Pointer-backed C fields use
addressed loads/stores from `object_memory.rs` (spelled by name only under the 2026-09 layout
proof); unsupported aggregate ABI and volatile/atomic
surfaces diagnose rather than silently degrade.
