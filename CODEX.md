# c2das agent contract

`c2das` is an experimental C-to-daScript transpiler whose architecture follows c2rust:

`Clang AST -> CBOR -> C AST -> translator -> daScript AST -> printer -> .das`.

## Mandatory reading and routing

Read root `AGENTS.md`, `ARCHITECTURE_COMMON.md`, `REVIEW_COMMON.md`, `LAWS.md`, the nearest
folder contracts, and the relevant `skills/*.md` before changing a semantic owner.  Codex sessions
use `AGENTS.md` as their automatic repository instruction entrypoint.  `docs/codex/agents/` is a
versioned topology and report-contract library for agents launched through Codex collaboration; it
is not a hidden hook or automatic executor.

Use these owners, rather than fixing symptoms at rendering time:

- C layout facts: `translator/layout.rs`.
- raw-address/pointer/null ABI crossings: `translator/abi.rs`.
- libc/raw-memory runtime declarations and calls: `translator/runtime.rs`.
- pointer-backed C objects and fields: `translator/object_memory.rs`.
- C expressions, values and control flow: their named translator owners and `WithStmts`.

## Runtime facts

Windows is the source workspace.  The canonical execution target is WSL/Linux `daslang`; the
PowerShell preflight synchronizes to a named WSL mirror and proves the mirror hash.  Windows
`daslang.exe` is informational until it receives its own stable default-runtime gate.

Known fail-silent hazards are forbidden: post-render repairs, manual C layout outside `layout`,
raw-pointer conversions outside `abi`, duplicate runtime-name tables, identity union lowering,
and aggregate-value fallbacks.  C rvalue, C place, and raw address are distinct contracts.

## Instruction updates

When a semantic discovery changes how contributors must work, update in the same change arc the
owning architecture contract plus a fixture, source invariant, skill, or follow-up ledger.  Put
history in `LAWS.md` or `docs/followups/`; do not leave a stale active rule behind.
