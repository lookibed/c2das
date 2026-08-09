# c2rust -> c2dascript parity map

This file is the working architecture contract for c2dascript development.
Fixes must target the owning layer below, not generated text symptoms.

## Development rules

- No new generated-text normalizer rules for semantic bugs.
- No manual edits of generated `.das`.
- No snapshot accept to hide semantic drift.
- A failure must be assigned to its owning layer before code is changed.
- Every vertical block must add or update an intermediate invariant test.
- Real-world corpus drives priority; syntax tests are regression checks, not architecture.

## Real-world driver

Primary:

- `tests/manual/real-world-h264bsd-mp4`

Next corpus candidates:

- MPEG/plmpeg style streaming parser, for switch/fallthrough and byte-buffer control flow.
- SQLite/amalgamated C style corpus, for type emission, macros, anonymous structs/unions.
- Small crypto/hash corpus, for integer promotions, shifts, pointer/buffer arithmetic.

## Layer map

### CFG reconstruction

Source of truth in c2rust:

- `c2rust-transpile/src/cfg/mod.rs`
  - `Cfg::from_stmts`
  - `CfgBuilder`
  - `DeclStmtStore`
  - `StmtOrDecl::place_decls`
- `c2rust-transpile/src/cfg/relooper.rs`
  - `reloop`
  - `State::relooper`
  - `simplify_structure`
- `c2rust-transpile/src/cfg/structures.rs`
  - `structure`
  - `process_cfg`
  - `StructuredAST`

c2dascript status:

- Present:
  - `c2dascript-transpile/src/cfg/mod.rs`
  - `c2dascript-transpile/src/cfg/relooper.rs`
  - `c2dascript-transpile/src/cfg/structures.rs`
  - `loops.rs`, `multiples.rs`, `inc_cleanup.rs`
- Simplified:
  - `ExitStyle` has only `Break` and `Continue`.
  - Exit target/context is not preserved enough to distinguish loop break, switch break,
    fallthrough-to-followup, and goto-table transitions.
  - `Block` lowering currently emits `while(true)` wrappers, which is a backend workaround
    rather than a faithful CFG contract.
  - Stable label ids were added locally; this fixes collisions but is not a full c2rust port.
- Missing/weak:
  - Full c2rust exit classification discipline.
  - Intermediate tests for structured CFG before printing.
  - Switch/fallthrough invariant tests.

Current invariant:

- `DaExpr::Break` may only be emitted inside a daScript loop-compatible context.
- A switch fallthrough edge to the after-switch continuation must not lower to top-level `break`.
- CFG label emission must be deterministic and injective for reachable labels.

Current real-world failure:

- `minimp4_read` has `switch(nb)` fallthrough and no C `break`.
- c2dascript emits a top-level daScript `break`, so the bug belongs to CFG exit classification.

### Decl lifting

Source of truth in c2rust:

- `c2rust-transpile/src/cfg/mod.rs`
  - `DeclStmtStore`
  - `StmtOrDecl`
  - `place_decls`
  - `CfgBuilder::into_cfg`
- `c2rust-transpile/src/cfg/relooper.rs`
  - `reloop(..., store, ...)`
  - final `place_decls` pass

c2dascript status:

- Present:
  - `DeclStmtStore`
  - `StmtOrDecl`
  - some `place_decls` logic.
- Simplified:
  - Temp/declaration ownership is split between `WithStmts`, translator helpers, CFG blocks,
    and late normalizers.
  - Some temps are created outside a centralized decl-placement discipline.
- Missing/weak:
  - A complete "temp declaration dominates every use-site" invariant test.
  - A single registry for synthetic locals introduced by expression lowering.

Current invariant:

- Every synthetic local must have a declaration that dominates all use-sites.
- No use-site may reference a synthetic local that did not pass through decl placement.

### Expression translation

Source of truth in c2rust:

- `c2rust-transpile/src/translator/mod.rs`
  - `Translation::convert_expr`
  - `Translation::convert_stmt`
  - `Translation::convert_decl`
- `c2rust-transpile/src/translator/operators.rs`
- `c2rust-transpile/src/translator/functions.rs`
- `c2rust-transpile/src/with_stmts.rs`

c2dascript status:

- Present:
  - `translator/mod.rs`, `operators.rs`, `functions.rs`, `with_stmts.rs`.
- Simplified:
  - Some expression normalization is duplicated in translator, AST display, and old generated text
    normalizer rules.
  - Bool-to-numeric and numeric assignment policy is now partly centralized, but still has legacy
    normalizer debt.
- Missing/weak:
  - Canonical IR patterns for complex expressions before printing.
  - Tests that inspect `DaExpr`/`DaStmt` directly for all lowered expression families.

Current invariant:

- Expression lowering must produce backend-valid daScript AST, not rely on text replacement.

### Implicit/explicit casts

Source of truth in c2rust:

- `c2rust-transpile/src/translator/mod.rs`
  - `convert_cast`
  - implicit/explicit cast handling inside `convert_expr`
- `c2rust-transpile/src/convert_type.rs`

c2dascript status:

