use std::path::Path;

#[test]
fn c2rust_to_c2dascript_map_covers_required_layers() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("workspace root");
    let map_path = root.join("docs/c2rust_to_c2dascript_map.md");
    let map = std::fs::read_to_string(&map_path)
        .unwrap_or_else(|err| panic!("failed to read {}: {err}", map_path.display()));

    for required in [
        "CFG reconstruction",
        "Decl lifting / temp placement",
        "Expression translation",
        "Implicit / explicit casts",
        "Pointer / null lowering",
        "C runtime / libc compatibility",
        "Anonymous / named type emission",
        "Renaming / namespaces",
        "Statement / expression normalization",
        "Intermediate Invariants",
        "Frozen Debt",
        "c2da_runtime_helpers",
        "Function pointer / callback ABI",
        "invoke(function?)",
    ] {
        assert!(
            map.contains(required),
            "architecture map does not mention required layer/invariant: {required}"
        );
    }

    for frozen_debt in [
        "normalize_generated_numeric_patterns",
        "replace_generated_function",
        "normalize_first_phase_shift_assignments",
    ] {
        assert!(
            map.contains(frozen_debt),
            "architecture map must explicitly track frozen generated-text debt: {frozen_debt}"
        );
    }
}

#[test]
fn callback_repro_does_not_emit_invalid_invoke_function_pointer() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("workspace root");
    let das_path = root.join("tests/manual/repro-architecture/repro_function_pointer_callback.das");
    let das = std::fs::read_to_string(&das_path)
        .unwrap_or_else(|err| panic!("failed to read {}: {err}", das_path.display()));

    assert!(
        !das.contains("invoke("),
        "C function pointer fallback must not emit daScript invoke(function?)"
    );
    assert!(
        das.contains("rc = int(0)"),
        "callback fallback should materialize the C int return default"
    );
}

#[test]
fn local_anonymous_enum_repro_does_not_emit_missing_named_type() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("workspace root");
    let das_path = root.join("tests/manual/repro-architecture/repro_local_anonymous_enum.das");
    let das = std::fs::read_to_string(&das_path)
        .unwrap_or_else(|err| panic!("failed to read {}: {err}", das_path.display()));

    assert!(
        !das.contains("Unnamed"),
        "anonymous enum variables must lower to their integral type, not to a missing synthetic named type"
    );
    assert!(
        das.contains("var e : uint") || das.contains("var e : int"),
        "local anonymous enum variable should be represented as an integral daScript type"
    );
}

#[test]
fn string_literal_address_repro_does_not_index_string_literal() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("workspace root");
    let das_path = root.join("tests/manual/repro-architecture/repro_string_literal_address.das");
    let das = std::fs::read_to_string(&das_path)
        .unwrap_or_else(|err| panic!("failed to read {}: {err}", das_path.display()));

    assert!(
        !das.contains("\"SoundHandler\"[0]"),
        "C &string_literal[0] must not lower to daScript string literal indexing"
    );
    assert!(
        das.contains("null"),
        "until static char storage is modeled, string literal address lowering should use a typed null sentinel"
    );
}

#[test]
fn pointer_null_cast_repro_lowers_zero_to_null() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("workspace root");
    let das_path = root.join("tests/manual/repro-architecture/repro_pointer_null_cast.das");
    let das = std::fs::read_to_string(&das_path)
        .unwrap_or_else(|err| panic!("failed to read {}: {err}", das_path.display()));

    for invalid in [
        "cast<Node?>(0)",
        "reinterpret<Node?>(0)",
        "reinterpret<Node?>(cast<Node?>(0))",
        "reinterpret<Node?>(null)",
    ] {
        assert!(
            !das.contains(invalid),
            "C integer zero pointer conversions must lower to null, not {invalid}"
        );
    }
    assert!(
        das.contains("return null") || das.contains("p = null"),
        "pointer zero conversions should materialize daScript null"
    );
}

#[test]
fn canonical_abi_owns_storage_literals_bool_and_pointer_raw_conversions() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR")).parent().expect("workspace root");
    let translator = root.join("c2dascript-transpile/src/translator");
    let abi = std::fs::read_to_string(translator.join("abi.rs")).expect("abi.rs");

    for api in [
        "fn raw_address_to_pointer",
        "fn pointer_to_raw_address",
        "fn null_pointer",
        "fn storage_byte_to_numeric",
        "fn integer_literal_for_type",
        "fn bool_to_integer",
    ] {
        assert!(abi.contains(api), "canonical ABI API missing: {api}");
    }

    // These are conversion owners. A local reinterpret here would bypass the
    // ABI contract rather than expressing ordinary C numeric type lowering.
    for file in ["functions.rs", "operators.rs", "pointers.rs", "value_lowering.rs"] {
        let source = std::fs::read_to_string(translator.join(file)).expect("translator source");
        assert!(
            !source.contains("CastKind::Reinterpret"),
            "{file} must use translator/abi.rs for pointer/raw reinterpret"
        );
    }

    for obsolete in [
        "lower_bool_numeric_cast",
        "lower_bool_numeric_cast_arg",
        "fn integer_literal_for_type",
        "fn strip_numeric_literal_casts",
    ] {
        let functions = std::fs::read_to_string(translator.join("functions.rs")).expect("functions.rs");
        assert!(
            !functions.contains(obsolete),
            "legacy ABI helper survived outside abi.rs: {obsolete}"
        );
    }
}

