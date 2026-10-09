options gen2
options indenting = 4

module c2das_doom_player shared public

require engine.core
require modules/c2das/doom/doom_eden_play_all
require strings
require math

/*
    c2das_doom_player.das: plays the c2das-translated doomgeneric
    (src/doom_eden_play_all.c translated with the eden flags, installed in an
    EdenSpark project as modules/c2das/doom/doom_eden_play_all.das) in the
    scene. Hand-written host, not translated output; it mirrors the wasm3das
    DgvPlayer (eden/abi_dgv_player.das), without the wasm interpreter: the
    engine is daslang code and its memory is the module's heap `c2da_mem`.

    c2das_doom_start registers the WAD with c2da_eden_add_file, runs dge_init
    (the WAD load and R_Init) and creates a node with a C2dasDoomPlayer
    component. Every on_update the component sends the key edges, runs one
    dge_tick with the clock advanced by one game tic (1000 / 35 ms), and
    copies the 320x200 paletted screen into the texture. When
    is_audio_active(), one stereo stream at dge_audio_rate() plays the sound
    effects dg_eden_sound.c mixed during the update's tics (pump_audio).

    Keys (action set c2das_doom_keys): arrows / W S move and turn, A D and
    , . strafe, Alt + turn strafes, Ctrl or F fire, Space or E use, Shift
    run, Enter, Esc the menu, Backspace back, Y / N answers, Tab the map,
    = - (and numpad + -) map zoom / screen size, 1..7 weapons, F1..F12,
    Pause. No mouse: the C entry (dg_eden_play.c) has keys only.

    Key delivery is level-based: every update each Doom key is down when any
    of its bindings is held (or was tapped within the update), and an edge is
    queued with dge_key only when that state changes, so two bindings of one
    Doom key (W and Up) do not release each other and a missed editor edge
    cannot leave a key stuck. dge_key queues into the C ring (64 events) that
    DG_GetKey drains on the next dge_tick, so edges in updates without a tic
    are kept. Held arrows repeat their key down (menus scroll), like the
    keyboard's autorepeat.
*/


struct private DoomKeyMap {
    action : string
    key : KeyCode
    doomKey : int
}


// doomkeys.h (decimal: hex literals are uint in daslang 0.6.4)
let private DOOM_KEY_RIGHTARROW = 174
let private DOOM_KEY_LEFTARROW = 172
let private DOOM_KEY_UPARROW = 173
let private DOOM_KEY_DOWNARROW = 175
let private DOOM_KEY_STRAFE_L = 160
let private DOOM_KEY_STRAFE_R = 161
let private DOOM_KEY_USE = 162
let private DOOM_KEY_FIRE = 163
let private DOOM_KEY_ESCAPE = 27
let private DOOM_KEY_ENTER = 13
let private DOOM_KEY_TAB = 9
let private DOOM_KEY_RSHIFT = 182
let private DOOM_KEY_RALT = 184
let private DOOM_KEY_BACKSPACE = 127
let private DOOM_KEY_PAUSE = 255
let private DOOM_KEY_EQUALS = 61
let private DOOM_KEY_MINUS = 45
let private DOOM_KEY_F1 = 187

let private SCREEN_W = 320
let private SCREEN_H = 200

// queued stream batches (about one game tic each) above which new audio is dropped
let private AUDIO_MAX_QUEUE = 8

// keyboard autorepeat of held arrows: first repeat, then the period
let private REPEAT_DELAY_MS = 400.0lf
let private REPEAT_PERIOD_MS = 100.0lf

// one Doom key and the state Doom was last told about
struct private DoomKeyState {
    doomKey : int
    held : bool
    downTic : int
    repeats : bool
    since : int64
    lastRepeat : int64
}

var private g_keyMap : array<DoomKeyMap>
var private g_keyStates : array<DoomKeyState>
var private g_keysReady = false
var private g_started = false
var private g_keyEvents = 0


def private add_key(action : string; key : KeyCode; doomKey : int) {
    push(g_keyMap, DoomKeyMap(action = action, key = key, doomKey = doomKey))
    for (s in g_keyStates) {
        if (s.doomKey == doomKey) {
            return
        }
    }
    let arrow = doomKey == DOOM_KEY_UPARROW || doomKey == DOOM_KEY_DOWNARROW || doomKey == DOOM_KEY_LEFTARROW || doomKey == DOOM_KEY_RIGHTARROW
    push(g_keyStates, DoomKeyState(doomKey = doomKey, repeats = arrow))
}


