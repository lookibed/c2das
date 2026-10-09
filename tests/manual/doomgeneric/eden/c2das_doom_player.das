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
    copies the 320x200 paletted screen into the texture.

    Keys (action set c2das_doom_keys): arrows / W S move and turn, A D strafe,
    Ctrl or F fire, Space or E use, Shift run, Enter, Esc or Backspace the
    menu, Y / N answers, Tab the map, 1..7 weapons.
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

let private SCREEN_W = 320
let private SCREEN_H = 200

var private g_keyMap : array<DoomKeyMap>
var private g_keysReady = false
var private g_started = false


def private add_key(action : string; key : KeyCode; doomKey : int) {
    push(g_keyMap, DoomKeyMap(action = action, key = key, doomKey = doomKey))
}


def private ensure_keys() {
    if (g_keysReady) {
        return
    }
    g_keysReady = true
    clear(g_keyMap)
    add_key("c2d_up", KeyCode.Up, DOOM_KEY_UPARROW)
    add_key("c2d_w", KeyCode.W, DOOM_KEY_UPARROW)
    add_key("c2d_down", KeyCode.Down, DOOM_KEY_DOWNARROW)
    add_key("c2d_s", KeyCode.S, DOOM_KEY_DOWNARROW)
    add_key("c2d_left", KeyCode.Left, DOOM_KEY_LEFTARROW)
    add_key("c2d_right", KeyCode.Right, DOOM_KEY_RIGHTARROW)
    add_key("c2d_a", KeyCode.A, DOOM_KEY_STRAFE_L)
    add_key("c2d_d", KeyCode.D, DOOM_KEY_STRAFE_R)
    add_key("c2d_ctrl", KeyCode.LControl, DOOM_KEY_FIRE)
    add_key("c2d_f", KeyCode.F, DOOM_KEY_FIRE)
    add_key("c2d_space", KeyCode.Space, DOOM_KEY_USE)
    add_key("c2d_e", KeyCode.E, DOOM_KEY_USE)
    add_key("c2d_shift", KeyCode.LShift, DOOM_KEY_RSHIFT)
    add_key("c2d_enter", KeyCode.Return, DOOM_KEY_ENTER)
    add_key("c2d_escape", KeyCode.Escape, DOOM_KEY_ESCAPE)
    add_key("c2d_back", KeyCode.Back, DOOM_KEY_ESCAPE)
    add_key("c2d_tab", KeyCode.Tab, DOOM_KEY_TAB)
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

    def override on_update {
        if (stopped) {
            return
        }
        ensure_keys()
        for (m in g_keyMap) {
            if (is_action_just_pressed(m.action, ModifierMatchMode.Weak)) {
                dge_key(1, m.doomKey)
                print("[c2das doom] key {m.action} -> {m.doomKey}\n")
            } elif (is_action_just_released(m.action, ModifierMatchMode.Weak)) {
                dge_key(0, m.doomKey)
            }
        }
        // at most real time: the editor updates at its frame rate (60 Hz),
        // doom's game tic is 1/35 s, so an update ahead of the clock skips
        if (realTime && double(ticks) >= double(get_time_nsec(startTicks)) * 35.0lf / 1000000000.0lf) {
            return
        }
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
            return
        }
        show_frame()
        update_status()
    }

    def show_frame {
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
        let t1 = ref_time_ticks()
        update_texture(bitmap, texture)
        lastUploadMs = double(get_time_nsec(t1)) / 1000000.0lf
    }

    def report : string {
        let seconds = double(get_time_nsec(startTicks)) / 1000000000.0lf
        let fps10 = seconds > 0.0lf ? int(double(ticks) * 10.0lf / seconds) : 0
        let avg10 = ticks > 0 ? int(totalTickMs * 10.0lf / double(ticks)) : 0
        let copy100 = ticks > 0 ? int(totalCopyMs * 100.0lf / double(ticks)) : 0
        return "c2das doom: {ticks} tics, {fps10 / 10}.{fps10 % 10} tics/s (35 = real time), tick {int(lastTickMs)} ms (avg {avg10 / 10}.{avg10 % 10}), frame copy {copy100 / 100}.{copy100 % 100} ms avg, upload {int(lastUploadMs * 1000.0lf)} us, frames {dge_frames()}"
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
        if (status.isAlive) {
            remove_node(status)
        }
    }
}


// starts the translated doom on `wad` (the IWAD's bytes). The engine's state
// is the module's globals, so it starts once per game run. Returns the player
// node, or an invalid NodeId with the reason printed. `realTime` caps the
// game at 35 tics/s; without it every editor update runs one tic
def public c2das_doom_start(var wad : array<uint8>; realTime : bool = true) : NodeId {
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
    var player = new C2dasDoomPlayer(screen = screen, status = status, realTime = realTime)
    player.startTicks = ref_time_ticks()
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
