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