def private send_key(pressed : bool; doomKey : int) {
    dge_key(pressed ? 1 : 0, doomKey)
    g_keyEvents++
}


// the level-based key edges of this update (see the header); `tic`: the
// number of tics run so far
def private pump_keys(tic : int) {
    for (s in g_keyStates) {
        var down = false
        var tapped = false
        for (m in g_keyMap) {
            if (m.doomKey == s.doomKey) {
                if (is_action_pressed(m.action, ModifierMatchMode.Weak)) {
                    down = true
                }
                if (is_action_just_pressed(m.action, ModifierMatchMode.Weak)) {
                    tapped = true
                }
            }
        }
        if ((down || tapped) && !s.held) {
            send_key(true, s.doomKey)
            s.held = true
            s.downTic = tic
            s.since = ref_time_ticks()
            s.lastRepeat = s.since
        } elif (down && s.held && s.repeats) {
            let heldMs = double(get_time_nsec(s.since)) / 1000000.0lf
            if (heldMs >= REPEAT_DELAY_MS && double(get_time_nsec(s.lastRepeat)) / 1000000.0lf >= REPEAT_PERIOD_MS) {
                send_key(true, s.doomKey)
                s.lastRepeat = ref_time_ticks()
            }
        }
        // a key stays down until a tic has seen it, so a tap shorter than
        // one update (or than the real-time cap's gap) still acts in game
        if (!down && s.held && tic > s.downTic) {
            send_key(false, s.doomKey)
            s.held = false
        }
    }
}


def private ensure_keys() {
    if (g_keysReady) {
        return
    }
    g_keysReady = true
    clear(g_keyMap)
    clear(g_keyStates)
    add_key("c2d_up", KeyCode.Up, DOOM_KEY_UPARROW)
    add_key("c2d_w", KeyCode.W, DOOM_KEY_UPARROW)
    add_key("c2d_down", KeyCode.Down, DOOM_KEY_DOWNARROW)
    add_key("c2d_s", KeyCode.S, DOOM_KEY_DOWNARROW)
    add_key("c2d_left", KeyCode.Left, DOOM_KEY_LEFTARROW)
    add_key("c2d_right", KeyCode.Right, DOOM_KEY_RIGHTARROW)
    add_key("c2d_a", KeyCode.A, DOOM_KEY_STRAFE_L)
    add_key("c2d_d", KeyCode.D, DOOM_KEY_STRAFE_R)
    add_key("c2d_comma", KeyCode.Comma, DOOM_KEY_STRAFE_L)
    add_key("c2d_period", KeyCode.Period, DOOM_KEY_STRAFE_R)
    add_key("c2d_lalt", KeyCode.LAlt, DOOM_KEY_RALT)
    add_key("c2d_ralt", KeyCode.RAlt, DOOM_KEY_RALT)
    add_key("c2d_ctrl", KeyCode.LControl, DOOM_KEY_FIRE)
    add_key("c2d_rctrl", KeyCode.RControl, DOOM_KEY_FIRE)
    add_key("c2d_f", KeyCode.F, DOOM_KEY_FIRE)
    add_key("c2d_space", KeyCode.Space, DOOM_KEY_USE)
    add_key("c2d_e", KeyCode.E, DOOM_KEY_USE)
    add_key("c2d_shift", KeyCode.LShift, DOOM_KEY_RSHIFT)
    add_key("c2d_rshift", KeyCode.RShift, DOOM_KEY_RSHIFT)
    add_key("c2d_enter", KeyCode.Return, DOOM_KEY_ENTER)
    add_key("c2d_escape", KeyCode.Escape, DOOM_KEY_ESCAPE)
    add_key("c2d_back", KeyCode.Back, DOOM_KEY_BACKSPACE)
    add_key("c2d_tab", KeyCode.Tab, DOOM_KEY_TAB)
    add_key("c2d_equals", KeyCode.Equals, DOOM_KEY_EQUALS)
    add_key("c2d_minus", KeyCode.Minus, DOOM_KEY_MINUS)
    add_key("c2d_add", KeyCode.Add, DOOM_KEY_EQUALS)
    add_key("c2d_subtract", KeyCode.Subtract, DOOM_KEY_MINUS)
    add_key("c2d_pause", KeyCode.Pause, DOOM_KEY_PAUSE)
    // doomkeys.h: KEY_F1..KEY_F10 = 0x80 + 0x3b.., KEY_F11 / KEY_F12 = 0x80 + 0x57 / 0x58
    add_key("c2d_f1", KeyCode.F1, DOOM_KEY_F1)
    add_key("c2d_f2", KeyCode.F2, DOOM_KEY_F1 + 1)
    add_key("c2d_f3", KeyCode.F3, DOOM_KEY_F1 + 2)
    add_key("c2d_f4", KeyCode.F4, DOOM_KEY_F1 + 3)
    add_key("c2d_f5", KeyCode.F5, DOOM_KEY_F1 + 4)
    add_key("c2d_f6", KeyCode.F6, DOOM_KEY_F1 + 5)
    add_key("c2d_f7", KeyCode.F7, DOOM_KEY_F1 + 6)
    add_key("c2d_f8", KeyCode.F8, DOOM_KEY_F1 + 7)
    add_key("c2d_f9", KeyCode.F9, DOOM_KEY_F1 + 8)
    add_key("c2d_f10", KeyCode.F10, DOOM_KEY_F1 + 9)
    add_key("c2d_f11", KeyCode.F11, 128 + 87)
    add_key("c2d_f12", KeyCode.F12, 128 + 88)
    add_key("c2d_y", KeyCode.Y, int('y'))
    add_key("c2d_n", KeyCode.N, int('n'))
    add_key("c2d_1", KeyCode._1, int('1'))
    add_key("c2d_2", KeyCode._2, int('2'))
    add_key("c2d_3", KeyCode._3, int('3'))
    add_key("c2d_4", KeyCode._4, int('4'))
    add_key("c2d_5", KeyCode._5, int('5'))
    add_key("c2d_6", KeyCode._6, int('6'))
    add_key("c2d_7", KeyCode._7, int('7'))
    var keys : ActionSet
    for (m in g_keyMap) {
        var buttons : array<KeyboardButtonInput>
        push(buttons, KeyboardButtonInput(idx = m.key))
        keys[m.action] = Action(buttonActions = ButtonAction(keyboardButtons <- buttons))
    }
    add_and_activate_action_set("c2das_doom_keys", keys)
}


