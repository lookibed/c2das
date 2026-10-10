options stack = 8388608

// Example main.das of an EdenSpark project that plays dasDOOM.
//
// Install (see the dasDOOM README):
//   <project>/modules/dasdoom/   the contents of dasDOOM's eden/ directory
//   <project>/assets/dasdoom/doom1.wad.data   the shareware doom1.wad, renamed
// then run the game and type a cheat in the console:
//   doom_play            plays at Doom's real time (35 tics/s)
//   doom_play fast       one tic per editor update
//   doom_play turbo      4 tics per editor update (turbo2, turbo3, turbo6, turbo8)
//   doom_report          the player's status line
//   doom_bench 700       700 tics in one call, with and without the frame copy

require engine.core
require modules/dasdoom/c2das_doom_player


var doomWadId : TextId
var doomNode : NodeId


[export]
def on_initialize() {
    let camera = create_node(NodeData(name = "camera", position = float3(0, 0, -5)))
    add_component(camera, new Camera(orthographic = true, orthographicSize = 10f))
    doomWadId = request_text("assets/dasdoom/doom1.wad.data")
}


def private doom_turbo_of(mode : string) : int {
    if (mode == "turbo") {
        return 4
    } elif (mode == "turbo2") {
        return 2
    } elif (mode == "turbo3") {
        return 3
    } elif (mode == "turbo6") {
        return 6
    } elif (mode == "turbo8") {
        return 8
    }
    return 0
}


[cheat]
def doom_play(mode : string = "real") {
    if (doomNode.isAlive) {
        // already running: switch the mode
        c2das_doom_set_turbo(doomNode, doom_turbo_of(mode))
        print("DOOM mode {mode}")
        return
    }
    var wad : array<uint8>
    let found = get_binary_asset(doomWadId) $(data) {
        resize(wad, length(data))
        for (i in range(length(data))) {
            wad[i] = data[i]
        }
    }
    if (!found || length(wad) == 0) {
        print("DOOM: assets/dasdoom/doom1.wad.data not loaded yet")
        return
    }
    doomNode = c2das_doom_start(wad, mode != "fast", doom_turbo_of(mode))
    if (doomNode.isAlive) {
        doomNode.localPosition = float3(0, 0, -1)
    }
    print("DOOM {doomNode.isAlive ? "started" : "failed"}")
}


[cheat]
def doom_report() {
    print("DOOM {c2das_doom_report(doomNode)}")
    print("DOOM keys {c2das_doom_keys_report()}")
}


// the engine's potential speed: n tics in one call (game time, no real-time
// cap) with the frame copy, then n more without it
[cheat]
def doom_bench(n : int = 700) {
    if (!doomNode.isAlive) {
        doom_play("real")
    }
    print("DOOM BENCH\n{c2das_doom_bench(doomNode, n)}")
}


[export]
def on_update() {
}
