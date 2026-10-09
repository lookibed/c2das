#![allow(clippy::too_many_arguments)]

mod diagnostics;

pub mod build_files;
pub mod c_ast;
pub mod cfg;
mod compile_cmds;
pub mod convert_type;
pub mod renamer;
pub mod target;
pub mod translator;
pub mod with_stmts;

use std::collections::{BTreeMap, BTreeSet, HashMap, HashSet};
use std::fs::{self, File};

use das_ast::DaDecl;
use std::io::Write;
use std::path::{Path, PathBuf};

use log::warn;
use regex::Regex;
pub use tempfile::TempDir;

use crate::c_ast::*;
pub use crate::diagnostics::Diagnostic;
use crate::diagnostics::TranslationError;
use c2rust_ast_exporter as ast_exporter;

use crate::compile_cmds::get_compile_commands;
use std::prelude::v1::Vec;

/// Failure produced by the translation API.
///
/// [`transpile`] continues past a failed translation unit so the rest of a
/// compilation database is still processed, while [`transpile_checked`] stops
/// at the first one; both report every failure, and neither writes an output
/// file for a unit that failed. An unsupported C construct can therefore never
/// be mistaken for a successfully printed partial module.
#[derive(Debug)]
pub enum TranspileError {
    CompileCommands(String),
    MissingInput(PathBuf),
    ClangAst(ast_exporter::ExporterFailure),
    Translation(TranslationError),
    Output {
        path: PathBuf,
        error: std::io::Error,
    },
    /// `--module-layout source` cannot lay the program out: two definitions of
    /// one external symbol, two units with one stem (or a stem taking a
    /// cluster's or the shared module's name), a shared type the units declare
    /// differently, a module requiring the one with `main`, or two fragments
    /// of a cluster declaring one generated helper differently.
    Layout(String),
}

impl std::fmt::Display for TranspileError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::CompileCommands(error) => write!(f, "compile_commands: {error}"),
            Self::MissingInput(path) => {
                write!(f, "input C file does not exist: {}", path.display())
            }
            Self::ClangAst(error) => write!(f, "Clang AST export: {error}"),
            Self::Translation(error) => write!(f, "{error}"),
            Self::Output { path, error } => write!(f, "cannot write {}: {error}", path.display()),
            Self::Layout(error) => write!(f, "module layout: {error}"),
        }
    }
}

impl std::error::Error for TranspileError {}

type PragmaVec = Vec<(&'static str, Vec<&'static str>)>;
type PragmaSet = indexmap::IndexSet<(&'static str, &'static str)>;
type CrateSet = indexmap::IndexSet<ExternCrate>;

#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
pub enum ExternCrate {
    C2RustBitfields,
    C2RustAsmCasts,
    F128,
    NumTraits,
    Memoffset,
    Libc,
}

/// How a program's translation units are laid out over daslang modules
/// (`--module-layout`).
#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
pub enum ModuleLayout {
    /// One `.das` per translation unit, each a complete module carrying its
    /// own prelude copy; a reference to another unit's symbol fails closed.
    /// The default.
    #[default]
    Unity,
    /// One `module <stem>` per `.c` file.  The runtime prelude, the C type
    /// section and the `--libc std` helpers go to one shared module
    /// (`--runtime-module`, default [`DEFAULT_RUNTIME_MODULE`]); a unit
    /// `require`s the modules whose external symbols it references; a C
    /// `static` is `private`.  Units that reference each other in a cycle
    /// (daslang refuses a cyclic `require`) are one module: a cluster file
    /// `include`s each unit's `<stem>.das.inc` fragment
    /// ([`FRAGMENT_EXTENSION`]).
    Source,
}

/// The shared module's name under `--module-layout source` when
/// `--runtime-module` names none.
pub const DEFAULT_RUNTIME_MODULE: &str = "c2da_runtime";

impl ModuleLayout {
    pub const ALL: [Self; 2] = [Self::Unity, Self::Source];

    pub fn parse(text: &str) -> Option<Self> {
        Self::ALL.into_iter().find(|mode| mode.as_str() == text)
    }

    pub fn as_str(self) -> &'static str {
        match self {
            Self::Unity => "unity",
            Self::Source => "source",
        }
    }
}

impl std::fmt::Display for ModuleLayout {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(self.as_str())
    }
}

/// libc policy for a translation unit (`--libc`).
///
/// The mode decides what a call to a body-less external C function may become.
/// It never relaxes the fail-closed rule: a symbol the selected mode does not
/// know is still a `TranslationError` naming that symbol.
#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
pub enum LibcMode {
    /// Only the canonical raw-memory runtime (`malloc`, `memcpy`, …) is
    /// accepted, lowered to the translator-emitted `c2da_rt_*` helpers. Every
    /// other external call is rejected. This is the default.
    #[default]
    NoStd,
    /// Replacement: the libc entry points in `translator/libc.rs` are lowered
    /// to daslib/daslang analogues through translator-emitted `c2da_std_*`
    /// helpers, with the ABI adapters at the call boundary.
    Std,
    /// Foreign-function interface to the host libc. Not implemented.
    Ffi,
    /// Replacement where one exists, FFI otherwise. Not implemented.
    All,
    /// The EdenSpark sandbox's libc: `Std`'s table without `daslib/fio`:
    /// console output through `print`/`to_log`, read-only files the host
    /// registers with `c2da_eden_add_file`, `exit` unwinding to the entry
    /// wrapper (`docs/eden-flags.md` flag 5, `translator/libc.rs`).
    Eden,
}

impl LibcMode {
    /// The spelling `--libc` accepts, or `None` for an unknown mode.
    pub fn parse(text: &str) -> Option<Self> {
        match text {
            "nostd" => Some(Self::NoStd),
            "std" => Some(Self::Std),
            "ffi" => Some(Self::Ffi),
            "all" => Some(Self::All),
            "eden" => Some(Self::Eden),
            _ => None,
        }
    }

    /// The spelling this mode is written with on the command line.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::NoStd => "nostd",
            Self::Std => "std",
            Self::Ffi => "ffi",
            Self::All => "all",
            Self::Eden => "eden",
        }
    }

    /// Every spelling `--libc` accepts, in the order the usage text lists them.
    pub const ALL: [Self; 5] = [Self::NoStd, Self::Std, Self::Ffi, Self::All, Self::Eden];
}

