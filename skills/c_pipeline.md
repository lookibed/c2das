# C pipeline

Follow the canonical flow: Clang AST -> CBOR -> C AST -> translator -> daScript AST -> printer.
When a fact is absent or contradictory, diagnose at the earliest owner with the original C source
location.  Do not infer C semantics from rendered daScript or a fixture wrapper.
