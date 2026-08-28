use serde_cbor::{from_slice, Value};
use std::env;
use std::error::Error;
use std::ffi::{c_char, CStr};
use std::fmt;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Command, ExitStatus, Stdio};
use std::thread;
use std::time::{Duration, Instant};

use crate::clang_ast::BuiltinVaListKind;

pub mod clang_ast;

/// A failure before CBOR becomes a valid Rust value.  This is deliberately a
/// distinct error family from translator diagnostics: the frontend cannot
/// honestly attach a C AST node until the exporter has emitted one.
#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ExporterFailure {
    pub input: PathBuf,
    pub phase: String,
    pub detail: String,
    pub exit_code: Option<i32>,
    pub signal: Option<i32>,
    pub stderr: String,
    pub trace: Option<String>,
    pub command: Vec<String>,
}

impl ExporterFailure {
    fn protocol(input: &Path, detail: impl Into<String>, trace: Option<String>) -> Self {
        Self {
            input: input.to_owned(),
            phase: "cbor-protocol".to_owned(),
            detail: detail.into(),
            exit_code: None,
            signal: None,
            stderr: String::new(),
            trace,
            command: Vec::new(),
        }
    }

    fn protocol_with_context(
        input: &Path,
        detail: impl Into<String>,
        trace: Option<String>,
        command: Vec<String>,
    ) -> Self {
        Self {
            input: input.to_owned(),
            phase: "cbor-protocol".to_owned(),
            detail: detail.into(),
            exit_code: None,
            signal: None,
            stderr: String::new(),
            trace,
            command,
        }
    }

    fn child(
        input: &Path,
        status: &ExitStatus,
        stderr: String,
        trace: Option<String>,
        command: Vec<String>,
    ) -> Self {
        Self {
            input: input.to_owned(),
            phase: "clang-cbor-exporter".to_owned(),
            detail: "isolated exporter terminated before producing validated CBOR".to_owned(),
            exit_code: status.code(),
            signal: process_signal(status),
            stderr,
            trace,
            command,
        }
    }
}

impl fmt::Display for ExporterFailure {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            formatter,
            "exporter failure: phase={}; input={}; detail={}",
            self.phase,
            self.input.display(),
            self.detail
        )?;
        if let Some(code) = self.exit_code {
            write!(formatter, "; exit_code={code}")?;
        }
        if let Some(signal) = self.signal {
            write!(formatter, "; signal={signal}")?;
        }
        if let Some(trace) = &self.trace {
            write!(formatter, "; last_trace={trace}")?;
        }
        if !self.stderr.is_empty() {
            write!(formatter, "; stderr={}", diagnostic_excerpt(&self.stderr))?;
        }
        if !self.command.is_empty() {
            write!(formatter, "; command={}", self.command.join(" "))?;
        }
        Ok(())
    }
}

impl Error for ExporterFailure {}

impl Default for BuiltinVaListKind {
    fn default() -> Self {
        Self::CharPtrBuiltinVaList
    }
}

pub fn get_clang_major_version() -> Option<u32> {
    let s = unsafe { CStr::from_ptr(clang_version()) };
    s.to_str()
        .unwrap()
        .split('.')
        .next()
        .unwrap()
        .parse::<u32>()
        .ok()
}

pub fn get_untyped_ast(
    file_path: &Path,
    cc_db: &Path,
    extra_args: &[&str],
    debug: bool,
) -> Result<clang_ast::AstContext, ExporterFailure> {
    let cbor = get_ast_cbor(file_path, cc_db, extra_args, debug)?;

    let items: Value = from_slice(&cbor.bytes).map_err(|error| {
        ExporterFailure::protocol_with_context(
            file_path,
            format!("invalid CBOR: {error}"),
            cbor.trace.clone(),
            cbor.command.clone(),
        )
    })?;

    clang_ast::process(items).map_err(|error| {
        ExporterFailure::protocol_with_context(
            file_path,
            error.to_string(),
            cbor.trace,
            cbor.command,
        )
    })
}

/// The configured child executable. This is public for boundary probes and
/// tooling, not for bypassing `get_untyped_ast`: callers still receive a
/// source-scoped `ExporterFailure` if the binary is absent.
pub fn standalone_exporter_path() -> Result<PathBuf, ExporterFailure> {
    exporter_executable(Path::new("<exporter-boundary-probe>"))
}

struct ExportedCbor {
    bytes: Vec<u8>,
    trace: Option<String>,
    command: Vec<String>,
}