impl std::fmt::Display for LibcMode {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(self.as_str())
    }
}

/// Call-site inlining policy for tiny `static` C helpers (`--inline=<mode>`).
///
/// See `translator/inline.rs` for which helpers qualify at all.  One `.das`
/// feeds the interpreter, `-jit`, `-exe` and the AOT build alike, so the
/// translator cannot know which run mode will consume it; a mode here is a
/// fixed policy, not a per-run-mode decision.
#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
pub enum InlineMode {
    /// Substitute every qualifying helper at its direct call sites.  Pays in
    /// the interpreter, which dispatches every call.
    On,
    /// Substitute nothing (`--no-inline` is an alias).  The output is what
    /// the translator wrote before `translator/inline.rs` existed.
    Off,
    /// The default policy, chosen from the per-run-mode benchmark in
    /// `docs/followups/hot_path_levers.md` (lever 4).  It currently admits
    /// what `On` admits: the substitution pays in the interpreter and is
    /// neutral under `-jit`, `-exe` and AOT, so no narrower fixed policy
    /// beat it in any mode.  Naming the default separately lets a build pin
    /// `on` or `off` while the default stays free to follow new numbers.
    #[default]
    Auto,
}

impl InlineMode {
    /// The spelling `--inline=` accepts, or `None` for an unknown mode.
    pub fn parse(text: &str) -> Option<Self> {
        match text {
            "on" => Some(Self::On),
            "off" => Some(Self::Off),
            "auto" => Some(Self::Auto),
            _ => None,
        }
    }

    /// The spelling this mode is written with on the command line.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::On => "on",
            Self::Off => "off",
            Self::Auto => "auto",
        }
    }

    /// Every spelling `--inline=` accepts, in the order the usage text lists them.
    pub const ALL: [Self; 3] = [Self::On, Self::Off, Self::Auto];
}

impl std::fmt::Display for InlineMode {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(self.as_str())
    }
}

/// Configuration settings for the translation process
#[derive(Clone, Debug)]
pub struct TranspilerConfig {
    pub dump_untyped_context: bool,
    pub dump_typed_context: bool,
    pub pretty_typed_context: bool,
    pub verbose: bool,
    pub debug_ast_exporter: bool,
    pub filter: Option<Regex>,
    pub translate_valist: bool,
    pub overwrite_existing: bool,
    pub output_dir: Option<PathBuf>,
    pub log_level: log::LevelFilter,
    pub edition: c2rust_rust_tools::RustEdition,
    /// Which direct calls to tiny `static` C helpers are substituted with the
    /// expression they stand for (`--inline=on|off|auto`, `--no-inline` =
    /// `--inline=off`).  See [`InlineMode`] and `translator/inline.rs`.
    pub inline: InlineMode,
    /// Declare the output `module <file stem> public` (`--public-module`).
    /// An anonymous module is enough for `require` and for the interpreter,
    /// the JIT and `-exe`, but daslang's AOT generator keeps a module's
    /// unexported functions only when the module is a named public one.
    pub public_module: bool,
    /// Write `options solid_context = true` into the module header
    /// (`--no-solid-context` turns it off).  Default on: every read of a
    /// translated C global is otherwise a mangled-name lookup through the
    /// context (`jit_get_global_mnh`), which a compiled mode cannot hoist out
    /// of a loop — measured at 1.27x -> 1.06x of C `-O2` on the h264bsd
    /// corpus case (`docs/followups/hot_path_levers.md`).  It changes nothing
    /// in the bodies and runs in the interpreter, `-jit`, `-exe` and AOT.
    pub solid_context: bool,
    /// Put `unsafe_deref` on every function this translator emits
    /// (`--unsafe-deref`, default off).  daScript's `ExprAt`, `ExprPtr2Ref`
    /// and field dereference emit a null check unless the *enclosing
    /// function* carries the annotation; the expression-level `unsafe` the
    /// translator writes does not suppress it.  Faithful to C — dereferencing
    /// a null pointer is undefined behaviour there, so the check is not a
    /// semantic the C program had — but it trades a located daScript
    /// exception for a SIGSEGV, which is why it is opt-in.
    pub unsafe_deref: bool,
    /// Extra `options <text>` lines after `options gen2` (`--das-option`,
    /// repeatable), for target-specific module options such as
    /// `disable_auto_inline` on an AOT build.
    pub das_options: Vec<String>,
    /// Which libc entry points this translation unit may call (`--libc`).
    /// See [`LibcMode`]; `nostd` is the default and leaves output unchanged.
    pub libc: LibcMode,
    /// Emit the program-wide runtime prelude (`translator::runtime_module_source`:
    /// the `c2da_rt_*` raw heap, the variadic cursor and the fixed numeric
    /// helpers) once, as the public module `<output dir>/<name>.das`, and make
    /// every translated unit `require <name>` instead of carrying its own copy
    /// (`--runtime-module <name>`).  `None`, the default, writes the prelude
    /// into every unit as before.  The `--libc std` prelude is not moved: its
    /// helper set is chosen per unit from the calls the unit makes and built
    /// on the unit's own Clang target facts (`libc.rs StdLayout`).
    pub runtime_module: Option<String>,
    /// How the program is laid out over daslang modules (`--module-layout`).
    /// See [`ModuleLayout`]; `unity` is the default and leaves output
    /// unchanged.
    pub module_layout: ModuleLayout,
    /// Translator diagnostics switched on beyond the default set
    /// (`-W<name>`); [`Diagnostic::All`] switches on every one of them.
    pub enabled_warnings: HashSet<Diagnostic>,
    /// Translator diagnostics switched off (`-Wno-<name>`). A name here wins
    /// over both the default set and `-Wall`.
    pub disabled_warnings: HashSet<Diagnostic>,
    /// Target switches for a runtime other than master daslang
    /// (`--target eden` and its individual flags, `target.rs`).  The
    /// default is master daslang and leaves output unchanged.
    pub target: target::TargetOptions,
}

/// AST-level inventory for target-specific C surfaces.  These counts are
/// taken after Clang CBOR has become the typed C AST, so they cannot be
/// confused with comments, disabled preprocessor branches, or source text.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct AsmSimdInventory {
    pub inline_asm: usize,
    pub shuffle_vector: usize,
    pub convert_vector: usize,
    pub vector_type: usize,
}

