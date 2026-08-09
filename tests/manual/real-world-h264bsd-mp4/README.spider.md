# H264BSD + MP4 Real-World Comparison

This fixture combines two upstream repositories:

- [`lieff/minimp4`](https://github.com/lieff/minimp4) for MP4 demux
- [`oneam/h264bsd`](https://github.com/oneam/h264bsd) for H.264 decode

The wasm module is built as a standalone non-WASI memory-backed decode-only fixture:
- `src/minimp4.c` provides the header-only demux implementation
- `src/h264bsd.c` aggregates upstream decoder `.c` files
- `src/shim.c` provides a simple standalone heap and libc-style helpers
- `src/module.c` embeds a canonical `sample.mp4` clip and exports:
  - `h264mp4_decode_hash(i32 frame_limit) -> i32`
  - `h264mp4_probe_width() -> i32`
  - `h264mp4_probe_height() -> i32`
  - `h264mp4_probe_frame_count(i32 frame_limit) -> i32`
  - `h264mp4_probe_first_frame_hash() -> i32`
  - `h264mp4_probe_last_frame_hash(i32 frame_limit) -> i32`
- the same module also exposes a plain-Lua host adapter path for real `.mp4` files:
  - `h264mp4_host_alloc(i32 size) -> i32`
  - `h264mp4_host_reset() -> i32`
  - `h264mp4_host_load(i32 bytes_ptr, i32 bytes_len) -> i32`
  - `h264mp4_host_decode_frame(i32 frame_index) -> i32`
  - `h264mp4_host_get_y_ptr() -> i32`
  - `h264mp4_host_get_u_ptr() -> i32`
  - `h264mp4_host_get_v_ptr() -> i32`
  - `h264mp4_host_get_y_size() -> i32`
  - `h264mp4_host_get_u_size() -> i32`
  - `h264mp4_host_get_v_size() -> i32`
  - `h264mp4_host_get_width() -> i32`
  - `h264mp4_host_get_height() -> i32`

Chosen v1 scope:
- MP4 input only
- H.264/AVC video only
- no audio
- no encode
- no generalized streaming API
- canonical parity is based on decoded `YUV420` frame data

The committed canonical clip is:
- `96x64`
- `12` frames
- H.264 baseline in `sample.mp4`
- generated deterministically from `ffmpeg` `testsrc2`

## Canonical Commands

From the repository root:

```powershell
cargo build --release -p spider-cli
```

```powershell
D:\Backups\WASI\wasi-sdk-24.0\bin\clang.exe --% --target=wasm32 -O2 -nostdlib -Wl,--no-entry -Wl,--export-all -Itests/manual/real-world-h264bsd-mp4/include tests/manual/real-world-h264bsd-mp4/src/module.c tests/manual/real-world-h264bsd-mp4/src/shim.c tests/manual/real-world-h264bsd-mp4/src/minimp4.c tests/manual/real-world-h264bsd-mp4/src/h264bsd.c -o tests/manual/real-world-h264bsd-mp4/generated/h264mp4.wasm
```

```powershell
D:\Backups\wasmtime\wasmtime-v24.0.1\wasmtime.exe -C cache=n --invoke h264mp4_decode_hash tests/manual/real-world-h264bsd-mp4/generated/h264mp4.wasm 8
D:\Backups\wasmtime\wasmtime-v24.0.1\wasmtime.exe -C cache=n --invoke h264mp4_probe_width tests/manual/real-world-h264bsd-mp4/generated/h264mp4.wasm
D:\Backups\wasmtime\wasmtime-v24.0.1\wasmtime.exe -C cache=n --invoke h264mp4_probe_height tests/manual/real-world-h264bsd-mp4/generated/h264mp4.wasm
D:\Backups\wasmtime\wasmtime-v24.0.1\wasmtime.exe -C cache=n --invoke h264mp4_probe_frame_count tests/manual/real-world-h264bsd-mp4/generated/h264mp4.wasm 8
D:\Backups\wasmtime\wasmtime-v24.0.1\wasmtime.exe -C cache=n --invoke h264mp4_probe_first_frame_hash tests/manual/real-world-h264bsd-mp4/generated/h264mp4.wasm
D:\Backups\wasmtime\wasmtime-v24.0.1\wasmtime.exe -C cache=n --invoke h264mp4_probe_last_frame_hash tests/manual/real-world-h264bsd-mp4/generated/h264mp4.wasm 8
```

```powershell
$text = & target\release\spider-cli.exe tests\manual\real-world-h264bsd-mp4\generated\h264mp4.wasm -t lua-no-ffi
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText((Resolve-Path "tests/manual/real-world-h264bsd-mp4/generated/h264mp4.lua"), ($text -join [Environment]::NewLine), $utf8NoBom)
```

```powershell
luajit tests/manual/real-world-h264bsd-mp4/main.lua lua-no-ffi 8
```

## External Host Adapter Visual Test

This fixture also includes a real file-based smoke test through plain Lua file APIs:
- reads a real `.mp4` from disk with `io.open(..., "rb")`
- copies the bytes into wasm memory
- decodes frame `0`
- tries to decode frame `7`, and falls back to the highest available frame down to `1`
- reads decoded `YUV420` planes back out of wasm memory
- converts them to RGB in Lua
- writes each decoded frame as a `P6` `.ppm` file

The host adapter script is:
- [host_main.lua](/D:/Backups/Spider/tests/manual/real-world-h264bsd-mp4/host_main.lua:1)

Run it like this:

```powershell
luajit tests/manual/real-world-h264bsd-mp4/host_main.lua lua-no-ffi
```

Or with your own baseline `.mp4`:

```powershell
luajit tests/manual/real-world-h264bsd-mp4/host_main.lua lua-no-ffi path\to\your.mp4
```

Decode one exact frame without fallback:

```powershell
luajit tests/manual/real-world-h264bsd-mp4/host_main.lua lua-no-ffi tests/manual/real-world-h264bsd-mp4/fixtures/sample.mp4 --frame 7
```

Decode every available frame, optionally capped by a max count:

```powershell
luajit tests/manual/real-world-h264bsd-mp4/host_main.lua lua-no-ffi tests/manual/real-world-h264bsd-mp4/fixtures/sample.mp4 --all-frames
luajit tests/manual/real-world-h264bsd-mp4/host_main.lua lua-no-ffi tests/manual/real-world-h264bsd-mp4/fixtures/sample.mp4 --all-frames 8
```

Expected outputs:
- `tests/manual/real-world-h264bsd-mp4/generated/frames/sample_frame000.ppm`
- `tests/manual/real-world-h264bsd-mp4/generated/frames/sample_frame007.ppm` (or `frame006..frame001` fallback)

The default mode is still the original smoke workflow:

- decode frame `0`
- then try frame `7`, with fallback `6..1`

The new `--frame N` mode is a targeted manual runner:

- decode exactly frame `N`
- write exactly one `PPM`
- fail clearly if that frame is unavailable

The new `--all-frames [max]` mode is a sequential manual runner:

- start at frame `0`
- keep requesting increasing frame indices until decode fails or `max` is reached
- write one `PPM` per decoded frame under `generated/frames/`

## Wasmtime Host Runner

For a symmetric host-in-the-loop comparison against the Lua host script, use:

- [Tools/WasmtimeHostRunner](/D:/Backups/Spider/Tools/WasmtimeHostRunner/src/main.rs:1)

The runner now supports this fixture through the explicit `h264mp4` fixture flag:

```powershell
cargo build --release -p wasmtime-host-runner
target\release\wasmtime-host-runner.exe --fixture h264mp4 --mode baseline --wasm tests\manual\real-world-h264bsd-mp4\generated\h264mp4.wasm --input tests\manual\real-world-h264bsd-mp4\fixtures\sample.mp4 --frames 12 --output-dir tests\manual\real-world-h264bsd-mp4\generated\frames_wasmtime
```

Current rough `wasmtime` result on the canonical `12`-frame clip with frame writes:

- `12` frames decoded
- about `78.56 ms` total

This runner is still fixture-specific rather than universal:

- it knows concrete `h264mp4_*` export names
- it exists to mirror the manual host workflow closely enough for honest comparison
- it should be treated as a practical utility for the current video fixtures, not as a finalized shared host-runner framework

## Useful Manual Commands

Convert generated `.ppm` frames to `.png` for quick visual inspection:

```powershell
ffmpeg -y -i D:\Backups\Spider\tests\manual\real-world-h264bsd-mp4\generated\frames\sample_frame000.ppm D:\Backups\Spider\tests\manual\real-world-h264bsd-mp4\generated\frames\sample_frame000.png
ffmpeg -y -i D:\Backups\Spider\tests\manual\real-world-h264bsd-mp4\generated\frames\sample_frame007.ppm D:\Backups\Spider\tests\manual\real-world-h264bsd-mp4\generated\frames\sample_frame007.png
```

Generate another small baseline-profile sample:

```powershell
ffmpeg -y -f lavfi -i testsrc2=size=96x64:rate=12 -frames:v 12 -c:v libx264 -profile:v baseline -pix_fmt yuv420p -bf 0 -an D:\Backups\Spider\tests\manual\real-world-h264bsd-mp4\fixtures\my_sample.mp4
```

Run the host smoke directly on your own `.mp4`:

```powershell
luajit D:\Backups\Spider\tests\manual\real-world-h264bsd-mp4\host_main.lua lua-no-ffi D:\path\to\your_video.mp4
```

If your source video is a more modern H.264 variant, first re-encode it into the constrained baseline-friendly shape that this v1 fixture expects:

```powershell
ffmpeg -y -i "video_in.mp4" -an -c:v libx264 -profile:v baseline -pix_fmt yuv420p -bf 0 "video_out.mp4"
```

Then run the fixture on the converted file:

```powershell
luajit D:\Backups\Spider\tests\manual\real-world-h264bsd-mp4\host_main.lua lua-no-ffi D:\Backups\Spider\tests\manual\real-world-h264bsd-mp4\fixtures\your_video_baseline.mp4
```

## Current Result

This fixture is now green on the narrowed v1 scope:

- `wasmtime` and `lua-no-ffi` match on the canonical `frame_limit = 8` probe set
- `host_main.lua` writes real decoded `PPM` frames for `sample.mp4`
- the canonical values are:
  - `DecodeHash = -419184337`
  - `Width = 96`
  - `Height = 64`
  - `FrameCount = 8`
  - `FirstFrameHash = -53578803`
  - `LastFrameHash = 131893473`

The current scope is still intentionally narrow:

- constrained baseline-profile MP4 only
- no audio
- no generalized streaming API
- parity is defined on decoded `YUV420` frame data, not RGB presentation output
