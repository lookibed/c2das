options gen2

// Benchmark entrypoint for the PLMPEG graph (daslang build).
// Prints exactly what `src/plmpeg_bench_entry.c` prints; see that file for the
// line contract.  Hashes are collected first and printed after the timed loop.
require all

[export]
def main() : int {
    var hashes : array<int>
    // The C heap is a static array that exists before `main`; the translation
    // reserves its heap (64 MiB) on the first allocation.  Reserve it here, as a
    // `--libc std` program's argv construction does, so `setup_us` times the
    // same work as the C entry's (docs/corpus-build-recipe.md, section 7).
    all::c2da_rt_init_heap()
    let t0 = ref_time_ticks()
    if (all::plmpeg_frames_begin() == 0) {
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
