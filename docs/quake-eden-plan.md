# Quake 1 in the EdenSpark editor: measurements and plan

Researched 2026-10-12. Labels: **[M]** measured, **[D]** from other c2das docs, **[E]** estimate.
The Eden target and its editor facts are in [`eden-flags.md`](eden-flags.md).

## Port: quakegeneric

[erysdren/quakegeneric](https://github.com/erysdren/quakegeneric) (GPL-2) wraps the WinQuake
software renderer the way doomgeneric wraps Doom.

**Platform layer:** the host provides 7 functions:
- `QG_Init`, `QG_Quit`;
- `QG_DrawFrame(pixels)` (8-bit, 320x240);
- `QG_SetPalette(768 bytes)`;
- `QG_GetKey`, `QG_GetMouseMove`, `QG_GetJoyAxes`.

The port itself provides `QG_Create` and `QG_Tick(seconds)`. Sound, network, CD and sys are null
stubs.

**Size and memory:**
- 63 compiled `.c` files, 41 168 lines [M].
- Hunk: 8 MiB from one `malloc`.
- Peak with `pak0.pak` (18.7 MB) held as a byte array: 60–70 MiB, under the editor's 100 MiB cap [E].

**Known issues:**
- **32-bit only [M].** QuakeQ string handles are pointer differences truncated to `int`, so a 64-bit
  native build segfaults in `map e1m1` (`PR_ExecuteProgram → strcmp`). Under
  `--memory-model linear` every address is a heap offset below 2^31, so this should be harmless
  [E, to verify].
- **`pak0.pak`:** the shareware licence (`SLICNSE.TXT`) allows distribution only of the shareware
  as a whole and forbids commercial use. The pak is fetched by a script and never committed.

Other ports — WinQuake/sdlquake, Chocolate Quake, tyrquake — have bigger platform layers and gain
nothing for the first milestone. QuakeSpasm is GL-only and about 100k lines; it is the reference for
the GPU milestone.

## Cost

### Native C [M]

gcc -O2, ms per frame:

| program | ms/frame |
|---|---|
| Quake `timedemo demo1`, 320x240 | 0.37–0.42 |
| Quake `e1m1`, server and progs | 0.28–0.29 |
| Doom | 0.13–0.16 |

Profile shares: spans and z-spans 40–47%, edges and BSP 30–35% (float-heavy), alias models 5%,
server about 10%.

### Quake-shaped kernels translated with the eden flags, per 320x240 frame [M]

| kernel | C | master raw | master linear | editor linear | editor ÷ C |
|---|---|---|---|---|---|
| spans (`D_DrawSpans8` shape) | 0.067 ms | 3.3 ms | 4.2 ms | 3.79 ms | 57× |
| surface block (lightmap + colormap) | 0.089 ms | 2.7 ms | 3.0 ms | 3.61 ms | 41× |
| float transform, 2000 vertices in heap structs | 0.008 ms | 0.22 ms | 3.3 ms | 3.07 ms | **~380×** |

Floats are the lever. One `float` access in the editor costs:

| heap layout | load | store |
|---|---|---|
| byte heap (today's linear model) | 46 ns | 62 ns |
| word heap (`array<uint>`) | 13.7 ns | 16 ns |
| `array<float>` | 7.2 ns | — |

**Estimate for the software renderer in the editor [E]:** 25–40 ms/frame, so 16–38 fps, about
25 fps likely. Quake runs on a variable frame time, so 20–30 fps is playable.

## GPU paths in Eden

What scripts can and cannot do (documentation survey, plus measurements):
- **Not available to scripts:** vertex shaders, compute shaders, immediate-mode drawing, vertex
  colours, a second UV set.
- **Framebuffer to dynamic texture** (Doom's path) [M]:

  | frame | palette → Bitmap | `update_texture` |
  |---|---|---|
  | 320x200 | 0.93 ms | 0.087 ms |
  | 640x480 | 4.46 ms | 1.04 ms |

  A palette lookup done in a pixel shader would remove the conversion.
- **Dynamic meshes** [M]. Positions, normals, one UV set and triangles only.

  | triangles | build | `update_mesh` |
  |---|---|---|
  | 1 k | 0.27 ms | 0.07 ms |
  | 10 k | 2.08 ms | 0.47 ms |

  The engine batches by mesh and material.
- **Pixel shaders only:** a `.shader` file using `engine.render.shader_dsl` and `[pixel_shader]`.
  The language is a float-only daslang subset with 16 float4 registers and 128 instructions, loops
  unrolled. This is from the docs; no shader was compiled in the editor.
- **A GL 1.x immediate-mode shim** is too costly: about 2 ms per 10 k triangles before the C side
  even runs. The workable form is a capture layer:
  1. At map load, GLQuake's world polygons become static meshes and its textures become
     `create_texture`.
  2. Per frame, only the camera, entities, alias-model frames and changed lightmap regions are
     updated.
- **An `eden_gpu` ABI:** c2das has no import mechanism yet, because an undefined extern is a strict
  error. The first step is a command buffer that the C writes into the heap and the host decodes
  each frame, as Doom's host does pull-only today. Real imports come later through a flag.

## Translator work found

1. **libm:** `sqrt`, `sin`, `cos`, `tan`, `atan`, `atan2`, `pow`. This was the first blocker [M].
2. **stdio under the linear model:** `getc` was the second blocker [M] and `clock_gettime` is
   refused [M]. `fscanf`, `rand` and `time` are missing [E].
3. **`setjmp`/`longjmp`** for `Host_Error`, lowered to panic plus `try/recover`.
4. **Float access cost:**
   - reuse heap loads within a block, and do not read a value back right after storing it — Quake's
     `DotProduct`/`VectorMA` macros reload the same fields. **Landed** (`linear/reuse.rs`, case
     `p229-linear-load-reuse`); see "M1.5: load reuse" below for what it buys;
   - optionally, a word-heap fast path for aligned floats, about 3.4× cheaper per access.
5. **A host-import flag** binding an undefined C extern to a daslang function, with heap ranges
   passed as (offset, length).
6. **Harness rule:** the unit with `main` must not sit in a dependency cycle, so the entry goes in
   its own file.

## Milestones

| milestone | content | expected in the editor |
|---|---|---|
| M0 | translator fixes 1–3; a quakegeneric timedemo case whose frame hashes equal C | — |
| M1 | C play harness (`qge_*`) and host copied from the Doom player; a dasQUAKE repo shaped like dasDOOM | 16–38 fps [E] |
| M1.5 | load reuse in the translator; palette lookup in a pixel shader | ~35–40 fps [E] |
| M2 | GLQuake capture layer → static meshes; command-buffer ABI, then host imports | ~60 fps [E] |

## Status (2026-10-12, 03:40)

### M0: done

Both cases equal C on master daslang, 101 frame-hash lines each:
- `quakegeneric-demo1-std` (raw memory);
- `quakegeneric-demo1-eden-linear` (`--libc eden --memory-model linear --dialect eden-0.6.4
  --no-unsafe`).

Translator work it took:
- libm, `rand`, `setjmp`/`longjmp`;
- `getc`, `fscanf` (std and linear), `sprintf`, `strerror`, printf floats under linear;
- local unions in the linear heap;
- calls through variadic and unprototyped function pointers;
- bool/enum conversions.

### M1: done, playable in the editor

The play build (`qg_eden_play.c` + `eden/c2das_quake_player.das`, per-file layout) runs in the
EdenSpark editor [M]:

| mode | fps | ms per frame |
|---|---|---|
| attract demos | 17–19 | 47–55 |
| `+map start` | 11–12 | 75–85 |
| `quake_bench 300` | 16 | 61 per tick |

- **QuakeC under the linear model:** its 32-bit string offsets work, because heap offsets are
  below 2^31.
- **Keyboard input in the editor:** not yet verified.
- **One project, one c2das program:** Doom and Quake cannot share an Eden project yet. Both ship a
  module named `c2da_runtime`, and the editor refuses the duplicate name.

### Host imports: landed as an experimental flag

`--host-import c=module::fn` and `--host-import-prefix pre=module` bind an undefined C extern to a
daslang function. Under linear memory, pointers pass as heap offsets, plus `c2da_mem` as the first
argument. Fixtures: `h01`, `m06`. Details: `eden-flags.md`, "Host imports (experimental)".

This is the call path an `eden_gpu_*` ABI for M2 will use.

### dasDOOM and dasQUAKE in one editor project (04:05)

Both public exports (`lookibed/dasDOOM`, `lookibed/dasQUAKE`) were installed side by side in one
EdenSpark project. The runtime modules are named per program (`dasdoom_runtime`,
`dasquake_runtime`), so the two no longer collide on `c2da_runtime`.

**Quake verified in the editor:**
- the demo renders;
- Esc opens the menu;
- New Game starts;
- holding Up walks forward.

**Memory:** peak context use with both games running is 93.4 of 104.9 MB.
- The 18.7 MB pak is stored as a 32 MiB array, the largest single allocation.
- A leftover probe project pushed the total past the cap. A project should hold nothing else.

**Speed [M]:**

| situation | Quake | Doom |
|---|---|---|
| Quake alone | 17.7 fps; `quake_bench` 44–60 ms per tick, 16.6–22.8 fps engine-only | — |
| both running | 12–14.5 fps | 12.7–15.6 tics/s |

### M1.5: load reuse (translator, 04:30)

The rule is in `eden-flags.md`, "`--memory-model linear` as built", under "Load reuse". Within a
block, a repeated 4-byte heap load becomes one `let`, and a `float` store is forwarded to the next
load of its address. Nothing is reused across a call, a store through another pointer, or control
flow. `volatile` is excluded.

- **Micro-benchmark** (20 M iterations, master daslang, 2 runs): one `float` load is 44–49 ns.
  Three loads of one field take 133–138 ns; one load plus a `let` takes 53–54 ns. Folding the
  address `p + 1 * 4 + k` into `p + 5 + k` gains under 5%, which is noise.
- **Quake timedemo** (`quakegeneric-demo1-eden-linear` flags, 100 frames, master daslang,
  `-no-module-cache`, interleaved, 13 runs of each): float load sites go from 3042 to 2782.
  - Wall time is bimodal on this machine, about 14.5 s or about 17.5 s, for either build.
  - Compiling takes 6.0–6.4 s.
  - In the fast mode, base takes 14.74–15.46 s and new takes 14.19–14.74 s. That is ≈ 86 → ≈ 82
    ms per frame (best runs, compile time removed), ≈ 5%. The gap is within the noise of the slow
    mode, so it is not a confirmed gain.
- **Why so little:** the hot transforms (`TransformVector`, `R_AliasTransformVector`, …) store
  `out[k]` between their `DotProduct`s over `in`. In C, `out` may alias `in`, so every `in`
  field has to be read again after each store. A bigger lever needs either restrict/alias facts
  or the word-heap fast path for aligned floats (item 4, about 3.4× per access).

### Next

1. The `das-critic-perf` libm peephole, landed. Then the load-reuse optimization for Quake's
   float-heavy code (M1.5).
2. A per-program name for the shared runtime module.
3. Key input for Quake in the editor.
4. M2: `eden_gpu_*` imports for a GLQuake-style capture layer.
