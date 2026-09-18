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

## Fixtures

| File | Bytes | Content | Origin |
|---|---|---|---|
| `fixtures/sample.m1v` | 22929 | 96×64, 11 frames | imported with the directory in `48f0a23c5`; also embedded as `src/sample_mpg_data.h` for the entries that take no file |
| `fixtures/testsrc2_320x240.m1v` | 266389 | 320×240, 60 encoded frames (I/P only, GOP 12), 59 output by the decoder | synthesized, see below |

`testsrc2_320x240.m1v` (sha256
`44770b31a508736bbab933761ec8e09225b85f8da5f7ea14410c6840b4afe2ad`) is a deterministic,
license-free stream generated on 2026-09-18 with
`ffmpeg version 4.4.2-0ubuntu0.22.04.1` from its built-in `testsrc2` pattern:

```sh
ffmpeg -threads 1 -f lavfi -i "testsrc2=size=320x240:rate=25:duration=2.4" \
    -c:v mpeg1video -bf 0 -g 12 -q:v 5 -threads 1 -f mpeg1video testsrc2_320x240.m1v
```

Two runs of that command produce byte-identical output.  B-frames are left out on
purpose: the harness decodes with `plm_video_set_no_delay(video, 1)`, under which pl_mpeg
hands back the reference picture for each B-frame, so a B-frame stream pins two identical
hashes per GOP triple and checks less, not more.  Every one of the 59 decoded frames of
this stream hashes differently.  It is read at run time by the `src/plmpeg_file_*` entries
(last command-line argument), never embedded.
