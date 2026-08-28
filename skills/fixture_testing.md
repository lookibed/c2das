# Fixture testing

Every reachable semantic branch has a minimal C fixture, Rust AST/render assertion, and WSL
`daslang` execution when runnable.  Register fixtures in the canonical runner.  Negative fixture
success means a precise diagnostic, not an implementation claim.  Never alter generated output to
create the expected result.
