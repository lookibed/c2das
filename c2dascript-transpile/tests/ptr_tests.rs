use std::path::Path;

fn transpile(name: &str) -> String {
    transpile_with_libc(name, c2dascript_transpile::LibcMode::NoStd)
}

fn transpile_with_libc(name: &str, libc: c2dascript_transpile::LibcMode) -> String {
    let c_path = Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .join(format!("tests/syntax/{}.c", name));
    assert!(c_path.exists(), "C file not found: {:?}", c_path);
    let (_td, cc_path) = c2dascript_transpile::create_temp_compile_commands(&[c_path.clone()]);
    let temp = tempfile::tempdir().expect("temporary AST/render output directory");
    let config = c2dascript_transpile::TranspilerConfig {
        output_dir: Some(temp.path().join("das")),
        libc,
        ..Default::default()
    };
    let outputs = c2dascript_transpile::transpile_checked(config, &cc_path, &["-w"])
        .unwrap_or_else(|error| panic!("{name}: strict AST/render translation failed: {error}"));
    assert_eq!(
        outputs.len(),
        1,
        "{name}: one input must produce one output"
    );
    let s = std::fs::read_to_string(&outputs[0]).expect("fresh temporary daScript output");
    eprintln!("=== {} ===\n{}", name, s);
    s
}

fn transpile_error(name: &str) -> String {
    let c_path = Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .join(format!("tests/syntax/{}.c", name));
    let (_td, cc_path) = c2dascript_transpile::create_temp_compile_commands(&[c_path]);
    let temp = tempfile::tempdir().expect("temporary diagnostic output directory");
    let config = c2dascript_transpile::TranspilerConfig {
        output_dir: Some(temp.path().join("das")),
        ..Default::default()
    };
    c2dascript_transpile::transpile_checked(config, &cc_path, &["-w"])
        .expect_err("negative fixture must return TranslationError")
        .to_string()
}

fn assert_precise_translation_error(name: &str, operation: &str, c_type: &str, cause: &str) {
    let error = transpile_error(name);
    assert!(
        error.contains(operation),
        "{name}: missing operation: {error}"
    );
    assert!(
        error.contains(&format!("c_type={c_type}")),
        "{name}: missing C type {c_type}: {error}"
    );
    assert!(
        error.contains(&format!("{name}.c")),
        "{name}: missing exact source file location: {error}"
    );
    assert!(
        error.contains(cause),
        "{name}: missing semantic cause: {error}"
    );
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
        d.contains("c2da_rt_malloc(4ul)"),
        "malloc calls must lower to the canonical runtime before printing"
    );
    assert!(
        !d.contains("unsafe(malloc("),
        "source malloc must not survive as the backend call target"
    );
    assert!(
        d.contains("var value : int? = null") && d.contains("reinterpret<int?>(c2da_rt_malloc("),
        "runtime raw address must materialize directly as the demanded int?"
    );
}

#[test]
fn p18_runtime_calloc_and_memset_use_canonical_raw_memory_abi() {
    let d = transpile("p18_runtime_calloc_memset");
    assert!(d.contains("c2da_rt_calloc(4ul, 1ul)"));
    assert!(d.contains("c2da_rt_memset("));
    assert!(!d.contains("unsafe(calloc("));
    assert!(!d.contains("unsafe(memset("));
}

#[test]
fn p19_runtime_memory_calls_use_canonical_raw_memory_abi() {
    let d = transpile("p19_runtime_memory_calls");
    for runtime_name in [
        "c2da_rt_memset(",
        "c2da_rt_realloc(",
        "c2da_rt_free(",
        "c2da_rt_memcmp(",
        "c2da_rt_memchr(",
    ] {
        assert!(d.contains(runtime_name), "missing lowered {runtime_name}");
    }
    // C copies cross to daslang's builtin copies over void? views of the two
    // raw addresses; the source-typed pointers never reach them directly.
    for builtin in ["memcpy(", "memmove("] {
        assert!(
            d.contains(&format!("unsafe({builtin}unsafe(reinterpret<void?>(")),
            "missing builtin {builtin} over raw addresses"
        );
    }
    for source_name in ["memset(", "realloc(", "free(", "memcmp(", "memchr("] {
        assert!(
            !d.contains(&format!("unsafe({source_name}")),
            "source call survived: {source_name}"
        );
    }
}

