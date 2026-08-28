# C pipeline

Follow the canonical flow: Clang AST -> CBOR -> C AST -> translator -> daScript AST -> printer.
When a fact is absent or contradictory, diagnose at the earliest owner with the original C source
location.  Do not infer C semantics from rendered daScript or a fixture wrapper.

The Clang/CBOR exporter is an isolated process boundary.  A signal, timeout,
missing CBOR or malformed CBOR is an `ExporterFailure`, not a translator
diagnostic and never a parent-process crash.  Record its input, phase, signal
or exit status and last persisted trace event; only after exporter success may
the C AST/translator owners claim a source-located C semantic diagnostic.
