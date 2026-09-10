# MPEG-1 decode performance: native C vs c2das vs a hand-written daslang port

Measured 2026-09-10 on an Intel Core i5-6200U (2 cores / 4 threads, 2.30 GHz), Debian 13,
Linux 6.12.107. All runs serial on an otherwise idle machine.

Three implementations of the same decoder are compared on the same five MPEG-1 elementary
streams:

1. **C native** — upstream `pl_mpeg.h` (`tests/manual/real-world-plmpeg-stream/upstream/pl_mpeg.h`,
   4439 lines), compiled with `clang-18` at `-O2` and at `-O0`.
2. **c2das** — the same C translated to daScript by this repository's transpiler and run
   under the daslang interpreter.
3. **plmpeg-stream** — the independent hand-written daslang port at
   <https://github.com/lookibed/plmpeg-stream> (`src/main.das`, 2718 lines), also under the
   interpreter.

All three fold every decoded RGB frame into the same 32-bit summary hash, so decoded pixel
data can be compared across implementations.

## daslang version and flags

```
$ daslang --version
0.6.4
```

`daslang -h` advertises `-jit`, `-jit-no-cache`, `-jit-stack`, `-exe` (JIT to a standalone
executable) and `-use-aot`. **None of them is usable in this build**, so there is no JIT
column in the tables below:

* `-jit` loads `modules/dasLLVM`, whose bindings are `[extern(..., library="LLVM.dll")]`.
  The loader looks for `LLVM.dll` via `dlopen`, the `dll_search_paths` policy, and finally
  `<das_root>/lib/LLVM.dll`. `<das_root>/lib/` contains only the two daScript runtime
  shared objects, so the first failure is `can't load library LLVM.dll`.
* Pointing it at a system LLVM (`LD_LIBRARY_PATH` with an `LLVM.dll` symlink to
  `libLLVM-18.so.1`, then to `libLLVM.so.19.1`) gets past loading but fails on symbols:
  `LLVMRunPassesOnFunction`, `LLVMPassBuilderOptionsSetAAPipeline`,
  `LLVMOrcCreateObjectLinkingLayerWithInProcessMemoryManager`,
  `LLVMOrcCreateRTDyldObjectLinkingLayerWithSectionMemoryManagerReserveAlloc` do not exist
  in either. `modules/dasLLVM/README.md` states the bindings are generated for
  **LLVM 22.1.5**; only LLVM 18 (and a stray LLVM 19 runtime) are installed here.
* `-use-aot` needs AOT stubs linked into the `daslang` binary; this build has none.

To get a JIT number, drop an LLVM 22.1.5 shared library at
`<das_root>/lib/LLVM.dll` and re-run with `-jit`. Everything below is the **pure
interpreter**.

