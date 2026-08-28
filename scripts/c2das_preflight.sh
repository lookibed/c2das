#!/usr/bin/env bash
# Canonical Linux/WSL preflight. Windows invokes it only after hash-verified mirroring.
set -euo pipefail

# `wsl.exe env ...` starts a non-login shell.  Make the canonical runner independent of
# interactive shell configuration while preserving ordinary CI PATHs.
if ! command -v cargo >/dev/null 2>&1 && [[ -f "$HOME/.cargo/env" ]]; then
    # shellcheck disable=SC1090
    source "$HOME/.cargo/env"
fi
command -v cargo >/dev/null 2>&1 || { echo 'cargo is unavailable in this WSL runtime' >&2; exit 127; }

mode=fast
while (($#)); do
    case "$1" in
        --full) mode=full ;;
        --extended) mode=extended ;;
        --fast) mode=fast ;;
        *) echo "usage: $0 [--fast|--full|--extended]" >&2; exit 64 ;;
    esac
    shift
done

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -n "${C2DAS_MIRROR_NAME:-}" ]]; then
    default_target="/root/.cache/c2das/${C2DAS_MIRROR_NAME}"
else
    default_target="$root/.c2das-target"
fi
export CARGO_TARGET_DIR="${C2DAS_CARGO_TARGET_DIR:-$default_target}"

gate() { local name="$1"; shift; printf '\n== c2das gate: %s ==\n' "$name"; "$@"; }

tree_hash() {
    (
        cd "$1"
        find . -type f ! -path './.git/*' ! -path './target/*' ! -path './.c2das-target/*' ! -name '.c2das-sync-manifest' -print0 \
          | LC_ALL=C sort -z | xargs -0 sha256sum | sha256sum | awk '{print $1}'
    )
}

check_sync() {
    if [[ -n "${C2DAS_SOURCE_HASH:-}" ]]; then
        [[ -n "${C2DAS_MIRROR_NAME:-}" ]] || { echo 'missing named WSL mirror' >&2; return 1; }
        local actual; actual="$(tree_hash "$root")"
        [[ "$actual" == "$C2DAS_SOURCE_HASH" ]] || { echo "stale WSL mirror: expected $C2DAS_SOURCE_HASH, got $actual" >&2; return 1; }
        printf 'verified mirror %s at source hash %s\n' "$C2DAS_MIRROR_NAME" "$actual"
        return 0
    fi
    git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
        echo 'non-git WSL tree: invoke scripts/c2das_preflight.ps1 from Windows' >&2; return 1;
    }
    printf 'native git checkout %s\n' "$(git -C "$root" rev-parse --short HEAD)"
}

check_untracked() {
    if [[ -n "${C2DAS_SOURCE_HASH:-}" ]]; then
        [[ "${C2DAS_UNTRACKED_CLEAN:-}" == 1 ]] || {
            echo 'Windows synchronizer did not prove source artifact cleanliness' >&2; return 1;
        }
        return 0
    fi
    local files; files="$(git -C "$root" ls-files --others --exclude-standard)"
    [[ -z "$files" ]] || { echo "untracked artifacts are forbidden:" >&2; printf '%s\n' "$files" >&2; return 1; }
    if git -C "$root" ls-files --others --exclude-standard '*.das' | grep -q .; then
        echo 'unregistered generated .das artifact found' >&2; return 1
    fi
}

check_architecture() {
    cargo test -p c2dascript-transpile --test architecture_tests
    cargo test -p c2dascript-transpile --test governance_tests
}
check_changed_fixture_assertions() { cargo test -p c2dascript-transpile --test ptr_tests; }
check_runtime_owners() {
    ! rg -n 'normalize_generated_numeric_patterns|normalize_first_phase_shift_assignments|replace_generated_function' "$root/c2dascript-transpile/src/translator"
    ! rg -n 'let mut [A-Za-z_][A-Za-z0-9_]* = .*\.to_string\(\)' "$root/c2dascript-transpile/src/translator"
}
check_corpus_inventory() {
    test -f "$root/docs/followups/real_world_status.md"
    test -f "$root/tests/manual/real-world-h264bsd-mp4/UPSTREAM.md"
    if find "$root/tests/manual/real-world-h264bsd-mp4/upstream" -type d -name .git -print -quit | grep -q .; then
        echo 'nested Git metadata remains in versioned H264 fixture input' >&2; return 1
    fi
    grep -Fq '| PLMPEG stream |' "$root/docs/followups/real_world_status.md"
}

gate sync check_sync
gate untracked-artifacts check_untracked
gate rustfmt cargo fmt --check
gate translator-architecture check_architecture
gate changed-fixture-assertions check_changed_fixture_assertions
gate runtime-owner-invariants check_runtime_owners
gate abi-daslang bash "$root/tests/syntax/check_abi_das.sh"
gate plmpeg-c-graph bash "$root/tests/manual/real-world-plmpeg-stream/check_c_graph.sh"

if [[ "$mode" == full || "$mode" == extended ]]; then gate workspace-tests cargo test --workspace; fi
if [[ "$mode" == extended ]]; then
    gate real-world-ledger check_corpus_inventory
    if grep -Fq '| PLMPEG stream | canonical repository graph | known red |' "$root/docs/followups/real_world_status.md"; then
        echo 'PLMPEG is explicitly known-red; refusing to label its runner a success.' >&2; exit 2
    fi
    gate plmpeg-end-to-end bash "$root/tests/manual/real-world-plmpeg-stream/run_end_to_end.sh"
fi
printf '\n== c2das preflight %s: PASS ==\n' "$mode"
