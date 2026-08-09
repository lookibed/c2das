#include <stddef.h>
#include <stdint.h>

#include "../upstream/h264bsd/src/h264bsd_byte_stream.h"
#include "../upstream/h264bsd/src/h264bsd_decoder.h"
#include "../upstream/h264bsd/src/h264bsd_nal_unit.h"
#include "../upstream/h264bsd/src/h264bsd_seq_param_set.h"
#include "../upstream/h264bsd/src/h264bsd_slice_data.h"
#include "../upstream/h264bsd/src/h264bsd_slice_header.h"
#include "../upstream/h264bsd/src/h264bsd_storage.h"
#include "../upstream/minimp4/minimp4.h"
#include "sample_mp4_data.h"

void *malloc(size_t size);
void free(void *ptr);
void *realloc(void *ptr, size_t size);
void *memcpy(void *dest, const void *src, size_t count);
void *memset(void *dest, int value, size_t count);
void shim_reset_heap(void);
int c2da_probe_minimp4_read4(int (*read_callback)(int64_t offset, void *buffer, size_t size, void *token), void *token, int64_t file_size);
int c2da_probe_minimp4_first_box_name(int (*read_callback)(int64_t offset, void *buffer, size_t size, void *token), void *token, int64_t file_size);
int c2da_probe_minimp4_first_box_read_pos(int (*read_callback)(int64_t offset, void *buffer, size_t size, void *token), void *token, int64_t file_size);
int c2da_probe_minimp4_first_box_eof(int (*read_callback)(int64_t offset, void *buffer, size_t size, void *token), void *token, int64_t file_size);
int c2da_probe_minimp4_second_box_name(int (*read_callback)(int64_t offset, void *buffer, size_t size, void *token), void *token, int64_t file_size);
int c2da_probe_minimp4_second_box_read_pos(int (*read_callback)(int64_t offset, void *buffer, size_t size, void *token), void *token, int64_t file_size);
int c2da_probe_mp4d_open_read_pos(int (*read_callback)(int64_t offset, void *buffer, size_t size, void *token), void *token, int64_t file_size);
int c2da_probe_mp4d_open_track_count(int (*read_callback)(int64_t offset, void *buffer, size_t size, void *token), void *token, int64_t file_size);

typedef struct DecodeSummary {
    uint32_t combined_hash;
    uint32_t first_hash;
    uint32_t last_hash;
    int frame_count;
    int width;
    int height;
} DecodeSummary;

typedef struct DecoderState {
    storage_t *storage;
    int width;
    int height;
    uint8_t *picture;
} DecoderState;

typedef struct MemoryInput {
    const uint8_t *bytes;
    int length;
} MemoryInput;

static uint8_t *host_bytes = 0;
static int host_length = 0;
static uint8_t *host_picture = 0;
static int host_width = 0;
static int host_height = 0;
static int host_y_size = 0;
static int host_u_size = 0;
static int host_v_size = 0;

static uint32_t rotl32(uint32_t value, unsigned int shift) {
    return (value << shift) | (value >> (32u - shift));
}

static uint32_t fold_bytes(const uint8_t *bytes, int length) {
    uint32_t hash = 0x811C9DC5u;
    int index = 0;

    for (index = 0; index < length; index++) {
        hash ^= bytes[index];
        hash *= 16777619u;
        hash = rotl32(hash, 5u);
    }

    return hash;
}

static int memory_read_callback(int64_t offset, void *buffer, size_t size, void *token) {
    MemoryInput *input = (MemoryInput *)token;

    if (offset < 0) {
        return 1;
    }

    if ((offset + (int64_t)size) > input->length) {
        return 1;
    }

    memcpy(buffer, input->bytes + (size_t)offset, size);
    return 0;
}

int32_t h264mp4_probe_memory_read_status(void) {
    MemoryInput input;
    uint8_t bytes[4];

    input.bytes = (const uint8_t *)sample_mp4_bytes;
    input.length = (int)sample_mp4_len;
    bytes[0] = 0xFFu;
    bytes[1] = 0xFFu;
    bytes[2] = 0xFFu;
    bytes[3] = 0xFFu;

    return memory_read_callback(0, bytes, 4u, &input);
}

int32_t h264mp4_probe_memory_read_word0(void) {
    MemoryInput input;
    uint8_t bytes[4];

    input.bytes = (const uint8_t *)sample_mp4_bytes;
    input.length = (int)sample_mp4_len;
    bytes[0] = 0xFFu;
    bytes[1] = 0xFFu;
    bytes[2] = 0xFFu;
    bytes[3] = 0xFFu;

    if (memory_read_callback(0, bytes, 4u, &input) != 0) {
        return -1;
    }

    return ((int32_t)bytes[0] << 24) | ((int32_t)bytes[1] << 16) | ((int32_t)bytes[2] << 8) | (int32_t)bytes[3];
}

int32_t h264mp4_probe_minimp4_read4(void) {
    MemoryInput input;

    input.bytes = (const uint8_t *)sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    return c2da_probe_minimp4_read4(memory_read_callback, &input, sample_mp4_len);
}

int32_t h264mp4_probe_minimp4_first_box_name(void) {
    MemoryInput input;

    input.bytes = (const uint8_t *)sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    return c2da_probe_minimp4_first_box_name(memory_read_callback, &input, sample_mp4_len);
}

int32_t h264mp4_probe_minimp4_first_box_read_pos(void) {
    MemoryInput input;

    input.bytes = (const uint8_t *)sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    return c2da_probe_minimp4_first_box_read_pos(memory_read_callback, &input, sample_mp4_len);
}

int32_t h264mp4_probe_minimp4_first_box_eof(void) {
    MemoryInput input;

    input.bytes = (const uint8_t *)sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    return c2da_probe_minimp4_first_box_eof(memory_read_callback, &input, sample_mp4_len);
}

int32_t h264mp4_probe_minimp4_second_box_name(void) {
    MemoryInput input;

    input.bytes = (const uint8_t *)sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    return c2da_probe_minimp4_second_box_name(memory_read_callback, &input, sample_mp4_len);
}

int32_t h264mp4_probe_minimp4_second_box_read_pos(void) {
    MemoryInput input;

    input.bytes = (const uint8_t *)sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    return c2da_probe_minimp4_second_box_read_pos(memory_read_callback, &input, sample_mp4_len);
}

int32_t h264mp4_probe_mp4d_open_read_pos(void) {
    MemoryInput input;

    input.bytes = (const uint8_t *)sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    return c2da_probe_mp4d_open_read_pos(memory_read_callback, &input, sample_mp4_len);
}

int32_t h264mp4_probe_mp4d_open_track_count(void) {
    MemoryInput input;

    input.bytes = (const uint8_t *)sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    return c2da_probe_mp4d_open_track_count(memory_read_callback, &input, sample_mp4_len);
}

static int find_avc_track(const MP4D_demux_t *mp4) {
    unsigned int index = 0;

    for (index = 0; index < mp4->track_count; index++) {
        const MP4D_track_t *track = mp4->track + index;

        if (track->handler_type == MP4D_HANDLER_TYPE_VIDE && track->object_type_indication == MP4_OBJECT_TYPE_AVC) {
            return (int)index;
        }
    }

    return -1;
}

static int sample_annexb_size(const uint8_t *sample, int sample_bytes, int length_size);

