# dasQUAKE

The Quake engine as [daslang](https://dascript.org/) source. It is
[quakegeneric](https://github.com/erysdren/quakegeneric), id Software's WinQuake software
renderer behind a seven-function platform layer, translated from C by
[c2das](https://github.com/lookibed/c2das). The engine code is generated, not written by hand.
Each C file becomes a daslang module named after it, or a `.das.inc` fragment of a cluster
module when files depend on each other in a cycle. So the tree mirrors the original sources.

> **Generated — do not edit.** Regenerate from a c2das checkout with
> `python3 scripts/export_dasquake.py <dasQUAKE checkout>`.
> This tree: c2das `@C2DAS_SHORT@`, quakegeneric `@UPSTREAM_COMMIT@`. Details are in
> [`GENERATED.json`](GENERATED.json).

## Layout

| path | what it is |
|---|---|
| `quake/` | The timedemo program under `--libc std`, `--module-layout source`: @QUAKE_MODULES@ modules (one per C file, or a cluster of mutually dependent files), @QUAKE_INCS@ `.das.inc` fragments, and the runtime `dasquake_runtime.das` (named per program, so dasQUAKE and dasDOOM fit in one EdenSpark project). The entry `quake_entry.das` plays `+timedemo demo1` and prints one hash per frame. |
| `quake/run.sh` | Runs the program on `id1/pak0.pak` and compares the 100 frame hashes with `expected_frames.txt`, the output of the C build. |
| `eden/` | The interactive build for the EdenSpark editor, per file like `quake/`: the engine with the play platform layer `qg_eden_play.c` (it joins the cluster module `@PLAY_MODULE@.das`, which defines the `qge_*` host API), the runtime `dasquake_runtime.das`, the hand-written host `c2das_quake_player.das`, and `main.das.example`. |
| `quake/qg_host.das`, `quake/quake_sdl.das` | The desktop SDL3 build (see below): `qg_host.das` is the translation of the host API `harness/sdl/qg_host.c` (start, tick, key and mouse input, frame hashes, the frame as ARGB pixels), `quake_sdl.das` the hand-written daslang host that opens the window through dasSDL3. |
| `sdl/run.bat` | Runs the SDL3 build on Windows. |
| `harness/` | The c2das-authored C entries and platform layers that the translations include. |
| `tools/get_pak.sh` | Downloads the Quake 1.06 shareware release and extracts `id1/pak0.pak`, checking SHA-1s. |

## Run it on daslang

```sh
tools/get_pak.sh                 # writes ./id1/pak0.pak (shareware 1.06; needs lhasa)
DASLANG=/path/to/daslang quake/run.sh .
```

`run.sh` uses `$DASLANG`, or `daslang` from `PATH`.

## Desktop (SDL3, via dasSDL3)

![dasQUAKE in an SDL3 window, daslang -jit](docs/sdl3.png)

The same translated engine as `quake/`, in a desktop window. The window, the input, the texture
upload and the timing go through [dasSDL3](https://github.com/spiiin/dasSDL3) by spiiin, the
SDL3 bindings for daslang. The host `quake/quake_sdl.das` is about 300 lines of daslang. Each
loop iteration runs one engine frame, converts the 8-bit 320×240 screen through the palette to
ARGB8888 (in the translated `qg_host.das`), uploads it to a streaming texture and presents it
letterboxed in the resizable 960×720 window.

By default it plays: the pak's attract loop runs demo1, demo2 and demo3 at real time, and any
key opens the menu, where New Game starts episode 1. Keyboard and mouse go to the engine; while
a game is being played (no menu, console or demo) the mouse is captured for mouse look. Keys are
Quake's defaults: arrows move and turn, Ctrl fires, Space jumps, Shift runs, Esc for the menu,
`` ` `` for the console. Closing the window ends the run. There is no sound: quakegeneric
compiles the null sound driver.

`--timedemo` is the check and the frame-rate figure: `+timedemo demo1` on the corpus's virtual
1/64 s tick, as fast as possible, then one FNV-1a hash per recorded frame and the timing. The
first 100 hashes must equal `quake/expected_frames.txt`.

Requirements (Windows x64; this is the platform it was run on):

- daslang built with LLVM (for `-jit`), and the MSVC build tools: the JIT's link step needs
  `vcvars64.bat`'s library paths. `run.bat` finds them through `vswhere.exe`, or set `VCVARS`.
- dasSDL3 built as a daslang module (its `src/package` CMake entry, SDL 3.4.16), in a project
  root whose `modules\dasSDL3\` holds `dasSDL3.shared_module` and the `dassdl3\` scripts.
- The shareware `id1\pak0.pak` (`tools/get_pak.sh`).

```bat
set DASLANG=<daScript>\bin\daslang.exe
set DASSDL3_PROJ=<project root with modules\dasSDL3>
set QUAKE_BASEDIR=<directory holding id1\pak0.pak>
sdl\run.bat                              & rem play, -jit
sdl\run.bat --fullscreen                 & rem the same, full screen
sdl\run.bat --timedemo --frames 919      & rem all of demo1 as fast as possible, hashes and fps
```

`QUAKE_BASEDIR` defaults to the repository root. The JIT writes its cache into `DASQUAKE_WORK`
(default `%TEMP%\dasquake-sdl`). The first `-jit` run compiles the engine first; later runs reuse
the cache. Linux is not claimed: this build has only been run on Windows.

Run on 2026-11-01 from this export, on Windows 10 with an AMD Ryzen 7 7435HS laptop CPU,
daslang 0.6.4 (LLVM JIT), SDL 3.4.16, the `windows` video driver with the `direct3d11` renderer.
Every timedemo run printed the 100 hashes of `quake/expected_frames.txt`, and both full runs
printed the same 919 hashes.

| `sdl\run.bat --timedemo --frames 919`, window, vsync off | fps |
|---|---:|
| run 1 | 900 |
| run 2 | 1034 |

This is a quick figure from two runs, not a benchmark, and no C build was measured beside it.

## Play it in EdenSpark

1. Copy the contents of `eden/` into `<project>/modules/dasquake/`.
2. Put the shareware pak at `<project>/assets/dasquake/pak0.pak.data` (the same file,
   renamed).
3. Merge `eden/main.das.example` into the project's `main.das`. It loads the pak in
   `on_initialize` and defines the cheats.
4. Run the game and type a cheat in the console:
   - `quake_play` plays the attract demos at real time; Esc opens the menu, where New Game
     starts episode 1;
   - `quake_play map` starts the map `start` directly;
   - `quake_play fixed` advances the game by 33 ms per editor update;
   - `quake_mouse` turns mouse look on or off;
   - `quake_bench 300` measures the engine;
   - `quake_report` prints the status line.

Keys: arrows or W/S move and turn, A/D or `,`/`.` strafe, Ctrl or F fires, Space jumps, Shift
runs, Enter, Esc for the menu, Tab for the scores, 1–8 select weapons, `=`/`-` the screen size,
Q/Z/X look up, down and centre. With `quake_mouse` on, the mouse turns (x) and walks (y), Quake's
default without `+mlook`.

## Not done

- **Sound.** quakegeneric compiles the null sound driver; the game is silent.
- **Published builds.** Only the editor is targeted. An exported EdenSpark build has stricter
  rules than the editor.

## License

GPL-2.0, as quakegeneric. See [`LICENSE`](LICENSE) and [`NOTICE`](NOTICE). The Quake game data
is not included: the shareware licence allows its distribution only as the whole release, free
of charge and for non-commercial use.
