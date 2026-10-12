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

// presents and palette calls so far, and the average convert / upload ms
def public eden_gpu_report : string {
    let n = double(max(g_presents, 1))
    let c = int(g_convertMs / n * 1000.0lf)
    let u = int(g_uploadMs / n * 1000.0lf)
    let path = g_shader ? "v1 shader" : "v0 cpu"
    return "eden_gpu ({path}): presents {g_presents}, palettes {g_palettes} ({g_palUploads} uploaded), convert {c} us/present, upload {u} us/present"
}
