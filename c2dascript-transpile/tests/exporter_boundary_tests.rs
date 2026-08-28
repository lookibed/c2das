use std::env;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::Mutex;

use c2dascript_transpile::{
    create_temp_compile_commands, transpile_checked, TranspileError, TranspilerConfig,
};

static EXPORTER_ENV_LOCK: Mutex<()> = Mutex::new(());

fn transpile_failure_with_config(
    fixture: &str,
    configure: impl FnOnce(&mut TranspilerConfig),
) -> c2rust_ast_exporter::ExporterFailure {
    let source = Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("workspace root")
        .join("tests/syntax")
        .join(fixture);
    let (_compile_commands_dir, compile_commands) = create_temp_compile_commands(&[source]);
    let output = tempfile::tempdir().expect("temporary output directory");
    let mut config = TranspilerConfig {
        output_dir: Some(output.path().join("das")),
        ..Default::default()
    };
    configure(&mut config);

    match transpile_checked(config, &compile_commands, &["-w"]) {
        Err(TranspileError::ClangAst(failure)) => failure,
        Err(other) => panic!("expected exporter failure, got {other}"),
        Ok(outputs) => panic!("expected exporter failure, produced {outputs:?}"),
    }
}

fn transpile_failure(fixture: &str) -> c2rust_ast_exporter::ExporterFailure {
    transpile_failure_with_config(fixture, |_| {})
}

struct EnvironmentOverride {
    key: &'static str,
    previous: Option<std::ffi::OsString>,
}

impl EnvironmentOverride {
    fn set(key: &'static str, value: impl AsRef<std::ffi::OsStr>) -> Self {
        let previous = env::var_os(key);
        env::set_var(key, value);
        Self { key, previous }
    }
}

impl Drop for EnvironmentOverride {
    fn drop(&mut self) {
        if let Some(value) = &self.previous {
            env::set_var(self.key, value);
        } else {
            env::remove_var(self.key);
        }
    }
}

#[cfg(unix)]
fn fake_exporter(body: &str) -> (tempfile::TempDir, PathBuf) {
    use std::os::unix::fs::PermissionsExt;

    let directory = tempfile::tempdir().expect("temporary fake exporter directory");
    let path = directory.path().join("fake-exporter.sh");
    fs::write(&path, format!("#!/bin/sh\n{body}\n")).expect("write fake exporter");
    fs::set_permissions(&path, fs::Permissions::from_mode(0o755))
        .expect("make fake exporter executable");
    (directory, path)
}

fn configured_exporter() -> PathBuf {
    c2rust_ast_exporter::standalone_exporter_path()
        .expect("test build must provide the isolated exporter executable")
}

#[cfg(unix)]
#[test]
fn successful_child_without_cbor_is_rejected_as_a_protocol_failure() {
    let _environment = EXPORTER_ENV_LOCK
        .lock()
        .unwrap_or_else(|poison| poison.into_inner());
    let (_directory, executable) = fake_exporter("exit 0");
    let _exporter = EnvironmentOverride::set("C2DAS_AST_EXPORTER_BIN", &executable);
    let failure = transpile_failure("p17_runtime_malloc.c");
    assert_eq!(failure.phase, "cbor-protocol");
    assert!(failure.detail.contains("missing CBOR result"));
}

#[cfg(unix)]
#[test]
fn stalled_child_is_killed_and_reported_as_an_exporter_timeout() {
    let _environment = EXPORTER_ENV_LOCK
        .lock()
        .unwrap_or_else(|poison| poison.into_inner());
    let (_directory, executable) = fake_exporter("sleep 1");
    let _exporter = EnvironmentOverride::set("C2DAS_AST_EXPORTER_BIN", &executable);
    let _timeout = EnvironmentOverride::set("C2DAS_AST_EXPORTER_TIMEOUT_MS", "5");
    let failure = transpile_failure("p17_runtime_malloc.c");
    assert_eq!(failure.phase, "exporter-timeout");
    assert!(failure.detail.contains("5 ms"));
}

#[cfg(unix)]
#[test]
fn large_child_diagnostic_remains_a_child_failure_not_a_timeout() {
    let _environment = EXPORTER_ENV_LOCK
        .lock()
        .unwrap_or_else(|poison| poison.into_inner());
    let (_directory, executable) =
        fake_exporter("dd if=/dev/zero bs=131072 count=1 1>&2 2>/dev/null; exit 1");
    let _exporter = EnvironmentOverride::set("C2DAS_AST_EXPORTER_BIN", &executable);
    let _timeout = EnvironmentOverride::set("C2DAS_AST_EXPORTER_TIMEOUT_MS", "1000");
    let failure = transpile_failure("p17_runtime_malloc.c");
    assert_eq!(failure.phase, "clang-cbor-exporter");
    assert_eq!(failure.exit_code, Some(1));
    assert!(failure.stderr.len() >= 128 * 1024);
    assert!(!failure.stderr.contains('\0'));
}

#[cfg(unix)]
#[test]
fn malformed_child_cbor_is_rejected_with_trace_and_command_evidence() {
    let _environment = EXPORTER_ENV_LOCK
        .lock()
        .unwrap_or_else(|poison| poison.into_inner());
    let (_directory, executable) = fake_exporter(
        "while [ \"$#\" -gt 0 ]; do if [ \"$1\" = --c2das-output ]; then shift; printf '\\001not-cbor' > \"$1\"; break; fi; shift; done; exit 0",
    );
    let _exporter = EnvironmentOverride::set("C2DAS_AST_EXPORTER_BIN", &executable);
    let failure = transpile_failure("p17_runtime_malloc.c");
    assert_eq!(failure.phase, "cbor-protocol");
    assert!(failure.detail.contains("invalid CBOR"));
    assert!(!failure.command.is_empty());
}

#[cfg(unix)]
#[test]
fn debug_configuration_reaches_the_isolated_exporter_protocol() {
    let _environment = EXPORTER_ENV_LOCK
        .lock()
        .unwrap_or_else(|poison| poison.into_inner());
    let (_directory, executable) = fake_exporter("exit 0");
    let _exporter = EnvironmentOverride::set("C2DAS_AST_EXPORTER_BIN", &executable);
    let failure = transpile_failure_with_config("p17_runtime_malloc.c", |config| {
        config.debug_ast_exporter = true;
    });
    assert_eq!(failure.phase, "cbor-protocol");
    assert!(failure
        .command
        .iter()
        .any(|argument| argument == "--c2das-debug"));
}

#[test]
fn invalid_clangtool_option_is_a_structured_child_exit_not_an_abort() {
    let _environment = EXPORTER_ENV_LOCK
        .lock()
        .unwrap_or_else(|poison| poison.into_inner());
    let workspace = tempfile::tempdir().expect("probe workspace");
    let output = workspace.path().join("result.cbor");
    let trace = workspace.path().join("trace.txt");
    let result = Command::new(configured_exporter())
        .args([
            "--c2das-output",
            output.to_str().expect("UTF-8 output path"),
            "--c2das-trace",
            trace.to_str().expect("UTF-8 trace path"),
            "--definitely-invalid-c2das-option",
        ])
        .output()
        .expect("run isolated exporter");
    assert_eq!(result.status.code(), Some(64));
    assert!(!output.exists(), "invalid ClangTool input produced CBOR");
    assert_eq!(
        fs::read_to_string(trace).expect("trace"),
        "phase=clang-tooling-start\nphase=clang-option-parse-error\nphase=clang-tooling-error\n"
    );
}
