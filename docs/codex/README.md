# Codex collaboration topology

These files are versioned role contracts for Codex collaboration sessions.  They describe how to
run the repository's review and audit roles through Codex's actual multi-agent facilities.  They
are not configuration hooks and are not automatically executed by the Codex app.

The enforceable entrypoint is root `AGENTS.md`; runnable enforcement is the local preflight
(`scripts/c2das_preflight.sh`, the authoritative gate) and the Rust governance tests.  GitHub
Actions mirrors part of the preflight (see README, "Continuous integration") and is not the
gate.  A session selecting a role must read its contract before starting it.
