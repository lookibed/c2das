//! Target switches (`src/target.rs`, `docs/eden-flags.md`): AST/render
//! assertions.  The runtime proofs are the canonical cases
//! `p190-float-compare-nan-safe`, `p191-target-flag-unimplemented` and
//! `p192-dialect-eden-refuses-option`.
use c2dascript_transpile::target::{Dialect, FloatCompare, NoUnsafe, TargetOptions};
use std::path::Path;

fn translate(name: &str, target: TargetOptions) -> Result<String, String> {
    let c_path = Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .join(format!("tests/syntax/{name}.c"));
    let (_td, cc_path) = c2dascript_transpile::create_temp_compile_commands(&[c_path]);
    let temp = tempfile::tempdir().expect("temporary output directory");
    let config = c2dascript_transpile::TranspilerConfig {
        output_dir: Some(temp.path().join("das")),
        target,
        ..Default::default()
    };
    let outputs = c2dascript_transpile::transpile_checked(config, &cc_path, &["-w"])
        .map_err(|error| error.to_string())?;
    Ok(std::fs::read_to_string(&outputs[0]).expect("fresh output"))
}

/// Under `nan-safe` every floating comparison of the fixture — the six
/// operators on `double` and `float`, truthiness and `!x` — is a guarded
/// helper call; the default output names no helper and needs no `math_bits`.
#[test]
fn float_compare_nan_safe_guards_every_floating_comparison() {
    let guarded = translate(
        "p190_float_compare_nan_safe",
        TargetOptions {
            float_compare: FloatCompare::NanSafe,
            ..Default::default()
        },
    )
    .unwrap();
    assert!(guarded.contains("require daslib/math_bits"));
    for op in ["eq", "ne", "lt", "le", "gt", "ge"] {
        for suffix in ["d", "f"] {
            let helper = format!("c2da_fcmp_{op}_{suffix}(");
            assert!(guarded.contains(&helper), "missing {helper}");
        }
    }
    // `isnan` is a bit test, never the comparison it guards.
    assert!(guarded.contains("double_bits_to_uint64(x)"));
    assert!(guarded.contains("float_bits_to_uint(x)"));
    // No plain comparison of the fixture's NaN locals survives.
    for plain in [
        "dnan == ",
        "dnan != ",
        "dnan < ",
        "fnan != ",
        "fnan == ",
        "x < 3.0lf",
    ] {
        assert!(
            !guarded.contains(plain),
            "plain comparison `{plain}` survived"
        );
    }

    let default = translate("p190_float_compare_nan_safe", TargetOptions::default()).unwrap();
    assert!(!default.contains("c2da_fcmp_"));
    assert!(!default.contains("math_bits"));
}

/// `--dialect eden-0.6.4` accepts the default module header (`gen2`,
/// `solid_context`) and refuses nothing in a plain program.
#[test]
fn dialect_eden_accepts_default_header() {
    translate(
        "p191_target_flag_unimplemented",
        TargetOptions {
            dialect: Dialect::Eden064,
            ..Default::default()
        },
    )
    .unwrap();
}

/// `--no-unsafe` fails closed on the raw-memory runtime prelude every module
/// carries today, naming the first sites; `report` writes the module.
#[test]
fn no_unsafe_fails_closed_and_report_mode_writes() {
    let error = translate(
        "p191_target_flag_unimplemented",
        TargetOptions {
            no_unsafe: NoUnsafe::Fail,
            ..Default::default()
        },
    )
    .unwrap_err();
    assert!(error.contains("--no-unsafe:"), "{error}");
    assert!(error.contains("need `unsafe`"), "{error}");
    translate(
        "p191_target_flag_unimplemented",
        TargetOptions {
            no_unsafe: NoUnsafe::Report,
            ..Default::default()
        },
    )
    .unwrap();
}

#[test]
fn eden_preset_lists_every_unimplemented_switch() {
    let missing = TargetOptions::eden().unimplemented();
    assert_eq!(
        missing,
        [
            "--fnptr-model table",
            "--varargs-model heap",
            "--entry eden",
            "--records typed",
        ]
    );
    assert!(TargetOptions::default().unimplemented().is_empty());
}
