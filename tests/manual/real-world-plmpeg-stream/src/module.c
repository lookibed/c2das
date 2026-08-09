#include <stddef.h>
#include <stdint.h>

#define PLM_NO_STDIO
#include "../upstream/pl_mpeg.h"
#include "sample_mpg_data.h"

void *malloc(size_t size);
void free(void *ptr);
void *memset(void *dest, int value, size_t count);
void shim_reset_heap(void);
int plm_buffer_find_start_code(plm_buffer_t *self, int code);

static const int REAL_WORLD_PLMPEG_START_SEQUENCE = 0xB3;

typedef struct DecodeSummary {
    uint32_t combined_hash;
    uint32_t first_hash;
    uint32_t last_hash;
    int frame_count;
    int width;
    int height;
} DecodeSummary;

static uint8_t *host_bytes = 0;
static int host_length = 0;
static uint8_t *host_rgb = 0;
static int host_rgb_size = 0;
static int host_width = 0;
static int host_height = 0;
static plm_video_t *host_stream_video = 0;
static uint8_t *host_stream_rgb = 0;
static int host_stream_rgb_size = 0;
static int host_stream_width = 0;
static int host_stream_height = 0;
static int host_stream_frame_index = -1;

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

static plm_video_t *create_decoder(uint8_t *bytes, size_t length) {
    plm_buffer_t *buffer = plm_buffer_create_with_memory(bytes, length, 0);
    plm_video_t *video = 0;

    if (!buffer) {
        return 0;
    }

    video = plm_video_create_with_buffer(buffer, 1);
    if (!video) {
        plm_buffer_destroy(buffer);
        return 0;
    }

    plm_video_set_no_delay(video, 1);
    return video;
}

static int decode_summary(uint8_t *bytes, size_t length, int frame_limit, DecodeSummary *summary) {
    plm_video_t *video = create_decoder(bytes, length);
    int rgb_size = 0;
    uint8_t *rgb = 0;
    int frame_index = 0;

    if (!video) {
        return 0;
    }

    summary->combined_hash = 0x811C9DC5u;
    summary->first_hash = 0u;
    summary->last_hash = 0u;
    summary->frame_count = 0;
    summary->width = plm_video_get_width(video);
    summary->height = plm_video_get_height(video);

    if (summary->width <= 0 || summary->height <= 0) {
        plm_video_destroy(video);
        return 0;
    }

    rgb_size = summary->width * summary->height * 3;
    rgb = (uint8_t *)malloc((size_t)rgb_size);
    if (!rgb) {
        plm_video_destroy(video);
        return 0;
    }

    while (1) {
        plm_frame_t *frame = plm_video_decode(video);
        uint32_t frame_hash = 0u;

        if (!frame) {
            break;
        }

        plm_frame_to_rgb(frame, rgb, summary->width * 3);
        frame_hash = fold_bytes(rgb, rgb_size);

        if (frame_index == 0) {
            summary->first_hash = frame_hash;
        }

        summary->last_hash = frame_hash;
        summary->combined_hash ^= frame_hash + (uint32_t)(frame_index * 0x9E3779B9u);
        summary->combined_hash = rotl32(summary->combined_hash, 7u);
        summary->combined_hash += 0x7F4A7C15u;
        summary->frame_count = frame_index + 1;
        frame_index += 1;

        if (frame_limit > 0 && frame_index >= frame_limit) {
            break;
        }
    }

    summary->combined_hash ^= (uint32_t)summary->width;
    summary->combined_hash = rotl32(summary->combined_hash, 3u);
    summary->combined_hash ^= (uint32_t)summary->height;
    summary->combined_hash = rotl32(summary->combined_hash, 3u);
    summary->combined_hash ^= (uint32_t)summary->frame_count;

    plm_video_destroy(video);
    return 1;
}

