options gen2
options indenting = 4

// eden_gpu ABI v0: the host side of the two host imports of
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
// - eden_gpu_present(pixels, w, h): the w*h 8-bit screen through the lookup
//   table into the bitmap, then update_texture on the bound texture.
//
// The player binds its texture with eden_gpu_bind before the first frame;
// until then present only converts.  v0 converts on the CPU; the palette
// lookup in a pixel shader is the next step.
module eden_gpu public

require engine.core

var private g_lut : uint[256]
var private g_bitmap : Bitmap
var private g_width : int = 0
var private g_height : int = 0
var private g_texture : TextureId
var private g_bound : bool = false
var private g_presents : int = 0
var private g_palettes : int = 0
var private g_convertMs : double = 0.0lf
var private g_uploadMs : double = 0.0lf

// the texture eden_gpu_present updates (w x h, RGBA)
def public eden_gpu_bind(texture : TextureId) {
    g_texture = texture
    g_bound = true
}

def public eden_gpu_palette(mem : array<uint8>; rgb768 : int) {
    for (i in range(256)) {
        let p = rgb768 + i * 3
        g_lut[i] = 0xff000000u | uint(mem[p]) | (uint(mem[p + 1]) << 8u) | (uint(mem[p + 2]) << 16u)
    }
    g_palettes++
}

def public eden_gpu_present(mem : array<uint8>; pixels : int; w : int; h : int) {
    let t0 = ref_time_ticks()
    if (w != g_width || h != g_height) {
        g_width = w
        g_height = h
        g_bitmap <- Bitmap(w, h)
    }
    for (i in range(w * h)) {
        g_bitmap.pixels[i] = g_lut[int(mem[pixels + i])]
    }
    g_convertMs += double(get_time_nsec(t0)) / 1000000.0lf
    g_presents++
    if (g_bound) {
        let t1 = ref_time_ticks()
        update_texture(g_bitmap, g_texture)
        g_uploadMs += double(get_time_nsec(t1)) / 1000000.0lf
    }
}

// presents and palette calls so far, and the average convert / upload ms
def public eden_gpu_report : string {
    let n = double(max(g_presents, 1))
    let c = int(g_convertMs / n * 1000.0lf)
    let u = int(g_uploadMs / n * 1000.0lf)
    return "eden_gpu: presents {g_presents}, palettes {g_palettes}, convert {c} us/present, upload {u} us/present"
}
