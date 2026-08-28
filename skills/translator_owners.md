# Translator owners

Before editing a lowering, read `c2dascript-transpile/src/translator/ARCHITECTURE.md`.  One owner
per semantic contract: ABI in `abi.rs`, layout in `layout.rs`, runtime in `runtime.rs`, raw objects
in `object_memory.rs`; values/operators/functions/CFG own only their documented adjacent role.
Add a source-invariant test whenever a new owner boundary could be duplicated.