pub fn inventory_asm_simd(
    tcfg: &TranspilerConfig,
    cc_db: &Path,
    extra_clang_args: &[&str],
) -> Result<AsmSimdInventory, String> {
    let lcmds = get_compile_commands(cc_db, &tcfg.filter).map_err(|err| err.to_string())?;
    let mut inventory = AsmSimdInventory::default();
    for lcmd in &lcmds {
        for cmd in &lcmd.cmd_inputs {
            let input_path = cmd.abs_file();
            let untyped = ast_exporter::get_untyped_ast(
                &input_path,
                cc_db,
                extra_clang_args,
                tcfg.debug_ast_exporter,
            )
            .map_err(|err| format!("{}: {err}", input_path.display()))?;
            let typed = ConversionContext::new(&input_path, &untyped).into_typed_context();
            inventory.inline_asm += typed
                .iter_stmts()
                .filter(|(_, stmt)| matches!(stmt.kind, CStmtKind::Asm { .. }))
                .count();
            inventory.shuffle_vector += typed
                .iter_exprs()
                .filter(|(_, expr)| matches!(expr.kind, CExprKind::ShuffleVector(..)))
                .count();
            inventory.convert_vector += typed
                .iter_exprs()
                .filter(|(_, expr)| matches!(expr.kind, CExprKind::ConvertVector(..)))
                .count();
            inventory.vector_type += typed
                .iter_types()
                .filter(|(_, ty)| matches!(ty.kind, CTypeKind::Vector(..)))
                .count();
        }
    }
    Ok(inventory)
}

impl Default for TranspilerConfig {
    fn default() -> Self {
        TranspilerConfig {
            dump_untyped_context: false,
            dump_typed_context: false,
            pretty_typed_context: false,
            verbose: false,
            debug_ast_exporter: false,
            filter: None,
            translate_valist: false,
            overwrite_existing: false,
            output_dir: None,
            log_level: log::LevelFilter::Warn,
            edition: c2rust_rust_tools::RustEdition::Edition2021,
            inline: InlineMode::default(),
            public_module: false,
            solid_context: true,
            unsafe_deref: false,
            das_options: vec![],
            libc: LibcMode::NoStd,
            runtime_module: None,
            module_layout: ModuleLayout::Unity,
            enabled_warnings: HashSet::new(),
            disabled_warnings: HashSet::new(),
            target: target::TargetOptions::default(),
        }
    }
}

pub fn create_temp_compile_commands(sources: &[PathBuf]) -> (TempDir, PathBuf) {
    let temp_dir = tempfile::Builder::new()
        .prefix("c2dascript-")
        .tempdir()
        .expect("Failed to create temporary directory");
    let temp_path = temp_dir.path().join("compile_commands.json");
    let compile_commands: Vec<CompileCmd> = sources
        .iter()
        .map(|source_file| {
            let absolute_path = fs::canonicalize(source_file)
                .unwrap_or_else(|_| panic!("Could not canonicalize {}", source_file.display()));
            CompileCmd {
                directory: PathBuf::from("."),
                file: absolute_path.clone(),
                arguments: vec![
                    "clang".to_string(),
                    absolute_path.to_str().unwrap().to_owned(),
                ],
                command: None,
                output: None,
            }
        })
        .collect();
    let json_content = serde_json::to_string(&compile_commands).unwrap();
    let mut file =
        File::create(&temp_path).expect("Failed to create temporary compile_commands.json");
    file.write_all(json_content.as_bytes())
        .expect("Failed to write to temporary compile_commands.json");
    (temp_dir, temp_path)
}

/// Translate every selected command, continuing past a failed translation unit
/// so the rest of a compilation database is still processed, and report every
/// failure to the caller.
///
/// This is the permissive counterpart of [`transpile_checked`]: it differs only
/// in *when* it stops, never in what it accepts. A translation unit that cannot
/// be lowered produces no output file and is returned here as an error, so a
/// caller can never mistake a skipped unit for a successful one.
pub fn transpile(
    tcfg: TranspilerConfig,
    cc_db: &Path,
    extra_clang_args: &[&str],
) -> Result<Vec<PathBuf>, Vec<TranspileError>> {
    diagnostics::init(
        tcfg.enabled_warnings.clone(),
        tcfg.disabled_warnings.clone(),
        tcfg.log_level,
    );

    let lcmds = match get_compile_commands(cc_db, &tcfg.filter) {
        Ok(l) => l,
        Err(e) => {
            return Err(vec![TranspileError::CompileCommands(e.to_string())]);
        }
    };
    // The source layout links the units before translating any of them, so
    // it has no per-unit "continue past a failure" mode: a failed unit is a
    // failed program.
    if tcfg.module_layout == ModuleLayout::Source {
        return transpile_source_layout(
            &tcfg,
            &lcmds
                .iter()
                .flat_map(|lcmd| lcmd.cmd_inputs.iter().map(|cmd| cmd.abs_file()))
                .collect::<Vec<_>>(),
            cc_db,
            extra_clang_args,
        )
            .map_err(|error| vec![error]);
    }

    let mut outputs = Vec::new();
    let mut failures = Vec::new();
    for lcmd in &lcmds {
        for cmd in &lcmd.cmd_inputs {
            match transpile_single_checked(&tcfg, &cmd.abs_file(), cc_db, extra_clang_args) {
                Ok(path) => outputs.push(path),
                Err(error) => {
                    warn!("Failed to transpile {}", cmd.abs_file().display());
                    failures.push(error);
                }
            }
        }
    }
    if failures.is_empty() {
        write_runtime_module(&tcfg).map_err(|error| vec![error])?;
        Ok(outputs)
    } else {
        Err(failures)
    }
}

/// Writes the shared runtime module `<output dir>/<name>.das` when
/// [`TranspilerConfig::runtime_module`] names one, and returns its path.
///
/// The module is a function of the configuration alone — no translation unit
/// contributes to it — so it is written once, after every unit translated,
/// and never for a run that failed: a failed translation writes no file.
fn write_runtime_module(tcfg: &TranspilerConfig) -> Result<Option<PathBuf>, TranspileError> {
    let Some(name) = &tcfg.runtime_module else {
        return Ok(None);
    };
    let output_dir = tcfg.output_dir.clone().unwrap_or_else(|| PathBuf::from("."));
    fs::create_dir_all(&output_dir).map_err(|error| TranspileError::Output {
        path: output_dir.clone(),
        error,
    })?;
    let output_path = output_dir.join(name).with_extension("das");
    let source =
        translator::runtime_module_source(tcfg, name).map_err(TranspileError::Translation)?;
    fs::write(&output_path, source).map_err(|error| TranspileError::Output {
        path: output_path.clone(),
        error,
    })?;
    println!("Wrote {}", output_path.display());
    Ok(Some(output_path))
}