- Present:
  - Cast handling in `translator/mod.rs`.
  - daScript type conversion in `convert_type.rs`.
- Simplified:
  - daScript requires stricter operand matching, so c2rust cast rules need a backend-specific
    mediation layer rather than direct 1:1 output.
  - Pointer-target `Cast` is currently printed as `reinterpret` to satisfy daScript backend rules.
- Missing/weak:
  - A single cast policy table for C cast kind -> daScript lowering.
  - Intermediate tests for cast-kind normalization.

Current invariant:

- Bool-to-numeric cannot print as `int(bool)`/`uint(bool)`.
- Pointer-to-pointer or pointer-qualifier casts must be backend-valid `reinterpret`.
- Numeric binop operands must be backend-compatible before printing.

### Pointer/null lowering

Source of truth in c2rust:

- `c2rust-transpile/src/translator/pointers.rs`
- `c2rust-transpile/src/translator/operators.rs`
- `c2rust-transpile/src/convert_type.rs`

c2dascript status:

- Present:
  - `translator/pointers.rs`
  - pointer cases inside `operators.rs`
  - pointer type lowering in `convert_type.rs`
- Simplified:
  - c2rust raw pointer operations map to Rust pointer methods; daScript needs explicit unsafe
    backend ABI such as `i_das_ptr_add`.
  - Pointer values and numeric address values are still mixed in several paths.
- Missing/weak:
  - Complete pointer/null coercion policy.
  - Tests for pointer arithmetic, null comparison, malloc/realloc/free ABI, and pointer
    qualifier casts.

Current invariant:

- Lowered pointer arithmetic must call backend-valid ABI and return the expected pointer type.
- Null remains `null` only in pointer-typed contexts; integer/address contexts must not compare to `null`.

### Anonymous/named type emission

Source of truth in c2rust:

- `c2rust-transpile/src/convert_type.rs`
- `c2rust-transpile/src/translator/structs_unions.rs`
- `c2rust-transpile/src/translator/enums.rs`
- `c2rust-transpile/src/translator/mod.rs`
  - declaration collection/emission order

c2dascript status:

- Present:
  - `convert_type.rs`
  - `translator/structs_unions.rs`
  - `translator/enums.rs`
- Simplified:
  - Some anonymous/named handling is incomplete or relies on generated output cleanup.
  - Type alias emission is weaker than c2rust.
- Missing/weak:
  - Deterministic unique type registry.
  - Full anonymous struct/union model.
  - Tests for repeated inclusion, anonymous nested records, and multi-file aggregation.

Current invariant:

- Type emission must be deterministic and unique.
- Duplicate type emission must be fixed in type collection/emission, never by a dedup script.

### Renaming/namespaces

Source of truth in c2rust:

- `c2rust-transpile/src/renamer.rs`
- `c2rust-transpile/src/convert_type.rs`
- `c2rust-transpile/src/translator/mod.rs`

c2dascript status:

- Present:
  - `renamer.rs` with daScript keywords and prelude names.
- Simplified:
  - Namespace distinctions are thinner than c2rust.
  - Synthetic temps, local names, type names, and backend-reserved names need stronger separation.
- Missing/weak:
  - Tests for collisions between user names, synthetic names, type names, and daScript prelude.

Current invariant:

- Synthetic names must not collide with user names or daScript reserved/prelude names.

### Statement/expression normalization

Source of truth in c2rust:

- `c2rust-transpile/src/with_stmts.rs`
- `c2rust-transpile/src/cfg/mod.rs`
- `c2rust-transpile/src/cfg/inc_cleanup.rs`
- `c2rust-transpile/src/translator/operators.rs`

c2dascript status:

- Present:
  - `with_stmts.rs`
  - `cfg/inc_cleanup.rs`
  - normalization helpers in `translator/mod.rs` and `operators.rs`.
- Simplified:
  - Old generated-text normalizer still contains semantic rewrites.
  - Some AST Display code contains backend-validity repairs that should eventually move upward.
- Missing/weak:
  - Central statement/expression normalization pass with explicit invariants.
  - Tests for intermediate normalized AST.

Current invariant:

- Generated-text normalizer must shrink over time.
- New semantic fixes go into translator/CFG/type layers, not into string replacement.

## Current vertical block

Block:

- CFG reconstruction + switch/fallthrough exit classification.

Reason:

- `real-world-h264bsd-mp4/src/minimp4.das` fails because `minimp4_read` emits top-level
  `break` for a C `switch(nb)` fallthrough construct that has no C `break`.

Owning files:

- `c2dascript-transpile/src/cfg/mod.rs`
- `c2dascript-transpile/src/cfg/relooper.rs`
- `c2dascript-transpile/src/cfg/structures.rs`

Required test shape:

- Minimal C switch fallthrough fixture:
  - `switch (n) { case 4: ...; case 3: ...; case 2: ...; default: case 1: ...; } return v;`
- Intermediate assertion:
  - structured output must not contain top-level `DaExpr::Break`.
  - generated function must contain `return`.
- Backend assertion:
  - Windows `daslang.exe` accepts the generated `.das`.
