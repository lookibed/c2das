use std::env;
use std::path::Path;

fn main() {
    let args: Vec<String> = env::args().collect();
    eprintln!("c2dascript-transpile v{}", env!("CARGO_PKG_VERSION"));

    if args.len() < 2 {
        eprintln!("Usage: c2dascript-transpile <compile_commands.json> [extra_clang_args...]");
        eprintln!("   or: c2dascript-transpile --file <file.c> [extra_clang_args...]");
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
        output_dir: None,
        log_level: log::LevelFilter::Warn,
        edition: c2rust_rust_tools::RustEdition::Edition2021,
    };

    let path = Path::new(&args[1]);

    if args[1] == "--file" {
        if args.len() < 3 {
            eprintln!("--file requires a .c file path");
            std::process::exit(1);
        }
        let c_file = Path::new(&args[2]);
        let extra: Vec<&str> = args[3..]
            .iter()
            .map(|s| s.as_str())
            .filter(|s| *s != "--")
            .collect();
        let (temp_dir, cc_db) =
            c2dascript_transpile::create_temp_compile_commands(&[c_file.to_owned()]);
        c2dascript_transpile::transpile(config, &cc_db, &extra);
        drop(temp_dir);
    } else if path.exists() && path.extension().map(|s| s == "json").unwrap_or(false) {
        let extra: Vec<&str> = args[2..]
            .iter()
            .map(|s| s.as_str())
            .filter(|s| *s != "--")
            .collect();
        c2dascript_transpile::transpile(config, path, &extra);
    } else {
        eprintln!("Expected compile_commands.json or --file <file.c>");
        std::process::exit(1);
    }
}
