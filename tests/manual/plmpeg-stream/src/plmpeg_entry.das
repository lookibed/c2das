options gen2

// Fixture-owned entrypoint. `all.das` is the generated target module and
// never receives a synthetic `main` from the translator.
// The printed lines and their order are the contract shared with
// `src/plmpeg_reference_entry.c` / `plmpeg_reference.expected`: the two
// header probes, then every decoded frame's RGB hash from the streaming API.
require all

[export]
def main() : int {
    print("sequence_start_code={all::plmpeg_probe_sequence_start_code()}\n")
    print("video_has_header={all::plmpeg_probe_video_has_header()}\n")
    if (all::plmpeg_frames_begin() == 0) {
        print("frames_begin=0\n")
        return 1
    }
    print("width={all::plmpeg_frames_width()}\n")
    print("height={all::plmpeg_frames_height()}\n")
    var frames = 0
    while (all::plmpeg_frames_next() != 0) {
        print("frame[{all::plmpeg_frames_index()}]={all::plmpeg_frames_hash()}\n")
        frames++
    }
    all::plmpeg_frames_end()
    print("frames={frames}\n")
    return frames > 0 ? 0 : 1
}
