use std::path::Path;

fn transpile(name: &str) -> String {
    let c_path = Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .join(format!("tests/syntax/{}.c", name));
    assert!(c_path.exists(), "C file not found: {:?}", c_path);
    let (_td, cc_path) = c2dascript_transpile::create_temp_compile_commands(&[c_path.clone()]);
    c2dascript_transpile::transpile(
        c2dascript_transpile::TranspilerConfig::default(),
        &cc_path,
        &["-w"],
    );
    let das_path = c_path.with_extension("das");
    let s = std::fs::read_to_string(&das_path).unwrap_or_default();
    eprintln!("=== {} ===\n{}", name, s);
    s
}

#[test]
fn p01_ptr_deref() {
    let d = transpile("p01_ptr_deref");
    assert!(d.contains("*") || d.contains("addr"));
}
#[test]
fn p02_ptr_assign() {
    let d = transpile("p02_ptr_assign");
    assert!(d.contains("addr"));
}
#[test]
fn p03_ptr_add() {
    let d = transpile("p03_ptr_add");
    assert!(d.contains("arr["));
}
#[test]
fn p04_arrow_basic() {
    let d = transpile("p04_arrow_basic");
    assert!(d.contains("struct Point"));
    assert!(d.contains("addr"));
}
#[test]
fn p05_arrow_chain() {
    let d = transpile("p05_arrow_chain");
    assert!(d.contains("struct"));
}
#[test]
fn p06_ptr_to_ptr() {
    let d = transpile("p06_ptr_to_ptr");
    assert!(d.contains("addr"));
}
#[test]
fn p07_ptr_arith() {
    let d = transpile("p07_ptr_arith");
    assert!(d.contains("deref") || d.contains("*p"));
}
#[test]
fn p08_arrow_func() {
    let d = transpile("p08_arrow_func");
    assert!(d.contains("struct Rect"));
    assert!(d.contains("area"));
}
#[test]
fn p09_ptr_null() {
    let d = transpile("p09_ptr_null");
    assert!(d.contains("null"));
}
#[test]
fn p10_ptr_swap() {
    let d = transpile("p10_ptr_swap");
    assert!(d.contains("def swap"));
    assert!(d.contains("var"));
}

#[test]
fn u01_unsafe_ptr() {
    let d = transpile("u01_unsafe_ptr");
    assert!(d.contains("addr") || d.contains("*x"));
}
#[test]
fn u02_unsafe_write() {
    let d = transpile("u02_unsafe_write");
    assert!(d.contains("var"));
    assert!(d.contains("*"));
}
#[test]
fn u03_unsafe_swap() {
    let d = transpile("u03_unsafe_swap");
    assert!(d.contains("def swap"));
    assert!(d.contains("var"));
}

#[test]
fn p17_runtime_malloc_uses_canonical_raw_memory_abi() {
    let d = transpile("p17_runtime_malloc");
    assert!(
        d.contains("c2da_rt_malloc(uint64("),
        "malloc calls must lower to the canonical runtime before printing"
    );
    assert!(
        !d.contains("unsafe(malloc("),
        "source malloc must not survive as the backend call target"
    );
    assert!(
        d.contains("var value : int? = null")
            && d.contains("reinterpret<int?>(c2da_rt_malloc("),
        "runtime raw address must materialize directly as the demanded int?"
    );
}

#[test]
fn p18_runtime_calloc_and_memset_use_canonical_raw_memory_abi() {
    let d = transpile("p18_runtime_calloc_memset");
    assert!(d.contains("c2da_rt_calloc(uint64(4), uint64(1))"));
    assert!(d.contains("c2da_rt_memset("));
    assert!(!d.contains("unsafe(calloc("));
    assert!(!d.contains("unsafe(memset("));
}

#[test]
fn p19_runtime_memory_calls_use_canonical_raw_memory_abi() {
    let d = transpile("p19_runtime_memory_calls");
    for runtime_name in [
        "c2da_rt_realloc(",
        "c2da_rt_free(",
        "c2da_rt_memcpy(",
        "c2da_rt_memmove(",
        "c2da_rt_memcmp(",
        "c2da_rt_memchr(",
    ] {
        assert!(d.contains(runtime_name), "missing lowered {runtime_name}");
    }
    for source_name in ["realloc(", "free(", "memcpy(", "memmove(", "memcmp(", "memchr("] {
        assert!(!d.contains(&format!("unsafe({source_name}")), "source call survived: {source_name}");
    }
}

#[test]
fn p20_pointer_abi_edges_stay_typed_outside_raw_boundaries() {
    let d = transpile("p20_pointer_abi_edges");
    assert!(d.contains("var typed : uint8?"));
    assert!(d.contains("var erased : uint8?"), "void* must stay pointer-shaped");
    assert!(d.contains("var restored : uint8?"));
    assert!(d.contains("var nil : uint8? = null"));
    assert!(!d.contains("uint8? = uint64("));
    assert!(!d.contains("cast<uint8?>(0)"));
}

