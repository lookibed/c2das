# WSL and CI reproduction

Canonical local runtime evidence is a Linux Git checkout of this repository plus a locally
built `daslang` (see README prerequisites), checked with `bash scripts/c2das_preflight.sh`.
That local preflight is the authoritative gate; GitHub Actions only mirrors part of it:

- `.github/workflows/ci.yml` (ubuntu-22.04, Clang 18): rustfmt, release build, workspace tests
  without the inherited `c2rust-transpile` and `das_ast` suites, the test-registry check, the
  `c2dascript-transpile` contract and snapshot tests, and a no-untracked-files check.  No daScript.
- `.github/workflows/c2das-runtime.yml` (ubuntu-24.04): builds an interpreter-only daScript
  (`DAS_LLVM_DISABLED=ON`, GUI/audio/network modules off) at the pinned `lookibed/daScript`
  revision, caches it by revision and configure flags, and runs `c2das_preflight.sh --fast`.
  JIT, AOT and `-exe` are not exercised.

To reproduce the runtime workflow locally, build daScript with the workflow's
`DASCRIPT_CMAKE_FLAGS` and run the preflight with `DASROOT` pointing at that checkout.
Windows runtime output is informational only.
