use std::path::{Path, PathBuf};

fn workspace_root() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("workspace root")
        .to_path_buf()
}

#[test]
fn development_system_contracts_are_present_and_cited() {
    let root = workspace_root();
    for relative in [
        "AGENTS.md",
        "CODEX.md",
        "ARCHITECTURE_COMMON.md",
        "REVIEW_COMMON.md",
        "LAWS.md",
        "c2dascript-transpile/src/translator/ARCHITECTURE.md",
        "c2dascript-transpile/src/translator/REVIEW.md",
        "c2dascript-transpile/tests/ARCHITECTURE.md",
        "c2dascript-transpile/tests/REVIEW.md",
        "tests/ARCHITECTURE.md",
        "tests/REVIEW.md",
        "tests/manual/ARCHITECTURE.md",
        "tests/manual/REVIEW.md",
        "skills/internal/review_round.md",
        "scripts/c2das_preflight.ps1",
        "scripts/c2das_preflight.sh",
        "docs/followups/real_world_status.md",
        "docs/preflight-baseline.md",
    ] {
        assert!(
            root.join(relative).is_file(),
            "missing governing contract: {relative}"
        );
    }

    let translator_architecture =
        std::fs::read_to_string(root.join("c2dascript-transpile/src/translator/ARCHITECTURE.md"))
            .expect("translator architecture");
    for owner in [
        "`abi.rs`",
        "`layout.rs`",
        "`runtime.rs`",
        "`object_memory.rs`",
        "printer",
        "source-located `TranslationError`",
    ] {
        assert!(
            translator_architecture.contains(owner),
            "missing translator owner citation: {owner}"
        );
    }
}

#[test]
fn all_codex_review_roles_and_c2das_skills_are_versioned() {
    let root = workspace_root();
    for role in [
        "targeted-reviewer",
        "tdd-auditor",
        "review-md-auditor",
        "style-hygiene-auditor",
        "dragon",
        "placement-auditor",
        "harvester",
        "flashlight",
        "analysis-bot",
        "archivist",
        "janitor",
        "spartan",
    ] {
        assert!(
            root.join("docs/codex/agents")
                .join(format!("{role}.md"))
                .is_file(),
            "missing agent role: {role}"
        );
    }
    for skill in [
        "internal/make_pr.md",
        "internal/review_round.md",
        "internal/preflight.md",
        "internal/tdd_audit.md",
        "internal/worktree_audit.md",
        "internal/c2rust_parity.md",
        "internal/wsl_ci_repro.md",
        "c_pipeline.md",
        "translator_owners.md",
        "raw_memory_abi.md",
        "clang_layout.md",
        "object_memory.md",
        "fixture_testing.md",
        "real_world_corpora.md",
    ] {
        assert!(
            root.join("skills").join(skill).is_file(),
            "missing skill: {skill}"
        );
    }
}

#[test]
fn review_round_is_proof_first_and_tdd_audit_requires_restoration() {
    let root = workspace_root();
    let review_round = std::fs::read_to_string(root.join("skills/internal/review_round.md"))
        .expect("review round");
    for required in [
        "grounding",
        "3-6",
        "falsification",
        "fresh cold review round",
        "flashlight",
    ] {
        assert!(
            review_round.contains(required),
            "review round missing proof phase: {required}"
        );
    }
    let tdd = std::fs::read_to_string(root.join("docs/codex/agents/tdd-auditor.md"))
        .expect("tdd auditor");
    for required in [
        "dedicated Windows git worktree",
        "named WSL mirror",
        "restore",
        "COVERED",
    ] {
        assert!(
            tdd.contains(required),
            "TDD audit contract missing: {required}"
        );
    }
}

#[test]
fn preflight_and_corpus_ledgers_are_fail_closed() {
    let root = workspace_root();
    let preflight =
        std::fs::read_to_string(root.join("scripts/c2das_preflight.sh")).expect("preflight");
    for required in [
        "stale WSL mirror",
        "untracked artifacts are forbidden",
        "abi-daslang",
        "plmpeg-c-graph",
        "refusing to label its runner a success",
    ] {
        assert!(
            preflight.contains(required),
            "preflight missing fail-closed gate: {required}"
        );
    }
    let upstream =
        std::fs::read_to_string(root.join("tests/manual/real-world-h264bsd-mp4/UPSTREAM.md"))
            .expect("H264 provenance");
    assert!(upstream.contains("contains no\nnested Git metadata"));
    assert!(upstream.contains("42bcb5d753ad86d84903354bf3c68423c28adb7b"));
    assert!(upstream.contains("4575afb4f69ace25a1a048e25cc86bf8c8d14f2b"));

    let baseline = std::fs::read_to_string(root.join("docs/preflight-baseline.md"))
        .expect("preflight baseline");
    for required in [
        "not an exemption",
        "ABI daScript suite",
        "missing generated fixture",
    ] {
        assert!(
            baseline.contains(required),
            "baseline omits measured gate: {required}"
        );
    }
}
