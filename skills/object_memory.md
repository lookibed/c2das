# Object memory

Distinguish C place, C rvalue, and raw address.  Pointer-backed field access goes through
`object_memory.rs` field address plus raw load/store; alignment determines typed access versus
copy path, and every object copy is daslang's builtin `memcpy`/`memmove` (`object_byte_copy`).
A bitfield goes through its aligned storage unit (`layout.rs bitfield_unit`); in a natural record
the unit is a daScript field of its own (`c2da_bits_<n>`, `layout.rs natural_members`), and
the bitfield is a shift and a mask on it by name (`s.c2da_bits_0`, `p.c2da_bits_0`;
`object_memory.rs bitfield_storage`), never an address or a byte copy.  A scalar or pointer leaf reached through a typed pointer to a record with a proven
layout (`layout.rs record_has_proven_layout`) is spelled `p.field` / `p.inner.field`
(`named_field_lvalue`, the only such lowering), and module assembly refuses a record named
without its `static_assert` layout proof; a `const S *` base is converted through
`abi.rs named_field_base`.  Addresses of fields, fixed-array fields, aggregate copies, bitfields
and storage-backed records stay on Clang byte offsets.  A storage-backed record field (union,
packed or bitfield struct) of a natural record is inline integer storage (`layout.rs
inline_record_storage`): its members are read through their own types at the field's address
(`inline_record_place_address`), a member of the storage's own type is the field itself, and the
record's other fields stay by-name.  A struct whose bitfields do not group into exact units
(packed, overlapping units, a unit shared with an ordinary field, unnamed bitfields) is
storage-backed; `p177` and `p151` are the fixtures.  A storage-backed object's storage is its
identity: arrays of them are one contiguous block, pointer arithmetic on them is raw and scaled by
Clang's size, and assignment or initialization copies bytes in place, never replacing a wrapper
(`translator/ARCHITECTURE.md`, "Storage-backed objects").  Aggregate rvalue copies, by-value ABI,
volatile/atomic and unfinished bitfield surfaces remain exact diagnostics until their own
canonical layer lands.
