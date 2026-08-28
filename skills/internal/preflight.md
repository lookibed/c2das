# Preflight skill

Run `scripts/c2das_preflight.ps1` from Windows for canonical validation.  It synchronizes the
working revision and diff to a named WSL mirror before invoking `scripts/c2das_preflight.sh`.
Use `--full` for workspace tests and `--extended` for corpus inventory/green corpus execution.
Never cite a direct stale WSL checkout as a canonical result.
