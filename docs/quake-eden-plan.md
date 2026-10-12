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
  unrolled. Quake's palette lookup runs in one; see "eden_gpu ABI v1" below.
- **A GL 1.x immediate-mode shim** is too costly: about 2 ms per 10 k triangles before the C side
  even runs. A capture layer that turns GLQuake's polygons into static Eden meshes would work
  technically, but it is **out of scope**: the Eden GPU is used for computation only, never for
  scene geometry (decision of 2026-10-12, see Milestones).
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
| M2 | GPU **for computation only**: per-pixel work of the software renderer moved into pixel shaders (palette lookup done; next candidates: surface-cache building, i.e. lightmap × texture, and span texture mapping), through `eden_gpu_*` host imports | — |

**Decision (2026-10-12):** the Eden GPU is used for computation only. c2das does not build Eden
scene geometry (meshes, cameras) from the translated program. A GLQuake-style capture layer is out
of scope, and the M2a mesh prototype was reverted (`b32236340`).

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

This is the call path the `eden_gpu_*` compute ABI uses.

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

### eden_gpu ABI v0 (05:20)

The translated engine now calls the host's display functions itself instead of the host polling
`qge_screen`/`qge_palette` after every tick.

- **C side:** `src/qg_eden_gpu.c`, a copy of `qg_eden_play.c` with the same `qge_*` API.
  `QG_DrawFrame` calls `eden_gpu_present(pixels, 320, 240)` and `QG_SetPalette` calls
  `eden_gpu_palette(rgb768)`. Both are declared `extern` in `src/qg_eden_gpu.h` and defined
  nowhere in C.
- **Translation:** the play units of `quakegeneric-demo1-eden-linear` (with `qg_eden_gpu.c` in
  place of `qg_eden_play.c`), its eden flags, `--module-layout source --public-module
  --runtime-module dasquake_gpu_runtime --host-import-prefix eden_gpu_=eden_gpu`. The
  translator emits `eden_gpu::eden_gpu_present(c2da_mem, qge_screen_pixels, 320, 240)` and
  `require eden_gpu` in the cluster module.
- **Host side:** `eden/eden_gpu.das` (hand-written, module `eden_gpu`). `eden_gpu_palette(mem,
  rgb768)` builds a 256-entry RGBA table. `eden_gpu_present(mem, pixels, w, h)` converts the
  8-bit indices through it into a `Bitmap` and calls `update_texture` on the texture the player
  bound with `eden_gpu_bind`. The palette lookup runs **on the CPU**; the `[pixel_shader]`
  lookup was not attempted in v0.
- **Player:** a copy of the installed `c2das_quake_player.das` (not committed) whose
  `show_frame` only binds the texture. It is installed as `modules/dasquake_gpu/`, with the
  cheat `quake_gpu_play`.

Measured in the editor, attract demos, real time [M]:

| | value |
|---|---|
| fps | 16.2–17.2 (M1 polling build: 17–19) |
| engine frame | 62 ms avg |
| `eden_gpu_present` CPU convert | 1.86 ms per present |
| `update_texture` | 0.44 ms per present |
| presents / palette calls | 239 / 47 after about 15 s |

The frame rate is unchanged within noise, as expected: v0 moves the same conversion from the
player into the import. Screenshot: the demo1 scene renders correctly.

- **One Quake per project:** the GPU install and `modules/dasquake` cannot be loaded together.
  Every engine unit module (`chase_cluster`, `crc`, …) has the same name in both, and the editor
  compiles every `.das` in the project, so it reports `MODULE NAME COLLISION` even when
  `main.das` requires only one of them. `--runtime-module` renames only the runtime. Two
  translations of one program in one project need a module-name prefix in the translator.
- **Next:** pass the 8-bit indices as a texture and do the palette lookup in a `[pixel_shader]`.
  That removes the 1.86 ms convert, but the upload becomes one byte per pixel. Done in v1.

### eden_gpu ABI v1: palette shader (10:15)

The palette lookup now runs in an Eden pixel shader. The C side and the translation are the same
as in v0; only the host changed.

- **`eden/quake_palette.shader`** (hand-written, unlit). It has two `Sampler2D` material
  properties:
  - `indexTex`: the 8-bit screen, four indices per RGBA8 texel (80x240).
  - `paletteTex`: the palette as a 256x1 texture.

  The shader takes the texel at `uv` and picks the channel `floor(frac(uv.x * 80) * 4)`. It does
  this with a `step` mask and a `dot`, because the DSL has no integer or array indexing. It then
  makes a dependent read from the palette at `u = index * 255/256 + 0.5/256`:

  ```
  let packed = tex2d(indexTex, inp.uv).zyxw
  let ch = floor(frac(inp.uv.x * packedWidth) * 4.0)
  let m1 = step(0.5, ch)
  let m2 = step(1.5, ch)
  let m3 = step(2.5, ch)
  let index = dot(packed, float4(1.0 - m1, m1 - m2, m2 - m3, m3))
  let rgb = tex2d(paletteTex, float2(index * (255.0 / 256.0) + 0.5 / 256.0, 0.5)).xyz
  return UnlitOutput(color = rgb)
  ```