static int decode_frame_rgb(uint8_t *bytes, size_t length, int frame_index, uint8_t **rgb_ptr, int *rgb_size, int *width, int *height) {
    plm_video_t *video = create_decoder(bytes, length);
    uint8_t *rgb = 0;
    int local_width = 0;
    int local_height = 0;
    int local_size = 0;
    int current = 0;

    if (!video) {
        return 0;
    }

    local_width = plm_video_get_width(video);
    local_height = plm_video_get_height(video);
    if (local_width <= 0 || local_height <= 0) {
        plm_video_destroy(video);
        return 0;
    }

    local_size = local_width * local_height * 3;
    rgb = (uint8_t *)malloc((size_t)local_size);
    if (!rgb) {
        plm_video_destroy(video);
        return 0;
    }

    while (1) {
        plm_frame_t *frame = plm_video_decode(video);
        if (!frame) {
            plm_video_destroy(video);
            return 0;
        }

        if (current == frame_index) {
            plm_frame_to_rgb(frame, rgb, local_width * 3);
            *rgb_ptr = rgb;
            *rgb_size = local_size;
            *width = local_width;
            *height = local_height;
            plm_video_destroy(video);
            return 1;
        }

        current += 1;
    }
}

static void host_stream_end_internal(void) {
    if (host_stream_video) {
        plm_video_destroy(host_stream_video);
    }

    host_stream_video = 0;
    host_stream_rgb = 0;
    host_stream_rgb_size = 0;
    host_stream_width = 0;
    host_stream_height = 0;
    host_stream_frame_index = -1;
}

int32_t plmpeg_decode_hash(int32_t frame_limit) {
    DecodeSummary summary;

    shim_reset_heap();
    if (!decode_summary((uint8_t *)sample_mpg_bytes, sample_mpg_len, frame_limit, &summary)) {
        return -1;
    }

    return (int32_t)summary.combined_hash;
}

int32_t plmpeg_probe_width(void) {
    DecodeSummary summary;

    shim_reset_heap();
    if (!decode_summary((uint8_t *)sample_mpg_bytes, sample_mpg_len, 1, &summary)) {
        return -1;
    }

    return summary.width;
}

int32_t plmpeg_probe_height(void) {
    DecodeSummary summary;

    shim_reset_heap();
    if (!decode_summary((uint8_t *)sample_mpg_bytes, sample_mpg_len, 1, &summary)) {
        return -1;
    }

    return summary.height;
}

int32_t plmpeg_probe_frame_count(int32_t frame_limit) {
    DecodeSummary summary;

    shim_reset_heap();
    if (!decode_summary((uint8_t *)sample_mpg_bytes, sample_mpg_len, frame_limit, &summary)) {
        return -1;
    }

    return summary.frame_count;
}

int32_t plmpeg_probe_first_frame_hash(void) {
    DecodeSummary summary;

    shim_reset_heap();
    if (!decode_summary((uint8_t *)sample_mpg_bytes, sample_mpg_len, 1, &summary)) {
        return -1;
    }

    return (int32_t)summary.first_hash;
}

int32_t plmpeg_probe_last_frame_hash(int32_t frame_limit) {
    DecodeSummary summary;

    shim_reset_heap();
    if (!decode_summary((uint8_t *)sample_mpg_bytes, sample_mpg_len, frame_limit, &summary)) {
        return -1;
    }

    return (int32_t)summary.last_hash;
}

int32_t plmpeg_probe_sequence_start_code(void) {
    plm_buffer_t *buffer = 0;
    int code = -1;

    shim_reset_heap();
    buffer = plm_buffer_create_with_memory((uint8_t *)sample_mpg_bytes, sample_mpg_len, 0);
    if (!buffer) {
        return -2;
    }

    code = plm_buffer_find_start_code(buffer, REAL_WORLD_PLMPEG_START_SEQUENCE);
    plm_buffer_destroy(buffer);
    return code;
}

int32_t plmpeg_probe_video_has_header(void) {
    plm_video_t *video = 0;
    int result = 0;

    shim_reset_heap();
    video = create_decoder((uint8_t *)sample_mpg_bytes, sample_mpg_len);
    if (!video) {
        return -1;
    }

    result = plm_video_has_header(video);
    plm_video_destroy(video);
    return result;
}

int32_t plmpeg_host_alloc(int32_t size) {
    void *result = 0;
    if (size <= 0) {
        return 0;
    }
    result = malloc((size_t)size);
    return (int32_t)(intptr_t)result;
}