#[test]
fn p21_byte_reads_are_widened_before_numeric_operations() {
    let d = transpile("p21_byte_numeric");
    assert!(d.contains("def byte_numeric_edges() : int"));
    assert!(
        d.contains("uint(left) < uint(right)"),
        "byte comparison must widen storage uint8 values to uint"
    );
    assert!(d.contains("uint("), "byte arithmetic must widen storage uint8 values");
    assert!(!d.contains("uint8? = uint64("));
}

#[test]
fn p26_variadic_sum_uses_the_canonical_packed_abi() {
    let d = transpile("p26_variadic_sum");
    assert!(d.contains("struct C2daVaArg"));
    assert!(d.contains("def sum(var count : int; var c2da_va_args : array<C2daVaArg>)"));
    assert!(d.contains("def variadic_sum_runtime() : int"));
    assert!(d.contains("C2daVaArg(tag = 1, i64 = int64(int(10))"));
    assert!(d.contains("c2da_va_item"));
    assert!(!d.contains("__builtin_va_start"));
    assert!(!d.contains("va_arg not supported"));
}

#[test]
fn p27_variadic_promotions_pack_int_and_double_lanes() {
    let d = transpile("p27_variadic_promotions");
    assert!(d.contains("def promoted_sum(var count : int; var c2da_va_args : array<C2daVaArg>) : double"));
    assert!(d.contains("C2daVaArg(tag = 1"), "integer promotions must use the integer ABI lane");
    assert!(d.contains("C2daVaArg(tag = 2"), "float must be promoted to the double ABI lane");
    assert!(d.contains("double("), "the promoted floating argument must materialize as double");
}

#[test]
fn p28_variadic_multiple_types_pack_integer_double_and_raw_lanes() {
    let d = transpile("p28_variadic_multiple_types");
    assert!(d.contains("C2daVaArg(tag = 1"));
    assert!(d.contains("C2daVaArg(tag = 2"));
    assert!(d.contains("C2daVaArg(tag = 3"));
    assert!(d.contains("reinterpret<int?>(c2da_va_item"));
}

#[test]
fn p29_variadic_function_pointer_is_diagnosed_before_printing() {
    let d = transpile("p29_variadic_function_pointer_unsupported");
    assert!(
        !d.contains("callback("),
        "unsupported indirect variadic calls must not be printed as invalid daScript"
    );
}

#[test]
fn n02_unsupported_va_arg_type_is_not_printed_as_a_fake_value() {
    let d = transpile("n02_unsupported_va_arg_type");
    assert!(
        !d.contains("def unsupported_va_arg_type"),
        "unsupported va_arg must reject the declaration, never synthesize 0/null"
    );
    assert!(!d.contains("va_arg("));
}

#[test]
fn n03_inline_asm_is_rejected_without_a_placeholder_statement() {
    let d = transpile("n03_inline_asm");
    assert!(!d.contains("def unsupported_inline_asm"));
    assert!(!d.contains("asm("));
}

#[test]
fn n04_simd_shuffle_is_rejected_without_scalar_emulation() {
    let d = transpile("n04_simd_shuffle");
    assert!(!d.contains("def unsupported_simd_shuffle"));
    assert!(!d.contains("shufflevector"));
}

#[test]
fn n05_simd_convert_is_rejected_without_scalar_emulation() {
    let d = transpile("n05_simd_convert");
    assert!(!d.contains("def unsupported_simd_convert"));
    assert!(!d.contains("convertvector"));
}

#[test]
fn n01_unsupported_builtin_is_not_silently_lowered() {
    let d = transpile("n01_unsupported_builtin");
    assert!(!d.contains("def unsupported_builtin_diagnostic"));
    assert!(!d.contains("__builtin_abs"));
}

#[test]
fn p30_macro_constant_expression_is_lowered_as_expanded_ast() {
    let d = transpile("p30_macro_constant_expression");
    assert!(d.contains("def macro_constant_expression_runtime() : int"));
    assert!(!d.contains("ADD_SCALE"));
    assert!(!d.contains("#define"));
}

#[test]
fn p31_macro_side_effect_is_not_reconstructed_from_text() {
    let d = transpile("p31_macro_side_effect");
    assert!(d.contains("def macro_side_effect_runtime() : int"));
    assert!(!d.contains("NEXT_AND_DOUBLE"));
    assert!(!d.contains("#define"));
}

#[test]
fn p32_statement_expression_uses_statement_ast_not_macro_text() {
    let d = transpile("p32_macro_statement_expression");
    assert!(d.contains("def macro_statement_expression_runtime() : int"));
    assert!(!d.contains("ACCUMULATE_ONCE"));
    assert!(!d.contains("#define"));
}

#[test]
fn p33_sizeof_and_builtin_expect_use_explicit_lowering() {
    let d = transpile("p33_predefined_sizeof_builtin");
    assert!(d.contains("def predefined_sizeof_builtin_runtime() : int"));
    assert!(!d.contains("__builtin_expect"));
    assert!(d.contains("int(12)"), "sizeof must remain a numeric AST value");
}

