options stack = 8388608

// Example main.das of an EdenSpark project that plays dasQUAKE.
//
// Install (see the dasQUAKE README):
//   <project>/modules/dasquake/   the contents of dasQUAKE's eden/ directory
//   <project>/assets/dasquake/pak0.pak.data   the shareware id1/pak0.pak, renamed
// then run the game and type a cheat in the console:
//   quake_play            the attract demos at real time; Esc opens the menu
//   quake_play map        starts the map `start` (`+map start`) at real time
//   quake_play fixed      one fixed 33 ms step of game time per editor update
//   quake_mouse           turns mouse look on or off
//   quake_report          the player's status line
//   quake_bench 300       300 ticks in one call, with and without the frame copy

require engine.core
require modules/dasquake/c2das_quake_player


var quakePakId : TextId
var quakeNode : NodeId
var quakeMouse = false


[export]
def on_initialize() {
    let camera = create_node(NodeData(name = "camera", position = float3(0, 0, -5)))
    add_component(camera, new Camera(orthographic = true, orthographicSize = 10f))
    quakePakId = request_text("assets/dasquake/pak0.pak.data")
}


[cheat]
def quake_play(mode : string = "real") {
    if (quakeNode.isAlive) {
        // already running: switch the clock mode
        c2das_quake_set_real_time(quakeNode, mode != "fixed")
        print("QUAKE mode {mode}")
        return
    }
    var pak : array<uint8>
    let found = get_binary_asset(quakePakId) $(data) {
        resize(pak, length(data))
        for (i in range(length(data))) {
            pak[i] = data[i]
        }
    }
    if (!found || length(pak) == 0) {
        print("QUAKE: assets/dasquake/pak0.pak.data not loaded yet")
        return
    }
    quakeNode = c2das_quake_start(pak, mode != "fixed", mode == "map")
    if (quakeNode.isAlive) {
        quakeNode.localPosition = float3(0, 0, -1)
    }
    print("QUAKE {quakeNode.isAlive ? "started" : "failed"}")
}


[cheat]
def quake_mouse() {
    quakeMouse = !quakeMouse
    c2das_quake_set_mouse(quakeNode, quakeMouse)
    print("QUAKE mouse {quakeMouse ? "on" : "off"}")
}


[cheat]
def quake_report() {
    print("QUAKE {c2das_quake_report(quakeNode)}")
    print("QUAKE keys {c2das_quake_keys_report()}")
}


// the engine's potential speed: n ticks of 33 ms game time in one call with
// the frame copy, then n more without it
[cheat]
def quake_bench(n : int = 300) {
    if (!quakeNode.isAlive) {
        quake_play("real")
    }
    print("QUAKE BENCH\n{c2das_quake_bench(quakeNode, n)}")
}


[export]
def on_update() {
}
