# Upstream provenance

This directory vendors fixture input as ordinary source files.  It intentionally contains no
nested Git metadata.

| Component | Upstream | Revision | License retained at |
|---|---|---|---|
| doomgeneric | https://github.com/ozkl/doomgeneric | `dcb7a8dbc7a16ce3dda29382ac9aae9d77d21284` (2026-04-12, "boolean fix") | `upstream/doomgeneric/LICENSE` (GPL-2.0) |

Import procedure: clone the upstream at the recorded revision into a temporary directory, copy
its `doomgeneric/` source directory whole into `upstream/doomgeneric/doomgeneric/` and
`LICENSE`, `README.md`, `README.TXT` into `upstream/doomgeneric/`, excluding `.git`, then record
the new revision here.  `screenshots/`, `doomgeneric.sln` and upstream's top-level `.gitignore`
are not vendored (the `.gitignore` ignores a path named `doomgeneric`, which would hide the
vendored source directory from this repository).  Local graph wrappers, the platform layer and
generated outputs belong outside `upstream/`.

The vendored `doomgeneric/` is byte-identical to upstream at the revision above (202 files,
checked with `diff -r` against a fresh clone).  The copy in `lookibed/Spider`
(`tests/manual/real-world-doomgeneric/upstream/`) that this corpus was first pointed at is
*not* pristine: its `d_main.c` replaces upstream's
`I_AtExit((atexit_func_t) G_CheckDemoStatus, true)` with a wrapper function for WebAssembly's
typed `call_indirect`, so it was not used as the source of the import.

`src/all.c` compiles 80 of the vendored translation units (55,700 lines of `.c`): upstream
Makefile's 81-entry `SRC_DOOM` list without its X11 backend `doomgeneric_xlib.c`.  The other `doomgeneric_*.c` backends, the
SDL/Allegro sound and music modules, `gusconf.c`, `mus2mid.c` and `icon.c` are vendored for
provenance and never compiled.  No vendored file is modified; the two things the unity build
needs (renaming `wi_stuff.c`'s file-scope `anim_t`/`anims`, which clash with `p_spec.c`'s, and
sending the engine's console to stderr) are preprocessor definitions in `src/all.c`, described
there and in `README.md`.

## Fixtures

| File | Bytes | sha256 | md5 | Content | Origin |
|---|---|---|---|---|---|
| `fixtures/doom1.wad` | 4196020 | `1d7d43be501e67d927e415e0b8f3e29c3bf33075e859721816f652a526cac771` | `f0cefca49926d00903cf57551d901abe` | the DOOM shareware IWAD, version 1.9: episode 1 (E1M1–E1M9) and three demo lumps | id Software's shareware release, copied unmodified from `lookibed/Spider` `tests/manual/real-world-doomgeneric/fixtures/doom1.wad`; the md5 is the one the shareware 1.9 IWAD is catalogued under, and doomgeneric identifies it as "DOOM Shareware" |

`doom1.wad` is game data, not part of doomgeneric and not covered by its GPL.  id Software
released the shareware episode for free redistribution on the condition that it is distributed
unmodified; the file is vendored byte for byte and must stay that way.  Its license text lives
in the shareware release's own documentation, which is not vendored.

The corpus plays the IWAD's first demo lump.  Its 13-byte header, read from the file:

| Lump | Bytes | Version | Skill | Episode / map | Tics |
|---|---|---|---|---|---|
| `DEMO1` | 20118 | 109 (1.9) | 2 (Hurt me plenty) | E1M5 | 5026 |
| `DEMO2` | 15358 | 109 | 2 | E1M3 | 3836 |
| `DEMO3` | 8550 | 109 | 2 | E1M7 | 2134 |

The WAD is read at run time through the engine's own `w_file_stdc.c` (`fopen`/`fread`) from the
path given as the program's last argument, never embedded.