#[test]
fn p34_records_and_unions_use_clang_layout_facts() {
    let d = transpile("p34_c_layout_records");
    assert!(d.contains("def c_layout_records_runtime() : int"));
    assert!(d.contains("uint64(12)"), "struct size must be emitted from Clang layout");
    assert!(d.contains("uint64(4)"), "align/offsetof/union layout must be emitted from Clang layout");
    assert!(!d.contains("unsupported sizeof type layout"));
}

#[test]
fn p35_pointer_backed_struct_uses_c_field_offsets() {
    let d = transpile("p35_pointer_backed_struct");
    assert!(d.contains("def pointer_backed_struct_runtime() : int"));
    assert!(d.contains("reinterpret<uint?>(object)))[2]"),
        "padded C field must use Clang offset 8 as a uint index");
    assert!(d.contains("reinterpret<uint?>("), "field must be an address-backed typed lvalue");
}

#[test]
fn p37_union_overlay_uses_raw_zero_offset_access() {
    let d = transpile("p37_union_overlay");
    assert!(d.contains("def union_overlay_runtime() : int"));
    assert!(d.contains("reinterpret<uint?>(value)))[0]"));
    assert!(d.contains("reinterpret<uint8?>(value)))[0]"));
    assert!(!d.contains("value.word") && !d.contains("value.byte"));
}

#[test]
fn p39_packed_scalar_uses_memcpy_not_typed_deref() {
    let d = transpile("p39_packed_scalar");
    assert!(d.contains("def packed_scalar_runtime() : int"));
    assert!(d.contains("c2da_rt_memcpy("), "packed access must cross the runtime copy boundary");
    assert!(!d.contains("reinterpret<uint?>(pair)))["),
        "packed uint32 must not be lowered as typed pointer indexing");
}

#[test]
fn p38_local_union_uses_raw_storage_wrapper() {
    let d = transpile("p38_local_union_init");
    assert!(d.contains("struct local_overlay") && d.contains("c2da_storage : uint64"));
    assert!(d.contains("c2da_rt_calloc(uint64(1), uint64(4))"));
    assert!(!d.contains("value.word") && !d.contains("value.byte"));
}

#[test]
fn p40_bitfields_use_masked_raw_rmw() {
    let d = transpile("p40_bitfield_rmw");
    assert!(d.contains("def bitfield_rmw_runtime() : int"));
    assert!(d.contains("& uint(0x7)") && d.contains("<< uint(3)"));
    assert!(!d.contains("value.low") && !d.contains("value.high"));
}

#[test]
fn p41_union_cast_initializes_raw_storage() {
    let d = transpile("p41_union_cast");
    assert!(d.contains("struct cast_overlay") && d.contains("c2da_storage"));
    assert!(d.contains("c2da_rt_calloc(uint64(1), uint64(4))"));
    assert!(!d.contains("cast_overlay(uint(0x11223344))"));
}

#[test]
fn p22_literals_follow_their_c_target_types() {
    let d = transpile("p22_typed_literals");
    assert!(d.contains("byte = uint8("));
    assert!(d.contains("uint64(0x100000000uL)"));
    assert!(d.contains("int(42)"));
    assert!(d.contains("def return_byte_literal() : uint8"));
    assert!(d.contains("def return_u64_literal() : uint64"));
    assert!(d.contains("def return_int_literal() : int"));
}

#[test]
fn p23_bool_to_numeric_is_statement_lowered_at_every_value_site() {
    let d = transpile("p23_bool_numeric");
    assert!(!d.contains("int(left < right)"));
    assert!(!d.contains("int(left == right)"));
    assert!(d.contains("var c2da_fresh"));
    assert!(d.contains("= int(1)"));
}

#[test]
fn p24_nonruntime_pointer_calls_use_typed_pointer_abi_without_runtime() {
    let d = transpile("p24_nonruntime_pointer_call");
    assert!(d.contains("def identity_byte(var value : uint8?) : uint8?"));
    assert!(d.contains("def identity_void(var "));
    assert!(d.contains("def identity_void(var value_0 : uint8?) : uint8?"));
    assert!(d.contains("var erased : uint8?"));
    assert!(d.contains("var restored : uint8?"));
    assert!(!d.contains("identity_void(c2da_rt_"));
    assert!(!d.contains("uint8? = uint64("));
}

#[test]
fn p25_array_initializers_are_aggregate_ast_not_numeric_casts() {
    let d = transpile("p25_array_initializers");
    assert!(d.contains("var values : array<uint8> = []"));
    assert!(d.contains("values = [uint8(int(3)), uint8(int(5)), uint8(0)]"));
    assert!(d.contains("zeros = [uint8(0), uint8(0)]"));
    assert!(!d.contains("cast<array<uint8>>(0)"));
}
