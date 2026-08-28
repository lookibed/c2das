# Test-system architecture

`tests/syntax` is the canonical executable ABI suite.  Its C inputs and Rust render assertions
are paired; WSL `daslang` execution is the runtime proof.  Generated `.das` is registered fixture
output, never a scratch artifact.  Corpus runners remain separate from the fast suite.
