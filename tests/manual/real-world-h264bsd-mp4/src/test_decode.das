options gen2
require c2da_module

[export] def main() : int {
    print("h264bsd decoder test\n")
    var w : int = c2da_module::h264mp4_probe_width()
    print("width={w}\n")
    var h : int = c2da_module::h264mp4_probe_height()
    print("height={h}\n")
    var fc : int = c2da_module::h264mp4_probe_frame_count(8)
    print("frame_count={fc}\n")
    if (w <= 0 || h <= 0 || fc <= 0) {
        return 1
    }
    return 0
}
