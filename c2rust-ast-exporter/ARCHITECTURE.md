# Clang/CBOR exporter architecture

## 1. Process boundary

`AstExporter.cpp` owns Clang traversal and CBOR construction.  It runs only in
the `c2rust-ast-exporter` child executable.  The Rust library owns launching
that child, collecting its temporary CBOR result and translating every
non-success outcome into `ExporterFailure`.

The exporter is not memory-safe merely because its Rust caller is memory-safe.
An assertion, abort, signal or timeout in Clang/C++ belongs to the exporter
phase and must not terminate the transpiler process.

## 2. Artifact protocol

The child receives an output path and a trace path.  It writes CBOR to a
temporary sibling and atomically renames it only after a successful export.
The trace is append-only and flushes its last completed event.  It records
Clang phase transitions and every newly exported AST entry with its C source
span; this is the crash-localisation fact retained on a signal. Parent-side
validation rejects a missing, empty or malformed CBOR file as `cbor-protocol`;
it never uses a partial file. Child stdout/stderr go to temporary files rather
than pipes, so a large Clang diagnostic cannot turn a normal failure into a
false timeout.

## 3. Ownership and boundaries

`ExporterFailure` carries input identity, phase, exit code or Unix signal,
stderr and the last persisted trace event.  It is not a `TranslationError`:
there is no trustworthy C AST source location until this layer succeeds.

`c2dascript-transpile` may convert it to `TranspileError::ClangAst`, but it may
not replace it with a generic warning or continue with a partial translation.
