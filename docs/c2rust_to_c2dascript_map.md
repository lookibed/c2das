# c2rust -> c2dascript Architecture Map

This file is the working map for architecture-first development. It is not a status report for one corpus. Every fix must name the owning layer below before changing code.

## Rules

- Do not fix lost declarations, missing temporaries, or broken dominance in printers.
- Do not fix pointer/null semantics by generated-text replacement.
- Do not fix duplicate type emission by a dedup script or snapshot accept.
- Do not add corpus-specific branches in translator/core.
- New real-world failures must be grouped by owning layer before implementation.

## Layer Map

| Layer | c2rust source of truth | c2dascript current owner | Port status | Known simplification / gap |
| --- | --- | --- | --- | --- |
| CFG reconstruction | `c2rust-transpile/src/cfg/mod.rs`, `cfg/relooper.rs`, `cfg/structures.rs`, `cfg/loops.rs`, `cfg/inc_cleanup.rs` | `c2dascript-transpile/src/cfg/mod.rs`, `cfg/relooper.rs`, `cfg/structures.rs`, `cfg/loops.rs`, `cfg/inc_cleanup.rs` | Partially ported | `convert_function_body` has daScript-specific lowering and recent return coercion. Temp declaration dominance is not yet asserted by tests. For-loop entry/cond wiring was repaired reactively and needs invariant coverage. |
| Decl lifting / temp placement | `translator/mod.rs` item arrangement, `cfg/structures.rs`, `with_stmts.rs`, `rust_ast/item_store.rs` | `translator/mod.rs`, `with_stmts.rs`, `cfg/structures.rs`, `das_ast` declarations | Weak / incomplete | Synthetic locals can be introduced in multiple places (`lower_bool_numeric_cast_arg`, assignment lowering, call lowering). There is no single verifier that every temp dominates every use-site. |
| Expression translation | `translator/mod.rs`, `translator/functions.rs`, `translator/operators.rs`, `translator/named_references.rs` | Same c2dascript paths plus `das_ast/src/expr.rs` printer | Broad but uneven | Several daScript backend rules live in printer or late normalizers. Function-value references and call ordering were handled after real-world failures, not from a full call/value model. C function pointer calls currently use a backend-valid default-result fallback instead of typed callback ABI support; this is intentional tracked debt, not a final model. |
| Implicit / explicit casts | `translator/mod.rs`, `translator/operators.rs`, `convert_type.rs`, `translator/pointers.rs`, `translator/enums.rs` | Same c2dascript paths | In progress | Integer promotions, shift result typing, bool-to-numeric lowering, and pointer/integer mediation are spread across call args, assignment, return, and operator code. Needs one cast policy table and tests against intermediate AST/text fragments. |
| Pointer / null lowering | `translator/pointers.rs`, `translator/operators.rs`, `translator/named_references.rs`, `convert_type.rs` | Same c2dascript paths | In progress | daScript has explicit `unsafe`/pointer restrictions. Current code still mixes pointer semantic values, nullable pointers, and `uint64` address-like values. Pointer-index unsafe placement had printer-level fixes and needs owning-layer tests. |
| C runtime / libc compatibility | `translator/builtins.rs`, libc call handling in `translator/functions.rs`, runtime shims emitted by c2rust support code | `translator/functions.rs`, `translator/mod.rs::c2da_runtime_helpers`, `translator/builtins.rs` | Early vertical block | daScript only has a small subset of libc-like builtins. Missing calls such as `memchr`, `memset`, `strdup`, and `strlen` must lower through typed runtime helpers and call-argument policy, not generated text replacement. Current helper semantics are conservative and backend-valid; full memory semantics remain future work. |
| Anonymous / named type emission | `translator/structs_unions.rs`, `translator/enums.rs`, `convert_type.rs`, `translator/mod.rs` type arrangement | Same c2dascript paths | Partially ported | Anonymous typedef-backed structs are handled, but deterministic uniqueness/emission order is not enforced by a registry invariant test. Builtin typedef aliases are skipped ad hoc. |
| Renaming / namespaces | `renamer.rs`, `translator/mod.rs` name declaration, `rust_ast/item_store.rs` | `renamer.rs`, `translator/mod.rs`, `das_ast` names | Basic | daScript keyword hygiene exists, but namespaces for type/global/local/synthetic names are not separately audited. |
| Statement / expression normalization | `translator/mod.rs` normalization, `cfg/inc_cleanup.rs`, `cfg/structures.rs` | typed lowering, `with_stmts.rs`, `cfg/inc_cleanup.rs`, `cfg/structures.rs`, `das_ast/src/expr.rs` | In progress | The post-render rewrite block was removed. Semantic normalization belongs to typed lowering/CFG; printer output is never rewritten. See `docs/post-render-inventory.md`. |

