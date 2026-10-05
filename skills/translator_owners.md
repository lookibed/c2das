# Translator owners

Before editing a lowering, read `c2dascript-transpile/src/translator/ARCHITECTURE.md`.  One owner
per semantic contract: ABI in `abi.rs`, layout in `layout.rs`, runtime in `runtime.rs`, raw objects
in `object_memory.rs`; values/operators/functions/CFG own only their documented adjacent role.
Add a source-invariant test whenever a new owner boundary could be duplicated.
Control flow has two back ends: `cfg/structured.rs` for bodies without `goto`, `cfg/labels.rs`
(via `CfgBuilder`) for the rest; a new C statement shape is lowered by both, or
`structured::fallback_reason` sends it to the flat one.  Run with `-Wcontrol-flow` to see
which back end each function took.
