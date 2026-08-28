# Manual and real-world corpus architecture

Manual corpus directories preserve upstream source, provenance, local graph wrappers, reference
oracles, and recorded blockers separately.  Upstream sources are versioned ordinary files: never
embedded repositories.  A corpus is green only after its documented graph, transpilation, and
real WSL daScript execution all succeed.
