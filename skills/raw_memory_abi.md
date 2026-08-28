# Raw-memory ABI

All raw-address ↔ pointer, null-pointer, and storage-byte ABI conversions use `abi.rs`.  All raw
allocations and libc memory declarations use `runtime.rs`.  Carry expected C types through the
conversion; raw `uint64` is an ABI representation, not a general C pointer value.
