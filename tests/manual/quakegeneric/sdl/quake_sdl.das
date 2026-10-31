options gen2

// daslang host of the SDL3 harness: runs the c2das translation of
// quakegeneric (the case `quakegeneric-demo1-std`'s units plus the host API
// `qg_host.c`, translated with `--strict --libc std --module-layout source`)
// as an SDL3 window application.  dasQUAKE (`scripts/export_dasquake.py`)
// stages it beside its `quake/` modules, with the runtime module's name
// rewritten; the calls below are unqualified.
//
//   daslang [-jit] quake_sdl.das -- [--timedemo [--frames N] [--no-present]] [--fullscreen] <basedir>
//
// `<basedir>` holds `id1/pak0.pak`.
//
// Play (the default): `quake -basedir <basedir>` on the host's real clock.
// The pak's attract loop plays demo1, demo2 and demo3 at their recorded
// speed; any key opens the menu, where New Game starts the shareware episode.
// Keyboard and mouse go to the engine (`qg_host_key`, `qg_host_mouse`); the
// mouse is captured (relative mode, mouse look) only while a game is being
// played with no menu or console up.  The presentation waits for vsync.
// Closing the window ends the run.
//
// `--timedemo`: the corpus entry `quake_entry.c`: `+timedemo demo1` on the
// virtual 1/64 s tick until N frames are recorded (default 100, the case's
// count; demo1 records 919), no vsync, then `frame[i]=<hash>` per frame and `frames=N` (the case's
// expected stdout), then `setup_us`, `loop_frames`, `loop_us` and `fps`.
// `--no-present` drops SDL video (no window, upload or present).
require c2da_runtime
require qg_host
require math
require sdl3
require strings

let HASH_LIMIT = 4096 // the platform layer's QG_MAX_FRAMES
let WINDOW_SCALE = 3
let MIN_FRAME_SECONDS = 1.0lf / 72.0lf // the engine's frame-rate cap (Host_FilterTime)

// `quakekeys.h`
let K_TAB = 9
let K_ENTER = 13
let K_ESCAPE = 27
let K_BACKSPACE = 127
let K_UPARROW = 128
let K_DOWNARROW = 129
let K_LEFTARROW = 130
let K_RIGHTARROW = 131
let K_ALT = 132
let K_CTRL = 133
let K_SHIFT = 134
let K_F1 = 135
let K_INS = 147
let K_DEL = 148
let K_PGDN = 149
let K_PGUP = 150
let K_HOME = 151
let K_END = 152
let K_PAUSE = 255
let K_MOUSE1 = 200
let K_MOUSE2 = 201
let K_MOUSE3 = 202
let K_MWHEELUP = 239
let K_MWHEELDOWN = 240

// An SDL3 keycode as a `quakekeys.h` code, 0 for a key Quake has no code for.
// SDL3 gives printable keys their lower-case ASCII code, as Quake does.
def quake_key(k : uint) : int {
    if (k == SDLK_TAB) {
        return K_TAB
    } elif (k == SDLK_RETURN || k == SDLK_KP_ENTER) {
        return K_ENTER
    } elif (k == SDLK_ESCAPE) {
        return K_ESCAPE
    } elif (k == SDLK_BACKSPACE) {
        return K_BACKSPACE
    } elif (k == SDLK_UP) {
        return K_UPARROW
    } elif (k == SDLK_DOWN) {
        return K_DOWNARROW
    } elif (k == SDLK_LEFT) {
        return K_LEFTARROW
    } elif (k == SDLK_RIGHT) {
        return K_RIGHTARROW
    } elif (k == SDLK_LALT || k == SDLK_RALT) {
        return K_ALT
    } elif (k == SDLK_LCTRL || k == SDLK_RCTRL) {
        return K_CTRL
    } elif (k == SDLK_LSHIFT || k == SDLK_RSHIFT) {
        return K_SHIFT
    } elif (k >= SDLK_F1 && k <= SDLK_F12) {
        return K_F1 + int(k - SDLK_F1)
    } elif (k == SDLK_INSERT) {
        return K_INS
    } elif (k == SDLK_DELETE) {
        return K_DEL
    } elif (k == SDLK_PAGEDOWN) {
        return K_PGDN
    } elif (k == SDLK_PAGEUP) {
        return K_PGUP
    } elif (k == SDLK_HOME) {
        return K_HOME
    } elif (k == SDLK_END) {
        return K_END
    } elif (k == SDLK_PAUSE) {
        return K_PAUSE
    } elif (k > 0u && k < 128u) {
        return int(k)
    }
    return 0
}

