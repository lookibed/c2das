options gen2
options indenting = 4

module c2das_quake_player shared public

require engine.core
require modules/c2das/quake/chase_cluster
require modules/c2das/quake/c2da_runtime
require strings
require math

/*
    c2das_quake_player.das: plays the c2das-translated quakegeneric (the
    engine units of the case quakegeneric-demo1-eden-linear plus the play
    harness src/qg_eden_play.c, translated with the eden flags and
    --module-layout source, installed in an EdenSpark project under
    modules/c2das/quake/) in the scene. Hand-written host, not translated
    output; it follows the Doom player (tests/manual/doomgeneric/eden/
    c2das_doom_player.das).

    The qge_* entry functions of qg_eden_play.c live in the cluster module of
    the engine's include cycle, which the harness joins. Its name is
    `<lexically first member>_cluster`; `chase_cluster` above is the expected
    one, and scripts/export_dasquake.py rewrites that require to the module
    that actually defines qge_init. The heap c2da_mem and c2da_eden_add_file
    live in the shared runtime module c2da_runtime.

    c2das_quake_start registers the pak as quake/id1/pak0.pak
    (QGE_PAK_NAME of qg_eden.h) with c2da_eden_add_file, runs qge_init (the
    attract demos; the menu starts a game) or qge_init_map (`+map start`),
    and creates a node with a C2dasQuakePlayer component. Every on_update the
    component sends the key edges and mouse movement, runs one qge_tick, and
    copies the 320x240 paletted screen through the 768-byte RGB palette into
    the texture.

    Time: Quake runs on a variable frame time. In real-time mode qge_tick gets
    the wall clock since the start, so a slow interpreter runs the game at its
    own frame rate with the engine's 0.1 s cap per frame (Host_FilterTime). In
    fixed mode the clock advances FIXED_STEP_MS per update.

    Keys (action set c2das_quake_keys), sent as quakekeys.h codes and bound by
    the pak's default.cfg: arrows / W S move and turn, A D and , . strafe, Alt
    + turn strafes, Ctrl or F fire, Space jump, Shift run, Enter, Esc the
    menu, Backspace, Tab the scores, Y / N, 1..8 weapons, = - screen size,
    Q / Z / X look up / down / centre (sent as PgDn / Del / End), F1..F12,
    Pause. Mouse buttons are not bound. Key delivery is level-based like
    the Doom player's.

    Mouse: off by default (the editor's cursor crosses the scene all the
    time); c2das_quake_set_mouse turns it on, and then every MouseMove delta
    of the input command buffer goes to qge_mouse. Sound: quakegeneric's sound
    driver is the null one (snd_null.c); the game is silent.
*/


struct private QuakeKeyMap {
    action : string
    key : KeyCode
    quakeKey : int
}


// quakekeys.h (decimal: hex literals are uint in daslang 0.6.4)
let private QK_TAB = 9
let private QK_ENTER = 13
let private QK_ESCAPE = 27
let private QK_SPACE = 32
let private QK_BACKSPACE = 127
let private QK_UPARROW = 128
let private QK_DOWNARROW = 129
let private QK_LEFTARROW = 130
let private QK_RIGHTARROW = 131
let private QK_ALT = 132
let private QK_CTRL = 133
let private QK_SHIFT = 134
let private QK_F1 = 135
let private QK_DEL = 148
let private QK_PGDN = 149
let private QK_END = 152
let private QK_PAUSE = 255

// the play harness's base directory and pak name (qg_eden.h)
let private PAK_NAME = "quake/id1/pak0.pak"

// the clock step of fixed mode, and of quake_bench
let private FIXED_STEP_MS = 1000 / 30

// keyboard autorepeat of held arrows: first repeat, then the period
let private REPEAT_DELAY_MS = 400.0lf
let private REPEAT_PERIOD_MS = 100.0lf

// one Quake key and the state Quake was last told about
struct private QuakeKeyState {
    quakeKey : int
    held : bool
    downTick : int
    repeats : bool
    since : int64
    lastRepeat : int64
}

var private g_keyMap : array<QuakeKeyMap>
var private g_keyStates : array<QuakeKeyState>
var private g_keysReady = false
var private g_started = false
var private g_keyEvents = 0


