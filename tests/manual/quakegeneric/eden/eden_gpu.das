options gen2
options indenting = 4

// eden_gpu ABI v0/v1: the host side of the two host imports of
// src/qg_eden_gpu.c (declared in src/qg_eden_gpu.h), bound by the translator
// with `--host-import-prefix eden_gpu_=eden_gpu`.  Hand-written host code, not
// translated output.
//
// Under --memory-model linear every import receives the heap `c2da_mem` by
// reference as an extra first argument and a C pointer as an int offset into
// it.  This module requires neither the translated modules nor the runtime,
// so no require cycle forms.
//
// - eden_gpu_palette(rgb768): the engine's 256 RGB triples into a 256-entry
//   RGBA lookup table (the pointer is valid only during the call).
// - eden_gpu_present(pixels, w, h): the w*h 8-bit screen to the GPU.
//
// Two paths, chosen by eden_gpu_material before the first frame:
// - v1 (shader, the default): present packs the indices four per RGBA8 texel
//   (a w/4 x h texture, no palette lookup) and uploads it; palette uploads a
//   256x1 RGBA texture only when the colours change; the pixel shader
//   eden/quake_palette.shader does the lookup.
// - v0 (cpu): present converts through the table into a w x h RGBA bitmap
//   on the CPU and uploads that to a pixel_art material.
module eden_gpu public

require engine.core
require daslib/math_bits

// the shader, installed next to this module
let private PALETTE_SHADER = "modules/dasquake_gpu/quake_palette.shader"

var private g_lut : uint[256]
var private g_bitmap : Bitmap
var private g_palBitmap : Bitmap
var private g_width : int = 0
var private g_height : int = 0
var private g_texture : TextureId
var private g_palTexture : TextureId
var private g_bound : bool = false
var private g_shader : bool = false
var private g_palDirty : bool = true
var private g_presents : int = 0
var private g_palettes : int = 0
var private g_palUploads : int = 0
var private g_convertMs : double = 0.0lf
var private g_uploadMs : double = 0.0lf

// the texture eden_gpu_present updates (w x h, RGBA) on the v0 CPU path
def public eden_gpu_bind(texture : TextureId) {
    g_texture = texture
    g_bound = true
    g_shader = false
}

// creates the screen textures and returns the material that shows them.
// `shader`: v1, the palette lookup in quake_palette.shader (w must be a
// multiple of 4); otherwise v0, the CPU conversion into a pixel_art material
def public eden_gpu_material(w : int; h : int; shader : bool) : MaterialId {
    g_width = w
    g_height = h
    if (!shader || w % 4 != 0) {
        g_bitmap <- Bitmap(w, h)
        var blank : array<uint>
        resize(blank, w * h)
        let tex = create_texture(w, h, blank, TextureDeclaration(
            filter = TextureFilter.Point,
            generateMipLevels = false,
            addressing = TextureAddress.Clamp
        ))
        eden_gpu_bind(tex)
        return create_material(MaterialImport(shaderName = "pixel_art", diffuse = tex))
    }
    g_bitmap <- Bitmap(w / 4, h)
    g_palBitmap <- Bitmap(256, 1)
    var blank : array<uint>
    resize(blank, w / 4 * h)
    // indices are data: no sRGB decode, no filtering, no mips
    g_texture = create_texture(w / 4, h, blank, TextureDeclaration(
        filter = TextureFilter.Point,
        generateMipLevels = false,
        addressing = TextureAddress.Clamp,
        sRGB = false
    ))
    var pal : array<uint>
    resize(pal, 256)
    g_palTexture = create_texture(256, 1, pal, TextureDeclaration(
        filter = TextureFilter.Point,
        generateMipLevels = false,
        addressing = TextureAddress.Clamp
    ))
    g_bound = true
    g_shader = true
    g_palDirty = true
    var props = MaterialProperties("indexTex", g_texture)
    props |> add("paletteTex", g_palTexture)
    props |> add("packedWidth", float(w / 4))
    return create_material(MaterialImport(shaderId = request_shader(PALETTE_SHADER), properties <- props))
}

def public eden_gpu_palette(mem : array<uint8>; rgb768 : int) {
    for (i in range(256)) {
        let p = rgb768 + i * 3
        // a Bitmap texel is 0xAARRGGBB (measured: R in the low byte showed
        // Quake's brown console blue)
        let c = 0xff000000u | (uint(mem[p]) << 16u) | (uint(mem[p + 1]) << 8u) | uint(mem[p + 2])
        if (g_lut[i] != c) {
            g_lut[i] = c
            g_palDirty = true
        }
    }
    g_palettes++
}

