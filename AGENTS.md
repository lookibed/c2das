# Workspace hygiene

- Keep source, generated `.das`, logs, and temporary probes separate.  Never use a deploy,
  corpus, or source directory as scratch space.
- Generated `.das` is evidence, not source: it may be committed only when registered as an
  intentional fixture artifact.  Do not overwrite a checked-in oracle while diagnosing.
- Windows `D:\Backups\с2daslang\c2dascript` is the editing authority.  WSL is a named,
  disposable validation mirror; validate its source hash before treating a result as evidence.
- Before changing translator semantics, read `CODEX.md`, the nearest `ARCHITECTURE.md`, the
  nearest `REVIEW.md`, and the matching skill in `skills/`.
- Unsupported C semantics fail closed with a source-located diagnostic.  No generated-text
  replacement, fixture-specific body rewrite, or silent daScript-value fallback is permitted.