def private add_key(action : string; key : KeyCode; quakeKey : int) {
    push(g_keyMap, QuakeKeyMap(action = action, key = key, quakeKey = quakeKey))
    for (s in g_keyStates) {
        if (s.quakeKey == quakeKey) {
            return
        }
    }
    let arrow = quakeKey == QK_UPARROW || quakeKey == QK_DOWNARROW || quakeKey == QK_LEFTARROW || quakeKey == QK_RIGHTARROW
    push(g_keyStates, QuakeKeyState(quakeKey = quakeKey, repeats = arrow))
}


def private send_key(pressed : bool; quakeKey : int) {
    qge_key(pressed ? 1 : 0, quakeKey)
    g_keyEvents++
}


// the level-based key edges of this update; `tick`: the number of qge_tick calls so far
def private pump_keys(tick : int) {
    for (s in g_keyStates) {
        var down = false
        var tapped = false
        for (m in g_keyMap) {
            if (m.quakeKey == s.quakeKey) {
                if (is_action_pressed(m.action, ModifierMatchMode.Weak)) {
                    down = true
                }
                if (is_action_just_pressed(m.action, ModifierMatchMode.Weak)) {
                    tapped = true
                }
            }
        }
        if ((down || tapped) && !s.held) {
            send_key(true, s.quakeKey)
            s.held = true
            s.downTick = tick
            s.since = ref_time_ticks()
            s.lastRepeat = s.since
        } elif (down && s.held && s.repeats) {
            let heldMs = double(get_time_nsec(s.since)) / 1000000.0lf
            if (heldMs >= REPEAT_DELAY_MS && double(get_time_nsec(s.lastRepeat)) / 1000000.0lf >= REPEAT_PERIOD_MS) {
                send_key(true, s.quakeKey)
                s.lastRepeat = ref_time_ticks()
            }
        }
        // a key stays down until a tick has seen it
        if (!down && s.held && tick > s.downTick) {
            send_key(false, s.quakeKey)
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
    add_key("c2q_up", KeyCode.Up, QK_UPARROW)
    add_key("c2q_w", KeyCode.W, QK_UPARROW)
    add_key("c2q_down", KeyCode.Down, QK_DOWNARROW)
    add_key("c2q_s", KeyCode.S, QK_DOWNARROW)
    add_key("c2q_left", KeyCode.Left, QK_LEFTARROW)
    add_key("c2q_right", KeyCode.Right, QK_RIGHTARROW)
    // default.cfg binds , and . to +moveleft / +moveright
    add_key("c2q_a", KeyCode.A, int(','))
    add_key("c2q_d", KeyCode.D, int('.'))
    add_key("c2q_comma", KeyCode.Comma, int(','))
    add_key("c2q_period", KeyCode.Period, int('.'))
    add_key("c2q_lalt", KeyCode.LAlt, QK_ALT)
    add_key("c2q_ralt", KeyCode.RAlt, QK_ALT)
    add_key("c2q_ctrl", KeyCode.LControl, QK_CTRL)
    add_key("c2q_rctrl", KeyCode.RControl, QK_CTRL)
    add_key("c2q_f", KeyCode.F, QK_CTRL)
    add_key("c2q_space", KeyCode.Space, QK_SPACE)
    add_key("c2q_shift", KeyCode.LShift, QK_SHIFT)
    add_key("c2q_rshift", KeyCode.RShift, QK_SHIFT)
    add_key("c2q_enter", KeyCode.Return, QK_ENTER)
    add_key("c2q_escape", KeyCode.Escape, QK_ESCAPE)
    add_key("c2q_back", KeyCode.Back, QK_BACKSPACE)
    add_key("c2q_tab", KeyCode.Tab, QK_TAB)
    // look up / down / centre: default.cfg binds them to PgDn, Del and End
    add_key("c2q_equals", KeyCode.Equals, int('='))
    add_key("c2q_minus", KeyCode.Minus, int('-'))
    add_key("c2q_q", KeyCode.Q, QK_PGDN)
    add_key("c2q_z", KeyCode.Z, QK_DEL)
    add_key("c2q_x", KeyCode.X, QK_END)
    add_key("c2q_pause", KeyCode.Pause, QK_PAUSE)
    add_key("c2q_f1", KeyCode.F1, QK_F1)
    add_key("c2q_f2", KeyCode.F2, QK_F1 + 1)
    add_key("c2q_f3", KeyCode.F3, QK_F1 + 2)
    add_key("c2q_f4", KeyCode.F4, QK_F1 + 3)
    add_key("c2q_f5", KeyCode.F5, QK_F1 + 4)
    add_key("c2q_f6", KeyCode.F6, QK_F1 + 5)
    add_key("c2q_f7", KeyCode.F7, QK_F1 + 6)
    add_key("c2q_f8", KeyCode.F8, QK_F1 + 7)
    add_key("c2q_f9", KeyCode.F9, QK_F1 + 8)
    add_key("c2q_f10", KeyCode.F10, QK_F1 + 9)
    add_key("c2q_f11", KeyCode.F11, QK_F1 + 10)
    add_key("c2q_f12", KeyCode.F12, QK_F1 + 11)
    add_key("c2q_y", KeyCode.Y, int('y'))
    add_key("c2q_n", KeyCode.N, int('n'))
    add_key("c2q_1", KeyCode._1, int('1'))
    add_key("c2q_2", KeyCode._2, int('2'))
    add_key("c2q_3", KeyCode._3, int('3'))
    add_key("c2q_4", KeyCode._4, int('4'))
    add_key("c2q_5", KeyCode._5, int('5'))
    add_key("c2q_6", KeyCode._6, int('6'))
    add_key("c2q_7", KeyCode._7, int('7'))
    add_key("c2q_8", KeyCode._8, int('8'))
    var keys : ActionSet
    for (m in g_keyMap) {
        var buttons : array<KeyboardButtonInput>
        push(buttons, KeyboardButtonInput(idx = m.key))
        keys[m.action] = Action(buttonActions = ButtonAction(keyboardButtons <- buttons))
    }
    add_and_activate_action_set("c2das_quake_keys", keys)
}


// `v` with two decimals
def private fmt(v : double) : string {
    let c = int(v * 100.0lf + 0.5lf)
    let f = c % 100
    return "{c / 100}.{f < 10 ? "0" : ""}{f}"
}


class C2dasQuakePlayer : Component {
    screen : NodeId
    status : NodeId
    texture : TextureId
    bitmap : Bitmap
    lut : uint[256]
    width : int = 320
    height : int = 240
    hasTexture : bool = false
    ticks : int = 0
    // the game clock handed to qge_tick, in ms
    clockMs : uint = 0u
    lastTickMs : double = 0.0lf
    totalTickMs : double = 0.0lf
    lastCopyMs : double = 0.0lf
    totalCopyMs : double = 0.0lf
    lastUploadMs : double = 0.0lf
    startTicks : int64 = 0l
    // real time: the game clock is clockBase + the wall time since clockStart
    // (rebased by quake_bench and a mode switch, so it never runs backwards)
    clockBase : uint = 0u
    clockStart : int64 = 0l
    // frames and ticks the fps rate is measured from (quake_bench moves them)
    baseFrames : int = 0
    baseTicks : int = 0
    stopped : bool = false
    reason : string
    statusText : string = "c2das quake: starting"
    // true: the wall clock; false: FIXED_STEP_MS per update
    realTime : bool = true
    mouseOn : bool = false
    mouseEvents : int = 0
    prevUpdate : int64 = 0l
    lastFrameMs : double = 0.0lf
    avgFrameMs : double = 0.0lf

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
        pump_mouse()
        let next = realTime ? clockBase + uint(get_time_nsec(clockStart) / 1000000l) : clockMs + uint(FIXED_STEP_MS)
        if (!self->one_tick(next)) {
            return
        }
        show_frame()
        update_status()
    }

    // the MouseMove deltas of this update into qge_mouse (only when mouseOn)
    def pump_mouse {
        if (!mouseOn) {
            return
        }
        var dx = 0.0
        var dy = 0.0
        for (cmd in get_input_command_buffer()) {
            if (cmd is RawMouseInputEvent) {
                let mouse = cmd as RawMouseInputEvent
                if (mouse.kind == RawMouseInputEventKind.MouseMove) {
                    dx += mouse.deltaPosition.x
                    dy += mouse.deltaPosition.y
                }
            }
        }
        let ix = int(dx)
        let iy = int(dy)
        if (ix != 0 || iy != 0) {
            qge_mouse(ix, iy)
            mouseEvents++
        }
    }

    // one qge_tick with the game clock at `next` ms; false once the engine stopped
    def one_tick(next : uint) : bool {
        let t0 = ref_time_ticks()
        var failed = false
        clockMs = next
        try {
            qge_tick(clockMs)
        } recover {
            failed = true
        }
        lastTickMs = double(get_time_nsec(t0)) / 1000000.0lf
        totalTickMs += lastTickMs
        ticks++
        if (failed) {
            stop_with("the engine exited or trapped at tick {ticks}")
            return false
        }
        return true
    }

    def show_frame {
        ensure_texture()
        if (!copy_frame()) {
            return
        }
        let t1 = ref_time_ticks()
        update_texture(bitmap, texture)
        lastUploadMs = double(get_time_nsec(t1)) / 1000000.0lf
    }

    def ensure_texture {
        if (!hasTexture) {
            hasTexture = true
            var blank : array<uint>
            resize(blank, width * height)
            texture = create_texture(width, height, blank, TextureDeclaration(
                filter = TextureFilter.Point,
                generateMipLevels = false,
                addressing = TextureAddress.Clamp
            ))
            bitmap <- Bitmap(width, height)
            // 320x240 is 4:3
            screen.localScale = float3(12.0, 9.0, 1.0)
            screen?.Mesh.materialId = create_material(MaterialImport(shaderName = "pixel_art", diffuse = texture))
        }
    }

    // the palette and the 8-bit screen into `bitmap` (no texture update);
    // false before the first frame
    def copy_frame : bool {
        let scr = int(qge_screen())
        if (scr == 0) {
            return false
        }
        let t0 = ref_time_ticks()
        // the palette: 256 RGB byte triples in the heap, into 0xAARRGGBB
        // Bitmap texels (R in the low byte showed the brown console blue)
        let pal = int(qge_palette())
        for (i in range(256)) {
            let p = pal + i * 3
            lut[i] = 0xff000000u | (uint(c2da_mem[p]) << 16u) | (uint(c2da_mem[p + 1]) << 8u) | uint(c2da_mem[p + 2])
        }
        // the screen: one palette index per pixel, row-major, top row first
        for (i in range(width * height)) {
            bitmap.pixels[i] = lut[int(c2da_mem[scr + i])]
        }
        lastCopyMs = double(get_time_nsec(t0)) / 1000000.0lf
        totalCopyMs += lastCopyMs
        return true
    }

    def report : string {
        let seconds = double(get_time_nsec(startTicks)) / 1000000000.0lf
        let frames = qge_frames()
        let fps = seconds > 0.0lf ? double(frames - baseFrames) / seconds : 0.0lf
        let done = ticks - baseTicks
        let avgTick = done > 0 ? totalTickMs / double(ticks) : 0.0lf
        let avgCopy = ticks > 0 ? totalCopyMs / double(ticks) : 0.0lf
        let mode = realTime ? "real time" : "fixed {FIXED_STEP_MS} ms/update"
        return "c2das quake ({mode}): {fmt(fps)} fps, frame {fmt(lastTickMs)} ms (avg {fmt(avgTick)}), copy {fmt(avgCopy)} ms avg, upload {int(lastUploadMs * 1000.0lf)} us, editor frame {fmt(avgFrameMs)} ms, frames {frames}, ticks {ticks}, game clock {clockMs} ms, key events {g_keyEvents}, mouse {mouseOn ? "on" : "off"} ({mouseEvents})"
    }

    // runs `n` ticks in one call, FIXED_STEP_MS of game time each (no
    // real-time cap); `copy`: the frame copy after each tick, the texture
    // updated after the last
    def bench(n : int; copy : bool) : string {
        ensure_texture()
        let startTick = ticks
        let startFrames = qge_frames()
        var engineMs = 0.0lf
        var copyMs = 0.0lf
        let tAll = ref_time_ticks()
        for (_i in range(n)) {
            if (!self->one_tick(clockMs + uint(FIXED_STEP_MS))) {
                break
            }
            engineMs += lastTickMs
            if (copy && copy_frame()) {
                copyMs += lastCopyMs
            }
        }
        let wallMs = double(get_time_nsec(tAll)) / 1000000.0lf
        if (copy) {
            let t1 = ref_time_ticks()
            update_texture(bitmap, texture)
            lastUploadMs = double(get_time_nsec(t1)) / 1000000.0lf
        }
        let done = ticks - startTick
        let frames = qge_frames() - startFrames
        // the fps rate restarts after the bench; real time continues from the game clock
        baseFrames = qge_frames()
        baseTicks = ticks
        startTicks = ref_time_ticks()
        self->rebase_clock()
        let dn = double(max(done, 1))
        let engineFps = engineMs > 0.0lf ? double(frames) * 1000.0lf / engineMs : 0.0lf
        let bothFps = engineMs + copyMs > 0.0lf ? double(frames) * 1000.0lf / (engineMs + copyMs) : 0.0lf
        let res = "bench {copy ? "with copy" : "no copy"}: ticks {startTick + 1}..{ticks} ({done}), frames {frames}, wall {fmt(wallMs)} ms, engine {fmt(engineMs)} ms = {fmt(engineMs / dn)} ms/tick, copy {fmt(copyMs)} ms = {fmt(copyMs / dn)} ms/copy, upload {fmt(lastUploadMs)} ms; fps engine-only {fmt(engineFps)}, engine+copy {fmt(bothFps)}"
        statusText = res
        if (status.isAlive) {
            update_debug_text(status, statusText)
        }
        print("[c2das quake] {res}\n")
        return res
    }

    // real time continues from the current game clock
    def rebase_clock {
        clockBase = clockMs
        clockStart = ref_time_ticks()
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
        print("[c2das quake] stopped: {why}\n")
        update_status()
    }

    def override on_destroy {
        if (status.isAlive) {
            remove_node(status)
        }
    }
}


// starts the translated Quake on `pak` (the bytes of the shareware
// id1/pak0.pak). The engine's state is the module's globals, so it starts once
// per game run. `startMap`: `+map start` instead of the attract demos.
// Returns the player node, or an invalid NodeId with the reason printed
def public c2das_quake_start(var pak : array<uint8>; realTime : bool = true; startMap : bool = false) : NodeId {
    if (g_started) {
        print("[c2das quake] already started; restart the game to start again\n")
        return NodeId()
    }
    g_started = true
    ensure_keys()
    let t0 = ref_time_ticks()
    c2da_eden_add_file(PAK_NAME, pak)
    var failed = false
    try {
        if (startMap) {
            qge_init_map()
        } else {
            qge_init()
        }
    } recover {
        failed = true
    }
    let initMs = get_time_usec(t0) / 1000
    if (failed) {
        print("[c2das quake] qge_init failed after {initMs} ms\n")
        return NodeId()
    }
    print("[c2das quake] qge_init done in {initMs} ms, {qge_width()}x{qge_height()}, heap {length(c2da_mem)} bytes\n")
    let screen = create_node(NodeData(name = "c2das_quake", position = float3(0, 0, 0)))
    add_component(screen, new Mesh(meshId = QUAD_MESH_ID, visibility = MeshVisibility.VisibleInAnyCamera))
    let status = create_debug_text("c2das quake: starting", float2(16, 48), TOP_LEFT_ANCHOR)
    var player = new C2dasQuakePlayer(screen = screen, status = status, realTime = realTime,
                                      width = qge_width(), height = qge_height())
    player.startTicks = ref_time_ticks()
    player.clockStart = player.startTicks
    add_component(screen, player)
    return screen
}


// the status line of a running player; "none" without one
def public c2das_quake_report(node : NodeId) : string {
    let player = get_component(node, type<C2dasQuakePlayer>)
    if (player == null) {
        return "none"
    }
    return player.statusText
}


// quake_bench: `n` ticks in one call with the frame copy, then `n` without
// it. The two result lines joined by "\n", or "none" without a player
def public c2das_quake_bench(node : NodeId; n : int) : string {
    var player = get_component(node, type<C2dasQuakePlayer>)
    if (player == null) {
        return "none"
    }
    let withCopy = player->bench(n, true)
    let noCopy = player->bench(n, false)
    return "{withCopy}\n{noCopy}"
}


// switches a running player between real time and fixed steps
def public c2das_quake_set_real_time(node : NodeId; realTime : bool) {
    var player = get_component(node, type<C2dasQuakePlayer>)
    if (player != null) {
        player.realTime = realTime
        player->rebase_clock()
    }
}


// turns the mouse (MouseMove deltas to qge_mouse) on or off
def public c2das_quake_set_mouse(node : NodeId; on : bool) {
    var player = get_component(node, type<C2dasQuakePlayer>)
    if (player != null) {
        player.mouseOn = on
    }
}


// the bindings held now and the Quake keys the player holds down, for checks
def public c2das_quake_keys_report : string {
    var res = "pressed:"
    for (m in g_keyMap) {
        if (is_action_pressed(m.action, ModifierMatchMode.Weak)) {
            res = "{res} {m.action}"
        }
    }
    res = "{res}; held:"
    for (s in g_keyStates) {
        if (s.held) {
            res = "{res} {s.quakeKey}@{s.downTick}"
        }
    }
    return "{res}; key events {g_keyEvents}"
}
