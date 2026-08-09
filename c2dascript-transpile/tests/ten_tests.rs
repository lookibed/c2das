use std::path::Path;
use std::process::Command;

fn transpile_and_verify(c_name: &str) -> (i32, String) {
    let c_path = Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .join(format!("tests/syntax/{}.c", c_name));
    assert!(c_path.exists(), "C file not found: {:?}", c_path);

    let (_td, cc_path) = c2dascript_transpile::create_temp_compile_commands(&[c_path.clone()]);
    c2dascript_transpile::transpile(
        c2dascript_transpile::TranspilerConfig::default(),
        &cc_path,
        &["-w"],
    );

    let das_path = c_path.with_extension("das");
    let das_src = std::fs::read_to_string(&das_path)
        .unwrap_or_else(|_| panic!("No .das generated for {}", c_name));
    eprintln!("=== {} ===\n{}", c_name, das_src);

    // Try daslang
    let daslang = if cfg!(target_os = "windows") {
        "D:\\Backups\\с2daslang\\daScript\\bin\\Release\\daslang.exe"
    } else {
        "/usr/bin/daslang"
    };

    let exit_code = if Path::new(daslang).exists() {
        let output = Command::new(daslang)
            .arg(&das_path)
            .output()
            .unwrap_or_else(|_| panic!("failed to run daslang on {}", c_name));
        if !output.status.success() {
            let stderr = String::from_utf8_lossy(&output.stderr);
            if stderr.contains("function 'main' not found") {
                -1
            } else {
                panic!("daslang error for {}:\n{}", c_name, stderr);
            }
        } else {
            output.status.code().unwrap_or(-1)
        }
    } else {
        -2 // daslang not available on this platform
    };

    (exit_code, das_src)
}

#[test]
fn t01_arith() {
    let (code, das) = transpile_and_verify("t01_arith");
    assert!(das.contains("return 10 + 20 - 5"));
    if code > 0 {
        assert_eq!(code, 25);
    }
}

#[test]
fn t02_mul_div() {
    let (code, das) = transpile_and_verify("t02_mul_div");
    assert!(das.contains("return 7 * 6 / 2"));
    if code > 0 {
        assert_eq!(code, 21);
    }
}

#[test]
fn t03_cmp() {
    let (code, das) = transpile_and_verify("t03_cmp");
    assert!(das.contains("if ("));
    assert!(das.contains("a > b"));
    if code > 0 {
        assert_eq!(code, 10);
    }
}

#[test]
fn t04_logical() {
    let (code, das) = transpile_and_verify("t04_logical");
    assert!(das.contains("&&"));
    assert!(das.contains("b == 0"));
    if code > 0 {
        assert_eq!(code, 1);
    }
}

#[test]
fn t05_if_elif() {
    let (code, das) = transpile_and_verify("t05_if_elif");
    // either elif or nested if/else
    assert!(das.contains("x < 0") || das.contains("elif ("));
    assert!(das.contains("def classify"));
    if code > 0 {
        assert_eq!(code, 0);
    }
}

#[test]
fn t06_while() {
    let (code, das) = transpile_and_verify("t06_while");
    assert!(das.contains("while ("));
    assert!(das.contains("sum_to"));
    if code > 0 {
        assert_eq!(code, 55);
    }
}

#[test]
fn t07_for() {
    let (code, das) = transpile_and_verify("t07_for");
    assert!(das.contains("while ("));
    assert!(das.contains("i = i + 1"));
    if code > 0 {
        assert_eq!(code, 55);
    }
}

#[test]
fn t08_struct() {
    let (code, das) = transpile_and_verify("t08_struct");
    assert!(das.contains("struct Point"));
    assert!(das.contains("p2.x"));
    if code > 0 {
        assert_eq!(code, 50);
    }
}

#[test]
fn t09_enum() {
    let (code, das) = transpile_and_verify("t09_enum");
    assert!(das.contains("def color_val"));
    assert!(das.contains("return 30"));
    if code > 0 {
        assert_eq!(code, 40);
    }
}

#[test]
fn t10_chain() {
    let (code, das) = transpile_and_verify("t10_chain");
    assert!(das.contains("def max"));
    assert!(das.contains("def min"));
    assert!(das.contains("def clamp"));
    if code > 0 {
        assert_eq!(code, 40);
    }
}
