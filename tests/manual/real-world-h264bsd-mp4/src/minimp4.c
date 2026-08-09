#define MINIMP4_IMPLEMENTATION
#include "../upstream/minimp4/minimp4.h"

int c2da_probe_minimp4_read4(int (*read_callback)(int64_t offset, void *buffer, size_t size, void *token), void *token, int64_t file_size) {
    MP4D_demux_t mp4;
    int eof_flag = 0;

    memset(&mp4, 0, sizeof(MP4D_demux_t));
    mp4.read_callback = read_callback;
    mp4.token = token;
    mp4.read_size = file_size;

    return (int)minimp4_read(&mp4, 4, &eof_flag);
}

int c2da_probe_minimp4_first_box_name(int (*read_callback)(int64_t offset, void *buffer, size_t size, void *token), void *token, int64_t file_size) {
    MP4D_demux_t mp4;
    int eof_flag = 0;

    memset(&mp4, 0, sizeof(MP4D_demux_t));
    mp4.read_callback = read_callback;
    mp4.token = token;
    mp4.read_size = file_size;

    (void)minimp4_read(&mp4, 4, &eof_flag);
    return (int)minimp4_read(&mp4, 4, &eof_flag);
}

int c2da_probe_minimp4_first_box_read_pos(int (*read_callback)(int64_t offset, void *buffer, size_t size, void *token), void *token, int64_t file_size) {
    MP4D_demux_t mp4;
    int eof_flag = 0;

    memset(&mp4, 0, sizeof(MP4D_demux_t));
    mp4.read_callback = read_callback;
    mp4.token = token;
    mp4.read_size = file_size;

    (void)minimp4_read(&mp4, 4, &eof_flag);
    (void)minimp4_read(&mp4, 4, &eof_flag);
    return (int)mp4.read_pos;
}

int c2da_probe_minimp4_first_box_eof(int (*read_callback)(int64_t offset, void *buffer, size_t size, void *token), void *token, int64_t file_size) {
    MP4D_demux_t mp4;
    int eof_flag = 0;

    memset(&mp4, 0, sizeof(MP4D_demux_t));
    mp4.read_callback = read_callback;
    mp4.token = token;
    mp4.read_size = file_size;

    (void)minimp4_read(&mp4, 4, &eof_flag);
    (void)minimp4_read(&mp4, 4, &eof_flag);
    return eof_flag;
}

int c2da_probe_minimp4_second_box_name(int (*read_callback)(int64_t offset, void *buffer, size_t size, void *token), void *token, int64_t file_size) {
    MP4D_demux_t mp4;
    int eof_flag = 0;
    boxsize_t box_bytes;
    boxsize_t payload_bytes;

    memset(&mp4, 0, sizeof(MP4D_demux_t));
    mp4.read_callback = read_callback;
    mp4.token = token;
    mp4.read_size = file_size;

    box_bytes = minimp4_read(&mp4, 4, &eof_flag);
    (void)minimp4_read(&mp4, 4, &eof_flag);
    payload_bytes = box_bytes - 8;
    my_fseek(&mp4, payload_bytes, &eof_flag);
    (void)minimp4_read(&mp4, 4, &eof_flag);
    return (int)minimp4_read(&mp4, 4, &eof_flag);
}

int c2da_probe_minimp4_second_box_read_pos(int (*read_callback)(int64_t offset, void *buffer, size_t size, void *token), void *token, int64_t file_size) {
    MP4D_demux_t mp4;
    int eof_flag = 0;
    boxsize_t box_bytes;
    boxsize_t payload_bytes;

    memset(&mp4, 0, sizeof(MP4D_demux_t));
    mp4.read_callback = read_callback;
    mp4.token = token;
    mp4.read_size = file_size;

    box_bytes = minimp4_read(&mp4, 4, &eof_flag);
    (void)minimp4_read(&mp4, 4, &eof_flag);
    payload_bytes = box_bytes - 8;
    my_fseek(&mp4, payload_bytes, &eof_flag);
    (void)minimp4_read(&mp4, 4, &eof_flag);
    (void)minimp4_read(&mp4, 4, &eof_flag);
    return (int)mp4.read_pos;
}

int c2da_probe_mp4d_open_read_pos(int (*read_callback)(int64_t offset, void *buffer, size_t size, void *token), void *token, int64_t file_size) {
    MP4D_demux_t mp4;

    if (MP4D_open(&mp4, read_callback, token, file_size) != 0) {
        MP4D_close(&mp4);
        return -1;
    }

    return (int)mp4.read_pos;
}

int c2da_probe_mp4d_open_track_count(int (*read_callback)(int64_t offset, void *buffer, size_t size, void *token), void *token, int64_t file_size) {
    MP4D_demux_t mp4;

    if (MP4D_open(&mp4, read_callback, token, file_size) == 0) {
        return -1;
    }

    MP4D_close(&mp4);
    return (int)mp4.track_count;
}