static int infer_length_size(const uint8_t *sample, int sample_bytes) {
    int candidate = 0;

    for (candidate = 4; candidate >= 1; candidate--) {
        if (sample_annexb_size(sample, sample_bytes, candidate) >= 0) {
            return candidate;
        }
    }

    return 0;
}

static int detect_track_length_size(
    const MP4D_demux_t *mp4,
    int track_index,
    const uint8_t *bytes,
    int total_bytes
) {
    unsigned int sample_index = 0;

    for (sample_index = 0; sample_index < mp4->track[track_index].sample_count; sample_index++) {
        unsigned int frame_bytes = 0;
        MP4D_file_offset_t offset = MP4D_frame_offset(mp4, (unsigned int)track_index, sample_index, &frame_bytes, 0, 0);

        if (frame_bytes == 0) {
            continue;
        }

        if ((offset + frame_bytes) > (unsigned int)total_bytes) {
            return 0;
        }

        return infer_length_size(bytes + offset, (int)frame_bytes);
    }

    return 0;
}

static int output_picture_width(storage_t *storage) {
    return (int)h264bsdPicWidth(storage) * 16;
}

static int output_picture_height(storage_t *storage) {
    return (int)h264bsdPicHeight(storage) * 16;
}

static int sample_annexb_size(const uint8_t *sample, int sample_bytes, int length_size) {
    int offset = 0;
    int total = 0;

    while (offset < sample_bytes) {
        int nal_size = 0;
        int length_index = 0;

        if ((sample_bytes - offset) < length_size) {
            return -1;
        }

        for (length_index = 0; length_index < length_size; length_index++) {
            nal_size = (nal_size << 8) | sample[offset + length_index];
        }

        offset += length_size;
        if (nal_size < 0 || (sample_bytes - offset) < nal_size) {
            return -1;
        }

        total += 4 + nal_size;
        offset += nal_size;
    }

    return total;
}

static int header_annexb_size(const MP4D_demux_t *mp4, int track_index) {
    int total = 0;
    int bytes = 0;
    int index = 0;
    const void *ptr = 0;

    while ((ptr = MP4D_read_sps(mp4, (unsigned int)track_index, index, &bytes)) != 0) {
        (void)ptr;
        total += 4 + bytes;
        index += 1;
    }

    index = 0;
    while ((ptr = MP4D_read_pps(mp4, (unsigned int)track_index, index, &bytes)) != 0) {
        (void)ptr;
        total += 4 + bytes;
        index += 1;
    }

    return total;
}

static int build_annexb_sample(
    const MP4D_demux_t *mp4,
    int track_index,
    const uint8_t *sample,
    int sample_bytes,
    int include_headers,
    uint8_t *scratch,
    int scratch_capacity,
    int length_size
) {
    int out = 0;
    int bytes = 0;
    int index = 0;
    const uint8_t start_code[4] = {0u, 0u, 0u, 1u};
    int offset = 0;
    const void *ptr = 0;

    if (include_headers) {
        while ((ptr = MP4D_read_sps(mp4, (unsigned int)track_index, index, &bytes)) != 0) {
            if ((out + 4 + bytes) > scratch_capacity) {
                return -1;
            }

            memcpy(scratch + out, start_code, 4u);
            out += 4;
            memcpy(scratch + out, ptr, (size_t)bytes);
            out += bytes;
            index += 1;
        }

        index = 0;
        while ((ptr = MP4D_read_pps(mp4, (unsigned int)track_index, index, &bytes)) != 0) {
            if ((out + 4 + bytes) > scratch_capacity) {
                return -1;
            }

            memcpy(scratch + out, start_code, 4u);
            out += 4;
            memcpy(scratch + out, ptr, (size_t)bytes);
            out += bytes;
            index += 1;
        }
    }

    while (offset < sample_bytes) {
        int nal_size = 0;
        int length_index = 0;

        if ((sample_bytes - offset) < length_size) {
            return -1;
        }

        for (length_index = 0; length_index < length_size; length_index++) {
            nal_size = (nal_size << 8) | sample[offset + length_index];
        }

        offset += length_size;
        if (nal_size < 0 || (sample_bytes - offset) < nal_size) {
            return -1;
        }

        if ((out + 4 + nal_size) > scratch_capacity) {
            return -1;
        }

        memcpy(scratch + out, start_code, 4u);
        out += 4;
        memcpy(scratch + out, sample + offset, (size_t)nal_size);
        out += nal_size;
        offset += nal_size;
    }

    return out;
}

static int decode_access_unit(DecoderState *state, const uint8_t *bytes, int length, int *picture_ready) {
    int offset = 0;

    *picture_ready = 0;

    while (offset < length) {
        u32 read_bytes = 0;
        u32 result = h264bsdDecode(state->storage, (u8 *)(bytes + offset), (u32)(length - offset), 0u, &read_bytes);

        if (result == H264BSD_ERROR || result == H264BSD_PARAM_SET_ERROR || result == H264BSD_MEMALLOC_ERROR) {
            return 0;
        }

        if (read_bytes == 0u && result != H264BSD_HDRS_RDY) {
            return 0;
        }

        offset += (int)read_bytes;

        if (result == H264BSD_HDRS_RDY) {
            state->width = output_picture_width(state->storage);
            state->height = output_picture_height(state->storage);
        }

        if (result == H264BSD_PIC_RDY) {
            u32 pic_id = 0;
            u32 is_idr_pic = 0;
            u32 num_err_mbs = 0;

            state->picture = h264bsdNextOutputPicture(state->storage, &pic_id, &is_idr_pic, &num_err_mbs);
            state->width = output_picture_width(state->storage);
            state->height = output_picture_height(state->storage);
            *picture_ready = 1;
        }
    }

    return 1;
}

