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
| `harness/` | The c2das-authored C entries and platform layers that the translations include. |
| `tools/get_pak.sh` | Downloads the Quake 1.06 shareware release and extracts `id1/pak0.pak`, checking SHA-1s. |

## Run it on daslang

```sh
tools/get_pak.sh                 # writes ./id1/pak0.pak (shareware 1.06; needs lhasa)
DASLANG=/path/to/daslang quake/run.sh .
```

`run.sh` uses `$DASLANG`, or `daslang` from `PATH`.

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
