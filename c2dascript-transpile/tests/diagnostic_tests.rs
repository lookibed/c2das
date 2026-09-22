//! The translator's command-line contracts, observed where a user observes
//! them: on the command line's stderr, and in the file it writes.
//!
//! A warning is a user-visible contract, so it is pinned through the real
//! binary rather than through an in-process logger: the flag name printed in
//! the message (`[-Wmust-tail]`) and the spelling that switches it off
//! (`-Wno-must-tail`) must be the same two strings the CLI accepts.  The
//! module-wide policy flags below (`--no-solid-context`, `--unsafe-deref`)
//! are pinned the same way, because what they promise is a line of the
//! generated module, not an internal state.

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

// ── module-wide policy flags ────────────────────────────────────────────
//
// `solid_context` is a header line and `unsafe_deref` an annotation on every
// emitted function; both are measured levers from
// `docs/followups/hot_path_levers.md`, and both are only worth anything if
// they really reach every declaration of the written module.

/// Translates `name` with the extra arguments and returns the daScript module
/// the binary wrote.  Panics unless the translation succeeded.
fn translate_module(name: &str, extra: &[&str]) -> String {
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
    assert!(
        output.status.success(),
        "{name}: translation must succeed, got {status:?}\n{stderr}",
        status = output.status,
        stderr = String::from_utf8_lossy(&output.stderr),
    );
    let module = output_dir.path().join(format!("{name}.das"));
    std::fs::read_to_string(&module)
        .unwrap_or_else(|err| panic!("cannot read generated {}: {err}", module.display()))
}

/// The annotation block a `def` carries, i.e. the `[...]` line immediately
/// above it, or `None` when the definition is unannotated.
fn annotations_above_defs(module: &str) -> Vec<Option<&str>> {
    let lines: Vec<&str> = module.lines().collect();
    lines
        .iter()
        .enumerate()
        .filter(|(_, line)| line.starts_with("def "))
        .map(|(index, _)| {
            index
                .checked_sub(1)
                .map(|previous| lines[previous])
                .filter(|previous| previous.starts_with('['))
        })
        .collect()
}

/// `solid_context` is the default header, and the only way to lose it is to
/// ask for that.
#[test]
fn solid_context_is_the_default_module_header() {
    let default = translate_module("p85_pointer_sum_compare", &[]);
    let header: Vec<&str> = default
        .lines()
        .take_while(|line| line.starts_with("options "))
        .collect();
    assert_eq!(
        header,
        vec!["options gen2", "options solid_context = true"],
        "the default header must be `gen2` then `solid_context`, in that order:\n{default}"
    );

    let opted_out = translate_module("p85_pointer_sum_compare", &["--no-solid-context"]);
    assert!(
        !opted_out.contains("solid_context"),
        "--no-solid-context must leave no trace of the option:\n{opted_out}"
    );
    assert!(
        opted_out.starts_with("options gen2\n"),
        "--no-solid-context must keep the rest of the header:\n{opted_out}"
    );
}

/// `--inline=<mode>` is the call-site inlining policy, and `--no-inline` is
/// kept as an alias of `--inline=off`.  p71 is the fixture whose `static`
/// helpers (`clamp255`, `sign_of`, `sat`, …) are substituted under
/// `--inline=on`, so it is where `on` and `off` must differ.
#[test]
fn inline_knob_modes_and_the_no_inline_alias() {
    let off = translate_module("p71_static_inline_calls", &["--inline=off"]);
    let alias = translate_module("p71_static_inline_calls", &["--no-inline"]);
    assert_eq!(alias, off, "`--no-inline` must be exactly `--inline=off`");

    let on = translate_module("p71_static_inline_calls", &["--inline=on"]);
    assert_ne!(on, off, "p71's static helpers must be substituted under `--inline=on`");
    // Under `off` every helper is still reached by a call; under `on` the
    // clamp shape has become a conditional-expression chain instead.
    assert!(
        off.contains("clamp255(") && !off.contains(" ? "),
        "`--inline=off` must keep the calls and write no substituted chain:\n{off}"
    );
    assert!(on.contains(" ? "), "`--inline=on` must write the substituted chain:\n{on}");

    let default = translate_module("p71_static_inline_calls", &[]);
    let auto = translate_module("p71_static_inline_calls", &["--inline=auto"]);
    assert_eq!(default, auto, "`auto` is the default policy");
}

/// An unknown `--inline=` mode, or `--no-inline` next to a mode that is not
/// `off`, stops before anything is written.
#[test]
fn inline_knob_rejects_unknown_and_contradictory_modes() {
    for extra in [&["--inline=sometimes"][..], &["--no-inline", "--inline=on"][..]] {
        let output_dir = tempfile::tempdir().expect("temporary daScript output directory");
        let output = Command::new(env!("CARGO_BIN_EXE_c2dascript-transpile"))
            .args(extra)
            .arg("--output-dir")
            .arg(output_dir.path())
            .arg("--file")
            .arg(fixture("p71_static_inline_calls"))
            .output()
            .expect("c2dascript-transpile must run");
        assert!(!output.status.success(), "{extra:?} must be refused");
        assert!(
            std::fs::read_dir(output_dir.path()).unwrap().next().is_none(),
            "{extra:?}: nothing may be written"
        );
    }
}

/// `--unsafe-deref` reaches *every* definition the module contains — the
/// translated C functions, the `c2da_rt_*` runtime helpers and the generated
/// initializers alike — and nothing else changes.
#[test]
fn unsafe_deref_annotates_every_definition_and_is_opt_in() {
    let default = translate_module("p85_pointer_sum_compare", &[]);
    assert!(
        !default.contains("unsafe_deref"),
        "the checked null dereference is the default; nothing may carry the annotation:\n{default}"
    );

    let unchecked = translate_module("p85_pointer_sum_compare", &["--unsafe-deref"]);
    let annotated = annotations_above_defs(&unchecked);
    assert!(
        !annotated.is_empty(),
        "the fixture must define functions at all:\n{unchecked}"
    );
    for annotation in &annotated {
        let annotation = annotation.expect("every `def` must carry an annotation block");
        assert!(
            annotation.contains("unsafe_deref"),
            "a definition without `unsafe_deref` keeps its null checks: {annotation}"
        );
    }
    // daScript's grammar allows one annotation block per declaration, so an
    // exported function must gain the annotation inside the block it already
    // has rather than on a second line.
    assert!(
        unchecked.contains("[export, unsafe_deref]"),
        "an exported definition must keep `export` in the same block:\n{unchecked}"
    );
    assert!(
        !unchecked.contains("[export]\n[unsafe_deref]"),
        "two annotation blocks in a row are a daScript syntax error:\n{unchecked}"
    );

    // Only the annotations differ: the bodies are the same text either way.
    let stripped: String = unchecked
        .lines()
        .filter(|line| *line != "[unsafe_deref]")
        .map(|line| format!("{}\n", line.replace("[export, unsafe_deref]", "[export]")))
        .collect();
    assert_eq!(
        stripped, default,
        "`--unsafe-deref` must add annotations and change nothing else"
    );
}
