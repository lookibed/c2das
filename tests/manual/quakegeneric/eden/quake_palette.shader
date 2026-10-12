require engine.render.shader_dsl

// eden_gpu ABI v1: Quake's 8-bit palette lookup on the GPU.  Hand-written,
// not translated output; eden/eden_gpu.das creates the material.
//
// indexTex: the 320x240 8-bit screen packed four indices per RGBA8 texel
// (80x240, byte i of a row in byte i % 4 of a texel), point filtered, not
// sRGB, no mips.  paletteTex: the 256x1 RGBA palette, point filtered.
// Screen pixel x lies in texel x / 4 and channel x % 4; the index (a byte
// normalized to 0..1) is the u of a dependent read from the palette.
var {
    indexTex : Sampler2D = Sampler2D("%builtin_package/logo.png")
    paletteTex : Sampler2D = Sampler2D("%builtin_package/logo.png")
    packedWidth = 80.0
}

[pixel_shader]
def quake_palette(inp : UnlitInput) {
    // a Bitmap texel is 0xAARRGGBB, so the group's bytes 0 1 2 3 are the
    // channels B G R A: .zyxw puts them in byte order
    let packed = tex2d(indexTex, inp.uv).zyxw
    // the channel of this pixel in its texel: 0, 1, 2 or 3
    let ch = floor(frac(inp.uv.x * packedWidth) * 4.0)
    let m1 = step(0.5, ch)
    let m2 = step(1.5, ch)
    let m3 = step(2.5, ch)
    let mask = float4(1.0 - m1, m1 - m2, m2 - m3, m3)
    let index = dot(packed, mask)
    let u = index * (255.0 / 256.0) + 0.5 / 256.0
    let rgb = tex2d(paletteTex, float2(u, 0.5)).xyz
    return UnlitOutput(color = rgb)
}
