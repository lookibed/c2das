# Upstream provenance

This directory vendors fixture input as ordinary source files.  It intentionally contains no
nested Git metadata.

| Component | Upstream | Revision | License retained at |
|---|---|---|---|
| quakegeneric | https://github.com/erysdren/quakegeneric | `13052102577c629650cf07a46151a4b6e1b19c3c` (2025-01-27, "source/makefile: overhaul") | `upstream/quakegeneric/LICENSE` (GPL-2.0) |

quakegeneric wraps id Software's WinQuake software renderer the way doomgeneric wraps Doom: the
port provides `QG_Create` and `QG_Tick`, the host implements seven `QG_*` functions
(`source/quakegeneric.h`).

Import procedure: clone the upstream at the recorded revision into a temporary directory and copy
the whole tree, excluding `.git`, into `upstream/quakegeneric/`, then record the new revision here.
Local wrappers, the platform layer and generated outputs belong outside `upstream/`.

The vendored tree is byte-identical to upstream at the revision above (132 files, checked with
`diff -r` against a fresh clone).  An earlier, unpublished fixture copy of the same revision was
also checked with `diff -r` and is identical; it was not modified.  No vendored file is modified.

## What is compiled

The cases compile 70 units one by one (`translation_units`), never as a unity build: Quake's
headers have no include guards (`quakedef.h` includes them all), so a second engine `.c` in the
same translation unit redefines every type.

- The 68 engine units of upstream's `source/makefile` `OBJS` list, in its order: the engine with
  the null CD, input, sound, network-driver, system and video modules (`*_null.c`, `net_none.c`)
  and the generic port `quakegeneric.c`.  The makefile's SDL2 backend `quakegeneric_sdl2.c` and
  the other backends (`quakegeneric_dos.c`, `quakegeneric_null.c`, `quakegeneric_w32.c`) are
  vendored but not compiled.