#[test]
fn p98_pointer_argument_of_the_parameter_type_crosses_as_itself() {
    let d = transpile("p98_pointer_arg_same_type");
    // `self` already is a `counter_t?`: no reinterpret, no unsafe.
    assert!(
        d.contains("counter_has(self_0, 1)"),
        "same-type argument was converted"
    );
    // A decayed const table is a `const` value; the reinterpret that lets it
    // reach the `var` parameter stays, as daslang's `addr<T?>` sugar.
    assert!(d.contains("table_value(unsafe(addr<entry_t const?>(TABLE[0])), 1)"));
    assert!(d.contains("first_byte(unsafe(addr<uint8 const?>(word)))"));
    // A field load keeps one wrapper per node that needs one: the index and
    // each reinterpret, never a second one around the same node.
    assert!(
        !d.contains("unsafe(unsafe(unsafe("),
        "wrapper around a wrapper"
    );
}

#[test]
fn p101_std_text_is_built_in_one_string_builder() {
    let d = transpile_with_libc(
        "p101_std_text_builders",
        c2dascript_transpile::LibcMode::Std,
    );
    // Text assembled byte by byte goes through one daslib string builder,
    // never a `string +=` per byte.
    assert!(d.contains(
        "    let out : string = build_string($(var writer : StringBuilderWriter) {\n        var i : int = 0\n"
    ));
    assert!(d.contains("write_char(writer, ch)"));
    assert!(d.contains("write(writer, c2da_std_number("));
    assert!(!d.contains("+= to_char("));
    assert!(!d.contains("verbatim"));
    // A specification's spelling is read back out of the format itself.
    assert!(d.contains("write(writer, c2da_std_take(f, i, j - i))"));
    assert!(d.contains(
        "\"--libc std: printf conversion is not implemented: \" + c2da_std_take(f, i, j + 1 - i)"
    ));
    assert!(
        d.contains("body = c2da_std_take(unsafe(reinterpret<int8 const?>(address)), 0, precision)")
    );
    // `strtod`'s digits, the C-string readers and the field padding.
    assert!(d.contains("write_char(writer, c2da_std_raw_byte(nptr, k))"));
    assert!(d.contains("let spaces : string = repeat(\" \", gap)"));
    assert!(!d.contains("c2da_std_repeat"));
    // The C locale's classes are daslib's, byte for byte.
    assert!(d.contains("if (is_alpha(c)) {"));
    assert!(d.contains("if (is_number(b)) {"));
    // A value that is already the payload lane's type is not converted again.
    assert!(d.contains("C2daVaArg(tag = 1, i64 = 42l,"));
    assert!(d.contains("C2daVaArg(tag = 2, i64 = 0, f64 = value,"));
    assert!(d.contains("C2daVaArg(tag = 1, i64 = int64(count),"));
}

#[test]
fn p99_conditionals_without_statements_are_daslang_expressions() {
    let d = transpile("p99_direct_conditionals");
    // `?:` whose arms are one expression each: daslang's `c ? a : b`, the
    // condition a `bool`, only the chosen call evaluated.
    assert!(d.contains("value_0 = x < y ? note(1, 10) : note(2, 20)"));
    // `&&`/`||` stored as a value: short-circuit on `bool`, C's 0/1 once.
    assert!(d.contains("value_0 = note(3, 0) != 0 && note(4, 1) != 0 ? 1 : 0"));
    assert!(d.contains("both = a != 0 && b != 0 ? 1 : 0"));
    assert!(d.contains("neither = !(a != 0 || b != 0) ? 1 : 0"));
    assert!(d.contains("not_less = !(a < b) ? 1 : 0"));
    // Mixed arms convert to the usual arithmetic type, the chosen arm only.
    assert!(d.contains("as_unsigned = sel != 0 ? uint(negative) : big"));
    assert!(d.contains("real = sel != 0 ? half : double(negative)"));
    // Pointer arms and pointer operands.
    assert!(d.contains("value_0 = *(null_p != null ? null_p : p_0)"));
    assert!(d.contains("value_0 = p_0 != null && *p_0 == 9 ? 1 : 0"));
    // A condition takes the `bool` itself, never `(b ? 1 : 0) != 0`.
    assert!(d.contains("if (x < y && note(14, 1) != 0) {"));
    assert!(
        !d.contains("? 1 : 0) != 0"),
        "int round trip in a condition"
    );
    // A right operand or an arm with statements keeps the guarded flag, so
    // `i++` runs only when C evaluates it.
    assert!(d.contains(
        "if (x > y) {\n        c2da_postinc_2 = i_0\n        i_0 = i_0 + 1\n        if (c2da_postinc_2 != 0) {"
    ));
    assert!(d.contains(" = note(10, i_0)\n    }\n    value_0 = c2da_fresh"));
    // A pointer arm whose conversion to the result type the lowering spells
    // as nothing (an array decay to `const char *`) keeps the temporary:
    // daslang's `?:` wants both arms of one type.
    assert!(d.contains("} else {\n            c2da_fresh0 = unsafe(addr(c2da_str_0[0]))\n"));
    // The min/max rewrite of `a < b ? a : b` is gone: it guessed `int` for
    // operands of unknown type.
    assert!(!d.contains("c2da_min_") && !d.contains("c2da_max_"));
}