// `v` with two decimals
def private fmt(v : double) : string {
    let c = int(v * 100.0lf + 0.5lf)
    let f = c % 100
    return "{c / 100}.{f < 10 ? "0" : ""}{f}"
}


class C2dasDoomPlayer : Component {
    screen : NodeId
    status : NodeId
    texture : TextureId
    bitmap : Bitmap
    lut : uint[256]
    hasTexture : bool = false
    ticks : int = 0
    lastTickMs : double = 0.0lf
    totalTickMs : double = 0.0lf
    lastCopyMs : double = 0.0lf
    totalCopyMs : double = 0.0lf
    lastUploadMs : double = 0.0lf
    startTicks : int64 = 0l
    stopped : bool = false
    reason : string
    statusText : string = "c2das doom: starting"
    // false: one tic per editor update, as fast as the editor updates
    realTime : bool = true
    // > 0: `turbo` tics per editor update, one texture update (no real-time cap)
    turbo : int = 0
    // the tic count and the clock the tics/s rate is measured from (doom_bench moves them)
    baseTicks : int = 0
    // editor frame time: the time between two on_update calls
    prevUpdate : int64 = 0l
    lastFrameMs : double = 0.0lf
    avgFrameMs : double = 0.0lf
    // sound effects: one stereo stream at dge_audio_rate(), fed every update
    // with the frames dg_eden_sound.c mixed since the last update
    audioOn : bool = false
    audio : SoundHandle
    audioFrames : int = 0
    audioBatches : int = 0
    audioSkipped : int = 0
    audioQueue : int = 0
    lastAudioMs : double = 0.0lf
    totalAudioMs : double = 0.0lf

