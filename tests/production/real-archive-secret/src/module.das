options gen2

def c2da_min_int(a : int; b : int) : int {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_int(a : int; b : int) : int {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_min_uint(a : uint; b : uint) : uint {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_uint(a : uint; b : uint) : uint {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_min_int64(a : int64; b : int64) : int64 {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_int64(a : int64; b : int64) : int64 {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_min_uint64(a : uint64; b : uint64) : uint64 {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_uint64(a : uint64; b : uint64) : uint64 {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_clip_uint(v : int) : uint {
    if (v < 0) {
        return 0x0
    }
    if (v > 255) {
        return 0xff
    }
    return uint(v)
}
def c2da_bool_to_uint(v : bool) : uint {
    if (v) {
        return 0x1
    } else {
        return 0x0
    }
}
def c2da___assert_fail(expr : void?; file : void?; line : uint; func : void?) {
}
typedef size_t = uint64
typedef time_t = int64
typedef mz_ulong = uint64
typedef mz_alloc_func = function?
typedef mz_free_func = function?
typedef mz_realloc_func = function?
struct mz_internal_state {
}
struct mz_stream_s {
    next_in : uint8 const?
    avail_in : uint
    total_in : uint64
    next_out : uint8?
    avail_out : uint
    total_out : uint64
    msg : int8?
    state : mz_internal_state?
    zalloc : mz_alloc_func
    zfree : mz_free_func
    opaque : uint64
    data_type : int
    adler : uint64
    reserved : uint64
}
struct mz_stream {
    next_in : uint8 const?
    avail_in : uint
    total_in : uint64
    next_out : uint8?
    avail_out : uint
    total_out : uint64
    msg : int8?
    state : mz_internal_state?
    zalloc : mz_alloc_func
    zfree : mz_free_func
    opaque : uint64
    data_type : int
    adler : uint64
    reserved : uint64
}
typedef mz_streamp = mz_stream_s?
typedef int16_t = int16
typedef uint16_t = uint16
typedef uint32_t = uint
typedef uint64_t = uint64
typedef uintptr_t = uint64
typedef mz_uint8 = uint8
typedef mz_int16 = int16
typedef mz_uint16 = uint16
typedef mz_uint32 = uint
typedef mz_uint = uint
typedef mz_uint64 = uint64
typedef mz_bool = int
struct tinfl_decompressor_tag {
    m_state : uint
    m_num_bits : uint
    m_zhdr0 : uint
    m_zhdr1 : uint
    m_z_adler32 : uint
    m_final : uint
    m_type : uint
    m_check_adler32 : uint
    m_dist : uint
    m_counter : uint
    m_num_extra : uint
    m_table_sizes : array<uint>
    m_bit_buf : uint64
    m_dist_from_out_buf_start : size_t
    m_look_up : array<array<int16>>
    m_tree_0 : array<int16>
    m_tree_1 : array<int16>
    m_tree_2 : array<int16>
    m_code_size_0 : array<uint8>
    m_code_size_1 : array<uint8>
    m_code_size_2 : array<uint8>
    m_raw_header : array<uint8>
    m_len_codes : array<uint8>
}
typedef tinfl_bit_buf_t = uint64
struct tinfl_decompressor {
    m_state : uint
    m_num_bits : uint
    m_zhdr0 : uint
    m_zhdr1 : uint
    m_z_adler32 : uint
    m_final : uint
    m_type : uint
    m_check_adler32 : uint
    m_dist : uint
    m_counter : uint
    m_num_extra : uint
    m_table_sizes : array<uint>
    m_bit_buf : uint64
    m_dist_from_out_buf_start : size_t
    m_look_up : array<array<int16>>
    m_tree_0 : array<int16>
    m_tree_1 : array<int16>
    m_tree_2 : array<int16>
    m_code_size_0 : array<uint8>
    m_code_size_1 : array<uint8>
    m_code_size_2 : array<uint8>
    m_raw_header : array<uint8>
    m_len_codes : array<uint8>
}
struct mz_zip_archive_file_stat {
    m_file_index : uint
    m_central_dir_ofs : uint64
    m_version_made_by : uint16
    m_version_needed : uint16
    m_bit_flag : uint16
    m_method : uint16
    m_crc32 : uint
    m_comp_size : uint64
    m_uncomp_size : uint64
    m_internal_attr : uint16
    m_external_attr : uint
    m_local_header_ofs : uint64
    m_comment_size : uint
    m_is_directory : int
    m_is_encrypted : int
    m_is_supported : int
    m_filename : array<int8>
    m_comment : array<int8>
    m_time : int64
}
typedef mz_file_read_func = function?
typedef mz_file_write_func = function?
typedef mz_file_needs_keepalive = function?
struct mz_zip_internal_state_tag {
}
struct mz_zip_internal_state {
}
enum mz_zip_mode {
    MZ_ZIP_MODE_INVALID = 0
    MZ_ZIP_MODE_READING = 1
    MZ_ZIP_MODE_WRITING = 2
    MZ_ZIP_MODE_WRITING_HAS_BEEN_FINALIZED = 3
}
enum mz_zip_type {
    MZ_ZIP_TYPE_INVALID = 0
    MZ_ZIP_TYPE_USER = 1
    MZ_ZIP_TYPE_MEMORY = 2
    MZ_ZIP_TYPE_HEAP = 3
    MZ_ZIP_TYPE_FILE = 4
    MZ_ZIP_TYPE_CFILE = 5
    MZ_ZIP_TOTAL_TYPES = 6
}
enum mz_zip_error {
    MZ_ZIP_NO_ERROR = 0
    MZ_ZIP_UNDEFINED_ERROR = 1
    MZ_ZIP_TOO_MANY_FILES = 2
    MZ_ZIP_FILE_TOO_LARGE = 3
    MZ_ZIP_UNSUPPORTED_METHOD = 4
    MZ_ZIP_UNSUPPORTED_ENCRYPTION = 5
    MZ_ZIP_UNSUPPORTED_FEATURE = 6
    MZ_ZIP_FAILED_FINDING_CENTRAL_DIR = 7
    MZ_ZIP_NOT_AN_ARCHIVE = 8
    MZ_ZIP_INVALID_HEADER_OR_CORRUPTED = 9
    MZ_ZIP_UNSUPPORTED_MULTIDISK = 10
    MZ_ZIP_DECOMPRESSION_FAILED = 11
    MZ_ZIP_COMPRESSION_FAILED = 12
    MZ_ZIP_UNEXPECTED_DECOMPRESSED_SIZE = 13
    MZ_ZIP_CRC_CHECK_FAILED = 14
    MZ_ZIP_UNSUPPORTED_CDIR_SIZE = 15
    MZ_ZIP_ALLOC_FAILED = 16
    MZ_ZIP_FILE_OPEN_FAILED = 17
    MZ_ZIP_FILE_CREATE_FAILED = 18
    MZ_ZIP_FILE_WRITE_FAILED = 19
    MZ_ZIP_FILE_READ_FAILED = 20
    MZ_ZIP_FILE_CLOSE_FAILED = 21
    MZ_ZIP_FILE_SEEK_FAILED = 22
    MZ_ZIP_FILE_STAT_FAILED = 23
    MZ_ZIP_INVALID_PARAMETER = 24
    MZ_ZIP_INVALID_FILENAME = 25
    MZ_ZIP_BUF_TOO_SMALL = 26
    MZ_ZIP_INTERNAL_ERROR = 27
    MZ_ZIP_FILE_NOT_FOUND = 28
    MZ_ZIP_ARCHIVE_TOO_LARGE = 29
    MZ_ZIP_VALIDATION_FAILED = 30
    MZ_ZIP_WRITE_CALLBACK_FAILED = 31
    MZ_ZIP_TOTAL_ERRORS = 32
}
struct mz_zip_archive {
    m_archive_size : uint64
    m_central_directory_file_ofs : uint64
    m_total_files : uint
    m_zip_mode : mz_zip_mode
    m_zip_type : mz_zip_type
    m_last_error : mz_zip_error
    m_file_offset_alignment : uint64
    m_pAlloc : mz_alloc_func
    m_pFree : mz_free_func
    m_pRealloc : mz_realloc_func
    m_pAlloc_opaque : uint64
    m_pRead : mz_file_read_func
    m_pWrite : mz_file_write_func
    m_pNeeds_keepalive : mz_file_needs_keepalive
    m_pIO_opaque : uint64
    m_pState : mz_zip_internal_state_tag?
}
struct mz_zip_reader_extract_iter_state {
    pZip : mz_zip_archive?
    flags : uint
    status : int
    read_buf_size : uint64
    read_buf_ofs : uint64
    read_buf_avail : uint64
    comp_remaining : uint64
    out_buf_ofs : uint64
    cur_file_ofs : uint64
    file_stat : mz_zip_archive_file_stat
    pRead_buf : uint64
    pWrite_buf : uint64
    out_blk_remain : size_t
    inflator : tinfl_decompressor_tag
    file_crc32 : uint
}
[export]
def deflateInit(var pStream : mz_streamp; var level : int) : int {
    return mz_deflateInit(pStream, level)
}
[export]
def deflateInit2(var pStream_0 : mz_streamp; var level_0 : int; var method : int; var window_bits : int; var mem_level : int; var strategy : int) : int {
    return mz_deflateInit2(pStream_0, level_0, method, window_bits, mem_level, strategy)
}
[export]
def deflateReset(var pStream_1 : mz_streamp) : int {
    return mz_deflateReset(pStream_1)
}
[export]
def deflate(var pStream_2 : mz_streamp; var flush : int) : int {
    return mz_deflate(pStream_2, flush)
}
[export]
def deflateEnd(var pStream_3 : mz_streamp) : int {
    return mz_deflateEnd(pStream_3)
}
[export]
def deflateBound(var pStream_4 : mz_streamp; var source_len : uint64) : uint64 {
    return mz_deflateBound(pStream_4, source_len)
}
[export]
def compress(var pDest : uint8?; var pDest_len : uint64?; var pSource : uint8 const?; var source_len_0 : uint64) : int {
    return mz_compress(pDest, pDest_len, pSource, source_len_0)
}
[export]
def compress2(var pDest_0 : uint8?; var pDest_len_0 : uint64?; var pSource_0 : uint8 const?; var source_len_1 : uint64; var level_1 : int) : int {
    return mz_compress2(pDest_0, pDest_len_0, pSource_0, source_len_1, level_1)
}
[export]
def compressBound(var source_len_2 : uint64) : uint64 {
    return mz_compressBound(source_len_2)
}
[export]
def inflateInit(var pStream_5 : mz_streamp) : int {
    return mz_inflateInit(pStream_5)
}
[export]
def inflateInit2(var pStream_6 : mz_streamp; var window_bits_0 : int) : int {
    return mz_inflateInit2(pStream_6, window_bits_0)
}
[export]
def inflateReset(var pStream_7 : mz_streamp) : int {
    return mz_inflateReset(pStream_7)
}
[export]
def inflate(var pStream_8 : mz_streamp; var flush_0 : int) : int {
    return mz_inflate(pStream_8, flush_0)
}
[export]
def inflateEnd(var pStream_9 : mz_streamp) : int {
    return mz_inflateEnd(pStream_9)
}
[export]
def uncompress(var pDest_1 : uint8?; var pDest_len_1 : uint64?; var pSource_1 : uint8 const?; var source_len_3 : uint64) : int {
    return mz_uncompress(pDest_1, pDest_len_1, pSource_1, source_len_3)
}
[export]
def uncompress2(var pDest_2 : uint8?; var pDest_len_2 : uint64?; var pSource_2 : uint8 const?; var pSource_len : uint64?) : int {
    return mz_uncompress2(pDest_2, pDest_len_2, pSource_2, pSource_len)
}
[export]
def crc32(var crc : uint64; var ptr : uint8 const?; var buf_len : size_t) : uint64 {
    return mz_crc32(crc, ptr, buf_len)
}
[export]
def adler32(var adler : uint64; var ptr_0 : uint8 const?; var buf_len_0 : size_t) : uint64 {
    return mz_adler32(adler, ptr_0, buf_len_0)
}
[export]
def zError(var err : int) : int8 const? {
    return unsafe(unsafe(reinterpret<int8 const?>(mz_error(err))))
}
[export]
def c2da___bswap_16(var c2da___bsx : uint16) : uint16 {
    return uint16(uint(uint(int(c2da___bsx)) >> uint(8)) & uint(255) | uint(int(uint(int(c2da___bsx)) & uint(255) << uint(8))))
}
[export]
def c2da___bswap_32(var c2da___bsx_0 : uint) : uint {
    return uint(uint(uint(c2da___bsx_0)) & uint(0xff000000)) >> uint(uint(24)) | uint(uint(uint(c2da___bsx_0)) & uint(0xff0000)) >> uint(uint(8)) | uint(uint(uint(c2da___bsx_0)) & uint(0xff00)) << uint(uint(8)) | uint(uint(uint(c2da___bsx_0)) & uint(0xff)) << uint(uint(24))
}
[export]
def c2da___bswap_64(var c2da___bsx_1 : uint64) : uint64 {
    return uint64(uint64(c2da___bsx_1) & uint64(0xff00000000000000uL)) >> uint64(uint64(56)) | uint64(uint64(c2da___bsx_1) & uint64(0xff000000000000uL)) >> uint64(uint64(40)) | uint64(uint64(c2da___bsx_1) & uint64(0xff0000000000uL)) >> uint64(uint64(24)) | uint64(uint64(c2da___bsx_1) & uint64(0xff00000000uL)) >> uint64(uint64(8)) | uint64(uint64(c2da___bsx_1) & uint64(0xff000000)) << uint64(uint64(8)) | uint64(uint64(c2da___bsx_1) & uint64(0xff0000)) << uint64(uint64(24)) | uint64(uint64(c2da___bsx_1) & uint64(0xff00)) << uint64(uint64(40)) | uint64(uint64(c2da___bsx_1) & uint64(0xff)) << uint64(uint64(56))
}
[export]
def c2da___uint16_identity(var c2da___x : uint16) : uint16 {
    return c2da___x
}
[export]
def c2da___uint32_identity(var c2da___x_0 : uint) : uint {
    return c2da___x_0
}
[export]
def c2da___uint64_identity(var c2da___x_1 : uint64) : uint64 {
    return c2da___x_1
}
var secret_name : array<int8> const = "secretik.txt"

var expected_text : array<int8> const = "Hi Bebra 2026!"

[export]
def miniz_secret_alloc(var size : int) : int {
    var ptr_1 : uint64 = uint64(0)
    ptr_1 = uint64(0x0)
    if (int(size) < 0) {
        return 0
    } else {
        ptr_1 = unsafe(malloc(unsafe(reinterpret<size_t>(size))))
        return int(ptr_1)
    }
}
[export]
def miniz_secret_expected_length() : int {
    return int(4 - int(int(uint64(0x1))))
}
[export]
def miniz_secret_extract_message(var archive_ptr : int; var archive_size : int; var out_ptr : int; var out_capacity : int) : int {
    var archive : mz_zip_archive = mz_zip_archive()
    var file_index : uint = uint(0)
    var heap_result : uint64 = uint64(0)
    var heap_size : size_t = unsafe(reinterpret<size_t>(0))
    var ok : int = int(0)
    file_index = uint(0)
    heap_result = uint64(0x0)
    heap_size = unsafe(reinterpret<size_t>(0))
    ok = 0
    if (uint64(int(archive_ptr)) == uint64(0) || int(archive_size) <= 0 || uint64(int(out_ptr)) == uint64(0) || int(out_capacity) <= 0) {
        return -1001
    } else {
        mz_zip_zero_struct(unsafe(addr(archive)))
        ok = mz_zip_reader_init_mem(unsafe(addr(archive)), unsafe(reinterpret<uintptr_t>(archive_ptr)), unsafe(reinterpret<size_t>(archive_size)), uint(0))
        if (uint64(ok) == uint64(0)) {
            return -1002 - int(mz_zip_get_last_error(unsafe(addr(archive))))
        } else {
            ok = mz_zip_reader_locate_file_v2(unsafe(addr(archive)), unsafe(addr(secret_name[0])), null, uint(0), unsafe(addr(file_index)))
            if (uint64(ok) == uint64(0)) {
                mz_zip_reader_end(unsafe(addr(archive)))
                return -1003 - int(mz_zip_get_last_error(unsafe(addr(archive))))
            } else {
                heap_result = mz_zip_reader_extract_to_heap(unsafe(addr(archive)), file_index, unsafe(addr(heap_size)), uint(0))
                if (uint64(heap_result) == uint64(0)) {
                    mz_zip_reader_end(unsafe(addr(archive)))
                    return -1004 - int(mz_zip_get_last_error(unsafe(addr(archive))))
                } elif (int(heap_size) > int(out_capacity)) {
                    mz_free(heap_result)
                    mz_zip_reader_end(unsafe(addr(archive)))
                    return -1005 - int(heap_size)
                } else {
                    memcpy(unsafe(reinterpret<uintptr_t>(out_ptr)), heap_result, uint64(heap_size))
                    mz_free(heap_result)
                    mz_zip_reader_end(unsafe(addr(archive)))
                    return int(heap_size)
                }
            }
        }
    }
}
[export]
def miniz_secret_extract_message_iter(var archive_ptr_0 : int; var archive_size_0 : int; var out_ptr_0 : int; var out_capacity_0 : int) : int {
    var archive_0 : mz_zip_archive = mz_zip_archive()
    var file_index_0 : uint = uint(0)
    var state : mz_zip_reader_extract_iter_state? = cast<mz_zip_reader_extract_iter_state?>(0)
    var total : size_t = unsafe(reinterpret<size_t>(0))
    var ok_0 : int = int(0)
    var chunk : size_t = unsafe(reinterpret<size_t>(0))
    file_index_0 = uint(0)
    state = null
    total = unsafe(reinterpret<size_t>(0))
    ok_0 = 0
    if (uint64(int(archive_ptr_0)) == uint64(0) || int(archive_size_0) <= 0 || uint64(int(out_ptr_0)) == uint64(0) || int(out_capacity_0) <= 0) {
        return -1101
    } else {
        mz_zip_zero_struct(unsafe(addr(archive_0)))
        ok_0 = mz_zip_reader_init_mem(unsafe(addr(archive_0)), unsafe(reinterpret<uintptr_t>(archive_ptr_0)), unsafe(reinterpret<size_t>(archive_size_0)), uint(0))
        if (uint64(ok_0) == uint64(0)) {
            return -1102 - int(mz_zip_get_last_error(unsafe(addr(archive_0))))
        } else {
            ok_0 = mz_zip_reader_locate_file_v2(unsafe(addr(archive_0)), unsafe(addr(secret_name[0])), null, uint(0), unsafe(addr(file_index_0)))
            if (uint64(ok_0) == uint64(0)) {
                mz_zip_reader_end(unsafe(addr(archive_0)))
                return -1103 - int(mz_zip_get_last_error(unsafe(addr(archive_0))))
            } else {
                state = unsafe(unsafe(reinterpret<mz_zip_reader_extract_iter_state?>(mz_zip_reader_extract_iter_new(unsafe(addr(archive_0)), file_index_0, uint(0)))))
                if (state == null) {
                    mz_zip_reader_end(unsafe(addr(archive_0)))
                    return -1104 - int(mz_zip_get_last_error(unsafe(addr(archive_0))))
                } else {
                    while (true) {
                        if (!unsafe(reinterpret<size_t>(total)) < unsafe(reinterpret<size_t>(out_capacity_0))) {
                            break
                        }
                        chunk = mz_zip_reader_extract_iter_read(state, unsafe(reinterpret<uintptr_t>(out_ptr_0)) + unsafe(reinterpret<uintptr_t>(unsafe(reinterpret<uintptr_t>(unsafe(reinterpret<size_t>(total)))))), unsafe(reinterpret<size_t>(out_capacity_0)) - unsafe(reinterpret<size_t>(total)))
                        if (uint64(unsafe(reinterpret<size_t>(chunk))) == uint64(0)) {
                            break
                            break
                        } else {
                            total = unsafe(reinterpret<size_t>(total + chunk))
                        }
                    }
                    ok_0 = mz_zip_reader_extract_iter_free(state)
                    if (uint64(ok_0) == uint64(0)) {
                        mz_zip_reader_end(unsafe(addr(archive_0)))
                        return -1105 - int(mz_zip_get_last_error(unsafe(addr(archive_0))))
                    } else {
                        mz_zip_reader_end(unsafe(addr(archive_0)))
                        return int(total)
                    }
                }
            }
        }
    }
}
[export]
def miniz_secret_probe_expected_crc32() : int {
    return int(mz_crc32(uint64(0), unsafe(addr(expected_text[0])), 4 - int(int(uint64(0x1)))))
}
[export]
def miniz_secret_probe_buffer_crc32(var ptr_2 : int; var len : int) : int {
    if (uint64(int(ptr_2)) == uint64(0) || int(len) < 0) {
        return 0
    } else {
        return int(mz_crc32(uint64(0), unsafe(reinterpret<uintptr_t>(ptr_2)), unsafe(reinterpret<size_t>(len))))
    }
}
[export]
def miniz_secret_probe_file_crc32(var archive_ptr_1 : int; var archive_size_1 : int) : int {
    var archive_1 : mz_zip_archive = mz_zip_archive()
    var file_index_1 : uint = uint(0)
    var file_stat : mz_zip_archive_file_stat = mz_zip_archive_file_stat()
    var ok_1 : int = int(0)
    file_index_1 = uint(0)
    ok_1 = 0
    if (uint64(int(archive_ptr_1)) == uint64(0) || int(archive_size_1) <= 0) {
        return -1201
    } else {
        mz_zip_zero_struct(unsafe(addr(archive_1)))
        ok_1 = mz_zip_reader_init_mem(unsafe(addr(archive_1)), unsafe(reinterpret<uintptr_t>(archive_ptr_1)), unsafe(reinterpret<size_t>(archive_size_1)), uint(0))
        if (uint64(ok_1) == uint64(0)) {
            return -1202 - int(mz_zip_get_last_error(unsafe(addr(archive_1))))
        } else {
            ok_1 = mz_zip_reader_locate_file_v2(unsafe(addr(archive_1)), unsafe(addr(secret_name[0])), null, uint(0), unsafe(addr(file_index_1)))
            if (uint64(ok_1) == uint64(0)) {
                mz_zip_reader_end(unsafe(addr(archive_1)))
                return -1203 - int(mz_zip_get_last_error(unsafe(addr(archive_1))))
            } else {
                ok_1 = mz_zip_reader_file_stat(unsafe(addr(archive_1)), file_index_1, unsafe(addr(file_stat)))
                if (uint64(ok_1) == uint64(0)) {
                    mz_zip_reader_end(unsafe(addr(archive_1)))
                    return -1204 - int(mz_zip_get_last_error(unsafe(addr(archive_1))))
                } else {
                    mz_zip_reader_end(unsafe(addr(archive_1)))
                    return int(file_stat.m_crc32)
                }
            }
        }
    }
}
[export]
def miniz_secret_extract_message_direct(var archive_ptr_2 : int; var archive_size_2 : int; var out_ptr_1 : int; var out_capacity_1 : int) : int {
    var archive_2 : mz_zip_archive = mz_zip_archive()
    var file_index_2 : uint = uint(0)
    var file_stat_0 : mz_zip_archive_file_stat = mz_zip_archive_file_stat()
    var ok_2 : int = int(0)
    file_index_2 = uint(0)
    ok_2 = 0
    if (uint64(int(archive_ptr_2)) == uint64(0) || int(archive_size_2) <= 0 || uint64(int(out_ptr_1)) == uint64(0) || int(out_capacity_1) <= 0) {
        return -1301
    } else {
        mz_zip_zero_struct(unsafe(addr(archive_2)))
        ok_2 = mz_zip_reader_init_mem(unsafe(addr(archive_2)), unsafe(reinterpret<uintptr_t>(archive_ptr_2)), unsafe(reinterpret<size_t>(archive_size_2)), uint(0))
        if (uint64(ok_2) == uint64(0)) {
            return -1302 - int(mz_zip_get_last_error(unsafe(addr(archive_2))))
        } else {
            ok_2 = mz_zip_reader_locate_file_v2(unsafe(addr(archive_2)), unsafe(addr(secret_name[0])), null, uint(0), unsafe(addr(file_index_2)))
            if (uint64(ok_2) == uint64(0)) {
                mz_zip_reader_end(unsafe(addr(archive_2)))
                return -1303 - int(mz_zip_get_last_error(unsafe(addr(archive_2))))
            } else {
                ok_2 = mz_zip_reader_file_stat(unsafe(addr(archive_2)), file_index_2, unsafe(addr(file_stat_0)))
                if (uint64(ok_2) == uint64(0)) {
                    mz_zip_reader_end(unsafe(addr(archive_2)))
                    return -1304 - int(mz_zip_get_last_error(unsafe(addr(archive_2))))
                } elif (int(file_stat_0.m_uncomp_size) > int(out_capacity_1)) {
                    mz_zip_reader_end(unsafe(addr(archive_2)))
                    return -1305 - int(file_stat_0.m_uncomp_size)
                } else {
                    ok_2 = mz_zip_reader_extract_to_mem(unsafe(addr(archive_2)), file_index_2, unsafe(reinterpret<uintptr_t>(out_ptr_1)), unsafe(reinterpret<size_t>(out_capacity_1)), uint(0))
                    if (uint64(ok_2) == uint64(0)) {
                        mz_zip_reader_end(unsafe(addr(archive_2)))
                        return -1306 - int(mz_zip_get_last_error(unsafe(addr(archive_2))))
                    } else {
                        mz_zip_reader_end(unsafe(addr(archive_2)))
                        return int(file_stat_0.m_uncomp_size)
                    }
                }
            }
        }
    }
}
[export]
def miniz_secret_matches_expected(var message_ptr : int; var message_len : int) : int {
    if (int(message_len) != int(4 - int(int(uint64(0x1))))) {
        return 0
    } elif (uint64(memcmp(unsafe(reinterpret<uintptr_t>(message_ptr)), unsafe(unsafe(reinterpret<uint64>(unsafe(addr(expected_text[0]))))), unsafe(reinterpret<size_t>(message_len)))) != uint64(0)) {
        return 0
    } else {
        return 1
    }
}
var MZ_ZIP_MODE_WRITING_HAS_BEEN_FINALIZED : int = 3

var MZ_ZIP_MODE_WRITING : int = 2

var MZ_ZIP_MODE_READING : int = 1

var MZ_ZIP_MODE_INVALID : int = 0

var MZ_ZIP_TOTAL_TYPES : int = 6

var MZ_ZIP_TYPE_CFILE : int = 5

var MZ_ZIP_TYPE_FILE : int = 4

var MZ_ZIP_TYPE_HEAP : int = 3

var MZ_ZIP_TYPE_MEMORY : int = 2

var MZ_ZIP_TYPE_USER : int = 1

var MZ_ZIP_TYPE_INVALID : int = 0

var MZ_ZIP_TOTAL_ERRORS : int = 32

var MZ_ZIP_WRITE_CALLBACK_FAILED : int = 31

var MZ_ZIP_VALIDATION_FAILED : int = 30

var MZ_ZIP_ARCHIVE_TOO_LARGE : int = 29

var MZ_ZIP_FILE_NOT_FOUND : int = 28

var MZ_ZIP_INTERNAL_ERROR : int = 27

var MZ_ZIP_BUF_TOO_SMALL : int = 26

var MZ_ZIP_INVALID_FILENAME : int = 25

var MZ_ZIP_INVALID_PARAMETER : int = 24

var MZ_ZIP_FILE_STAT_FAILED : int = 23

var MZ_ZIP_FILE_SEEK_FAILED : int = 22

var MZ_ZIP_FILE_CLOSE_FAILED : int = 21

var MZ_ZIP_FILE_READ_FAILED : int = 20

var MZ_ZIP_FILE_WRITE_FAILED : int = 19

var MZ_ZIP_FILE_CREATE_FAILED : int = 18

var MZ_ZIP_FILE_OPEN_FAILED : int = 17

var MZ_ZIP_ALLOC_FAILED : int = 16

var MZ_ZIP_UNSUPPORTED_CDIR_SIZE : int = 15

var MZ_ZIP_CRC_CHECK_FAILED : int = 14

var MZ_ZIP_UNEXPECTED_DECOMPRESSED_SIZE : int = 13

var MZ_ZIP_COMPRESSION_FAILED : int = 12

var MZ_ZIP_DECOMPRESSION_FAILED : int = 11

var MZ_ZIP_UNSUPPORTED_MULTIDISK : int = 10

var MZ_ZIP_INVALID_HEADER_OR_CORRUPTED : int = 9

var MZ_ZIP_NOT_AN_ARCHIVE : int = 8

var MZ_ZIP_FAILED_FINDING_CENTRAL_DIR : int = 7

var MZ_ZIP_UNSUPPORTED_FEATURE : int = 6

var MZ_ZIP_UNSUPPORTED_ENCRYPTION : int = 5

var MZ_ZIP_UNSUPPORTED_METHOD : int = 4

var MZ_ZIP_FILE_TOO_LARGE : int = 3

var MZ_ZIP_TOO_MANY_FILES : int = 2

var MZ_ZIP_UNDEFINED_ERROR : int = 1

var MZ_ZIP_NO_ERROR : int = 0


[export] def main() : int {
    return 0
}
