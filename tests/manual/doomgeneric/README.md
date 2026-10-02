# doomgeneric

Manual corpus: the Doom engine, through doomgeneric (Chocolate Doom reduced to a handful of
platform hooks), vendored under `upstream/` at the revision recorded in `UPSTREAM.md`, with id
Software's shareware IWAD as the fixture.  It is the largest C program of the corpora so far:
80 engine translation units, 55,700 lines of C, compiled as one translation unit.

The workload is vanilla Doom's own demo benchmark: the engine runs as
`doom -iwad <wad> -nosound -nomusic -timedemo demo1` and plays back the IWAD's first demo lump
(DEMO1: E1M5, skill 2, 5026 tics).  Under `-timedemo` the engine sets `singletics`, so every
`doomgeneric_Tick` runs exactly one game tic and renders exactly one frame, and the demo's
recorded input is the only input.  The platform layer hashes every rendered frame.

The canonical case is `doomgeneric-demo1-std` in `tests/canonical/cases.json`: `src/doom_all.c`
translated under `--libc std`.  It is **known-red**: the C reference is pinned and green, and
the translation compiles and matches every pinned frame under `-jit`, but the daslang
*interpreter* stops on a daslang defect (see "Translation status");
`docs/followups/corpus_status.md`, "doomgeneric: translation gaps", lists every gap found.

## Layout