/// Translate every selected command and return every output path, failing on
/// the first unsupported user declaration. This is the canonical API for
/// fixture assertions and executable cases; it never writes next to a source
/// file when [`TranspilerConfig::output_dir`] is set.
pub fn transpile_checked(
    tcfg: TranspilerConfig,
    cc_db: &Path,
    extra_clang_args: &[&str],
) -> Result<Vec<PathBuf>, TranspileError> {
    diagnostics::init(
        tcfg.enabled_warnings.clone(),
        tcfg.disabled_warnings.clone(),
        tcfg.log_level,
    );
    let lcmds = get_compile_commands(cc_db, &tcfg.filter)
        .map_err(|error| TranspileError::CompileCommands(error.to_string()))?;
    if tcfg.module_layout == ModuleLayout::Source {
        return transpile_source_layout(
            &tcfg,
            &lcmds
                .iter()
                .flat_map(|lcmd| lcmd.cmd_inputs.iter().map(|cmd| cmd.abs_file()))
                .collect::<Vec<_>>(),
            cc_db,
            extra_clang_args,
        );
    }
    let mut outputs = Vec::new();
    for lcmd in &lcmds {
        for cmd in &lcmd.cmd_inputs {
            outputs.push(transpile_single_checked(
                &tcfg,
                &cmd.abs_file(),
                cc_db,
                extra_clang_args,
            )?);
        }
    }
    write_runtime_module(&tcfg)?;
    Ok(outputs)
}

fn output_path_for(tcfg: &TranspilerConfig, input_path: &Path) -> Result<PathBuf, TranspileError> {
    if let Some(output_dir) = &tcfg.output_dir {
        fs::create_dir_all(output_dir).map_err(|error| TranspileError::Output {
            path: output_dir.clone(),
            error,
        })?;
        let filename = input_path
            .file_name()
            .ok_or_else(|| TranspileError::MissingInput(input_path.to_path_buf()))?;
        return Ok(output_dir.join(filename).with_extension("das"));
    }
    Ok(input_path.with_extension("das"))
}

fn transpile_single_checked(
    tcfg: &TranspilerConfig,
    input_path: &Path,
    cc_db: &Path,
    extra_clang_args: &[&str],
) -> Result<PathBuf, TranspileError> {
    let file = input_path
        .file_stem()
        .and_then(|s| s.to_str())
        .unwrap_or("unknown");
    if !input_path.exists() {
        warn!(
            "Input C file {} does not exist, skipping!",
            input_path.display()
        );
        return Err(TranspileError::MissingInput(input_path.to_path_buf()));
    }

    println!("Transpiling {}", file);

    let typed_context = typed_context_for(tcfg, input_path, cc_db, extra_clang_args)?;

    let (das_code, _maybe_decl_map, _pragmas, _crates) =
        translator::translate_checked(typed_context, tcfg, input_path)
            .map_err(TranspileError::Translation)?;

    let output_path = output_path_for(tcfg, input_path)?;
    write_output(&output_path, &das_code)?;
    Ok(output_path)
}

/// Runs the Clang exporter over one unit and types its AST.
fn typed_context_for(
    tcfg: &TranspilerConfig,
    input_path: &Path,
    cc_db: &Path,
    extra_clang_args: &[&str],
) -> Result<TypedAstContext, TranspileError> {
    let untyped_context = match ast_exporter::get_untyped_ast(
        input_path,
        cc_db,
        extra_clang_args,
        tcfg.debug_ast_exporter,
    ) {
        Err(e) => {
            warn!(
                "Error: {}. Skipping {}; is it well-formed C?",
                e,
                input_path.display()
            );
            return Err(TranspileError::ClangAst(e));
        }
        Ok(cxt) => cxt,
    };
    let conv = ConversionContext::new(input_path, &untyped_context);
    Ok(conv.into_typed_context())
}

fn write_output(output_path: &Path, das_code: &str) -> Result<(), TranspileError> {
    let mut file = File::create(output_path).map_err(|error| TranspileError::Output {
        path: output_path.to_path_buf(),
        error,
    })?;
    file.write_all(das_code.as_bytes())
        .map_err(|error| TranspileError::Output {
            path: output_path.to_path_buf(),
            error,
        })?;
    println!("Wrote {}", output_path.display());
    Ok(())
}

