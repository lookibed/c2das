# Object memory

Distinguish C place, C rvalue, and raw address.  Pointer-backed field access goes through
`object_memory.rs` field address plus raw load/store; alignment determines typed access versus
memcpy path.  Aggregate rvalue copies, by-value ABI, volatile/atomic and unfinished bitfield
surfaces remain exact diagnostics until their own canonical layer lands.
