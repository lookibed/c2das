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
    std::fs::read_to_string(&das_path).unwrap_or_default()
}

#[test]
fn d01_basic() {
    let d = transpile("d01_basic");
    assert!(d.contains("while"));
    assert!(d.len() > 20);
}
#[test]
fn d02_once() {
    let d = transpile("d02_once");
    assert!(d.contains("while"));
}
#[test]
fn d03_zero() {
    let d = transpile("d03_zero");
    assert!(d.contains("while"));
}
#[test]
fn d04_break() {
    let d = transpile("d04_break");
    assert!(d.contains("while"));
    assert!(d.contains("break"));
}
#[test]
fn d05_continue() {
    let d = transpile("d05_continue");
    assert!(d.contains("while"));
    assert!(d.contains("_first") || d.contains("continue"));
}
#[test]
fn d06_nested_do() {
    let d = transpile("d06_nested_do");
    assert!(d.contains("while"));
}
#[test]
fn d07_fact() {
    let d = transpile("d07_do_while_var");
    assert!(d.contains("while"));
}
#[test]
fn d08_do_in_while() {
    let d = transpile("d08_do_in_while");
    assert!(d.contains("while"));
}
#[test]
fn d09_continue_in_while() {
    let d = transpile("d09_continue_in_while");
    assert!(d.contains("while"));
}
#[test]
fn d10_sum_do() {
    let d = transpile("d10_sum_do");
    assert!(d.contains("while"));
}