- `src/qg_platform.c` (ours): the seven `QG_*` functions.  No input; every frame without the
  console is hashed (32-bit FNV-1a over the RGB of each pixel through the current palette, the
  doomgeneric corpus's hash) and recorded.
- `src/quake_entry.c` (ours): `main`, alone in its file so that no dependency cycle of engine
  units contains it.  It runs the engine as `quake -basedir <dir> +timedemo demo1`, ticks
  `QG_Tick(1/64)` until 100 frames are recorded, and prints `frame[i]=<hash>` lines and
  `frames=100`.

`src/engine_config.h` is force-included (`-include`) into every unit: it sends the engine's
console (`printf`/`vprintf`/`puts`/`putchar`) to stderr, because stdout is the oracle; the entry
ends the redirection.  The cases link `-lm` (the C reference program needs libm).

Frames that show any of the console (`scr_con_current != 0`) are not recorded: the console scrolls
up over the demo's first frames, and its log shows the base directory's absolute path and the
build time (`host.c` prints `__DATE__`/`__TIME__`), so those frames differ between builds and
directories.

## Native oracle

clang-18 on x86-64 Linux, 64-bit, `-std=c11` with the case flags.  The port is documented as
32-bit only (its makefile builds `-m32`, and a 64-bit `map e1m1` segfaults in QuakeC string
handling), but `timedemo` plays a demo without a server, so no QuakeC runs and the 64-bit build
plays `demo1` correctly.  A 32-bit build was not tried: this host has no 32-bit libc.

The 100 recorded frames (all distinct) are identical for clang-18 `-O0`, clang-18 `-O2`, clang-18
`-O2 -ftrivial-auto-var-init=pattern` and gcc `-O2`, and for two different base directories.  A
`-O2` run takes about 45 ms in all (startup, level load and 100 frames).

MemorySanitizer reports one read of an uninitialized value in upstream: `R_Alias_clip_z`
(`r_aclip.c:55`) compares `v[1]` of z-clipped alias vertices, which `R_AliasPreparePoints` leaves
unset.  It does not change any recorded frame (the pattern-initialised build matches), but a
translation that gives those stack slots different contents takes the other branch of that
comparison.

## Translation status

`quakegeneric-demo1-std` is `ready`: the translated program reproduces the C reference's 101
frame hashes.  `quakegeneric-demo1-eden-linear` is `ready` too: under the EdenSpark flags
(`--memory-model linear`, `--libc eden`, `--no-unsafe`) the same 101 lines come out.  Its test
host registers every file under the base directory argument (`fixtures/`) with
`c2da_eden_add_file` (`scripts/run_c2das_cases.py`, `write_eden_host`).

| case | status |
|---|---|
| `quakegeneric-demo1-std` (`--libc std`) | passes |
| `quakegeneric-demo1-eden-linear` (eden flags, `--memory-model linear`) | passes |

The last three gaps on the way, each with its fixture: `strerror` over C memory
(`p225-linear-strerror`), a call with arguments through an unprototyped function pointer held
in the heap and a `!side` heap index (`p226-linear-unprototyped-call`).

At the time of import (2026-10-12, translator at `e988a8de1`) both cases stopped at
`unsupported external call: atan` in `Chase_Update`.

The rest of libm the engine calls (`sqrt`, `sin`, `cos`, `tan`, `pow`) and stdio under the linear
model (`getc` in `cl_demo.c`, which reads the demo's CD-track line) are the next expected blockers (`docs/quake-eden-plan.md`, "Translator
work found"); they were not reached here.  These are translator gaps: the C is not changed to
avoid them.

## Play build (EdenSpark)

Milestone M1 of `docs/quake-eden-plan.md`, prepared ahead of the translator work it needs.

- `src/qg_eden_play.c` (ours) with `src/qg_eden.h`: the seven `QG_*` functions for interactive
  play and the host API `qge_init` (attract demos), `qge_init_map` (`+map start`),
  `qge_tick(ms)` (host clock; `QG_Tick` gets the time since the previous call), `qge_key`
  (`quakekeys.h` codes, a 64-event queue `QG_GetKey` drains), `qge_mouse`, `qge_screen`,
  `qge_palette`, `qge_frames`, `qge_width`, `qge_height`.  The engine runs as
  `quake -basedir quake`, so the host registers the pak as `quake/id1/pak0.pak`.  The screen is
  the engine's own `vid_buffer`; the palette is copied into a harness buffer, because the
  engine passes palettes from its stack (`V_UpdatePalette`, `CL_ParseServerMessage`).  No sound:
  `snd_null.c` is the sound driver.
- The play translation units are the case's 68 engine units plus `src/qg_eden_play.c`
  (not `qg_platform.c` or `quake_entry.c`; no `main`).
- `eden/c2das_quake_player.das` (hand-written host, follows the Doom player): texture from the
  8-bit screen through the RGB palette, keys through an action set, optional mouse from the
  input command buffer, status line with fps and frame ms.  `scripts/export_dasquake.py` and
  `scripts/dasquake/` export the dasQUAKE tree like dasDOOM's.

Checked natively (clang-18, 64-bit, the 68 engine units, `qg_eden_play.c` and a test driver in
scratch): `qge_init` then 400 `qge_tick` calls 40 ms apart, with an Esc press and mouse
movement, render 409 frames (every tick at least one; level loads render extra ones), and the screen address is `vid_buffer`.
`qge_init_map` segfaults natively after loading `maps/start.bsp`: the 64-bit QuakeC string
issue above.

In the EdenSpark editor (2026-10-12, exporter output of this tree's translator, eden/ installed
under `modules/dasquake/`, the pak as `assets/dasquake/pak0.pak.data`): `quake_play` plays the
attract demos and `quake_play map` loads and renders `maps/start.bsp` (under the linear model
the QuakeC string offsets are 32-bit).  The host's status line read 17-19 fps for the demos
(frame about 47-55 ms, screen copy about 1.3 ms) and about 11-12 fps on `start` (frame about
75-85 ms); `quake_bench 300` measured 61.6 ms/tick with the copy, 60.5 ms/tick without.  One
editor session, one machine, interpreter as the editor runs it; keyboard input was not
exercised.  The project's Doom install could not stay required next to it: both translations
ship a module named `c2da_runtime`, and one context holds one module of a name.

## Fixtures

`fixtures/id1/pak0.pak` is id Software's Quake shareware game data (version 1.06, episode 1).  It
is game data, not part of quakegeneric and not covered by its GPL or by this repository's
BSD-3-Clause licence, and it is **not committed**: `tools/get_pak.sh` fetches the shareware
release and extracts it (see `fixtures/README.md` for sizes and hashes).

Its terms are the shareware release's `SLICNSE.TXT` ("SHAREWARE VERSION: QUAKE, LIMITED USE
SOFTWARE LICENSE AGREEMENT"):

- section 6 grants the end user "the limited right to distribute, free of charge only, the
  Software as a whole", and Providers the right to distribute it electronically, compressed, with
  the agreement accompanying it;
- the grant is for non-commercial use: the agreement forbids commercially exploiting the Software
  or any portion of it.

Committing `pak0.pak` alone would distribute a portion of the release outside its whole, so this
repository does not; the fetch script downloads the whole release from a mirror of id Software's
FTP site and extracts the pak locally.
