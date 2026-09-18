# h264bsd-mp4

Manual corpus: the h264bsd H.264 baseline decoder and the minimp4 MP4 demuxer,
vendored under `upstream/` at the revisions recorded in `UPSTREAM.md`.  The
canonical case `h264bsd-mp4` in `tests/canonical/cases.json` decodes every
picture of `fixtures/sample.mp4` and pins its per-picture YUV hashes.

## Layout

- `src/all.c` — the c2das translation graph: `shim.c`, `h264bsd.c`, `minimp4.c`,
  `module.c` in one translation unit.
- `src/all_reference.c` — the C reference graph, pinned separately so the
  reference build always keeps the fixture's own libc bodies.
- `src/module.c` — the probe API, scalar-only: demuxer/decoder probes and the
  streaming `h264mp4_frames_*` API (begin, next, hash, index, width, height, end)
  that yields one hash per decoded picture.
- `src/h264_entry.das` / `src/h264_reference_entry.c` — the canonical entries; they
  print the same lines, recorded in `h264_reference.expected` and in
  `cases.json`.
- `src/h264_bench_entry.das` / `src/h264_bench_entry.c` — the benchmark entries
  for `scripts/corpus_matrix.py`: the same hashes plus `setup_us` and `decode_us`.
- `src/sample_mp4_data.h` — `fixtures/sample.mp4` as a C array.
- `include/` — libc stubs that shadow the system headers for the whole graph.

Generated daScript never lives here: every runner translates a temporary copy
of this directory and deletes any `.das` that is not one of the entries above.

## Run

```sh
python3 scripts/run_c2das_cases.py --case h264bsd-mp4
python3 scripts/corpus_matrix.py converge --case h264bsd-mp4
python3 scripts/corpus_matrix.py bench --case h264bsd-mp4
```