int32_t plmpeg_host_load(int32_t bytes_ptr, int32_t bytes_len) {
    if (bytes_ptr == 0 || bytes_len <= 0) {
        return 0;
    }

    host_bytes = (uint8_t *)(intptr_t)bytes_ptr;
    host_length = bytes_len;
    host_rgb = 0;
    host_rgb_size = 0;
    host_width = 0;
    host_height = 0;
    host_stream_end_internal();
    return 1;
}

int32_t plmpeg_host_decode_frame(int32_t frame_index) {
    uint8_t *rgb = 0;
    int rgb_size = 0;
    int width = 0;
    int height = 0;

    if (!host_bytes || host_length <= 0 || frame_index < 0) {
        return 0;
    }

    if (!decode_frame_rgb(host_bytes, (size_t)host_length, frame_index, &rgb, &rgb_size, &width, &height)) {
        return 0;
    }

    host_rgb = rgb;
    host_rgb_size = rgb_size;
    host_width = width;
    host_height = height;
    return 1;
}

int32_t plmpeg_host_get_rgb_ptr(void) {
    return (int32_t)(intptr_t)host_rgb;
}

int32_t plmpeg_host_get_rgb_size(void) {
    return host_rgb_size;
}

int32_t plmpeg_host_get_width(void) {
    return host_width;
}

int32_t plmpeg_host_get_height(void) {
    return host_height;
}

int32_t plmpeg_host_stream_begin(void) {
    int width = 0;
    int height = 0;
    int rgb_size = 0;
    uint8_t *rgb = 0;

    if (!host_bytes || host_length <= 0) {
        return 0;
    }

    host_stream_end_internal();
    host_stream_video = create_decoder(host_bytes, (size_t)host_length);
    if (!host_stream_video) {
        return 0;
    }

    width = plm_video_get_width(host_stream_video);
    height = plm_video_get_height(host_stream_video);
    if (width <= 0 || height <= 0) {
        host_stream_end_internal();
        return 0;
    }

    rgb_size = width * height * 3;
    rgb = (uint8_t *)malloc((size_t)rgb_size);
    if (!rgb) {
        host_stream_end_internal();
        return 0;
    }

    host_stream_rgb = rgb;
    host_stream_rgb_size = rgb_size;
    host_stream_width = width;
    host_stream_height = height;
    host_stream_frame_index = -1;
    return 1;
}

int32_t plmpeg_host_stream_decode_next(void) {
    plm_frame_t *frame = 0;

    if (!host_stream_video || !host_stream_rgb) {
        return 0;
    }

    frame = plm_video_decode(host_stream_video);
    if (!frame) {
        return 0;
    }

    plm_frame_to_rgb(frame, host_stream_rgb, host_stream_width * 3);
    host_stream_frame_index += 1;

    host_rgb = host_stream_rgb;
    host_rgb_size = host_stream_rgb_size;
    host_width = host_stream_width;
    host_height = host_stream_height;
    return 1;
}

int32_t plmpeg_host_stream_end(void) {
    host_stream_end_internal();
    return 1;
}

int32_t plmpeg_host_stream_get_frame_index(void) {
    return host_stream_frame_index;
}

int32_t plmpeg_host_probe_video_has_header(void) {
    plm_video_t *video = 0;
    int result = 0;

    if (!host_bytes || host_length <= 0) {
        return -1;
    }

    video = create_decoder(host_bytes, (size_t)host_length);
    if (!video) {
        return -2;
    }

    result = plm_video_has_header(video);
    plm_video_destroy(video);
    return result;
}

int32_t plmpeg_host_probe_width(void) {
    plm_video_t *video = 0;
    int result = 0;

    if (!host_bytes || host_length <= 0) {
        return -1;
    }

    video = create_decoder(host_bytes, (size_t)host_length);
    if (!video) {
        return -2;
    }

    result = plm_video_get_width(video);
    plm_video_destroy(video);
    return result;
}

int32_t plmpeg_host_probe_height(void) {
    plm_video_t *video = 0;
    int result = 0;

    if (!host_bytes || host_length <= 0) {
        return -1;
    }

    video = create_decoder(host_bytes, (size_t)host_length);
    if (!video) {
        return -2;
    }

    result = plm_video_get_height(video);
    plm_video_destroy(video);
    return result;
}
