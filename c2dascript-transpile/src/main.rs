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
        eprintln!("   or: c2dascript-transpile [--strict] [--inline=on|off|auto] [--no-inline] [--public-module] [--no-solid-context] [--unsafe-deref] [--das-option <text>]... [--libc nostd|std|ffi|all|eden] [--target master|eden] [--float-compare ieee|nan-safe] [--dialect master|eden-0.6.4] [--no-unsafe[=fail|report|off]] [--memory-model raw|linear] [--fnptr-model value|table] [--varargs-model array|heap] [--heap-reserve <bytes>] [--entry main|eden] [--records natural|typed] [--runtime-module <name>] [--module-layout unity|source] [-W[no-]<diagnostic>]... [--output-dir <dir>] --file <file.c> [extra_clang_args...]");
        std::process::exit(1);
    }

    let strict = take_flag(&mut args, "--strict");
    // Which tiny `static` helpers are substituted at their call sites
    // (TranspilerConfig::inline).  `--no-inline` predates the knob and stays
    // an alias of `--inline=off`; given together, the two must agree.
    let no_inline = take_flag(&mut args, "--no-inline");
    let inline = match take_prefixed(&mut args, "--inline=") {
        Some(text) => match c2dascript_transpile::InlineMode::parse(&text) {
            Some(mode) => mode,
            None => {
                let modes: Vec<&str> = c2dascript_transpile::InlineMode::ALL
                    .iter()
                    .map(|mode| mode.as_str())
                    .collect();
                eprintln!(
                    "unknown inline mode '{text}'; expected one of {}",
                    modes.join(", ")
                );
                std::process::exit(1);
            }
        },
        None if no_inline => c2dascript_transpile::InlineMode::Off,
        None => c2dascript_transpile::InlineMode::default(),
    };
    if no_inline && inline != c2dascript_transpile::InlineMode::Off {
        eprintln!("--no-inline contradicts --inline={inline}");
        std::process::exit(1);
    }
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
    // Target switches (`target.rs`, `docs/eden-flags.md`).  `--target eden`
    // sets the whole preset; an individual flag given with it overrides its
    // part of the preset, whatever the order on the command line.
    let preset = take_value(&mut args, "--target");
    let mut target = match preset.as_deref() {
        None | Some("master") => c2dascript_transpile::target::TargetOptions::default(),
        Some("eden") => c2dascript_transpile::target::TargetOptions::eden(),
        Some(other) => {
            eprintln!("unknown target '{other}'; expected one of master, eden");
            std::process::exit(1);
        }
    };
    let preset_libc =
        (preset.as_deref() == Some("eden")).then_some(c2dascript_transpile::LibcMode::Eden);
    use c2dascript_transpile::target as tg;
    if let Some(v) = take_switch(
        &mut args,
        "--memory-model",
        tg::MemoryModel::parse,
        &tg::MemoryModel::ALL.map(tg::MemoryModel::as_str),
    ) {
        target.memory_model = v;
    }
    if let Some(v) = take_switch(
        &mut args,
        "--fnptr-model",
        tg::FnPtrModel::parse,
        &tg::FnPtrModel::ALL.map(tg::FnPtrModel::as_str),
    ) {
        target.fnptr_model = v;
    }
    if let Some(v) = take_switch(
        &mut args,
        "--float-compare",
        tg::FloatCompare::parse,
        &tg::FloatCompare::ALL.map(tg::FloatCompare::as_str),
    ) {
        target.float_compare = v;
    }
    if let Some(v) = take_switch(
        &mut args,
        "--varargs-model",
        tg::VarargsModel::parse,
        &tg::VarargsModel::ALL.map(tg::VarargsModel::as_str),
    ) {
        target.varargs_model = v;
    }
    if let Some(v) = take_switch(
        &mut args,
        "--dialect",
        tg::Dialect::parse,
        &tg::Dialect::ALL.map(tg::Dialect::as_str),
    ) {
        target.dialect = v;
    }
    if let Some(v) = take_switch(
        &mut args,
        "--entry",
        tg::EntryModel::parse,
        &tg::EntryModel::ALL.map(tg::EntryModel::as_str),
    ) {
        target.entry = v;
    }
    if let Some(v) = take_switch(
        &mut args,
        "--records",
        tg::RecordsModel::parse,
        &tg::RecordsModel::ALL.map(tg::RecordsModel::as_str),
    ) {
        target.records = v;
    }
    if let Some(text) = take_value(&mut args, "--heap-reserve") {
        match text.parse::<u64>() {
            Ok(bytes) if bytes > 0 => target.heap_reserve = Some(bytes),
            _ => {
                eprintln!("--heap-reserve '{text}' is not a positive byte count");
                std::process::exit(1);
            }
        }
    }
    if take_flag(&mut args, "--no-unsafe") {
        target.no_unsafe = tg::NoUnsafe::Fail;
    }
    if let Some(mode) = take_prefixed(&mut args, "--no-unsafe=") {
        target.no_unsafe = match mode.as_str() {
            "fail" => tg::NoUnsafe::Fail,
            "report" => tg::NoUnsafe::Report,
            "off" => tg::NoUnsafe::Off,
            _ => {
                eprintln!("unknown --no-unsafe mode '{mode}'; expected one of fail, report, off");
                std::process::exit(1);
            }
        };
    }
    // A target switch the translator cannot honour yet stops before any
    // output is written, by name.
    let missing = target.unimplemented();
    if !missing.is_empty() {
        for flag in &missing {
            eprintln!("{flag} is not implemented yet");
        }
        std::process::exit(2);
    }
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
        None => preset_libc.unwrap_or_default(),
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
    // The program-wide runtime prelude written once as `<output dir>/<name>.das`
    // and `require`d by every translated unit (TranspilerConfig::runtime_module).
    // The name is a daslang module name, so it has to be an identifier.
    let runtime_module = take_value(&mut args, "--runtime-module");
    if let Some(name) = &runtime_module {
        let mut chars = name.chars();
        let is_identifier = matches!(chars.next(), Some(c) if c.is_ascii_alphabetic() || c == '_')
            && chars.all(|c| c.is_ascii_alphanumeric() || c == '_');
        if !is_identifier {
            eprintln!("--runtime-module '{name}' is not a daslang module name (identifier)");
            std::process::exit(1);
        }
    }
    // How the program is laid out over daslang modules
    // (TranspilerConfig::module_layout).  `source` links the units of a
    // compile_commands.json, so a single `--file` is refused below.
    let module_layout = match take_value(&mut args, "--module-layout") {
        Some(text) => match c2dascript_transpile::ModuleLayout::parse(&text) {
            Some(layout) => layout,
            None => {
                let layouts: Vec<&str> = c2dascript_transpile::ModuleLayout::ALL
                    .iter()
                    .map(|layout| layout.as_str())
                    .collect();
                eprintln!(
                    "unknown module layout '{text}'; expected one of {}",
                    layouts.join(", ")
                );
                std::process::exit(1);
            }
        },
        None => c2dascript_transpile::ModuleLayout::default(),
    };
    let output_dir = take_option(&mut args, "--output-dir");
    if args.is_empty() {
        eprintln!("Expected compile_commands.json or --file <file.c>");
        std::process::exit(1);
    }
    if module_layout == c2dascript_transpile::ModuleLayout::Source && args[0] == "--file" {
        eprintln!("--module-layout source links a program: pass its compile_commands.json");
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
        inline,
        public_module,
        solid_context: !no_solid_context,
        unsafe_deref,
        das_options,
        libc,
        runtime_module,
        module_layout,
        enabled_warnings,
        disabled_warnings,
        target,
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

/// Removes the last `<prefix><value>` argument (e.g. `--inline=off`) and
/// returns its value; every earlier one is removed too, so the last wins.
fn take_prefixed(args: &mut Vec<String>, prefix: &str) -> Option<String> {
    let mut value = None;
    while let Some(index) = args.iter().position(|arg| arg.starts_with(prefix)) {
        value = Some(args.remove(index)[prefix.len()..].to_owned());
    }
    value
}

/// `take_value` for a target switch: parses the word with `parse`, or exits
/// naming the accepted spellings.
fn take_switch<T>(
    args: &mut Vec<String>,
    option: &str,
    parse: fn(&str) -> Option<T>,
    spellings: &[&str],
) -> Option<T> {
    let text = take_value(args, option)?;
    match parse(&text) {
        Some(value) => Some(value),
        None => {
            eprintln!(
                "unknown {option} value '{text}'; expected one of {}",
                spellings.join(", ")
            );
            std::process::exit(1);
        }
    }
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
fn run(
    config: c2dascript_transpile::TranspilerConfig,
    cc_db: &Path,
    extra: &[&str],
    strict: bool,
) -> i32 {
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