def public eden_gpu_present(mem : array<uint8>; pixels : int; w : int; h : int) {
    if (w != g_width || h != g_height) {
        // no material for this size yet: nothing is shown
        return
    }
    let t0 = ref_time_ticks()
    if (g_shader) {
        // four indices per texel; byte k of the group is byte k of the
        // 0xAARRGGBB texel, so the channels B G R A (quake_palette.shader)
        for (i in range(w * h / 4)) {
            let p = pixels + i * 4
            g_bitmap.pixels[i] = uint(mem[p]) | (uint(mem[p + 1]) << 8u) | (uint(mem[p + 2]) << 16u) | (uint(mem[p + 3]) << 24u)
        }
    } else {
        for (i in range(w * h)) {
            g_bitmap.pixels[i] = g_lut[int(mem[pixels + i])]
        }
    }
    g_convertMs += double(get_time_nsec(t0)) / 1000000.0lf
    g_presents++
    if (g_bound) {
        let t1 = ref_time_ticks()
        if (g_shader && g_palDirty) {
            g_palDirty = false
            for (i in range(256)) {
                g_palBitmap.pixels[i] = g_lut[i]
            }
            update_texture(g_palBitmap, g_palTexture)
            g_palUploads++
        }
        update_texture(g_bitmap, g_texture)
        g_uploadMs += double(get_time_nsec(t1)) / 1000000.0lf
    }
}

// ---- M2a: the world model as static Eden meshes ----
//
// Quake is right-handed, Z up, in inches-ish units; Eden is Y up, Z forward.
// Quake (x fwd, y left, z up) -> Eden (-y, z, x) * WORLD_SCALE, placed at
// WORLD_ORIGIN, far above the screen quad the orthographic camera shows.
let private WORLD_SCALE = 1.0 / 32.0
let private WORLD_ORIGIN = float3(0.0, 1000.0, 0.0)

var private g_worldRoot : NodeId
var private g_worldCamera : NodeId
var private g_worldNodes : array<NodeId>
var private g_worldMaterials : array<MaterialId>
var private g_worldTris : int = 0
var private g_worldVerts : int = 0
var private g_worldMeshes : int = 0
var private g_worldTextures : int = 0
var private g_worldStart : int64 = 0l
var private g_worldBuildMs : double = 0.0lf
var private g_worldHostMs : double = 0.0lf
var private g_cameraCalls : int = 0
var private g_cameraMs : double = 0.0lf
var private g_worldViewport = float4(0.5, 0.0, 0.5, 1.0)

def private quake_dir(x, y, z : float) : float3 {
    return float3(-y, z, x)
}

def private ld_f32(mem : array<uint8>; a : int) : float {
    return uint_bits_to_float(uint(mem[a]) | (uint(mem[a + 1]) << 8u) | (uint(mem[a + 2]) << 16u) | (uint(mem[a + 3]) << 24u))
}

def private ld_i32(mem : array<uint8>; a : int) : int {
    return int(uint(mem[a]) | (uint(mem[a + 1]) << 8u) | (uint(mem[a + 2]) << 16u) | (uint(mem[a + 3]) << 24u))
}

// the viewport of the GPU world camera (default: the right half)
def public eden_gpu_world_viewport(v : float4) {
    g_worldViewport = v
}

// shows or hides the GPU world and its camera (for an A/B of the frame cost)
def public eden_gpu_world_show(on : bool) {
    if (g_worldRoot.isAlive) {
        g_worldRoot.isActive = on
    }
    if (g_worldCamera.isAlive) {
        g_worldCamera.isActive = on
    }
}

def public eden_gpu_world_begin(mem : array<uint8>; ntextures : int) {
    g_worldStart = ref_time_ticks()
    g_worldHostMs = 0.0lf
    for (n in g_worldNodes) {
        if (n.isAlive) {
            remove_node(n)
        }
    }
    clear(g_worldNodes)
    clear(g_worldMaterials)
    resize(g_worldMaterials, ntextures)
    g_worldTris = 0
    g_worldVerts = 0
    g_worldMeshes = 0
    g_worldTextures = 0
    if (!g_worldRoot.isAlive) {
        g_worldRoot = create_node(NodeData(name = "quake_world", position = WORLD_ORIGIN))
    }
}

// one miptex (w*h palette indices) into a texture and a lit, double-sided material
def public eden_gpu_world_texture(mem : array<uint8>; tex : int; pixels : int; w : int; h : int; rgb768 : int) {
    let t0 = ref_time_ticks()
    if (tex < 0 || tex >= length(g_worldMaterials) || w <= 0 || h <= 0) {
        return
    }
    var lut : uint[256]
    for (i in range(256)) {
        let p = rgb768 + i * 3
        lut[i] = 0xff000000u | (uint(mem[p]) << 16u) | (uint(mem[p + 1]) << 8u) | uint(mem[p + 2])
    }
    var texels : array<uint>
    resize(texels, w * h)
    for (i in range(w * h)) {
        texels[i] = lut[int(mem[pixels + i])]
    }
    let id = create_texture(w, h, texels, TextureDeclaration(
        filter = TextureFilter.Point,
        generateMipLevels = true,
        addressing = TextureAddress.Wrap
    ))
    g_worldMaterials[tex] = create_material(MaterialImport(diffuse = id, faceCullMode = FaceCullMode.None))
    g_worldTextures++
    g_worldHostMs += double(get_time_nsec(t0)) / 1000000.0lf
}