- `src/all.c` — the c2das target graph: the configuration (`CMAP256`, 320×200, `NORMALUNIX`,
  `LINUX`, `_DEFAULT_SOURCE`, the same as upstream's Makefile and its ports), upstream
  Makefile's `SRC_DOOM` list without the X11 backend, and the platform layer, in one
  translation unit.  See "The unity build" below for the two preprocessor definitions it
  needs.
- `src/dg_platform.c` — the platform layer: the six `DG_*` hooks of `doomgeneric.h` for a
  headless, deterministic run.  Time is virtual (`DG_GetTicksMs` answers a counter that only
  `DG_SleepMs` and the entries move), there are no keys, and `DG_DrawFrame` records a 32-bit
  FNV-1a hash of the frame's 64,000 pixels, each taken as its 24-bit RGB colour through the
  current palette `colors[256]`, so a palette change (damage and pickup flashes) changes the
  hash as much as a pixel change does.  Written for this corpus; Spider's
  `dg_voxelcore.c` (a WASI platform layer with an in-memory IWAD) was the starting point for
  the virtual clock, nothing else of it is needed here because the engine reads the IWAD
  itself through `w_file_stdc.c`.
- `src/doom_entry.c` — the C entry: starts the engine on the IWAD named by the last
  command-line argument, ticks until 70 frames exist and prints `frame[i]=<hash>` per frame
  and `frames=70`.
- `src/doom_bench_entry.c` — the same over 1000 frames, plus `setup_us`
  (`doomgeneric_Create`: startup, IWAD indexing, renderer tables, the first 41 frames) and
  `decode_us` (the tick loop, 959 frames, per-frame hash included), measured with
  `clock_gettime(CLOCK_MONOTONIC)` and printed after the loop.
- `src/doom_all.c` / `src/doom_bench_all.c` — the graph plus one of those entries in a single
  translation unit, so the translated module carries the program's `main`.  These are the
  `--libc std` translation inputs, and the C reference programs.
- `include/ctype.h` — shadows the system header for the graph: `isspace`, `isprint`,
  `toupper`, `tolower` as plain functions with the glibc ABI, instead of glibc's macros over
  `__ctype_b_loc()` (the same choice as `tests/manual/wasm3/include/ctype.h`).  Every other
  header is the system's.
- `fixtures/doom1.wad` — the shareware IWAD, 4,196,020 bytes, unmodified (`UPSTREAM.md`).

## The unity build

Compiled separately, the 80 files need nothing; compiled as one translation unit they need two
things, both preprocessor definitions in `src/all.c`, no edit of a vendored file:

- `p_spec.c` and `wi_stuff.c` each define a file-scope `anim_t` type and `anims` table (one
  for flat and texture animations, one for the intermission screen).  `wi_stuff.c` is
  included with `anim_t` and `anims` renamed to `wi_anim_t` and `wi_anims`; nothing outside
  `wi_stuff.c` names its two.  Clang reports no other clash (no redefinition, no
  macro redefinition) across the 80 files.
- The engine's console goes to stderr: `printf`, `puts` and `putchar` are redefined as
  `fprintf(stderr, ...)`/`fputc(..., stderr)` for the engine files and undefined again
  before the platform layer and the entry.  The startup log prints the zone heap's address
  (`i_system.c`, `"zone memory: %p"`) and the IWAD's path, so it differs between two runs of
  the same binary and between C and daslang; stdout carries only the entry's oracle lines.
  The engine's `fprintf(stderr, ...)` calls are unchanged.

## Build and run, natively

Run from a scratch directory: the engine creates `./.savegame/` in the working directory at
startup (`m_config.c`, `M_GetSaveGameDir`), and would do so inside this checkout.

```sh
C=<checkout>/tests/manual/doomgeneric
clang-18 -std=c11 -O2 -I$C/include -I$C/upstream/doomgeneric/doomgeneric -I$C/src \
    $C/src/doom_all.c -o doom
./doom $C/fixtures/doom1.wad 2>/dev/null
```

No `-lm` and no `-D` are needed.  Clang prints 74 `-Wdeprecated-non-prototype`
warnings (Doom's unprototyped action-function declarations in `info.c`), one
`-Wpointer-to-int-cast` (`p_maputl.c:849`, see below) and one `-Wabsolute-value`
(`r_segs.c:399`); all are upstream's.

Output: 70 lines `frame[0]=-288221841` … `frame[69]=763190869` (pinned in `cases.json`),
then `frames=70`, exit 0.  `-O0`, `-O2` and `-O3 -march=native` print the same hashes, and
the 1000-frame benchmark entry prints the same first 70.  The whole run takes about 10 ms at
`-O2`; the benchmark's tick loop about 113 ms at `-O3 -march=native`.

The first 41 frames are rendered inside `doomgeneric_Create` (`D_DoomLoop` → `D_Display`,
which runs the screen wipe of `f_wipe.c` into the level, one frame per virtual tic); frames
39–44 hash the same because the view does not change over those tics.  From frame 41 on,
every frame is one demo tic.

## Determinism

Nothing in the run reads the host: the clock is virtual, there is no input, sound and music
are off, the engine reads nothing but the IWAD (`default.cfg` is absent and is never written,
because the program returns from `main` instead of calling `I_Quit`).  The one address the
engine turns into data is `p_maputl.c:849`: vanilla's intercepts-overrun emulation writes
`(int) intercept->d.thing` into other globals when a trace crosses more than 128 intercepts.
Whether DEMO1 triggers it within the benchmark's 1000 frames has not been checked; if it
does, a translation, whose addresses differ from C's, could diverge there for a reason that is
not a translator defect.

## Translation status

Known-red (2026-10-02).  Strict translation of `src/doom_all.c` under `--libc std` succeeds,
the module compiles in daslang (`das_options: ["stack = 4194304"]`: the generated initializer
of the 967-entry `states[]` table needs more than daslang's default stack), and `daslang -jit`
prints all 70 pinned frame hashes.  The interpreter stops at startup in `Z_CheckHeap` with
`EXCEPTION: jump to label 0 failed`: daslang's if-return folding moves the statements after
an `if (...) { return }` — labels included — into a nested `else` block, and a `goto` back to
a label outside it then fails.  It is a daslang defect with a pure-daslang reproducer in
`docs/followups/corpus_status.md`, "doomgeneric: translation gaps", which also lists every
translator gap found and fixed.  The case carries its `corpus` block; `corpus_matrix.py` runs
it only under `--case` while it is known-red.  The intercepts-overrun emulation of
`p_maputl.c:849` does not affect the 70 pinned frames (the `-jit` run matches C).
