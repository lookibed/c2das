# Preflight skill

Run `cd /root/c2das && bash scripts/c2das_preflight.sh` for canonical validation.  The optional
PowerShell wrapper only opens that same command in WSL; it neither synchronizes nor validates a
Windows checkout.  Use `--full` for workspace tests and `--extended` for corpus inventory/green
corpus execution.
