options gen2

// Fixture-owned entrypoint. `all.das` is the generated target module and
// never receives a synthetic `main` from the translator.
require all

[export]
def main() : int {
    print("sequence_start_code={all::plmpeg_probe_sequence_start_code()}\n")
    print("video_has_header={all::plmpeg_probe_video_has_header()}\n")
    return 0
}