#[test]
fn p100_conversions_of_values_already_of_the_target_type_are_dropped() {
    let d = transpile("p100_redundant_conversions");
    // An `int` index, a `u32` call with `u32` arguments, arithmetic of two
    // `int64`s and a load through a `const` pointer are already the type
    // the conversion names.
    assert!(d.contains("total = total + unsafe(unsafe(addr(table_0[0]))[i_0])"));
    assert!(d.contains("bits = get_bits(word_0, 8u)\n"));
    assert!(d.contains("more = 16u * get_bits(word_0, 4u)\n"));
    assert!(d.contains("return ns / 1000000000l\n"));
    assert!(d.contains("return unsafe(unsafe(reinterpret<uint8 const?>(in_0))[i])\n"));
    assert!(d.contains("from_const = unsafe(unsafe(addr(table_0[0]))[ci])\n"));
    // `uint8(c ? int(t1) : int(t2))` of two `uint8`s is the conditional.
    assert!(d.contains("return int(t2) == 255 ? t1 : t2\n"));
    // Conversions that change the type stay.
    for kept in [
        "u = uint(negative)\n",
        "widened = int(b)\n",
        "less = i_1 < negative ? 1 : 0\n",
        "narrowed = int(big)\n",
        "from_const_unsigned = uint(ci)\n",
        "b = load(unsafe(addr<uint8 const?>(BYTES[0])), i_1)\n",
    ] {
        assert!(d.contains(kept), "missing `{}`", kept.trim_end());
    }
}

#[test]
fn p96_copies_reach_the_builtin_past_a_source_defined_memmove() {
    let d = transpile("p96_memcpy_builtin");
    assert!(
        d.contains("def memmove_0(") && !d.contains("def memmove("),
        "a C definition of memmove must not shadow daslang's builtin memmove"
    );
    assert!(!d.contains("c2da_rt_memcpy(unsafe") && !d.contains("c2da_rt_memmove(unsafe"));
    assert!(
        !d.contains("memmove_0(unsafe"),
        "calls must not reach the C body"
    );
    assert!(d.contains("unsafe(memcpy(") && d.contains("unsafe(memmove("));
    // A size that is not a nonzero constant guards the copy (C's n == 0 no-op).
    assert!(d.contains(" != 0x0) {\n        unsafe(memcpy("));
}

#[test]
fn p97_constant_conversions_print_as_literals_of_their_target_type() {
    let d = transpile("p97_constant_conversions");
    // A constant conversion is its exact C result, spelled in the target type.
    for folded in [
        "narrowed = 44u8\n",
        "wrapped = 4294967295u\n",
        "wide = 0xfffffffffffffffful\n",
        "from_unsigned = (-2147483647 - 1)\n",
        "ll_min = (-9223372036854775807l - 1l)\n",
        "short_wrap = int16(4464)\n",
        "ushort_wrap = uint16(65534)\n",
        "hex_byte = 0xabu8\n",
        "mask = 0xff000000u >> 24u\n",
        "shifted = 0xfful << 8ul\n",
        "negative_wide = -5l\n",
        "real = 3.0lf\n",
        "var failures : int = 0\n",
    ] {
        assert!(d.contains(folded), "missing folded constant {folded:?}");
    }
    // `int8` has no literal, and a float that rounds keeps its conversion.
    assert!(d.contains("negative_byte = int8(-1)\n"));
    assert!(d.contains("single = float(16777217)\n"));
    // The narrowing of a size argument is part of the C value.
    assert!(d.contains(", 0u8, 4ul)"));
    assert!(!d.contains("int(int(") && !d.contains("uint64(int("));
}

#[test]
fn p20_pointer_abi_edges_stay_typed_outside_raw_boundaries() {
    let d = transpile("p20_pointer_abi_edges");
    assert!(d.contains("var typed : uint8?"));
    assert!(
        d.contains("var erased : uint8?"),
        "void* must stay pointer-shaped"
    );
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
        d.contains("int(left) < int(right)"),
        "C promotes unsigned char to int, so the comparison is signed"
    );
    assert!(
        d.contains("int(left) + int(right)"),
        "byte arithmetic must widen storage uint8 values to the promoted type"
    );
    assert!(!d.contains("uint8? = uint64("));
}

