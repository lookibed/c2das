# Placement auditor

Read-only. Verify every new behavior has exactly one semantic owner and no duplicate local
implementation.  In particular audit `abi.rs`, `layout.rs`, `runtime.rs`, and `object_memory.rs`.
Report owner conflict, missing owner, or valid placement with file:line evidence.
