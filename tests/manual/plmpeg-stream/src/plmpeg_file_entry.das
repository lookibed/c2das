options gen2

// Fixture-owned entrypoint over a stream file named by the last command-line
// argument (`daslang plmpeg_file_entry.das -- fixtures/x.m1v`, or the same
// path as the last argument of the -exe binary / the AOT host).  The file is
// read here with daslib/fio and handed to the translated graph as bytes, so
// the graph never embeds it and its size does not touch translation.
// The printed lines and their order are the contract shared with
// `src/plmpeg_file_reference_entry.c`: every decoded frame's RGB hash.
require all
require daslib/fio

def load_last_argument(var data : array<uint8>) : bool {
    let args <- get_command_line_arguments()
    if (length(args) == 0) {
        return false
    }
    let path = args[length(args) - 1]
    var loaded = false
    fopen(path, "rb") $(f) {
        if (f != null) {
            let size = fstat(f).size
            if (size > 0ul) {
                fload(f, int64(size)) $(bytes) {
                    data := bytes
                    loaded = true
                }
            }
        }
    }
    return loaded
}

[export]
def main() : int {
    var data : array<uint8>
    if (!load_last_argument(data)) {
        print("load=0\n")
        return 2
    }
    print("bytes={length(data)}\n")
    if (all::plmpeg_frames_begin_bytes(unsafe(addr(data[0])), length(data)) == 0) {
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
