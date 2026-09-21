//! The translator's own `-W` diagnostics, observed where a user observes
//! them: on the command line's stderr.
//!
//! A warning is a user-visible contract, so it is pinned through the real
//! binary rather than through an in-process logger: the flag name printed in
//! the message (`[-Wmust-tail]`) and the spelling that switches it off
//! (`-Wno-must-tail`) must be the same two strings the CLI accepts.

use std::path::{Path, PathBuf};
use std::process::Command;

fn fixture(name: &str) -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .join("tests/syntax")
        .join(format!("{name}.c"))
}

/// Translates `name` with the extra arguments and returns the process's
/// stderr. Panics unless the translation succeeded: a diagnostic about a
/// dropped guarantee is a warning, never a failure.
fn translate(name: &str, extra: &[&str]) -> String {
    let output_dir = tempfile::tempdir().expect("temporary daScript output directory");
    let mut command = Command::new(env!("CARGO_BIN_EXE_c2dascript-transpile"));
    command
        .arg("--strict")
        .arg("--output-dir")
        .arg(output_dir.path())
        .arg("--file")
        .arg(fixture(name))
        .arg("-std=c11")
        .arg("-w")
        .args(extra);
    let output = command.output().expect("c2dascript-transpile must run");
    let stderr = String::from_utf8_lossy(&output.stderr).into_owned();
    assert!(
        output.status.success(),
        "{name}: translation must succeed, got {status:?}\n{stderr}",
        status = output.status,
    );
    stderr
}

fn must_tail_warnings(stderr: &str) -> Vec<&str> {
    stderr
        .lines()
        .filter(|line| line.contains("[-Wmust-tail]"))
        .collect()
}

/// Every dropped `musttail` is reported once, at the attributed statement's
/// own source location.
#[test]
fn dropped_musttail_warns_once_per_attributed_statement() {
    let stderr = translate("p74_musttail_return", &[]);
    let warnings = must_tail_warnings(&stderr);
    assert_eq!(
        warnings.len(),
        5,
        "p74 has five `musttail` statements, each must warn exactly once:\n{stderr}"
    );
    for warning in &warnings {
        assert!(
            warning.contains("p74_musttail_return.c:"),
            "a dropped guarantee must carry its source location: {warning}"
        );
        assert!(
            warning.contains(
                "musttail dropped: daslang gives no tail-call guarantee; this return will \
                 recurse where C iterated (stack depth is bounded by the run mode)"
            ),
            "unexpected wording: {warning}"
        );
    }
    // `countdown` is the one direct self-recursive tail call in the fixture;
    // the mutually recursive pair is deliberately not reported as such (no
    // call-graph SCC is computed).
    let self_recursive: Vec<&&str> = warnings
        .iter()
        .filter(|warning| warning.contains("self-recursive tail call into `countdown`"))
        .collect();
    assert_eq!(
        self_recursive.len(),
        1,
        "the self-recursive tail call must say so:\n{stderr}"
    );
    assert!(
        self_recursive[0].contains("the recursion depth is unbounded"),
        "unexpected wording: {}",
        self_recursive[0]
    );
}

/// The printed flag name is the spelling that switches the diagnostic off.
#[test]
fn wno_must_tail_silences_the_diagnostic() {
    let stderr = translate("p74_musttail_return", &["-Wno-must-tail"]);
    assert!(
        must_tail_warnings(&stderr).is_empty(),
        "-Wno-must-tail must silence every dropped-musttail warning:\n{stderr}"
    );
}

/// A translation unit without the attribute stays quiet.
#[test]
fn a_unit_without_musttail_does_not_warn() {
    let stderr = translate("p85_pointer_sum_compare", &[]);
    assert!(
        must_tail_warnings(&stderr).is_empty(),
        "nothing was dropped, so nothing may be reported:\n{stderr}"
    );
}
