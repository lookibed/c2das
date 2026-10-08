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

/// The `--unsafe-deref` translation under `--libc std`: no null checks and
/// no fixed-array range checks (`hint(unsafe_range_check)`).
fn transpile_unsafe_deref(name: &str) -> String {
    let c_path = Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .join(format!("tests/syntax/{}.c", name));
    assert!(c_path.exists(), "C file not found: {:?}", c_path);
    let (_td, cc_path) = c2dascript_transpile::create_temp_compile_commands(&[c_path.clone()]);
    let temp = tempfile::tempdir().expect("temporary AST/render output directory");
    let config = c2dascript_transpile::TranspilerConfig {
        output_dir: Some(temp.path().join("das")),
        libc: c2dascript_transpile::LibcMode::Std,
        unsafe_deref: true,
        ..Default::default()
    };
    let outputs = c2dascript_transpile::transpile_checked(config, &cc_path, &["-w"])
        .unwrap_or_else(|error| panic!("{name}: strict AST/render translation failed: {error}"));
    assert_eq!(outputs.len(), 1, "{name}: one input must produce one output");
    let s = std::fs::read_to_string(&outputs[0]).expect("fresh temporary daScript output");
    eprintln!("=== {} (unsafe_deref) ===\n{}", name, s);
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
        d.contains("var value : int? = unsafe(reinterpret<int?>(")
            && d.contains("reinterpret<int?>(c2da_rt_malloc("),
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
    assert!(d.contains("while (x < y && note(14, 1) != 0) {"));
    assert!(
        !d.contains("? 1 : 0) != 0"),
        "int round trip in a condition"
    );
    // A right operand or an arm with statements keeps the guarded flag, so
    // `i++` runs only when C evaluates it.
    assert!(d.contains(
        "if (x > y) {\n        var c2da_postinc_1 : int = i_0\n        i_0 += 1\n        if (c2da_postinc_1 != 0) {"
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
    assert!(d.contains("total += table_0[i_0]"));
    assert!(d.contains("bits = get_bits(word_0, 8u)\n"));
    assert!(d.contains("more = 16u * get_bits(word_0, 4u)\n"));
    assert!(d.contains("return ns / 1000000000l\n"));
    // Indexing a pointer already of the element pointer type needs no reinterpret.
    assert!(d.contains("return unsafe(in_0[i])\n"));
    assert!(d.contains("from_const = table_0[ci]\n"));
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
fn p102_locals_are_declared_bare_and_initialised_in_place() {
    let d = transpile("p102_local_declarations");
    // Numbers, pointers, pointer aliases and plain structs are hoisted with no
    // initializer: daslang zero-fills them.
    // (`i` is the range loop's variable, p175, so it has no `var`.)
    assert!(d.contains(
        "def loop_reinit(var n : int) : int {\n    var total : int\n    var acc : int\n    var pt : point\n"
    ));
    // The C initializer stays where C wrote it, inside the loop.
    assert!(d.contains(
        "for (i in range(0, n)) {\n        acc = 10\n        pt = point(x = i, y = i * 2, tag = null)\n"
    ));
    assert!(d.contains("    var p_0 : int?\n    var pt_0 : point\n    var cur : cursor_t\n"));
    assert!(d.contains("    var wr : wrapped\n"));
    // A site temporary in a structured loop body stays a local of the body.
    assert!(d.contains("        var c2da_postinc : cursor_t = cur_0\n"));
    // A storage-backed union and a daslang `enum` keep their explicit value.
    assert!(d.contains("var b_0 : bits = bits(c2da_storage = c2da_rt_calloc(1ul, 4ul))"));
    assert!(d.contains("var c : colour = colour()"));
    // A store that opens the body is the last declaration's value, and only
    // that one's; a store naming its own object stays an assignment.
    assert!(d.contains("def first_store(var k_2 : int) : int {\n    var bias : int = k_2 + 1\n"));
    assert!(d.contains("    var bias_0 : int\n    doubled = k_3 * 2\n    bias_0 = 1\n"));
    assert!(d.contains("var c2da_fresh0 : int = int(op) + 1\n"));
    assert!(d.contains("    var self : uint8?\n    self = unsafe(addr<uint8?>(self))\n"));
    // One `return` closes a void function whose early `return` was laid out
    // after the closing one.
    assert!(d.contains("    g_state += b_1\n    return\n}\n"));
    assert!(
        !d.contains("    return\n    return\n"),
        "unreachable second return"
    );
}

#[test]
fn p113_block_scope_function_declarations_emit_the_function_at_module_scope() {
    let d = transpile("p113_block_scope_function_decl");
    // The block-scope declaration is no statement of its own.
    assert!(d.contains("def run_twice() : int {\n    return later(1) + later(2)\n}\n"));
    // The function it declares first is emitted once, at module scope.
    assert_eq!(d.matches("def later(").count(), 1, "later emitted once");
    assert_eq!(d.matches("def counter_value(").count(), 1);
    assert!(d.contains("\n[export, sideeffects]\ndef later(var k_0 : int) : int {\n"));
}

#[test]
fn p114_assignment_arguments_are_hoisted_values() {
    let d = transpile("p114_assignment_arguments");
    // A call statement's assignment argument: the store, then its value.
    assert!(d.contains("    x -= 8\n    sink(x, unsafe(addr<int?>(out_0)))\n"));
    assert!(d.contains("    *p = 7\n    sink(*p, unsafe(addr<int?>(out_0)))\n"));
    assert!(d.contains("    bits <<= 4u\n    note(bits)\n"));
    assert!(d.contains("        total += i\n        sink(total, unsafe(addr<int?>(out_0)))\n"));
    assert!(!d.contains("sink(x = "), "assignment printed inside a call");
}

#[test]
fn p115_unprototyped_designators_take_the_slot_type() {
    let d = transpile("p115_unprototyped_function_values");
    // `bump` is designated through `void bump();`: its value is converted to
    // the `void (*)()` type C gives it.
    assert!(d.contains("state(tics = 1, action = unsafe(reinterpret<function<():void>>(@@bump)))"));
    assert!(d.contains("state(tics = 2, action = unsafe(reinterpret<function<():void>>(@@add)))"));
    // A designator whose type already is the emitted function's is not.
    assert!(d.contains("state(tics = 3, action = @@none_0)"));
    // The call through the slot converts back to the callee's real type.
    assert!(d.contains("invoke(unsafe(reinterpret<action_p1>("));
}

#[test]
fn p116_self_referencing_globals_are_initialised_by_init() {
    let d = transpile("p116_self_referencing_initializer");
    // The objects keep module storage and get their value in `[init]`.
    assert!(d.contains("var sounds : sfx_s[4]\n"));
    assert!(d.contains("[init, sideeffects]\ndef c2da_gset_sounds() {\n"));
    assert!(d.contains("link = unsafe(addr(unsafe(unsafe(addr(sounds[0]))[1])))"));
    assert!(d.contains("var ring : node\n"));
    assert!(d.contains("        ring = node(next = unsafe(addr(ring)), value = 7)\n"));
    // A global that depends on the self-referencing one moves with it.
    assert!(d.contains("var loudest : sfx_s?\n"));
    assert!(d.contains("[init, sideeffects]\ndef c2da_gset_loudest() {\n"));
    assert!(!d.contains("var sounds : sfx_s[4] ="));
    // A table reached again through the body of a function it holds.
    assert!(d.contains("[init, sideeffects]\ndef c2da_gset_ops() {\n"));
    assert!(d.contains("        ops = fixed_array<function<(var _arg0:int):int>>(@@op_self)\n"));
}

#[test]
fn p103_records_with_zero_sized_fields_are_storage_backed() {
    let d = transpile_with_libc(
        "p103_zero_sized_fields",
        c2dascript_transpile::LibcMode::Std,
    );
    // daslang gives an empty-struct or zero-length-array field at least one
    // byte, so no record holding one may be a daslang struct with its fields:
    // each owns Clang's bytes (the object size is Clang's).
    for (record, size) in [
        ("WithEmpty", 8),
        ("TrailingEmpty", 4),
        ("EmptyArray", 4),
        ("MidZero", 8),
        ("Tail", 4),
        ("AnonWithEmpty", 2),
    ] {
        assert!(
            d.contains(&format!(
                "struct {record} {{\n    c2da_storage : uint64 = c2da_rt_calloc(1ul, {size}ul)\n}}\n"
            )),
            "{record} must be storage-backed with Clang's size {size}"
        );
    }
    // A record embedding one of them by value holds its bytes inline (p176):
    // `Outer` is natural, `inner` its eight bytes as `uint[2]`, and the proof
    // asserts Clang's offsets around it.
    assert!(d.contains("struct Outer {\n    inner : uint[2]\n    after : int\n}\n"));
    assert!(d.contains(
        "static_assert(typeinfo offsetof<after>(type<Outer>) == 8, \"C layout of Outer: offsetof after\")"
    ));
    assert!(
        !d.contains("    e : Empty\n") && !d.contains("    es : Empty[4]\n"),
        "no daslang field of an empty struct"
    );
    // The empty struct on its own is 0 bytes in both, and stays a struct.
    assert!(d.contains("struct Empty {\n}\n"));
    // `p->b` reads Clang's offset 4.
    assert!(d.contains(
        "def read_b(var p : WithEmpty?) : int {\n    return unsafe(unsafe(reinterpret<int?>(unsafe(reinterpret<uint64>(p))))[1])\n}"
    ));
}

#[test]
fn p104_proven_record_fields_are_accessed_by_name() {
    let d = transpile_with_libc("p104_field_by_name", c2dascript_transpile::LibcMode::Std);
    // Loads and stores of scalar and pointer fields, one level and nested,
    // through a typed record pointer.
    for line in [
        "    n_0.count = 40\n",
        "    n_0.inner.tag = int16(-3)\n",
        "    n_0.inner.weight = 2.5lf\n",
        "    n_0.next = next\n",
        "    n_0.big = 0x123456789abcdeful\n",
        "    return n_5.next.count\n",
        "    return uint(p.lo) + p.hi + uint(p.owner.count)\n",
        "    pp.hi = 1000u\n",
    ] {
        assert!(d.contains(line), "missing by-name access: {line:?}");
    }
    // A `const S *` base is converted once to `S?` (abi.rs), so a pointer
    // field reads out as a plain pointer.
    assert!(d.contains("def weight_of(var n_3 : Node const?) : double {\n    return unsafe(reinterpret<Node?>(n_3)).inner.weight\n}"));
    assert!(d.contains("unsafe(reinterpret<Node?>(n_1)).label_0"));
    // A read-modify-write through a call evaluates the call once and binds
    // the typed record pointer, not a raw address.
    assert!(d.contains(
        "    var c2da_fresh0 : Node? = unsafe(reinterpret<Node?>(pick(n_4)))\n    c2da_fresh0.count += 2\n"
    ));
    assert_eq!(d.matches("pick(n_4)").count(), 3);
    // No byte-offset field access is left in the functions that use only
    // scalar and pointer leaves.
    for function in [
        "fill",
        "label_of",
        "next_of",
        "weight_of",
        "bump",
        "second_count",
        "sum_pair",
    ] {
        let start = d
            .find(&format!("def {function}("))
            .unwrap_or_else(|| panic!("missing {function}"));
        let body = &d[start..start + d[start..].find("\n}\n").expect("function end")];
        assert!(
            !body.contains("reinterpret<uint64>"),
            "{function} still uses a byte offset:\n{body}"
        );
    }
    // Every record accessed by name has its compile-time layout proof, the
    // typedef'd anonymous struct included.
    assert_eq!(d.matches("def c2da_layout_proofs() {\n").count(), 1);
    for assertion in [
        "static_assert(typeinfo sizeof(type<Node>) == 56, \"C layout of Node: sizeof\")",
        "static_assert(typeinfo alignof(type<Node>) == 8, \"C layout of Node: alignof\")",
        "static_assert(typeinfo offsetof<count>(type<Node>) == 4, \"C layout of Node: offsetof count\")",
        "static_assert(typeinfo offsetof<inner>(type<Node>) == 8, \"C layout of Node: offsetof inner\")",
        "static_assert(typeinfo offsetof<flag>(type<Node>) == 48, \"C layout of Node: offsetof flag\")",
        "static_assert(typeinfo offsetof<weight>(type<Inner>) == 8, \"C layout of Inner: offsetof weight\")",
        "static_assert(typeinfo sizeof(type<Pair>) == 16, \"C layout of Pair: sizeof\")",
        "static_assert(typeinfo offsetof<owner>(type<Pair>) == 8, \"C layout of Pair: offsetof owner\")",
    ] {
        assert!(d.contains(assertion), "missing layout proof: {assertion}");
    }
}

#[test]
fn p105_unproven_and_address_places_keep_byte_offsets() {
    let d = transpile_with_libc(
        "p105_field_by_offset_kept",
        c2dascript_transpile::LibcMode::Std,
    );
    // Union, packed, over-aligned and a flexible array member are
    // storage-backed: Clang offsets only.  A bitfield record is natural
    // (p177): its fields are shifts and masks on the unit field by name.
    for (function, access) in [
        (
            "word_of",
            "unsafe(unsafe(reinterpret<uint?>(unsafe(reinterpret<uint64>(w))))[0])",
        ),
        ("bits_of", "b.c2da_bits_0 >> 3 & 0x1f"),
        ("packed_of", "unsafe(reinterpret<uint64>(p)) + 1ul)), 4ul))"),
        (
            "aligned_of",
            "unsafe(unsafe(reinterpret<int?>(unsafe(reinterpret<uint64>(a))))[4])",
        ),
        (
            "flex_sum",
            "unsafe(unsafe(reinterpret<int?>(unsafe(reinterpret<uint64>(f))))[0])",
        ),
    ] {
        let start = d
            .find(&format!("def {function}("))
            .unwrap_or_else(|| panic!("missing {function}"));
        let body = &d[start..start + d[start..].find("\n}\n").expect("function end")];
        assert!(
            body.contains(access),
            "{function} lost its byte offset:\n{body}"
        );
    }
    for record in ["Word", "Packed", "Aligned", "Flex"] {
        assert!(
            !d.contains(&format!("type<{record}>")),
            "a storage-backed record has no daslang layout to prove: {record}"
        );
    }
    // A record containing a union is natural (p176): the union field is its
    // inline storage, `tag` goes by name and the union's array member is
    // read at the field's offset.
    assert!(d.contains("struct HasUnion {\n    tag : int\n    w : uint\n}\n"));
    assert!(d.contains(
        "static_assert(typeinfo offsetof<w>(type<HasUnion>) == 4, \"C layout of HasUnion: offsetof w\")"
    ));
    let body = function_body(&d, "tag_and_byte");
    assert!(
        body.contains("    var c2da_fresh0 : uint8? = unsafe(reinterpret<uint8?>(unsafe(reinterpret<uint64>(h)) + 4ul))\n    return h.tag + int(unsafe(unsafe(reinterpret<uint8?>(c2da_fresh0))[0]))"),
        "{body}"
    );
    // In the proven `Buf`, the scalar fields go by name while the address of
    // a field and an element of a fixed-array field stay on offsets (p178
    // says why the field array is not indexed by name).
    assert!(d.contains("    s_0 = b_0.len + b_0.tail\n"));
    assert!(d.contains("unsafe(reinterpret<int?>(unsafe(reinterpret<uint64>(b_0)) + 12ul))"));
    assert!(d.contains("unsafe(reinterpret<uint8?>(unsafe(reinterpret<uint64>(b_0)) + 4ul))"));
    assert!(d.contains(
        "static_assert(typeinfo offsetof<data>(type<Buf>) == 4, \"C layout of Buf: offsetof data\")"
    ));
}

#[test]
fn p120_enum_compound_assignment_computes_in_the_integer_type() {
    let d = transpile_with_libc(
        "p120_enum_compound_assignment",
        c2dascript_transpile::LibcMode::Std,
    );
    // The enum operand is read as its compatible integer type, the operation
    // runs there, and the result is re-read as the enum (binjgb's
    // `CPU_SPEED.speed ^= 1` and `FC ^= 1`).
    assert!(d.contains("s.speed = unsafe(reinterpret<Speed>(uint(s.speed) ^ 1u))"));
    assert!(d.contains("f.C = unsafe(reinterpret<Bool>(uint(f.C) ^ 1u))"));
    assert!(d.contains("t = unsafe(reinterpret<Speed>(uint(t) - 1u))"));
    // `++`/`--` the same; a narrower enum is narrowed to its own integer
    // type before it is re-read, through a storage-backed field too.
    assert!(d.contains("enum Small : uint8 {"));
    assert!(d.contains(
        "unsafe(unsafe(reinterpret<Small?>(p.c2da_storage))[7]) = unsafe(reinterpret<Small>(uint8(int(unsafe(unsafe(reinterpret<Small?>(p.c2da_storage))[7])) - 1)))"
    ));
    // Never an operator applied to the enum value itself.
    assert!(!d.contains("(s.speed ^ 1u)") && !d.contains("(t + 1u)"));
}

#[test]
fn p121_switch_dispatch_is_a_jump_table_or_a_split() {
    let d = transpile_with_libc("p121_switch_dispatch", c2dascript_transpile::LibcMode::Std);
    // A dense switch is a bounds test and one computed jump into a run of
    // label numbers; 256 cases are not an elif chain.
    assert!(d.contains(
        "    if (c2da_fresh0 >= 0 && c2da_fresh0 <= 255) {\n        goto c2da_fresh0 + 1\n    }\n"
    ));
    assert!(!d.contains("elif (c2da_fresh0 == 255)"));
    // Holes in the range go to the default arm through the table.
    assert!(d.contains("        goto x - 8\n"));
    // 64-bit scrutinees subtract the low case in their own type.
    assert!(d.contains("goto int(w - 0xffffffff00000000ul) + 2"));
    // A sparse set is split at its median value.
    assert!(d.contains("def sparse(var v : int64) : int {\n    if (v < 9l) {\n"));
    // Flat back end: an arm that falls off a void function is sent to a
    // `return` trampoline at the top of the body, where no folding can
    // remove the `return`.
    assert!(d.contains(
        "def early_out_flat(var k_0 : int) {\n    goto label 7\n    label 6:\n    return\n    label 7:\n    if (k_0 >= 1 && k_0 <= 5) {\n        goto k_0 + 1\n    }\n"
    ));
    // Structured back end: the switch is a region of the body, and the arm
    // that returns returns where it stands.
    assert!(d.contains(
        "def early_out(var k_1 : int) {\n    if (k_1 >= 1 && k_1 <= 5) {\n        goto k_1\n    }\n    goto label 0\n"
    ));
    assert!(d.contains("    label 5:\n    return\n    label 0:\n    g_seen += 1000\n"));
    // No elif chain is longer than four arms.
    let mut elifs = 0;
    for line in d.lines().map(str::trim_start) {
        if line.starts_with("} elif") {
            elifs += 1;
            assert!(elifs <= 3, "an elif chain of more than four arms");
        } else if !line.starts_with("goto label") {
            elifs = 0;
        }
    }
}

#[test]
fn p122_bool_conditions_test_the_bool_itself() {
    let d = transpile_with_libc("p122_bool_conditions", c2dascript_transpile::LibcMode::Std);
    // A `_Bool` operand of `&&`/`||`/`!` is tested as itself.
    assert!(d.contains("if (a && o.level > 2) {"));
    assert!(d.contains("if (b || o.verbose) {"));
    assert!(d.contains("if (!(a && b)) {"));
    assert!(d.contains("if (unsafe(flags[i]) && i >= 0) {"));
    assert!(!d.contains("== true ? 1 : 0) != 0"));
    // An integer constant returned as `_Bool` is a `bool` constant.
    assert!(d.contains("    return true\n"));
    assert!(d.contains("    return false\n"));
    assert!(!d.contains("0 != 0") && !d.contains("1 != 0"));
    // A constant loop condition is no test at all.
    assert!(!d.contains("if (true)") && !d.contains("if (false)"));
    // A narrowing conversion of a literal keeps C's value: (unsigned char)256 is 0.
    assert!(d.contains("if (0u8 != 0x0)"));
}

#[test]
fn p130_typedef_storage_records_declare_one_wrapper() {
    let d = transpile_with_libc(
        "p130_typedef_storage_records",
        c2dascript_transpile::LibcMode::Std,
    );
    // The union, its typedef and the typedef of that typedef name one
    // wrapper; the packed struct and its alias likewise.
    for name in ["value_t", "post_t", "holder_s"] {
        assert_eq!(
            d.matches(&format!("\nstruct {name} {{\n")).count(),
            1,
            "struct {name} must be declared exactly once"
        );
    }
    assert!(!d.contains("struct alias_t") && !d.contains("struct column_t"));
    assert!(d.contains("var cell2 : value_t = value_t(c2da_storage = c2da_rt_calloc(1ul, 4ul))"));
}

#[test]
fn p131_storage_record_arrays_are_contiguous_and_step_by_clang_size() {
    let d = transpile_with_libc(
        "p131_storage_record_arrays",
        c2dascript_transpile::LibcMode::Std,
    );
    // An uninitialised file-scope array is one zeroed block, each wrapper a
    // slice of it; a single object owns its own zeroed storage.
    assert!(
        d.contains("var entries : entry_t[4] = c2da_records_entry_t_4(c2da_rt_calloc(1ul, 48ul))")
    );
    assert!(d.contains(
        "return fixed_array<entry_t>(entry_t(c2da_storage = base), entry_t(c2da_storage = base + 12ul), entry_t(c2da_storage = base + 24ul), entry_t(c2da_storage = base + 36ul))"
    ));
    assert!(d.contains("var single : entry_t = entry_t(c2da_storage = c2da_rt_calloc(1ul, 12ul))"));
    assert!(d.contains(
        "return fixed_array<table_t[2]>(c2da_records_table_t_2(base), c2da_records_table_t_2(base + 80ul))"
    ));
    // The array decays to its first element's byte address.
    assert!(d.contains(
        "p = unsafe(reinterpret<entry_t?>(unsafe(reinterpret<entry_t?>(entries[0].c2da_storage))))"
    ));
    // Pointer arithmetic steps by Clang's 12 bytes, not the wrapper's 8.
    assert!(d.contains("p = unsafe(reinterpret<entry_t?>(unsafe(reinterpret<uint64>(p)) + 24ul))"));
    assert!(d.contains("p = unsafe(reinterpret<entry_t?>(unsafe(reinterpret<uint64>(p)) - 12ul))"));
    assert!(d.contains(
        "first = unsafe(reinterpret<entry_t const?>(unsafe(reinterpret<uint64>(first)) + 12ul))"
    ));
    assert!(
        d.contains(") / 12l"),
        "a pointer difference divides by Clang's size"
    );
    assert!(
        !d.contains("unsafe(p + "),
        "no daslang pointer arithmetic on a wrapper pointer"
    );
}

#[test]
fn p132_storage_objects_keep_their_storage() {
    let d = transpile_with_libc(
        "p132_storage_object_identity",
        c2dascript_transpile::LibcMode::Std,
    );
    // A cyclic array keeps its contiguous storage; `[init]` copies the
    // initializer's bytes into it instead of replacing the wrappers.
    assert!(d.contains("var ring : node[3] = c2da_records_node_3(c2da_rt_calloc(1ul, 63ul))"));
    assert!(d.contains(
        "        var c2da_fresh18 : node[3] = c2da_ginit_ring()\n        for (c2da_fresh19, c2da_fresh20 in ring, c2da_fresh18) {\n            unsafe(memmove(unsafe(reinterpret<void?>(c2da_fresh19.c2da_storage)), unsafe(reinterpret<void?>(c2da_fresh20.c2da_storage)), 21ul))\n"
    ));
    assert!(!d.contains("ring = c2da_ginit_ring()"));
    // `st_t` holds its union inline (p176) and is a natural record: its
    // cyclic array is assigned in place like any other daslang global, and
    // the union member is read at the field's address.
    assert!(d.contains("struct st_t {\n    id : int\n    a : uint64\n    mine : int?\n}\n"));
    assert!(d.contains("        states = c2da_ginit_states()\n"));
    assert!(d.contains(
        "invoke(unsafe(unsafe(reinterpret<function<():void>?>(unsafe(reinterpret<uint64>(unsafe(addr(states[0].a))))))[0]))"
    ));
    // An initialised (acyclic) array is built the same way.
    assert!(
        d.contains("var table_0 : pair_t[3] = c2da_records_pair_t_3(c2da_rt_calloc(1ul, 15ul))")
    );
    // Assignment writes bytes; the wrapper is never replaced.
    assert!(d.contains(
        "unsafe(memmove(unsafe(reinterpret<void?>(cell.c2da_storage)), unsafe(reinterpret<void?>(other.c2da_storage)), 4ul))"
    ));
    assert!(!d.contains("    cell = "));
    // A loop-body declaration copies into the object the function holds:
    // no allocation per pass.
    assert!(d.contains(
        "    for (i in range(0, 3)) {\n        unsafe(memmove(unsafe(reinterpret<void?>(local.c2da_storage)), unsafe(reinterpret<void?>(unsafe(unsafe(addr(table_0[0]))[i]).c2da_storage)), 5ul))\n"
    ));
}

#[test]
fn p133_const_record_copy_drops_the_qualifier() {
    let d = transpile_with_libc(
        "p133_const_record_copy",
        c2dascript_transpile::LibcMode::Std,
    );
    // `*file_data` through `const FileData *` is read as an unqualified record.
    assert!(d.contains("var c2da_fresh0 : FileData = *unsafe(reinterpret<FileData?>(file_data))"));
    // A by-value parameter with pointer members is copied out of the
    // read-only daslang reference the same way.
    assert!(d.contains("var iter : FileData = *unsafe(addr<FileData?>(c2da_fresh1))"));
    assert!(d.contains("var n : Nested = *unsafe(addr<Nested?>(c2da_fresh2))"));
    assert!(d.contains("e = *unsafe(addr<FileData?>(empty_0))"));
    // A record without pointer members copies as it is.
    assert!(d.contains("var copy : Plain = *p\n"));
}

#[test]
fn p134_narrow_and_enum_conversions_convert_the_value() {
    let d = transpile_with_libc(
        "p134_pointer_integer_enum_conversions",
        c2dascript_transpile::LibcMode::Std,
    );
    // `(unsigned)p` converts the raw address; it is never a reinterpret of a
    // pointer to a narrower integer.
    assert!(d.contains("span = uint(unsafe(reinterpret<uint64>("));
    assert!(!d.contains("reinterpret<int>(") && !d.contains("reinterpret<uint>("));
    // A byte converted to an enum is first the enum's integer.
    assert!(d.contains("skill = unsafe(reinterpret<skill_t>(uint(*c2da_postinc)))"));
    assert!(d.contains("c = unsafe(reinterpret<skill_t>(uint(*c2da_postinc_0)))"));
    assert!(
        !d.contains("reinterpret<skill_t?>"),
        "the byte is never re-read as an enum"
    );
}

#[test]
fn p135_globals_read_by_initializers_spell_their_zero() {
    let d = transpile_with_libc(
        "p135_static_zero_spelled",
        c2dascript_transpile::LibcMode::Std,
    );
    assert!(d.contains("var x : int = default<int>\n"));
    assert!(d.contains("var arr : int[4] = default<int[4]>\n"));
    assert!(d.contains("var d : double = default<double>\n"));
    // An object no initializer reads keeps daslang's zero-filled declaration.
    assert!(d.contains("var untouched : int\n"));
}

#[test]
fn p140_early_exits_never_strand_a_jump_target() {
    let d = transpile_with_libc(
        "p140_early_exit_jump_targets",
        c2dascript_transpile::LibcMode::Std,
    );
    // Structured back end: the `break` is daslang's own.
    let structured = function_body(&d, "check_list");
    assert!(
        structured.contains(
            "    while (true) {\n        if (n_0.next == head_0) {\n            break\n        }\n"
        ),
        "{structured}"
    );
    assert!(!structured.contains("label"), "{structured}");
    let body = function_body(&d, "check_list_flat");
    // Flat back end: the loop exit is a jump to an out-of-line `return`, not an
    // `if (c) { return }` that daslang's if-return folding would turn into
    // an `else` block holding the loop's labels.
    assert!(
        body.contains("    if (n.next == head) {\n        goto label 7\n    }\n"),
        "{body}"
    );
    assert!(
        body.contains("    goto label 0\n    label 7:\n    return\n    label 4:\n"),
        "{body}"
    );
    assert!(!body.contains("{\n        return\n    }"), "{body}");
}

#[test]
fn p141_integers_widen_to_the_address_before_becoming_pointers() {
    let d = transpile_with_libc(
        "p141_integer_to_pointer_width",
        c2dascript_transpile::LibcMode::Std,
    );
    // The integer is a 64-bit address before it becomes a pointer or a
    // function value; a four-byte operand is never reinterpreted as eight.
    assert!(d.contains("reinterpret<uint8?>(uint64(n))"), "{d}");
    assert!(d.contains("reinterpret<uint8?>(uint64(n_0))"), "{d}");
    assert!(d.contains("return unsafe(reinterpret<action_t>(0xfffffffffffffffful))"));
    assert!(d.contains("return unsafe(reinterpret<action_t>(uint64(n_1)))"));
    assert!(!d.contains("reinterpret<action_t>(-1)"));
}

/// The text of the translated function `name`, from its `def` to its end.
fn function_body<'a>(d: &'a str, name: &str) -> &'a str {
    d.split(&format!("def {name}("))
        .nth(1)
        .and_then(|rest| rest.split("\n}\n").next())
        .unwrap_or_else(|| panic!("{name} is translated"))
}

#[test]
fn p150_object_copies_are_daslang_builtin_copies() {
    let d = transpile_with_libc(
        "p150_object_byte_copies",
        c2dascript_transpile::LibcMode::Std,
    );
    let body = function_body(&d, "main_0");
    // No object copy runs the runtime's byte loop.
    assert!(!body.contains("c2da_rt_memcpy"), "{body}");
    // An assignment between two C objects may overlap exactly: `memmove`,
    // here `words[1] = words[1]`.
    assert!(
        body.contains(
            "unsafe(memmove(unsafe(reinterpret<void?>(unsafe(unsafe(addr(words[0]))[1]).c2da_storage)), \
             unsafe(reinterpret<void?>(unsafe(unsafe(addr(words[0]))[1]).c2da_storage)), 4ul))"
        ),
        "{body}"
    );
    // A copy into a temporary of its own: `memcpy` (the union read out of
    // `*q`, the packed record read out of `*pk`).
    assert!(body.contains("4ul))\n    unsafe(memmove(unsafe(reinterpret<void?>(unsafe(reinterpret<uint64>(p_0))))"), "{body}");
    assert!(
        body.contains("unsafe(reinterpret<void?>(unsafe(reinterpret<uint64>(pk)))), 7ul))"),
        "{body}"
    );
    // A misaligned scalar moves through a typed temporary, four bytes from
    // offset 1 of the packed record.
    assert!(
        body.contains(
            "unsafe(memcpy(unsafe(reinterpret<void?>(unsafe(reinterpret<uint64>(pk)) + 1ul)), \
             unsafe(reinterpret<void?>(unsafe(reinterpret<uint64>(unsafe(addr(c2da_fresh"
        ),
        "{body}"
    );
}

#[test]
fn p151_bitfields_go_through_their_aligned_storage_unit() {
    let d = transpile_with_libc(
        "p151_bitfield_storage_units",
        c2dascript_transpile::LibcMode::Std,
    );
    let body = function_body(&d, "main_0");
    // `color.r` is bits 16..23 of the four-byte unit at offset 0, the
    // record's one field (p177): a shift and a mask on it, never a
    // four-byte copy from byte 2 (two bytes past the record).
    assert!(d.contains("struct color {\n    c2da_bits_0 : uint\n}\n"), "{d}");
    assert!(body.contains("last.c2da_bits_0 >> 16 & 0xff"), "{body}");
    assert!(
        !body.contains("unsafe(reinterpret<uint64>(last)) + 2ul"),
        "{body}"
    );
    // The read-modify-write keeps the other fields of the unit.
    assert!(body.contains("last.c2da_bits_0 = last.c2da_bits_0 & 0xff00ffffu | "), "{body}");
    // A 40-bit field of a `long long` is the eight-byte unit.
    assert!(d.contains("struct wide {\n    c2da_bits_0 : uint64\n}\n"), "{d}");
    assert!(body.contains("(0x123456ul & 0xfffffful) << 40ul"), "{body}");
    // An ordinary field sharing a unit's bytes (`tagged.tag`), and a packed
    // record, keep the storage-backed form; the packed record's field that
    // straddles its unit keeps the byte path, and a bitfield record inside
    // a union goes through the union's bytes.
    assert!(d.contains("struct tagged {\n    c2da_storage : uint64 = c2da_rt_calloc(1ul, 4ul)\n}\n"), "{d}");
    assert!(body.contains(".c2da_storage + 3ul)), 4ul))"), "{body}");
    assert!(
        body.contains("unsafe(unsafe(reinterpret<uint?>(e.c2da_storage))[0]) & 0xfffff000u | 0xabcu & 0xfffu"),
        "{body}"
    );
}

#[test]
fn p152_discarded_postfix_increments_save_no_old_value() {
    let d = transpile_with_libc(
        "p152_discarded_postfix_increments",
        c2dascript_transpile::LibcMode::Std,
    );
    let body = function_body(&d, "main_0");
    // `for` steps, statements and a statement-level comma: no copy.
    assert!(
        body.contains("    while (i < 3) {\n        total += i\n        i += 1\n    }\n"),
        "{body}"
    );
    assert!(
        body.contains("        total += 1\n        i += 1\n        j -= 1\n"),
        "{body}"
    );
    assert!(
        body.contains("    unsafe {\n        p += 1\n    }\n"),
        "{body}"
    );
    // Used values keep the old value: `a[i++]`, `y = i--`, `*q++ = 5`,
    // `while (n--)`.
    assert!(
        body.contains(
            "var c2da_postinc_2 : int = i\n    i += 1\n    a[c2da_postinc_2] = 7"
        ),
        "{body}"
    );
    assert!(
        body.contains("var c2da_postinc_4 : int = i\n    i -= 1\n    y = c2da_postinc_4"),
        "{body}"
    );
    // `*q++ = 5` with a value that cannot observe `q`: store, then step.
    assert!(body.contains("    *q = 5\n    unsafe {\n        q += 1\n    }\n"), "{body}");
    assert!(
        body.contains(
            "var c2da_postinc_6 : int = n\n        n -= 1\n        if (c2da_postinc_6 == 0) {\n            break\n"
        ),
        "{body}"
    );
}

#[test]
fn p153_self_updates_are_compound_assignments() {
    let d = transpile_with_libc(
        "p153_compound_assignment_spelling",
        c2dascript_transpile::LibcMode::Std,
    );
    let body = function_body(&d, "main_0");
    for update in [
        "x += 3",
        "x *= 4",
        "x /= 3",
        "x %= 7",
        "x <<= 2",
        "x >>= 1",
        "x |= 64",
        "x &= 127",
        "x ^= 5",
        "u >>= 4u",
        "ll -= 100l",
        "ull <<= 40ul",
        "f += 0.25",
        "d -= 0.5lf",
        "arr[i] *= 3",
        "arr[i - 1] += arr[i]",
        "*p -= 1",
        "a.count += 1",
        "pa.mean += 0.5lf",
        "global_total *= 2",
        "i += k",
    ] {
        assert!(
            body.contains(&format!("    {update}\n")),
            "{update}: {body}"
        );
    }
    // Kept: a narrow storage type computed in `int`, a call in the value, and
    // the place as the right operand.
    assert!(body.contains("    b = uint8(int(b) + 1)\n"), "{body}");
    assert!(body.contains("    s = int16(int(s) * 3)\n"), "{body}");
    assert!(body.contains("    x = x + twice(x)\n"), "{body}");
    assert!(body.contains("    x = 1 - x\n"), "{body}");
    // A typed pointer stepped by an `int` or `int64` is a pointer `+=` in an
    // `unsafe` block.
    assert!(
        body.contains(
            "    unsafe {\n        walk += 1\n    }\n    unsafe {\n        walk += stride\n    }\n"
        ),
        "{body}"
    );
}

#[test]
fn p154_disjoint_site_temporaries_share_their_variables() {
    let d = transpile_with_libc(
        "p154_coalesced_temporaries",
        c2dascript_transpile::LibcMode::Std,
    );
    let body = function_body(&d, "step");
    // Seven enumeration temporaries of the `switch` arms are two variables,
    // four post-increment values two, two field addresses one.
    assert!(
        body.contains(
            "    var r : int\n    var keep : int?\n    var c2da_fresh7 : answer_t = answer_t()\n    \
             var c2da_fresh2 : answer_t = answer_t()\n    var c2da_postinc : int\n    \
             var c2da_fresh4 : int?\n    var c2da_postinc_2 : int\n    r = 0\n"
        ),
        "{body}"
    );
    // Overlapping lives keep their own variables: `s->n-- + s->n++`.
    assert!(
        body.contains(
            "    c2da_postinc = s.n\n    s.n = c2da_postinc - 1\n    c2da_postinc_2 = s.n\n"
        ),
        "{body}"
    );
    // A chain assignment's two values are both live at once.
    assert!(
        body.contains("    s.c = c2da_fresh7\n    c2da_fresh2 = c2da_fresh7\n"),
        "{body}"
    );
}

/// `extern int g;` with no definition in the unit is another unit's object:
/// refused with its location, never a fresh `var g` (C11 6.2.2p4).  The two
/// defining shapes in the same fixture — `extern` then a definition, and a
/// tentative definition — must not trip the rule: the error names only the
/// undefined one.
#[test]
fn p172_undefined_extern_object_is_refused_not_declared() {
    let error = transpile_error("p172_extern_object_undefined");
    assert!(
        error.contains("operation=top-level declaration lowering"),
        "{error}"
    );
    assert!(
        error.contains(
            "unsupported external object: owned_elsewhere is declared extern and defined \
             nowhere in this translation unit"
        ),
        "{error}"
    );
    assert!(
        error.contains("p172_extern_object_undefined.c:17:1"),
        "the diagnostic must point at the extern declaration: {error}"
    );
    assert!(
        !error.contains("defined_later") && !error.contains("tentative"),
        "a definition in the unit is never an external object: {error}"
    );
}

#[test]
fn p171_calls_keep_their_side_effects_and_null_casts_are_null() {
    let d = transpile_with_libc(
        "p171_unused_call_side_effects",
        c2dascript_transpile::LibcMode::Std,
    );
    // daslang infers `decrease_ammo` free of side effects and would remove an
    // unused call to it; every defined function states the C fact instead.
    for name in ["decrease_ammo", "bump", "clear_state"] {
        let at = d
            .find(&format!("def {name}("))
            .unwrap_or_else(|| panic!("{name} is translated:\n{d}"));
        let head = &d[..at];
        let annotation = head.rfind('[').map(|i| &head[i..]).unwrap_or("");
        assert!(
            annotation.contains("sideeffects"),
            "{name}: {annotation}\n{d}"
        );
    }
    // `(state_t *) S_NULL` with an enumeration constant 0 is the null pointer.
    assert!(d.contains("= null\n"), "{d}");
    assert!(!d.contains("reinterpret<state_t?>(0)"), "{d}");
}

#[test]
fn p173_pointer_subscript_of_its_own_type_has_no_reinterpret() {
    let d = transpile_with_libc(
        "p173_same_type_pointer_index",
        c2dascript_transpile::LibcMode::Std,
    );
    // Globals declared through the `lighttable_t` typedef, `const` parameters
    // and plain locals are indexed as they are.
    let main = function_body(&d, "main_0");
    assert!(
        main.contains("direct += uint(unsafe(dc_colormap[int(unsafe(dc_source[i_4 & 127]))]))"),
        "{main}"
    );
    let typedef = function_body(&d, "sum_typedef_bytes");
    assert!(
        typedef.contains("acc += uint(unsafe(map[int(unsafe(src[i_1]))]))"),
        "{typedef}"
    );
    // `char *` and `unsigned char *` each index their own pointer; neither
    // is reinterpreted to the other.
    let signed = function_body(&d, "sum_signed_chars");
    assert!(
        signed.contains("acc_0 += int(unsafe(bytes[i_2])) + int(unsafe(text[i_2]))"),
        "{signed}"
    );
    assert!(
        signed.contains("bytes = unsafe(reinterpret<uint8?>(text))"),
        "{signed}"
    );
    // A `void *` cast to `unsigned char *` is a conversion and stays one.
    let void = function_body(&d, "sum_void");
    assert!(
        void.contains("unsafe(unsafe(reinterpret<uint8?>(blob))[i_3])"),
        "{void}"
    );
}

#[test]
fn p174_post_step_store_is_store_then_step_when_the_value_cannot_see_the_pointer() {
    let d = transpile_with_libc("p174_post_step_store", c2dascript_transpile::LibcMode::Std);
    let main = function_body(&d, "main_0");
    // A local pointer and a value that cannot reach it: the store, then the
    // step — a pure value, a read through another pointer, a global read.
    assert!(
        main.contains("        *dest = table_0[i_0 & 15]\n        unsafe {\n            dest += 1\n        }\n"),
        "{main}"
    );
    assert!(
        main.contains(
            "        *dest = *c2da_postinc\n        unsafe {\n            dest += 1\n        }\n"
        ),
        "{main}"
    );
    assert!(
        main.contains("    *mark = uint8(level)\n    unsafe {\n        mark += 1\n    }\n"),
        "{main}"
    );
    // A global pointer with a value that reads no memory.
    assert!(
        main.contains("    *out = 42u8\n    unsafe {\n        out += 1\n    }\n"),
        "{main}"
    );
    assert!(
        main.contains("    *out = uint8(level + 1)\n    unsafe {\n        out += 1\n    }\n"),
        "{main}"
    );
    // The post-decrement form.
    assert!(
        main.contains("    *back = 1u8\n    unsafe {\n        back -= 1\n    }\n    *back = 2u8\n    unsafe {\n        back -= 1\n    }\n    *back = 3u8\n"),
        "{main}"
    );
    // The copy stays when the value names the pointer, reads memory while
    // the pointer is a global, or calls a function.
    assert!(
        main.contains("    var c2da_postinc_0 : uint8? = mark\n    unsafe {\n        mark += 1\n    }\n    *c2da_postinc_0 = uint8(mark != null ? 1 : 0)\n"),
        "{main}"
    );
    assert!(
        main.contains("    var c2da_postinc_2 : uint8? = out\n    unsafe {\n        out += 1\n    }\n    var c2da_postinc_3 : uint8 const? = in_0\n    unsafe {\n        in_0 += 1\n    }\n    *c2da_postinc_2 = *c2da_postinc_3\n"),
        "{main}"
    );
    assert!(
        main.contains("    *c2da_postinc_6 = next_level()\n"),
        "{main}"
    );
    assert!(
        main.contains("    *c2da_postinc_7 = out_is_set()\n"),
        "{main}"
    );
}

#[test]
fn p170_enum_constant_reads_are_literals() {
    let d = transpile_with_libc(
        "p170_enum_constant_literals",
        c2dascript_transpile::LibcMode::Std,
    );
    // The module names every constant, as a `let` of the constant's type.
    assert!(d.contains("let TRUE : int = 1\n"), "{d}");
    assert!(d.contains("let SCALE : int = -3\n"), "{d}");
    assert!(d.contains("let BIG : uint = 0xf0000000u\n"), "{d}");
    assert!(d.contains("let STATE_RUN : int = 5\n"), "{d}");
    // File-scope initializers read the values.
    assert!(d.contains("var bound : int = 4 * 2\n"), "{d}");
    // A body reads none of the names: an assignment's right-hand side, a
    // store through a pointer, a loop bound, a named-enum store and
    // arithmetic are all the literal.
    let wrapped = function_body(&d, "wrapped");
    assert!(wrapped.contains("    flag = 0\n"), "{wrapped}");
    assert!(wrapped.contains("    flag = 1\n"), "{wrapped}");
    let step = function_body(&d, "step");
    assert!(step.contains("    for (j in range(0, 4)) {\n"), "{step}");
    assert!(step.contains("    *out = 6\n"), "{step}");
    assert!(
        step.contains("    m.state = unsafe(reinterpret<state_t>(6u))\n"),
        "{step}"
    );
    assert!(step.contains(" * -3 + j\n"), "{step}");
    for name in [
        "TRUE",
        "FALSE",
        "SCALE",
        "CHANNEL_COUNT",
        "STATE_RUN",
        "STATE_DONE",
        "BIG",
    ] {
        for body in [&wrapped, &step, &function_body(&d, "main_0")] {
            assert!(
                !body.contains(name),
                "{name} read by name in a translated body:\n{body}"
            );
        }
    }
}

#[test]
fn p175_counted_loops_are_range_loops() {
    let d = transpile_with_libc("p175_counted_loops", c2dascript_transpile::LibcMode::Std);
    // `do … while (count--)`, `count` unnamed in the body and dead after:
    // `count + 1` passes, as a 64-bit unsigned count so `count < 0` and
    // `INT_MAX` run exactly as C's wrap does.
    let body = function_body(&d, "count_down");
    assert!(
        body.contains("    for (c2da_iter in urange64(0ul, uint64(uint(count)) + 1ul)) {\n        total += 2\n    }\n"),
        "{body}"
    );
    // `continue` is daslang's own: the range steps the counter.
    let body = function_body(&d, "count_continue");
    assert!(
        body.contains("        if ((total_4 & 1) != 0) {\n            continue\n        }\n"),
        "{body}"
    );
    // A counter re-initialised by an enclosing loop is dead after the inner.
    let body = function_body(&d, "count_in_outer_loop");
    assert!(
        body.contains("    for (r in range(0, rows)) {\n        count_5 = cols\n        for (c2da_iter_2 in urange64(0ul, uint64(uint(count_5)) + 1ul)) {\n"),
        "{body}"
    );
    // Fallbacks keep today's loop: the body reads the counter, the counter
    // is read after the loop, the counter is unsigned.
    for name in ["count_read_in_body", "count_live_after", "count_unsigned"] {
        let body = function_body(&d, name);
        assert!(
            body.contains("    while (true) {\n") && !body.contains("urange64"),
            "{name}: {body}"
        );
    }
    // `for (int i = 0; i < n; i++)`: the C variable is the loop variable and
    // has no hoisted `var`; a declaration before the loop is dropped too.
    let body = function_body(&d, "index_sum");
    assert!(
        body.contains("    for (i in range(0, n)) {\n        total_6 += i * i\n    }\n") && !body.contains("var i"),
        "{body}"
    );
    let body = function_body(&d, "index_declared_before");
    assert!(
        body.contains("    for (i_0 in range(1, n_0)) {\n") && !body.contains("var i_0"),
        "{body}"
    );
    // Named before the loop and dead after it: a fresh variable iterates
    // from the C variable's value.
    let body = function_body(&d, "index_reused_before");
    assert!(
        body.contains("    i_8 = 0\n    for (c2da_i_8 in range(i_8, n_8)) {\n        total_14 += c2da_i_8\n    }\n"),
        "{body}"
    );
    // Unsigned, nested, `continue` and `break` in the body.
    let body = function_body(&d, "index_unsigned");
    assert!(body.contains("    for (i_6 in urange(2u, n_6)) {\n"), "{body}");
    let body = function_body(&d, "nested");
    assert!(
        body.contains("    for (r_0 in range(0, rows_0)) {\n        for (c in range(0, cols_0)) {\n            if (c == r_0) {\n                continue\n            }\n"),
        "{body}"
    );
    let body = function_body(&d, "index_continue_and_break");
    assert!(body.contains("    for (i_7 in range(0, n_7)) {\n"), "{body}");
    // Fallbacks: `i` live after the loop (with and without `break`), `i`
    // written in the body, the bound written in the body or read through
    // a pointer.
    for name in [
        "index_live_after",
        "index_break_live_after",
        "index_written_in_body",
        "bound_changes",
        "bound_through_pointer",
    ] {
        let body = function_body(&d, name);
        assert!(
            body.contains("    while (i_") && !body.contains(" in range("),
            "{name}: {body}"
        );
    }
}

#[test]
fn p160_loops_are_daslang_loops() {
    let d = transpile_with_libc("p160_structured_loops", c2dascript_transpile::LibcMode::Std);
    for name in [
        "for_loops",
        "while_loops",
        "do_loops",
        "nested",
        "early_return",
        "fresh_per_pass",
        "address_taken",
        "forever",
    ] {
        let body = function_body(&d, name);
        assert!(
            !body.contains("label") && !body.contains("goto"),
            "{name}: {body}"
        );
    }
    let body = function_body(&d, "for_loops");
    // A counted `for` is a range loop (p175), whose `continue` is daslang's
    // own; a `for` with a step of its own continues through that step,
    // written before the `continue`.
    assert!(
        body.contains("    for (i in range(0, n)) {\n        if (i % 3 == 0) {\n            continue\n        }\n"),
        "{body}"
    );
    assert!(
        body.contains("            a += 1\n            b -= 7\n            continue\n"),
        "{body}"
    );
    // A condition with statements of its own is tested at the top of the body.
    let body = function_body(&d, "while_loops");
    assert!(
        body.contains(
            "    while (true) {\n        value = next_value(unsafe(addr<int?>(cursor_0)))\n        if (value == 0) {\n            break\n        }\n"
        ),
        "{body}"
    );
    // `do`/`while`: the condition at the bottom, and again before `continue`;
    // `do … while (0)` is its body, or a loop its `break` leaves.
    let body = function_body(&d, "do_loops");
    assert!(
        body.contains("        if (k == 6) {\n            if (k >= limit) {\n                break\n            }\n            continue\n        }\n"),
        "{body}"
    );
    assert!(
        body.contains("    total_1 += 1000\n    while (true) {\n"),
        "{body}"
    );
    assert!(
        body.contains("        if (total_1 > 3000) {\n            break\n        }\n        total_1 += 1\n        break\n    }\n"),
        "{body}"
    );
    // A loop body's C declaration is re-initialised on every pass.
    let body = function_body(&d, "fresh_per_pass");
    assert!(
        body.contains("    for (i_2 in range(0, 4)) {\n        counter = 10\n        scratch = fixed_array<int>(i_2, i_2 + 1, i_2 + 2)\n"),
        "{body}"
    );
    // A function that leaves only through a `return` in an endless loop ends
    // on a `return` daslang can see.
    let body = function_body(&d, "forever");
    assert!(
        body.ends_with(
            "    panic(\"control reached the end of a non-void function\")\n    return 0"
        ),
        "{body}"
    );
}

#[test]
fn p161_switch_is_a_label_region_or_a_chain() {
    let d = transpile_with_libc(
        "p161_structured_switch",
        c2dascript_transpile::LibcMode::Std,
    );
    let body = function_body(&d, "run");
    // The region sits inside the loop body: dispatch, arms, end.
    assert!(
        body.contains("        if (c2da_fresh0 >= 0 && c2da_fresh0 <= 7) {\n            goto c2da_fresh0 + 4\n        }\n        goto label 0\n"),
        "{body}"
    );
    // The loop's `continue` inside an `if` of an arm moves out of line; the
    // early `return` too.
    assert!(
        body.contains("[i])) == 4) {\n            goto label 1\n        }\n"),
        "{body}"
    );
    assert!(
        body.contains("        label 1:\n        continue\n"),
        "{body}"
    );
    assert!(
        body.contains("        if (acc > 1000) {\n            goto label 2\n        }\n"),
        "{body}"
    );
    assert!(
        body.contains("        label 2:\n        return -acc\n"),
        "{body}"
    );
    // The site temporary of the region's list is hoisted for AOT.
    assert!(body.contains("    var c2da_postinc : int\n"), "{body}");
    // A switch that ends the body of a range loop (p175) sends its `break`
    // and its holes to the end, which is the loop's own `continue`.
    let body = function_body(&d, "tally");
    assert!(body.contains("    for (i_0 in range(0, n_0)) {\n"), "{body}");
    assert!(
        body.contains("        continue\n        label 5:\n        label 6:\n        continue\n        label 0:\n"),
        "{body}"
    );
    // A switch that ends a void function: `break` is `return`, and the empty
    // last arm and the holes share a trampoline.
    let body = function_body(&d, "store");
    assert!(
        body.contains("    if (x >= 1 && x <= 9) {\n        goto x - 1\n    }\n    return\n    label 6:\n    label 8:\n    return\n"),
        "{body}"
    );
    // Small switches whose arms never fall through are `if`/`elif` chains.
    let body = function_body(&d, "in_arm");
    assert!(
        body.contains("    if (a != 0) {\n        if (b == 1) {\n            r = 1\n        } elif (b == 2) {\n            r = 2\n        }\n    } else {\n"),
        "{body}"
    );
    let body = function_body(&d, "temporaries");
    assert!(!body.contains("label"), "{body}");
    assert!(
        body.contains("        } else {\n            var c2da_postinc_1 : int = y\n"),
        "{body}"
    );
    let body = function_body(&d, "no_cases");
    assert!(body.contains("    x_1 += 1\n    return x_1"), "{body}");
    // An `if` arm holding an inner region and the outer `break` is spliced
    // into the outer region's labels, where that jump can land.
    let body = function_body(&d, "break_past_region");
    assert!(
        body.contains(
            "    label 0:\n    if (b_1 == 0) {\n        goto label 4\n    }\n    if (c == 1) {\n"
        ),
        "{body}"
    );
    assert!(
        body.contains("    label 3:\n    goto label 6\n    label 4:\n    r_1 = 9\n"),
        "{body}"
    );
}

#[test]
fn p162_bodies_with_goto_or_nested_cases_stay_flat() {
    let d = transpile_with_libc(
        "p162_structured_fallback",
        c2dascript_transpile::LibcMode::Std,
    );
    for name in [
        "forward_goto",
        "backward_goto",
        "irreducible",
        "duff",
        "before_first_case",
    ] {
        let body = function_body(&d, name);
        assert!(
            body.contains("label 0:") && !body.contains("while"),
            "{name} is flat: {body}"
        );
    }
    let body = function_body(&d, "structured");
    assert!(body.contains("    for (i_0 in range(0, n_1)) {\n"), "{body}");
    assert!(!body.contains("label"), "{body}");
}

#[test]
fn n12_typedef_record_field_is_diagnosed_not_dropped() {
    assert_precise_translation_error(
        "n12_typedef_record_field_unsupported",
        "operation=type declaration lowering",
        "Struct",
        "unsupported record field type LongDouble in field x",
    );
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
        "failures = 0\n",
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
    assert!(d.contains("var nil : uint8?\n") && d.contains("nil = null\n"));
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
    // The record's layout is proven, so the padded field is reached by name,
    // and the module asserts that daslang puts it at Clang's offset 8.
    assert!(
        d.contains("    object.value = 0x10203040u\n"),
        "a field of a proven record is accessed by name"
    );
    assert!(d.contains(
        "static_assert(typeinfo offsetof<value>(type<padded_object>) == 8, \"C layout of padded_object: offsetof value\")"
    ));
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
        d.contains("unsafe(memcpy("),
        "packed access must go through a byte copy"
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
    // `object->inner.count` is a by-name path through two proven records;
    // the proof pins `inner` at Clang's offset 4.
    assert!(
        d.contains("    object.inner.count = 0x10203040u\n"),
        "a nested field of proven records is accessed by name"
    );
    assert!(d.contains(
        "static_assert(typeinfo offsetof<inner>(type<nested_outer>) == 4, \"C layout of nested_outer: offsetof inner\")"
    ));
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

/// The diagnostic a negative fixture's translation fails with, under `libc`.
fn transpile_error_with_libc(name: &str, libc: c2dascript_transpile::LibcMode) -> String {
    let c_path = Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .join(format!("tests/syntax/{}.c", name));
    assert!(c_path.exists(), "C file not found: {:?}", c_path);
    let (_td, cc_path) = c2dascript_transpile::create_temp_compile_commands(&[c_path]);
    let temp = tempfile::tempdir().expect("temporary diagnostic output directory");
    let config = c2dascript_transpile::TranspilerConfig {
        output_dir: Some(temp.path().join("das")),
        libc,
        ..Default::default()
    };
    c2dascript_transpile::transpile_checked(config, &cc_path, &["-w"])
        .expect_err("negative fixture must return TranslationError")
        .to_string()
}

#[test]
fn p110_std_string_extras_are_exact() {
    let d = transpile_with_libc(
        "p110_std_string_extras",
        c2dascript_transpile::LibcMode::Std,
    );
    // `strdup` is a raw-heap block `free` can release, copied terminator
    // included, and `NULL` with ENOMEM when the heap is exhausted.
    assert!(d.contains("let base : uint64 = c2da_rt_malloc(n + 0x1ul)"));
    assert!(d.contains(
        "    while (i <= n) {\n        c2da_std_raw_put(base, i, c2da_std_raw_byte(s, i))"
    ));
    assert!(d.contains("        c2da_std_set_errno(12)\n        return 0x0ul"));
    assert!(d.contains("unsafe(reinterpret<int8?>(c2da_std_strdup("));
    // The case-insensitive comparisons answer glibc's byte difference.
    assert!(d.contains("let ca = c2da_std_tolower(c2da_std_raw_byte(a, i))"));
    assert!(d.contains("            return ca - cb\n"));
    assert!(d.contains("def c2da_std_strncasecmp(a : uint64; b : uint64; n : uint64) : int"));
    assert!(d.contains("    while (i < n) {\n        let ca = c2da_std_tolower("));
    // `atof` is `strtod(nptr, NULL)`.
    assert!(d.contains("    return c2da_std_strtod(nptr, 0x0ul)\n"));
    // `abs` and `fabs` reach the std helpers from Clang's builtin shape too,
    // and `fabs` clears the sign bit rather than comparing with zero.
    assert!(d.contains("c2da_std_abs(-5)"));
    assert!(d.contains("var y : double = c2da_std_fabs(x)"));
    assert!(d.contains(
        "return unsafe(reinterpret<double>(unsafe(reinterpret<uint64>(x)) & 0x7ffffffffffffffful))"
    ));
    assert!(!d.contains("c2da_fabs_double"));
    // `system` has no command processor: `system(NULL)` is 0, any command
    // runs nothing and is -1 with ENOSYS.
    assert!(d.contains(
        "def c2da_std_system(command : uint64) : int {\n    if (command == 0x0ul) {\n        return 0\n    }\n    c2da_std_set_errno(38)\n    return -1\n}"
    ));
    // `mkdir` never touches the file system: -1 with EPERM.
    assert!(d.contains(
        "def c2da_std_mkdir(path : uint64; mode : uint) : int {\n    c2da_std_set_errno(1)\n    return -1\n}"
    ));
    assert!(d.contains("c2da_std_mkdir(") && d.contains(", 0x1edu)"));
    assert!(!d.contains("fio::mkdir") && !d.contains(" mkdir("));
}

#[test]
fn p111_std_sscanf_implements_the_integer_conversions() {
    let d = transpile_with_libc("p111_std_sscanf", c2dascript_transpile::LibcMode::Std);
    assert!(
        d.contains("def c2da_std_sscanf(s : uint64; f : uint64; args : array<C2daVaArg>) : int")
    );
    // The store targets are raw lanes of the canonical variadic payload.
    assert!(d.contains("c2da_std_sscanf(unsafe(reinterpret<uint64>(input)), unsafe(reinterpret<uint64>(format)), [C2daVaArg(tag = 3,"));
    // glibc's subject: `0x` is consumed only for a base that takes it.
    assert!(d.contains("if ((b | 32) == 120) {"));
    // The value is `strtol`'s or `strtoul`'s, saturated with ERANGE, and its
    // low 32 bits are what is stored.
    assert!(d.contains(
        "value = c2da_std_strto(s + start, 0x0ul, base, 0x7ffffffffffffffful, 0x8000000000000000ul)"
    ));
    assert!(d.contains(
        "value = c2da_std_strto(s + start, 0x0ul, base, 0xfffffffffffffffful, 0xfffffffffffffffful)"
    ));
    assert!(d.contains("unsafe(unsafe(reinterpret<uint?>(cell))[0]) = uint(value & 0xfffffffful)"));
    // A computed format is checked at run time, loudly.
    assert!(
        d.contains("panic(\"--libc std: sscanf conversion is not implemented: \" + build_string(")
    );
    assert!(d.contains(
        "panic(\"--libc std: sscanf has no pointer argument to store a conversion through\")"
    ));
}

#[test]
fn p112_std_sscanf_rejects_unimplemented_conversions() {
    let error = transpile_error_with_libc(
        "p112_std_sscanf_unsupported",
        c2dascript_transpile::LibcMode::Std,
    );
    assert!(
        error.contains("--libc std: sscanf conversion `%5d` is not implemented"),
        "missing the conversion: {error}"
    );
    assert!(
        error.contains("p112_std_sscanf_unsupported.c:8:31"),
        "missing the format's source location: {error}"
    );
}

#[test]
fn p176_union_fields_lie_inline_in_natural_records() {
    let d = transpile_with_libc(
        "p176_inline_union_fields",
        c2dascript_transpile::LibcMode::Std,
    );
    // A union field is the unsigned integer of its size and alignment (a
    // fixed array of them when wider); the record keeps its own fields and
    // its layout proof covers the union field.  The union itself keeps its
    // wrapper for the objects that name it on their own.
    assert!(d.contains("struct thinker_s {\n    prev : thinker_s?\n    next : thinker_s?\n    function_0 : uint64\n}\n"));
    assert!(d.contains("struct mobj_s {\n    thinker : thinker_s\n    x : int\n"));
    assert!(d.contains("struct sample {\n    id : int\n    bits : uint\n    tail : int\n}\n"));
    assert!(d.contains("struct mixed {\n    tag : int8\n    w : uint64\n}\n"));
    assert!(d.contains("struct bytes3 {\n    u : uint8[3]\n    end : int8\n}\n"));
    assert!(d.contains("struct actionf_t {\n    c2da_storage : uint64 = c2da_rt_calloc(1ul, 8ul)\n}\n"));
    assert!(d.contains("static_assert(typeinfo offsetof<function_0>(type<thinker_s>) == 16, \"C layout of thinker_s: offsetof function_0\")"));
    assert!(d.contains("static_assert(typeinfo offsetof<bits>(type<sample>) == 4, \"C layout of sample: offsetof bits\")"));
    // A union aligned beyond eight bytes has no inline storage: the record
    // that holds it stays storage-backed.
    assert!(d.contains("struct wide {\n    c2da_storage : uint64 = c2da_rt_calloc(1ul, 32ul)\n}\n"));
    // A packed record embedded by value is inline storage of its own
    // alignment; its members are read through their own types at the
    // field's offset, and the record's other fields go by name.  A bitfield
    // record is natural (p177) and an ordinary field.
    assert!(d.contains("struct actor {\n    id : int\n    spawn : uint8[10]\n    tint : color\n    after : int\n}\n"));
    assert!(d.contains("struct mapthing {\n    c2da_storage : uint64 = c2da_rt_calloc(1ul, 10ul)\n}\n"));
    let body = function_body(&d, "main_0");
    assert!(
        body.contains("unsafe(unsafe(reinterpret<int16?>(unsafe(reinterpret<uint64>(unsafe(addr(ac.spawn))))))[3]) = int16(int(unsafe(unsafe(reinterpret<int16?>(unsafe(reinterpret<uint64>(ap))))[5])) + 1)"),
        "{body}"
    );
    assert!(body.contains("i64 = int64(ap.after)"), "{body}");
    assert!(body.contains("int(ap.tint.c2da_bits_0 >> 16 & 0xff)"), "{body}");
    assert!(
        body.contains("    ap.tint.c2da_bits_0 = ap.tint.c2da_bits_0 & 0xff00ffffu | (200u & 0xffu) << 16u\n"),
        "{body}"
    );
    // The other fields of the record are reached by name, through the
    // embedded record too.
    let body = function_body(&d, "think_mobj");
    assert!(body.contains("    mo.x += 2\n    mo.y -= 1\n"), "{body}");
    // A function-pointer member is read, compared and called through its
    // own type at the field's offset; the removal mark is a reinterpret.
    let body = function_body(&d, "run_thinkers");
    assert!(
        body.contains("if (unsafe(unsafe(reinterpret<actionf_v?>(unsafe(reinterpret<uint64>(t_0))))[2]) == unsafe(reinterpret<actionf_v>(0xfffffffffffffffful))) {"),
        "{body}"
    );
    assert!(
        body.contains("invoke(unsafe(unsafe(reinterpret<actionf_p1?>(unsafe(reinterpret<uint64>(t_0))))[2]), unsafe(reinterpret<uint8?>(t_0)))"),
        "{body}"
    );
    assert!(body.contains("        t_0 = unsafe(reinterpret<thinker_s?>(t_0.next))\n"), "{body}");
    // A malloc'd record is the raw heap block typed as the record; a store
    // into the union member of the embedded thinker is at Clang's offset.
    let body = function_body(&d, "spawn");
    assert!(
        body.contains("    unsafe(unsafe(reinterpret<actionf_p1?>(unsafe(reinterpret<uint64>(mo_1))))[2]) = @@think_mobj\n"),
        "{body}"
    );
    let body = function_body(&d, "main_0");
    // A member whose type is the storage type is the field itself.
    assert!(body.contains("    sp.bits = 0x40490fdbu\n"), "{body}");
    // Members of a union field of a local record are read through the
    // field's address; a member of an rvalue record's union is bound first.
    assert!(
        body.contains("unsafe(unsafe(reinterpret<float?>(unsafe(reinterpret<uint64>(unsafe(addr(s_1.bits))))))[0])"),
        "{body}"
    );
    assert!(
        body.contains("unsafe(unsafe(reinterpret<uint8?>(unsafe(reinterpret<uint64>(unsafe(addr(t_1.bits))))))[0]) = 0xffu8\n"),
        "{body}"
    );
    assert!(body.contains("    var c2da_fresh9 : uint = make_sample(3, 0.5).bits\n"), "{body}");
    // A union value assigned to the field, and the field assigned to a
    // union object, copy the union's bytes; the pointer to the member and
    // to the union are the field's address.
    assert!(
        body.contains("unsafe(memmove(unsafe(reinterpret<void?>(unsafe(reinterpret<uint64>(unsafe(addr(s_1.bits)))))), unsafe(reinterpret<void?>(c2da_fresh8.c2da_storage)), 4ul))"),
        "{body}"
    );
    assert!(
        body.contains("unsafe(memmove(unsafe(reinterpret<void?>(unsafe(reinterpret<uint64>(sp)) + 4ul)), unsafe(reinterpret<void?>(c2da_fresh10.c2da_storage)), 4ul))"),
        "{body}"
    );
    assert!(body.contains("    var fnp : actionf_t?\n"), "{body}");
    assert!(
        body.contains("var c2da_fresh3 : actionf_p1? = unsafe(reinterpret<actionf_p1?>(unsafe(reinterpret<uint64>(unsafe(addr(pool[1].thinker.function_0))))))"),
        "{body}"
    );
    // The braced initializer of a union field reads the storage out of the
    // wrapper the initializer builds.
    let body = function_body(&d, "make_sample");
    assert!(
        body.contains("s_0 = sample(id = id, bits = unsafe(unsafe(reinterpret<uint?>(c2da_fresh2.c2da_storage))[0]), tail = id * 2)"),
        "{body}"
    );
}

#[test]
fn p177_bitfield_records_are_natural_with_unit_fields() {
    let d = transpile_with_libc(
        "p177_natural_bitfield_records",
        c2dascript_transpile::LibcMode::Std,
    );
    // Every run of bitfields sharing a storage unit is one unsigned integer
    // of the unit's size; the ordinary fields keep their own; the layout
    // proof asserts each unit's offset once.
    assert!(d.contains("struct color {\n    c2da_bits_0 : uint\n}\n"), "{d}");
    assert!(
        d.contains("struct packet {\n    kind : int\n    c2da_bits_0 : uint\n    c2da_bits_1 : uint16\n    c2da_bits_2 : uint8\n    tail : int16\n}\n"),
        "{d}"
    );
    assert!(d.contains("struct pixel {\n    x : int\n    c : color\n    y : int\n}\n"), "{d}");
    assert!(d.contains("static_assert(typeinfo offsetof<c2da_bits_0>(type<color>) == 0, \"C layout of color: offsetof c2da_bits_0\")"));
    assert!(d.contains("static_assert(typeinfo offsetof<c2da_bits_1>(type<packet>) == 8, \"C layout of packet: offsetof c2da_bits_1\")"));
    assert!(d.contains("static_assert(typeinfo offsetof<c2da_bits_2>(type<packet>) == 10, \"C layout of packet: offsetof c2da_bits_2\")"));
    assert!(d.contains("static_assert(typeinfo offsetof<tail>(type<packet>) == 12, \"C layout of packet: offsetof tail\")"));
    // A packed record, overlapping units of different sizes and a unit an
    // ordinary field shares stay storage-backed.
    assert!(d.contains("struct tight {\n    c2da_storage : uint64 = c2da_rt_calloc(1ul, 5ul)\n}\n"), "{d}");
    assert!(d.contains("struct mixed_units {\n    c2da_storage : uint64 = c2da_rt_calloc(1ul, 4ul)\n}\n"), "{d}");
    assert!(d.contains("struct tagged {\n    c2da_storage : uint64 = c2da_rt_calloc(1ul, 4ul)\n}\n"), "{d}");
    // Doom's frame hash: the palette entry is a value copy, each field a
    // shift and a mask on the word; no allocation and no byte copy.
    let body = function_body(&d, "hash_frame");
    assert!(
        body.contains("rgb = (c.c2da_bits_0 >> 16 & 0xff) << 16u | (c.c2da_bits_0 >> 8 & 0xff) << 8u | c.c2da_bits_0 & 0xff\n"),
        "{body}"
    );
    assert!(!body.contains("calloc") && !body.contains("memcpy"), "{body}");
    // Through a pointer: a read-modify-write of the unit by name.
    let body = function_body(&d, "set_color");
    assert!(body.contains("    p.c2da_bits_0 = p.c2da_bits_0 & 0xff00ffffu | (r & 0xffu) << 16u\n"), "{body}");
    assert!(body.contains("    p.c2da_bits_0 = p.c2da_bits_0 & 0xffffff00u | b & 0xffu\n"), "{body}");
    assert!(!body.contains("memcpy"), "{body}");
    // Signed fields are sign-extended, a field as wide as its unit is the
    // unit, a one-byte unit computes in `uint`.
    let body = function_body(&d, "sum_packet");
    assert!(body.contains("var c2da_fresh0 : int = int(unsafe(reinterpret<packet?>(p_0)).c2da_bits_0 & 0x3f)\n"), "{body}");
    assert!(body.contains("        c2da_fresh0 |= -64\n"), "{body}");
    assert!(body.contains("int(unsafe(reinterpret<packet?>(p_0)).c2da_bits_1)"), "{body}");
    assert!(body.contains("uint8(uint(unsafe(reinterpret<packet?>(p_0)).c2da_bits_2) >> 4 & 0xf)"), "{body}");
    // Initializers compose the units; constant ones fold into one word.
    assert!(
        d.contains("var palette : color[4] = fixed_array<color>(color(c2da_bits_0 = 0xff030201u), color(c2da_bits_0 = 0x0u), color(c2da_bits_0 = 0x1c80000u), color(c2da_bits_0 = 0x70707u))\n"),
        "{d}"
    );
    let body = function_body(&d, "main_0");
    assert!(
        body.contains("    pk = packet(kind = 1, c2da_bits_0 = 0xfeee907bu, c2da_bits_1 = uint16(0xffff), c2da_bits_2 = 0xc9u8, tail = int16(-3))\n"),
        "{body}"
    );
    assert!(body.contains("    px = pixel(x = 4, c = color(c2da_bits_0 = 0x4030201u), y = 5)\n"), "{body}");
    // A copy is a value copy; stores go directly to the object, an array
    // element, an embedded record, a malloc'd record.
    assert!(body.contains("    d = c_0\n"), "{body}");
    assert!(body.contains("    pks[1] = pk\n"), "{body}");
    assert!(body.contains("    d.c2da_bits_0 = d.c2da_bits_0 & 0xff00ffffu | (99u & 0xffu) << 16u\n"), "{body}");
    assert!(
        body.contains("    palette[1].c2da_bits_0 = palette[1].c2da_bits_0 & 0xffffff00u | 100u & 0xffu\n"),
        "{body}"
    );
    assert!(body.contains("    px.c.c2da_bits_0 = px.c.c2da_bits_0 & 0xff00ffffu | (77u & 0xffu) << 16u\n"), "{body}");
    assert!(body.contains("    heap.c2da_bits_0 = heap.c2da_bits_0 & 0xffffffu | (255u & 0xffu) << 24u\n"), "{body}");
    // A narrow unit computes in `uint` and is narrowed back; a field as
    // wide as its unit replaces the unit.
    assert!(body.contains("    pk.c2da_bits_2 = uint8(uint(pk.c2da_bits_2) & 0xf0u | 15u & 0xfu)\n"), "{body}");
    assert!(body.contains("    pk.c2da_bits_1 = uint16(0u & 0xffffu)\n"), "{body}");
    // The bytes are Clang's: `&s` as `uint8*`, `*(uint32_t *)&s`.
    assert!(body.contains("    word = *unsafe(addr<uint?>(c_0))\n"), "{body}");
    // The packed fallback keeps the byte path.
    assert!(body.contains("t.c2da_storage + 3ul)), 4ul))"), "{body}");
}

#[test]
fn p178_declared_array_subscripts_are_fixed_array_indexes() {
    let d = transpile_with_libc(
        "p178_direct_array_subscripts",
        c2dascript_transpile::LibcMode::Std,
    );
    let main = function_body(&d, "main_0");
    // A global, a static, a local: the array indexed itself, read, written,
    // compound-assigned and stepped in place.
    assert!(main.contains("    ceilingclip[rw_x] = int16(mid)\n"), "{main}");
    assert!(
        main.contains("    floorclip[rw_x] = int16(int(ceilingclip[rw_x]) + 1)\n"),
        "{main}"
    );
    assert!(main.contains("    main__counter[1] += 1\n    main__counter[1] += local[2]\n"), "{main}");
    assert!(main.contains("    local[rw_x] = local[rw_x - 1] * 2\n    local[0] <<= 3\n"), "{main}");
    // An array of arrays is indexed twice; an array of natural records
    // reaches the element's field by name.
    assert!(main.contains("            grid[i_3][j_0] = i_3 * 10 + j_0\n"), "{main}");
    assert!(main.contains("    grid[1][2] += grid[2][3]\n    grid[2][0] += 1\n"), "{main}");
    assert!(main.contains("        points[i_4].x = i_4\n        points[i_4].y = i_4 * i_4\n"), "{main}");
    assert!(main.contains("    points[2].y += points[3].x\n    points[1].x += 1\n"), "{main}");
    assert!(main.contains("    v_0 = by_value(planes[1], 2)\n"), "{main}");
    // The address of an element is the decayed pointer stepped by the index:
    // `&table[5]` is the one-past-the-end pointer a fixed-array index would
    // refuse.
    assert!(main.contains("    p = unsafe(addr<int?>(unsafe(unsafe(addr(local[0]))[2])))\n"), "{main}");
    assert!(
        main.contains("    end = unsafe(addr<int const?>(unsafe(unsafe(addr(table_0[0]))[5])))\n"),
        "{main}"
    );
    // A subscript of a decayed pointer stays a pointer index.
    let body = function_body(&d, "sum_decayed");
    assert!(body.contains("        s += unsafe(a[i])\n"), "{body}");
    assert!(main.contains("    unsafe(p[1]) = 55\n"), "{main}");
    let body = function_body(&d, "row_sum");
    assert!(body.contains("        s_0 += grid[row][j]\n"), "{body}");
    // Nothing indexes a declared array variable through its decayed address.
    assert!(!main.contains("addr(ceilingclip[0])") && !main.contains("addr(grid[0])"), "{main}");
    // An array *field* keeps its bytes at the Clang offset: C indexes past a
    // field array into the fields beside it (Doom's visplane pads, with
    // `-1` among the indexes), which a fixed-array index refuses and
    // daslang's unchecked index scales in `uint32`.
    let body = function_body(&d, "fill_plane");
    assert!(
        body.contains("    var c2da_fresh0 : uint16? = unsafe(reinterpret<uint16?>(unsafe(reinterpret<uint64>(plane)) + 4ul))\n    unsafe(unsafe(reinterpret<uint16?>(c2da_fresh0))[x]) = uint16(v)\n"),
        "{body}"
    );
    assert!(!body.contains("plane.top["), "{body}");
    let body = function_body(&d, "by_value");
    assert!(body.contains("    unsafe(unsafe(addr(plane_1.top[0]))[x_1]) = uint16(7)\n"), "{body}");
    // An array member of a union is bytes at its Clang offset.
    let body = function_body(&d, "tagged_bytes");
    assert!(
        body.contains("unsafe(reinterpret<uint8?>(unsafe(reinterpret<uint64>(t)) + 4ul))"),
        "{body}"
    );
    assert!(!body.contains("t.w.bytes["), "{body}");

    // The struct hack, a trailing one-element array field indexed past the
    // record, is one more field array at its offset.
    let body = function_body(&d, "fill_page");
    assert!(
        body.contains("unsafe(reinterpret<int?>(unsafe(reinterpret<uint64>(pg)) + 4ul))"),
        "{body}"
    );
    assert!(!body.contains("pg.code["), "{body}");

    // `--unsafe-deref` drops the range check of the direct index with the
    // null checks (`hint(unsafe_range_check)`); the spelling is the same in
    // both builds — the field arrays stay on offsets there too.
    let u = transpile_unsafe_deref("p178_direct_array_subscripts");
    assert!(
        u.contains("[export, unsafe_deref, hint(unsafe_range_check), sideeffects]\ndef fill_plane("),
        "{u}"
    );
    let body = function_body(&u, "fill_plane");
    assert!(
        body.contains("    unsafe(unsafe(reinterpret<uint16?>(c2da_fresh0))[x]) = uint16(v)\n"),
        "{body}"
    );
    assert!(!body.contains("plane.top["), "{body}");
    let umain = function_body(&u, "main_0");
    assert!(umain.contains("    ceilingclip[rw_x] = int16(mid)\n"), "{umain}");
    assert!(
        umain.contains("    end = unsafe(addr<int const?>(unsafe(unsafe(addr(table_0[0]))[5])))\n"),
        "{umain}"
    );
}
