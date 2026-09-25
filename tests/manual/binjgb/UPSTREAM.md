# Upstream provenance

This directory vendors fixture input as ordinary source files.  It intentionally contains no
nested Git metadata.

| Component | Upstream | Revision | License retained at |
|---|---|---|---|
| binjgb | https://github.com/binji/binjgb | `8191a5d6e48133e5f85de7307cf7eb2e0cf2f701` ("Fix assert", 2026-01-05) | `upstream/binjgb/LICENSE` (MIT, Copyright (c) 2016 Ben Smith) |
| cgb-acid2 | https://github.com/mattcurrie/cgb-acid2 | release `v1.1` (2020-04-14) | `fixtures/cgb-acid2.LICENSE` (MIT, Copyright (c) 2020 Matt Currie) |

## binjgb

The vendored files are upstream's `src/common.c`, `common.h`, `emulator.c`, `emulator.h`,
`joypad.c`, `joypad.h`, `memory.h` and `builtin-palettes.def`, byte-identical to that revision,
and the top-level `LICENSE`.  The corpus arrived through Spider's
`tests/manual/real-world-binjgb/upstream/`, which recorded no revision; every one of its files was
compared byte for byte against upstream's history and matches `8191a5d6` (the newest commit
touching `src/emulator.c` whose tree matches all of them).  Spider's copy lacked `memory.h` and
shadowed it with a stub that only included `string.h`; this corpus vendors upstream's own
`memory.h` from the same revision instead, which `#define`s `xmalloc`, `xcalloc`, `xrealloc`,
`xfree` and `xstrdup` to the libc allocators (`TRACE_MEMORY` 0).

Import procedure: fetch the recorded revision into a temporary directory, copy the eight files
above into `upstream/binjgb/src/` and `LICENSE` into `upstream/binjgb/`, then record the new
revision here.  Not vendored: the SDL/OpenGL host (`host*.c`, `binjgb.c`), the debugger and
ImGui UI, the rewind buffer (`rewind.c`), option parsing (`options.c`), the tester, the
memory-tracing `memory.c` (unused with `TRACE_MEMORY` 0), `emulator-debug.*`, the emscripten
build and the test suites.  Local graph wrappers and generated outputs belong outside
`upstream/`.

`src/all.c` compiles the three vendored translation units — `common.c`, `emulator.c`,
`joypad.c` — which are upstream's emulator library without any host.  `joypad.c` (the input
recording buffer for rewind and movie playback) is never called by the corpus entries; it is
part of the graph because it is part of that library, and it is where two of the translation
blockers are (see `README.md`).

## Fixtures

| File | Bytes | sha256 | Content | Origin |
|---|---|---|---|---|
| `fixtures/cgb-acid2.gbc` | 32768 | `197fb0bcec544f0400527fc707e0a94f55435974986e6986b424ace5de81720e` | Matt Currie's Game Boy Color PPU test ROM (CGB-only header, ROM only, no RAM) | the `cgb-acid2.gbc` asset of release `v1.1`, https://github.com/mattcurrie/cgb-acid2/releases/download/v1.1/cgb-acid2.gbc |
| `fixtures/cgb-acid2.LICENSE` | 1068 | `2b5ed6f8abbded3913a08ebe8f4eedb340735efc3b024570244d6efa73418044` | the ROM's MIT license | `LICENSE` at the root of the cgb-acid2 repository |

The ROM also arrived through Spider's fixture directory; it is byte-identical to the `v1.1`
release asset (the `v1.0` asset differs).  It is the only ROM in this corpus: it is
MIT-licensed test software written for emulator validation.  It is read at run time by the
`src/*entry.c` programs (last command-line argument), never embedded.