#[test]
fn real_world_driver_fixtures_are_present() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("workspace root");

    for fixture in [
        "tests/manual/real-world-h264bsd-mp4/compile_commands.json",
        "tests/manual/real-world-h264bsd-mp4/src/all.c",
        "tests/manual/real-world-plmpeg-stream/compile_commands.json",
        "tests/manual/real-world-plmpeg-stream/src/all.c",
    ] {
        let path = root.join(fixture);
        assert!(
            path.exists(),
            "missing real-world driver fixture: {}",
            path.display()
        );
    }
}

#[test]
fn variadic_macro_and_simd_boundaries_are_owned_before_printing() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR")).parent().expect("workspace root");
    let translator = root.join("c2dascript-transpile/src/translator");
    let variadic = std::fs::read_to_string(translator.join("variadic.rs")).expect("variadic owner");
    let macros = std::fs::read_to_string(translator.join("macros.rs")).expect("macro owner");
    let assembly = std::fs::read_to_string(translator.join("assembly.rs")).expect("asm owner");
    let simd = std::fs::read_to_string(translator.join("simd.rs")).expect("simd owner");
    let functions = std::fs::read_to_string(translator.join("functions.rs")).expect("call boundary");
    let printer = std::fs::read_dir(root.join("das_ast/src"))
        .expect("das_ast source directory")
        .filter_map(Result::ok)
        .filter_map(|entry| std::fs::read_to_string(entry.path()).ok())
        .collect::<String>();

    for api in ["fn convert_vaarg", "fn pack_variadic_call_tail", "fn pack_variadic_argument"] {
        assert!(variadic.contains(api), "variadic ABI owner missing {api}");
    }
    assert!(!functions.contains("fn pack_variadic_argument"));
    assert!(macros.contains("fn convert_gnu_statement_expression"));
    assert!(macros.contains("fn convert_predefined_expression"));
    assert!(assembly.contains("unsupported inline asm"));
    assert!(simd.contains("unsupported SIMD shuffle vector"));
    assert!(simd.contains("unsupported SIMD convert vector"));

    // daScript printing must be a serializer, never an ABI repair layer.
    for forbidden in ["va_arg", "va_start", "va_end", "C2daVaArg"] {
        assert!(!printer.contains(forbidden), "printer must not normalize variadic ABI: {forbidden}");
    }
}

#[test]
fn real_world_asm_simd_inventory_is_taken_from_typed_c_ast() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR")).parent().expect("workspace root");
    for fixture in [
        // Individual real translation units are the canonical AST corpus.
        // The `all.c` amalgamations intentionally include implementation
        // owners more than once and are not a valid Clang AST input.
        "tests/manual/real-world-plmpeg-stream/src/module.c",
        "tests/manual/real-world-plmpeg-stream/src/pl_mpeg.c",
        "tests/manual/real-world-plmpeg-stream/src/shim.c",
        "tests/manual/real-world-h264bsd-mp4/src/h264bsd.c",
        "tests/manual/real-world-h264bsd-mp4/src/minimp4.c",
        "tests/manual/real-world-h264bsd-mp4/src/module.c",
        "tests/manual/real-world-h264bsd-mp4/src/shim.c",
    ] {
        let source = root.join(fixture);
        let (_temp, commands) = c2dascript_transpile::create_temp_compile_commands(&[source]);
        let inventory = c2dascript_transpile::inventory_asm_simd(
            &c2dascript_transpile::TranspilerConfig::default(),
            &commands,
            &["-w"],
        )
        .unwrap_or_else(|error| panic!("AST inventory for {fixture} failed: {error}"));
        assert_eq!(inventory.inline_asm, 0, "unclassified inline asm in {fixture}");
        assert_eq!(inventory.shuffle_vector, 0, "unclassified shuffle vector in {fixture}");
        assert_eq!(inventory.convert_vector, 0, "unclassified convert vector in {fixture}");
        assert_eq!(inventory.vector_type, 0, "unclassified vector type in {fixture}");
    }
}