- **`eden/eden_gpu.das`** has a new import, `eden_gpu_material(w, h, shader)`, which creates the
  textures and returns the material:
  - The index texture uses `Point` filtering, no mips, `Clamp` addressing and `sRGB = false`.
  - The palette texture uses `Point` filtering, no mips and the default sRGB.
  - The material is `MaterialImport(shaderId = request_shader(...), properties <- props)`, where
    `props` is `MaterialProperties("indexTex", tex)` plus `add("paletteTex", pal)` and
    `add("packedWidth", 80.0)`.

  `eden_gpu_present` packs four bytes into each `uint` texel (19 200 iterations instead of 76 800
  lookups) and calls `update_texture`. `eden_gpu_palette` compares the new colours with the table
  and re-uploads the 256x1 texture only when they changed.
- **Fallback:** the cheat `quake_gpu_play [real|fixed|map] [gpu|cpu]`. `cpu` selects the v0 path:
  the CPU lookup into a 320x240 `pixel_art` material. A width that is not a multiple of 4 also
  falls back to v0.
- **Install:** the editor's asset database has no entry for a `.shader` without a `.meta`, and
  `request_shader` then fails with `asset '...' not found`. The fix is
  `quake_palette.shader.meta`, holding `guid:t="<fresh guid>"` and `assetType:i=12`, next to the
  shader in `modules/dasquake_gpu/`.

**Byte order (a v0 bug, fixed):** a `Bitmap` texel is `0xAARRGGBB`. v0, and the M1 player
`c2das_quake_player.das`, packed R into the low byte, so red and blue were swapped. The brown
console showed blue and the demo1 scene showed teal. The v0 claim that "the demo1 scene renders
correctly" was wrong. All three lookup tables now pack `R << 16 | G << 8 | B`. In the shader, a
packed index texel's bytes 0..3 arrive as channels B G R A, which `.zyxw` puts back in order.

Measured in the editor, attract demos, real time. Both runs used the same editor session and the
same build, and were reported after about 1020 frames [M]:

| | v0 cpu | v1 shader |
|---|---|---|
| present CPU (convert / pack) | 1.71 ms | 1.03 ms |
| `update_texture` per present | 0.31 ms | 0.13 ms (palette re-uploads included) |
| present total | 2.02 ms | 1.16 ms |
| fps | 20.5 | 20.7 |
| palette calls / uploads | 152 / — | 150 / 134 |

- **Present cost:** v1 cuts the per-present CPU cost by 0.86 ms (43 %). The packing loop is
  still 1 ms because it runs in the interpreter: daslang has no safe way to view 4 heap bytes as
  one `uint`. On a 46 ms engine frame the fps change is within noise.
- **Palette uploads:** these are nearly one per palette call. Quake's palette shifts (damage and
  item flashes) change the colours on most calls.
- **Image:** the scene and the status bar match the v0 output. The `UnlitOutput` colour comes
  out slightly lighter than the `pixel_art` material: on JPEG region means the R and G channels
  are 5–16 levels higher and B is equal. This is not an index error, because the geometry and
  text are identical; it is probably the unlit path's tonemapping or exposure.

DSL facts found (all compiled and run):
- A dependent texture read (`tex2d` with a UV computed from another `tex2d`) works.
- A `Sampler2D` property can be bound to a runtime `TextureId` through `MaterialProperties`. The
  `Sampler2D("...")` default is only a placeholder.
- The shader's filtering, mips and sRGB come from the `TextureDeclaration` of `create_texture`.
- `frac`, `floor`, `step` and `dot` exist. `UnlitInput` / `UnlitOutput(color = ...)` work.
- No 8-bit single-channel format turned up. `TextureFormat` lists DXT, ATI, A8R8G8B8 and
  A2R10G10B10. `update_texture` also takes `Texture2Dfloat` and `Texture2Duint` (4 bytes per
  texel), which were not tried. So one byte per index needs the 4-per-texel packing.
- The register and instruction limits were not hit. The shader uses about 15 operations.

### Next

1. The `das-critic-perf` libm peephole, landed. Then the load-reuse optimization for Quake's
   float-heavy code (M1.5).
2. A per-program name for the shared runtime module.
3. Key input for Quake in the editor.
4. M2, compute only: move the software renderer's per-pixel stages into pixel shaders through
   `eden_gpu_*` imports. The palette lookup is done. Next candidates are surface-cache building
   (lightmap × texture) and span texture mapping. No Eden geometry.