static int decode_summary(const uint8_t *bytes, int length, int frame_limit, DecodeSummary *summary) {
    MemoryInput input;
    MP4D_demux_t mp4;
    int track_index = -1;
    int track_length_size = 0;
    int prefix_bytes = 0;
    int max_sample_bytes = 0;
    uint8_t *scratch = 0;
    DecoderState state;
    int sample_index = 0;

    memset(summary, 0, sizeof(DecodeSummary));
    memset(&mp4, 0, sizeof(MP4D_demux_t));
    input.bytes = bytes;
    input.length = length;

    if (MP4D_open(&mp4, memory_read_callback, &input, length) == 0) {
        return 0;
    }

    track_index = find_avc_track(&mp4);
    if (track_index < 0) {
        MP4D_close(&mp4);
        return 0;
    }

    track_length_size = detect_track_length_size(&mp4, track_index, bytes, length);
    if (track_length_size <= 0) {
        MP4D_close(&mp4);
        return 0;
    }

    prefix_bytes = header_annexb_size(&mp4, track_index);
    for (sample_index = 0; sample_index < (int)mp4.track[track_index].sample_count; sample_index++) {
        unsigned int frame_bytes = 0;
        MP4D_file_offset_t offset = MP4D_frame_offset(&mp4, (unsigned int)track_index, (unsigned int)sample_index, &frame_bytes, 0, 0);
        int annexb_bytes = 0;

        if ((offset + frame_bytes) > (unsigned int)length) {
            MP4D_close(&mp4);
            return 0;
        }

        annexb_bytes = sample_annexb_size(bytes + offset, (int)frame_bytes, track_length_size);
        if (annexb_bytes < 0) {
            MP4D_close(&mp4);
            return 0;
        }

        if ((annexb_bytes + prefix_bytes) > max_sample_bytes) {
            max_sample_bytes = annexb_bytes + prefix_bytes;
        }
    }

    scratch = (uint8_t *)malloc((size_t)max_sample_bytes);
    if (!scratch) {
        MP4D_close(&mp4);
        return 0;
    }

    memset(&state, 0, sizeof(DecoderState));
    state.storage = h264bsdAlloc();
    if (!state.storage) {
        MP4D_close(&mp4);
        return 0;
    }

    if (h264bsdInit(state.storage, 0u) != H264BSD_RDY) {
        h264bsdFree(state.storage);
        MP4D_close(&mp4);
        return 0;
    }

    summary->combined_hash = 0x811C9DC5u;

    for (sample_index = 0; sample_index < (int)mp4.track[track_index].sample_count; sample_index++) {
        unsigned int frame_bytes = 0;
        MP4D_file_offset_t offset = MP4D_frame_offset(&mp4, (unsigned int)track_index, (unsigned int)sample_index, &frame_bytes, 0, 0);
        int sample_length = build_annexb_sample(
            &mp4,
            track_index,
            bytes + offset,
            (int)frame_bytes,
            sample_index == 0,
            scratch,
            max_sample_bytes,
            track_length_size
        );
        int picture_ready = 0;

        if (sample_length < 0) {
            h264bsdShutdown(state.storage);
            h264bsdFree(state.storage);
            MP4D_close(&mp4);
            return 0;
        }

        if (!decode_access_unit(&state, scratch, sample_length, &picture_ready)) {
            h264bsdShutdown(state.storage);
            h264bsdFree(state.storage);
            MP4D_close(&mp4);
            return 0;
        }

        if (picture_ready) {
            int picture_bytes = (state.width * state.height * 3) / 2;
            uint32_t frame_hash = fold_bytes(state.picture, picture_bytes);

            if (summary->frame_count == 0) {
                summary->first_hash = frame_hash;
                summary->width = state.width;
                summary->height = state.height;
            }

            summary->last_hash = frame_hash;
            summary->combined_hash ^= frame_hash + (uint32_t)(summary->frame_count * 0x9E3779B9u);
            summary->combined_hash = rotl32(summary->combined_hash, 7u);
            summary->combined_hash += 0x7F4A7C15u;
            summary->frame_count += 1;

            if (frame_limit > 0 && summary->frame_count >= frame_limit) {
                break;
            }
        }
    }

    summary->combined_hash ^= (uint32_t)summary->width;
    summary->combined_hash = rotl32(summary->combined_hash, 3u);
    summary->combined_hash ^= (uint32_t)summary->height;
    summary->combined_hash = rotl32(summary->combined_hash, 3u);
    summary->combined_hash ^= (uint32_t)summary->frame_count;

    h264bsdShutdown(state.storage);
    h264bsdFree(state.storage);
    MP4D_close(&mp4);
    return summary->frame_count > 0;
}

static int decode_frame_yuv(const uint8_t *bytes, int length, int frame_index, uint8_t **picture, int *width, int *height) {
    MemoryInput input;
    MP4D_demux_t mp4;
    int track_index = -1;
    int track_length_size = 0;
    int prefix_bytes = 0;
    int max_sample_bytes = 0;
    uint8_t *scratch = 0;
    DecoderState state;
    int sample_index = 0;
    int picture_index = 0;

    memset(&mp4, 0, sizeof(MP4D_demux_t));
    input.bytes = bytes;
    input.length = length;

    if (MP4D_open(&mp4, memory_read_callback, &input, length) == 0) {
        return 0;
    }

    track_index = find_avc_track(&mp4);
    if (track_index < 0) {
        MP4D_close(&mp4);
        return 0;
    }

    track_length_size = detect_track_length_size(&mp4, track_index, bytes, length);
    if (track_length_size <= 0) {
        MP4D_close(&mp4);
        return 0;
    }

    prefix_bytes = header_annexb_size(&mp4, track_index);
    for (sample_index = 0; sample_index < (int)mp4.track[track_index].sample_count; sample_index++) {
        unsigned int frame_bytes = 0;
        MP4D_file_offset_t offset = MP4D_frame_offset(&mp4, (unsigned int)track_index, (unsigned int)sample_index, &frame_bytes, 0, 0);
        int annexb_bytes = sample_annexb_size(bytes + offset, (int)frame_bytes, track_length_size);

        if (annexb_bytes < 0) {
            MP4D_close(&mp4);
            return 0;
        }

        if ((annexb_bytes + prefix_bytes) > max_sample_bytes) {
            max_sample_bytes = annexb_bytes + prefix_bytes;
        }
    }

    scratch = (uint8_t *)malloc((size_t)max_sample_bytes);
    if (!scratch) {
        MP4D_close(&mp4);
        return 0;
    }

    memset(&state, 0, sizeof(DecoderState));
    state.storage = h264bsdAlloc();
    if (!state.storage) {
        MP4D_close(&mp4);
        return 0;
    }

    if (h264bsdInit(state.storage, 0u) != H264BSD_RDY) {
        h264bsdFree(state.storage);
        MP4D_close(&mp4);
        return 0;
    }

    for (sample_index = 0; sample_index < (int)mp4.track[track_index].sample_count; sample_index++) {
        unsigned int frame_bytes = 0;
        MP4D_file_offset_t offset = MP4D_frame_offset(&mp4, (unsigned int)track_index, (unsigned int)sample_index, &frame_bytes, 0, 0);
        int sample_length = build_annexb_sample(
            &mp4,
            track_index,
            bytes + offset,
            (int)frame_bytes,
            sample_index == 0,
            scratch,
            max_sample_bytes,
            track_length_size
        );
        int picture_ready = 0;

        if (sample_length < 0) {
            h264bsdShutdown(state.storage);
            h264bsdFree(state.storage);
            MP4D_close(&mp4);
            return 0;
        }

        if (!decode_access_unit(&state, scratch, sample_length, &picture_ready)) {
            h264bsdShutdown(state.storage);
            h264bsdFree(state.storage);
            MP4D_close(&mp4);
            return 0;
        }

        if (picture_ready) {
            if (picture_index == frame_index) {
                *picture = state.picture;
                *width = state.width;
                *height = state.height;
                h264bsdShutdown(state.storage);
                h264bsdFree(state.storage);
                MP4D_close(&mp4);
                return 1;
            }

            picture_index += 1;
        }
    }

    h264bsdShutdown(state.storage);
    h264bsdFree(state.storage);
    MP4D_close(&mp4);
    return 0;
}

int32_t h264mp4_decode_hash(int32_t frame_limit) {
    DecodeSummary summary;

    shim_reset_heap();
    if (!decode_summary((const uint8_t *)sample_mp4_bytes, sample_mp4_len, frame_limit, &summary)) {
        return -1;
    }

    return (int32_t)summary.combined_hash;
}

int32_t h264mp4_probe_width(void) {
    DecodeSummary summary;

    shim_reset_heap();
    if (!decode_summary((const uint8_t *)sample_mp4_bytes, sample_mp4_len, 1, &summary)) {
        return -1;
    }

    return summary.width;
}

