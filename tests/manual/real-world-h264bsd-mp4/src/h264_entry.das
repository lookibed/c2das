options gen2

// Fixture-owned entrypoint. `all.das` is the generated target module and
// never receives a synthetic `main` from the translator.
// The printed lines and their order are the contract shared with
// `src/h264_reference_entry.c` / `h264_reference.expected`.
require all

[export]
def main() : int {
    print("memory_read_status={all::h264mp4_probe_memory_read_status()}\n")
    print("memory_read_word0={all::h264mp4_probe_memory_read_word0()}\n")
    print("first_box_name={all::h264mp4_probe_minimp4_first_box_name()}\n")
    print("second_box_name={all::h264mp4_probe_minimp4_second_box_name()}\n")
    // h264mp4_probe_mp4d_open_track_count is deliberately not pinned: it reads
    // mp4.track_count *after* MP4D_close, i.e. released demuxer state.
    print("track_index={all::h264mp4_probe_track_index()}\n")
    print("sample_count={all::h264mp4_probe_sample_count()}\n")
    let width = all::h264mp4_probe_width()
    let height = all::h264mp4_probe_height()
    let frame_count = all::h264mp4_probe_frame_count(8)
    print("width={width}\n")
    print("height={height}\n")
    print("frame_count={frame_count}\n")
    if (width <= 0 || height <= 0 || frame_count <= 0) {
        return 1
    }
    return 0
}
