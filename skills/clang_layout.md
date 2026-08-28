# Clang layout

`layout.rs` consumes exported Clang facts for size, alignment, and field bit offsets.  It alone
normalizes aliases and handles incomplete/VLA/function diagnostics.  Never reconstruct C layout
from daScript structs, pointer width heuristics, or local arithmetic.
