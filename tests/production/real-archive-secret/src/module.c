#include "../../real-world-miniz/upstream/miniz.h"
#include "../../real-world-miniz/upstream/miniz_zip.h"

#include <stdint.h>

void miniz_secret_reset(void);

static const char secret_name[] = "secretik.txt";
static const char expected_text[] = "Hi Bebra 2026!";

int miniz_secret_alloc(int size) {
    void *ptr = 0;

    if (size < 0) {
        return 0;
    }

    ptr = malloc((size_t)size);
    return (int)(uintptr_t)ptr;
}

int miniz_secret_expected_length(void) {
    return (int)(sizeof(expected_text) - 1u);
}

int miniz_secret_extract_message(int archive_ptr, int archive_size, int out_ptr, int out_capacity) {
    mz_zip_archive archive;
    mz_uint32 file_index = 0;
    void *heap_result = 0;
    size_t heap_size = 0;
    mz_bool ok = MZ_FALSE;

    if ((archive_ptr == 0) || (archive_size <= 0) || (out_ptr == 0) || (out_capacity <= 0)) {
        return -1001;
    }

    mz_zip_zero_struct(&archive);
    ok = mz_zip_reader_init_mem(&archive, (const void *)(uintptr_t)archive_ptr, (size_t)archive_size, 0);
    if (!ok) {
        return -1002 - (int)mz_zip_get_last_error(&archive);
    }

    ok = mz_zip_reader_locate_file_v2(&archive, secret_name, 0, 0, &file_index);
    if (!ok) {
        mz_zip_reader_end(&archive);
        return -1003 - (int)mz_zip_get_last_error(&archive);
    }

    heap_result = mz_zip_reader_extract_to_heap(&archive, file_index, &heap_size, 0);
    if (!heap_result) {
        mz_zip_reader_end(&archive);
        return -1004 - (int)mz_zip_get_last_error(&archive);
    }

    if ((int)heap_size > out_capacity) {
        mz_free(heap_result);
        mz_zip_reader_end(&archive);
        return -1005 - (int)heap_size;
    }

    memcpy((void *)(uintptr_t)out_ptr, heap_result, heap_size);
    mz_free(heap_result);
    mz_zip_reader_end(&archive);

    return (int)heap_size;
}

int miniz_secret_extract_message_iter(int archive_ptr, int archive_size, int out_ptr, int out_capacity) {
    mz_zip_archive archive;
    mz_uint32 file_index = 0;
    mz_zip_reader_extract_iter_state *state = 0;
    size_t total = 0;
    mz_bool ok = MZ_FALSE;

    if ((archive_ptr == 0) || (archive_size <= 0) || (out_ptr == 0) || (out_capacity <= 0)) {
        return -1101;
    }

    mz_zip_zero_struct(&archive);
    ok = mz_zip_reader_init_mem(&archive, (const void *)(uintptr_t)archive_ptr, (size_t)archive_size, 0);
    if (!ok) {
        return -1102 - (int)mz_zip_get_last_error(&archive);
    }

    ok = mz_zip_reader_locate_file_v2(&archive, secret_name, 0, 0, &file_index);
    if (!ok) {
        mz_zip_reader_end(&archive);
        return -1103 - (int)mz_zip_get_last_error(&archive);
    }

    state = mz_zip_reader_extract_iter_new(&archive, file_index, 0);
    if (!state) {
        mz_zip_reader_end(&archive);
        return -1104 - (int)mz_zip_get_last_error(&archive);
    }

    while (total < (size_t)out_capacity) {
        size_t chunk = mz_zip_reader_extract_iter_read(
            state,
            (void *)((uintptr_t)out_ptr + total),
            (size_t)out_capacity - total
        );
        if (chunk == 0) {
            break;
        }

        total += chunk;
    }

    ok = mz_zip_reader_extract_iter_free(state);
    if (!ok) {
        mz_zip_reader_end(&archive);
        return -1105 - (int)mz_zip_get_last_error(&archive);
    }

    mz_zip_reader_end(&archive);
    return (int)total;
}

