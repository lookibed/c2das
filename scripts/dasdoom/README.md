# dasDOOM

The Doom engine as [daslang](https://dascript.org/) source. It is
[doomgeneric](https://github.com/ozkl/doomgeneric) translated from C by
[c2das](https://github.com/lookibed/c2das). The engine code is generated, not written by hand.
Each C file becomes a daslang module named after it, or a `.das.inc` fragment of a cluster
module when files depend on each other in a cycle. So the tree mirrors the original sources.

> **Generated — do not edit.** Regenerate from a c2das checkout with
> `python3 scripts/export_dasdoom.py <dasDOOM checkout>`.
> This tree: c2das `@C2DAS_SHORT@`, doomgeneric `@UPSTREAM_COMMIT@`. Details are in
> [`GENERATED.json`](GENERATED.json).

## Layout

| path | what it is |
|---|---|
| `doom/` | The timedemo program under `--libc std`, `--module-layout source`: @DOOM_MODULES@ modules (one per C file, or a cluster of mutually dependent files), @DOOM_INCS@ `.das.inc` fragments, and the runtime `c2da_runtime.das`. The entry `doom_entry.das` plays `-timedemo demo1` and prints one hash per frame. |
| `doom/run.sh` | Runs the program on `doom1.wad` and compares the first 70 frame hashes with `expected_frames.txt`, the output of the C build. |
| `eden/` | The interactive build for the EdenSpark editor: `doom_eden_play_all.das` (engine, platform layer and sound mixer in one module), the hand-written host `c2das_doom_player.das`, and `main.das.example`. |
| `harness/` | The c2das-authored C entries and platform layers that the translations include. |
| `tools/get_wad.sh` | Downloads the shareware `doom1.wad` and checks its SHA-1. |

## Run it on daslang

```sh
tools/get_wad.sh                 # writes ./doom1.wad (shareware 1.9)
DASLANG=/path/to/daslang doom/run.sh doom1.wad
```

`run.sh` uses `$DASLANG`, or `daslang` from `PATH`. The interpreter runs the 70 frames,
WAD load included, in a few seconds.

Tested with daslang 0.6.4: this export with
[GaijinEntertainment/daScript](https://github.com/GaijinEntertainment/daScript) master
`c4e4906eb` (2026-10-07). c2das CI pins the
[`lookibed/daScript`](https://github.com/lookibed/daScript) revision
`48c221317415b4b8ea473c09c68ff5f9c94a254b` for its runtime tests.

## Measured

From c2das's
[benchmark snapshot](https://github.com/lookibed/c2das#benchmark-snapshot), Linux, AMD Ryzen 7
7435HS, 2026-10-08, c2das `712474e26`. Doom `-timedemo demo1`, 1000 frames at 320×200, medians
of 5 runs. Those runs translate the engine as one unit, not this per-file layout.

| build | time | ratio to C -O3 |
|---|---:|---:|
| C, clang -O3 | 110 ms | 1.00× |
| daslang interpreter | 3868 ms | 35.1× |
| daslang LLVM JIT | 128 ms | 1.16× |
| daslang standalone executable | 122 ms | 1.10× |

In the EdenSpark editor, 2026-10-09: the editor runs scripts in its interpreter only.

| measurement | tics/s |
|---|---:|
| real time (Doom's own speed) | 35 |
| uncapped, one tic per editor update | 59.8 (the editor's update rate) |
| engine only, `doom_bench 700`, demo tics 1–700 / 701–1400 | 142 / 110 |
| engine and frame copy | 123 / 100 |

So the editor plays Doom at full speed with headroom of about 3–4×.

## Play it in EdenSpark

1. Copy the contents of `eden/` into `<project>/modules/dasdoom/`.
2. Put the shareware WAD at `<project>/assets/dasdoom/doom1.wad.data` (the same file,
   renamed).
3. Merge `eden/main.das.example` into the project's `main.das`. It loads the WAD in
   `on_initialize` and defines the cheats.
4. Run the game and type a cheat in the console:
   - `doom_play` plays at real time;
   - `doom_play fast` runs one tic per editor update;
   - `doom_play turbo` runs 4 tics per update;
   - `doom_bench 700` measures the engine;
   - `doom_report` prints the status line.

Keys: arrows or WASD move, Ctrl or F fires, Space or E uses, Shift runs, Enter, Esc for the
menu, Tab for the map, 1–7 select weapons. The mouse is not used.

Sound effects play through one stereo stream at 11 025 Hz.

## Not done

- **Music.** The game runs with `-nomusic`.
- **Published builds.** Only the editor is tested. An exported EdenSpark build has stricter
  rules than the editor.
- **Per-file layout for the EdenSpark build.** The play harness is one C translation unit:
  `dg_eden_play.c` calls file-static functions of `dg_eden_sound.c`. So `eden/` is a
  single module, while `doom/` is per file.

## License

GPL-2.0, as doomgeneric. See [`LICENSE`](LICENSE) and [`NOTICE`](NOTICE). The Doom WAD is
not included.
