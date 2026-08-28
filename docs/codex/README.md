# Codex collaboration topology

These files are versioned role contracts for Codex collaboration sessions.  They describe how to
run the repository's review and audit roles through Codex's actual multi-agent facilities.  They
are not configuration hooks and are not automatically executed by the Codex app.

The enforceable entrypoint is root `AGENTS.md`; runnable enforcement is the preflight, Rust
governance tests, and CI.  A session selecting a role must read its contract before starting it.