int32_t h264mp4_probe_height(void) {
    DecodeSummary summary;

    shim_reset_heap();
    if (!decode_summary((const uint8_t *)sample_mp4_bytes, sample_mp4_len, 1, &summary)) {
        return -1;
    }

    return summary.height;
}

int32_t h264mp4_probe_frame_count(int32_t frame_limit) {
    DecodeSummary summary;

    shim_reset_heap();
    if (!decode_summary((const uint8_t *)sample_mp4_bytes, sample_mp4_len, frame_limit, &summary)) {
        return -1;
    }

    return summary.frame_count;
}

int32_t h264mp4_probe_first_frame_hash(void) {
    DecodeSummary summary;

    shim_reset_heap();
    if (!decode_summary((const uint8_t *)sample_mp4_bytes, sample_mp4_len, 1, &summary)) {
        return -1;
    }

    return (int32_t)summary.first_hash;
}

int32_t h264mp4_probe_last_frame_hash(int32_t frame_limit) {
    DecodeSummary summary;

    shim_reset_heap();
    if (!decode_summary((const uint8_t *)sample_mp4_bytes, sample_mp4_len, frame_limit, &summary)) {
        return -1;
    }

    return (int32_t)summary.last_hash;
}

int32_t h264mp4_probe_track_index(void) {
    MemoryInput input;
    MP4D_demux_t mp4;
    int track_index = -1;

    shim_reset_heap();
    memset(&mp4, 0, sizeof(MP4D_demux_t));
    input.bytes = (const uint8_t *)sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    if (MP4D_open(&mp4, memory_read_callback, &input, sample_mp4_len) == 0) {
        return -2;
    }

    track_index = find_avc_track(&mp4);
    MP4D_close(&mp4);
    return track_index;
}

int32_t h264mp4_probe_sample0_size(void) {
    MemoryInput input;
    MP4D_demux_t mp4;
    int track_index = -1;
    unsigned int frame_bytes = 0;
    MP4D_file_offset_t offset = 0;

    shim_reset_heap();
    memset(&mp4, 0, sizeof(MP4D_demux_t));
    input.bytes = (const uint8_t *)sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    if (MP4D_open(&mp4, memory_read_callback, &input, sample_mp4_len) == 0) {
        return -2;
    }

    track_index = find_avc_track(&mp4);
    if (track_index < 0) {
        MP4D_close(&mp4);
        return -1;
    }

    offset = MP4D_frame_offset(&mp4, (unsigned int)track_index, 0u, &frame_bytes, 0, 0);
    MP4D_close(&mp4);

    if ((offset + frame_bytes) > sample_mp4_len) {
        return -3;
    }

    return (int32_t)frame_bytes;
}

int32_t h264mp4_probe_sample_count(void) {
    MemoryInput input;
    MP4D_demux_t mp4;
    int track_index = -1;

    shim_reset_heap();
    memset(&mp4, 0, sizeof(MP4D_demux_t));
    input.bytes = (const uint8_t *)sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    if (MP4D_open(&mp4, memory_read_callback, &input, sample_mp4_len) == 0) {
        return -2;
    }

    track_index = find_avc_track(&mp4);
    if (track_index < 0) {
        MP4D_close(&mp4);
        return -1;
    }

    return (int32_t)mp4.track[track_index].sample_count;
}

int32_t h264mp4_probe_sample0_offset(void) {
    MemoryInput input;
    MP4D_demux_t mp4;
    int track_index = -1;
    unsigned int frame_bytes = 0;
    MP4D_file_offset_t offset = 0;

    shim_reset_heap();
    memset(&mp4, 0, sizeof(MP4D_demux_t));
    input.bytes = (const uint8_t *)sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    if (MP4D_open(&mp4, memory_read_callback, &input, sample_mp4_len) == 0) {
        return -2;
    }

    track_index = find_avc_track(&mp4);
    if (track_index < 0) {
        MP4D_close(&mp4);
        return -1;
    }

    offset = MP4D_frame_offset(&mp4, (unsigned int)track_index, 0u, &frame_bytes, 0, 0);
    MP4D_close(&mp4);
    return (int32_t)offset;
}

int32_t h264mp4_probe_length_size(void) {
    MemoryInput input;
    MP4D_demux_t mp4;
    int track_index = -1;

    shim_reset_heap();
    memset(&mp4, 0, sizeof(MP4D_demux_t));
    input.bytes = (const uint8_t *)sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    if (MP4D_open(&mp4, memory_read_callback, &input, sample_mp4_len) == 0) {
        return -2;
    }

    track_index = find_avc_track(&mp4);
    if (track_index < 0) {
        MP4D_close(&mp4);
        return -1;
    }

    return detect_track_length_size(&mp4, track_index, sample_mp4_bytes, (int)sample_mp4_len);
}

int32_t h264mp4_probe_header_size(void) {
    MemoryInput input;
    MP4D_demux_t mp4;
    int track_index = -1;

    shim_reset_heap();
    memset(&mp4, 0, sizeof(MP4D_demux_t));
    input.bytes = (const uint8_t *)sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    if (MP4D_open(&mp4, memory_read_callback, &input, sample_mp4_len) == 0) {
        return -2;
    }

    track_index = find_avc_track(&mp4);
    if (track_index < 0) {
        MP4D_close(&mp4);
        return -1;
    }

    return header_annexb_size(&mp4, track_index);
}

int32_t h264mp4_probe_sample0_prefix(void) {
    MemoryInput input;
    MP4D_demux_t mp4;
    int track_index = -1;
    int length_size = 0;
    unsigned int frame_bytes = 0;
    MP4D_file_offset_t offset = 0;
    int index = 0;
    int prefix = 0;

    shim_reset_heap();
    memset(&mp4, 0, sizeof(MP4D_demux_t));
    input.bytes = (const uint8_t *)sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    if (MP4D_open(&mp4, memory_read_callback, &input, sample_mp4_len) == 0) {
        return -2;
    }

    track_index = find_avc_track(&mp4);
    if (track_index < 0) {
        MP4D_close(&mp4);
        return -1;
    }

    length_size = detect_track_length_size(&mp4, track_index, sample_mp4_bytes, (int)sample_mp4_len);
    offset = MP4D_frame_offset(&mp4, (unsigned int)track_index, 0u, &frame_bytes, 0, 0);
    if (length_size <= 0 || frame_bytes < (unsigned int)length_size) {
        MP4D_close(&mp4);
        return -3;
    }

    for (index = 0; index < length_size; index++) {
        prefix = (prefix << 8) | sample_mp4_bytes[offset + index];
    }
    MP4D_close(&mp4);
    return prefix;
}

int32_t h264mp4_probe_dsi_bytes(void) {
    MemoryInput input;
    MP4D_demux_t mp4;
    int track_index = -1;

    shim_reset_heap();
    memset(&mp4, 0, sizeof(MP4D_demux_t));
    input.bytes = (const uint8_t *)sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    if (MP4D_open(&mp4, memory_read_callback, &input, sample_mp4_len) == 0) {
        return -2;
    }

    track_index = find_avc_track(&mp4);
    if (track_index < 0) {
        MP4D_close(&mp4);
        return -1;
    }

    return mp4.track[track_index].dsi_bytes;
}

