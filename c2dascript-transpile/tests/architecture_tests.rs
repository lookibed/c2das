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
