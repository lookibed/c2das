options gen2

// Benchmark entrypoint over a stream file named by the last command-line
// argument (daslang build).  Prints exactly what
// `src/plmpeg_file_bench_entry.c` prints; see `plmpeg_bench_entry.c` for the
// line contract.  Reading the file is outside every timed region.
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
    var hashes : array<int>
    let t0 = ref_time_ticks()
    if (all::plmpeg_frames_begin_bytes(unsafe(addr(data[0])), length(data)) == 0) {
        print("frames_begin=0\n")
        return 1
    }
    let setup_us = get_time_usec(t0)
    let t1 = ref_time_ticks()
    while (all::plmpeg_frames_next() != 0) {
        push(hashes, all::plmpeg_frames_hash())
    }
    let decode_us = get_time_usec(t1)
    for (i in range(length(hashes))) {
        print("frame[{i}]={hashes[i]}\n")
    }
    print("frames={length(hashes)}\n")
    print("width={all::plmpeg_frames_width()}\n")
    print("height={all::plmpeg_frames_height()}\n")
    all::plmpeg_frames_end()
    print("setup_us={setup_us}\n")
    print("decode_us={decode_us}\n")
    return length(hashes) > 0 ? 0 : 1
}
