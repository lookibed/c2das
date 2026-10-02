# Object memory

Distinguish C place, C rvalue, and raw address.  Pointer-backed field access goes through
`object_memory.rs` field address plus raw load/store; alignment determines typed access versus
memcpy path.  A scalar or pointer leaf reached through a typed pointer to a record with a proven
layout (`layout.rs record_has_proven_layout`) is spelled `p.field` / `p.inner.field`
(`named_field_lvalue`, the only such lowering), and module assembly refuses a record named
without its `static_assert` layout proof; a `const S *` base is converted through
`abi.rs named_field_base`.  Addresses of fields, fixed-array fields, aggregate copies, bitfields
and storage-backed records stay on Clang byte offsets.  A storage-backed object's storage is its
identity: arrays of them are one contiguous block, pointer arithmetic on them is raw and scaled by
Clang's size, and assignment or initialization copies bytes in place, never replacing a wrapper
(`translator/ARCHITECTURE.md`, "Storage-backed objects").  Aggregate rvalue copies, by-value ABI,
volatile/atomic and unfinished bitfield surfaces remain exact diagnostics until their own
canonical layer lands.