    def override on_update {
        if (stopped) {
            return
        }
        if (prevUpdate != 0l) {
            lastFrameMs = double(get_time_nsec(prevUpdate)) / 1000000.0lf
            avgFrameMs = avgFrameMs == 0.0lf ? lastFrameMs : avgFrameMs * 0.95lf + lastFrameMs * 0.05lf
        }
        prevUpdate = ref_time_ticks()
        ensure_keys()
        pump_keys(ticks)
        // at most real time: the editor updates at its frame rate (60 Hz),
        // doom's game tic is 1/35 s, so an update ahead of the clock skips
        if (turbo == 0 && realTime && double(ticks - baseTicks) >= double(get_time_nsec(startTicks)) * 35.0lf / 1000000000.0lf) {
            return
        }
        for (_k in range(turbo > 0 ? turbo : 1)) {
            if (!self->one_tick()) {
                return
            }
        }
        pump_audio()
        show_frame()
        update_status()
    }

    // one dge_tick with the clock advanced by one game tic; false once the engine stopped
    def one_tick : bool {
        let t0 = ref_time_ticks()
        var failed = false
        try {
            // the engine's clock: one game tic (1000 / 35 ms) per call
            dge_tick(uint((ticks + 1) * 1000 / 35))
        } recover {
            failed = true
        }
        lastTickMs = double(get_time_nsec(t0)) / 1000000.0lf
        totalTickMs += lastTickMs
        ticks++
        if (failed) {
            stop_with("the engine exited or trapped at tic {ticks}")
            return false
        }
        return true
    }

    // the frames mixed since the last call (interleaved int16 stereo in the
    // heap) as floats into the stream; dropped when audio is off or the stream
    // already holds AUDIO_MAX_QUEUE batches (a game faster than real time)
    def pump_audio {
        let n = dge_audio_frames()
        if (n == 0) {
            return
        }
        if (!audioOn) {
            dge_audio_consume()
            return
        }
        let t0 = ref_time_ticks()
        audioQueue = get_stream_queue(audio)
        if (audioQueue > AUDIO_MAX_QUEUE) {
            audioSkipped += n
            dge_audio_consume()
            return
        }
        let base = int(dge_audio_buffer())
        var inscope floats : array<float>
        resize(floats, n * 2)
        for (i in range(n * 2)) {
            let at = base + i * 2
            var v = int(c2da_mem[at]) | (int(c2da_mem[at + 1]) << 8)
            if (v >= 32768) {
                v -= 65536
            }
            floats[i] = float(v) / 32768.0
        }
        append_to_stream(audio, floats)
        dge_audio_consume()
        audioFrames += n
        audioBatches++
        lastAudioMs = double(get_time_nsec(t0)) / 1000000.0lf
        totalAudioMs += lastAudioMs
    }

    def show_frame {
        ensure_texture()
        copy_frame()
        let t1 = ref_time_ticks()
        update_texture(bitmap, texture)
        lastUploadMs = double(get_time_nsec(t1)) / 1000000.0lf
    }

    def ensure_texture {
        if (!hasTexture) {
            hasTexture = true
            var blank : array<uint>
            resize(blank, SCREEN_W * SCREEN_H)
            texture = create_texture(SCREEN_W, SCREEN_H, blank, TextureDeclaration(
                filter = TextureFilter.Point,
                generateMipLevels = false,
                addressing = TextureAddress.Clamp
            ))
            bitmap <- Bitmap(SCREEN_W, SCREEN_H)
            // doom's 320x200 is drawn for a 4:3 screen
            screen.localScale = float3(12.0, 9.0, 1.0)
            screen?.Mesh.materialId = create_material(MaterialImport(shaderName = "pixel_art", diffuse = texture))
        }
    }

    // the palette and the 8-bit screen into `bitmap` (no texture update)
    def copy_frame {
        let t0 = ref_time_ticks()
        // the palette: 256 little-endian 0x00RRGGBB words in the heap
        let pal = int(dge_palette())
        for (i in range(256)) {
            let p = pal + i * 4
            lut[i] = 0xff000000u | uint(c2da_mem[p]) | (uint(c2da_mem[p + 1]) << 8u) | (uint(c2da_mem[p + 2]) << 16u)
        }
        // the screen: one palette index per pixel, row-major, top row first
        let scr = int(dge_screen())
        for (i in range(SCREEN_W * SCREEN_H)) {
            bitmap.pixels[i] = lut[int(c2da_mem[scr + i])]
        }
        lastCopyMs = double(get_time_nsec(t0)) / 1000000.0lf
        totalCopyMs += lastCopyMs
    }

