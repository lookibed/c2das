#!/usr/bin/env bash
set -euo pipefail

dasroot="${DASROOT:-/root/daScript}"
syntax_dir="$(cd "$(dirname "$0")" && pwd)"

for entry in \
    p17_runtime_malloc:runtime_malloc_returns_typed_pointer \
    p18_runtime_calloc_memset:runtime_calloc_and_memset_lower_to_runtime \
    p19_runtime_memory_calls:runtime_memory_calls_lower_to_runtime \
    p20_pointer_abi_edges:pointer_abi_edges \
    p21_byte_numeric:byte_numeric_edges \
    p22_typed_literals:typed_literals \
    p23_bool_numeric:bool_numeric_runtime \
    p24_nonruntime_pointer_call:nonruntime_pointer_call \
    p25_array_initializers:array_initializers_runtime
do
    test_name="${entry%%:*}"
    main_name="${entry#*:}"
    "$dasroot/bin/daslang" "$syntax_dir/$test_name.das" -main "$main_name"
done
