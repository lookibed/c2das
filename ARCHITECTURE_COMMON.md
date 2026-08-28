# Architecture common law

## Truth boundaries

Clang AST/CBOR facts own C types, source locations, and ABI layout.  daScript representation is
an output implementation, never evidence that a C record has compatible layout.

Every semantic transformation has one owner.  A caller may request an operation through its
public API but may not recreate its ABI arithmetic, type rule, or runtime declaration locally.
The printer consumes typed daScript AST only; it never repairs C semantics after rendering.

## Proof boundary

A supported path has all three: a source-level invariant, a distinguishing C fixture, and real
`daslang` execution where executable.  A green diagnostic test proves fail-closed behaviour, not
language support.  Real-world corpora are evidence only at their recorded revision and only when
their runner reaches the declared gate.