    def report : string {
        let seconds = double(get_time_nsec(startTicks)) / 1000000000.0lf
        let fps10 = seconds > 0.0lf ? int(double(ticks - baseTicks) * 10.0lf / seconds) : 0
        let avg10 = ticks > 0 ? int(totalTickMs * 10.0lf / double(ticks)) : 0
        let copy100 = ticks > 0 ? int(totalCopyMs * 100.0lf / double(ticks)) : 0
        let frame10 = int(avgFrameMs * 10.0lf)
        let mode = turbo > 0 ? "turbo {turbo} tics/update" : (realTime ? "real time" : "fast")
        return "c2das doom ({mode}): {ticks} tics, {fps10 / 10}.{fps10 % 10} tics/s (35 = real time), tick {int(lastTickMs)} ms (avg {avg10 / 10}.{avg10 % 10}), frame copy {copy100 / 100}.{copy100 % 100} ms avg, upload {int(lastUploadMs * 1000.0lf)} us, editor frame {frame10 / 10}.{frame10 % 10} ms, frames {dge_frames()}, key events {g_keyEvents}\n{self->audio_report()}"
    }

    def audio_report : string {
        let audio100 = audioBatches > 0 ? int(totalAudioMs * 100.0lf / double(audioBatches)) : 0
        let state = audioOn ? "on" : "off"
        return "audio {state}: sfx started {dge_audio_starts()}, peak {dge_audio_peak()}, appended {audioFrames} frames in {audioBatches} batches, stream queue {audioQueue}, skipped {audioSkipped}, mixer dropped {int(dge_audio_dropped())}, append {audio100 / 100}.{audio100 % 100} ms avg"
    }

    // runs `n` tics in one call, game time (no real-time cap); `copy`: the full
    // frame copy into the Bitmap after each tic, the texture updated after the last
    def bench(n : int; copy : bool) : string {
        ensure_texture()
        let startTic = ticks
        var engineMs = 0.0lf
        var copyMs = 0.0lf
        var postWipeTics = 0
        var postWipeMs = 0.0lf
        let tAll = ref_time_ticks()
        for (_i in range(n)) {
            if (!self->one_tick()) {
                break
            }
            // the bench's sound is not played (its mixing is in the tick's time)
            dge_audio_consume()
            engineMs += lastTickMs
            // the first ~40 tics of the attract demo include the screen wipe
            if (ticks > 50) {
                postWipeTics++
                postWipeMs += lastTickMs
            }
            if (copy) {
                copy_frame()
                copyMs += lastCopyMs
            }
        }
        let wallMs = double(get_time_nsec(tAll)) / 1000000.0lf
        if (copy) {
            let t1 = ref_time_ticks()
            update_texture(bitmap, texture)
            lastUploadMs = double(get_time_nsec(t1)) / 1000000.0lf
        }
        let done = ticks - startTic
        // the real-time clock restarts after the bench
        baseTicks = ticks
        startTicks = ref_time_ticks()
        let dn = double(max(done, 1))
        let engineTps = engineMs > 0.0lf ? dn * 1000.0lf / engineMs : 0.0lf
        let bothTps = engineMs + copyMs > 0.0lf ? dn * 1000.0lf / (engineMs + copyMs) : 0.0lf
        let wallTps = wallMs > 0.0lf ? dn * 1000.0lf / wallMs : 0.0lf
        let postTps = postWipeMs > 0.0lf ? double(postWipeTics) * 1000.0lf / postWipeMs : 0.0lf
        let res = "bench {copy ? "with copy" : "no copy"}: tics {startTic + 1}..{ticks} ({done}), wall {fmt(wallMs)} ms, engine {fmt(engineMs)} ms = {fmt(engineMs / dn)} ms/tick, copy {fmt(copyMs)} ms = {fmt(copyMs / dn)} ms/copy, upload {fmt(lastUploadMs)} ms; tics/s engine-only {fmt(engineTps)}, engine+copy {fmt(bothTps)}, wall {fmt(wallTps)}; after tic 50: {postWipeTics} tics {fmt(postTps)} tics/s engine-only"
        statusText = res
        if (status.isAlive) {
            update_debug_text(status, statusText)
        }
        print("[c2das doom] {res}\n")
        return res
    }

