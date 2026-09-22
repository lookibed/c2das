use std::collections::HashSet;
use std::env;
use std::path::Path;
use std::str::FromStr;

use c2dascript_transpile::Diagnostic;

fn main() {
    let mut args: Vec<String> = env::args().skip(1).collect();
    eprintln!("c2dascript-transpile v{}", env!("CARGO_PKG_VERSION"));

    if args.is_empty() {
        eprintln!("Usage: c2dascript-transpile <compile_commands.json> [extra_clang_args...]");
        eprintln!("   or: c2dascript-transpile [--strict] [--no-inline] [--public-module] [--no-solid-context] [--unsafe-deref] [--das-option <text>]... [--libc nostd|std|ffi|all] [-W[no-]<diagnostic>]... [--output-dir <dir>] --file <file.c> [extra_clang_args...]");
        std::process::exit(1);
    }

    let strict = take_flag(&mut args, "--strict");
    // Opt out of substituting tiny `static` helpers at their call sites, so
    // the effect of that substitution can be measured against this build.
    let no_inline = take_flag(&mut args, "--no-inline");
    // Module header the output declares: `module <stem> public` and extra
    // `options` lines (see TranspilerConfig::public_module / das_options).
    let public_module = take_flag(&mut args, "--public-module");
    // `options solid_context = true` is the translator's default header line;
    // this drops it, for a build that wants daslang's per-read global lookup
    // back (see TranspilerConfig::solid_context).
    let no_solid_context = take_flag(&mut args, "--no-solid-context");
    // Put `unsafe_deref` on every emitted function: a null dereference then
    // faults instead of raising daslang's located exception.  Off by default;
    // see TranspilerConfig::unsafe_deref.
    let unsafe_deref = take_flag(&mut args, "--unsafe-deref");
    let mut das_options: Vec<String> = Vec::new();
    while let Some(option) = take_option(&mut args, "--das-option") {
        das_options.push(option.to_string_lossy().into_owned());
    }
    // The translator's own diagnostic switches, e.g. `-Wno-must-tail`.  Every
    // other `-W…` argument is clang's and is left in `args`.
    let (enabled_warnings, disabled_warnings) = take_warning_switches(&mut args);
    // Which libc entry points the translated module may call. `nostd` is the
    // default and the only mode that is fully implemented besides `std`.
    let libc = match take_value(&mut args, "--libc") {
        Some(text) => match c2dascript_transpile::LibcMode::parse(&text) {
            Some(mode) => mode,
            None => {
                let modes: Vec<&str> = c2dascript_transpile::LibcMode::ALL
                    .iter()
                    .map(|mode| mode.as_str())
                    .collect();
                eprintln!(
                    "unknown libc mode '{text}'; expected one of {}",
                    modes.join(", ")
                );
                std::process::exit(1);
            }
        },
        None => c2dascript_transpile::LibcMode::default(),
    };
    // A mode the translator cannot honour must stop before any output is
    // written: a partially-honoured libc policy is indistinguishable from a
    // wrong one in the generated module.
    if matches!(
        libc,
        c2dascript_transpile::LibcMode::Ffi | c2dascript_transpile::LibcMode::All
    ) {
        eprintln!("libc mode '{libc}' is not implemented yet");
        std::process::exit(2);
    }
    let output_dir = take_option(&mut args, "--output-dir");
    if args.is_empty() {
        eprintln!("Expected compile_commands.json or --file <file.c>");
        std::process::exit(1);
    }
    let config = c2dascript_transpile::TranspilerConfig {
        dump_untyped_context: false,
        dump_typed_context: false,
        pretty_typed_context: false,
        verbose: false,
        debug_ast_exporter: false,
        filter: None,
        translate_valist: true,
        overwrite_existing: true,
        output_dir,
        log_level: log::LevelFilter::Warn,
        edition: c2rust_rust_tools::RustEdition::Edition2021,
        inline_functions: !no_inline,
        public_module,
        solid_context: !no_solid_context,
        unsafe_deref,
        das_options,
        libc,
        enabled_warnings,
        disabled_warnings,
    };

    let path = Path::new(&args[0]);

    if args[0] == "--file" {
        if args.len() < 2 {
            eprintln!("--file requires a .c file path");
            std::process::exit(1);
        }
        let c_file = Path::new(&args[1]);
        let extra: Vec<&str> = args[2..]
            .iter()
            .map(|s| s.as_str())
            .filter(|s| *s != "--")
            .collect();
        let (temp_dir, cc_db) =
            c2dascript_transpile::create_temp_compile_commands(&[c_file.to_owned()]);
        let status = run(config, &cc_db, &extra, strict);
        // The temporary compile database must be removed on failure too:
        // `process::exit` runs no destructors, so the exit happens only after
        // the explicit drop.
        drop(temp_dir);
        if status != 0 {
            std::process::exit(status);
        }
    } else if path.exists() && path.extension().map(|s| s == "json").unwrap_or(false) {
        let extra: Vec<&str> = args[1..]
            .iter()
            .map(|s| s.as_str())
            .filter(|s| *s != "--")
            .collect();
        let status = run(config, path, &extra, strict);
        if status != 0 {
            std::process::exit(status);
        }
    } else {
        eprintln!("Expected compile_commands.json or --file <file.c>");
        std::process::exit(1);
    }
}

