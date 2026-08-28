# Upstream provenance

This directory vendors fixture input as ordinary source files.  It intentionally contains no
nested Git metadata.

| Component | Upstream | Revision | License retained at |
|---|---|---|---|
| h264bsd | https://github.com/oneam/h264bsd | `42bcb5d753ad86d84903354bf3c68423c28adb7b` | `upstream/h264bsd/LICENSE.md` |
| minimp4 | https://github.com/lieff/minimp4 | `4575afb4f69ace25a1a048e25cc86bf8c8d14f2b` | `upstream/minimp4/LICENSE` |

Import procedure: clone each upstream at the recorded revision into a temporary directory, copy
the working tree into `upstream/<component>/` while excluding `.git`, retain its license, then
record the new revision here.  Local graph wrappers and generated outputs belong outside
`upstream/`.