    def update_status {
        statusText = self->report()
        if (stopped) {
            statusText = "{statusText}\nstopped: {reason}"
        }
        if (status.isAlive) {
            update_debug_text(status, statusText)
        }
    }

    def stop_with(why : string) {
        stopped = true
        reason = why
        print("[c2das doom] stopped: {why}\n")
        update_status()
    }

    def override on_destroy {
        if (audioOn) {
            stop(audio)
            audioOn = false
        }
        if (status.isAlive) {
            remove_node(status)
        }
    }
}


// starts the translated doom on `wad` (the IWAD's bytes). The engine's state
// is the module's globals, so it starts once per game run. Returns the player
// node, or an invalid NodeId with the reason printed. `realTime` caps the
// game at 35 tics/s; without it every editor update runs one tic. `turbo` > 0
// runs that many tics per editor update with one texture update
def public c2das_doom_start(var wad : array<uint8>; realTime : bool = true; turbo : int = 0) : NodeId {
    if (g_started) {
        print("[c2das doom] already started; restart the game to start again\n")
        return NodeId()
    }
    g_started = true
    ensure_keys()
    let t0 = ref_time_ticks()
    c2da_eden_add_file("doom1.wad", wad)
    var failed = false
    try {
        dge_init()
    } recover {
        failed = true
    }
    let initMs = get_time_usec(t0) / 1000
    if (failed) {
        print("[c2das doom] dge_init failed after {initMs} ms\n")
        return NodeId()
    }
    print("[c2das doom] dge_init done in {initMs} ms, screen at {dge_screen()}, heap {length(c2da_mem)} bytes\n")
    let screen = create_node(NodeData(name = "c2das_doom", position = float3(0, 0, 0)))
    add_component(screen, new Mesh(meshId = QUAD_MESH_ID, visibility = MeshVisibility.VisibleInAnyCamera))
    let status = create_debug_text("c2das doom: starting", float2(16, 48), TOP_LEFT_ANCHOR)
    var player = new C2dasDoomPlayer(screen = screen, status = status, realTime = realTime, turbo = turbo)
    player.startTicks = ref_time_ticks()
    if (is_audio_active()) {
        player.audio = play_sound_stream(dge_audio_rate(), 2)
        player.audioOn = true
    }
    print("[c2das doom] audio {player.audioOn ? "on" : "off (is_audio_active false)"}, {dge_audio_rate()} Hz stereo\n")
    add_component(screen, player)
    return screen
}


// the status line of a running player; "none" without one
def public c2das_doom_report(node : NodeId) : string {
    let player = get_component(node, type<C2dasDoomPlayer>)
    if (player == null) {
        return "none"
    }
    return player.statusText
}


// doom_bench: `n` tics in one call with the frame copy, then `n` without it;
// a negative `n` runs the -n tics without the copy first. The two result lines
// joined by "\n", or "none" without a player
def public c2das_doom_bench(node : NodeId; n : int) : string {
    var player = get_component(node, type<C2dasDoomPlayer>)
    if (player == null) {
        return "none"
    }
    if (n < 0) {
        let noCopyFirst = player->bench(-n, false)
        let withCopyThen = player->bench(-n, true)
        return "{noCopyFirst}\n{withCopyThen}"
    }
    let withCopy = player->bench(n, true)
    let noCopy = player->bench(n, false)
    return "{withCopy}\n{noCopy}"
}


// the bindings held now and the Doom keys the player holds down, for checks
def public c2das_doom_keys_report : string {
    var res = "pressed:"
    for (m in g_keyMap) {
        if (is_action_pressed(m.action, ModifierMatchMode.Weak)) {
            res = "{res} {m.action}"
        }
    }
    res = "{res}; held:"
    for (s in g_keyStates) {
        if (s.held) {
            res = "{res} {s.doomKey}@{s.downTic}"
        }
    }
    return "{res}; key events {g_keyEvents}"
}


// sets the tics per editor update of a running player (0: back to one tic)
def public c2das_doom_set_turbo(node : NodeId; k : int) {
    var player = get_component(node, type<C2dasDoomPlayer>)
    if (player != null) {
        player.turbo = k
        player.baseTicks = player.ticks
        player.startTicks = ref_time_ticks()
    }
}