def mouse_key(button : uint8) : int {
    if (button == uint8(SDL_BUTTON_LEFT)) {
        return K_MOUSE1
    } elif (button == uint8(SDL_BUTTON_RIGHT)) {
        return K_MOUSE2
    } elif (button == uint8(SDL_BUTTON_MIDDLE)) {
        return K_MOUSE3
    }
    return 0
}

[export]
def main() : int {
    var present = true
    var timedemo = false
    var fullscreen = false
    var frame_limit = 100
    var basedir = ""
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
        } elif (args[i] == "--timedemo") {
            timedemo = true
        } elif (args[i] == "--fullscreen") {
            fullscreen = true
        } elif (args[i] == "--frames" && i + 1 < length(args)) {
            i++
            frame_limit = to_int(args[i])
        } else {
            basedir = args[i]
        }
        i++
    }
    if (empty(basedir)) {
        print("load=0\n")
        return 2
    }
    if (!timedemo) {
        present = true
    }
    // The engine keeps the path (C `char *`, through `com_argv`) for the
    // whole run: a zero-terminated copy that lives until `main` returns, with
    // '/' separators (the engine joins paths with '/', which Windows' file
    // API accepts).
    var basedir_c : array<uint8>
    for (ch in basedir) {
        basedir_c |> push(ch == '\\' ? uint8('/') : uint8(ch))
    }
    basedir_c |> push(uint8(0))

    let width = qg_host_width()
    let height = qg_host_height()
    var window : SDL_Window?
    var renderer : SDL_Renderer?
    var texture : SDL_Texture?
    unsafe {
        if (present) {
            if (!SDL_Init(SDL_INIT_VIDEO)) {
                print("SDL_Init failed: {SDL_GetError()}\n")
                return 1
            }
            let flags = fullscreen ? (SDL_WINDOW_RESIZABLE | SDL_WINDOW_FULLSCREEN) : SDL_WINDOW_RESIZABLE
            window = SDL_CreateWindow("dasQUAKE (daslang + dasSDL3)", width * WINDOW_SCALE, height * WINDOW_SCALE, flags)
            if (window == null) {
                print("SDL_CreateWindow failed: {SDL_GetError()}\n")
                return 1
            }
            renderer = SDL_CreateRenderer(window, "") // an empty das string is passed as NULL: SDL picks the default
            if (renderer == null) {
                print("SDL_CreateRenderer failed: {SDL_GetError()}\n")
                return 1
            }
            SDL_SetRenderVSync(renderer, timedemo ? 0 : 1)
            // Any window size shows the whole 4:3 screen, letterboxed.
            SDL_SetRenderLogicalPresentation(renderer, width, height, SDL_RendererLogicalPresentation.LOGICAL_PRESENTATION_LETTERBOX)
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

        // The translated runtime reserves its heap on the first allocation; do
        // it before the timer (C's heap exists before main).
        c2da_rt_init_heap()
        let freq = double(SDL_GetPerformanceFrequency())
        let t0 = SDL_GetPerformanceCounter()
        if (timedemo) {
            qg_host_start_timedemo(reinterpret<int8?>(addr(basedir_c[0])))
        } else {
            qg_host_start_play(reinterpret<int8?>(addr(basedir_c[0])))
        }
        let t1 = SDL_GetPerformanceCounter()
        let first_frame = qg_host_frame_count()
        var running = true
        var event = SDL_MakeEvent()
        var shown = 0
        var last = t1
        var captured = false
        var mouse_dx = 0.0
        var mouse_dy = 0.0
        // Startup and the level load record no frame on some ticks: a bound.
        let tick_limit = 20 * frame_limit + 2000
        var ticks = 0
        while (running && (!timedemo || (qg_host_frame_count() < frame_limit && ticks < tick_limit))) {
            if (present) {
                while (SDL_PollEvent(addr(event))) {
                    let kind = event.event_type
                    if (SDL_EventIsQuit(event)) {
                        running = false
                    } elif (timedemo) {
                        if (SDL_EventIsEscape(event)) {
                            running = false
                        }
                    } elif (kind == SDL_EVENT_KEY_DOWN || kind == SDL_EVENT_KEY_UP) {
                        var key : SDL_KeyboardEvent
                        SDL_ReadKeyEvent(event, key)
                        let qkey = quake_key(key.key)
                        if (qkey != 0) {
                            qg_host_key(kind == SDL_EVENT_KEY_DOWN ? 1 : 0, qkey)
                        }
                    } elif (kind == SDL_EVENT_MOUSE_BUTTON_DOWN || kind == SDL_EVENT_MOUSE_BUTTON_UP) {
                        var button : SDL_MouseButtonEvent
                        SDL_ReadMouseButtonEvent(event, button)
                        let qkey = mouse_key(button.button)
                        if (qkey != 0) {
                            qg_host_key(kind == SDL_EVENT_MOUSE_BUTTON_DOWN ? 1 : 0, qkey)
                        }
                    } elif (kind == SDL_EVENT_MOUSE_WHEEL) {
                        var wheel : SDL_MouseWheelEvent
                        SDL_ReadMouseWheelEvent(event, wheel)
                        if (wheel.y != 0.0) {
                            let qkey = wheel.y > 0.0 ? K_MWHEELUP : K_MWHEELDOWN
                            qg_host_key(1, qkey)
                            qg_host_key(0, qkey)
                        }
                    } elif (kind == SDL_EVENT_MOUSE_MOTION && captured) {
                        var motion : SDL_MouseMotionEvent
                        SDL_ReadMouseMotionEvent(event, motion)
                        mouse_dx += motion.xrel
                        mouse_dy += motion.yrel
                    }
                }
            }
            if (timedemo) {
                qg_host_tick_timedemo()
                ticks++
            } else {
                let mx = int(mouse_dx)
                let my = int(mouse_dy)
                if (mx != 0 || my != 0) {
                    qg_host_mouse(mx, my)
                    mouse_dx -= float(mx)
                    mouse_dy -= float(my)
                }
                let now = SDL_GetPerformanceCounter()
                qg_host_tick(double(now - last) / freq)
                last = now
                let in_game = qg_host_in_game() != 0
                if (in_game != captured) {
                    captured = in_game
                    SDL_SetWindowRelativeMouseMode(window, captured)
                    mouse_dx = 0.0
                    mouse_dy = 0.0
                }
            }
            let pixels = qg_host_frame_argb()
            if (present) {
                SDL_UpdateTexture(texture, null, pixels, width * 4)
                SDL_RenderClear(renderer)
                SDL_RenderTexture(renderer, texture, null, null)
                SDL_RenderPresent(renderer)
                shown++
            }
            if (!timedemo) {
                // Without vsync (e.g. SDL_VIDEODRIVER=dummy) do not spin
                // faster than the engine renders.
                let spent = double(SDL_GetPerformanceCounter() - last) / freq
                if (spent < MIN_FRAME_SECONDS) {
                    SDL_Delay(uint((MIN_FRAME_SECONDS - spent) * 1000.0lf))
                }
            }
        }
        let t2 = SDL_GetPerformanceCounter()

        let frames = qg_host_frame_count()
        let loop_frames = frames - first_frame
        let loop_s = double(t2 - t1) / freq
        if (timedemo) {
            for (f in range(min(frames, HASH_LIMIT))) {
                print("frame[{f}]={qg_host_frame_hash(f)}\n")
            }
            print("frames={frames}\n")
            if (frames < frame_limit) {
                // demo1 records 919 frames, then the client stops rendering
                print("short of {frame_limit} frames after {ticks} ticks\n")
            }
        } else {
            print("shown={shown}\n")
        }
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
    delete basedir_c
    return 0
}