int32_t h264mp4_probe_dsi_word0(void) {
    MemoryInput input;
    MP4D_demux_t mp4;
    int track_index = -1;
    int index = 0;
    int value = 0;

    shim_reset_heap();
    memset(&mp4, 0, sizeof(MP4D_demux_t));
    input.bytes = (const uint8_t *)sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    if (MP4D_open(&mp4, memory_read_callback, &input, sample_mp4_len) == 0) {
        return -2;
    }

    track_index = find_avc_track(&mp4);
    if (track_index < 0 || !mp4.track[track_index].dsi || mp4.track[track_index].dsi_bytes < 4) {
        MP4D_close(&mp4);
        return -1;
    }

    for (index = 0; index < 4; index++) {
        value = (value << 8) | mp4.track[track_index].dsi[index];
    }
    MP4D_close(&mp4);
    return value;
}

int32_t h264mp4_probe_dsi_word1(void) {
    MemoryInput input;
    MP4D_demux_t mp4;
    int track_index = -1;
    int index = 0;
    int value = 0;

    shim_reset_heap();
    memset(&mp4, 0, sizeof(MP4D_demux_t));
    input.bytes = (const uint8_t *)sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    if (MP4D_open(&mp4, memory_read_callback, &input, sample_mp4_len) == 0) {
        return -2;
    }

    track_index = find_avc_track(&mp4);
    if (track_index < 0 || !mp4.track[track_index].dsi || mp4.track[track_index].dsi_bytes < 8) {
        MP4D_close(&mp4);
        return -1;
    }

    for (index = 4; index < 8; index++) {
        value = (value << 8) | mp4.track[track_index].dsi[index];
    }
    MP4D_close(&mp4);
    return value;
}

int32_t h264mp4_probe_first_decode_result(void) {
    MemoryInput input;
    MP4D_demux_t mp4;
    int track_index = -1;
    int track_length_size = 0;
    int prefix_bytes = 0;
    unsigned int frame_bytes = 0;
    MP4D_file_offset_t offset = 0;
    storage_t *storage = 0;
    uint8_t *scratch = 0;
    int sample_length = 0;
    u32 read_bytes = 0;
    u32 result = 0;

    shim_reset_heap();
    input.bytes = sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    if (MP4D_open(&mp4, memory_read_callback, &input, sample_mp4_len) == 0) {
        return -2;
    }

    track_index = find_avc_track(&mp4);
    if (track_index < 0) {
        MP4D_close(&mp4);
        return -3;
    }

    track_length_size = detect_track_length_size(&mp4, track_index, sample_mp4_bytes, (int)sample_mp4_len);
    prefix_bytes = header_annexb_size(&mp4, track_index);
    offset = MP4D_frame_offset(&mp4, (unsigned int)track_index, 0u, &frame_bytes, 0, 0);
    scratch = (uint8_t *)malloc((size_t)frame_bytes + (size_t)prefix_bytes + 64u);
    storage = h264bsdAlloc();
    if (!scratch || !storage) {
        MP4D_close(&mp4);
        return -4;
    }

    if (h264bsdInit(storage, 0u) != H264BSD_RDY) {
        h264bsdFree(storage);
        MP4D_close(&mp4);
        return -5;
    }

    sample_length = build_annexb_sample(
        &mp4,
        track_index,
        sample_mp4_bytes + offset,
        (int)frame_bytes,
        1,
        scratch,
        (int)frame_bytes + prefix_bytes + 64,
        track_length_size
    );
    if (sample_length <= 0) {
        h264bsdShutdown(storage);
        h264bsdFree(storage);
        MP4D_close(&mp4);
        return -6;
    }

    result = h264bsdDecode(storage, scratch, (u32)sample_length, 0u, &read_bytes);
    h264bsdShutdown(storage);
    h264bsdFree(storage);
    MP4D_close(&mp4);
    return (int32_t)result;
}

int32_t h264mp4_probe_first_decode_bytes(void) {
    MemoryInput input;
    MP4D_demux_t mp4;
    int track_index = -1;
    int track_length_size = 0;
    int prefix_bytes = 0;
    unsigned int frame_bytes = 0;
    MP4D_file_offset_t offset = 0;
    storage_t *storage = 0;
    uint8_t *scratch = 0;
    int sample_length = 0;
    u32 read_bytes = 0;

    shim_reset_heap();
    input.bytes = sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    if (MP4D_open(&mp4, memory_read_callback, &input, sample_mp4_len) == 0) {
        return -2;
    }

    track_index = find_avc_track(&mp4);
    if (track_index < 0) {
        MP4D_close(&mp4);
        return -3;
    }

    track_length_size = detect_track_length_size(&mp4, track_index, sample_mp4_bytes, (int)sample_mp4_len);
    prefix_bytes = header_annexb_size(&mp4, track_index);
    offset = MP4D_frame_offset(&mp4, (unsigned int)track_index, 0u, &frame_bytes, 0, 0);
    scratch = (uint8_t *)malloc((size_t)frame_bytes + (size_t)prefix_bytes + 64u);
    storage = h264bsdAlloc();
    if (!scratch || !storage) {
        MP4D_close(&mp4);
        return -4;
    }

    if (h264bsdInit(storage, 0u) != H264BSD_RDY) {
        h264bsdFree(storage);
        MP4D_close(&mp4);
        return -5;
    }

    sample_length = build_annexb_sample(
        &mp4,
        track_index,
        sample_mp4_bytes + offset,
        (int)frame_bytes,
        1,
        scratch,
        (int)frame_bytes + prefix_bytes + 64,
        track_length_size
    );
    if (sample_length <= 0) {
        h264bsdShutdown(storage);
        h264bsdFree(storage);
        MP4D_close(&mp4);
        return -6;
    }

    (void)h264bsdDecode(storage, scratch, (u32)sample_length, 0u, &read_bytes);
    h264bsdShutdown(storage);
    h264bsdFree(storage);
    MP4D_close(&mp4);
    return (int32_t)read_bytes;
}

int32_t h264mp4_probe_annexb_byte(int32_t byte_index) {
    MemoryInput input;
    MP4D_demux_t mp4;
    int track_index = -1;
    int track_length_size = 0;
    int prefix_bytes = 0;
    unsigned int frame_bytes = 0;
    MP4D_file_offset_t offset = 0;
    uint8_t *scratch = 0;
    int sample_length = 0;
    int result = -1;

    if (byte_index < 0) {
        return -1;
    }

    shim_reset_heap();

    input.bytes = (const uint8_t *)sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    if (MP4D_open(&mp4, memory_read_callback, &input, (int64_t)sample_mp4_len) != 1) {
        return -2;
    }

    track_index = find_avc_track(&mp4);
    if (track_index < 0) {
        MP4D_close(&mp4);
        return -3;
    }

    track_length_size = detect_track_length_size(&mp4, track_index, sample_mp4_bytes, (int)sample_mp4_len);
    prefix_bytes = header_annexb_size(&mp4, track_index);
    offset = MP4D_frame_offset(&mp4, (unsigned int)track_index, 0u, &frame_bytes, 0, 0);
    scratch = (uint8_t *)malloc((size_t)frame_bytes + (size_t)prefix_bytes + 64u);
    if (scratch == 0) {
        MP4D_close(&mp4);
        return -4;
    }

    sample_length = build_annexb_sample(
        &mp4,
        track_index,
        sample_mp4_bytes + offset,
        (int)frame_bytes,
        1,
        scratch,
        (int)frame_bytes + prefix_bytes + 64,
        track_length_size
    );

    if (sample_length <= 0 || byte_index >= sample_length) {
        result = -5;
    } else {
        result = (int)scratch[byte_index];
    }

    MP4D_close(&mp4);
    return result;
}