/// `--module-layout source`: one `module <stem>` per unit plus the shared
/// module, written only once every unit has translated.  Units on a reference
/// cycle are one module, a cluster: `<name>.das` holds the header, options and
/// `require`s and `include`s each member's `<stem>.das.inc` fragment.
///
/// The link pre-pass ([`link_units`]) reads every unit's Clang AST before any
/// is translated: it needs the whole program to say which module owns each
/// external symbol, which units form clusters, and it refuses a symbol two
/// units define.  A cluster is translated twice: the first pass learns every
/// fragment's module-level declarations, which the second gives each member
/// for its initialization-order pass and which order the includes.  The shared module then takes the runtime
/// prelude, the merged C type section — the same C type reaches it once, and
/// a unit whose copy of a type prints differently fails closed, so a type
/// crossing a call boundary is one daslang type — and the union of the
/// units' `--libc std` helpers.
fn transpile_source_layout(
    tcfg: &TranspilerConfig,
    inputs: &[PathBuf],
    cc_db: &Path,
    extra_clang_args: &[&str],
) -> Result<Vec<PathBuf>, TranspileError> {
    let mut contexts = Vec::with_capacity(inputs.len());
    for input_path in inputs {
        if !input_path.exists() {
            return Err(TranspileError::MissingInput(input_path.clone()));
        }
        println!("Reading {}", input_path.display());
        contexts.push(typed_context_for(
            tcfg,
            input_path,
            cc_db,
            extra_clang_args,
        )?);
    }
    let runtime_module = tcfg
        .runtime_module
        .clone()
        .unwrap_or_else(|| DEFAULT_RUNTIME_MODULE.to_owned());
    let (links, clusters) = link_units(inputs, &contexts, &runtime_module)?;
    let shared_tcfg = TranspilerConfig {
        runtime_module: Some(runtime_module.clone()),
        ..tcfg.clone()
    };
    let output_dir = tcfg.output_dir.clone().unwrap_or_else(|| PathBuf::from("."));
    let mut cluster_of: HashMap<usize, usize> = HashMap::new();
    for (index, cluster) in clusters.iter().enumerate() {
        for &member in &cluster.members {
            cluster_of.insert(member, index);
        }
    }
    // Per cluster: the module-level declarations its fragments made so far,
    // name → (text, unit), and the union of their `require`s.
    let mut cluster_decls: Vec<BTreeMap<String, (String, PathBuf)>> =
        vec![BTreeMap::new(); clusters.len()];
    let mut cluster_requires: Vec<BTreeSet<String>> = vec![BTreeSet::new(); clusters.len()];

    // Every fragment's initialization-order pass needs the module-level
    // functions and objects of its module mates (`UnitLink::foreign_refs`),
    // which exist only once those are translated: a cluster is translated a
    // first time, with the same name reservations, to learn them.
    let mut links = links;
    let mut clusters = clusters;
    for cluster in &mut clusters {
        let mut declared: BTreeSet<String> = BTreeSet::new();
        let mut reads: Vec<Vec<(String, Vec<String>)>> = Vec::new();
        let mut objects: Vec<BTreeSet<String>> = Vec::new();
        for &member in &cluster.members {
            let mut link = links[member].clone();
            link.reserved_values.extend(declared.iter().cloned());
            let output = translator::translate_unit(
                contexts[member].clone(),
                &shared_tcfg,
                &inputs[member],
                link,
            )
            .map_err(TranspileError::Translation)?;
            declared.extend(output.fragment_decls.iter().map(fragment_decl_name));
            objects.push(
                output
                    .fragment_decls
                    .iter()
                    .filter(|decl| match decl {
                        DaDecl::Private(inner) => matches!(**inner, DaDecl::Variable(_)),
                        other => matches!(other, DaDecl::Variable(_)),
                    })
                    .map(fragment_decl_name)
                    .collect(),
            );
            reads.push(
                output
                    .fragment_decls
                    .iter()
                    .filter_map(translator::module_level_reads)
                    .collect(),
            );
        }
        for (index, &member) in cluster.members.iter().enumerate() {
            for (other, member_reads) in reads.iter().enumerate() {
                if other == index {
                    continue;
                }
                for (name, names) in member_reads {
                    links[member]
                        .foreign_refs
                        .entry(name.clone())
                        .or_insert_with(|| names.clone());
                }
            }
        }
        cluster.members = include_order(&cluster.members, &reads, &objects);
    }

    let mut sources: Vec<(PathBuf, String)> = Vec::with_capacity(inputs.len());
    let mut shared_types: Vec<DaDecl> = Vec::new();
    let mut shared_type_text: HashMap<String, (String, PathBuf)> = HashMap::new();
    let mut libc_helpers: BTreeMap<String, (DaDecl, PathBuf)> = BTreeMap::new();
    let mut program_linear = translator::LinearLink::default();
    for (unit, ((input_path, context), mut link)) in
        inputs.iter().zip(contexts).zip(links).enumerate()
    {
        println!("Transpiling {}", link.module);
        let cluster = cluster_of.get(&unit).copied();
        if let Some(cluster) = cluster {
            // Units of one cluster are translated in compilation-database
            // order, each after reserving every name the earlier ones
            // declared, so a later unit's same-named static is renamed.
            link.reserved_values
                .extend(cluster_decls[cluster].keys().cloned());
        }
        // `--memory-model linear`: units are laid out in the one heap in this
        // order, each continuing the static block and the function tables of
        // the ones before it.
        link.linear = program_linear.clone();
        let output = translator::translate_unit(context, &shared_tcfg, input_path, link)
            .map_err(TranspileError::Translation)?;
        if let Some(state) = output.linear {
            program_linear = state;
        }
        for decl in output.shared_types {
            let key = shared_decl_key(&decl);
            let text = decl.to_string();
            // A unit that only sees `struct S;` (an opaque handle, C11
            // 6.2.5p22) declares the record with no fields; the unit that
            // completes it owns the one shared declaration.
            let is_opaque_record = |d: &DaDecl| {
                matches!(d, DaDecl::Structure(s) if s.fields.is_empty())
            };
            match shared_type_text.get(&key) {
                None => {
                    shared_type_text.insert(key, (text, input_path.clone()));
                    shared_types.push(decl);
                }
                Some((seen, _)) if *seen == text => {}
                Some(_) if is_opaque_record(&decl) => {}
                Some((seen, _))
                    if matches!(&shared_types.iter().find(|d| shared_decl_key(d) == key),
                        Some(d) if is_opaque_record(d)) =>
                {
                    let _ = seen;
                    let position = shared_types
                        .iter()
                        .position(|d| shared_decl_key(d) == key)
                        .expect("the opaque declaration is in the shared set");
                    shared_types[position] = decl;
                    shared_type_text.insert(key, (text, input_path.clone()));
                }
                Some((seen, first)) => {
                    let differing = seen
                        .lines()
                        .zip(text.lines())
                        .find(|(a, b)| a != b)
                        .map(|(a, b)| format!("; first difference: `{a}` vs `{b}`"))
                        .unwrap_or_default();
                    return Err(TranspileError::Layout(format!(
                        "{key} is declared differently by {} and {}; the source layout \
                         shares one declaration of every C type{differing}",
                        first.display(),
                        input_path.display()
                    )));
                }
            }
        }
        for decl in output.libc_helpers {
            let key = shared_decl_key(&decl);
            match libc_helpers.get(&key) {
                None => {
                    libc_helpers.insert(key, (decl, input_path.clone()));
                }
                Some((seen, _)) if seen.to_string() == decl.to_string() => {}
                Some((_, first)) => {
                    return Err(TranspileError::Layout(format!(
                        "std helper {key} is built differently by {} and {} (different C \
                         target facts); the source layout shares one std prelude",
                        first.display(),
                        input_path.display()
                    )));
                }
            }
        }
        let Some(cluster) = cluster else {
            sources.push((output_path_for(tcfg, input_path)?, output.source));
            continue;
        };
        // A fragment: declarations only.  A name an earlier fragment of the
        // cluster declared can only be a generated helper with a fixed name
        // (a renamer-picked name avoids the reserved ones); the same text is
        // declared once, a different one fails closed.
        let mut text = String::new();
        for decl in output.fragment_decls {
            let name = fragment_decl_name(&decl);
            let decl_text = decl.to_string();
            match cluster_decls[cluster].get(&name) {
                Some((seen, _)) if *seen == decl_text => continue,
                Some((_, first)) => {
                    return Err(TranspileError::Layout(format!(
                        "{name} is declared differently by {} and {}, which reference each \
                         other in a cycle and share one module",
                        first.display(),
                        input_path.display()
                    )));
                }
                None => {
                    cluster_decls[cluster].insert(name, (decl_text.clone(), input_path.clone()));
                }
            }
            text.push_str(&decl_text);
            text.push('\n');
        }
        cluster_requires[cluster].extend(output.requires);
        fs::create_dir_all(&output_dir).map_err(|error| TranspileError::Output {
            path: output_dir.clone(),
            error,
        })?;
        sources.push((
            output_dir.join(format!("{}.{FRAGMENT_EXTENSION}", stem_of_path(input_path))),
            text,
        ));
    }

    let mut outputs = Vec::with_capacity(sources.len() + 1);
    for (output_path, source) in &sources {
        write_output(output_path, source)?;
        outputs.push(output_path.clone());
    }
    for (cluster, requires) in clusters.iter().zip(cluster_requires) {
        // The cluster's own name is not a module to require; the shared
        // runtime module and the std prelude's daslib modules are, first.
        let mut ordered: Vec<String> = Vec::new();
        for require in std::iter::once(runtime_module.clone())
            .chain(requires.iter().filter(|r| **r != runtime_module).cloned())
        {
            if require != cluster.name && requires.contains(&require) && !ordered.contains(&require)
            {
                ordered.push(require);
            }
        }
        let includes: Vec<String> = cluster
            .members
            .iter()
            .map(|&member| format!("{}.{FRAGMENT_EXTENSION}", stem_of_path(&inputs[member])))
            .collect();
        let path = output_dir.join(format!("{}.das", cluster.name));
        let source = translator::cluster_module_source(
            &shared_tcfg,
            &cluster.name,
            !cluster.entry,
            ordered,
            &includes,
        );
        write_output(&path, &source)?;
        outputs.push(path);
    }
    let shared_path = output_dir.join(&runtime_module).with_extension("das");
    let shared_source = translator::shared_module_source(
        &shared_tcfg,
        &runtime_module,
        shared_types,
        libc_helpers.into_values().map(|(decl, _)| decl).collect(),
        (tcfg.target.memory_model == crate::target::MemoryModel::Linear).then_some(&program_linear),
    )
    .map_err(TranspileError::Translation)?;
    write_output(&shared_path, &shared_source)?;
    outputs.push(shared_path);
    Ok(outputs)
}

