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
     `DotProduct`/`VectorMA` macros reload the same fields;
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