fn get_ast_cbor(
    file_path: &Path,
    cc_db: &Path,
    extra_args: &[&str],
    debug: bool,
) -> Result<ExportedCbor, ExporterFailure> {
    let work = tempfile::Builder::new()
        .prefix("c2das-exporter-")
        .tempdir()
        .map_err(|error| {
            ExporterFailure::protocol(file_path, format!("temporary workspace: {error}"), None)
        })?;
    let cbor_path = work.path().join("result.cbor");
    let trace_path = work.path().join("trace.txt");
    let executable = exporter_executable(file_path)?;
    let mut arguments = vec![
        "--c2das-output".to_owned(),
        cbor_path.display().to_string(),
        "--c2das-trace".to_owned(),
        trace_path.display().to_string(),
        file_path.display().to_string(),
        "-p".to_owned(),
        cc_db.display().to_string(),
    ];
    for argument in extra_args {
        arguments.push(format!("-extra-arg={argument}"));
    }
    if debug {
        arguments.push("--c2das-debug".to_owned());
    }
    let mut invocation = Vec::with_capacity(arguments.len() + 1);
    invocation.push(executable.display().to_string());
    invocation.extend(arguments.iter().cloned());
    let mut command = Command::new(&executable);
    command.args(&arguments);
    let timeout = exporter_timeout();
    let stdout_path = work.path().join("stdout.txt");
    let stderr_path = work.path().join("stderr.txt");
    let stdout = fs::File::create(&stdout_path).map_err(|error| {
        ExporterFailure::protocol(file_path, format!("temporary stdout file: {error}"), None)
    })?;
    let stderr = fs::File::create(&stderr_path).map_err(|error| {
        ExporterFailure::protocol(file_path, format!("temporary stderr file: {error}"), None)
    })?;
    let mut child = command
        // Files, rather than pipes, are intentional: Clang diagnostics can
        // exceed a pipe buffer.  The parent must not misclassify that normal
        // nonzero exit as a timeout because it stopped draining stderr.
        .stdout(Stdio::from(stdout))
        .stderr(Stdio::from(stderr))
        .spawn()
        .map_err(|error| ExporterFailure {
            input: file_path.to_owned(),
            phase: "exporter-launch".to_owned(),
            detail: error.to_string(),
            exit_code: None,
            signal: None,
            stderr: String::new(),
            trace: None,
            command: invocation.clone(),
        })?;
    let started = Instant::now();
    let mut timed_out = false;
    loop {
        if child
            .try_wait()
            .map_err(|error| ExporterFailure::protocol(file_path, error.to_string(), None))?
            .is_some()
        {
            break;
        }
        if started.elapsed() >= timeout {
            timed_out = true;
            child
                .kill()
                .map_err(|error| ExporterFailure::protocol(file_path, error.to_string(), None))?;
            break;
        }
        thread::sleep(Duration::from_millis(10));
    }
    let status = child
        .wait()
        .map_err(|error| ExporterFailure::protocol(file_path, error.to_string(), None))?;
    let trace = fs::read_to_string(&trace_path)
        .ok()
        .and_then(|text| text.lines().last().map(str::to_owned));
    let stderr = read_diagnostic_file(&stderr_path);
    if timed_out {
        return Err(ExporterFailure {
            input: file_path.to_owned(),
            phase: "exporter-timeout".to_owned(),
            detail: format!("isolated exporter exceeded {} ms", timeout.as_millis()),
            exit_code: status.code(),
            signal: process_signal(&status),
            stderr,
            trace,
            command: invocation,
        });
    }
    if !status.success() {
        return Err(ExporterFailure::child(
            file_path, &status, stderr, trace, invocation,
        ));
    }
    let bytes = fs::read(&cbor_path).map_err(|error| {
        ExporterFailure::protocol_with_context(
            file_path,
            format!("missing CBOR result: {error}"),
            trace.clone(),
            invocation.clone(),
        )
    })?;
    if bytes.is_empty() {
        return Err(ExporterFailure::protocol_with_context(
            file_path,
            "exporter produced empty CBOR",
            trace,
            invocation,
        ));
    }
    Ok(ExportedCbor {
        bytes,
        trace,
        command: invocation,
    })
}

fn read_diagnostic_file(path: &Path) -> String {
    const MAX_DIAGNOSTIC_BYTES: usize = 256 * 1024;
    let Ok(bytes) = fs::read(path) else {
        return String::new();
    };
    let truncated = bytes.len() > MAX_DIAGNOSTIC_BYTES;
    let mut rendered = String::from_utf8_lossy(&bytes[..bytes.len().min(MAX_DIAGNOSTIC_BYTES)])
        .chars()
        .map(|character| {
            if character == '\n' || character == '\t' || !character.is_control() {
                character
            } else {
                '�'
            }
        })
        .collect::<String>()
        .trim()
        .to_owned();
    if truncated {
        rendered.push_str("\n[diagnostic truncated after 262144 bytes]");
    }
    rendered
}

fn diagnostic_excerpt(stderr: &str) -> String {
    const MAX_DISPLAY_CHARS: usize = 2 * 1024;
    let mut chars = stderr.chars();
    let excerpt: String = chars.by_ref().take(MAX_DISPLAY_CHARS).collect();
    if chars.next().is_some() {
        format!("{excerpt}\n[diagnostic display truncated after 2048 characters]")
    } else {
        excerpt
    }
}

fn exporter_timeout() -> Duration {
    let milliseconds = env::var("C2DAS_AST_EXPORTER_TIMEOUT_MS")
        .ok()
        .and_then(|value| value.parse::<u64>().ok())
        .filter(|value| *value > 0)
        .unwrap_or(120_000);
    Duration::from_millis(milliseconds)
}

fn exporter_executable(input: &Path) -> Result<PathBuf, ExporterFailure> {
    let configured = env::var_os("C2DAS_AST_EXPORTER_BIN")
        .or_else(|| option_env!("C2DAS_AST_EXPORTER_BIN").map(Into::into));
    let Some(path) = configured.map(PathBuf::from) else {
        return Err(ExporterFailure::protocol(
            input,
            "standalone exporter is unavailable; set C2DAS_AST_EXPORTER_BIN",
            None,
        ));
    };
    if !path.is_file() {
        return Err(ExporterFailure::protocol(
            input,
            format!("standalone exporter is missing: {}", path.display()),
            None,
        ));
    }
    Ok(path)
}

extern "C" {
    fn clang_version() -> *const c_char;
}

#[cfg(unix)]
fn process_signal(status: &std::process::ExitStatus) -> Option<i32> {
    use std::os::unix::process::ExitStatusExt;
    status.signal()
}

#[cfg(not(unix))]
fn process_signal(_status: &std::process::ExitStatus) -> Option<i32> {
    None
}