/// The extension of a cluster member's fragment file, `<stem>.das.inc`.  It is
/// not `.das` because a fragment is not a program on its own (no header, no
/// `require`s, names its module mates define) and a tool that compiles every
/// `.das` file of a directory standalone — the EdenSpark editor among them,
/// `docs/eden-flags.md` — must not pick it up; daslang's `include` accepts any
/// file name.
pub const FRAGMENT_EXTENSION: &str = "das.inc";

/// The order a cluster's module file includes its fragments in.
///
/// daslang initializes a module's objects in declaration order, `include`
/// being textual, and rejects an initializer that names an object declared
/// after it — following functions, through calls and `@@`, to the objects
/// their bodies name (`global_order.rs`).  A fragment whose initializers
/// reach another fragment's objects is therefore included after it.  The
/// order is otherwise the compilation database's; fragments that reach each
/// other's objects keep that order, and daslang reports the object it cannot
/// initialize.  `reads[i]`/`objects[i]` describe `members[i]` (name → names
/// its body or initializer reads; the names of its objects).
fn include_order(
    members: &[usize],
    reads: &[Vec<(String, Vec<String>)>],
    objects: &[BTreeSet<String>],
) -> Vec<usize> {
    let mut refs: HashMap<&str, &[String]> = HashMap::new();
    let mut owner: HashMap<&str, usize> = HashMap::new();
    for (index, member_reads) in reads.iter().enumerate() {
        for (name, names) in member_reads {
            refs.entry(name.as_str()).or_insert(names.as_slice());
        }
        for object in &objects[index] {
            owner.entry(object.as_str()).or_insert(index);
        }
    }
    let count = members.len();
    let mut after: Vec<BTreeSet<usize>> = vec![BTreeSet::new(); count];
    for index in 0..count {
        let mut pending: Vec<&str> = reads[index]
            .iter()
            .filter(|(name, _)| objects[index].contains(name))
            .flat_map(|(_, names)| names.iter().map(String::as_str))
            .collect();
        let mut seen: HashSet<&str> = HashSet::new();
        while let Some(name) = pending.pop() {
            if !seen.insert(name) {
                continue;
            }
            if let Some(&other) = owner.get(name) {
                if other != index {
                    after[index].insert(other);
                }
                continue;
            }
            if let Some(names) = refs.get(name) {
                pending.extend(names.iter().map(String::as_str));
            }
        }
    }
    let mut placed = vec![false; count];
    let mut order = Vec::with_capacity(count);
    while order.len() < count {
        // The first fragment, in database order, whose dependencies are
        // placed; on a cycle, the first unplaced one.
        let next = (0..count)
            .find(|&index| !placed[index] && after[index].iter().all(|&dep| placed[dep]))
            .or_else(|| (0..count).find(|&index| !placed[index]))
            .expect("an unplaced fragment remains");
        placed[next] = true;
        order.push(members[next]);
    }
    order
}

/// The module-level name a fragment's declaration takes.
fn fragment_decl_name(decl: &DaDecl) -> String {
    let key = shared_decl_key(decl);
    key.split_once(' ')
        .map_or(key.clone(), |(_, name)| name.to_owned())
}