fn take_flag(args: &mut Vec<String>, flag: &str) -> bool {
    if let Some(index) = args.iter().position(|arg| arg == flag) {
        args.remove(index);
        true
    } else {
        false
    }
}

/// Diagnostic names that clang spells as a `-W` warning of its own.  An
/// argument with one of these names belongs to the C compiler and is
/// forwarded untouched: swallowing `-Wall` here would change how the input is
/// parsed without saying so.  The translator's remaining diagnostics have
/// names no clang warning uses.
const CLANG_SHADOWED_DIAGNOSTICS: &[&str] = &["all", "comments"];

/// Removes the translator's own `-W<name>` / `-Wno-<name>` switches and
/// returns the enabled and the disabled set.  Every other `-W…` argument
/// stays in `args` and reaches clang.
fn take_warning_switches(args: &mut Vec<String>) -> (HashSet<Diagnostic>, HashSet<Diagnostic>) {
    let mut enabled = HashSet::new();
    let mut disabled = HashSet::new();
    args.retain(|arg| {
        let Some(name) = arg.strip_prefix("-W") else {
            return true;
        };
        let (name, enable) = match name.strip_prefix("no-") {
            Some(rest) => (rest, false),
            None => (name, true),
        };
        if CLANG_SHADOWED_DIAGNOSTICS.contains(&name) {
            return true;
        }
        match Diagnostic::from_str(name) {
            Ok(diagnostic) => {
                if enable {
                    enabled.insert(diagnostic);
                } else {
                    disabled.insert(diagnostic);
                }
                false
            }
            Err(_) => true,
        }
    });
    (enabled, disabled)
}

fn take_option(args: &mut Vec<String>, option: &str) -> Option<std::path::PathBuf> {
    take_value(args, option).map(Into::into)
}

/// `take_option` for an option whose value is a word rather than a path.
fn take_value(args: &mut Vec<String>, option: &str) -> Option<String> {
    let index = args.iter().position(|arg| arg == option)?;
    if index + 1 >= args.len() {
        eprintln!("{option} requires a value");
        std::process::exit(1);
    }
    args.remove(index);
    Some(args.remove(index))
}

/// Translates and returns the process exit status: 0, or 2 for a failed
/// translation.  It never exits itself, so the caller can release the
/// temporary compile database first.
fn run(config: c2dascript_transpile::TranspilerConfig, cc_db: &Path, extra: &[&str], strict: bool) -> i32 {
    // A failed translation is a failure in both modes. The two differ only in
    // whether the remaining translation units are still attempted; neither may
    // report success for a file that produced no output.
    if strict {
        if let Err(error) = c2dascript_transpile::transpile_checked(config, cc_db, extra) {
            eprintln!("translation failed: {error}");
            return 2;
        }
    } else if let Err(errors) = c2dascript_transpile::transpile(config, cc_db, extra) {
        for error in &errors {
            eprintln!("translation failed: {error}");
        }
        return 2;
    }
    0
}