int32_t h264mp4_probe_annexb_word(int32_t byte_index) {
    int b0 = h264mp4_probe_annexb_byte(byte_index);
    int b1 = h264mp4_probe_annexb_byte(byte_index + 1);
    int b2 = h264mp4_probe_annexb_byte(byte_index + 2);
    int b3 = h264mp4_probe_annexb_byte(byte_index + 3);

    if (b0 < 0 || b1 < 0 || b2 < 0 || b3 < 0) {
        return -1;
    }

    return (b0 << 24) | (b1 << 16) | (b2 << 8) | b3;
}

int32_t h264mp4_probe_h264_stage(int32_t field) {
    MemoryInput input;
    MP4D_demux_t mp4;
    int track_index = -1;
    int track_length_size = 0;
    int prefix_bytes = 0;
    unsigned int frame_bytes = 0;
    MP4D_file_offset_t offset = 0;
    uint8_t *scratch = 0;
    int sample_length = 0;
    strmData_t strm;
    nalUnit_t nal;
    seqParamSet_t sps;
    u32 read_bytes = 0;
    u32 tmp = 0;
    int result = -1;

    shim_reset_heap();

    input.bytes = (const uint8_t *)sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    if (MP4D_open(&mp4, memory_read_callback, &input, (int64_t)sample_mp4_len) != 1) {
        return -2;
    }

    track_index = find_avc_track(&mp4);
    if (track_index < 0) {
        MP4D_close(&mp4);
        return -3;
    }

    track_length_size = detect_track_length_size(&mp4, track_index, sample_mp4_bytes, (int)sample_mp4_len);
    prefix_bytes = header_annexb_size(&mp4, track_index);
    offset = MP4D_frame_offset(&mp4, (unsigned int)track_index, 0u, &frame_bytes, 0, 0);
    scratch = (uint8_t *)malloc((size_t)frame_bytes + (size_t)prefix_bytes + 64u);
    if (scratch == 0) {
        MP4D_close(&mp4);
        return -4;
    }

    sample_length = build_annexb_sample(
        &mp4,
        track_index,
        sample_mp4_bytes + offset,
        (int)frame_bytes,
        1,
        scratch,
        (int)frame_bytes + prefix_bytes + 64,
        track_length_size
    );
    if (sample_length <= 0) {
        MP4D_close(&mp4);
        return -5;
    }

    tmp = h264bsdExtractNalUnit(scratch, (u32)sample_length, &strm, &read_bytes);
    if (field == 0) result = (int)tmp;
    else if (field == 1) result = (int)read_bytes;
    else if (field == 2) result = (int)strm.strmBuffReadBits;
    else if (field == 3) result = (int)strm.bitPosInWord;

    if (tmp == 0u && result == -1) {
        tmp = h264bsdDecodeNalUnit(&strm, &nal);
        if (field == 10) result = (int)tmp;
        else if (field == 11) result = (int)nal.nalUnitType;
        else if (field == 12) result = (int)nal.nalRefIdc;
        else if (field == 13) result = (int)strm.strmBuffReadBits;
        else if (field == 14) result = (int)strm.bitPosInWord;

        if (tmp == 0u && nal.nalUnitType == NAL_SEQ_PARAM_SET && result == -1) {
            tmp = h264bsdDecodeSeqParamSet(&strm, &sps);
            if (field == 20) result = (int)tmp;
            else if (field == 21) result = (int)sps.profileIdc;
            else if (field == 22) result = (int)sps.levelIdc;
            else if (field == 23) result = (int)sps.seqParameterSetId;
            else if (field == 24) result = (int)sps.picWidthInMbs;
            else if (field == 25) result = (int)sps.picHeightInMbs;
            else if (field == 26) result = (int)sps.maxFrameNum;
            else if (field == 27) result = (int)sps.picOrderCntType;
            else if (field == 28) result = (int)strm.strmBuffReadBits;
            else if (field == 29) result = (int)strm.bitPosInWord;
        }
    }

    MP4D_close(&mp4);
    return result;
}

int32_t h264mp4_probe_sample0_nal_at_offset(int32_t nal_offset, int32_t field) {
    MemoryInput input;
    MP4D_demux_t mp4;
    int track_index = -1;
    int track_length_size = 0;
    int prefix_bytes = 0;
    unsigned int frame_bytes = 0;
    MP4D_file_offset_t offset = 0;
    uint8_t *scratch = 0;
    int sample_length = 0;
    u32 read_bytes = 0;
    strmData_t strm;
    nalUnit_t nal;
    u32 extract_result = 0;
    u32 nal_result = 0;

    shim_reset_heap();
    memset(&mp4, 0, sizeof(MP4D_demux_t));
    memset(&strm, 0, sizeof(strmData_t));
    memset(&nal, 0, sizeof(nalUnit_t));
    input.bytes = sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    if (MP4D_open(&mp4, memory_read_callback, &input, sample_mp4_len) == 0) {
        return -2;
    }

    track_index = find_avc_track(&mp4);
    if (track_index < 0) {
        MP4D_close(&mp4);
        return -3;
    }

    track_length_size = detect_track_length_size(&mp4, track_index, sample_mp4_bytes, (int)sample_mp4_len);
    prefix_bytes = header_annexb_size(&mp4, track_index);
    offset = MP4D_frame_offset(&mp4, (unsigned int)track_index, 0u, &frame_bytes, 0, 0);
    scratch = (uint8_t *)malloc((size_t)frame_bytes + (size_t)prefix_bytes + 64u);
    if (!scratch) {
        MP4D_close(&mp4);
        return -4;
    }

    sample_length = build_annexb_sample(
        &mp4,
        track_index,
        sample_mp4_bytes + offset,
        (int)frame_bytes,
        1,
        scratch,
        (int)frame_bytes + prefix_bytes + 64,
        track_length_size
    );
    MP4D_close(&mp4);

    if (sample_length < 0) {
        return -5;
    }
    if (nal_offset < 0 || nal_offset >= sample_length) {
        return -6;
    }

    extract_result = h264bsdExtractNalUnit(scratch + nal_offset, (u32)(sample_length - nal_offset), &strm, &read_bytes);
    nal_result = h264bsdDecodeNalUnit(&strm, &nal);

    if (field == 0) {
        return sample_length;
    } else if (field == 1) {
        return (int32_t)extract_result;
    } else if (field == 2) {
        return (int32_t)read_bytes;
    } else if (field == 3) {
        return (int32_t)nal_result;
    } else if (field == 4) {
        return (int32_t)nal.nalUnitType;
    } else if (field == 5) {
        return (int32_t)nal.nalRefIdc;
    } else if (field == 6) {
        return (int32_t)strm.strmBuffReadBits;
    } else if (field == 7) {
        return (int32_t)strm.bitPosInWord;
    }

    return -100;
}