fn stem_of_path(path: &Path) -> String {
    path.file_stem()
        .map(|stem| stem.to_string_lossy().into_owned())
        .unwrap_or_default()
}

/// `kind name` of a shared declaration, the identity it is merged by.
fn shared_decl_key(decl: &DaDecl) -> String {
    match decl {
        DaDecl::Function(f) => format!("function {}", f.name),
        DaDecl::Variable(v) => format!("variable {}", v.name),
        DaDecl::Structure(s) => format!("struct {}", s.name),
        DaDecl::Enumeration(e) => format!("enum {}", e.name),
        DaDecl::Alias(a) => format!("typedef {}", a.name),
        DaDecl::Private(inner) => shared_decl_key(inner),
    }
}

/// The link pre-pass of the source layout.
///
/// A unit defines the external symbols it gives external linkage and a body
/// or an object (C11 6.2.2, 6.9.2); it references every external function
/// and object it declares without defining.  A reference to a symbol no unit
/// defines is not a link edge — the unit's own lowering fails closed on a
/// call to it as before, and an unused prototype from a header costs nothing.
/// daslang refuses a cyclic `require`, so the units of every strongly
/// connected component of the edges unit → owner become one module, a
/// [`SourceCluster`]; the components then form a DAG of `require`s.
fn link_units(
    inputs: &[PathBuf],
    contexts: &[TypedAstContext],
    runtime_module: &str,
) -> Result<(Vec<translator::UnitLink>, Vec<SourceCluster>), TranspileError> {
    let mut stems: Vec<String> = Vec::with_capacity(inputs.len());
    let mut stem_of: HashMap<String, PathBuf> = HashMap::new();
    for input in inputs {
        let stem = input
            .file_stem()
            .map(|s| s.to_string_lossy().into_owned())
            .ok_or_else(|| TranspileError::MissingInput(input.clone()))?;
        if let Some(other) = stem_of.insert(stem.clone(), input.clone()) {
            return Err(TranspileError::Layout(format!(
                "{} and {} would both become module {stem}",
                other.display(),
                input.display()
            )));
        }
        if stem == runtime_module {
            return Err(TranspileError::Layout(format!(
                "{} would become module {stem}, the shared runtime module's name",
                input.display()
            )));
        }
        stems.push(stem);
    }

    let mut owner: HashMap<String, usize> = HashMap::new();
    let mut references: Vec<BTreeSet<String>> = Vec::with_capacity(inputs.len());
    // The unit defining C `main` stays an anonymous module so daslang runs
    // it as the program (`translator::translate_impl`); nothing may `require`
    // it.
    let mut entry_unit: Option<usize> = None;
    for (unit, context) in contexts.iter().enumerate() {
        let mut defines = BTreeSet::new();
        let mut refs = BTreeSet::new();
        for (_, decl) in context.iter_decls() {
            match &decl.kind {
                CDeclKind::Function {
                    is_global: true,
                    name,
                    body: Some(_),
                    ..
                } => {
                    defines.insert(name.clone());
                }
                CDeclKind::Variable {
                    has_static_duration: true,
                    is_externally_visible: true,
                    is_defn: true,
                    ident,
                    ..
                } => {
                    defines.insert(ident.clone());
                }
                _ => {}
            }
        }
        // A reference is a use, not a declaration: a header's prototype that
        // the unit never names makes no edge (it would make every pair of
        // units sharing a header a cycle).
        for (_, expr) in context.iter_exprs() {
            let CExprKind::DeclRef(_, decl_id, _) = expr.kind else {
                continue;
            };
            match &context[decl_id].kind {
                CDeclKind::Function {
                    is_global: true,
                    name,
                    ..
                } => {
                    refs.insert(name.clone());
                }
                CDeclKind::Variable {
                    has_static_duration: true,
                    is_externally_visible: true,
                    ident,
                    ..
                } => {
                    refs.insert(ident.clone());
                }
                _ => {}
            }
        }
        for name in defines {
            if name == "main" {
                entry_unit = Some(unit);
                continue;
            }
            refs.remove(&name);
            if let Some(&other) = owner.get(&name) {
                return Err(TranspileError::Layout(format!(
                    "{name} is defined by both {} and {}",
                    inputs[other].display(),
                    inputs[unit].display()
                )));
            }
            owner.insert(name, unit);
        }
        references.push(refs);
    }

    // The edges unit → owner of a symbol it references.
    let edges: Vec<BTreeSet<usize>> = references
        .iter()
        .enumerate()
        .map(|(unit, refs)| {
            refs.iter()
                .filter_map(|name| owner.get(name).copied())
                .filter(|&other| other != unit)
                .collect()
        })
        .collect();

    // Units that reference each other in a cycle — a strongly connected
    // component of the graph — cannot be modules that `require` each other;
    // they are one module, a cluster.  The component of a unit is found by
    // Tarjan's algorithm; a component's identity is its lowest unit index.
    let component = strongly_connected_components(&edges);
    let mut clusters: Vec<SourceCluster> = Vec::new();
    let mut cluster_of: Vec<Option<usize>> = vec![None; inputs.len()];
    for unit in 0..inputs.len() {
        let members: Vec<usize> = (0..inputs.len())
            .filter(|&other| component[other] == component[unit])
            .collect();
        if members.len() < 2 || members[0] != unit {
            continue;
        }
        // Named after the lexically first member's stem, so the name depends
        // on the program and not on the order of the compilation database.
        let first = members
            .iter()
            .map(|&member| stems[member].as_str())
            .min()
            .expect("a cluster has members");
        // The cluster holding C `main` is the program daslang runs, an
        // anonymous module; it takes the entry unit's name so the program
        // file is `<entry stem>.das` whatever the layout of the units.
        let entry = entry_unit.filter(|entry| members.contains(entry));
        let name = match entry {
            Some(entry) => stems[entry].clone(),
            None => format!("{first}_cluster"),
        };
        if let Some(other) = stem_of.get(&name).filter(|_| entry.is_none()) {
            return Err(TranspileError::Layout(format!(
                "{} would become module {name}, the name of the module of the units that \
                 reference each other in a cycle: {}",
                other.display(),
                members
                    .iter()
                    .map(|&member| inputs[member].display().to_string())
                    .collect::<Vec<_>>()
                    .join(", ")
            )));
        }
        if name == runtime_module {
            return Err(TranspileError::Layout(format!(
                "the cluster module {name} would take the shared runtime module's name"
            )));
        }
        for &member in &members {
            cluster_of[member] = Some(clusters.len());
        }
        clusters.push(SourceCluster {
            name,
            entry: entry.is_some(),
            members,
        });
    }
    let module_of = |unit: usize| -> String {
        match cluster_of[unit] {
            Some(cluster) => clusters[cluster].name.clone(),
            None => stems[unit].clone(),
        }
    };

    // A C type name two units define at different places is two C types
    // (a file-local `typedef struct {..} anim_t;` in each), and every C type
    // lives in the one shared module: the definition at the lexically first
    // place keeps the name, the n-th other place reserves the name and its
    // first n-1 renamer spellings so that the renamer gives it `<name>_<n-1>`.
    let mut type_sites: BTreeMap<(&'static str, String), BTreeMap<String, Vec<usize>>> =
        BTreeMap::new();
    for (unit, context) in contexts.iter().enumerate() {
        for (_, decl) in context.iter_decls() {
            let (kind, name) = match &decl.kind {
                CDeclKind::Typedef { name, .. } => ("typedef", name.clone()),
                CDeclKind::Struct {
                    name: Some(name),
                    fields: Some(_),
                    ..
                }
                | CDeclKind::Union {
                    name: Some(name),
                    fields: Some(_),
                    ..
                } => ("record", name.clone()),
                CDeclKind::Enum {
                    name: Some(name),
                    variants,
                    ..
                } if !variants.is_empty() => ("enum", name.clone()),
                _ => continue,
            };
            let Some(site) = context.display_loc(&decl.loc) else {
                continue;
            };
            let units = type_sites
                .entry((kind, name))
                .or_default()
                .entry(site.to_string())
                .or_default();
            if !units.contains(&unit) {
                units.push(unit);
            }
        }
    }
    let mut reserved_types: Vec<Vec<String>> = vec![Vec::new(); inputs.len()];
    for ((_, name), sites) in &type_sites {
        for (index, units) in sites.values().enumerate().skip(1) {
            for &unit in units {
                reserved_types[unit].push(name.clone());
                reserved_types[unit].extend((0..index - 1).map(|n| format!("{name}_{n}")));
            }
        }
    }

    let mut links: Vec<translator::UnitLink> = Vec::with_capacity(inputs.len());
    for (unit, refs) in references.iter().enumerate() {
        let mut owners = HashMap::new();
        let mut requires = BTreeSet::new();
        for name in refs {
            if let Some(&other) = owner.get(name) {
                if other != unit {
                    let same_module =
                        cluster_of[unit].is_some() && cluster_of[unit] == cluster_of[other];
                    let other_is_entry = match cluster_of[other] {
                        Some(cluster) => clusters[cluster].entry,
                        None => entry_unit == Some(other),
                    };
                    if other_is_entry && !same_module {
                        return Err(TranspileError::Layout(format!(
                            "{} references {name}, defined by {} in the entry module; the \
                             module with `main` is run as the program and cannot be required",
                            inputs[unit].display(),
                            inputs[other].display()
                        )));
                    }
                    owners.insert(name.clone(), module_of(other));
                    if !same_module {
                        requires.insert(module_of(other));
                    }
                }
            }
        }
        // A cluster member must not declare, as a private name, a name its
        // module mates define as an external symbol.
        let reserved_values = match cluster_of[unit] {
            Some(cluster) => clusters[cluster]
                .members
                .iter()
                .filter(|&&member| member != unit)
                .flat_map(|&member| {
                    owner
                        .iter()
                        .filter(move |(_, &defining)| defining == member)
                        .map(|(name, _)| name.clone())
                })
                .collect::<BTreeSet<_>>()
                .into_iter()
                .collect(),
            None => vec![],
        };
        links.push(translator::UnitLink {
            module: stems[unit].clone(),
            owners,
            requires: requires.into_iter().collect(),
            fragment: cluster_of[unit].is_some(),
            reserved_values,
            reserved_types: std::mem::take(&mut reserved_types[unit]),
            foreign_refs: HashMap::new(),
            linear: Default::default(),
        });
    }
    Ok((links, clusters))
}

/// Units of a `--module-layout source` program that reference each other in
/// a cycle and so are compiled as one daslang module (`link_units`).
struct SourceCluster {
    /// `<lexically first member stem>_cluster`, or the entry unit's stem for
    /// the cluster holding C `main`.
    name: String,
    /// Member units, in compilation-database order.
    members: Vec<usize>,
    /// A member defines C `main`: the module is the program and anonymous.
    entry: bool,
}

/// Tarjan's strongly connected components: the component id of every node.
fn strongly_connected_components(edges: &[BTreeSet<usize>]) -> Vec<usize> {
    struct State<'e> {
        edges: &'e [BTreeSet<usize>],
        index: Vec<Option<usize>>,
        low: Vec<usize>,
        on_stack: Vec<bool>,
        stack: Vec<usize>,
        next: usize,
        component: Vec<usize>,
    }
    fn visit(state: &mut State, node: usize) {
        state.index[node] = Some(state.next);
        state.low[node] = state.next;
        state.next += 1;
        state.stack.push(node);
        state.on_stack[node] = true;
        for &next in state.edges[node].iter() {
            match state.index[next] {
                None => {
                    visit(state, next);
                    state.low[node] = state.low[node].min(state.low[next]);
                }
                Some(index) if state.on_stack[next] => {
                    state.low[node] = state.low[node].min(index);
                }
                Some(_) => {}
            }
        }
        if Some(state.low[node]) == state.index[node] {
            let mut members = Vec::new();
            loop {
                let member = state.stack.pop().expect("the root is on the stack");
                state.on_stack[member] = false;
                members.push(member);
                if member == node {
                    break;
                }
            }
            let id = *members.iter().min().expect("a component has members");
            for member in members {
                state.component[member] = id;
            }
        }
    }
    let count = edges.len();
    let mut state = State {
        edges,
        index: vec![None; count],
        low: vec![0; count],
        on_stack: vec![false; count],
        stack: Vec::new(),
        next: 0,
        component: (0..count).collect(),
    };
    for node in 0..count {
        if state.index[node].is_none() {
            visit(&mut state, node);
        }
    }
    state.component
}

use crate::compile_cmds::CompileCmd;
