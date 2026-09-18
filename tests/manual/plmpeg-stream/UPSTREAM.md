# Upstream provenance

This directory vendors fixture input as ordinary source files.  It intentionally contains no
nested Git metadata.

| Component | Upstream | Revision | License retained at |
|---|---|---|---|
| pl_mpeg | https://github.com/phoboslab/pl_mpeg | `c871f2be022ece7ef4f64230b4fb8e1fb9eb6023` | `upstream/pl_mpeg.h` (SPDX header, MIT) and `upstream/README.md` |

The revision was established after the fact: the vendored `upstream/pl_mpeg.h`
(sha1 `1aeebc2ff8c617d01ecfa8305df170e614660531`) is byte-identical to `pl_mpeg.h` at that
commit ("Fix corrupt slice check; close #64", 2025-12-30) and to no earlier one; the
`upstream/` directory itself was added in c2das commit `48f0a23c5` without a record.

Import procedure: clone the upstream at the recorded revision into a temporary directory,
copy `pl_mpeg.h` and `README.md` into `upstream/` while excluding `.git`, then record the
new revision here.  Local graph wrappers and generated outputs belong outside `upstream/`.
