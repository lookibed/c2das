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

#[test] fn c01_const_int() { let d = transpile("c01_const_int"); assert!(d.contains("int const") || d.contains("42")); }
#[test] fn c02_const_ptr() { let d = transpile("c02_const_ptr"); assert!(d.contains("int const?")); }
#[test] fn c03_ptr_to_const() { let d = transpile("c03_ptr_to_const"); assert!(d.contains("def read_val")); }
#[test] fn c04_const_array() { let d = transpile("c04_const_array"); assert!(d.contains("def sum")); assert!(d.contains("while")); }
#[test] fn c05_const_struct_ptr() { let d = transpile("c05_const_struct_ptr"); assert!(d.contains("struct Point") || d.contains("dot")); }
#[test] fn c06_const_chain() { let d = transpile("c06_const_chain"); assert!(d.contains("def min_ptr") || d.contains("const")); }
#[test] fn c07_const_assign() { let d = transpile("c07_const_assign"); assert!(d.contains("int = *p") || d.contains("= *p")); }
#[test] fn c08_const_static() { let d = transpile("c08_const_static"); assert!(d.contains("SIZE") || d.contains("100")); }
#[test] fn c09_const_multi() { let d = transpile("c09_const_multi"); assert!(d.contains("def add")); }
#[test] fn c10_const_mixed() { let d = transpile("c10_const_mixed"); assert!(d.contains("def apply")); }
