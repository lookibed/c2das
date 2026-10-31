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
| `doom/` | The timedemo program under `--libc std`, `--module-layout source`: @DOOM_MODULES@ modules (one per C file, or a cluster of mutually dependent files), @DOOM_INCS@ `.das.inc` fragments, and the runtime `dasdoom_runtime.das` (named per program, so dasDOOM and dasQUAKE fit in one EdenSpark project). The entry `doom_entry.das` plays `-timedemo demo1` and prints one hash per frame. |
| `doom/run.sh` | Runs the program on `doom1.wad` and compares the first 70 frame hashes with `expected_frames.txt`, the output of the C build. |
| `doom/dg_host.das`, `doom/doom_sdl.das` | The desktop SDL3 build (see below): `dg_host.das` is the translation of the host API `harness/sdl/dg_host.c` (start, tic, frame hashes, the frame as ARGB pixels), `doom_sdl.das` the hand-written daslang host that opens the window through dasSDL3. |
| `sdl/run.bat` | Runs the SDL3 build on Windows. |
| `eden/` | The interactive build for the EdenSpark editor, per file like `doom/`: the engine with the platform layer and sound mixer (the harness files join the cluster module `am_map_cluster.das`, which defines the `dge_*` host API), the runtime `dasdoom_runtime.das`, the hand-written host `c2das_doom_player.das`, and `main.das.example`. |
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

## Desktop (SDL3, via dasSDL3)

![dasDOOM in an SDL3 window, daslang -jit](docs/sdl3.png)

The same translated engine as `doom/`, in a desktop window. The window, the texture upload
and the timing go through [dasSDL3](https://github.com/spiiin/dasSDL3) by spiiin, the SDL3
bindings for daslang. The host `doom/doom_sdl.das` is about 150 lines of daslang. It plays
`-timedemo demo1` of the shareware IWAD: each loop iteration runs one engine tic and frame,
converts the 8-bit frame through the palette to ARGB8888 (in the translated `dg_host.das`),
uploads it to a 320×200 streaming texture and presents it scaled to the 960×600 window. Escape
or closing the window stops it. Afterwards it prints one FNV-1a hash per frame, so every run is
checked against the C build, and the timing.

Doom is used here as a test bench, for the c2das translator and for dasSDL3: there is no
keyboard play, sound or music in this build, only the recorded demo.

Requirements (Windows x64; this is the platform it was run on):

- daslang built with LLVM (for `-jit`), and the MSVC build tools: the JIT's link step needs
  `vcvars64.bat`'s library paths. `run.bat` finds them through `vswhere.exe`, or set `VCVARS`.
- dasSDL3 built as a daslang module (its `src/package` CMake entry, SDL 3.4.16), in a project
  root whose `modules\dasSDL3\` holds `dasSDL3.shared_module` and the `dassdl3\` scripts.
- The shareware `doom1.wad` (`tools/get_wad.sh`).

```bat
set DASLANG=<daScript>\bin\daslang.exe
set DASSDL3_PROJ=<project root with modules\dasSDL3>
set DOOM_WAD=<path>\doom1.wad
sdl\run.bat                         & rem -jit, 1000 frames as fast as possible
sdl\run.bat jit --realtime --frames 5000   & rem the demo at Doom's own 35 frames per second
sdl\run.bat interp                  & rem the daslang interpreter
```

`DOOM_WAD` defaults to `doom1.wad` in the repository root. The engine writes `.savegame\` and
the JIT its cache into `DASDOOM_WORK` (default `%TEMP%\dasdoom-sdl`). The first `-jit` run
compiles the engine first, which took about half a minute; later runs reuse the cache. Linux is not
claimed: this build has only been run on Windows.

Run on 2026-11-01 from this export, on Windows 10 with an AMD Ryzen 7 7435HS laptop CPU,
daslang 0.6.4 (daScript `69a589623`, LLVM JIT), dasSDL3 `dea320f`, SDL 3.4.16 (static), the
`windows` video driver with the `direct3d11` renderer, vsync off. Every run printed the 70 hashes
of `doom/expected_frames.txt`, and all 1000 frame hashes were equal to the natively compiled C
build of the same engine (clang-cl).

| `sdl\run.bat jit`, window, 959 timed frames (frames 41–999) | fps |
|---|---:|
| run 1 | 3552 |
| run 2 | 3032 |

This is a quick figure from two runs, not a benchmark. The C build of the same program
(`clang-cl /O2 -march=native`) did 3319 fps in window mode in c2das's
[Windows SDL3 harness](https://github.com/lookibed/c2das/tree/master/tests/manual/doomgeneric/sdl),
measured there with three runs per variant and the whole engine as one module. At these
rates the window and present cost a large part of each frame. `--realtime` played 1159 frames
at 35.0 fps with the same hashes.

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

## License

GPL-2.0, as doomgeneric. See [`LICENSE`](LICENSE) and [`NOTICE`](NOTICE). The Doom WAD is
not included. dasSDL3 (MIT) is a separate project and is not included either; the SDL3 build
only uses it.