The profiler flags (`--das-profiler`, `--das-profiler-time-unit`) do work; see
[Where the time goes](#where-the-time-goes).

## The hash

Copied verbatim from `decode_summary()` / `fold_bytes()` in
`tests/manual/real-world-plmpeg-stream/src/module.c`, so the benchmark hash is the same
number the fixture oracle computes. All arithmetic is wrapping 32-bit unsigned:

```c
rotl32(v, s)      = (v << s) | (v >> (32u - s))
fold_bytes(p, n)  : h = 0x811C9DC5; for each byte b: h ^= b; h *= 16777619; h = rotl32(h, 5)

combined = 0x811C9DC5
per frame i:  combined ^= fold_bytes(rgb, w*h*3) + (uint32_t)(i * 0x9E3779B9);
              combined  = rotl32(combined, 7);
              combined += 0x7F4A7C15;
after loop:   combined ^= w; combined = rotl32(combined, 3);
              combined ^= h; combined = rotl32(combined, 3);
              combined ^= frames;
```

Every harness sets `plm_video_set_no_delay(video, 1)`, exactly as `module.c` does.

`decode_ms` times **only** the decode + `plm_frame_to_rgb` + hash loop; stream loading,
decoder construction and teardown are outside it. `hash_ms` is the accumulated time inside
`fold_bytes` — reported separately because that flat per-byte loop is a large share of the
work and it is not MPEG decoding.

## How it was built

Scratch tree (kept outside the repo, at `/tmp/c2das-perf`):

```
/tmp/c2das-perf/
  bench_c.c                     native C harness
  bench_c_O2, bench_c_O0        its two builds
  upstream/pl_mpeg.h            copy of the fixture's upstream header
  c2das/
    pl_mpeg.c                   copy of the fixture's src/pl_mpeg.c wrapper
    bench_module.c              benchmark API for the translated graph
    all_bench.c                 pl_mpeg.c + bench_module.c
    all_bench.das               transpiler output (6501 lines)
    bench_entry.das             daslang entry point
    include/{stdlib.h,string.h} copies of the fixture's shim headers
  plmpeg-stream/                clone of lookibed/plmpeg-stream
    examples/bench_hash.das     benchmark for the hand-written port
```

### 1. C native

```sh
clang-18 -O2 -std=c11 -D_POSIX_C_SOURCE=200809L -I<fixture>/upstream bench_c.c -o bench_c_O2 -lm
clang-18 -O0 -std=c11 -D_POSIX_C_SOURCE=200809L -I<fixture>/upstream bench_c.c -o bench_c_O0 -lm
./bench_c_O2 <stream>.m1v [frame_limit]
```

(`-D_POSIX_C_SOURCE=200809L` only so that strict `-std=c11` exposes `clock_gettime`.)

The timed loop:

```c
    t0 = now_ms();
    for (;;) {
        plm_frame_t *frame = plm_video_decode(video);
        uint32_t frame_hash = 0u;
        double h0 = 0.0;

        if (!frame) {
            break;
        }
        plm_frame_to_rgb(frame, rgb, width * 3);
        h0 = now_ms();
        frame_hash = fold_bytes(rgb, rgb_size);
        hash_ms += now_ms() - h0;

        combined ^= frame_hash + (uint32_t)(frame_index * 0x9E3779B9u);
        combined = rotl32(combined, 7u);
        combined += 0x7F4A7C15u;
        frame_index += 1;

        if (frame_limit > 0 && frame_index >= frame_limit) {
            break;
        }
    }
    combined ^= (uint32_t)width;
    combined = rotl32(combined, 3u);
    combined ^= (uint32_t)height;
    combined = rotl32(combined, 3u);
    combined ^= (uint32_t)frame_index;
    t1 = now_ms();
```

### 2. c2das

`bench_module.c` is `module.c` stripped of the embedded `sample_mpg_data.h` and of every
`c2da_rt_reset()` call (a reset would rewind the bump allocator and drop the stream bytes
the daslang side just wrote). Its API deliberately uses `int64_t` for addresses:

```c
int64_t bench_alloc(int32_t size);                                        /* -> raw heap address */
int32_t bench_decode_ptr(int64_t ptr, int32_t len, int32_t frame_limit);  /* -> combined hash */
int32_t bench_get_frames(void);
int32_t bench_get_width(void);
int32_t bench_get_height(void);
```

> The fixture's own `plmpeg_host_alloc` returns `int32_t`, which is **lossy**: the generated
> `c2da_rt_malloc` returns a real 64-bit host address into the `c2da_rt_heap : array<uint8>`
> global (`intptr(addr(c2da_rt_heap[start]))`), and truncating it to `int32_t` cannot survive
> a round trip. `int64_t` translates to `def bench_alloc(var size : int) : int64` and the
> address round-trips intact.

The decode loop is byte-identical to the C harness above (see
`/tmp/c2das-perf/c2das/bench_module.c`), including `create_decoder`, `fold_bytes` and
`rotl32` copied verbatim from `module.c`.

Transpile (`--strict` and `-w` both accepted; only benign "skipping implicit typedef"
warnings; 3.3 s wall, 6501 lines of `.das`):

```sh
cargo run -q -p c2dascript-transpile -- --strict \
  --output-dir /tmp/c2das-perf/c2das \
  --file /tmp/c2das-perf/c2das/all_bench.c \
  -DPLM_NO_STDIO -I/tmp/c2das-perf/c2das/include -I/tmp/c2das-perf/upstream -I/tmp/c2das-perf/c2das -w
```

Run:

```sh
cd /tmp/c2das-perf/c2das
daslang -dasroot <das_root> bench_entry.das -- <stream>.m1v [frame_limit]
```

`bench_entry.das`:

```das
options gen2

require all_bench
require daslib/fio
require strings

// milliseconds, 3 decimals, from an integer microsecond count
def ms3(usec : int) : string {
    let whole = usec / 1000
    let frac = usec % 1000
    return "{whole}.{frac:03}"
}

def script_args() : array<string> {
    var out : array<string>
    let argv <- get_command_line_arguments()
    var seen = false
    for (i in range(length(argv))) {
        if (seen) {
            push(out, argv[i])
        } elif (argv[i] == "--") {
            seen = true
        }
    }
    return <- out
}

def read_all(path : string; var data : array<uint8>) : bool {
    var ok = false
    fopen(path, "rb") <| $(f) {
        if (f != null) {
            let fs = fstat(f)
            let size = int(fs.size)
            if (size > 0) {
                resize(data, size)
                ok = fread(f, data) == size
            }
        }
    }
    return ok
}

[export]
def main() : int {
    let args <- script_args()
    if (length(args) < 1) {
        print("usage: daslang bench_entry.das -- <stream.m1v> [frame_limit]\n")
        return 1
    }
    let path = args[0]
    var frame_limit = 0
    if (length(args) >= 2) {
        frame_limit = to_int(args[1], false)
    }

    var data : array<uint8>
    if (!read_all(path, data)) {
        print("error: cannot read {path}\n")
        return 1
    }
    let len = length(data)

    let ptr = bench_alloc(len)
    if (ptr == 0l) {
        print("error: bench_alloc({len}) failed\n")
        return 1
    }

    // copy the stream into the c2das bump heap (outside the timed region)
    let copy_t0 = ref_time_ticks()
    unsafe {
        var dst = reinterpret<uint8?>(uint64(ptr))
        for (i in range(len)) {
            dst[i] = data[i]
        }
    }
    let copy_usec = get_time_usec(copy_t0)

    let t0 = ref_time_ticks()
    let hash = bench_decode_ptr(ptr, len, frame_limit)
    let decode_usec = get_time_usec(t0)

    let frames = bench_get_frames()
    let width = bench_get_width()
    let height = bench_get_height()
    let hash_ns = bench_get_hash_ns()
    let hash_usec = int(hash_ns / 1000l)

    print("frames={frames} width={width} height={height} hash={uint(hash):08x} decode_ms={ms3(decode_usec)} hash_ms={ms3(hash_usec)}\n")
    print("# bytes={len} copy_ms={ms3(copy_usec)}\n")
    return 0
}
```

The byte feed needs no access to `c2da_rt_heap` at all: the `int64` from `bench_alloc` is a
real host address, so `unsafe { reinterpret<uint8?>(uint64(ptr)) }` writes straight into the
heap — the same trick the generated `c2da_rt_memcpy` uses. The copy is outside the timed
region and costs 0.3 ms (`sample.m1v`) to 27 ms (`test.m1v`). No stream had to be embedded
as a C array, and the 64 MB `c2da_rt_heap` reservation held a 2 MB stream plus 1920×1080
frame buffers without trouble.

**`hash_ms` is always `0.000` for c2das**: there is no clock reachable from the translated C
(the graph has no libc time functions), so `bench_get_hash_ns()` returns 0. The c2das
`hash_ms` column below is therefore blank, not zero-cost.

### 3. plmpeg-stream

```sh
cd /tmp/c2das-perf/plmpeg-stream/examples
daslang -dasroot <das_root> bench_hash.das -- <stream>.m1v [frame_limit]
```

`require plmpeg` does **not** work under 0.6.4: the repo ships a `plmpeg.das_module`
manifest but no `plmpeg.das`, so `-load_module /tmp/c2das-perf/plmpeg-stream` still gives
`error[20605]: missing prerequisite 'plmpeg'; file not found`. The benchmark therefore uses
`require ../src/main.das` (the monolith), which compiles clean under 0.6.4.

`examples/bench_hash.das`:

```das
options gen2
require ../src/main.das
require daslib/fio
require daslib/strings

def rotl32(v : uint; s : uint) : uint {
    return (v << s) | (v >> (32u - s))
}

def fold_bytes(var bytes : array<uint8>) : uint {
    var hash = 0x811C9DC5u
    for (b in bytes) {
        hash ^= uint(b)
        hash *= 16777619u
        hash = rotl32(hash, 5u)
    }
    return hash
}

def bench_args(var path : string&; var frame_limit : int&) : bool {
    var args <- get_command_line_arguments()
    var seen_sep = false
    var taken = 0
    for (a in args) {
        if (!seen_sep) {
            if (a == "--") { seen_sep = true }
            continue
        }
        if (taken == 0) { path = a }
        elif (taken == 1) { frame_limit = to_int(a) }
        taken += 1
    }
    return taken > 0
}

[export]
def main() : int {
    var path = ""
    var frame_limit = 0
    if (!bench_args(path, frame_limit)) {
        print("usage: daslang bench_hash.das -- <file.m1v> [frame_limit]\n")
        return 1
    }

    var bytes : array<uint8>
    fopen(path, "rb") <| $(f) {
        if (f != null) {
            let st = fstat(f)
            resize(bytes, int(st.size))
            fread(f, bytes)
        }
    }
    if (length(bytes) == 0) {
        print("failed to read {path}\n")
        return 1
    }

    var buffer = plm_buffer_create_with_memory(bytes, length(bytes))
    if (buffer == null) { print("failed to create buffer\n"); return 1 }
    var video = plm_video_create_with_buffer(buffer, true)
    if (video == null) { print("failed to create video decoder\n"); return 1 }
    plm_video_set_no_delay(*video, true)

    let w = plm_video_get_width(*video)
    let h = plm_video_get_height(*video)
    let rgb_stride = w * 3
    var rgb : array<uint8>
    resize(rgb, rgb_stride * h)

    var combined = 0x811C9DC5u
    var frame_index = 0
    var hash_ns = 0l

    let t_all = ref_time_ticks()
    while (true) {
        var frame = plm_video_decode(*video)
        if (frame == null) { break }
        plm_frame_to_rgb(*frame, rgb, rgb_stride)

        let t_hash = ref_time_ticks()
        let fh = fold_bytes(rgb)
        hash_ns += ref_time_ticks() - t_hash

        combined ^= fh + uint(frame_index) * 0x9E3779B9u
        combined = rotl32(combined, 7u)
        combined += 0x7F4A7C15u
        frame_index += 1

        if (frame_limit > 0 && frame_index >= frame_limit) { break }
    }
    combined ^= uint(w)
    combined = rotl32(combined, 3u)
    combined ^= uint(h)
    combined = rotl32(combined, 3u)
    combined ^= uint(frame_index)
    let decode_ns = ref_time_ticks() - t_all

    let decode_ms = double(decode_ns) / 1000000.0lf
    let hash_ms = double(hash_ns) / 1000000.0lf
    print("frames={frame_index} width={w} height={h} hash={fmt(":08x", combined)} decode_ms={fmt(":.3f", decode_ms)} hash_ms={fmt(":.3f", hash_ms)}\n")

    // plm_video_destroy is known to assert on cleanup (see INTEGRATION.md); it would be
    // outside the timed region anyway, so it is skipped here.
    return 0
}
```

No change was needed inside `src/*.das` — the port compiles unmodified under 0.6.4. Two
behavioural deviations from the port's own example code, both forced:

* **`delete frame` was dropped.** `examples/decode_m1v.das` deletes the frame each
  iteration and `INTEGRATION.md` claims `plm_video_decode` allocates with `new PlmFrame`.
  It does not: it returns `addr(self.frame_backward)` / `addr(self.frame_current)` /
  `addr(self.frame_forward)`, interior pointers into `PlmVideo`. Under 0.6.4 the delete
  aborts the process on the first frame with `deleting 0x… 160, which is not a chunk
  pointer (or chunk size mismatch)`. That cost is not in the numbers.
* **`plm_video_destroy` skipped**, as the README warns it may crash. It is outside the
  timed region either way.

Five further 0.6.2→0.6.4 language differences surfaced while writing the benchmark; they
also break the shipped `examples/decode_m1v.das`, so they are recorded here: `def main`
needs `[export]`; `for a in args` must be `for (a in args)`; `===` is not accepted for
null comparison (use `==`); pointer arguments are not auto-dereferenced
(`plm_video_get_width(*video)`); `array<uint8>(n)` is an element-initializer list, not a
size (use `resize`); `sprintf` and `int(string)` do not exist (use `fmt(":08x", …)` and
`to_int` from `daslib/strings`).

## Results

Minimum of 3 runs per cell, serial, idle machine (`test.m1v` under the two interpreters:
1 serial run, cross-checked against 3 earlier runs). Streams are the fixtures shipped with
plmpeg-stream. `/usr/bin/time` is not installed on this box; wall time is a `date +%s.%N`
delta around the process.

Frame counts differ between implementations (see the hash matrix): C and c2das agree; the
hand-written port emits one extra trailing frame on every stream. `frames/s` is computed
from each implementation's own frame count, so it is comparable; `decode_ms` for
plmpeg-stream is for one frame more of work.

### Decode time (ms) and throughput (frames/s)

| stream | frames (C) | C `-O2` | C `-O0` | c2das (interp) | plmpeg-stream (interp) |
|---|---|---|---|---|---|
| `sample.m1v` 96×64 | 11 | **2.34 ms** — 4712 fps | **7.46 ms** — 1475 fps | **134.2 ms** — 81.9 fps | **74.3 ms** — 161.6 fps (12 fr) |
| `sample.m1v` limit 12 | 11 | 2.34 ms — 4705 fps | — | 124.4 ms — 88.4 fps | 74.7 ms — 160.7 fps (12 fr) |
| `hd8_test.m1v` 1280×720 | 7 | **73.79 ms** — 94.9 fps | **283.2 ms** — 24.7 fps | **3808.8 ms** — 1.84 fps | **3253.7 ms** — 2.46 fps (8 fr) |
| `hd_test.m1v` 1280×720 | 1 | **14.84 ms** — 67.4 fps | **54.82 ms** — 18.2 fps | **798.7 ms** — 1.25 fps | **923.1 ms** — 2.17 fps (2 fr) |
| `test_480p.m1v` 854×480 | 124 | **591.3 ms** — 209.7 fps | **2355.3 ms** — 52.6 fps | **34 953.6 ms** — 3.55 fps | **25 611.6 ms** — 4.88 fps (125 fr) |
| `test.m1v` 1920×1080 | 124 | **2891.4 ms** — 42.9 fps | **11 567.9 ms** — 10.7 fps | **163 887.0 ms** — 0.76 fps | **123 568.1 ms** — 1.01 fps (125 fr) |

`sample.m1v` at frame limit 12 is identical to the full stream: with `no_delay` the stream
yields only 11 frames in C (the port yields 12, see below).

Share of `decode_ms` spent inside `fold_bytes` (`hash_ms`), i.e. *not* MPEG decoding:

| stream | C `-O2` | C `-O0` | c2das | plmpeg-stream |
|---|---|---|---|---|
| `sample.m1v` | 0.38 ms (16%) | 1.63 ms (22%) | n/a | 4.41 ms (5.9%) |
| `hd8_test.m1v` | 36.1 ms (49%) | 158.2 ms (56%) | n/a | 464.5 ms (14%) |
| `hd_test.m1v` | 5.18 ms (35%) | 22.5 ms (41%) | n/a | 113.2 ms (12%) |
| `test_480p.m1v` | 278.2 ms (47%) | 1239.8 ms (53%) | n/a | 3324.7 ms (13%) |
| `test.m1v` | 1427.5 ms (49%) | 6294.9 ms (54%) | n/a | 16 797.6 ms (14%) |

### Process wall time (s)

This is what a user actually waits for. For the interpreters it includes daslang startup
plus compiling the module on every run.

| stream | C `-O2` | C `-O0` | c2das | plmpeg-stream |
|---|---|---|---|---|
| `sample.m1v` | 0.005 | 0.011 | 0.942 | 0.609 |
| `hd8_test.m1v` | 0.078 | 0.287 | 4.629 | 3.794 |
| `hd_test.m1v` | 0.020 | 0.058 | 1.610 | 1.463 |
| `test_480p.m1v` | 0.595 | 2.359 | 35.764 | 26.158 |
| `test.m1v` | 2.896 | 11.573 | 164.722 | 124.124 |

Fixed per-run overhead, measured directly with `-compile-only`:

| | source size | daslang compile | startup + compile + I/O (wall − decode) |
|---|---|---|---|
| c2das `all_bench.das` | 6501 lines (from 4601 lines of C) | 0.77–0.80 s | ≈ 0.81 s |
| plmpeg-stream `src/main.das` | 2718 lines | 0.53–0.56 s | ≈ 0.53 s |

Transpiling `all_bench.c` → `all_bench.das` takes a further **3.3 s**, but that is a build
step, not a per-run cost.

## Hash agreement matrix

| stream | C `-O2` | C `-O0` | c2das | plmpeg-stream |
|---|---|---|---|---|
| `sample.m1v` | `e2fcf7fa` (11 fr) | `e2fcf7fa` ✅ | `e2fcf7fa` ✅ | `42b5cd18` (12 fr) ❌ |
| `hd8_test.m1v` | `65effd87` (7 fr) | `65effd87` ✅ | `65effd87` ✅ | `c5405351` (8 fr) ❌ |
| `hd_test.m1v` | `24536797` (1 fr) | `24536797` ✅ | `24536797` ✅ | `9217d126` (2 fr) ❌ |
| `test_480p.m1v` | `08a9f38a` (124 fr) | `08a9f38a` ✅ | `08a9f38a` ✅ | `bdd00381` (125 fr) ❌ |
| `test.m1v` | `54999745` (124 fr) | `54999745` ✅ | `54999745` ✅ | `dab249f5` (125 fr) ❌ |

**c2das is bit-exact against native C on all five streams — no translator bug to report.**
That includes `test.m1v` (2 MB stream, 1920×1080, 124 frames) inside the 64 MB
`c2da_rt_heap`.

**plmpeg-stream disagrees on all five streams, from a single cause: it emits exactly one
extra trailing frame.** Clamping it to C's frame count makes the hash match bit-for-bit
everywhere:

| stream | frame limit | C | plmpeg-stream clamped |
|---|---|---|---|
| `sample.m1v` | 11 | `e2fcf7fa` | `e2fcf7fa` ✅ |
| `hd8_test.m1v` | 7 | `65effd87` | `65effd87` ✅ |
| `hd_test.m1v` | 1 | `24536797` | `24536797` ✅ |
| `test_480p.m1v` | 124 | `08a9f38a` | `08a9f38a` ✅ |
| `test.m1v` | 124 | `54999745` | `54999745` ✅ |

Walking `sample.m1v` frame by frame (limit 1…12) shows frames 1–11 hash identically in C and
in the port, so the port's pixel output is byte-identical for every real frame; the
divergence is purely **end-of-stream handling — the port returns one more frame after
upstream `plm_video_decode` has already returned `NULL`**. This is the port's bug, not
ours; it was not fixed here. Its README ("all 12 frames of the test sample") suggests the
off-by-one has been there since the port was written. Practical effect on the benchmark: it
does one frame more work per stream — negligible at 125 vs 124 frames, but 2× on
`hd_test.m1v` (2 vs 1) and +14% on `hd8_test.m1v` (8 vs 7).

## Where the time goes

`--das-profiler --das-profiler-time-unit ms` with stdout redirected to a file works.
(`--das-profiler-log-file` produced a 0-byte file and swallowed program stdout; and the
profiler OOM-killed the process on `test_480p.m1v`, twice.) The profile below is c2das on
`hd8_test.m1v`, where the profiler inflates decode from 4.3 s to 16.1 s (3.7×). The output
is an inclusive call tree; self time is inclusive minus children.

| # | function | self ms | % | calls |
|---|---|---|---|---|
| 1 | `plm_frame_to_rgb` | ~7062 | 44.0% | 7 |
| 2 | `plm_clamp` | ~5587 | 34.8% | 19 675 048 |
| 3 | `fold_bytes` | 1808 | 11.3% | 7 |
| 4 | `plm_video_process_macroblock` | 667 | 4.2% | 64 641 |
| 5 | `plm_video_decode_block` | ~284 | 1.8% | 23 891 |
| 6 | `plm_buffer_read` | ~237 | 1.5% | 300 468 |
| 7 | `plm_buffer_read_vlc` | ~107 | 0.7% | 90 246 |
| 8 | `plm_buffer_has` | ~95 | 0.6% | 301 507 |
| 9 | `plm_video_decode_macroblock` | ~40 | 0.25% | 7 286 |
| 10 | `plm_video_idct` / `c2da_rt_memset` | ~37 / ~32 | 0.2% | 4 149 / 4 150 |

The story is call overhead on flat per-byte loops, not MPEG arithmetic: `plm_clamp` is
called 19.35 M times from `plm_frame_to_rgb` alone (7 × 1280 × 720 × 3 — one interpreter
call per output RGB byte) where native C inlines it to two `cmov`s. `plm_frame_to_rgb` +
`plm_clamp` + `fold_bytes` together are ~90% of the run; the actual bitstream parsing and
IDCT are under 10%.

## Interpretation

The translated decoder runs **52–59× slower than `clang-18 -O2`** and **13–18× slower than
`-O0`**, consistently across streams from 96×64 to 1920×1080 — the ratio does not degrade
with resolution, which says the cost is a flat per-operation interpreter tax rather than
anything pathological the translation introduces. Against the hand-written daslang port,
c2das is **1.3–1.9× slower** on equal frame counts (1.92× on `sample`, 1.30× on `hd8_test`,
1.90× on `hd_test`, 1.32× on `test_480p`, ~1.34× on `test`), which is a much better result
than the raw-byte memory model would suggest: the c2das build routes every struct field
access through `c2da_rt_heap` offsets while the port uses native daScript structs, and that
costs well under a factor of two. Two-thirds of both interpreters' time goes to
`plm_frame_to_rgb` and the RGB byte-fold — flat per-pixel loops where the interpreter pays
one dispatch per byte — so the gap that matters for real use is not in the MPEG decoder at
all, and any future win (JIT, or lowering `plm_clamp`-style helpers) would land there
first. In wall-clock terms the practical picture is that the 22 KB fixture clip is
essentially free (0.94 s per run, 86% of it process startup plus daslang compiling the
6.5k-line module), 480p
decodes at 3.6 fps and 1080p at 0.76 fps — usable for correctness gates and offline
verification, not for playback. Finally, the correctness result is the more valuable one:
c2das reproduces native C bit-for-bit on all five streams including a 2 MB 1080p input,
while the independent hand-written port does not.

## Reproducing

The harness sources live under `/tmp/c2das-perf` (scratch, not committed). The two
non-obvious pieces — the `int64_t` address API in `bench_module.c` and the
`reinterpret<uint8?>` byte feed in `bench_entry.das` — are quoted in full above, and
`bench_c.c`'s timed loop and `bench_hash.das` are quoted in full as well, so the benchmark
can be rebuilt from this document alone plus the fixture at
`tests/manual/real-world-plmpeg-stream/`.

## Inlining tiny static functions

The profile above puts `plm_clamp` second at 34.8% of the run and **19 675 048 calls** —
one interpreter dispatch per output RGB byte, for a helper that native C folds into two
`cmov`s. That is the first thing to remove, and this section is what removing it did.

### What daslang offers, and why it is not enough

daslang 0.6.4 **does** have an `[inline]` function annotation, plus a heuristic tier behind
`options auto_inline_functions`. Both were measured with a 20 M-iteration loop over a clamp
helper (`/tmp/c2das-perf/inline_probe/`, run as `$(bash scripts/find_daslang.sh) probe.das`;
minimum of three runs, same machine as the tables above):

| probe | callee shape | ms / 20 M calls |
|---|---|---|
| `probe_plain` | plain `def`, `if`/`elif` body | 479.1 |
| `probe_inline` | `[inline]` on the same body | 485.3 |
| `probe_auto` | plain `def` + `options auto_inline_functions` | 526.8 |
| `probe_tern_plain` | plain `def`, `return c ? a : b` body | 304.0 |
| `probe_tern_inline` | `[inline]` on the ternary body | 271.0 |
| `probe_manual` | no function at all, ternary written at the call site | 277.2 |

`options log_optimization` confirms the splice really happens
(`INLINE plm_clamp into main at probe_inline_log.das:19:15`), so the annotation works — it
just buys **nothing** on a statement-shaped body: the interpreter pays about as much for the
spliced `if`/`elif` and its temps as for the call it replaced. What actually pays is turning
the body into one *expression*: 479 ms → 277 ms, a 1.7× cut, and that has nothing to do with
who does the inlining.

And on the body this translator actually emits, `[inline]` is not merely useless, it is
rejected. A C function body crosses through the CFG relooper, so `plm_clamp` comes out as

```das
def plm_clamp(var n_0 : int) : uint8 {
    var c2da_fresh357 : int = int(0)
    if (n_0 > int(255)) { c2da_fresh357 = int(1) }
    if (c2da_fresh357 != 0) { goto label 3 }
    ...
    label 3:
    n_0 = int(255)
    goto label 1
    panic("unreachable: fell out of a translated control-flow graph")
}
```

and `[inline]` is a fail-closed contract:

```
error[50501]: function annotation lint failed
[inline] body contains goto
```

That relooped shape is also far more expensive than the C source suggests. The same 20 M-call
probe against it:

| probe | ms / 20 M calls |
|---|---|
| `probe_real_call` — a call to the relooped body, verbatim from `all_bench.das` | 1119.4 |
| `probe_real_subst` — the conditional chain substituted at the call site | 338.4 |

**3.3×.** So the substitution has to happen in the translator, on the C AST, before the body
ever reaches the relooper. (There is no builtin `clamp` to lower onto, either:
`clamp(int, int, int)` is `error[30341]: no matching functions or generics`.)

### The rule

`c2dascript-transpile/src/translator/inline.rs` decides candidacy from the C AST;
`translator/functions.rs::convert_function_call` consults it before lowering the callee. A C
function is a candidate when

* it has a body and **internal linkage** (`static`) — no ABI surface another translation unit
  can observe;
* it is not variadic, takes at most four parameters, and every parameter type and the return
  type is an **arithmetic** C type (integer, enumeration, `float`/`double`). Records, arrays
  and pointers cross ABI boundaries of their own and are not duplicated into a call site;
* its body is either `return <expr>;` or the **clamp shape** — one `if`/`else` chain whose
  every arm assigns one and the same parameter, followed by `return <that parameter>;`
  (a trailing bare `else` is allowed);
* every expression in it is **pure**: literals, reads of this function's own parameters,
  enumeration constants, casts, arithmetic/comparison/logical/bitwise operators, `?:`, and
  direct calls to other candidates. No loops, no locals, no statics, no globals, no `&`, no
  `++`/`--`, no assignment beyond the clamp shape's own, no other calls;
* it does not reach itself. Direct recursion is rejected at analysis time; mutual recursion
  declines at the call site, off an expansion stack.

The **original definition is still emitted** — another translation unit, or a function
pointer taken in this one, may still reach it. Only *direct* calls are substituted, and a
call whose result is discarded, or that sits in a constant initializer, keeps its call.

At the call site each argument crosses exactly as a call would — converted at the parameter's
C type through `lower_to_c_value` with `ValueSite::CallArg`, so promotion and narrowing are
unchanged — and then binds a `var` temp unless it is already a leaf (a name or a literal).
If any argument needs a temp, all of them get one, so the arguments keep C's evaluation order
relative to each other; that is what makes `clamp(i++)` evaluate `i++` once even though the
body reads its parameter three times. The clamp shape becomes a conditional-expression chain,
and the body's own `return` expression is converted with the parameter bound to that chain,
so the function's return conversion is applied to the result exactly once. Any piece that
would need statements of its own inside a conditional arm declines and falls back to a real
call, so nothing is ever hoisted out of the arm that guards it.

`plm_frame_to_rgb` goes from

```das
unsafe(...[int(d_index_0 + int(0) + int(0))]) = uint8(uint8(plm_clamp(y_11 + r_0)))
```

to

```das
var c2da_fresh433 : int = y_11 + r_0
unsafe(...[int(d_index_0 + int(0) + int(0))]) = uint8(uint8(c2da_fresh433 > int(255) ? int(255) : c2da_fresh433 < int(0) ? int(0) : c2da_fresh433))
```

All 76 direct `plm_clamp` calls in `all_bench.das` disappear; the definition stays.
The module grows from 6501 to 6577 lines, and transpiling it still takes ~3.0 s.

`--no-inline` turns the whole thing off, and its output is **byte-identical** to the
translator's output before this change — which is how the two columns below were produced.

### Results

Minimum of three runs per cell, serial, idle machine, same box as every other table here.

| stream | `--no-inline` | inlined | speedup | hash |
|---|---|---|---|---|
| `sample.m1v` 96×64, 11 fr | 127.416 ms | **118.392 ms** | 1.08× | `e2fcf7fa` ✅ |
| `hd8_test.m1v` 1280×720, 7 fr | 3803.530 ms | **3219.099 ms** | 1.18× | `65effd87` ✅ |
| `test_480p.m1v` 854×480, 124 fr | 34 273.750 ms | **30 967.625 ms** | 1.11× | `08a9f38a` ✅ |

Every hash is unchanged, so the decoded pixels are still bit-identical to `clang-18 -O2`.

The h264bsd + minimp4 canonical case is unaffected either way. The only substitution the rule
finds in its 39 224-line graph is `rotl32` in the fixture's own summary hashing — four call
sites, none of them hot — and the daslang run times the same to within noise (minimum of
three, `date +%s.%N` around `daslang input/src/h264_entry.das -main main` in a
`--keep-workdir` workspace): **4.088 s** with `--no-inline`, **4.087 s** inlined, with
byte-identical stdout.

The win is smaller than the 34.8% the profile attributes to `plm_clamp`, because the profiler
charges an instrumentation cost per call and there were 19.35 M of them — which is also why
the profiled run itself drops from 16.1 s to 3.85 s. The uninstrumented gain on `hd8_test` is
584 ms of 3804, or 15.4%.

### Where the time goes now

`--das-profiler --das-profiler-time-unit ms` on `hd8_test.m1v`, same redirect quirk as above.
`plm_clamp` no longer appears at all.

| # | function | self ms | % | calls |
|---|---|---|---|---|
| 1 | `plm_frame_to_rgb` | 1272 | 33.0% | 7 |
| 2 | `fold_bytes` | 1137 | 29.5% | 7 |
| 3 | `plm_video_process_macroblock` | 617 | 16.0% | 64 641 |
| 4 | `plm_buffer_read` | 222 | 5.8% | 308 496 |
| 5 | `plm_video_decode_block` | 211 | 5.5% | 23 891 |

The remaining two thirds are the flat per-pixel loops themselves — `plm_frame_to_rgb`'s body
and the RGB byte-fold — where the interpreter pays one dispatch per *operation*, not per
call. No further call-elimination reaches those; a JIT or a lower-level lowering of the loop
bodies does.

### Reproducing this section

```sh
# translate both ways from the same C
cargo run -q -p c2dascript-transpile -- --strict --output-dir <dir> --file <dir>/all_bench.c \
  -DPLM_NO_STDIO -I<dir>/include -I<upstream> -I<dir> -w
cargo run -q -p c2dascript-transpile -- --strict --no-inline --output-dir <dir-noinline> ...

# run each three times per stream
daslang -dasroot <das_root> bench_entry.das -- <stream>.m1v
```

The canonical regression case for the rule itself is
`tests/syntax/p71_static_inline_calls.c` (`p71-static-inline-calls`): side-effecting
arguments, narrow parameter and return types, a candidate calling a candidate, a candidate
taken by address and called through the pointer, a loop and a recursion that must stay calls,
and calls in positions C only sometimes evaluates.
