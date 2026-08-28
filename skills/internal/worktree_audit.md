# Worktree audit

Create a dedicated Windows git worktree for mutation-based audit and a uniquely named WSL mirror
from that worktree.  Do not mutate the implementation worktree.  Record worktree path, mirror
name, narrow command, restoration command, and clean `git diff` proof.
