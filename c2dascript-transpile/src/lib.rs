#![allow(clippy::too_many_arguments)]

mod diagnostics;

pub mod build_files;
pub mod c_ast;
pub mod cfg;
mod compile_cmds;
pub mod convert_type;
pub mod renamer;
pub mod translator;
pub mod with_stmts;

use std::collections::HashSet;
use std::fs::{self, File};
use std::io::Write;
use std::path::{Path, PathBuf};

use log::warn;
use regex::Regex;
pub use tempfile::TempDir;

use crate::c_ast::*;
pub use crate::diagnostics::Diagnostic;
use c2rust_ast_exporter as ast_exporter;

use crate::compile_cmds::get_compile_commands;
use std::prelude::v1::Vec;

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

/// Configuration settings for the translation process
#[derive(Debug)]
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

pub fn transpile(tcfg: TranspilerConfig, cc_db: &Path, extra_clang_args: &[&str]) {
    diagnostics::init(HashSet::new(), tcfg.log_level);

    let lcmds = match get_compile_commands(cc_db, &tcfg.filter) {
        Ok(l) => l,
        Err(e) => {
            warn!(
                "Could not parse compile commands from {}: {}",
                cc_db.to_string_lossy(),
                e
            );
            return;
        }
    };

    for lcmd in &lcmds {
        let cmds = &lcmd.cmd_inputs;
        for cmd in cmds {
            if let Err(_) = transpile_single(&tcfg, &cmd.abs_file(), cc_db, extra_clang_args) {
                warn!("Failed to transpile {}", cmd.abs_file().display());
            }
        }
    }
}

fn transpile_single(
    tcfg: &TranspilerConfig,
    input_path: &Path,
    cc_db: &Path,
    extra_clang_args: &[&str],
) -> Result<PathBuf, ()> {
    let file = input_path
        .file_stem()
        .and_then(|s| s.to_str())
        .unwrap_or("unknown");
    if !input_path.exists() {
        warn!(
            "Input C file {} does not exist, skipping!",
            input_path.display()
        );
        return Err(());
    }

    println!("Transpiling {}", file);

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
            return Err(());
        }
        Ok(cxt) => cxt,
    };

    let typed_context = {
        let conv = ConversionContext::new(input_path, &untyped_context);
        conv.into_typed_context()
    };

    let (das_code, _maybe_decl_map, _pragmas, _crates) =
        translator::translate(typed_context, tcfg, input_path);

    let output_path = input_path.with_extension("das");
    if let Err(e) = (|| -> Result<(), std::io::Error> {
        let mut file = File::create(&output_path)?;
        file.write_all(das_code.as_bytes())?;
        Ok(())
    })() {
        warn!("Unable to write to {}: {}", output_path.display(), e);
        return Err(());
    }

    println!("Wrote {}", output_path.display());
    Ok(output_path)
}

use crate::compile_cmds::CompileCmd;
