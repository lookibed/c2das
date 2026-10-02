# doomgeneric as an SDL3 window application (Windows)

This harness runs the doomgeneric corpus as a real SDL3 window program and measures its
frame rate. It runs in three daslang modes (interpreter, `-jit`, AOT) on the c2das
translation, and in the same program built natively as C with MSVC and clang-cl. The engine
is the corpus's headless build: the same `-iwad <wad> -nosound -nomusic -timedemo demo1`
start-up, the same virtual clock and the same per-frame FNV-1a hash (`../src/dg_platform.c`).
Every run therefore prints the hashes of the corpus oracle, and those hashes are checked.
SDL lives only in the hosts. The engine contains no SDL code.

## Files

| File | Role |
|---|---|
| `dg_host.c` | Host API: `dg_host_start(iwad)`, `dg_host_tick()`, `dg_host_frame_count()`, `dg_host_frame_hash(i)`, `dg_host_frame_argb()` (the frame converted through the palette `colors[]` to 320×200 ARGB8888), `dg_host_width/height()`. It reads the platform layer's file-scope state and changes nothing in it. |
| `doom_host_all.c` | `../src/all.c` + `dg_host.c` as one translation unit, without a `main`. It is the translation input and the C reference's engine object. Under `_WIN32` it includes `<windows.h>` first and drops its `LoadMenu` macro, which would otherwise rename `m_menu.c`'s `LoadMenu` in the unity build. The Linux translation never compiles that part. |
| `dg_host.h` | Prototypes for the C host. |
| `doom_sdl_host.c` | C host: SDL3 window, loop, timing, output. |
| `doom_sdl.das` | daslang host: `require doom_host_all` (the translation), and the same loop as the C host. |
| `translate.sh` | Linux/WSL: translates `doom_host_all.c` twice (default and AOT header) and stages the host beside each translation. |
| `build_c.bat` | Windows: the four C reference builds. |
| `build_aot.bat`, `aot/` | Windows: the AOT build. dasSDL3 is built AOT-capable with the generated C++ linked in (`aot/CMakeLists.txt`, `aot/dasSDL3.das_module`). |
| `run.bat` | Windows: one run of one variant. |
| `bench.sh` | WSL: all variants × modes, `REPS` runs each, hash check, median FPS. |

## What one run does and prints

`doom_sdl_<build>.exe [--no-present] [--frames N] <wad>` and
`daslang [-jit|-use-aot] doom_sdl.das -- [--no-present] [--frames N] <wad>` run the same
steps in the same order:

1. SDL video init, a 960×600 window, the default renderer, vsync off, and a 320×200
   streaming ARGB8888 texture with nearest scaling. `--no-present` skips all of this.
2. `setup_us`: `dg_host_start`, the engine's whole start-up including the first 41 frames
   (the screen wipe).