int miniz_secret_probe_expected_crc32(void) {
    return (int)mz_crc32(MZ_CRC32_INIT, (const mz_uint8 *)expected_text, sizeof(expected_text) - 1u);
}

int miniz_secret_probe_buffer_crc32(int ptr, int len) {
    if ((ptr == 0) || (len < 0)) {
        return 0;
    }

    return (int)mz_crc32(MZ_CRC32_INIT, (const mz_uint8 *)(uintptr_t)ptr, (size_t)len);
}

int miniz_secret_probe_file_crc32(int archive_ptr, int archive_size) {
    mz_zip_archive archive;
    mz_uint32 file_index = 0;
    mz_zip_archive_file_stat file_stat;
    mz_bool ok = MZ_FALSE;

    if ((archive_ptr == 0) || (archive_size <= 0)) {
        return -1201;
    }

    mz_zip_zero_struct(&archive);
    ok = mz_zip_reader_init_mem(&archive, (const void *)(uintptr_t)archive_ptr, (size_t)archive_size, 0);
    if (!ok) {
        return -1202 - (int)mz_zip_get_last_error(&archive);
    }

    ok = mz_zip_reader_locate_file_v2(&archive, secret_name, 0, 0, &file_index);
    if (!ok) {
        mz_zip_reader_end(&archive);
        return -1203 - (int)mz_zip_get_last_error(&archive);
    }

    ok = mz_zip_reader_file_stat(&archive, file_index, &file_stat);
    if (!ok) {
        mz_zip_reader_end(&archive);
        return -1204 - (int)mz_zip_get_last_error(&archive);
    }

    mz_zip_reader_end(&archive);
    return (int)file_stat.m_crc32;
}

int miniz_secret_extract_message_direct(int archive_ptr, int archive_size, int out_ptr, int out_capacity) {
    mz_zip_archive archive;
    mz_uint32 file_index = 0;
    mz_zip_archive_file_stat file_stat;
    mz_bool ok = MZ_FALSE;

    if ((archive_ptr == 0) || (archive_size <= 0) || (out_ptr == 0) || (out_capacity <= 0)) {
        return -1301;
    }

    mz_zip_zero_struct(&archive);
    ok = mz_zip_reader_init_mem(&archive, (const void *)(uintptr_t)archive_ptr, (size_t)archive_size, 0);
    if (!ok) {
        return -1302 - (int)mz_zip_get_last_error(&archive);
    }

    ok = mz_zip_reader_locate_file_v2(&archive, secret_name, 0, 0, &file_index);
    if (!ok) {
        mz_zip_reader_end(&archive);
        return -1303 - (int)mz_zip_get_last_error(&archive);
    }

    ok = mz_zip_reader_file_stat(&archive, file_index, &file_stat);
    if (!ok) {
        mz_zip_reader_end(&archive);
        return -1304 - (int)mz_zip_get_last_error(&archive);
    }

    if ((int)file_stat.m_uncomp_size > out_capacity) {
        mz_zip_reader_end(&archive);
        return -1305 - (int)file_stat.m_uncomp_size;
    }

    ok = mz_zip_reader_extract_to_mem(&archive, file_index, (void *)(uintptr_t)out_ptr, (size_t)out_capacity, 0);
    if (!ok) {
        mz_zip_reader_end(&archive);
        return -1306 - (int)mz_zip_get_last_error(&archive);
    }

    mz_zip_reader_end(&archive);
    return (int)file_stat.m_uncomp_size;
}

int miniz_secret_matches_expected(int message_ptr, int message_len) {
    if (message_len != (int)(sizeof(expected_text) - 1u)) {
        return 0;
    }

    if (memcmp((const void *)(uintptr_t)message_ptr, expected_text, (size_t)message_len) != 0) {
        return 0;
    }

    return 1;
}
