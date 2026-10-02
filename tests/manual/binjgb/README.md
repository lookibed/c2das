# binjgb

Manual corpus: the core of binjgb, Ben Smith's Game Boy / Game Boy Color emulator, vendored
under `upstream/` at the revision recorded in `UPSTREAM.md`.  It is the first corpus whose
target is a whole-machine emulator: a cycle-counted SM83 CPU, the memory map and cartridge
mappers, the PPU with CGB palettes, the APU, timers and interrupts, all behind one
`emulator_run_until` call.

The corpus is the canonical case `binjgb-cgb-acid2-std` in `tests/canonical/cases.json`:
`src/binjgb_all.c` translated under `--libc std`, run against `fixtures/cgb-acid2.gbc`.  It is
**ready**: the unmodified graph converges with the C reference in every daslang run mode
(see "Translation status" below and `docs/corpus-convergence.md`).

## Layout

- `src/all.c` — the c2das target graph: upstream's `common.c`, `emulator.c` and `joypad.c` in
  one translation unit.
- `src/platform.c` — the platform layer both entries share, written against binjgb's public
  API only: ROM loading with upstream's `file_read_aligned`, the emulator configuration, the
  scripted joypad input and the per-frame hash (its header comment has the details).
- `src/entry.c` — the C entry of the canonical case.  Emulates 60 frames (one second of Game
  Boy time) and prints `rom_bytes=`, the cartridge header lines binjgb itself prints while it
  loads the ROM, `width=`, `height=`, `frame[i]=<hash>` per frame, `frames=60` and `ticks=`,
  the emulated CPU clock after the last frame.
- `src/bench_entry.c` — the same over 300 frames, plus `setup_us` (emulator creation) and
  `decode_us` (the frame loop: emulation and hashing), measured with
  `clock_gettime(CLOCK_MONOTONIC)`.  The ROM is read before any timer starts and the hashes
  are printed after the timed loop.
- `src/binjgb_all.c` / `src/binjgb_bench_all.c` — graph, platform layer and one of the entries
  in a single translation unit.  These are the `--libc std` translation inputs and the C
  programs.
- `include/` — libc stubs that shadow the system headers for the whole graph, declared with the
  glibc ABI so the C build links against the real libc: `stdio.h`, `stdlib.h`, `string.h`,
  `time.h`.  `stddef.h`, `stdint.h`, `inttypes.h` and `assert.h` come from the system.
- `fixtures/` — `cgb-acid2.gbc` and its license.

## The workload

- Game Boy Color mode: cgb-acid2's header requires CGB and `force_dmg` is off.  binjgb has no
  boot-ROM path; it starts from its own post-boot register state.
- `CGB_COLOR_CURVE_NONE`, random seed `0xcabba6e5`, 44100 Hz audio in 2048-frame buffers
  (generated and discarded; the frame loop waits only for `EMULATOR_EVENT_NEW_FRAME`).
- Scripted input: A held on frames 8 and 9, nothing otherwise.
- Hash: 32-bit FNV-1a over the 160×144 framebuffer packed to RGB555, two bytes per pixel,
  low byte first.  This is the packing and hash of the Spider fixture the corpus comes from,
  and its published values agree: first frame `1015431621`, frame 15 `838717591`.

cgb-acid2 draws its test image once and then idles, so every frame from frame 1 on hashes to
the same value, and the A press changes nothing visible.  The per-frame lines therefore check
the first frame and that nothing drifts after it; `ticks=` checks that the emulated CPU spent
exactly the same number of cycles.  A test ROM whose picture keeps changing would be a
stronger oracle; cgb-acid2 is the one freely licensed ROM this corpus carries.

## Build and run, natively

```sh
clang-18 -std=c11 -O2 -DNDEBUG -Iinclude -Iupstream/binjgb/src -Isrc src/binjgb_all.c -o /tmp/binjgb
/tmp/binjgb fixtures/cgb-acid2.gbc
```

`-O0`, `-O2` and `-O3 -march=native` print identical output, and so does an `-O0` build with
`-fsanitize=address,undefined` (no report).  `-DNDEBUG` compiles upstream's `assert`s out, as
in a release build of binjgb, for the C reference and the translation alike.  clang warns once
about the unused `print_joypad_buttons` in `joypad.c`.  `src/binjgb_bench_all.c` builds the
same way; at `-O3 -march=native` its 300 frames take about 60 ms.

## Translation status

Ready (2026-10-02).  `src/binjgb_all.c` translates under `--libc std` and prints the pinned
oracle in the interpreter, `-jit`, AOT and `-exe` (`docs/corpus-convergence.md`).  Three
translator gaps stood in the way and are fixed in the translator, each with a canonical case:
compound assignment on an enum-typed lvalue (`FC ^= 1`, `p120`), the 256-case `switch` whose
`elif` chain exceeded clang's bracket limit in the AOT C++ (`p121`), and a record with pointer
members copied out of a `const` place — `e->file_data = *file_data` and the by-value
`JoypadStateIter` parameters of `joypad.c` (`p133-const-record-copy`).  Upstream is not edited.
`docs/followups/corpus_status.md` ("binjgb: translation blockers") has the history.
