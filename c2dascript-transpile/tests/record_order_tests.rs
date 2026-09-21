//! The order records are declared in.
//!
//! daslang takes module-level `struct` declarations in any order.  `daslang
//! -aot` prints the same module as C++, where a member of a struct type needs
//! that struct complete, and its own sorter gives up when the embedded record
//! points back at its container (lookibed/daScript#2).  The translator
//! therefore emits records in an order where every by-value member's type is
//! already declared, which is what this asserts on the rendered module — the
//! text the AOT back end reads.

use std::collections::HashMap;
use std::path::Path;

fn transpile(name: &str) -> String {
    let c_path = Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("workspace root")
        .join(format!("tests/syntax/{name}.c"));
    assert!(c_path.exists(), "C file not found: {c_path:?}");
    let (_td, cc_path) = c2dascript_transpile::create_temp_compile_commands(&[c_path]);
    let temp = tempfile::tempdir().expect("temporary render output directory");
    let config = c2dascript_transpile::TranspilerConfig {
        output_dir: Some(temp.path().join("das")),
        ..Default::default()
    };
    let outputs = c2dascript_transpile::transpile_checked(config, &cc_path, &["-w"])
        .unwrap_or_else(|error| panic!("{name}: strict translation failed: {error}"));
    std::fs::read_to_string(&outputs[0]).expect("fresh temporary daScript output")
}

/// `struct Name {` … `}` blocks, in the order the module declares them, each
/// with its fields' rendered types.
fn records(module: &str) -> Vec<(String, Vec<String>)> {
    let mut out: Vec<(String, Vec<String>)> = Vec::new();
    let mut open: Option<(String, Vec<String>)> = None;
    for line in module.lines() {
        if let Some((name, fields)) = open.as_mut() {
            if line == "}" {
                out.push((std::mem::take(name), std::mem::take(fields)));
                open = None;
                continue;
            }
            if let Some((_, field_type)) = line.trim().split_once(" : ") {
                fields.push(field_type.trim().to_string());
            }
            continue;
        }
        if let Some(rest) = line.strip_prefix("struct ") {
            if let Some(name) = rest.strip_suffix(" {") {
                open = Some((name.to_string(), Vec::new()));
            }
        }
    }
    assert!(open.is_none(), "unterminated struct declaration");
    out
}

/// `typedef Name = Type` lines, which a field may name instead of a record.
fn aliases(module: &str) -> HashMap<String, String> {
    module
        .lines()
        .filter_map(|line| line.strip_prefix("typedef "))
        .filter_map(|rest| rest.split_once(" = "))
        .map(|(name, body)| (name.trim().to_string(), body.trim().to_string()))
        .collect()
}

/// The record a field holds *by value*, if any.
///
/// A `?` anywhere in the rendered type is a pointer, and a pointer member
/// never needs its pointee declared first — that is what lets two records
/// reference each other at all.  An array of a record does constrain the
/// order, so the `[N]` suffix is stripped rather than rejected.
fn embedded_record(
    field_type: &str,
    aliases: &HashMap<String, String>,
    known: &[String],
    depth: usize,
) -> Option<String> {
    if depth > 16 {
        return None;
    }
    let mut spelling = field_type.trim();
    if spelling.contains('?') || spelling.starts_with("function<") {
        return None;
    }
    if let Some(head) = spelling.split('[').next() {
        spelling = head.trim();
    }
    let spelling = spelling.trim_end_matches(" const").trim();
    if known.iter().any(|name| name == spelling) {
        return Some(spelling.to_string());
    }
    let body = aliases.get(spelling)?;
    embedded_record(body, aliases, known, depth + 1)
}

#[test]
fn records_precede_the_records_that_embed_them() {
    let module = transpile("p84_struct_definition_order");
    let records = records(&module);
    let aliases = aliases(&module);
    let names: Vec<String> = records.iter().map(|(name, _)| name.clone()).collect();
    let position: HashMap<&str, usize> = names
        .iter()
        .enumerate()
        .map(|(i, name)| (name.as_str(), i))
        .collect();

    // The case is only evidence if the module really has the shape: a record
    // embedded by value that points back at its container, and a three-level
    // chain of by-value members.
    let mut by_value_edges = 0usize;
    for (container, fields) in &records {
        let container_at = position[container.as_str()];
        for field_type in fields {
            let Some(embedded) = embedded_record(field_type, &aliases, &names, 0) else {
                continue;
            };
            by_value_edges += 1;
            let embedded_at = position[embedded.as_str()];
            assert!(
                embedded_at < container_at,
                "struct {embedded} is declared at {embedded_at}, after struct {container} \
                 at {container_at}, which embeds it by value as `{field_type}`;\n{module}"
            );
        }
    }
    assert!(
        by_value_edges >= 4,
        "the fixture no longer embeds records by value ({by_value_edges} edges)"
    );
    for pair in [("Inner", "Outer"), ("Leaf", "Middle"), ("Middle", "Trunk")] {
        assert!(
            position[pair.0] < position[pair.1],
            "{} must be declared before {}", pair.0, pair.1
        );
    }
}
