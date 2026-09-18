/* C-reference entrypoint for the canonical H264BSD + minimp4 graph.
 *
 * Scalar-only by design: every probe returns int32_t, so the oracle needs no
 * host-pointer transport ABI.  The lines printed here are the contract that
 * `src/h264_entry.das` must reproduce, in this order: the demuxer and decoder
 * probes, then every decoded picture's YUV hash from the streaming API.
 *
 * `-Iinclude` shadows the real <stdio.h> with the fixture's decoder-only stub
 * (an opaque `FILE` and nothing else), so the few libc entrypoints this file
 * needs are declared locally instead of included.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

extern FILE *stdout;

int printf(const char *format, ...);
int setvbuf(FILE *stream, char *buffer, int mode, size_t size);

int32_t h264mp4_probe_memory_read_status(void);
int32_t h264mp4_probe_memory_read_word0(void);
int32_t h264mp4_probe_minimp4_first_box_name(void);
int32_t h264mp4_probe_minimp4_second_box_name(void);
int32_t h264mp4_probe_track_index(void);
int32_t h264mp4_probe_sample_count(void);
int32_t h264mp4_probe_width(void);
int32_t h264mp4_probe_height(void);
int32_t h264mp4_probe_frame_count(int32_t frame_limit);
int32_t h264mp4_frames_begin(void);
int32_t h264mp4_frames_next(void);
int32_t h264mp4_frames_hash(void);
int32_t h264mp4_frames_index(void);
int32_t h264mp4_frames_end(void);

int main(void) {
    int32_t width = 0;
    int32_t height = 0;
    int32_t frame_count = 0;
    int frames = 0;

    /* Mandatory: with a buffered stdout glibc takes its buffer from shim.c's
     * bump allocator, and the first `shim_reset_heap()` inside a probe hands
     * that same memory back to the decoder, which then overwrites the text
     * still waiting to be flushed. */
    setvbuf(stdout, NULL, 2 /* _IONBF */, 0);

    printf("memory_read_status=%d\n", (int)h264mp4_probe_memory_read_status());
    printf("memory_read_word0=%d\n", (int)h264mp4_probe_memory_read_word0());
    printf("first_box_name=%d\n", (int)h264mp4_probe_minimp4_first_box_name());
    printf("second_box_name=%d\n", (int)h264mp4_probe_minimp4_second_box_name());
    /* h264mp4_probe_mp4d_open_track_count is deliberately not pinned: it reads
     * mp4.track_count *after* MP4D_close, i.e. released demuxer state. */
    printf("track_index=%d\n", (int)h264mp4_probe_track_index());
    printf("sample_count=%d\n", (int)h264mp4_probe_sample_count());

    width = h264mp4_probe_width();
    height = h264mp4_probe_height();
    frame_count = h264mp4_probe_frame_count(8);

    printf("width=%d\n", (int)width);
    printf("height=%d\n", (int)height);
    printf("frame_count=%d\n", (int)frame_count);

    if (width <= 0 || height <= 0 || frame_count <= 0) {
        return 1;
    }

    if (!h264mp4_frames_begin()) {
        printf("frames_begin=0\n");
        return 1;
    }
    while (h264mp4_frames_next()) {
        printf("frame[%d]=%d\n", (int)h264mp4_frames_index(), (int)h264mp4_frames_hash());
        frames += 1;
    }
    h264mp4_frames_end();
    printf("frames=%d\n", frames);
    return frames > 0 ? 0 : 1;
}
