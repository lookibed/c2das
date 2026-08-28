# Translator review obligations

Every changed reachable lowering branch needs a distinguishing C fixture.  Review must reject:

- post-render semantic repair;
- manual C layout or field-offset arithmetic outside `layout.rs`;
- raw pointer conversion outside `abi.rs`;
- any `c2da_rt_*` name table outside `runtime.rs`;
- silent aggregate fallback, union-as-ordinary-struct access, or fixture-specific replacement;
- unsupported semantics reported as successful translation.

Run the source-invariant architecture test and the narrow fixture before approving the change.