#[test]
fn p26_variadic_sum_uses_the_canonical_packed_abi() {
    let d = transpile("p26_variadic_sum");
    assert!(d.contains("struct C2daVaArg"));
    // The promoted-argument array is only read, so it is not a `var` parameter.
    assert!(d.contains("def sum(var count : int; c2da_va_args : array<C2daVaArg>)"));
    assert!(d.contains("def variadic_sum_runtime() : int"));
    assert!(d.contains("C2daVaArg(tag = 1, i64 = 10l"));
    assert!(d.contains("c2da_va_item"));
    assert!(!d.contains("__builtin_va_start"));
    assert!(!d.contains("va_arg not supported"));
}

#[test]
fn p27_variadic_promotions_pack_int_and_double_lanes() {
    let d = transpile("p27_variadic_promotions");
    assert!(
        d.contains("def promoted_sum(var count : int; c2da_va_args : array<C2daVaArg>) : double")
    );
    assert!(
        d.contains("C2daVaArg(tag = 1"),
        "integer promotions must use the integer ABI lane"
    );
    assert!(
        d.contains("C2daVaArg(tag = 2"),
        "float must be promoted to the double ABI lane"
    );
    assert!(
        d.contains("double("),
        "the promoted floating argument must materialize as double"
    );
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
    assert_precise_translation_error(
        "p29_variadic_function_pointer_unsupported",
        "operation=top-level declaration lowering",
        "Function",
        "unsupported variadic ABI boundary: variadic function pointer call",
    );
}

#[test]
#[ignore = "known-red: exporter crashes before the required TranslationError boundary"]
fn n02_unsupported_va_arg_type_is_not_printed_as_a_fake_value() {
    assert_precise_translation_error(
        "n02_unsupported_va_arg_type",
        "operation=top-level declaration lowering",
        "Function",
        "unsupported va_arg type",
    );
}

#[test]
#[ignore = "known-red: exporter crashes before the required TranslationError boundary"]
fn n03_inline_asm_is_rejected_without_a_placeholder_statement() {
    assert_precise_translation_error(
        "n03_inline_asm",
        "operation=top-level declaration lowering",
        "Function",
        "unsupported inline asm",
    );
}

#[test]
#[ignore = "known-red: exporter crashes before the required TranslationError boundary"]
fn n04_simd_shuffle_is_rejected_without_scalar_emulation() {
    assert_precise_translation_error(
        "n04_simd_shuffle",
        "operation=top-level declaration lowering",
        "Function",
        "shuffle vector",
    );
}

#[test]
#[ignore = "known-red: exporter crashes before the required TranslationError boundary"]
fn n05_simd_convert_is_rejected_without_scalar_emulation() {
    assert_precise_translation_error(
        "n05_simd_convert",
        "operation=top-level declaration lowering",
        "Function",
        "vector conversion",
    );
}

#[test]
#[ignore = "known-red: exporter crashes before the required TranslationError boundary"]
fn n01_unsupported_builtin_is_not_silently_lowered() {
    assert_precise_translation_error(
        "n01_unsupported_builtin",
        "operation=top-level declaration lowering",
        "Function",
        "unsupported builtin",
    );
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
    assert!(d.contains("12ul"), "sizeof must remain a numeric AST value");
}

#[test]
fn p34_records_and_unions_use_clang_layout_facts() {
    let d = transpile("p34_c_layout_records");
    assert!(d.contains("def c_layout_records_runtime() : int"));
    assert!(
        d.contains("12ul"),
        "struct size must be emitted from Clang layout"
    );
    assert!(
        d.contains("4ul"),
        "align/offsetof/union layout must be emitted from Clang layout"
    );
    assert!(!d.contains("unsupported sizeof type layout"));
}

#[test]
fn p35_pointer_backed_struct_uses_c_field_offsets() {
    let d = transpile("p35_pointer_backed_struct");
    assert!(d.contains("def pointer_backed_struct_runtime() : int"));
    assert!(
        d.contains("reinterpret<uint?>(") && d.contains("))[2]"),
        "padded C field must use an address-backed uint lvalue at Clang offset 8"
    );
}

#[test]
fn p37_union_overlay_uses_raw_zero_offset_access() {
    let d = transpile("p37_union_overlay");
    assert!(d.contains("def union_overlay_runtime() : int"));
    assert!(d.contains("reinterpret<uint?>(") && d.contains("))[0]"));
    assert!(d.contains("reinterpret<uint8?>(") && d.contains("))[0]"));
    assert!(!d.contains("value.word") && !d.contains("value.byte"));
}

