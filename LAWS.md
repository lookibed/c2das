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

## 2026-08 — Canonical runtime and object memory

Raw allocation and memory calls are declared by `runtime.rs`.  Pointer-backed C fields use
addressed loads/stores from `object_memory.rs` (spelled by name only under the 2026-09 layout
proof); unsupported aggregate ABI and volatile/atomic
surfaces diagnose rather than silently degrade.
