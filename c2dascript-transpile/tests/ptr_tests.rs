use std::path::Path;

fn transpile(name: &str) -> String {
    let c_path = Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent().unwrap()
        .join(format!("tests/syntax/{}.c", name));
    assert!(c_path.exists(), "C file not found: {:?}", c_path);
    let (_td, cc_path) = c2dascript_transpile::create_temp_compile_commands(&[c_path.clone()]);
    c2dascript_transpile::transpile(
        c2dascript_transpile::TranspilerConfig::default(),
        &cc_path, &["-w"],
    );
    let das_path = c_path.with_extension("das");
    let s = std::fs::read_to_string(&das_path).unwrap_or_default();
    eprintln!("=== {} ===\n{}", name, s);
    s
}

#[test] fn p01_ptr_deref() { let d = transpile("p01_ptr_deref"); assert!(d.contains("*") || d.contains("addr")); }
#[test] fn p02_ptr_assign() { let d = transpile("p02_ptr_assign"); assert!(d.contains("addr")); }
#[test] fn p03_ptr_add() { let d = transpile("p03_ptr_add"); assert!(d.contains("arr[")); }
#[test] fn p04_arrow_basic() { let d = transpile("p04_arrow_basic"); assert!(d.contains("struct Point")); assert!(d.contains("addr")); }
#[test] fn p05_arrow_chain() { let d = transpile("p05_arrow_chain"); assert!(d.contains("struct")); }
#[test] fn p06_ptr_to_ptr() { let d = transpile("p06_ptr_to_ptr"); assert!(d.contains("addr")); }
#[test] fn p07_ptr_arith() { let d = transpile("p07_ptr_arith"); assert!(d.contains("deref") || d.contains("*p")); }
#[test] fn p08_arrow_func() { let d = transpile("p08_arrow_func"); assert!(d.contains("struct Rect")); assert!(d.contains("area")); }
#[test] fn p09_ptr_null() { let d = transpile("p09_ptr_null"); assert!(d.contains("null")); }
#[test] fn p10_ptr_swap() { let d = transpile("p10_ptr_swap"); assert!(d.contains("def swap")); assert!(d.contains("var")); }

#[test] fn u01_unsafe_ptr() { let d = transpile("u01_unsafe_ptr"); assert!(d.contains("addr") || d.contains("*x")); }
#[test] fn u02_unsafe_write() { let d = transpile("u02_unsafe_write"); assert!(d.contains("var")); assert!(d.contains("*")); }
#[test] fn u03_unsafe_swap() { let d = transpile("u03_unsafe_swap"); assert!(d.contains("def swap")); assert!(d.contains("var")); }
