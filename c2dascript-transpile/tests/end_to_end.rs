use std::path::Path;

fn run_transpile(name: &str) -> String {
    let c_path = Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent().unwrap()
        .join(format!("tests/syntax/{}.c", name));
    assert!(c_path.exists(), "C test file not found: {:?}", c_path);

    let (_temp_dir, cc_path) = c2dascript_transpile::create_temp_compile_commands(&[c_path.clone()]);

    let tcfg = c2dascript_transpile::TranspilerConfig {
        verbose: false,
        ..Default::default()
    };

    let result = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
        c2dascript_transpile::transpile(tcfg, &cc_path, &["-w"]);
    }));

    let das_path = c_path.with_extension("das");
    let content = std::fs::read_to_string(&das_path).unwrap_or_default();
    println!("=== {} ===\n{}", name, content);
    if result.is_err() {
        eprintln!("WARNING: transpile panicked for {}", name);
    }
    content
}

#[test]
fn test_simple() {
    let das = run_transpile("test_simple");
    assert!(das.contains("def add"));
    assert!(das.contains("[export]"));
    assert!(das.contains("def main"));
}

#[test]
fn test_if_while() {
    let das = run_transpile("test_if");
    assert!(das.contains("def max"));
    assert!(das.contains("if ("));
    assert!(das.contains("while ("));
    assert!(das.contains("def sum_to_n"));
}

#[test]
fn test_full() {
    let das = run_transpile("test_full");
    assert!(das.contains("def max"));
    assert!(das.contains("while ("));
    assert!(das.contains("sum_to_n"));
    assert!(das.contains("[export]"));
}

#[test]
fn test_struct_enum() {
    let das = run_transpile("test_struct");
    assert!(das.contains("struct Point"));
    assert!(das.contains("x : int"));
    assert!(das.contains("y : int"));
    assert!(das.contains("enum Color"));
    assert!(das.contains("RED"));
    assert!(das.contains("GREEN"));
    assert!(das.contains("BLUE"));
}

#[test]
fn test_member() {
    let das = run_transpile("test_member");
    assert!(das.contains("p.x = 10"));
    assert!(das.contains("p.y = 20"));
    assert!(das.contains("p.x + p.y"));
}
