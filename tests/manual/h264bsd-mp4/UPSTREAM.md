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

## Fixtures

| File | Bytes | Content | Origin |
|---|---|---|---|
| `fixtures/sample.mp4` | 8044 | 96×64, 12 pictures, constrained baseline | imported with the directory in `48f0a23c5`; also embedded as `src/sample_mp4_data.h` for the entries that take no file |
| `fixtures/test_640x360.mp4` | 232093 | 640×360, 73 pictures, constrained baseline | h264bsd's own test vector `upstream/h264bsd/test/test_640x360.h264` (sha256 `efded563db87d062ff371b081649205302f89d8c74c5caaeff1a04ed508cd8b6`, same revision and license as the decoder), muxed into MP4 without re-encoding, see below |

`test_640x360.mp4` (sha256 `50b3b50b77d4dab8b80dc2699bc78db599624cc550d31db7be20d675b3777fd6`)
was produced on 2026-09-18 with `ffmpeg version 4.4.2-0ubuntu0.22.04.1`:

```sh
ffmpeg -i upstream/h264bsd/test/test_640x360.h264 -c copy -movflags +faststart test_640x360.mp4
```

The Annex B elementary stream is copied into MP4 samples unchanged, so the pictures the
decoder sees are exactly the upstream test vector's; the container is what minimp4 demuxes.
It is read at run time by the `src/h264_file_*` entries (last command-line argument), never
embedded.
