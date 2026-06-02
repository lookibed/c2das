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

#[test] fn s01_switch_basic() { let d = transpile("s01_switch_basic"); assert!(d.contains("if (") || d.contains("elif")); }
#[test] fn s02_switch_default() { let d = transpile("s02_switch_default"); assert!(d.contains("if (") || d.contains("else")); }
#[test] fn s03_switch_fallthrough() { let d = transpile("s03_switch_fallthrough"); assert!(d.contains("||") || d.contains("if (")); }

#[test] fn g01_goto_basic() { let d = transpile("g01_goto_basic"); assert!(d.contains("goto") || d.contains("label")); }
#[test] fn g02_goto_loop() { let d = transpile("g02_goto_loop"); assert!(d.contains("goto") || d.contains("label")); }
#[test] fn g03_goto_forward() { let d = transpile("g03_goto_forward"); assert!(d.contains("goto") || d.contains("label")); }

#[test] fn t01_typedef_simple() { let d = transpile("t01_typedef_simple"); assert!(d.contains("typedef")); }
#[test] fn t02_typedef_ptr() { let d = transpile("t02_typedef_ptr"); assert!(d.contains("typedef") || d.contains("int?")); }
#[test] fn t03_typedef_struct() { let d = transpile("t03_typedef_struct"); assert!(d.contains("typedef") || d.contains("struct")); }

#[test] fn c01_complex() { let d = transpile("c01_complex"); assert!(d.contains("typedef") || d.contains("struct Pair") || d.contains("max_pair")); }