#[test]
fn p39_packed_scalar_uses_memcpy_not_typed_deref() {
    let d = transpile("p39_packed_scalar");
    assert!(d.contains("def packed_scalar_runtime() : int"));
    assert!(
        d.contains("c2da_rt_memcpy("),
        "packed access must cross the runtime copy boundary"
    );
    assert!(
        !d.contains("reinterpret<uint?>(pair)))["),
        "packed uint32 must not be lowered as typed pointer indexing"
    );
}

#[test]
fn p40_nested_raw_aggregate_is_an_address_chain_not_an_rvalue() {
    let d = transpile("p40_nested_raw_aggregate_place");
    assert!(d.contains("def nested_raw_aggregate_place_runtime() : int"));
    assert!(
        !d.contains("aggregate C object rvalue from raw storage is not implemented"),
        "nested field access must reach its scalar leaf through raw addresses"
    );
    assert!(
        d.contains("reinterpret<uint?>(") && d.contains("))[1]"),
        "Clang offset 4 for inner.count must become the uint storage index"
    );
    assert!(d.contains("0x10203040") || d.contains("270544960"));
}

#[test]
fn p41_raw_array_field_decays_from_its_address_not_a_das_array_value() {
    let d = transpile("p41_raw_array_field_decay");
    assert!(d.contains("def raw_array_field_decay_runtime() : int"));
    assert!(d.contains("c2da_rt_calloc"));
    assert!(
        !d.contains("aggregate C object rvalue from raw storage is not implemented"),
        "array field decay must use its C object address"
    );
    assert!(d.contains(")[0]") && d.contains(")[3]"));
}

#[test]
fn p38_local_union_uses_raw_storage_wrapper() {
    let d = transpile("p38_local_union_init");
    assert!(d.contains("struct local_overlay") && d.contains("c2da_storage : uint64"));
    assert!(d.contains("c2da_rt_calloc(1ul, 4ul)"));
    assert!(!d.contains("value.word") && !d.contains("value.byte"));
}

#[test]
fn p40_bitfields_use_masked_raw_rmw() {
    let d = transpile("p40_bitfield_rmw");
    assert!(d.contains("def bitfield_rmw_runtime() : int"));
    assert!(d.contains("& 0x7u") && d.contains("<< 3u"));
    assert!(!d.contains("value.low") && !d.contains("value.high"));
}

#[test]
fn p41_union_cast_initializes_raw_storage() {
    let d = transpile("p41_union_cast");
    assert!(d.contains("struct cast_overlay") && d.contains("c2da_storage"));
    assert!(d.contains("c2da_rt_calloc(1ul, 4ul)"));
    assert!(!d.contains("cast_overlay(uint(0x11223344))"));
}

#[test]
fn p22_literals_follow_their_c_target_types() {
    let d = transpile("p22_typed_literals");
    // Each literal is spelled directly in its C target type, hex kept hex.
    assert!(d.contains("byte = 0xabu8"));
    assert!(d.contains("wide = 0x100000000ul"));
    assert!(d.contains("signed_value = 42\n"));
    assert!(!d.contains("int(42)") && !d.contains("uint8(int("));
    assert!(d.contains("def return_byte_literal() : uint8"));
    assert!(d.contains("def return_u64_literal() : uint64"));
    assert!(d.contains("def return_int_literal() : int"));
}

#[test]
fn p23_bool_to_numeric_is_materialized_at_every_value_site() {
    let d = transpile("p23_bool_numeric");
    // daslang has no `int(bool)`: C's 0/1 is `b ? 1 : 0`, in place, with no
    // temporary.
    assert!(!d.contains("int(left < right)"));
    assert!(!d.contains("int(left == right)"));
    assert!(d.contains("return left < right ? 1 : 0\n"));
    assert!(d.contains("assigned = left_0 < right_0 ? 1 : 0\n"));
    assert!(d.contains("take_int(left_0 == right_0 ? 1 : 0)"));
    assert!(d.contains("+ (left_0 != right_0 ? 1 : 0)"));
    assert!(!d.contains("var c2da_fresh"));
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
    // A C array of constant extent owns inline storage, so it is a daScript
    // fixed array `T[N]`, never a heap `array<T>` handle.
    assert!(d.contains("var values : uint8[3]"));
    assert!(d.contains("values = fixed_array<uint8>(3u8, 5u8, 0u8)"));
    assert!(d.contains("zeros = fixed_array<uint8>(0u8, 0u8)"));
    assert!(!d.contains("cast<array<uint8>>(0)"));
    assert!(!d.contains("array<uint8> = []"));
}