int32_t h264mp4_probe_sample0_idr_stage(int32_t field) {
    MemoryInput input;
    MP4D_demux_t mp4;
    int track_index = -1;
    int track_length_size = 0;
    int prefix_bytes = 0;
    int max_sample_bytes = 0;
    uint8_t *scratch = 0;
    storage_t *storage = 0;
    int sample_length = 0;
    int decode_offset = 0;
    strmData_t strm;
    nalUnit_t nal;
    u32 read_bytes = 0;
    u32 result = 0;
    u32 tmp = 0;
    u32 pps_id = 0;
    u32 sps_id = 0;
    u32 access_unit_boundary = 0;

    shim_reset_heap();
    memset(&mp4, 0, sizeof(MP4D_demux_t));
    memset(&strm, 0, sizeof(strmData_t));
    memset(&nal, 0, sizeof(nalUnit_t));
    input.bytes = sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    if (MP4D_open(&mp4, memory_read_callback, &input, sample_mp4_len) == 0) {
        return -2;
    }
    track_index = find_avc_track(&mp4);
    if (track_index < 0) {
        MP4D_close(&mp4);
        return -3;
    }
    track_length_size = detect_track_length_size(&mp4, track_index, sample_mp4_bytes, (int)sample_mp4_len);
    prefix_bytes = header_annexb_size(&mp4, track_index);

    {
        int sample_index = 0;
        for (sample_index = 0; sample_index < (int)mp4.track[track_index].sample_count; sample_index++) {
            unsigned int frame_bytes = 0;
            MP4D_file_offset_t sample_offset = MP4D_frame_offset(&mp4, (unsigned int)track_index, (unsigned int)sample_index, &frame_bytes, 0, 0);
            int annexb_bytes = sample_annexb_size(sample_mp4_bytes + sample_offset, (int)frame_bytes, track_length_size);
            if (annexb_bytes < 0) {
                MP4D_close(&mp4);
                return -4;
            }
            if ((annexb_bytes + prefix_bytes) > max_sample_bytes) {
                max_sample_bytes = annexb_bytes + prefix_bytes;
            }
        }
    }

    scratch = (uint8_t *)malloc((size_t)max_sample_bytes);
    storage = h264bsdAlloc();
    if (!scratch || !storage) {
        MP4D_close(&mp4);
        return -5;
    }
    if (h264bsdInit(storage, 0u) != H264BSD_RDY) {
        MP4D_close(&mp4);
        return -6;
    }

    {
        unsigned int frame_bytes = 0;
        MP4D_file_offset_t sample_offset = MP4D_frame_offset(&mp4, (unsigned int)track_index, 0u, &frame_bytes, 0, 0);
        sample_length = build_annexb_sample(
            &mp4,
            track_index,
            sample_mp4_bytes + sample_offset,
            (int)frame_bytes,
            1,
            scratch,
            max_sample_bytes,
            track_length_size
        );
    }
    MP4D_close(&mp4);
    if (sample_length < 0) {
        return -7;
    }

    while (decode_offset < 665) {
        read_bytes = 0;
        result = h264bsdDecode(storage, scratch + decode_offset, (u32)(sample_length - decode_offset), 0u, &read_bytes);
        if (result == H264BSD_ERROR || result == H264BSD_PARAM_SET_ERROR || result == H264BSD_MEMALLOC_ERROR) {
            return -10 - (int32_t)result;
        }
        if (read_bytes == 0u && result != H264BSD_HDRS_RDY) {
            return -20 - (int32_t)result;
        }
        decode_offset += (int)read_bytes;
    }

    if (field == 0) return decode_offset;

    read_bytes = 0;
    tmp = h264bsdExtractNalUnit(scratch + decode_offset, (u32)(sample_length - decode_offset), &strm, &read_bytes);
    if (field == 1) return (int32_t)tmp;
    if (field == 2) return (int32_t)read_bytes;
    if (tmp != 0u) return -30 - (int32_t)tmp;

    tmp = h264bsdDecodeNalUnit(&strm, &nal);
    if (field == 3) return (int32_t)tmp;
    if (field == 4) return (int32_t)nal.nalUnitType;
    if (field == 5) return (int32_t)nal.nalRefIdc;
    if (tmp != 0u) return -40 - (int32_t)tmp;

    tmp = h264bsdCheckAccessUnitBoundary(&strm, &nal, storage, &access_unit_boundary);
    if (field == 10) return (int32_t)tmp;
    if (field == 11) return (int32_t)access_unit_boundary;
    if (tmp != 0u) return -50 - (int32_t)tmp;

    if (field == 12) return (int32_t)h264bsdIsStartOfPicture(storage);
    if (field == 13) return (int32_t)storage->pendingActivation;
    if (field == 14) return storage->activeSps != 0;
    if (field == 15) return storage->activePps != 0;

    tmp = h264bsdCheckPpsId(&strm, &pps_id);
    if (field == 20) return (int32_t)tmp;
    if (field == 21) return (int32_t)pps_id;
    if (tmp != 0u) return -60 - (int32_t)tmp;

    sps_id = storage->activeSpsId;
    tmp = h264bsdActivateParamSets(storage, pps_id, 1u);
    if (field == 22) return (int32_t)tmp;
    if (field == 23) return (int32_t)sps_id;
    if (field == 24) return (int32_t)storage->activeSpsId;
    if (tmp != 0u) return -70 - (int32_t)tmp;

    tmp = h264bsdDecodeSliceHeader(&strm, storage->sliceHeader + 1, storage->activeSps, storage->activePps, &nal);
    if (field == 30) return (int32_t)tmp;
    if (field == 31) return (int32_t)storage->sliceHeader[1].firstMbInSlice;
    if (field == 32) return (int32_t)storage->sliceHeader[1].sliceType;
    if (field == 33) return (int32_t)storage->sliceHeader[1].frameNum;
    if (tmp != 0u) return -80 - (int32_t)tmp;

    storage->sliceHeader[0] = storage->sliceHeader[1];
    storage->validSliceInAccessUnit = 1u;
    storage->prevNalUnit[0] = nal;
    h264bsdComputeSliceGroupMap(storage, storage->sliceHeader->sliceGroupChangeCycle);
    h264bsdInitRefPicList(storage->dpb);
    tmp = h264bsdReorderRefPicList(storage->dpb, &storage->sliceHeader->refPicListReordering, storage->sliceHeader->frameNum, storage->sliceHeader->numRefIdxL0Active);
    if (field == 40) return (int32_t)tmp;
    if (tmp != 0u) return -90 - (int32_t)tmp;

    if (h264bsdIsStartOfPicture(storage)) {
        storage->currImage->data = h264bsdAllocateDpbImage(storage->dpb);
    }
    tmp = h264bsdDecodeSliceData(&strm, storage, storage->currImage, storage->sliceHeader);
    if (field == 50) return (int32_t)tmp;
    if (field == 51) return (int32_t)strm.strmBuffReadBits;
    if (field == 52) return (int32_t)strm.bitPosInWord;

    return -100;
}

