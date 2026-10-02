options gen2

// daslang host of the SDL3 harness: runs the c2das translation of
// `doom_host_all.c` (the doomgeneric corpus engine, its headless platform
// layer and the host API `dg_host.c`; translated with `--strict --libc std`
// into `doom_host_all.das`, staged beside this file) as an SDL3 window
// application and measures its frame rate.  It is `doom_sdl_host.c` line for
// line in the measured loop: the C host does the same SDL calls around the
// natively compiled engine.
//
//   daslang [-jit] doom_sdl.das -- [--no-present] [--frames N] <doom1.wad>
//
// Every option, every printed line and its meaning are those of
// `doom_sdl_host.c` (see there): `setup_us` times the engine's start-up
// (`dg_host_start`, the first 41 frames included), the loop runs one engine
// tic and frame, the palette conversion to ARGB8888, the texture upload and
// the present per iteration until the engine has rendered N frames (default
// 1000), `fps` = loop frames / loop seconds; `--no-present` drops SDL video
// (no window, events, upload or present).  `SDL_VIDEODRIVER=dummy` runs the
// window path headless.  The per-frame hashes are the platform layer's, so
// the first 70 are the corpus oracle's.
require doom_host_all
require math
require sdl3
require strings

let HASH_LIMIT = 4096 // the platform layer's DG_MAX_FRAMES
let WINDOW_SCALE = 3

[export]
def main() : int {
    var present = true
    var frame_limit = 1000
    var iwad = ""
    let args <- get_command_line_arguments()
    var first = length(args)
    for (i in range(length(args))) {
        if (args[i] == "--") {
            first = i + 1
            break
        }
    }
    var i = first
    while (i < length(args)) {
        if (args[i] == "--no-present") {
            present = false
        } elif (args[i] == "--frames" && i + 1 < length(args)) {
            i++
            frame_limit = to_int(args[i])
        } else {
            iwad = args[i]
        }
        i++
    }
    if (empty(iwad)) {
        print("load=0\n")
        return 2
    }
    // The engine keeps the path (C `char *`, through `myargv`) for the whole
    // run: a zero-terminated copy that lives until `main` returns.  The
    // translation is of the engine's POSIX configuration (`all.c`: `LINUX`,
    // `DIR_SEPARATOR` '/'), which takes the IWAD's file name after the last
    // '/' to identify it (`d_iwad.c`, `IdentifyIWADByName`); a Windows path is
    // handed over with '/' separators, which Windows' file API accepts, so the
    // engine sees the same file name as the natively built C host does.
    var iwad_c : array<uint8>
    for (ch in iwad) {
        iwad_c |> push(ch == '\\' ? uint8('/') : uint8(ch))
    }
    iwad_c |> push(uint8(0))

    let width = doom_host_all::dg_host_width()
    let height = doom_host_all::dg_host_height()
    var window : SDL_Window?
    var renderer : SDL_Renderer?
    var texture : SDL_Texture?
    unsafe {
        if (present) {
            if (!SDL_Init(SDL_INIT_VIDEO)) {
                print("SDL_Init failed: {SDL_GetError()}\n")
                return 1
            }
            window = SDL_CreateWindow("doomgeneric (daslang)", width * WINDOW_SCALE, height * WINDOW_SCALE, 0ul)
            if (window == null) {
                print("SDL_CreateWindow failed: {SDL_GetError()}\n")
                return 1
            }
            renderer = SDL_CreateRenderer(window, "") // an empty das string is passed as NULL: SDL picks the default
            if (renderer == null) {
                print("SDL_CreateRenderer failed: {SDL_GetError()}\n")
                return 1
            }
            SDL_SetRenderVSync(renderer, 0)
            texture = SDL_CreateTexture(renderer, SDL_PixelFormat.PIXELFORMAT_ARGB8888, SDL_TextureAccess.TEXTUREACCESS_STREAMING, width, height)
            if (texture == null) {
                print("SDL_CreateTexture failed: {SDL_GetError()}\n")
                return 1
            }
            SDL_SetTextureScaleMode(texture, SDL_ScaleMode.SCALEMODE_NEAREST)
            print("video driver: {SDL_GetCurrentVideoDriver()}, renderer: {SDL_GetRendererName(renderer)}\n")
        } else {
            print("video driver: none (--no-present)\n")
        }

        // The translated runtime reserves its heap on the first allocation; do it
        // before the timer, as the corpus bench entries do (C's heap exists before main).
        doom_host_all::c2da_rt_init_heap()
        let freq = double(SDL_GetPerformanceFrequency())
        let t0 = SDL_GetPerformanceCounter()
        doom_host_all::dg_host_start(reinterpret<int8?>(addr(iwad_c[0])))
        let t1 = SDL_GetPerformanceCounter()
        let first_frame = doom_host_all::dg_host_frame_count()
        var running = true
        var event = SDL_MakeEvent()
        while (running && doom_host_all::dg_host_frame_count() < frame_limit) {
            if (present) {
                while (SDL_PollEvent(addr(event))) {
                    if (SDL_EventIsQuit(event) || SDL_EventIsEscape(event)) {
                        running = false
                    }
                }
            }
            doom_host_all::dg_host_tick()
            let pixels = doom_host_all::dg_host_frame_argb()
            if (present) {
                SDL_UpdateTexture(texture, null, pixels, width * 4)
                SDL_RenderClear(renderer)
                SDL_RenderTexture(renderer, texture, null, null)
                SDL_RenderPresent(renderer)
            }
        }
        let t2 = SDL_GetPerformanceCounter()

        let frames = doom_host_all::dg_host_frame_count()
        let loop_frames = frames - first_frame
        let loop_s = double(t2 - t1) / freq
        for (f in range(min(frames, HASH_LIMIT))) {
            print("frame[{f}]={doom_host_all::dg_host_frame_hash(f)}\n")
        }
        print("frames={frames}\n")
        print("setup_us={int64(double(t1 - t0) * 1000000.0lf / freq)}\n")
        print("loop_frames={loop_frames}\n")
        print("loop_us={int64(loop_s * 1000000.0lf)}\n")
        print("fps={fmt(":.1f",loop_s > 0.0lf ? double(loop_frames) / loop_s : 0.0lf)}\n")

        if (present) {
            SDL_DestroyTexture(texture)
            SDL_DestroyRenderer(renderer)
            SDL_DestroyWindow(window)
            SDL_Quit()
        }
    }
    delete iwad_c
    return 0
}
