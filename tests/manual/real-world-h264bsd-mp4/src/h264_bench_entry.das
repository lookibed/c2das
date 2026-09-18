options gen2

// Benchmark entrypoint for the H264BSD + minimp4 graph (daslang build).
// Prints exactly what `src/h264_bench_entry.c` prints; see that file for the
// line contract.  Hashes are collected first and printed after the timed loop.
require all

[export]
def main() : int {
    var hashes : array<int>
    let t0 = ref_time_ticks()
    if (all::h264mp4_frames_begin() == 0) {
        print("frames_begin=0\n")
        return 1
    }
    let setup_us = get_time_usec(t0)
    let t1 = ref_time_ticks()
    while (all::h264mp4_frames_next() != 0) {
        push(hashes, all::h264mp4_frames_hash())
    }
    let decode_us = get_time_usec(t1)
    for (i in range(length(hashes))) {
        print("frame[{i}]={hashes[i]}\n")
    }
    print("frames={length(hashes)}\n")
    print("width={all::h264mp4_frames_width()}\n")
    print("height={all::h264mp4_frames_height()}\n")
    all::h264mp4_frames_end()
    print("setup_us={setup_us}\n")
    print("decode_us={decode_us}\n")
    return length(hashes) > 0 ? 0 : 1
}