int32_t h264mp4_probe_decode_until_sample(int32_t target_sample, int32_t field) {
    MemoryInput input;
    MP4D_demux_t mp4;
    int track_index = -1;
    int track_length_size = 0;
    int prefix_bytes = 0;
    int max_sample_bytes = 0;
    uint8_t *scratch = 0;
    DecoderState state;
    int sample_index = 0;
    int last_sample_length = 0;
    int last_ok = 0;
    int last_picture_ready = 0;
    int last_result = 0;
    int last_read_bytes = 0;
    int last_decode_offset = 0;
    int frame_count = 0;

    shim_reset_heap();
    memset(&mp4, 0, sizeof(MP4D_demux_t));
    memset(&state, 0, sizeof(DecoderState));
    input.bytes = sample_mp4_bytes;
    input.length = (int)sample_mp4_len;

    if (MP4D_open(&mp4, memory_read_callback, &input, sample_mp4_len) == 0) {
        return -2;
    }

    track_index = find_avc_track(&mp4);
    if (track_index < 0) {
        MP4D_close(&mp4);
        return -3;
    }

    track_length_size = detect_track_length_size(&mp4, track_index, sample_mp4_bytes, (int)sample_mp4_len);
    if (track_length_size <= 0) {
        MP4D_close(&mp4);
        return -4;
    }

    prefix_bytes = header_annexb_size(&mp4, track_index);
    for (sample_index = 0; sample_index < (int)mp4.track[track_index].sample_count; sample_index++) {
        unsigned int frame_bytes = 0;
        MP4D_file_offset_t offset = MP4D_frame_offset(&mp4, (unsigned int)track_index, (unsigned int)sample_index, &frame_bytes, 0, 0);
        int annexb_bytes = sample_annexb_size(sample_mp4_bytes + offset, (int)frame_bytes, track_length_size);

        if (annexb_bytes < 0) {
            MP4D_close(&mp4);
            return -5;
        }

        if ((annexb_bytes + prefix_bytes) > max_sample_bytes) {
            max_sample_bytes = annexb_bytes + prefix_bytes;
        }
    }

    scratch = (uint8_t *)malloc((size_t)max_sample_bytes);
    state.storage = h264bsdAlloc();
    if (!scratch || !state.storage) {
        MP4D_close(&mp4);
        return -6;
    }

    if (h264bsdInit(state.storage, 0u) != H264BSD_RDY) {
        h264bsdFree(state.storage);
        MP4D_close(&mp4);
        return -7;
    }

    for (sample_index = 0; sample_index < (int)mp4.track[track_index].sample_count; sample_index++) {
        unsigned int frame_bytes = 0;
        MP4D_file_offset_t offset = MP4D_frame_offset(&mp4, (unsigned int)track_index, (unsigned int)sample_index, &frame_bytes, 0, 0);

        last_sample_length = build_annexb_sample(
            &mp4,
            track_index,
            sample_mp4_bytes + offset,
            (int)frame_bytes,
            sample_index == 0,
            scratch,
            max_sample_bytes,
            track_length_size
        );
        if (last_sample_length < 0) {
            h264bsdShutdown(state.storage);
            h264bsdFree(state.storage);
            MP4D_close(&mp4);
            return -8;
        }

        last_picture_ready = 0;
        last_ok = 1;
        last_decode_offset = 0;
        while (last_decode_offset < last_sample_length) {
            u32 read_bytes = 0;
            u32 result = h264bsdDecode(
                state.storage,
                (u8 *)(scratch + last_decode_offset),
                (u32)(last_sample_length - last_decode_offset),
                0u,
                &read_bytes
            );

            last_result = (int)result;
            last_read_bytes = (int)read_bytes;

            if (result == H264BSD_ERROR || result == H264BSD_PARAM_SET_ERROR || result == H264BSD_MEMALLOC_ERROR) {
                last_ok = 0;
                break;
            }

            if (read_bytes == 0u && result != H264BSD_HDRS_RDY) {
                last_ok = 0;
                break;
            }

            last_decode_offset += (int)read_bytes;

            if (result == H264BSD_HDRS_RDY) {
                state.width = output_picture_width(state.storage);
                state.height = output_picture_height(state.storage);
            }

            if (result == H264BSD_PIC_RDY) {
                u32 pic_id = 0;
                u32 is_idr_pic = 0;
                u32 num_err_mbs = 0;

                state.picture = h264bsdNextOutputPicture(state.storage, &pic_id, &is_idr_pic, &num_err_mbs);
                state.width = output_picture_width(state.storage);
                state.height = output_picture_height(state.storage);
                last_picture_ready = 1;
            }
        }
        if (last_picture_ready) {
            frame_count += 1;
        }

        if (sample_index == target_sample || !last_ok) {
            int result = 0;
            if (field == 0) {
                result = last_sample_length;
            } else if (field == 1) {
                result = last_ok;
            } else if (field == 2) {
                result = last_picture_ready;
            } else if (field == 3) {
                result = state.width;
            } else if (field == 4) {
                result = state.height;
            } else if (field == 5) {
                result = frame_count;
            } else if (field == 6) {
                result = last_result;
            } else if (field == 7) {
                result = last_read_bytes;
            } else {
                result = last_decode_offset;
            }
            h264bsdShutdown(state.storage);
            h264bsdFree(state.storage);
            MP4D_close(&mp4);
            return result;
        }
    }

    h264bsdShutdown(state.storage);
    h264bsdFree(state.storage);
    MP4D_close(&mp4);
    return frame_count;
}

int32_t h264mp4_host_alloc(int32_t size) {
    void *result = 0;

    if (size <= 0) {
        return 0;
    }

    result = malloc((size_t)size);
    return (int32_t)(intptr_t)result;
}

int32_t h264mp4_host_reset(void) {
    shim_reset_heap();
    host_bytes = 0;
    host_length = 0;
    host_picture = 0;
    host_width = 0;
    host_height = 0;
    host_y_size = 0;
    host_u_size = 0;
    host_v_size = 0;
    return 1;
}

int32_t h264mp4_host_load(int32_t bytes_ptr, int32_t bytes_len) {
    if (bytes_ptr == 0 || bytes_len <= 0) {
        return 0;
    }

    host_bytes = (uint8_t *)(intptr_t)bytes_ptr;
    host_length = bytes_len;
    host_picture = 0;
    host_width = 0;
    host_height = 0;
    host_y_size = 0;
    host_u_size = 0;
    host_v_size = 0;
    return 1;
}

int32_t h264mp4_host_decode_frame(int32_t frame_index) {
    uint8_t *picture = 0;
    int width = 0;
    int height = 0;

    if (!host_bytes || host_length <= 0 || frame_index < 0) {
        return 0;
    }

    if (!decode_frame_yuv(host_bytes, host_length, frame_index, &picture, &width, &height)) {
        return 0;
    }

    host_picture = picture;
    host_width = width;
    host_height = height;
    host_y_size = width * height;
    host_u_size = host_y_size / 4;
    host_v_size = host_y_size / 4;
    return 1;
}

int32_t h264mp4_host_get_y_ptr(void) {
    return (int32_t)(intptr_t)host_picture;
}

int32_t h264mp4_host_get_u_ptr(void) {
    if (!host_picture) {
        return 0;
    }

    return (int32_t)(intptr_t)(host_picture + host_y_size);
}

int32_t h264mp4_host_get_v_ptr(void) {
    if (!host_picture) {
        return 0;
    }

    return (int32_t)(intptr_t)(host_picture + host_y_size + host_u_size);
}

int32_t h264mp4_host_get_y_size(void) {
    return host_y_size;
}

int32_t h264mp4_host_get_u_size(void) {
    return host_u_size;
}

int32_t h264mp4_host_get_v_size(void) {
    return host_v_size;
}

int32_t h264mp4_host_get_width(void) {
    return host_width;
}

int32_t h264mp4_host_get_height(void) {
    return host_height;
}
