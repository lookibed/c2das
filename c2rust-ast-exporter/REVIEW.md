# Exporter review checklist

Any change to the Clang/CBOR boundary preserves process isolation: an exporter
abort, signal, timeout, null result, missing output or malformed CBOR reaches
the parent as `ExporterFailure`, never as a parent-process crash.

Any protocol change updates the child writer, Rust reader, architecture
contract and a test which distinguishes success, signal failure and protocol
failure.

The review must falsify pipe-backpressure, malformed non-empty CBOR, timeout,
nonzero ClangTool status and external-library deployment. A trace assertion
must include a last AST event and source span; `clang-tooling-start` alone is
not crash localisation.

The child writes only caller-provided temporary paths.  It never creates CBOR,
logs or traces beside a source input.