## Intermediate Invariants

These invariants must become tests as the owning layers are rebuilt.

1. Every synthetic temporary has a single declaration that dominates every use-site in the lowered statement list.
2. Every `WithStmts` value entering CFG either materializes its statements before the value use, or is rejected by an invariant test.
3. Every pointer/null comparison lowers to a daScript-valid canonical form before printing.
4. Every pointer index operation is represented as an unsafe index operation, not merely an unsafe pointer operand.
5. Every binary numeric operation has backend-valid operand types and a backend-valid result type matching the C expression type.
6. Every bool-to-numeric conversion lowers to statement-safe daScript form when the backend does not allow `int(bool)`.
7. Anonymous type emission is deterministic and unique by semantic identity, not by traversal accident.
8. Function values are ordered or represented so that value references never depend on later declarations.
9. Printer code must only print AST semantics. It must not infer or repair semantic type/null/temp bugs.
10. Every C runtime call either maps to a known daScript builtin with backend-valid argument types, or to a typed `c2da_*` runtime helper emitted before user declarations.
11. Every C function pointer call must lower to backend-valid daScript. Until typed callback ABI support exists, call lowering must not emit `invoke(function?)`; it must preserve side-effecting argument evaluation and return the C return type default initializer.

## Real-World Driver

Primary corpus:

- `tests/manual/real-world-h264bsd-mp4`

Secondary corpus currently present:

- `tests/manual/real-world-plmpeg-stream`

Missing corpus slot:

- Add at least one more heavy fixture with a different profile before treating real-world coverage as broad. Candidates should stress callbacks, structs/unions, pointer arithmetic, and multi-TU ordering.

## Current Vertical Blocks

1. Decl placement / temp lifetime
   - Source truth: `c2rust` CFG + `WithStmts` + item/stmt arrangement discipline.
   - c2dascript task: inventory every synthetic temp producer and route it through one declaration-placement policy.
   - Required tests: temp dominance after bool-to-int lowering, chained assignment, function-call argument lowering, pointer arithmetic.

2. Type lowering / cast policy
   - Source truth: `c2rust` conversion paths in `translator/mod.rs`, `operators.rs`, `convert_type.rs`.
   - c2dascript task: centralize daScript operator/cast policy instead of local printer fixes.
   - Required tests: shift result type, bitwise result type, `uint == int literal`, function argument coercion, assignment to declared target type.

3. Pointer/null policy
   - Source truth: `c2rust` `pointers.rs`, `named_references.rs`, pointer casts in `translator/mod.rs`.
   - c2dascript task: define canonical internal forms for nullable pointer, raw address, function pointer, and null.
   - Required tests: `malloc == null`, `return null`, pointer index unsafe, address-of/deref cancellation.

4. C runtime / libc compatibility
   - Source truth: c2rust builtin/libc call translation and runtime support emission.
   - c2dascript task: centralize libc function-name routing, pointer argument coercion, unsafe call wrapping, and typed helper emission.
   - Required tests: missing libc helpers (`memchr`, `memset`, `strdup`, `strlen`), daScript builtin libc calls (`memcpy`, `memcmp`), pointer return values, size argument lowering to `int`.

5. Function pointer / callback ABI
   - Source truth: c2rust call translation, function pointer type lowering, and closure/function value representation.
   - c2dascript task: replace the current default-result fallback with a real typed callback representation once daScript function type syntax and nullable callback invocation policy are encoded in `DaType` and call lowering.
   - Required tests: struct-field callback call, typedef callback call, nullable callback guard, callback return value coercion, callback argument side-effect preservation.

## Render Boundary Invariant

Post-render generated-text normalizers and function-body replacements were
removed.  `DaModule::to_string()` is the terminal renderer boundary: a printer
may serialize typed AST but cannot repair semantics.  The historical inventory
and an owner/fixture-or-diagnostic obligation for each removed workaround are
in `docs/post-render-inventory.md`.