// a batch of triangles of texture `tex` into one static mesh node
def public eden_gpu_world_mesh(mem : array<uint8>; tex : int; verts : int; nverts : int; idx : int; nidx : int) {
    let t0 = ref_time_ticks()
    if (tex < 0 || tex >= length(g_worldMaterials) || nverts <= 0 || nidx < 3) {
        return
    }
    var positions : array<float3>
    var normals : array<float3>
    var uvs : array<float2>
    var tris : array<uint3>
    resize(positions, nverts)
    resize(normals, nverts)
    resize(uvs, nverts)
    resize(tris, nidx / 3)
    for (i in range(nverts)) {
        let p = verts + i * 32
        positions[i] = quake_dir(ld_f32(mem, p), ld_f32(mem, p + 4), ld_f32(mem, p + 8)) * WORLD_SCALE
        normals[i] = quake_dir(ld_f32(mem, p + 12), ld_f32(mem, p + 16), ld_f32(mem, p + 20))
        uvs[i] = float2(ld_f32(mem, p + 24), ld_f32(mem, p + 28))
    }
    for (i in range(nidx / 3)) {
        let p = idx + i * 12
        tris[i] = uint3(uint(ld_i32(mem, p)), uint(ld_i32(mem, p + 4)), uint(ld_i32(mem, p + 8)))
    }
    let mesh = create_mesh(MeshGeometry(vertices <- positions, normals <- normals, uv <- uvs, triangles <- tris))
    let node = create_node(NodeData(name = "quake_world_{tex}", parent = g_worldRoot))
    add_component(node, new Mesh(meshId = mesh, materialId = g_worldMaterials[tex]))
    g_worldNodes |> push(node)
    g_worldTris += nidx / 3
    g_worldVerts += nverts
    g_worldMeshes++
    g_worldHostMs += double(get_time_nsec(t0)) / 1000000.0lf
}

def public eden_gpu_world_end(mem : array<uint8>) {
    g_worldBuildMs = double(get_time_nsec(g_worldStart)) / 1000000.0lf
    if (!g_worldCamera.isAlive) {
        g_worldCamera = create_node(NodeData(name = "quake_world_camera", position = WORLD_ORIGIN))
        add_component(g_worldCamera, new Camera(fovAxis = FovAxis.Horizontal, fov = PI * 0.5, znear = 0.05, zfar = 500.0, viewport = g_worldViewport))
        let sun = create_node(NodeData(name = "quake_world_sun", rotation = quat4(float3(PI / 3.0, PI / 5.0, 0.0))))
        add_component(sun, new DirectionalLight())
    }
    print("[eden_gpu] world: {g_worldTextures} textures, {g_worldMeshes} meshes, {g_worldTris} triangles, {g_worldVerts} vertices; build {fmt2(g_worldBuildMs)} ms (host {fmt2(g_worldHostMs)} ms, C walk + call overhead the rest)\n")
}

// the Quake view (r_refdef) onto the GPU world camera
def public eden_gpu_camera(mem : array<uint8>; x, y, z, pitch, yaw, roll, fov_x, fov_y : float) {
    let t0 = ref_time_ticks()
    if (g_worldCamera.isAlive) {
        // Quake's AngleVectors
        let d2r = PI / 180.0
        let sy = sin(yaw * d2r)
        let cy = cos(yaw * d2r)
        let sp = sin(pitch * d2r)
        let cp = cos(pitch * d2r)
        let sr = sin(roll * d2r)
        let cr = cos(roll * d2r)
        let fwd = quake_dir(cp * cy, cp * sy, -sp)
        let up = quake_dir(cr * sp * cy + sr * sy, cr * sp * sy - sr * cy, cr * cp)
        g_worldCamera.localPosition = WORLD_ORIGIN + quake_dir(x, y, z) * WORLD_SCALE
        g_worldCamera.localRotation = make_quat_from_basis_zy(fwd, up)
        var cam = get_component(g_worldCamera, type<Camera>)
        if (cam != null) {
            // the horizontal fov: the viewport's aspect differs from 320x240
            cam.fov = fov_x * d2r
        }
    }
    g_cameraCalls++
    g_cameraMs += double(get_time_nsec(t0)) / 1000000.0lf
}

def private fmt2(v : double) : string {
    let c = int(v * 100.0lf + 0.5lf)
    let f = c % 100
    return "{c / 100}.{f < 10 ? "0" : ""}{f}"
}

// presents and palette calls so far, and the average convert / upload ms
def public eden_gpu_report : string {
    let n = double(max(g_presents, 1))
    let c = int(g_convertMs / n * 1000.0lf)
    let u = int(g_uploadMs / n * 1000.0lf)
    let path = g_shader ? "v1 shader" : "v0 cpu"
    var res = "eden_gpu ({path}): presents {g_presents}, palettes {g_palettes} ({g_palUploads} uploaded), convert {c} us/present, upload {u} us/present"
    if (g_worldMeshes > 0) {
        let cu = int(g_cameraMs / double(max(g_cameraCalls, 1)) * 1000.0lf)
        res = "{res}; world {g_worldTris} tris in {g_worldMeshes} meshes, build {fmt2(g_worldBuildMs)} ms, camera {g_cameraCalls} calls {cu} us/call"
    }
    return res
}