3. The loop runs until the engine has rendered N frames (default 1000, the corpus
   benchmark's count; DEMO1 has 5026 tics). Each iteration polls SDL events (a window close
   or Escape stops the run), runs one engine tic and frame (`dg_host_tick`, which includes
   the platform layer's per-frame hash), converts the frame through the palette
   (`dg_host_frame_argb`), then does `SDL_UpdateTexture`, `SDL_RenderClear`,
   `SDL_RenderTexture` and `SDL_RenderPresent`. `--no-present` keeps only the tic and the
   conversion. `loop_us` comes from SDL's performance counter, and `fps` = `loop_frames`
   / loop seconds.
4. After the loop, the program prints `frame[i]=<hash>` for every frame (at most 4096),
   then `frames=`, `setup_us=`, `loop_frames=`, `loop_us=` and `fps=`. Before the loop it
   prints `video driver: ..., renderer: ...`.

There are three presentation modes. **window** uses SDL's default video driver
(`windows`, renderer `direct3d11`). **dummy** sets `SDL_VIDEODRIVER=dummy`, which is
headless and uses SDL's software renderer, so its cost is the CPU scaling to 960×600.
**nopresent** (`--no-present`) shows the engine plus palette conversion alone.

The engine's log goes to stderr (`run.bat` drops it). The engine creates `.savegame\` in the
working directory, so run from a scratch directory, never from the checkout.

## Environment

| Variable | Used by | Meaning |
|---|---|---|
| `SDL3_DIR` | `build_c.bat`, `build_aot.bat` | SDL 3.4.16 install prefix: `include\SDL3`, `lib\SDL3-static.lib`, `cmake\` (static, `/MD`) |
| `VCVARS` | all `.bat` | `vcvars64.bat`, needed only when `cl.exe` is not on `PATH`. Default: found through `vswhere.exe`. `-jit` needs the MSVC environment too, because its `lld-link` step links `msvcrt.lib`. |
| `CLANG_CL` | `build_c.bat` | Default: `clang-cl` on `PATH`, else `%ProgramFiles%\LLVM\bin\clang-cl.exe` |
| `DASLANG` | `run.bat`, `build_aot.bat` | `daslang.exe` built with LLVM. Default: on `PATH` |
| `DASROOT` | `build_aot.bat` | daScript root (`include\`, `lib\libDaScriptDyn*.lib`). Default: parent of `DASLANG`'s `bin\` |
| `DASSDL3_DIR` | `build_aot.bat` | dasSDL3 checkout, used unmodified |
| `DASSDL3_PROJ` | `run.bat` interp/jit | Project root whose `modules\dasSDL3` holds the dasSDL3 module |
| `DASSDL3_AOT_PROJ` | `run.bat` aot | Default: `aot-proj` in the current directory (where `build_aot.bat` stages it) |
| `DOOM_WAD` | `run.bat` | Default: `..\fixtures\doom1.wad` beside the scripts |
| `DOOM_SDL_GEN` | `bench.sh` | `translate.sh`'s output directory, as a Windows path |

**Use a WAD on a Windows drive.** When the checkout lives in WSL, the default `DOOM_WAD` is a
`\\wsl.localhost\...` path. The engine reads lumps from the file during play, so a WSL-backed
path lengthened the measured C setup from 6 ms to 140 ms and lowered nopresent FPS by
about 5 %. Copy `fixtures\doom1.wad` to a local drive and point `DOOM_WAD` at it.

## Build and run

C reference (any Windows shell, from a scratch directory):

```bat
set SDL3_DIR=<sdl3 install prefix>
<checkout>\tests\manual\doomgeneric\sdl\build_c.bat
rem -> doom_sdl_msvc_O2.exe, doom_sdl_msvc_avx2.exe, doom_sdl_clang_O2.exe, doom_sdl_clang_native.exe
run.bat c msvc_O2                    & rem window
run.bat c clang_native --no-present  & rem engine + conversion only
set SDL_VIDEODRIVER=dummy & run.bat c msvc_O2
```

| Build | Flags |
|---|---|
| `msvc_O2` | `cl /O2 /MD` |
| `msvc_avx2` | `cl /O2 /arch:AVX2 /MD` |
| `clang_O2` | `clang-cl /O2 /MD` (generic x86-64) |
| `clang_native` | `clang-cl /O2 /clang:-march=native /MD`, which matches `-march=native`. This is the fair ceiling for `-jit`, which compiles for the host CPU (see `docs/corpus-build-recipe.md` §2 and `docs/corpus-benchmark.md`). |

daslang. Translate on Linux/WSL, run on Windows:

```sh
tests/manual/doomgeneric/sdl/translate.sh /mnt/d/<scratch>/gen     # never inside the checkout
```

```bat
set DASLANG=<daScript>\bin\daslang.exe
set DASSDL3_PROJ=<project root with modules\dasSDL3>
run.bat interp <scratch>\gen\default [--no-present] [--frames N]
run.bat jit    <scratch>\gen\default [--no-present] [--frames N]
set DASSDL3_DIR=<dasSDL3 checkout>
build_aot.bat <scratch>\gen\aot
run.bat aot    <scratch>\gen\aot     [--no-present] [--frames N]
```

The translation follows `docs/corpus-build-recipe.md`. The default module is
`c2dascript-transpile --strict --libc std` (`options solid_context = true`, null checks on).
The AOT module adds `--public-module --no-solid-context --das-option disable_auto_inline`
(step 6a), and its host copy gets `options disable_auto_inline` prepended. The AOT row
therefore lacks `solid_context` and daslang's inliner, as in the corpus benchmark.
`aot/CMakeLists.txt` compiles the generated C++ with MSVC `/O2 /arch:AVX2`, so compare it
with the AVX2/native C rows.

`daslang -use-aot` silently interprets any function that has no AOT body. To confirm that
everything is linked, run one copy of the AOT host with `options log_aot = true` added after
its first line. Every listed function must show `AOT=0x...`.

All variants, hash-checked (WSL; the Windows paths are passed through to `run.bat`):

```sh
DOOM_SDL_GEN='D:\<scratch>\gen' DASLANG=... DASSDL3_PROJ=... DOOM_WAD='D:\...\doom1.wad' \
    REPS=5 FRAMES=1000 tests/manual/doomgeneric/sdl/bench.sh /mnt/d/<scratch>
```

On every run, `bench.sh` requires the first 70 hashes to equal the oracle of
`doomgeneric-demo1-std` (`tests/canonical/cases.json`), and all frames to equal the first
variant's run in the same mode (the C build). A run that fails either check is reported as
FAIL with no number.

## Status

- The C reference is green on Windows. All four builds, in all three modes, print the
  oracle's first 70 hashes, and all 1000 (and 4000) frames agree with each other and with
  Linux `clang-18 -O2` of `../src/doom_bench_all.c`.
- The daslang modes wait on the translation: daslang refuses `doom_host_all.das` with the
  corpus's known errors (`structure is already defined actionf_t`, ...; see `../README.md`).
  The host itself compiles and runs in the interpreter, `-jit` and AOT against a stand-in
  module that has the translation's API signatures (`dg_host_start(int8?)`,
  `dg_host_frame_argb() : uint?`, ...).
