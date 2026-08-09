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
typedef int16_t = int16
typedef int64_t = int64
typedef uint8_t = uint8
typedef uint16_t = uint16
typedef uint32_t = uint
typedef uint64_t = uint64
typedef uintptr_t = uint64
struct allocation_header_s {
    size : size_t
}
struct allocation_header {
    size : size_t
}
typedef mz_ulong = uint64
typedef mz_uint32 = uint
typedef mz_uint8 = uint8
typedef mz_alloc_func = function<(opaque:uint64; items:uint64; item_size:uint64):uint64>
typedef mz_free_func = function<(opaque:uint64; address:uint64):void>
typedef mz_realloc_func = function<(opaque:uint64; address:uint64; new_size:uint64):uint64>
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
enum tdefl_status {
    TDEFL_STATUS_BAD_PARAM = -2
    TDEFL_STATUS_PUT_BUF_FAILED = -1
    TDEFL_STATUS_OKAY = 0
    TDEFL_STATUS_DONE = 1
}
typedef mz_uint = uint
typedef tdefl_put_buf_func_ptr = function<(pBuf:uint64; len:int; pUser:uint64):int>
typedef mz_bool = int
struct tdefl_compressor {
    m_pPut_buf_func : tdefl_put_buf_func_ptr
    m_pPut_buf_user : uint64
    m_flags : uint
    m_max_probes : array<uint>
    m_greedy_parsing : int
    m_adler32 : uint
    m_lookahead_pos : uint
    m_lookahead_size : uint
    m_dict_size : uint
    m_pLZ_code_buf : uint8?
    m_pLZ_flags : uint8?
    m_pOutput_buf : uint8?
    m_pOutput_buf_end : uint8?
    m_num_flags_left : uint
    m_total_lz_bytes : uint
    m_lz_code_buf_dict_pos : uint
    m_bits_in : uint
    m_bit_buffer : uint
    m_saved_match_dist : uint
    m_saved_match_len : uint
    m_saved_lit : uint
    m_output_flush_ofs : uint
    m_output_flush_remaining : uint
    m_finished : uint
    m_block_index : uint
    m_wants_to_finish : uint
    m_prev_return_status : tdefl_status
    m_pIn_buf : uint64
    m_pOut_buf : uint64
    m_pIn_buf_size : size_t?
    m_pOut_buf_size : size_t?
    m_flush : tdefl_flush
    m_pSrc : uint8 const?
    m_src_buf_left : size_t
    m_out_buf_ofs : size_t
    m_dict : array<uint8>
    m_huff_count : array<array<uint16>>
    m_huff_codes : array<array<uint16>>
    m_huff_code_sizes : array<array<uint8>>
    m_lz_code_buf : array<uint8>
    m_next : array<uint16>
    m_hash : array<uint16>
    m_output_buf : array<uint8>
}
typedef mz_uint16 = uint16
enum tdefl_flush {
    TDEFL_NO_FLUSH = 0
    TDEFL_SYNC_FLUSH = 2
    TDEFL_FULL_FLUSH = 3
    TDEFL_FINISH = 4
}
struct tdefl_sym_freq {
    m_key : uint16
    m_sym_index : uint16
}
typedef mz_uint64 = uint64
struct inflate_state {
    m_decomp : tinfl_decompressor_tag
    m_dict_ofs : uint
    m_dict_avail : uint
    m_first_call : uint
    m_has_flushed : uint
    m_window_bits : int
    m_dict : array<uint8>
    m_last_status : tinfl_status
}
enum tinfl_status {
    TINFL_STATUS_FAILED_CANNOT_MAKE_PROGRESS = -4
    TINFL_STATUS_BAD_PARAM = -3
    TINFL_STATUS_ADLER32_MISMATCH = -2
    TINFL_STATUS_FAILED = -1
    TINFL_STATUS_DONE = 0
    TINFL_STATUS_NEEDS_MORE_INPUT = 1
    TINFL_STATUS_HAS_MORE_OUTPUT = 2
}
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
typedef mz_int16 = int16
typedef tinfl_bit_buf_t = uint64
struct Unnamed {
    m_err : int
    m_pDesc : int8 const?
}
typedef mz_int64 = int64
struct mz_dummy_time_t_tag {
    m_dummy1 : uint
    m_dummy2 : uint
}
struct mz_dummy_time_t {
    m_dummy1 : uint
    m_dummy2 : uint
}
struct tdefl_output_buffer {
    m_size : size_t
    m_capacity : size_t
    m_pBuf : uint8?
    m_expandable : int
}
typedef tinfl_put_buf_func_ptr = function<(pBuf:uint64; len:int; pUser:uint64):int>
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
    m_padding : mz_dummy_time_t_tag
}
typedef mz_file_read_func = function?
typedef mz_file_write_func = function?
typedef mz_file_needs_keepalive = function?
struct mz_zip_internal_state_tag {
    m_central_dir : mz_zip_array
    m_central_dir_offsets : mz_zip_array
    m_sorted_central_dir_offsets : mz_zip_array
    m_init_flags : uint
    m_zip64 : int
    m_zip64_has_extended_info_fields : int
    m_pFile : uint64?
    m_file_archive_start_ofs : uint64
    m_pMem : uint64
    m_mem_size : size_t
    m_mem_capacity : size_t
}
struct mz_zip_array {
    m_p : uint64
    m_size : size_t
    m_capacity : size_t
    m_element_size : uint
}
struct mz_zip_internal_state {
    m_central_dir : mz_zip_array
    m_central_dir_offsets : mz_zip_array
    m_sorted_central_dir_offsets : mz_zip_array
    m_init_flags : uint
    m_zip64 : int
    m_zip64_has_extended_info_fields : int
    m_pFile : uint64?
    m_file_archive_start_ofs : uint64
    m_pMem : uint64
    m_mem_size : size_t
    m_mem_capacity : size_t
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
struct mz_zip_writer_add_state {
    m_pZip : mz_zip_archive?
    m_cur_archive_file_ofs : uint64
    m_comp_size : uint64
}


var heap : array<uint8>

var heap_offset : size_t = unsafe(reinterpret<size_t>(0))

[export]
def min_size(var lhs : size_t; var rhs : size_t) : size_t {
    var c2da_fresh0 : size_t = unsafe(reinterpret<size_t>(0))
    if (unsafe(reinterpret<size_t>(lhs)) < unsafe(reinterpret<size_t>(rhs))) {
        c2da_fresh0 = lhs
    } else {
        c2da_fresh0 = rhs
    }
    return c2da_fresh0
}
[export]
def miniz_secret_reset() {
    heap_offset = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
    return
}
[export]
def memset(var dest : uint64; var value : int; var count : size_t) : uint64 {
    return dest
}
[export]
def memcpy(var dest_0 : uint64; var src_0 : uint64; var count_0 : size_t) : uint64 {
    return dest_0
}
[export]
def memcmp(var c2da___s1 : uint64; var c2da___s2 : uint64; var c2da___n_0 : size_t) : int {
    return 0
}
[export]
def strlen(var src_1 : int8 const?) : size_t {
    return unsafe(reinterpret<size_t>(0))
}
[export]
def malloc(var size : size_t) : uint64 {
    return uint64(0)
}
[export]
def free(var ptr : uint64) {
    return
}
[export]
def realloc(var ptr_0 : uint64; var size_0 : size_t) : uint64 {
    return uint64(0)
}
[export]
def calloc(var c2da___nmemb : size_t; var c2da___size : size_t) : uint64 {
    return uint64(0)
}
[export]
def memmove(var c2da___dest : uint64; var c2da___src : uint64; var c2da___n : size_t) : uint64 {
    return c2da___dest
}
[export]
def mz_free(var p : uint64) {
    unsafe(free(p))
    return
}
[export]
def mz_adler32(var adler : uint64; var ptr : uint8 const?; var buf_len : size_t) : uint64 {
    var i_3 : uint = uint(0)
    var s1 : uint = uint(0)
    var s2 : uint = uint(0)
    var block_len : size_t = unsafe(reinterpret<size_t>(0))
    s1 = uint(uint64(adler) & uint64(65535))
    s2 = uint(((uint64((uint64(adler) == uint64(0)) ? 1 : 0) >> uint64((uint64(16) == uint64(0)) ? 1 : 0)) ? 1 : 0) ? 1 : 0)
    block_len = unsafe(reinterpret<size_t>(buf_len)) % unsafe(reinterpret<size_t>(5552))
    if (ptr == null) {
        return uint64(1)
    } elif (uint64(buf_len) != uint64(0)) {
        if (false) {
        }
    } else {
        return uint64(((uint(((uint(s2) == uint(0)) ? 1 : 0) ? 1 : 0) << uint(((uint(16) == uint(0)) ? 1 : 0) ? 1 : 0)) + uint(s1)) ? 1 : 0)
    }
}
[export]
def mz_crc32(var crc : uint64; var ptr_0 : uint8 const?; var buf_len_0 : size_t) : uint64 {
    var s_crc_table : array<uint> const = [uint(0), uint(1996959894), 0xee0e612c, 0x990951ba, uint(124634137), uint(1886057615), 0xe963a535, 0x9e6495a3, uint(249268274), uint(2044508324), 0xe0d5e91e, 0x97d2d988, uint(162941995), uint(2125561021), 0xe7b82d07, 0x90bf1d91, uint(498536548), uint(1789927666), 0xf3b97148, 0x84be41de, uint(450548861), uint(1843258603), 0xf4d4b551, 0x83d385c7, uint(325883990), uint(1684777152), 0xfd62f97a, 0x8a65c9ec, uint(335633487), uint(1661365465), 0xfa0f3d63, 0x8d080df5, uint(997073096), uint(1281953886), 0xd56041e4, 0xa2677172, uint(1006888145), uint(1258607687), 0xd20d85fd, 0xa50ab56b, uint(901097722), uint(1119000684), 0xdbbbc9d6, 0xacbcf940, uint(853044451), uint(1172266101), 0xdcd60dcf, 0xabd13d59, uint(651767980), uint(1373503546), 0xc8d75180, 0xbfd06116, uint(565507253), uint(1454621731), 0xcfba9599, 0xb8bda50f, uint(671266974), uint(1594198024), 0xc60cd9b2, 0xb10be924, uint(795835527), uint(1483230225), 0xc1611dab, 0xb6662d3d, uint(1994146192), uint(31158534), 0x98d220bc, 0xefd5102a, uint(1907459465), uint(112637215), 0x9fbfe4a5, 0xe8b8d433, uint(2013776290), uint(251722036), 0x9609a88e, 0xe10e9818, uint(2137656763), uint(141376813), 0x91646c97, 0xe6635c01, uint(1802195444), uint(476864866), 0x856530d8, 0xf262004e, uint(1812370925), uint(453092731), 0x8208f4c1, 0xf50fc457, uint(1706088902), uint(314042704), 0x8bbeb8ea, 0xfcb9887c, uint(1658658271), uint(366619977), 0x8cd37cf3, 0xfbd44c65, uint(1303535960), uint(984961486), 0xa3bc0074, 0xd4bb30e2, uint(1256170817), uint(1037604311), 0xa4d1c46d, 0xd3d6f4fb, uint(1131014506), uint(879679996), 0xad678846, 0xda60b8d0, uint(1141124467), uint(855842277), 0xaa0a4c5f, 0xdd0d7cc9, uint(1342533948), uint(654459306), 0xbe0b1010, 0xc90c2086, uint(1466479909), uint(544179635), 0xb966d409, 0xce61e49f, uint(1591671054), uint(702138776), 0xb0d09822, 0xc7d7a8b4, uint(1504918807), uint(783551873), 0xb7bd5c3b, 0xc0ba6cad, 0xedb88320, 0x9abfb3b6, uint(62317068), uint(1957810842), 0xead54739, 0x9dd277af, uint(81470997), uint(1943803523), 0xe3630b12, 0x94643b84, uint(225274430), uint(2053790376), 0xe40ecf0b, 0x9309ff9d, uint(167816743), uint(2097651377), 0xf00f9344, 0x8708a3d2, uint(503444072), uint(1762050814), 0xf762575d, 0x806567cb, uint(426522225), uint(1852507879), 0xfed41b76, 0x89d32be0, uint(282753626), uint(1742555852), 0xf9b9df6f, 0x8ebeeff9, uint(397917763), uint(1622183637), 0xd6d6a3e8, 0xa1d1937e, uint(953729732), uint(1340076626), 0xd1bb67f1, 0xa6bc5767, uint(1068828381), uint(1219638859), 0xd80d2bda, 0xaf0a1b4c, uint(906185462), uint(1090812512), 0xdf60efc3, 0xa867df55, uint(829329135), uint(1181335161), 0xcb61b38c, 0xbc66831a, uint(628085408), uint(1382605366), 0xcc0c7795, 0xbb0b4703, uint(570562233), uint(1426400815), 0xc5ba3bbe, 0xb2bd0b28, uint(733239954), uint(1555261956), 0xc2d7ffa7, 0xb5d0cf31, uint(752459403), uint(1541320221), 0x9b64c2b0, 0xec63f226, uint(1969922972), uint(40735498), 0x9c0906a9, 0xeb0e363f, uint(1913087877), uint(83908371), 0x95bf4a82, 0xe2b87a14, uint(2075208622), uint(213261112), 0x92d28e9b, 0xe5d5be0d, uint(2094854071), uint(198958881), 0x86d3d2d4, 0xf1d4e242, uint(1759359992), uint(534414190), 0x81be16cd, 0xf6b9265b, uint(1873836001), uint(414664567), 0x88085ae6, 0xff0f6a70, uint(1711684554), uint(285281116), 0x8f659eff, 0xf862ae69, uint(1634467795), uint(376229701), 0xa00ae278, 0xd70dd2ee, uint(1308918612), uint(956543938), 0xa7672661, 0xd06016f7, uint(1231636301), uint(1047427035), 0xaed16a4a, 0xd9d65adc, uint(1088359270), uint(936918000), 0xa9bcae53, 0xdebb9ec5, uint(1202900863), uint(817233897), 0xbdbdf21c, 0xcabac28a, uint(1404277552), uint(615818150), 0xbad03605, 0xcdd70693, uint(1423857449), uint(601450431), 0xb3667a2e, 0xc4614ab8, uint(1567103746), uint(711928724), 0xb40bbe37, 0xc30c8ea1, uint(1510334235), uint(755167117)]
    var crc32 : uint = uint(0)
    var pByte_buf : uint8 const? = null
    crc32 = uint(((uint(crc) == uint(0)) ? 1 : 0) ? 1 : 0) ^ uint(0xffffffff)
    pByte_buf = ptr_0
    while (true) {
        if (!unsafe(reinterpret<size_t>(buf_len_0)) >= unsafe(reinterpret<size_t>(4))) {
            if (false) {
            }
        }
        crc32 = uint(((uint(uint(crc32) == uint(0)) >> uint(uint(8) == uint(0)) ^ unsafe(unsafe(addr(s_crc_table[0]))[(uint(crc32) ^ uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pByte_buf)))[0]))) & uint(255)])) ? 1 : 0) ? 1 : 0)
        crc32 = uint(((uint(uint(crc32) == uint(0)) >> uint(uint(8) == uint(0)) ^ unsafe(unsafe(addr(s_crc_table[0]))[(uint(crc32) ^ uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pByte_buf)))[1]))) & uint(255)])) ? 1 : 0) ? 1 : 0)
        crc32 = uint(((uint(uint(crc32) == uint(0)) >> uint(uint(8) == uint(0)) ^ unsafe(unsafe(addr(s_crc_table[0]))[(uint(crc32) ^ uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pByte_buf)))[2]))) & uint(255)])) ? 1 : 0) ? 1 : 0)
        crc32 = uint(((uint(uint(crc32) == uint(0)) >> uint(uint(8) == uint(0)) ^ unsafe(unsafe(addr(s_crc_table[0]))[(uint(crc32) ^ uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pByte_buf)))[3]))) & uint(255)])) ? 1 : 0) ? 1 : 0)
        pByte_buf = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(pByte_buf + 4))))
        buf_len_0 = unsafe(reinterpret<size_t>(buf_len_0 - unsafe(reinterpret<size_t>(4))))
    }
    while (true) {
        if (!(uint64(buf_len_0) != uint64(0))) {
            if (false) {
            }
        }
        crc32 = uint(((uint(uint(crc32) == uint(0)) >> uint(uint(8) == uint(0)) ^ unsafe(unsafe(addr(s_crc_table[0]))[(uint(crc32) ^ uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pByte_buf)))[0]))) & uint(255)])) ? 1 : 0) ? 1 : 0)
        pByte_buf = unsafe(pByte_buf + uint64(1))
        pByte_buf
        buf_len_0 = buf_len_0 - uint64(1)
        buf_len_0
    }
    return uint64(~crc32)
}
[export]
def mz_version() : int8 const? {
    return unsafe(unsafe(reinterpret<int8 const?>(unsafe(addr(uint8(49))))))
}
[export]
def mz_deflateInit(var pStream : mz_streamp; var level : int) : int {
    return mz_deflateInit2(pStream, level, 8, 15, 9, MZ_DEFAULT_STRATEGY)
}
[export]
def mz_deflateInit2(var pStream_0 : mz_streamp; var level_0 : int; var method : int; var window_bits : int; var mem_level : int; var strategy : int) : int {
    var pComp : tdefl_compressor? = null
    var comp_flags : uint = uint(0)
    comp_flags = uint(TDEFL_COMPUTE_ADLER32) | tdefl_create_comp_flags_from_zip_params(level_0, window_bits, strategy)
    if (pStream_0 == null) {
        return MZ_STREAM_ERROR
    } elif (int(method) != 8 || int(mem_level) < 1 || int(mem_level) > 9 || int(window_bits) != 15 && -window_bits != 15) {
        return MZ_PARAM_ERROR
    } else {
        pStream_0.data_type = 0
        pStream_0.adler = uint64((uint64(1) == uint64(0)) ? 1 : 0)
        pStream_0.msg = null
        pStream_0.reserved = uint64((uint64(0) == uint64(0)) ? 1 : 0)
        pStream_0.total_in = uint64((uint64(0) == uint64(0)) ? 1 : 0)
        pStream_0.total_out = uint64((uint64(0) == uint64(0)) ? 1 : 0)
        if (pStream_0.zalloc == null) {
            pStream_0.zalloc = miniz_def_alloc_func
        }
        if (pStream_0.zfree == null) {
            pStream_0.zfree = miniz_def_free_func
        }
        pComp = unsafe(unsafe(reinterpret<tdefl_compressor?>(pStream_0.zalloc(pStream_0.opaque, unsafe(reinterpret<size_t>(1)), 4))))
        if (pComp == null) {
            return MZ_MEM_ERROR
        } else {
            pStream_0.state = unsafe(unsafe(reinterpret<mz_internal_state?>(pComp)))
            if (int(tdefl_init(pComp, null, uint64(0), int(comp_flags))) != int(TDEFL_STATUS_OKAY)) {
                mz_deflateEnd(pStream_0)
                return MZ_PARAM_ERROR
            } else {
                return MZ_OK
            }
        }
    }
}
[export]
def mz_deflateEnd(var pStream_1 : mz_streamp) : int {
    if (pStream_1 == null) {
        return MZ_STREAM_ERROR
    } else {
        if (pStream_1.state != null) {
            pStream_1.zfree(pStream_1.opaque, unsafe(unsafe(reinterpret<uint64>(pStream_1.state))))
            pStream_1.state = null
        }
        return MZ_OK
    }
}
[export]
def tdefl_create_comp_flags_from_zip_params(var level_1 : int; var window_bits_0 : int; var strategy_0 : int) : uint {
    var comp_flags_0 : uint = uint(0)
    var c2da_fresh1 : int = int(0)
    if (10 < int(level_1)) {
        c2da_fresh1 = 10
    } else {
        c2da_fresh1 = level_1
    }
    var c2da_fresh2 : int = int(0)
    if (int(level_1) >= 0) {
        c2da_fresh2 = c2da_fresh1
    } else {
        c2da_fresh2 = MZ_DEFAULT_LEVEL
    }
    var c2da_fresh3 : int = int(0)
    if (int(level_1) <= 3) {
        c2da_fresh3 = TDEFL_GREEDY_PARSING_FLAG
    } else {
        c2da_fresh3 = 0
    }
    comp_flags_0 = unsafe(unsafe(addr(s_tdefl_num_probes[0]))[uint(c2da_fresh2)]) | uint(c2da_fresh3)
    if (int(window_bits_0) > 0) {
        comp_flags_0 = uint(comp_flags_0 | uint(TDEFL_WRITE_ZLIB_HEADER))
    }
    if (uint64(level_1) == uint64(0)) {
        comp_flags_0 = uint(comp_flags_0 | uint(TDEFL_FORCE_ALL_RAW_BLOCKS))
    } elif (int(strategy_0) == int(MZ_FILTERED)) {
        comp_flags_0 = uint(comp_flags_0 | uint(TDEFL_FILTER_MATCHES))
    } elif (int(strategy_0) == int(MZ_HUFFMAN_ONLY)) {
        comp_flags_0 = uint(comp_flags_0 & uint(~TDEFL_MAX_PROBES_MASK))
    } elif (int(strategy_0) == int(MZ_FIXED)) {
        comp_flags_0 = uint(comp_flags_0 | uint(TDEFL_FORCE_ALL_STATIC_BLOCKS))
    } elif (int(strategy_0) == int(MZ_RLE)) {
        comp_flags_0 = uint(comp_flags_0 | uint(TDEFL_RLE_MATCHES))
    }
    return comp_flags_0
}
var s_tdefl_num_probes : array<uint> const = [uint(0), uint(1), uint(6), uint(32), uint(16), uint(32), uint(128), uint(256), uint(512), uint(768), uint(1500)]

[export]
def tdefl_init(var d : tdefl_compressor?; var pPut_buf_func : tdefl_put_buf_func_ptr; var pPut_buf_user : uint64; var flags : int) : tdefl_status {
    d.m_pPut_buf_func = pPut_buf_func
    d.m_pPut_buf_user = pPut_buf_user
    d.m_flags = uint(((uint(flags) == uint(0)) ? 1 : 0) ? 1 : 0)
    unsafe(unsafe(addr(d.m_max_probes[0]))[0]) = uint(((uint(1 + ((uint(int(flags) == int(0)) & uint(4095)) + 2) / 3)) ? 1 : 0) ? 1 : 0)
    d.m_greedy_parsing = int((uint64(int(flags) & int(TDEFL_GREEDY_PARSING_FLAG)) != uint64(0)) ? 1 : 0)
    unsafe(unsafe(addr(d.m_max_probes[0]))[1]) = uint(((uint(1 + ((int(uint(int(flags) == int(0)) & uint(4095) >> uint(2))) + 2) / 3)) ? 1 : 0) ? 1 : 0)
    if (uint64(int(flags) & int(TDEFL_NONDETERMINISTIC_PARSING_FLAG)) == uint64(0)) {
        memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(d.m_hash[0]))))), 0, uint64(4))
    }
    d.m_bits_in = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
    d.m_lz_code_buf_dict_pos = d.m_bits_in
    d.m_total_lz_bytes = d.m_lz_code_buf_dict_pos
    d.m_dict_size = d.m_total_lz_bytes
    d.m_lookahead_size = d.m_dict_size
    d.m_lookahead_pos = d.m_lookahead_size
    d.m_wants_to_finish = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
    d.m_bit_buffer = d.m_wants_to_finish
    d.m_block_index = d.m_bit_buffer
    d.m_finished = d.m_block_index
    d.m_output_flush_remaining = d.m_finished
    d.m_output_flush_ofs = d.m_output_flush_remaining
    d.m_pLZ_code_buf = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(addr(d.m_lz_code_buf[0])) + 1))))
    d.m_pLZ_flags = unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(d.m_lz_code_buf[0])))))
    *d.m_pLZ_flags = uint8(uint8(0))
    d.m_num_flags_left = uint(((uint(8) == uint(0)) ? 1 : 0) ? 1 : 0)
    d.m_pOutput_buf = unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(d.m_output_buf[0])))))
    d.m_pOutput_buf_end = unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(d.m_output_buf[0])))))
    d.m_prev_return_status = unsafe(reinterpret<tdefl_status>(TDEFL_STATUS_OKAY))
    d.m_saved_lit = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
    d.m_saved_match_len = d.m_saved_lit
    d.m_saved_match_dist = d.m_saved_match_len
    d.m_adler32 = uint(((uint(1) == uint(0)) ? 1 : 0) ? 1 : 0)
    d.m_pIn_buf = uint64(0x0)
    d.m_pOut_buf = uint64(0)
    d.m_pIn_buf_size = null
    d.m_pOut_buf_size = null
    d.m_flush = unsafe(reinterpret<tdefl_flush>(TDEFL_NO_FLUSH))
    d.m_pSrc = null
    d.m_src_buf_left = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
    d.m_out_buf_ofs = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
    if (uint64(int(flags) & int(TDEFL_NONDETERMINISTIC_PARSING_FLAG)) == uint64(0)) {
        memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(d.m_dict[0]))))), 0, uint64(4))
    }
    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(unsafe(unsafe(addr(unsafe(unsafe(addr(d.m_huff_count[0]))[0])[0]))[0])))))), 0, uint64((4 * int((uint64(TDEFL_MAX_HUFF_SYMBOLS_0) == uint64(0)) ? 1 : 0)) ? 1 : 0))
    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(unsafe(unsafe(addr(unsafe(unsafe(addr(d.m_huff_count[0]))[1])[0]))[0])))))), 0, uint64((4 * int((uint64(TDEFL_MAX_HUFF_SYMBOLS_1) == uint64(0)) ? 1 : 0)) ? 1 : 0))
    return unsafe(reinterpret<tdefl_status>(TDEFL_STATUS_OKAY))
}
[export]
def miniz_def_free_func(var opaque : uint64; var address : uint64) {
    address
    unsafe(free(address))
    return
}
[export]
def miniz_def_alloc_func(var opaque_0 : uint64; var items : size_t; var size : size_t) : uint64 {
    size
    return unsafe(unsafe(reinterpret<uint64>(unsafe(malloc(unsafe(reinterpret<size_t>(items)) * unsafe(reinterpret<size_t>(size)))))))
}
[export]
def mz_deflateReset(var pStream_2 : mz_streamp) : int {
    if (pStream_2 == null || pStream_2.state == null || pStream_2.zalloc == null || pStream_2.zfree == null) {
        return MZ_STREAM_ERROR
    } else {
        pStream_2.total_out = uint64((uint64(0) == uint64(0)) ? 1 : 0)
        pStream_2.total_in = pStream_2.total_out
        tdefl_init(pStream_2.state, null, uint64(0), int(pStream_2.state.m_flags))
        return MZ_OK
    }
}
[export]
def mz_deflate(var pStream_3 : mz_streamp; var flush : int) : int {
    var in_bytes : size_t = unsafe(reinterpret<size_t>(0))
    var out_bytes : size_t = unsafe(reinterpret<size_t>(0))
    var orig_total_in : uint64 = uint64(0)
    var orig_total_out : uint64 = uint64(0)
    var mz_status : int = int(0)
    mz_status = MZ_OK
    if (pStream_3 == null || pStream_3.state == null || int(flush) < 0 || int(flush) > int(MZ_FINISH) || pStream_3.next_out == null) {
        return MZ_STREAM_ERROR
    } elif (uint64(pStream_3.avail_out) == uint64(0)) {
        return MZ_BUF_ERROR
    } else {
        if (int(flush) == int(MZ_PARTIAL_FLUSH)) {
            flush = MZ_SYNC_FLUSH
        }
        if (int(pStream_3.state.m_prev_return_status) == int(TDEFL_STATUS_DONE)) {
            var c2da_fresh4 : int = int(0)
            if (int(flush) == int(MZ_FINISH)) {
                c2da_fresh4 = MZ_STREAM_END
            } else {
                c2da_fresh4 = MZ_BUF_ERROR
            }
            return c2da_fresh4
        } else {
            orig_total_in = uint64(pStream_3.total_in)
            orig_total_out = uint64(pStream_3.total_out)
            if (false) {
            }
        }
    }
}
[export]
def tdefl_get_adler32(var d_0 : tdefl_compressor?) : uint {
    return d_0.m_adler32
}
[export]
def tdefl_compress(var d_1 : tdefl_compressor?; var pIn_buf : uint64; var pIn_buf_size : size_t?; var pOut_buf : uint64; var pOut_buf_size : size_t?; var flush_0 : tdefl_flush) : tdefl_status {
    if (d_1 == null) {
        if (pIn_buf_size != null) {
            *pIn_buf_size = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
        }
        if (pOut_buf_size != null) {
            *pOut_buf_size = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
        }
        return unsafe(reinterpret<tdefl_status>(TDEFL_STATUS_BAD_PARAM))
    } else {
        d_1.m_pIn_buf = pIn_buf
        d_1.m_pIn_buf_size = unsafe(unsafe(reinterpret<size_t?>(pIn_buf_size)))
        d_1.m_pOut_buf = pOut_buf
        d_1.m_pOut_buf_size = unsafe(unsafe(reinterpret<size_t?>(pOut_buf_size)))
        d_1.m_pSrc = unsafe(unsafe(reinterpret<uint8 const?>(pIn_buf)))
        var c2da_fresh5 : size_t = unsafe(reinterpret<size_t>(0))
        if (uint64(pIn_buf_size) != uint64(0)) {
            c2da_fresh5 = *pIn_buf_size
        } else {
            c2da_fresh5 = unsafe(reinterpret<size_t>(0))
        }
        d_1.m_src_buf_left = unsafe(reinterpret<size_t>(c2da_fresh5))
        d_1.m_out_buf_ofs = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
        d_1.m_flush = flush_0
        if (unsafe(unsafe(reinterpret<uint64>(d_1.m_pPut_buf_func)) != unsafe(reinterpret<uint64>(unsafe(unsafe(reinterpret<tdefl_put_buf_func_ptr>(uint64(0) == uint64(0))))))) == (unsafe(uint64((unsafe(reinterpret<uint64>(uint64(pOut_buf) == uint64(0)))) ? 1 : 0) != uint64(0)) || unsafe(unsafe(reinterpret<uint64>(pOut_buf_size)) != unsafe(reinterpret<uint64>(unsafe(unsafe(reinterpret<size_t?>(uint64(0) == uint64(0)))))))) || int(d_1.m_prev_return_status) != int(TDEFL_STATUS_OKAY) || uint64(d_1.m_wants_to_finish) != uint64(0) && uint(flush_0) != uint(TDEFL_FINISH) || pIn_buf_size != null && uint64(*pIn_buf_size) != uint64(0) && uint64(pIn_buf) == uint64(0) || pOut_buf_size != null && uint64(*pOut_buf_size) != uint64(0) && uint64(pOut_buf) == uint64(0)) {
            if (pIn_buf_size != null) {
                *pIn_buf_size = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
            }
            if (pOut_buf_size != null) {
                *pOut_buf_size = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
            }
            d_1.m_prev_return_status = unsafe(reinterpret<tdefl_status>(TDEFL_STATUS_BAD_PARAM))
            return d_1.m_prev_return_status
        } else {
            d_1.m_wants_to_finish = uint(((d_1.m_wants_to_finish | uint(uint(flush_0) == uint(TDEFL_FINISH))) ? 1 : 0) ? 1 : 0)
            if (uint64(d_1.m_output_flush_remaining) != uint64(0) || uint64(d_1.m_finished) != uint64(0)) {
                d_1.m_prev_return_status = tdefl_flush_output_buffer(d_1)
                return d_1.m_prev_return_status
            } elif (uint64((tdefl_compress_normal(d_1) == uint64(0)) ? 1 : 0) == uint64(0)) {
                return d_1.m_prev_return_status
            } else {
                if (uint64(uint(d_1.m_flags) & uint(int(TDEFL_WRITE_ZLIB_HEADER) | int(TDEFL_COMPUTE_ADLER32))) != uint64(0) && uint64(pIn_buf) != uint64(0)) {
                    d_1.m_adler32 = uint(uint(mz_adler32(uint64(d_1.m_adler32), pIn_buf, unsafe(reinterpret<size_t>(unsafe(d_1.m_pSrc - pIn_buf))))))
                }
                if (uint64((uint(flush_0) == uint(0)) ? 1 : 0) != uint64(0) && uint64(d_1.m_lookahead_size) == uint64(0) && uint64(d_1.m_src_buf_left) == uint64(0) && uint64(d_1.m_output_flush_remaining) == uint64(0)) {
                    if (tdefl_flush_block(d_1, int(flush_0)) < 0) {
                        return d_1.m_prev_return_status
                    } else {
                        d_1.m_finished = uint(((uint(uint(flush_0) == uint(TDEFL_FINISH))) ? 1 : 0) ? 1 : 0)
                        if (uint(flush_0) == uint(TDEFL_FULL_FLUSH)) {
                            memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(d_1.m_hash[0]))))), 0, uint64(4))
                            memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(d_1.m_next[0]))))), 0, uint64(4))
                            d_1.m_dict_size = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
                        }
                    }
                }
                d_1.m_prev_return_status = tdefl_flush_output_buffer(d_1)
                return d_1.m_prev_return_status
            }
        }
    }
}
[export]
def tdefl_flush_output_buffer(var d_2 : tdefl_compressor?) : tdefl_status {
    var n : size_t = unsafe(reinterpret<size_t>(0))
    if (d_2.m_pIn_buf_size != null) {
        *d_2.m_pIn_buf_size = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(unsafe(d_2.m_pSrc - d_2.m_pIn_buf)))))
    }
    if (d_2.m_pOut_buf_size != null) {
        n = c2da_min_int((int(unsafe(reinterpret<size_t>(*d_2.m_pOut_buf_size) == int(0)) - unsafe(reinterpret<size_t>(d_2.m_out_buf_ofs))), int(unsafe(reinterpret<size_t>(d_2.m_output_flush_remaining)))) ? 1 : 0)
        memcpy(unsafe(unsafe(reinterpret<uint64>(unsafe(d_2.m_pOut_buf + unsafe(reinterpret<size_t>(d_2.m_out_buf_ofs)))))), unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(d_2.m_output_buf[0])) + uint(d_2.m_output_flush_ofs))))), uint64(n))
        d_2.m_output_flush_ofs = uint(d_2.m_output_flush_ofs + uint(n))
        d_2.m_output_flush_remaining = uint(d_2.m_output_flush_remaining - uint(n))
        d_2.m_out_buf_ofs = unsafe(reinterpret<size_t>(d_2.m_out_buf_ofs + n))
        *d_2.m_pOut_buf_size = unsafe(reinterpret<size_t>(d_2.m_out_buf_ofs))
    }
    var c2da_fresh6 : int = int(0)
    if (uint64(d_2.m_finished) != uint64(0) && uint64(d_2.m_output_flush_remaining) == uint64(0)) {
        c2da_fresh6 = TDEFL_STATUS_DONE
    } else {
        c2da_fresh6 = TDEFL_STATUS_OKAY
    }
    return unsafe(reinterpret<tdefl_status>(c2da_fresh6))
}
[export]
def tdefl_flush_block(var d_3 : tdefl_compressor?; var flush_1 : int) : int {
    var saved_bit_buf : uint = uint(0)
    var saved_bits_in : uint = uint(0)
    var pSaved_output_buf : uint8? = null
    var comp_block_succeeded : int = int(0)
    var n_0 : int = int(0)
    var use_raw_block : int = int(0)
    var pOutput_buf_start : uint8? = null
    var cmf : uint8 const = uint8(0)
    var flg : uint8 = uint8(0)
    var flevel : uint8 = uint8(0)
    var header_0 : uint = uint(0)
    var i_4 : uint = uint(0)
    var mz_un : uint = uint(0)
    var bits : uint = uint(0)
    var len : uint = uint(0)
    var bits_0 : uint = uint(0)
    var len_0 : uint = uint(0)
    var bits_1 : uint = uint(0)
    var len_1 : uint = uint(0)
    var i_5 : uint = uint(0)
    var bits_2 : uint = uint(0)
    var len_2 : uint = uint(0)
    var bits_3 : uint = uint(0)
    var len_3 : uint = uint(0)
    var bits_4 : uint = uint(0)
    var len_4 : uint = uint(0)
    var bits_5 : uint = uint(0)
    var len_5 : uint = uint(0)
    var i_7 : uint = uint(0)
    var z : uint = uint(0)
    var bits_8 : uint = uint(0)
    var len_8 : uint = uint(0)
    var bits_9 : uint = uint(0)
    var len_9 : uint = uint(0)
    var bits_6 : uint = uint(0)
    var len_6 : uint = uint(0)
    var i_6 : uint = uint(0)
    var a : uint = uint(0)
    var bits_7 : uint = uint(0)
    var len_7 : uint = uint(0)
    var bits_10 : uint = uint(0)
    var len_10 : uint = uint(0)
    var bytes_to_copy : int = int(0)
    comp_block_succeeded = 0
    use_raw_block = uint64(uint(d_3.m_flags) & uint(TDEFL_FORCE_ALL_RAW_BLOCKS)) != uint64(0) && uint(d_3.m_lookahead_pos) - uint(d_3.m_lz_code_buf_dict_pos) <= uint(d_3.m_dict_size)
    var c2da_fresh7 : uint8? = null
    if (unsafe(unsafe(reinterpret<uint64>(d_3.m_pPut_buf_func)) == unsafe(reinterpret<uint64>(unsafe(unsafe(reinterpret<tdefl_put_buf_func_ptr>(uint64(0) == uint64(0))))))) && unsafe(reinterpret<size_t>(*d_3.m_pOut_buf_size)) - unsafe(reinterpret<size_t>(d_3.m_out_buf_ofs)) >= unsafe(reinterpret<size_t>(TDEFL_OUT_BUF_SIZE)) ){
        c2da_fresh7 = unsafe(d_3.m_pOut_buf + unsafe(reinterpret<size_t>(d_3.m_out_buf_ofs)))
    } else {
        c2da_fresh7 = unsafe(addr(d_3.m_output_buf[0]))
    }
    pOutput_buf_start = c2da_fresh7
    d_3.m_pOutput_buf = unsafe(unsafe(reinterpret<uint8?>(pOutput_buf_start)))
    d_3.m_pOutput_buf_end = unsafe(unsafe(reinterpret<uint8?>(unsafe(d_3.m_pOutput_buf + (int(TDEFL_OUT_BUF_SIZE) - 16)))))
    {
        if (uint64(d_3.m_output_flush_remaining) == uint64(0)) {
        } else {
            c2da___assert_fail(null, null, uint(0), null)
        }
    }
    d_3.m_output_flush_ofs = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
    d_3.m_output_flush_remaining = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
    *d_3.m_pLZ_flags = uint8(uint8(int((int(*d_3.m_pLZ_flags) == int(0)) ? 1 : 0) >> int((int(uint(d_3.m_num_flags_left) == int(0))) ? 1 : 0)))
    d_3.m_pLZ_code_buf = unsafe(unsafe(reinterpret<uint8?>(unsafe(d_3.m_pLZ_code_buf - (uint(d_3.m_num_flags_left) == uint(8))))))
    if (uint64(uint(d_3.m_flags) & uint(TDEFL_WRITE_ZLIB_HEADER)) != uint64(0) && uint64(d_3.m_block_index) == uint64(0)) {
        cmf = uint8(120)
        flevel = uint8(3)
        mz_un = uint(4 / 4)
        if (false) {
        }
    } else {
        while (true) {
            bits_1 = uint(((int(flush_1) == int(TDEFL_FINISH)) ? 1 : 0) ? 1 : 0)
            len_1 = uint(1)
            {
                if (uint(bits_1) <= (0x1 << uint(len_1)) - 0x1) {
                } else {
                    c2da___assert_fail(null, null, uint(0), null)
                }
            }
            d_3.m_bit_buffer = uint(d_3.m_bit_buffer | uint(bits_1) << uint(d_3.m_bits_in))
            d_3.m_bits_in = uint(d_3.m_bits_in + len_1)
            while (true) {
                if (!(uint(d_3.m_bits_in) >= uint(8))) {
                    if (false) {
                    }
                }
                if (unsafe(unsafe(reinterpret<uint64>(d_3.m_pOutput_buf)) < unsafe(reinterpret<uint64>(d_3.m_pOutput_buf_end)))) {
                    d_3.m_pOutput_buf = unsafe(d_3.m_pOutput_buf + uint64(1))
                    *d_3.m_pOutput_buf = uint8(uint8(d_3.m_bit_buffer))
                }
                d_3.m_bit_buffer = uint(uint(d_3.m_bit_buffer) >> uint(8))
                d_3.m_bits_in = uint(d_3.m_bits_in - uint(8))
            }
            if (!(uint64(0) != uint64(0))) {
                if (false) {
                }
            }
        }
        pSaved_output_buf = unsafe(unsafe(reinterpret<uint8?>(d_3.m_pOutput_buf)))
        saved_bit_buf = uint(d_3.m_bit_buffer)
        saved_bits_in = uint(d_3.m_bits_in)
        if (uint64(use_raw_block) == uint64(0)) {
            comp_block_succeeded = tdefl_compress_block(d_3, uint64(uint(d_3.m_flags) & uint(TDEFL_FORCE_ALL_STATIC_BLOCKS)) != uint64(0) || uint(d_3.m_total_lz_bytes) < uint(48))
        }
        if (uint64(use_raw_block) != uint64(0) || uint64(d_3.m_total_lz_bytes) != uint64(0) && unsafe(d_3.m_pOutput_buf - pSaved_output_buf) + int64(0x1) >= int64(d_3.m_total_lz_bytes) && uint(d_3.m_lookahead_pos) - uint(d_3.m_lz_code_buf_dict_pos) <= uint(d_3.m_dict_size)) {
            d_3.m_pOutput_buf = unsafe(unsafe(reinterpret<uint8?>(pSaved_output_buf)))
            d_3.m_bits_in = uint(saved_bits_in)
            while (true) {
                bits_2 = uint(0)
                len_2 = uint(2)
                {
                    if (uint(bits_2) <= (0x1 << uint(len_2)) - 0x1) {
                    } else {
                        c2da___assert_fail(null, null, uint(0), null)
                    }
                }
                d_3.m_bit_buffer = uint(d_3.m_bit_buffer | uint(bits_2) << uint(d_3.m_bits_in))
                d_3.m_bits_in = uint(d_3.m_bits_in + len_2)
                while (true) {
                    if (!(uint(d_3.m_bits_in) >= uint(8))) {
                        if (false) {
                        }
                    }
                    if (unsafe(unsafe(reinterpret<uint64>(d_3.m_pOutput_buf)) < unsafe(reinterpret<uint64>(d_3.m_pOutput_buf_end)))) {
                        d_3.m_pOutput_buf = unsafe(d_3.m_pOutput_buf + uint64(1))
                        *d_3.m_pOutput_buf = uint8(uint8(d_3.m_bit_buffer))
                    }
                    d_3.m_bit_buffer = uint(uint(d_3.m_bit_buffer) >> uint(8))
                    d_3.m_bits_in = uint(d_3.m_bits_in - uint(8))
                }
                if (!(uint64(0) != uint64(0))) {
                    if (false) {
                    }
                }
            }
            if (uint64(d_3.m_bits_in) != uint64(0)) {
                while (true) {
                    bits_3 = uint(0)
                    len_3 = uint(8) - uint(d_3.m_bits_in)
                    {
                        if (uint(bits_3) <= (0x1 << uint(len_3)) - 0x1) {
                        } else {
                            c2da___assert_fail(null, null, uint(0), null)
                        }
                    }
                    d_3.m_bit_buffer = uint(d_3.m_bit_buffer | uint(bits_3) << uint(d_3.m_bits_in))
                    d_3.m_bits_in = uint(d_3.m_bits_in + len_3)
                    while (true) {
                        if (!(uint(d_3.m_bits_in) >= uint(8))) {
                            if (false) {
                            }
                        }
                        if (unsafe(unsafe(reinterpret<uint64>(d_3.m_pOutput_buf)) < unsafe(reinterpret<uint64>(d_3.m_pOutput_buf_end)))) {
                            d_3.m_pOutput_buf = unsafe(d_3.m_pOutput_buf + uint64(1))
                            *d_3.m_pOutput_buf = uint8(uint8(d_3.m_bit_buffer))
                        }
                        d_3.m_bit_buffer = uint(uint(d_3.m_bit_buffer) >> uint(8))
                        d_3.m_bits_in = uint(d_3.m_bits_in - uint(8))
                    }
                    if (!(uint64(0) != uint64(0))) {
                        if (false) {
                        }
                    }
                }
                if (false) {
                }
            } else {
                if (false) {
                }
            }
        } else {
            if (uint64(comp_block_succeeded) == uint64(0)) {
                d_3.m_pOutput_buf = unsafe(unsafe(reinterpret<uint8?>(pSaved_output_buf)))
                d_3.m_bits_in = uint(saved_bits_in)
                tdefl_compress_block(d_3, 1)
            }
            if (uint64(flush_1) != uint64(0)) {
                if (int(flush_1) == int(TDEFL_FINISH)) {
                    if (uint64(d_3.m_bits_in) != uint64(0)) {
                        while (true) {
                            bits_6 = uint(0)
                            len_6 = uint(8) - uint(d_3.m_bits_in)
                            {
                                if (uint(bits_6) <= (0x1 << uint(len_6)) - 0x1) {
                                } else {
                                    c2da___assert_fail(null, null, uint(0), null)
                                }
                            }
                            d_3.m_bit_buffer = uint(d_3.m_bit_buffer | uint(bits_6) << uint(d_3.m_bits_in))
                            d_3.m_bits_in = uint(d_3.m_bits_in + len_6)
                            while (true) {
                                if (!(uint(d_3.m_bits_in) >= uint(8))) {
                                    if (false) {
                                    }
                                }
                                if (unsafe(unsafe(reinterpret<uint64>(d_3.m_pOutput_buf)) < unsafe(reinterpret<uint64>(d_3.m_pOutput_buf_end)))) {
                                    d_3.m_pOutput_buf = unsafe(d_3.m_pOutput_buf + uint64(1))
                                    *d_3.m_pOutput_buf = uint8(uint8(d_3.m_bit_buffer))
                                }
                                d_3.m_bit_buffer = uint(uint(d_3.m_bit_buffer) >> uint(8))
                                d_3.m_bits_in = uint(d_3.m_bits_in - uint(8))
                            }
                            if (!(uint64(0) != uint64(0))) {
                                if (false) {
                                }
                            }
                        }
                    }
                    if (uint64(uint(d_3.m_flags) & uint(TDEFL_WRITE_ZLIB_HEADER)) != uint64(0)) {
                        a = d_3.m_adler32
                        if (false) {
                        }
                    }
                } else {
                    z = uint(0)
                    while (true) {
                        bits_8 = uint(0)
                        len_8 = uint(3)
                        {
                            if (uint(bits_8) <= (0x1 << uint(len_8)) - 0x1) {
                            } else {
                                c2da___assert_fail(null, null, uint(0), null)
                            }
                        }
                        d_3.m_bit_buffer = uint(d_3.m_bit_buffer | uint(bits_8) << uint(d_3.m_bits_in))
                        d_3.m_bits_in = uint(d_3.m_bits_in + len_8)
                        while (true) {
                            if (!(uint(d_3.m_bits_in) >= uint(8))) {
                                if (false) {
                                }
                            }
                            if (unsafe(unsafe(reinterpret<uint64>(d_3.m_pOutput_buf)) < unsafe(reinterpret<uint64>(d_3.m_pOutput_buf_end)))) {
                                d_3.m_pOutput_buf = unsafe(d_3.m_pOutput_buf + uint64(1))
                                *d_3.m_pOutput_buf = uint8(uint8(d_3.m_bit_buffer))
                            }
                            d_3.m_bit_buffer = uint(uint(d_3.m_bit_buffer) >> uint(8))
                            d_3.m_bits_in = uint(d_3.m_bits_in - uint(8))
                        }
                        if (!(uint64(0) != uint64(0))) {
                            if (false) {
                            }
                        }
                    }
                    if (uint64(d_3.m_bits_in) != uint64(0)) {
                        while (true) {
                            bits_9 = uint(0)
                            len_9 = uint(8) - uint(d_3.m_bits_in)
                            {
                                if (uint(bits_9) <= (0x1 << uint(len_9)) - 0x1) {
                                } else {
                                    c2da___assert_fail(null, null, uint(0), null)
                                }
                            }
                            d_3.m_bit_buffer = uint(d_3.m_bit_buffer | uint(bits_9) << uint(d_3.m_bits_in))
                            d_3.m_bits_in = uint(d_3.m_bits_in + len_9)
                            while (true) {
                                if (!(uint(d_3.m_bits_in) >= uint(8))) {
                                    if (false) {
                                    }
                                }
                                if (unsafe(unsafe(reinterpret<uint64>(d_3.m_pOutput_buf)) < unsafe(reinterpret<uint64>(d_3.m_pOutput_buf_end)))) {
                                    d_3.m_pOutput_buf = unsafe(d_3.m_pOutput_buf + uint64(1))
                                    *d_3.m_pOutput_buf = uint8(uint8(d_3.m_bit_buffer))
                                }
                                d_3.m_bit_buffer = uint(uint(d_3.m_bit_buffer) >> uint(8))
                                d_3.m_bits_in = uint(d_3.m_bits_in - uint(8))
                            }
                            if (!(uint64(0) != uint64(0))) {
                                if (false) {
                                }
                            }
                        }
                        if (false) {
                        }
                    } else {
                        if (false) {
                        }
                    }
                }
            }
            {
                if (unsafe(unsafe(reinterpret<uint64>(d_3.m_pOutput_buf)) < unsafe(reinterpret<uint64>(d_3.m_pOutput_buf_end)))) {
                } else {
                    c2da___assert_fail(null, null, uint(0), null)
                }
            }
            memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(unsafe(unsafe(addr(unsafe(unsafe(addr(d_3.m_huff_count[0]))[0])[0]))[0])))))), 0, uint64((4 * int((uint64(TDEFL_MAX_HUFF_SYMBOLS_0) == uint64(0)) ? 1 : 0)) ? 1 : 0))
            memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(unsafe(unsafe(addr(unsafe(unsafe(addr(d_3.m_huff_count[0]))[1])[0]))[0])))))), 0, uint64((4 * int((uint64(TDEFL_MAX_HUFF_SYMBOLS_1) == uint64(0)) ? 1 : 0)) ? 1 : 0))
            d_3.m_pLZ_code_buf = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(addr(d_3.m_lz_code_buf[0])) + 1))))
            d_3.m_pLZ_flags = unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(d_3.m_lz_code_buf[0])))))
            d_3.m_num_flags_left = uint(((uint(8) == uint(0)) ? 1 : 0) ? 1 : 0)
            d_3.m_lz_code_buf_dict_pos = uint(d_3.m_lz_code_buf_dict_pos + d_3.m_total_lz_bytes)
            d_3.m_total_lz_bytes = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
            d_3.m_block_index = d_3.m_block_index + uint(1)
            d_3.m_block_index
            n_0 = int(unsafe(d_3.m_pOutput_buf - pOutput_buf_start))
            if (uint64((int(n_0) == int(0)) ? 1 : 0) != uint64(0)) {
                if (d_3.m_pPut_buf_func != null) {
                    *d_3.m_pIn_buf_size = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(unsafe(d_3.m_pSrc - d_3.m_pIn_buf)))))
                    if (uint64((*d_3.m_pPut_buf_func(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(d_3.m_output_buf[0]) == uint64(0))))), n_0, d_3.m_pPut_buf_user)) ? 1 : 0) == uint64(0)) {
                        d_3.m_prev_return_status = unsafe(reinterpret<tdefl_status>(TDEFL_STATUS_PUT_BUF_FAILED))
                        return int(d_3.m_prev_return_status)
                    }
                } elif (unsafe(unsafe(reinterpret<uint64>(pOutput_buf_start)) == unsafe(reinterpret<uint64>(unsafe(addr(d_3.m_output_buf[0])))))) {
                    bytes_to_copy = int((c2da_min_int(int(unsafe(reinterpret<size_t>(n_0) == int(0))), int(unsafe(reinterpret<size_t>(*d_3.m_pOut_buf_size)) - unsafe(reinterpret<size_t>(d_3.m_out_buf_ofs))))) ? 1 : 0)
                    memcpy(unsafe(unsafe(reinterpret<uint64>(unsafe(d_3.m_pOut_buf + unsafe(reinterpret<size_t>(d_3.m_out_buf_ofs)))))), unsafe(unsafe(reinterpret<uint64>(unsafe(addr(d_3.m_output_buf[0]))))), uint64((uint64(bytes_to_copy) == uint64(0)) ? 1 : 0))
                    d_3.m_out_buf_ofs = unsafe(reinterpret<size_t>(d_3.m_out_buf_ofs + unsafe(reinterpret<size_t>(bytes_to_copy))))
                    n_0 = n_0 - bytes_to_copy
                    if (uint64((int(n_0) == int(0)) ? 1 : 0) != uint64(0)) {
                        d_3.m_output_flush_ofs = uint(((uint(bytes_to_copy) == uint(0)) ? 1 : 0) ? 1 : 0)
                        d_3.m_output_flush_remaining = uint(((uint(n_0) == uint(0)) ? 1 : 0) ? 1 : 0)
                    }
                } else {
                    d_3.m_out_buf_ofs = unsafe(reinterpret<size_t>(d_3.m_out_buf_ofs + unsafe(reinterpret<size_t>(n_0))))
                }
            }
            return int(d_3.m_output_flush_remaining)
        }
    }
}
[export]
def tdefl_compress_block(var d_4 : tdefl_compressor?; var static_block : int) : int {
    if (uint64(static_block) != uint64(0)) {
        tdefl_start_static_block(d_4)
    } else {
        tdefl_start_dynamic_block(d_4)
    }
    return tdefl_compress_lz_codes(d_4)
}
[export]
def tdefl_compress_lz_codes(var d_5 : tdefl_compressor?) : int {
    var flags_0 : uint = uint(0)
    var pLZ_codes : uint8? = null
    flags_0 = uint(((uint(1) == uint(0)) ? 1 : 0) ? 1 : 0)
    if (false) {
    }
}
var mz_bitmasks : array<uint> const = [uint(0), uint(1), uint(3), uint(7), uint(15), uint(31), uint(63), uint(127), uint(255), uint(511), uint(1023), uint(2047), uint(4095), uint(8191), uint(16383), uint(32767), uint(65535)]

var s_tdefl_large_dist_extra : array<uint8> const = [uint8(0), uint8(0), uint8(8), uint8(8), uint8(9), uint8(9), uint8(9), uint8(9), uint8(10), uint8(10), uint8(10), uint8(10), uint8(10), uint8(10), uint8(10), uint8(10), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13)]

var s_tdefl_large_dist_sym : array<uint8> const = [uint8(0), uint8(0), uint8(18), uint8(19), uint8(20), uint8(20), uint8(21), uint8(21), uint8(22), uint8(22), uint8(22), uint8(22), uint8(23), uint8(23), uint8(23), uint8(23), uint8(24), uint8(24), uint8(24), uint8(24), uint8(24), uint8(24), uint8(24), uint8(24), uint8(25), uint8(25), uint8(25), uint8(25), uint8(25), uint8(25), uint8(25), uint8(25), uint8(26), uint8(26), uint8(26), uint8(26), uint8(26), uint8(26), uint8(26), uint8(26), uint8(26), uint8(26), uint8(26), uint8(26), uint8(26), uint8(26), uint8(26), uint8(26), uint8(27), uint8(27), uint8(27), uint8(27), uint8(27), uint8(27), uint8(27), uint8(27), uint8(27), uint8(27), uint8(27), uint8(27), uint8(27), uint8(27), uint8(27), uint8(27), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(28), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29), uint8(29)]

var s_tdefl_small_dist_extra : array<uint8> const = [uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(1), uint8(1), uint8(1), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7)]

var s_tdefl_small_dist_sym : array<uint8> const = [uint8(0), uint8(1), uint8(2), uint8(3), uint8(4), uint8(4), uint8(5), uint8(5), uint8(6), uint8(6), uint8(6), uint8(6), uint8(7), uint8(7), uint8(7), uint8(7), uint8(8), uint8(8), uint8(8), uint8(8), uint8(8), uint8(8), uint8(8), uint8(8), uint8(9), uint8(9), uint8(9), uint8(9), uint8(9), uint8(9), uint8(9), uint8(9), uint8(10), uint8(10), uint8(10), uint8(10), uint8(10), uint8(10), uint8(10), uint8(10), uint8(10), uint8(10), uint8(10), uint8(10), uint8(10), uint8(10), uint8(10), uint8(10), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(11), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(12), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(13), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(14), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(15), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17), uint8(17)]

var s_tdefl_len_extra : array<uint8> const = [uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(1), uint8(1), uint8(1), uint8(1), uint8(1), uint8(1), uint8(1), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(0)]

var s_tdefl_len_sym : array<uint16> const = [uint16(257), uint16(258), uint16(259), uint16(260), uint16(261), uint16(262), uint16(263), uint16(264), uint16(265), uint16(265), uint16(266), uint16(266), uint16(267), uint16(267), uint16(268), uint16(268), uint16(269), uint16(269), uint16(269), uint16(269), uint16(270), uint16(270), uint16(270), uint16(270), uint16(271), uint16(271), uint16(271), uint16(271), uint16(272), uint16(272), uint16(272), uint16(272), uint16(273), uint16(273), uint16(273), uint16(273), uint16(273), uint16(273), uint16(273), uint16(273), uint16(274), uint16(274), uint16(274), uint16(274), uint16(274), uint16(274), uint16(274), uint16(274), uint16(275), uint16(275), uint16(275), uint16(275), uint16(275), uint16(275), uint16(275), uint16(275), uint16(276), uint16(276), uint16(276), uint16(276), uint16(276), uint16(276), uint16(276), uint16(276), uint16(277), uint16(277), uint16(277), uint16(277), uint16(277), uint16(277), uint16(277), uint16(277), uint16(277), uint16(277), uint16(277), uint16(277), uint16(277), uint16(277), uint16(277), uint16(277), uint16(278), uint16(278), uint16(278), uint16(278), uint16(278), uint16(278), uint16(278), uint16(278), uint16(278), uint16(278), uint16(278), uint16(278), uint16(278), uint16(278), uint16(278), uint16(278), uint16(279), uint16(279), uint16(279), uint16(279), uint16(279), uint16(279), uint16(279), uint16(279), uint16(279), uint16(279), uint16(279), uint16(279), uint16(279), uint16(279), uint16(279), uint16(279), uint16(280), uint16(280), uint16(280), uint16(280), uint16(280), uint16(280), uint16(280), uint16(280), uint16(280), uint16(280), uint16(280), uint16(280), uint16(280), uint16(280), uint16(280), uint16(280), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(281), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(282), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(283), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(284), uint16(285)]

[export]
def tdefl_start_dynamic_block(var d_6 : tdefl_compressor?) {
    var num_lit_codes : int = int(0)
    var num_dist_codes : int = int(0)
    var num_bit_lengths : int = int(0)
    var i_8 : uint = uint(0)
    var total_code_sizes_to_pack : uint = uint(0)
    var num_packed_code_sizes : uint = uint(0)
    var rle_z_count : uint = uint(0)
    var rle_repeat_count : uint = uint(0)
    var packed_code_sizes_index : uint = uint(0)
    var code_sizes_to_pack : array<uint8> = []
    var packed_code_sizes : array<uint8> = []
    var prev_code_size : uint8 = uint8(0)
    prev_code_size = uint8(255)
    unsafe(unsafe(addr(unsafe(unsafe(addr(d_6.m_huff_count[0]))[0])[0]))[256]) = uint16(uint16(1))
    tdefl_optimize_huffman_table(d_6, 0, TDEFL_MAX_HUFF_SYMBOLS_0, 15, 0)
    tdefl_optimize_huffman_table(d_6, 1, TDEFL_MAX_HUFF_SYMBOLS_1, 15, 0)
    if (false) {
    }
}
var s_tdefl_packed_code_size_syms_swizzle : array<uint8> const = [uint8(16), uint8(17), uint8(18), uint8(0), uint8(8), uint8(7), uint8(9), uint8(6), uint8(10), uint8(5), uint8(11), uint8(4), uint8(12), uint8(3), uint8(13), uint8(2), uint8(14), uint8(1), uint8(15)]

[export]
def tdefl_optimize_huffman_table(var d_7 : tdefl_compressor?; var table_num : int; var table_len : int; var code_size_limit : int; var static_table : int) {
    var i_9 : int = int(0)
    var j : int = int(0)
    var l : int = int(0)
    var num_codes : array<int> = []
    var next_code : array<uint> = []
    var syms0 : array<tdefl_sym_freq> = []
    var syms1 : array<tdefl_sym_freq> = []
    var pSyms : tdefl_sym_freq? = null
    var num_used_syms : int = int(0)
    var pSym_count : uint16 const? = null
    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(num_codes[0]))))), 0, uint64(4))
    if (uint64(static_table) != uint64(0)) {
        if (false) {
        }
    } else {
        num_used_syms = 0
        pSym_count = unsafe(addr(unsafe(unsafe(addr(unsafe(unsafe(addr(d_7.m_huff_count[0]))[uint(table_num)])[0]))[0])))
        if (false) {
        }
    }
}
[export]
def tdefl_huffman_enforce_max_code_size(var pNum_codes : int?; var code_list_len : int; var max_code_size : int) {
    var i_10 : int = int(0)
    var total_1 : uint = uint(0)
    total_1 = uint(0)
    if (int(code_list_len) <= 1) {
        return
    } else {
        if (false) {
        }
    }
}
[export]
def tdefl_calculate_minimum_redundancy(var A : tdefl_sym_freq?; var n_1 : int) {
    var root : int = int(0)
    var leaf : int = int(0)
    var next : int = int(0)
    var avbl : int = int(0)
    var used : int = int(0)
    var dpth : int = int(0)
    if (uint64((int(n_1) == uint64(0)) ? 1 : 0) == uint64(0)) {
        return
    } elif (int(n_1) == 1) {
        unsafe(unsafe(unsafe(reinterpret<tdefl_sym_freq?>(A)))[0]).m_key = uint16(uint16(1))
        return
    } else {
        unsafe(unsafe(unsafe(reinterpret<tdefl_sym_freq?>(A)))[0]).m_key = unsafe(unsafe(unsafe(reinterpret<tdefl_sym_freq?>(A)))[0]).m_key + int(unsafe(unsafe(unsafe(reinterpret<tdefl_sym_freq?>(A)))[1]).m_key)
        root = 0
        leaf = 2
        if (false) {
        }
    }
}
[export]
def tdefl_radix_sort_syms(var num_syms : uint; var pSyms0 : tdefl_sym_freq?; var pSyms1 : tdefl_sym_freq?) : tdefl_sym_freq? {
    var total_passes : uint = uint(0)
    var pass_shift : uint = uint(0)
    var pass_0 : uint = uint(0)
    var i_11 : uint = uint(0)
    var hist : array<uint> = []
    var pCur_syms : tdefl_sym_freq? = null
    var pNew_syms : tdefl_sym_freq? = null
    total_passes = uint(2)
    pCur_syms = pSyms0
    pNew_syms = pSyms1
    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(hist[0]))))), 0, uint64(4))
    if (false) {
    }
}
[export]
def tdefl_start_static_block(var d_8 : tdefl_compressor?) {
    var i_12 : uint = uint(0)
    var p_0 : uint8? = null
    p_0 = unsafe(addr(unsafe(unsafe(addr(unsafe(unsafe(addr(d_8.m_huff_code_sizes[0]))[0])[0]))[0])))
    if (false) {
    }
}
[export]
def tdefl_compress_normal(var d_9 : tdefl_compressor?) : int {
    var pSrc : uint8 const? = null
    var src_buf_left : size_t = unsafe(reinterpret<size_t>(0))
    var flush_2 : tdefl_flush = unsafe(reinterpret<tdefl_flush>(0))
    var len_to_move : uint = uint(0)
    var cur_match_dist : uint = uint(0)
    var cur_match_len : uint = uint(0)
    var cur_pos : uint = uint(0)
    var c_0 : uint8 = uint8(0)
    var dst_pos_0 : uint = uint(0)
    var ins_pos_0 : uint = uint(0)
    var hash_0 : uint = uint(0)
    var dst_pos : uint = uint(0)
    var ins_pos : uint = uint(0)
    var hash : uint = uint(0)
    var num_bytes_to_process : uint = uint(0)
    var pSrc_end : uint8 const? = null
    var c : uint8 = uint8(0)
    var c_1 : uint8 = uint8(0)
    var n_2 : int = int(0)
    pSrc = d_9.m_pSrc
    src_buf_left = d_9.m_src_buf_left
    flush_2 = d_9.m_flush
    while (true) {
        if (!(uint64(src_buf_left) != uint64(0) || uint64((uint(flush_2) == uint(0)) ? 1 : 0) != uint64(0) && uint64(d_9.m_lookahead_size) != uint64(0)) ){
            if (false) {
            }
        }
        if (uint(d_9.m_lookahead_size) + uint(d_9.m_dict_size) >= uint(int(TDEFL_MIN_MATCH_LEN) - 1)) {
            dst_pos = uint(d_9.m_lookahead_pos) + uint(d_9.m_lookahead_size) & uint(TDEFL_LZ_DICT_SIZE_MASK)
            ins_pos = uint(d_9.m_lookahead_pos) + (uint(d_9.m_lookahead_size) - uint(2))
            hash = uint(((int(unsafe(unsafe(addr(d_9.m_dict[0]) == int(0))[uint(ins_pos) & uint(TDEFL_LZ_DICT_SIZE_MASK)])) << int(TDEFL_LZ_HASH_SHIFT) ^ int(unsafe(unsafe(addr(d_9.m_dict[0]))[uint(ins_pos) + uint(1) & uint(TDEFL_LZ_DICT_SIZE_MASK)]))) ? 1 : 0) ? 1 : 0)
            var c2da_fresh8 : size_t = unsafe(reinterpret<size_t>(0))
            if (unsafe(reinterpret<size_t>(src_buf_left)) < unsafe(reinterpret<size_t>(uint(TDEFL_MAX_MATCH_LEN) - uint(d_9.m_lookahead_size)))) {
                c2da_fresh8 = src_buf_left
            } else {
                c2da_fresh8 = unsafe(reinterpret<size_t>(uint(TDEFL_MAX_MATCH_LEN) - uint(d_9.m_lookahead_size)))
            }
            num_bytes_to_process = uint(c2da_fresh8)
            var c2da_fresh9 : uint8 const? = null
            if (uint64(pSrc) != uint64(0)) {
                c2da_fresh9 = unsafe(pSrc + uint(num_bytes_to_process))
            } else {
                c2da_fresh9 = null
            }
            pSrc_end = c2da_fresh9
            src_buf_left = unsafe(reinterpret<size_t>(src_buf_left - unsafe(reinterpret<size_t>(num_bytes_to_process))))
            d_9.m_lookahead_size = uint(d_9.m_lookahead_size + num_bytes_to_process)
            while (true) {
                if (!unsafe(unsafe(reinterpret<uint64>(pSrc)) != unsafe(reinterpret<uint64>(pSrc_end)))) {
                    if (false) {
                    }
                }
                pSrc = unsafe(pSrc + uint64(1))
                c = *pSrc
                unsafe(unsafe(addr(d_9.m_dict[0]))[uint(dst_pos)]) = uint8(c)
                if (uint(dst_pos) < uint(int(TDEFL_MAX_MATCH_LEN) - 1)) {
                    unsafe(unsafe(addr(d_9.m_dict[0]))[uint(TDEFL_LZ_DICT_SIZE) + uint(dst_pos)]) = uint8(c)
                }
                hash = uint((((uint(uint(hash) == uint(0)) << uint(uint(int(TDEFL_LZ_HASH_SHIFT) == int(0))) ^ uint(c)) & uint(int(TDEFL_LZ_HASH_SIZE) - 1)) ? 1 : 0) ? 1 : 0)
                unsafe(unsafe(addr(d_9.m_next[0]))[uint(ins_pos) & uint(TDEFL_LZ_DICT_SIZE_MASK)]) = uint16(unsafe(unsafe(addr(d_9.m_hash[0]))[uint(hash)]))
                unsafe(unsafe(addr(d_9.m_hash[0]))[uint(hash)]) = uint16(uint16(ins_pos))
                dst_pos = uint(uint(dst_pos) + uint(1) & uint(TDEFL_LZ_DICT_SIZE_MASK))
                ins_pos = ins_pos + uint(1)
                ins_pos
            }
        } else {
            while (true) {
                if (uint64(src_buf_left) != uint64(0) && uint(d_9.m_lookahead_size) < uint(TDEFL_MAX_MATCH_LEN)) {
                    if (false) {
                    }
                }
                pSrc = unsafe(pSrc + uint64(1))
                c_0 = *pSrc
                dst_pos_0 = uint(d_9.m_lookahead_pos) + uint(d_9.m_lookahead_size) & uint(TDEFL_LZ_DICT_SIZE_MASK)
                src_buf_left = src_buf_left - uint64(1)
                src_buf_left
                unsafe(unsafe(addr(d_9.m_dict[0]))[uint(dst_pos_0)]) = uint8(c_0)
                if (uint(dst_pos_0) < uint(int(TDEFL_MAX_MATCH_LEN) - 1)) {
                    unsafe(unsafe(addr(d_9.m_dict[0]))[uint(TDEFL_LZ_DICT_SIZE) + uint(dst_pos_0)]) = uint8(c_0)
                }
                d_9.m_lookahead_size = d_9.m_lookahead_size + uint(1)
                if (uint(d_9.m_lookahead_size) + uint(d_9.m_dict_size) >= uint(TDEFL_MIN_MATCH_LEN)) {
                    ins_pos_0 = uint(d_9.m_lookahead_pos) + (uint(d_9.m_lookahead_size) - uint(1) - uint(2))
                    hash_0 = uint((((int(unsafe(unsafe(addr(d_9.m_dict[0]) == int(0))[uint(ins_pos_0) & uint(TDEFL_LZ_DICT_SIZE_MASK)])) << int(TDEFL_LZ_HASH_SHIFT) * 2 ^ int(unsafe(unsafe(addr(d_9.m_dict[0]))[uint(ins_pos_0) + uint(1) & uint(TDEFL_LZ_DICT_SIZE_MASK)])) << int(TDEFL_LZ_HASH_SHIFT) ^ int(c_0)) & int(TDEFL_LZ_HASH_SIZE) - 1) ? 1 : 0) ? 1 : 0)
                    unsafe(unsafe(addr(d_9.m_next[0]))[uint(ins_pos_0) & uint(TDEFL_LZ_DICT_SIZE_MASK)]) = uint16(unsafe(unsafe(addr(d_9.m_hash[0]))[uint(hash_0)]))
                    unsafe(unsafe(addr(d_9.m_hash[0]))[uint(hash_0)]) = uint16(uint16(ins_pos_0))
                }
            }
        }
        var c2da_fresh10 : uint = uint(0)
        if (uint(TDEFL_LZ_DICT_SIZE) - uint(d_9.m_lookahead_size) < uint(d_9.m_dict_size)) {
            c2da_fresh10 = uint(TDEFL_LZ_DICT_SIZE) - uint(d_9.m_lookahead_size)
        } else {
            c2da_fresh10 = d_9.m_dict_size
        }
        d_9.m_dict_size = uint(c2da_fresh10)
        if (uint64((uint(flush_2) == uint64(0)) ? 1 : 0) == uint64(0) && uint(d_9.m_lookahead_size) < uint(TDEFL_MAX_MATCH_LEN)) {
            if (false) {
            }
            if (false) {
            }
        } else {
            len_to_move = uint(((uint(1) == uint(0)) ? 1 : 0) ? 1 : 0)
            cur_match_dist = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
            var c2da_fresh11 : uint = uint(0)
            if (uint64(d_9.m_saved_match_len) != uint64(0)) {
                c2da_fresh11 = d_9.m_saved_match_len
            } else {
                c2da_fresh11 = uint(int(TDEFL_MIN_MATCH_LEN) - 1)
            }
            cur_match_len = uint(c2da_fresh11)
            cur_pos = uint(uint(d_9.m_lookahead_pos) & uint(TDEFL_LZ_DICT_SIZE_MASK))
            if (uint64(uint(d_9.m_flags) & uint(int(TDEFL_RLE_MATCHES) | int(TDEFL_FORCE_ALL_RAW_BLOCKS))) != uint64(0)) {
                if (uint64(d_9.m_dict_size) != uint64(0) && uint64(uint(d_9.m_flags) & uint(TDEFL_FORCE_ALL_RAW_BLOCKS)) == uint64(0)) {
                    c_1 = unsafe(unsafe(addr(d_9.m_dict[0]))[uint(cur_pos) - uint(1) & uint(TDEFL_LZ_DICT_SIZE_MASK)])
                    cur_match_len = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
                    while (true) {
                        if (!(uint(cur_match_len) < uint(d_9.m_lookahead_size))) {
                            if (false) {
                            }
                        }
                        if (int((unsafe(unsafe(addr(d_9.m_dict[0]) == int(0))[uint(cur_pos) + uint(cur_match_len)])) ? 1 : 0) != int(c_1)) {
                            if (false) {
                            }
                            if (false) {
                            }
                        } else {
                            cur_match_len = cur_match_len + uint(1)
                            cur_match_len
                        }
                    }
                    if (uint(cur_match_len) < uint(TDEFL_MIN_MATCH_LEN)) {
                        cur_match_len = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
                    } else {
                        cur_match_dist = uint(((uint(1) == uint(0)) ? 1 : 0) ? 1 : 0)
                    }
                }
            } else {
                tdefl_find_match(d_9, d_9.m_lookahead_pos, d_9.m_dict_size, d_9.m_lookahead_size, unsafe(addr(cur_match_dist)), unsafe(addr(cur_match_len)))
            }
            if (uint(cur_match_len) == uint(TDEFL_MIN_MATCH_LEN) && uint(cur_match_dist) >= 0x8 * 0x400 || uint(cur_pos) == uint(cur_match_dist) || uint64(uint(d_9.m_flags) & uint(TDEFL_FILTER_MATCHES)) != uint64(0) && uint(cur_match_len) <= uint(5)) {
                cur_match_len = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
                cur_match_dist = cur_match_len
            }
            if (uint64(d_9.m_saved_match_len) != uint64(0)) {
                if (uint(cur_match_len) > uint(d_9.m_saved_match_len)) {
                    tdefl_record_literal(d_9, uint8(d_9.m_saved_lit))
                    if (uint(cur_match_len) >= uint(128)) {
                        tdefl_record_match(d_9, cur_match_len, cur_match_dist)
                        d_9.m_saved_match_len = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
                        len_to_move = uint(cur_match_len)
                    } else {
                        d_9.m_saved_lit = uint(((uint(unsafe(unsafe(addr(d_9.m_dict[0]) == uint(0))[uint(cur_pos)]))) ? 1 : 0) ? 1 : 0)
                        d_9.m_saved_match_dist = uint(cur_match_dist)
                        d_9.m_saved_match_len = uint(cur_match_len)
                    }
                } else {
                    tdefl_record_match(d_9, d_9.m_saved_match_len, d_9.m_saved_match_dist)
                    len_to_move = uint(uint(d_9.m_saved_match_len) - uint(1))
                    d_9.m_saved_match_len = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
                }
            } elif (uint64(cur_match_dist) == uint64(0)) {
                var c2da_fresh12 : uint64 = uint64(0)
                if (uint64(cur_pos) < uint64((4 - int((int(uint64(1) == uint64(0))) ? 1 : 0)) ? 1 : 0)) {
                    c2da_fresh12 = uint64(cur_pos)
                } else {
                    c2da_fresh12 = 4 - int((int(uint64(1) == uint64(0))) ? 1 : 0)
                }
                tdefl_record_literal(d_9, unsafe(unsafe(addr(d_9.m_dict[0]))[uint(c2da_fresh12)]))
            } elif (uint64(d_9.m_greedy_parsing) != uint64(0) || uint64(uint(d_9.m_flags) & uint(TDEFL_RLE_MATCHES)) != uint64(0) || uint(cur_match_len) >= uint(128)) {
                tdefl_record_match(d_9, cur_match_len, cur_match_dist)
                len_to_move = uint(cur_match_len)
            } else {
                var c2da_fresh13 : uint64 = uint64(0)
                if (uint64(cur_pos) < uint64((4 - int((int(uint64(1) == uint64(0))) ? 1 : 0)) ? 1 : 0)) {
                    c2da_fresh13 = uint64(cur_pos)
                } else {
                    c2da_fresh13 = 4 - int((int(uint64(1) == uint64(0))) ? 1 : 0)
                }
                d_9.m_saved_lit = uint(((uint(unsafe(unsafe(addr(d_9.m_dict[0]) == uint(0))[uint(c2da_fresh13)]))) ? 1 : 0) ? 1 : 0)
                d_9.m_saved_match_dist = uint(cur_match_dist)
                d_9.m_saved_match_len = uint(cur_match_len)
            }
            d_9.m_lookahead_pos = uint(d_9.m_lookahead_pos + len_to_move)
            {
                if (uint(d_9.m_lookahead_size) >= uint(len_to_move)) {
                } else {
                    c2da___assert_fail(null, null, uint(0), null)
                }
            }
            d_9.m_lookahead_size = uint(d_9.m_lookahead_size - len_to_move)
            d_9.m_dict_size = uint(((c2da_min_int(int(uint(d_9.m_dict_size) + uint(len_to_move)), int(uint(TDEFL_LZ_DICT_SIZE) == uint(0)))) ? 1 : 0) ? 1 : 0)
            if (unsafe(unsafe(reinterpret<uint64>(d_9.m_pLZ_code_buf)) > unsafe(reinterpret<uint64>(unsafe(addr(unsafe(unsafe(addr(d_9.m_lz_code_buf[0]))[int(TDEFL_LZ_CODE_BUF_SIZE) - 8])))))) || uint(d_9.m_total_lz_bytes) > uint(31 * 1024) && uint(((uint(unsafe(d_9.m_pLZ_code_buf - unsafe(addr(d_9.m_lz_code_buf[0]) == uint(0)))) * uint(115)) ? 1 : 0) ? 1 : 0) >> uint(((uint(7) == uint(0)) ? 1 : 0) ? 1 : 0) >= uint(d_9.m_total_lz_bytes) || uint64(uint(d_9.m_flags) & uint(TDEFL_FORCE_ALL_RAW_BLOCKS)) != uint64(0)) {
                d_9.m_pSrc = unsafe(unsafe(reinterpret<uint8 const?>(pSrc)))
                d_9.m_src_buf_left = unsafe(reinterpret<size_t>(src_buf_left))
                n_2 = tdefl_flush_block(d_9, 0)
                if (uint64((int(n_2) == int(0)) ? 1 : 0) != uint64(0)) {
                    var c2da_fresh14 : int = int(0)
                    if (int(n_2) < 0) {
                        c2da_fresh14 = 0
                    } else {
                        c2da_fresh14 = 1
                    }
                    return c2da_fresh14
                }
            }
        }
    }
    d_9.m_pSrc = unsafe(unsafe(reinterpret<uint8 const?>(pSrc)))
    d_9.m_src_buf_left = unsafe(reinterpret<size_t>(src_buf_left))
    return 1
}
[export]
def tdefl_record_match(var d_10 : tdefl_compressor?; var match_len_0 : uint; var match_dist_0 : uint) {
    var s0 : uint = uint(0)
    var s1_0 : uint = uint(0)
    {
        if (uint(match_len_0) >= uint(TDEFL_MIN_MATCH_LEN) && uint(match_dist_0) >= uint(1) && uint(match_dist_0) <= uint(TDEFL_LZ_DICT_SIZE)) {
        } else {
            c2da___assert_fail(null, null, uint(0), null)
        }
    }
    d_10.m_total_lz_bytes = uint(d_10.m_total_lz_bytes + match_len_0)
    unsafe(unsafe(unsafe(reinterpret<uint8?>(d_10.m_pLZ_code_buf)))[0]) = uint8(uint8(uint(match_len_0) - uint(TDEFL_MIN_MATCH_LEN)))
    match_dist_0 = uint(match_dist_0 - uint(1))
    unsafe(unsafe(unsafe(reinterpret<uint8?>(d_10.m_pLZ_code_buf)))[1]) = uint8(uint8(uint(match_dist_0) & uint(255)))
    unsafe(unsafe(unsafe(reinterpret<uint8?>(d_10.m_pLZ_code_buf)))[2]) = uint8(uint8(uint(((uint(match_dist_0) == uint(0)) ? 1 : 0) ? 1 : 0) >> uint(((uint(8) == uint(0)) ? 1 : 0) ? 1 : 0)))
    d_10.m_pLZ_code_buf = unsafe(unsafe(reinterpret<uint8?>(unsafe(d_10.m_pLZ_code_buf + 3))))
    *d_10.m_pLZ_flags = uint8(uint8(uint(((uint(int(*d_10.m_pLZ_flags) == int(0)) >> uint(1)) ? 1 : 0) ? 1 : 0) | uint(128)))
    d_10.m_num_flags_left = d_10.m_num_flags_left - uint(1)
    if (uint64((uint(d_10.m_num_flags_left) == uint64(0)) ? 1 : 0) == uint64(0)) {
        d_10.m_num_flags_left = uint(((uint(8) == uint(0)) ? 1 : 0) ? 1 : 0)
        d_10.m_pLZ_code_buf = unsafe(d_10.m_pLZ_code_buf + uint64(1))
        d_10.m_pLZ_flags = unsafe(unsafe(reinterpret<uint8?>(d_10.m_pLZ_code_buf)))
    }
    s0 = uint(((uint(unsafe(unsafe(addr(s_tdefl_small_dist_sym[0]) == uint(0))[uint(match_dist_0) & uint(511)]))) ? 1 : 0) ? 1 : 0)
    s1_0 = uint(((uint(unsafe(unsafe(addr(s_tdefl_large_dist_sym[0]) == uint(0))[uint(uint(match_dist_0) == uint(0)) >> uint(uint(8) == uint(0)) & uint(127)]))) ? 1 : 0) ? 1 : 0)
    unsafe(unsafe(addr(unsafe(unsafe(addr(d_10.m_huff_count[0]))[1])[0]))[uint(c2da_fresh15)]) = unsafe(unsafe(addr(unsafe(unsafe(addr(d_10.m_huff_count[0]))[1])[0]))[uint(c2da_fresh15)]) + uint16(1)
    unsafe(unsafe(addr(unsafe(unsafe(addr(d_10.m_huff_count[0]))[1])[0]))[uint(c2da_fresh15)])
    unsafe(unsafe(addr(unsafe(unsafe(addr(d_10.m_huff_count[0]))[0])[0]))[uint(unsafe(unsafe(addr(s_tdefl_len_sym[0]))[uint(match_len_0) - uint(TDEFL_MIN_MATCH_LEN)]))]) = unsafe(unsafe(addr(unsafe(unsafe(addr(d_10.m_huff_count[0]))[0])[0]))[uint(unsafe(unsafe(addr(s_tdefl_len_sym[0]))[uint(match_len_0) - uint(TDEFL_MIN_MATCH_LEN)]))]) + uint16(1)
    unsafe(unsafe(addr(unsafe(unsafe(addr(d_10.m_huff_count[0]))[0])[0]))[uint(unsafe(unsafe(addr(s_tdefl_len_sym[0]))[uint(match_len_0) - uint(TDEFL_MIN_MATCH_LEN)]))])
    return
}
[export]
def tdefl_record_literal(var d_11 : tdefl_compressor?; var lit_0 : uint8) {
    d_11.m_total_lz_bytes = d_11.m_total_lz_bytes + uint(1)
    d_11.m_total_lz_bytes
    d_11.m_pLZ_code_buf = unsafe(d_11.m_pLZ_code_buf + uint64(1))
    *d_11.m_pLZ_code_buf = uint8(lit_0)
    *d_11.m_pLZ_flags = uint8(uint8(uint(((int(*d_11.m_pLZ_flags) == int(0)) ? 1 : 0) ? 1 : 0) >> uint(1)))
    d_11.m_num_flags_left = d_11.m_num_flags_left - uint(1)
    if (uint64((uint(d_11.m_num_flags_left) == uint64(0)) ? 1 : 0) == uint64(0)) {
        d_11.m_num_flags_left = uint(((uint(8) == uint(0)) ? 1 : 0) ? 1 : 0)
        d_11.m_pLZ_code_buf = unsafe(d_11.m_pLZ_code_buf + uint64(1))
        d_11.m_pLZ_flags = unsafe(unsafe(reinterpret<uint8?>(d_11.m_pLZ_code_buf)))
    }
    unsafe(unsafe(addr(unsafe(unsafe(addr(d_11.m_huff_count[0]))[0])[0]))[uint(lit_0)]) = unsafe(unsafe(addr(unsafe(unsafe(addr(d_11.m_huff_count[0]))[0])[0]))[uint(lit_0)]) + uint16(1)
    unsafe(unsafe(addr(unsafe(unsafe(addr(d_11.m_huff_count[0]))[0])[0]))[uint(lit_0)])
    return
}
[export]
def tdefl_find_match(var d_12 : tdefl_compressor?; var lookahead_pos : uint; var max_dist : uint; var max_match_len : uint; var pMatch_dist : uint?; var pMatch_len : uint?) {
    var dist : uint = uint(0)
    var pos : uint = uint(0)
    var match_len_1 : uint = uint(0)
    var probe_pos : uint = uint(0)
    var next_probe_pos : uint = uint(0)
    var probe_len : uint = uint(0)
    var num_probes_left : uint = uint(0)
    var s : uint8 const? = null
    var p_1 : uint8 const? = null
    var q : uint8 const? = null
    var c0 : uint8 = uint8(0)
    var c1 : uint8 = uint8(0)
    pos = uint(lookahead_pos) & uint(TDEFL_LZ_DICT_SIZE_MASK)
    match_len_1 = *pMatch_len
    probe_pos = pos
    num_probes_left = unsafe(unsafe(addr(d_12.m_max_probes[0]))[uint(((uint(match_len_1) >= uint(32)) ? 1 : 0) ? 1 : 0)])
    s = unsafe(unsafe(addr(d_12.m_dict[0])) + uint(pos))
    c0 = unsafe(unsafe(addr(d_12.m_dict[0]))[uint(pos) + uint(match_len_1)])
    c1 = unsafe(unsafe(addr(d_12.m_dict[0]))[uint(pos) + (uint(match_len_1) - uint(1))])
    {
        if (uint(max_match_len) <= uint(TDEFL_MAX_MATCH_LEN)) {
        } else {
            c2da___assert_fail(null, null, uint(0), null)
        }
    }
    if (uint(max_match_len) <= uint(match_len_1)) {
        return
    } else {
        if (false) {
        }
    }
}
[export]
def mz_deflateBound(var pStream_4 : mz_streamp; var source_len : uint64) : uint64 {
    pStream_4
    return c2da_max_int(int(uint64(128) + uint64(source_len) * uint64(110) / uint64(100)), int(uint64(128) + uint64(source_len) + (uint64(source_len) / uint64(31 * 1024) + uint64(1)) * uint64(5)))
}
[export]
def mz_compress(var pDest : uint8?; var pDest_len : uint64?; var pSource : uint8 const?; var source_len_0 : uint64) : int {
    return mz_compress2(pDest, pDest_len, pSource, source_len_0, MZ_DEFAULT_COMPRESSION)
}
[export]
def mz_compress2(var pDest_0 : uint8?; var pDest_len_0 : uint64?; var pSource_0 : uint8 const?; var source_len_1 : uint64; var level_2 : int) : int {
    var status : int = int(0)
    var stream : mz_stream_s = mz_stream_s()
    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(stream))))), 0, uint64(4))
    if ((uint64(source_len_1) | uint64(*pDest_len_0)) > uint64(0xffffffff)) {
        return MZ_PARAM_ERROR
    } else {
        stream.next_in = unsafe(unsafe(reinterpret<uint8 const?>(pSource_0)))
        stream.avail_in = uint(((uint(source_len_1) == uint(0)) ? 1 : 0) ? 1 : 0)
        stream.next_out = unsafe(unsafe(reinterpret<uint8?>(pDest_0)))
        stream.avail_out = uint(((uint(*pDest_len_0) == uint(0)) ? 1 : 0) ? 1 : 0)
        status = mz_deflateInit(unsafe(addr(stream)), level_2)
        if (int(status) != int(MZ_OK)) {
            return status
        } else {
            status = mz_deflate(unsafe(addr(stream)), MZ_FINISH)
            if (int(status) != int(MZ_STREAM_END)) {
                mz_deflateEnd(unsafe(addr(stream)))
                var c2da_fresh16 : int = int(0)
                if (int(status) == int(MZ_OK)) {
                    c2da_fresh16 = MZ_BUF_ERROR
                } else {
                    c2da_fresh16 = status
                }
                return c2da_fresh16
            } else {
                *pDest_len_0 = uint64(stream.total_out)
                return mz_deflateEnd(unsafe(addr(stream)))
            }
        }
    }
}
[export]
def mz_compressBound(var source_len_2 : uint64) : uint64 {
    return mz_deflateBound(null, source_len_2)
}
[export]
def mz_inflateInit(var pStream_5 : mz_streamp) : int {
    return mz_inflateInit2(pStream_5, 15)
}
[export]
def mz_inflateInit2(var pStream_6 : mz_streamp; var window_bits_1 : int) : int {
    var pDecomp : inflate_state? = null
    if (pStream_6 == null) {
        return MZ_STREAM_ERROR
    } elif (int(window_bits_1) != 15 && -window_bits_1 != 15) {
        return MZ_PARAM_ERROR
    } else {
        pStream_6.data_type = 0
        pStream_6.adler = uint64((uint64(0) == uint64(0)) ? 1 : 0)
        pStream_6.msg = null
        pStream_6.total_in = uint64((uint64(0) == uint64(0)) ? 1 : 0)
        pStream_6.total_out = uint64((uint64(0) == uint64(0)) ? 1 : 0)
        pStream_6.reserved = uint64((uint64(0) == uint64(0)) ? 1 : 0)
        if (pStream_6.zalloc == null) {
            pStream_6.zalloc = miniz_def_alloc_func
        }
        if (pStream_6.zfree == null) {
            pStream_6.zfree = miniz_def_free_func
        }
        pDecomp = unsafe(unsafe(reinterpret<inflate_state?>(pStream_6.zalloc(pStream_6.opaque, unsafe(reinterpret<size_t>(1)), 4))))
        if (pDecomp == null) {
            return MZ_MEM_ERROR
        } else {
            pStream_6.state = unsafe(unsafe(reinterpret<mz_internal_state?>(pDecomp)))
            while (true) {
                unsafe(addr(pDecomp.m_decomp)).m_state = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
                if (!(uint64(0) != uint64(0))) {
                    if (false) {
                    }
                }
            }
            pDecomp.m_dict_ofs = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
            pDecomp.m_dict_avail = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
            pDecomp.m_last_status = unsafe(reinterpret<tinfl_status>(TINFL_STATUS_NEEDS_MORE_INPUT))
            pDecomp.m_first_call = uint(((uint(1) == uint(0)) ? 1 : 0) ? 1 : 0)
            pDecomp.m_has_flushed = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
            pDecomp.m_window_bits = window_bits_1
            return MZ_OK
        }
    }
}
[export]
def mz_inflateReset(var pStream_7 : mz_streamp) : int {
    var pDecomp_0 : inflate_state? = null
    if (pStream_7 == null) {
        return MZ_STREAM_ERROR
    } else {
        pStream_7.data_type = 0
        pStream_7.adler = uint64((uint64(0) == uint64(0)) ? 1 : 0)
        pStream_7.msg = null
        pStream_7.total_in = uint64((uint64(0) == uint64(0)) ? 1 : 0)
        pStream_7.total_out = uint64((uint64(0) == uint64(0)) ? 1 : 0)
        pStream_7.reserved = uint64((uint64(0) == uint64(0)) ? 1 : 0)
        pDecomp_0 = unsafe(unsafe(reinterpret<inflate_state?>(pStream_7.state)))
        while (true) {
            unsafe(addr(pDecomp_0.m_decomp)).m_state = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
            if (!(uint64(0) != uint64(0))) {
                if (false) {
                }
            }
        }
        pDecomp_0.m_dict_ofs = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
        pDecomp_0.m_dict_avail = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
        pDecomp_0.m_last_status = unsafe(reinterpret<tinfl_status>(TINFL_STATUS_NEEDS_MORE_INPUT))
        pDecomp_0.m_first_call = uint(((uint(1) == uint(0)) ? 1 : 0) ? 1 : 0)
        pDecomp_0.m_has_flushed = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
        return MZ_OK
    }
}
[export]
def mz_inflate(var pStream_8 : mz_streamp; var flush_3 : int) : int {
    var pState : inflate_state? = null
    var n_3 : uint = uint(0)
    var first_call : uint = uint(0)
    var decomp_flags : uint = uint(0)
    var in_bytes_0 : size_t = unsafe(reinterpret<size_t>(0))
    var out_bytes_0 : size_t = unsafe(reinterpret<size_t>(0))
    var orig_avail_in : size_t = unsafe(reinterpret<size_t>(0))
    var status_0 : tinfl_status = unsafe(reinterpret<tinfl_status>(0))
    decomp_flags = uint(TINFL_FLAG_COMPUTE_ADLER32)
    if (pStream_8 == null || pStream_8.state == null) {
        return MZ_STREAM_ERROR
    } else {
        if (int(flush_3) == int(MZ_PARTIAL_FLUSH)) {
            flush_3 = MZ_SYNC_FLUSH
        }
        if (uint64(flush_3) != uint64(0) && int(flush_3) != int(MZ_SYNC_FLUSH) && int(flush_3) != int(MZ_FINISH)) {
            return MZ_STREAM_ERROR
        } else {
            pState = unsafe(unsafe(reinterpret<inflate_state?>(pStream_8.state)))
            if (int(pState.m_window_bits) > 0) {
                decomp_flags = uint(decomp_flags | uint(TINFL_FLAG_PARSE_ZLIB_HEADER))
            }
            orig_avail_in = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(pStream_8.avail_in))))
            first_call = uint(pState.m_first_call)
            pState.m_first_call = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
            if (int(pState.m_last_status) < 0) {
                return MZ_DATA_ERROR
            } elif (uint64(pState.m_has_flushed) != uint64(0) && int(flush_3) != int(MZ_FINISH)) {
                return MZ_STREAM_ERROR
            } else {
                pState.m_has_flushed = uint(((pState.m_has_flushed | uint(int(flush_3) == int(MZ_FINISH))) ? 1 : 0) ? 1 : 0)
                if (int(flush_3) == int(MZ_FINISH) && uint64(first_call) != uint64(0)) {
                    decomp_flags = uint(decomp_flags | uint(TINFL_FLAG_USING_NON_WRAPPING_OUTPUT_BUF))
                    in_bytes_0 = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(pStream_8.avail_in))))
                    out_bytes_0 = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(pStream_8.avail_out))))
                    status_0 = tinfl_decompress(unsafe(addr(pState.m_decomp)), pStream_8.next_in, unsafe(addr(in_bytes_0)), pStream_8.next_out, pStream_8.next_out, unsafe(addr(out_bytes_0)), decomp_flags)
                    pState.m_last_status = status_0
                    pStream_8.next_in = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(pStream_8.next_in + uint(in_bytes_0)))))
                    pStream_8.avail_in = uint(pStream_8.avail_in - uint(in_bytes_0))
                    pStream_8.total_in = uint64((pStream_8.total_in + uint64(uint(in_bytes_0) == uint(0))) ? 1 : 0)
                    pStream_8.adler = uint64((uint64(unsafe(addr(pState.m_decomp) == uint64(0)).m_check_adler32)) ? 1 : 0)
                    pStream_8.next_out = unsafe(unsafe(reinterpret<uint8?>(unsafe(pStream_8.next_out + uint(out_bytes_0)))))
                    pStream_8.avail_out = uint(pStream_8.avail_out - uint(out_bytes_0))
                    pStream_8.total_out = uint64((pStream_8.total_out + uint64(uint(out_bytes_0) == uint(0))) ? 1 : 0)
                    if (int(status_0) < 0) {
                        return MZ_DATA_ERROR
                    } elif (int(status_0) != int(TINFL_STATUS_DONE)) {
                        pState.m_last_status = unsafe(reinterpret<tinfl_status>(TINFL_STATUS_FAILED))
                        return MZ_BUF_ERROR
                    } else {
                        return MZ_STREAM_END
                    }
                } else {
                    if (int(flush_3) != int(MZ_FINISH)) {
                        decomp_flags = uint(decomp_flags | uint(TINFL_FLAG_HAS_MORE_INPUT))
                    }
                    if (uint64(pState.m_dict_avail) != uint64(0)) {
                        var c2da_fresh17 : uint = uint(0)
                        if (uint(pState.m_dict_avail) < uint(pStream_8.avail_out)) {
                            c2da_fresh17 = pState.m_dict_avail
                        } else {
                            c2da_fresh17 = pStream_8.avail_out
                        }
                        n_3 = uint(c2da_fresh17)
                        memcpy(unsafe(unsafe(reinterpret<uint64>(pStream_8.next_out))), unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(pState.m_dict[0])) + uint(pState.m_dict_ofs))))), uint64((uint64(n_3) == uint64(0)) ? 1 : 0))
                        pStream_8.next_out = unsafe(unsafe(reinterpret<uint8?>(unsafe(pStream_8.next_out + n_3))))
                        pStream_8.avail_out = uint(pStream_8.avail_out - n_3)
                        pStream_8.total_out = uint64(pStream_8.total_out + uint64(n_3))
                        pState.m_dict_avail = uint(pState.m_dict_avail - n_3)
                        pState.m_dict_ofs = uint(uint(pState.m_dict_ofs) + uint(n_3) & uint(32768 - 1))
                        var c2da_fresh18 : int = int(0)
                        if (int(pState.m_last_status) == int(TINFL_STATUS_DONE) && uint64(pState.m_dict_avail) == uint64(0)) {
                            c2da_fresh18 = MZ_STREAM_END
                        } else {
                            c2da_fresh18 = MZ_OK
                        }
                        return c2da_fresh18
                    } else {
                        if (false) {
                        }
                    }
                }
            }
        }
    }
}
[export]
def tinfl_decompress(var r : tinfl_decompressor_tag?; var pIn_buf_next : uint8 const?; var pIn_buf_size_0 : size_t?; var pOut_buf_start : uint8?; var pOut_buf_next : uint8?; var pOut_buf_size_0 : size_t?; decomp_flags_0 : uint const) : tinfl_status {
    var s_length_base : array<uint16> const = [uint16(3), uint16(4), uint16(5), uint16(6), uint16(7), uint16(8), uint16(9), uint16(10), uint16(11), uint16(13), uint16(15), uint16(17), uint16(19), uint16(23), uint16(27), uint16(31), uint16(35), uint16(43), uint16(51), uint16(59), uint16(67), uint16(83), uint16(99), uint16(115), uint16(131), uint16(163), uint16(195), uint16(227), uint16(258), uint16(0), uint16(0)]
    var s_length_extra : array<uint8> const = [uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(1), uint8(1), uint8(1), uint8(2), uint8(2), uint8(2), uint8(2), uint8(3), uint8(3), uint8(3), uint8(3), uint8(4), uint8(4), uint8(4), uint8(4), uint8(5), uint8(5), uint8(5), uint8(5), uint8(0), uint8(0), uint8(0)]
    var s_dist_base : array<uint16> const = [uint16(1), uint16(2), uint16(3), uint16(4), uint16(5), uint16(7), uint16(9), uint16(13), uint16(17), uint16(25), uint16(33), uint16(49), uint16(65), uint16(97), uint16(129), uint16(193), uint16(257), uint16(385), uint16(513), uint16(769), uint16(1025), uint16(1537), uint16(2049), uint16(3073), uint16(4097), uint16(6145), uint16(8193), uint16(12289), uint16(16385), uint16(24577), uint16(0), uint16(0)]
    var s_dist_extra : array<uint8> const = [uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(1), uint8(2), uint8(2), uint8(3), uint8(3), uint8(4), uint8(4), uint8(5), uint8(5), uint8(6), uint8(6), uint8(7), uint8(7), uint8(8), uint8(8), uint8(9), uint8(9), uint8(10), uint8(10), uint8(11), uint8(11), uint8(12), uint8(12), uint8(13), uint8(13)]
    var s_length_dezigzag : array<uint8> const = [uint8(16), uint8(17), uint8(18), uint8(0), uint8(8), uint8(7), uint8(9), uint8(6), uint8(10), uint8(5), uint8(11), uint8(4), uint8(12), uint8(3), uint8(13), uint8(2), uint8(14), uint8(1), uint8(15)]
    var s_min_table_sizes : array<uint16> const = [uint16(257), uint16(1), uint16(4)]
    var pTrees : array<int16?> = []
    var pCode_sizes : array<uint8?> = []
    var status_1 : tinfl_status = unsafe(reinterpret<tinfl_status>(0))
    var num_bits : uint = uint(0)
    var dist_0 : uint = uint(0)
    var counter : uint = uint(0)
    var num_extra : uint = uint(0)
    var bit_buf : uint64 = uint64(0)
    var pIn_buf_cur : uint8 const? = null
    var pIn_buf_end : uint8 const? = null
    var pOut_buf_cur : uint8? = null
    var pOut_buf_end : uint8? = null
    var out_buf_size_mask : size_t = unsafe(reinterpret<size_t>(0))
    var dist_from_out_buf_start : size_t = unsafe(reinterpret<size_t>(0))
    var c_2 : uint = uint(0)
    var c_3 : uint = uint(0)
    var c_4 : uint = uint(0)
    var c_5 : uint = uint(0)
    var n_4 : size_t = unsafe(reinterpret<size_t>(0))
    var p_2 : uint8? = null
    var i_13 : uint = uint(0)
    status_1 = unsafe(reinterpret<tinfl_status>(TINFL_STATUS_FAILED))
    pIn_buf_cur = pIn_buf_next
    pIn_buf_end = unsafe(pIn_buf_next + unsafe(reinterpret<size_t>(*pIn_buf_size_0)))
    pOut_buf_cur = pOut_buf_next
    var c2da_fresh22 : uint8? = null
    if (uint64(pOut_buf_next) != uint64(0)) {
        c2da_fresh22 = unsafe(pOut_buf_next + unsafe(reinterpret<size_t>(*pOut_buf_size_0)))
    } else {
        c2da_fresh22 = null
    }
    pOut_buf_end = c2da_fresh22
    var c2da_fresh23 : size_t = unsafe(reinterpret<size_t>(0))
    if (uint64(uint(decomp_flags_0) & uint(TINFL_FLAG_USING_NON_WRAPPING_OUTPUT_BUF)) != uint64(0)) {
        c2da_fresh23 = unsafe(reinterpret<size_t>(-1))
    } else {
        c2da_fresh23 = unsafe(reinterpret<size_t>(unsafe(pOut_buf_next - pOut_buf_start))) + (unsafe(reinterpret<size_t>(*pOut_buf_size_0) - unsafe(reinterpret<size_t>(1))))
    }
    out_buf_size_mask = c2da_fresh23
    if (uint64((unsafe(reinterpret<size_t>(out_buf_size_mask) == uint64(0)) + unsafe(reinterpret<size_t>(1)) & unsafe(reinterpret<size_t>(out_buf_size_mask))) ? 1 : 0) != uint64(0) || unsafe(unsafe(reinterpret<uint64>(pOut_buf_next)) < unsafe(reinterpret<uint64>(pOut_buf_start)))) {
        *pOut_buf_size_0 = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
        *pIn_buf_size_0 = *pOut_buf_size_0
        return unsafe(reinterpret<tinfl_status>(TINFL_STATUS_BAD_PARAM))
    } else {
        unsafe(unsafe(addr(pTrees[0]))[0]) = unsafe(unsafe(reinterpret<int16?>(unsafe(addr(r.m_tree_0[0])))))
        unsafe(unsafe(addr(pTrees[0]))[1]) = unsafe(unsafe(reinterpret<int16?>(unsafe(addr(r.m_tree_1[0])))))
        unsafe(unsafe(addr(pTrees[0]))[2]) = unsafe(unsafe(reinterpret<int16?>(unsafe(addr(r.m_tree_2[0])))))
        unsafe(unsafe(addr(pCode_sizes[0]))[0]) = unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(r.m_code_size_0[0])))))
        unsafe(unsafe(addr(pCode_sizes[0]))[1]) = unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(r.m_code_size_1[0])))))
        unsafe(unsafe(addr(pCode_sizes[0]))[2]) = unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(r.m_code_size_2[0])))))
        num_bits = uint(r.m_num_bits)
        bit_buf = uint64(r.m_bit_buf)
        dist_0 = uint(r.m_dist)
        counter = uint(r.m_counter)
        num_extra = uint(r.m_num_extra)
        dist_from_out_buf_start = unsafe(reinterpret<size_t>(r.m_dist_from_out_buf_start))
        r.m_state
        r.m_zhdr1 = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
        r.m_zhdr0 = r.m_zhdr1
        num_extra = r.m_zhdr0
        counter = num_extra
        dist_0 = counter
        num_bits = dist_0
        bit_buf = uint64((uint64(num_bits) == uint64(0)) ? 1 : 0)
        r.m_check_adler32 = uint(((uint(1) == uint(0)) ? 1 : 0) ? 1 : 0)
        r.m_z_adler32 = r.m_check_adler32
        while (true) {
            if (uint64(uint(decomp_flags_0) & uint(TINFL_FLAG_PARSE_ZLIB_HEADER)) != uint64(0)) {
                while (true) {
                    if (unsafe(unsafe(reinterpret<uint64>(pIn_buf_cur)) >= unsafe(reinterpret<uint64>(pIn_buf_end)))) {
                        var c2da_fresh24 : int = int(0)
                        if (uint64(uint(decomp_flags_0) & uint(TINFL_FLAG_HAS_MORE_INPUT)) != uint64(0)) {
                            c2da_fresh24 = TINFL_STATUS_NEEDS_MORE_INPUT
                        } else {
                            c2da_fresh24 = TINFL_STATUS_FAILED_CANNOT_MAKE_PROGRESS
                        }
                        status_1 = unsafe(reinterpret<tinfl_status>(c2da_fresh24))
                        r.m_state = uint(((uint(1) == uint(0)) ? 1 : 0) ? 1 : 0)
                        goto _common_exit
                    } else {
                        pIn_buf_cur = unsafe(pIn_buf_cur + uint64(1))
                        r.m_zhdr0 = uint(((uint(*pIn_buf_cur) == uint(0)) ? 1 : 0) ? 1 : 0)
                        if (uint64(0) != uint64(0)) {
                            continue
                        }
                        while (true) {
                            if (unsafe(unsafe(reinterpret<uint64>(pIn_buf_cur)) >= unsafe(reinterpret<uint64>(pIn_buf_end)))) {
                                var c2da_fresh25 : int = int(0)
                                if (uint64(uint(decomp_flags_0) & uint(TINFL_FLAG_HAS_MORE_INPUT)) != uint64(0)) {
                                    c2da_fresh25 = TINFL_STATUS_NEEDS_MORE_INPUT
                                } else {
                                    c2da_fresh25 = TINFL_STATUS_FAILED_CANNOT_MAKE_PROGRESS
                                }
                                status_1 = unsafe(reinterpret<tinfl_status>(c2da_fresh25))
                                r.m_state = uint(((uint(2) == uint(0)) ? 1 : 0) ? 1 : 0)
                                goto _common_exit
                            } else {
                                pIn_buf_cur = unsafe(pIn_buf_cur + uint64(1))
                                r.m_zhdr1 = uint(((uint(*pIn_buf_cur) == uint(0)) ? 1 : 0) ? 1 : 0)
                                if (uint64(0) != uint64(0)) {
                                    continue
                                }
                                counter = uint(((uint(uint64((uint(r.m_zhdr0) * uint(256) + uint(r.m_zhdr1)) % uint(31)) != uint64(0) || uint64(uint(r.m_zhdr1) & uint(32)) != uint64(0) || (uint(r.m_zhdr0) & uint(15)) != uint(8))) ? 1 : 0) ? 1 : 0)
                                if (uint64(uint(decomp_flags_0) & uint(TINFL_FLAG_USING_NON_WRAPPING_OUTPUT_BUF)) == uint64(0)) {
                                    counter = uint(((counter | uint(0x1 << 0x8 + (uint(uint(r.m_zhdr0) == uint(0)) >> uint(uint(4) == uint(0))) > 0x8000 || unsafe(reinterpret<size_t>(out_buf_size_mask)) + unsafe(reinterpret<size_t>(1)) < unsafe(reinterpret<size_t>(1)) << unsafe(reinterpret<size_t>(0x8 + (uint(uint(r.m_zhdr0) == uint(0)) >> uint(uint(4) == uint(0))))))) ? 1 : 0) ? 1 : 0)
                                }
                                if (uint64(counter) != uint64(0)) {
                                    if (false) {
                                    }
                                } else {
                                    if (false) {
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        while (true) {
            while (true) {
                if (uint(num_bits) < uint(3)) {
                    while (true) {
                        while (true) {
                            if (unsafe(unsafe(reinterpret<uint64>(pIn_buf_cur)) >= unsafe(reinterpret<uint64>(pIn_buf_end)))) {
                                var c2da_fresh26 : int = int(0)
                                if (uint64(uint(decomp_flags_0) & uint(TINFL_FLAG_HAS_MORE_INPUT)) != uint64(0)) {
                                    c2da_fresh26 = TINFL_STATUS_NEEDS_MORE_INPUT
                                } else {
                                    c2da_fresh26 = TINFL_STATUS_FAILED_CANNOT_MAKE_PROGRESS
                                }
                                status_1 = unsafe(reinterpret<tinfl_status>(c2da_fresh26))
                                r.m_state = uint(((uint(3) == uint(0)) ? 1 : 0) ? 1 : 0)
                                goto _common_exit
                            } else {
                                pIn_buf_cur = unsafe(pIn_buf_cur + uint64(1))
                                c_2 = uint(((uint(*pIn_buf_cur) == uint(0)) ? 1 : 0) ? 1 : 0)
                                if (uint64(0) != uint64(0)) {
                                    continue
                                }
                                bit_buf = uint64((bit_buf | uint64(uint64(c_2) == uint64(0)) << uint64(uint64(uint(num_bits) == uint64(0)))) ? 1 : 0)
                                num_bits = uint(num_bits + uint(8))
                                if (uint(num_bits) < uint(3)) {
                                    if (false) {
                                    }
                                }
                                if (false) {
                                }
                            }
                        }
                    }
                }
            }
            r.m_final = uint(uint(uint64(bit_buf) & uint64((uint(1) << uint(3)) - 1)))
            bit_buf = uint64(uint(bit_buf) >> uint(3))
            num_bits = uint(num_bits - uint(3))
            if (uint64(0) != uint64(0)) {
                continue
            }
            r.m_type = uint(((uint(uint(r.m_final) == uint(0)) >> uint(uint(1) == uint(0))) ? 1 : 0) ? 1 : 0)
            if (uint64((uint(r.m_type) == uint64(0)) ? 1 : 0) == uint64(0)) {
                while (true) {
                    if (uint(num_bits) < (uint(num_bits) & uint(7))) {
                        while (true) {
                            while (true) {
                                if (unsafe(unsafe(reinterpret<uint64>(pIn_buf_cur)) >= unsafe(reinterpret<uint64>(pIn_buf_end)))) {
                                    if (false) {
                                    }
                                }
                                pIn_buf_cur = unsafe(pIn_buf_cur + uint64(1))
                                c_3 = uint(((uint(*pIn_buf_cur) == uint(0)) ? 1 : 0) ? 1 : 0)
                                if (!(uint64(0) != uint64(0))) {
                                    if (false) {
                                    }
                                }
                            }
                            bit_buf = uint64((bit_buf | uint64(uint64(c_3) == uint64(0)) << uint64(uint64(uint(num_bits) == uint64(0)))) ? 1 : 0)
                            num_bits = uint(num_bits + uint(8))
                            if (uint(num_bits) < (uint(num_bits) & uint(7))) {
                                if (false) {
                                }
                            }
                        }
                    }
                    bit_buf = uint64(bit_buf >> (uint(num_bits) & uint(7)))
                    num_bits = uint(num_bits - (uint(num_bits) & uint(7)))
                    if (!(uint64(0) != uint64(0))) {
                        if (false) {
                        }
                    }
                }
                var c2da_fresh27 : int = int(0)
                if (uint64(uint(decomp_flags_0) & uint(TINFL_FLAG_HAS_MORE_INPUT)) != uint64(0)) {
                    c2da_fresh27 = TINFL_STATUS_NEEDS_MORE_INPUT
                } else {
                    c2da_fresh27 = TINFL_STATUS_FAILED_CANNOT_MAKE_PROGRESS
                }
                status_1 = unsafe(reinterpret<tinfl_status>(c2da_fresh27))
                r.m_state = uint(((uint(5) == uint(0)) ? 1 : 0) ? 1 : 0)
                goto _common_exit
            } elif (uint(r.m_type) == uint(3)) {
                if (false) {
                }
            } else {
                if (uint(r.m_type) == uint(1)) {
                    if (false) {
                    }
                }
                p_2 = unsafe(addr(r.m_code_size_0[0]))
                unsafe(unsafe(addr(r.m_table_sizes[0]))[0]) = uint(((uint(288) == uint(0)) ? 1 : 0) ? 1 : 0)
                unsafe(unsafe(addr(r.m_table_sizes[0]))[1]) = uint(((uint(32) == uint(0)) ? 1 : 0) ? 1 : 0)
                memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(r.m_code_size_1[0]))))), 5, uint64((uint64(32) == uint64(0)) ? 1 : 0))
                if (false) {
                }
            }
        }
    }
}
[export]
def tinfl_clear_tree(var r_0 : tinfl_decompressor_tag?) {
    if (uint64((uint(r_0.m_type) == uint64(0)) ? 1 : 0) == uint64(0)) {
        memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(r_0.m_tree_0[0]))))), 0, uint64(4))
    } elif (uint(r_0.m_type) == uint(1)) {
        memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(r_0.m_tree_1[0]))))), 0, uint64(4))
    } else {
        memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(r_0.m_tree_2[0]))))), 0, uint64(4))
    }
    return
}
[export]
def mz_inflateEnd(var pStream_9 : mz_streamp) : int {
    if (pStream_9 == null) {
        return MZ_STREAM_ERROR
    } else {
        if (pStream_9.state != null) {
            pStream_9.zfree(pStream_9.opaque, unsafe(unsafe(reinterpret<uint64>(pStream_9.state))))
            pStream_9.state = null
        }
        return MZ_OK
    }
}
[export]
def mz_uncompress(var pDest_1 : uint8?; var pDest_len_1 : uint64?; var pSource_1 : uint8 const?; var source_len_3 : uint64) : int {
    return mz_uncompress2(pDest_1, pDest_len_1, pSource_1, unsafe(addr(source_len_3)))
}
[export]
def mz_uncompress2(var pDest_2 : uint8?; var pDest_len_2 : uint64?; var pSource_2 : uint8 const?; var pSource_len : uint64?) : int {
    var stream_0 : mz_stream_s = mz_stream_s()
    var status_2 : int = int(0)
    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(stream_0))))), 0, uint64(4))
    if ((uint64(*pSource_len) | uint64(*pDest_len_2)) > uint64(0xffffffff)) {
        return MZ_PARAM_ERROR
    } else {
        stream_0.next_in = unsafe(unsafe(reinterpret<uint8 const?>(pSource_2)))
        stream_0.avail_in = uint(((uint(*pSource_len) == uint(0)) ? 1 : 0) ? 1 : 0)
        stream_0.next_out = unsafe(unsafe(reinterpret<uint8?>(pDest_2)))
        stream_0.avail_out = uint(((uint(*pDest_len_2) == uint(0)) ? 1 : 0) ? 1 : 0)
        status_2 = mz_inflateInit(unsafe(addr(stream_0)))
        if (int(status_2) != int(MZ_OK)) {
            return status_2
        } else {
            status_2 = mz_inflate(unsafe(addr(stream_0)), MZ_FINISH)
            *pSource_len = uint64(uint64(*pSource_len) - uint64(stream_0.avail_in))
            if (int(status_2) != int(MZ_STREAM_END)) {
                mz_inflateEnd(unsafe(addr(stream_0)))
                var c2da_fresh45 : int = int(0)
                if (int(status_2) == int(MZ_BUF_ERROR) && uint64(stream_0.avail_in) == uint64(0)) {
                    c2da_fresh45 = MZ_DATA_ERROR
                } else {
                    c2da_fresh45 = status_2
                }
                return c2da_fresh45
            } else {
                *pDest_len_2 = uint64(stream_0.total_out)
                return mz_inflateEnd(unsafe(addr(stream_0)))
            }
        }
    }
}
[export]
def mz_error(var err : int) : int8 const? {
    var s_error_descs : array<Unnamed> = [Unnamed(m_err = MZ_OK, m_pDesc = unsafe(addr(""[0]))), Unnamed(m_err = MZ_STREAM_END, m_pDesc = unsafe(addr(uint8(115)))), Unnamed(m_err = MZ_NEED_DICT, m_pDesc = unsafe(addr(uint8(110)))), Unnamed(m_err = MZ_ERRNO, m_pDesc = unsafe(addr(uint8(102)))), Unnamed(m_err = MZ_STREAM_ERROR, m_pDesc = unsafe(addr(uint8(115)))), Unnamed(m_err = MZ_DATA_ERROR, m_pDesc = unsafe(addr(uint8(100)))), Unnamed(m_err = MZ_MEM_ERROR, m_pDesc = unsafe(addr(uint8(111)))), Unnamed(m_err = MZ_BUF_ERROR, m_pDesc = unsafe(addr(uint8(98)))), Unnamed(m_err = MZ_VERSION_ERROR, m_pDesc = unsafe(addr(uint8(118)))), Unnamed(m_err = MZ_PARAM_ERROR, m_pDesc = unsafe(addr(uint8(112))))]
    var i_16 : uint = uint(0)
    if (false) {
    }
}
[export]
def deflateInit(var pStream_10 : mz_streamp; var level_3 : int) : int {
    return mz_deflateInit(pStream_10, level_3)
}
[export]
def deflateInit2(var pStream_11 : mz_streamp; var level_4 : int; var method_0 : int; var window_bits_2 : int; var mem_level_0 : int; var strategy_1 : int) : int {
    return mz_deflateInit2(pStream_11, level_4, method_0, window_bits_2, mem_level_0, strategy_1)
}
[export]
def deflateReset(var pStream_12 : mz_streamp) : int {
    return mz_deflateReset(pStream_12)
}
[export]
def deflate(var pStream_13 : mz_streamp; var flush_4 : int) : int {
    return mz_deflate(pStream_13, flush_4)
}
[export]
def deflateEnd(var pStream_14 : mz_streamp) : int {
    return mz_deflateEnd(pStream_14)
}
[export]
def deflateBound(var pStream_15 : mz_streamp; var source_len_4 : uint64) : uint64 {
    return mz_deflateBound(pStream_15, source_len_4)
}
[export]
def compress(var pDest_3 : uint8?; var pDest_len_3 : uint64?; var pSource_3 : uint8 const?; var source_len_5 : uint64) : int {
    return mz_compress(pDest_3, pDest_len_3, pSource_3, source_len_5)
}
[export]
def compress2(var pDest_4 : uint8?; var pDest_len_4 : uint64?; var pSource_4 : uint8 const?; var source_len_6 : uint64; var level_5 : int) : int {
    return mz_compress2(pDest_4, pDest_len_4, pSource_4, source_len_6, level_5)
}
[export]
def compressBound(var source_len_7 : uint64) : uint64 {
    return mz_compressBound(source_len_7)
}
[export]
def inflateInit(var pStream_16 : mz_streamp) : int {
    return mz_inflateInit(pStream_16)
}
[export]
def inflateInit2(var pStream_17 : mz_streamp; var window_bits_3 : int) : int {
    return mz_inflateInit2(pStream_17, window_bits_3)
}
[export]
def inflateReset(var pStream_18 : mz_streamp) : int {
    return mz_inflateReset(pStream_18)
}
[export]
def inflate(var pStream_19 : mz_streamp; var flush_5 : int) : int {
    return mz_inflate(pStream_19, flush_5)
}
[export]
def inflateEnd(var pStream_20 : mz_streamp) : int {
    return mz_inflateEnd(pStream_20)
}
[export]
def uncompress(var pDest_5 : uint8?; var pDest_len_5 : uint64?; var pSource_5 : uint8 const?; var source_len_8 : uint64) : int {
    return mz_uncompress(pDest_5, pDest_len_5, pSource_5, source_len_8)
}
[export]
def uncompress2(var pDest_6 : uint8?; var pDest_len_6 : uint64?; var pSource_6 : uint8 const?; var pSource_len_0 : uint64?) : int {
    return mz_uncompress2(pDest_6, pDest_len_6, pSource_6, pSource_len_0)
}
[export]
def crc32_0(var crc_0 : uint64; var ptr_2 : uint8 const?; var buf_len_2 : size_t) : uint64 {
    return mz_crc32(crc_0, ptr_2, buf_len_2)
}
[export]
def adler32(var adler_0 : uint64; var ptr_3 : uint8 const?; var buf_len_3 : size_t) : uint64 {
    return mz_adler32(adler_0, ptr_3, buf_len_3)
}
[export]
def zError(var err_0 : int) : int8 const? {
    return unsafe(unsafe(reinterpret<int8 const?>(mz_error(err_0))))
}
[export]
def c2da___bswap_16(var c2da___bsx : uint16) : uint16 {
    return uint16(uint(((uint(int(c2da___bsx) == int(0)) >> uint(8)) ? 1 : 0) ? 1 : 0) & uint(255) | uint(((int(uint(int(c2da___bsx) == int(0)) & uint(255) << uint(8))) ? 1 : 0) ? 1 : 0))
}
[export]
def c2da___bswap_32(var c2da___bsx_0 : uint) : uint {
    return uint(((uint(uint(c2da___bsx_0) == uint(0)) & uint(0xff000000)) ? 1 : 0) ? 1 : 0) >> uint(((uint(24) == uint(0)) ? 1 : 0) ? 1 : 0) | uint(((uint(uint(c2da___bsx_0) == uint(0)) & uint(0xff0000)) ? 1 : 0) ? 1 : 0) >> uint(((uint(8) == uint(0)) ? 1 : 0) ? 1 : 0) | uint(((uint(uint(c2da___bsx_0) == uint(0)) & uint(0xff00)) ? 1 : 0) ? 1 : 0) << uint(((uint(8) == uint(0)) ? 1 : 0) ? 1 : 0) | uint(((uint(uint(c2da___bsx_0) == uint(0)) & uint(0xff)) ? 1 : 0) ? 1 : 0) << uint(((uint(24) == uint(0)) ? 1 : 0) ? 1 : 0)
}
[export]
def c2da___bswap_64(var c2da___bsx_1 : uint64) : uint64 {
    return uint64(uint64(c2da___bsx_1) & uint64(0xff00000000000000uL)) >> uint64((uint64(56) == uint64(0)) ? 1 : 0) | uint64(uint64(c2da___bsx_1) & uint64(0xff000000000000uL)) >> uint64((uint64(40) == uint64(0)) ? 1 : 0) | uint64(uint64(c2da___bsx_1) & uint64(0xff0000000000uL)) >> uint64((uint64(24) == uint64(0)) ? 1 : 0) | uint64(uint64(c2da___bsx_1) & uint64(0xff00000000uL)) >> uint64((uint64(8) == uint64(0)) ? 1 : 0) | uint64(uint64(c2da___bsx_1) & uint64(0xff000000)) << uint64((uint64(8) == uint64(0)) ? 1 : 0) | uint64(uint64(c2da___bsx_1) & uint64(0xff0000)) << uint64((uint64(24) == uint64(0)) ? 1 : 0) | uint64(uint64(c2da___bsx_1) & uint64(0xff00)) << uint64((uint64(40) == uint64(0)) ? 1 : 0) | uint64(uint64(c2da___bsx_1) & uint64(0xff)) << uint64((uint64(56) == uint64(0)) ? 1 : 0)
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
[export]
def miniz_def_realloc_func(var opaque_1 : uint64; var address_0 : uint64; var items_0 : size_t; var size_0 : size_t) : uint64 {
    size_0
    return unsafe(unsafe(reinterpret<uint64>(unsafe(realloc(address_0, unsafe(reinterpret<size_t>(items_0)) * unsafe(reinterpret<size_t>(size_0)))))))
}
[export]
def tdefl_compress_mem_to_heap(var pSrc_buf : uint64; var src_buf_len : size_t; var pOut_len : size_t?; var flags_1 : int) : uint64 {
    var out_buf : tdefl_output_buffer = tdefl_output_buffer()
    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(out_buf))))), 0, uint64(4))
    if (pOut_len == null) {
        return unsafe(unsafe(reinterpret<uint64>(uint64(0x0) == uint64(0))))
    } else {
        *pOut_len = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
        out_buf.m_expandable = 1
        if (uint64((tdefl_compress_mem_to_output(pSrc_buf, src_buf_len, tdefl_output_buffer_putter, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(out_buf) == uint64(0))))), flags_1)) ? 1 : 0) == uint64(0)) {
            return unsafe(unsafe(reinterpret<uint64>(uint64(0) == uint64(0))))
        } else {
            *pOut_len = unsafe(reinterpret<size_t>(out_buf.m_size))
            return unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(reinterpret<uint64>(out_buf.m_pBuf))))))
        }
    }
}
[export]
def tdefl_output_buffer_putter(var pBuf : uint64; var len_25 : int; var pUser : uint64) : int {
    var p_3 : tdefl_output_buffer? = null
    var new_size : size_t = unsafe(reinterpret<size_t>(0))
    var new_capacity : size_t = unsafe(reinterpret<size_t>(0))
    var pNew_buf : uint8? = null
    p_3 = pUser
    new_size = unsafe(reinterpret<size_t>(p_3.m_size)) + unsafe(reinterpret<size_t>(len_25))
    if (unsafe(reinterpret<size_t>(new_size)) > unsafe(reinterpret<size_t>(p_3.m_capacity))) {
        new_capacity = p_3.m_capacity
        if (uint64(p_3.m_expandable) == uint64(0)) {
            return 0
        } else {
            while (true) {
                new_capacity = unsafe(reinterpret<size_t>(c2da_max_int((int(unsafe(reinterpret<size_t>(0x80) == int(0))), int(unsafe(reinterpret<size_t>(new_capacity)) << unsafe(reinterpret<size_t>(0x1)))) ? 1 : 0)))
                if (!unsafe(reinterpret<size_t>(new_size)) > unsafe(reinterpret<size_t>(new_capacity))) {
                    if (false) {
                    }
                }
            }
            pNew_buf = unsafe(unsafe(reinterpret<uint8?>(unsafe(realloc(unsafe(unsafe(reinterpret<uint64>(p_3.m_pBuf))), new_capacity)))))
            if (pNew_buf == null) {
                return 0
            } else {
                p_3.m_pBuf = unsafe(unsafe(reinterpret<uint8?>(pNew_buf)))
                p_3.m_capacity = unsafe(reinterpret<size_t>(new_capacity))
            }
        }
    }
    memcpy(unsafe(unsafe(reinterpret<uint64>(unsafe(p_3.m_pBuf + unsafe(reinterpret<size_t>(p_3.m_size)))))), pBuf, uint64((uint64(len_25) == uint64(0)) ? 1 : 0))
    p_3.m_size = unsafe(reinterpret<size_t>(new_size))
    return 1
}
[export]
def tdefl_compress_mem_to_output(var pBuf_0 : uint64; var buf_len_4 : size_t; var pPut_buf_func_0 : tdefl_put_buf_func_ptr; var pPut_buf_user_0 : uint64; var flags_2 : int) : int {
    var pComp_0 : tdefl_compressor? = null
    var succeeded : int = int(0)
    if (uint64(buf_len_4) != uint64(0) && uint64(pBuf_0) == uint64(0) || pPut_buf_func_0 == null) {
        return 0
    } else {
        pComp_0 = unsafe(unsafe(reinterpret<tdefl_compressor?>(unsafe(malloc(uint64(4) == uint64(0))))))
        if (pComp_0 == null) {
            return 0
        } else {
            succeeded = int((int(tdefl_init(pComp_0, pPut_buf_func_0, pPut_buf_user_0, flags_2) == int(0)) == int(TDEFL_STATUS_OKAY)) ? 1 : 0)
            succeeded = int((uint64(succeeded) != uint64(0) && int(tdefl_compress_buffer(pComp_0, pBuf_0, buf_len_4, unsafe(reinterpret<tdefl_flush>(TDEFL_FINISH)))) == int(TDEFL_STATUS_DONE)) ? 1 : 0)
            unsafe(free(unsafe(unsafe(reinterpret<uint64>(pComp_0)))))
            return succeeded
        }
    }
}
[export]
def tdefl_compress_buffer(var d_13 : tdefl_compressor?; var pIn_buf_0 : uint64; var in_buf_size : size_t; var flush_6 : tdefl_flush) : tdefl_status {
    {
        if (d_13.m_pPut_buf_func != null) {
        } else {
            c2da___assert_fail(null, null, uint(0), null)
        }
    }
    return tdefl_compress(d_13, pIn_buf_0, unsafe(addr(in_buf_size)), uint64(0), null, flush_6)
}
[export]
def tdefl_compress_mem_to_mem(var pOut_buf_0 : uint64; var out_buf_len : size_t; var pSrc_buf_0 : uint64; var src_buf_len_0 : size_t; var flags_3 : int) : size_t {
    var out_buf_0 : tdefl_output_buffer = tdefl_output_buffer()
    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(out_buf_0))))), 0, uint64(4))
    if (uint64(pOut_buf_0) == uint64(0)) {
        return unsafe(reinterpret<size_t>(0))
    } else {
        out_buf_0.m_pBuf = unsafe(unsafe(reinterpret<uint8?>(pOut_buf_0)))
        out_buf_0.m_capacity = unsafe(reinterpret<size_t>(out_buf_len))
        if (uint64((tdefl_compress_mem_to_output(pSrc_buf_0, src_buf_len_0, tdefl_output_buffer_putter, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(out_buf_0) == uint64(0))))), flags_3)) ? 1 : 0) == uint64(0)) {
            return unsafe(reinterpret<size_t>(0))
        } else {
            return out_buf_0.m_size
        }
    }
}
[export]
def tdefl_write_image_to_png_file_in_memory_ex(var pImage : uint64; var w : int; var h : int; var num_chans : int; var pLen_out : size_t?; var level_6 : uint; var flip : int) : uint64 {
    var s_tdefl_png_num_probes : array<uint> const = [uint(0), uint(1), uint(6), uint(32), uint(16), uint(32), uint(128), uint(256), uint(512), uint(768), uint(1500)]
    var pComp_1 : tdefl_compressor? = null
    var out_buf_1 : tdefl_output_buffer = tdefl_output_buffer()
    var i_17 : int = int(0)
    var bpl : int = int(0)
    var y : int = int(0)
    var z_0 : int = int(0)
    var c_16 : uint = uint(0)
    pComp_1 = unsafe(malloc(uint64(4) == uint64(0)))
    bpl = int(w) * int(num_chans)
    *pLen_out = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
    if (pComp_1 == null) {
        return unsafe(unsafe(reinterpret<uint64>(uint64(0) == uint64(0))))
    } else {
        memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(out_buf_1))))), 0, uint64(4))
        out_buf_1.m_expandable = 1
        out_buf_1.m_capacity = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(57 + c2da_max_int(int(64), int((1 + int(bpl)) * int(h)))))))
        out_buf_1.m_pBuf = unsafe(unsafe(reinterpret<uint8?>(unsafe(malloc(out_buf_1.m_capacity)))))
        if (unsafe(unsafe(reinterpret<uint64>(null)) == unsafe(reinterpret<uint64>(out_buf_1.m_pBuf)))) {
            unsafe(free(unsafe(unsafe(reinterpret<uint64>(pComp_1)))))
            return unsafe(unsafe(reinterpret<uint64>(uint64(0) == uint64(0))))
        } else {
            if (false) {
            }
        }
    }
}
[export]
def tdefl_write_image_to_png_file_in_memory(var pImage_0 : uint64; var w_0 : int; var h_0 : int; var num_chans_0 : int; var pLen_out_0 : size_t?) : uint64 {
    return unsafe(unsafe(reinterpret<uint64>(tdefl_write_image_to_png_file_in_memory_ex(pImage_0, w_0, h_0, num_chans_0, pLen_out_0, uint(6), 0))))
}
[export]
def tdefl_get_prev_return_status(var d_14 : tdefl_compressor?) : tdefl_status {
    return d_14.m_prev_return_status
}
[export]
def tdefl_compressor_alloc() : tdefl_compressor? {
    return unsafe(unsafe(reinterpret<tdefl_compressor?>(unsafe(malloc(uint64(4) == uint64(0))))))
}
[export]
def tdefl_compressor_free(var pComp_2 : tdefl_compressor?) {
    unsafe(free(unsafe(unsafe(reinterpret<uint64>(pComp_2)))))
    return
}
[export]
def tinfl_decompress_mem_to_heap(var pSrc_buf_1 : uint64; var src_buf_len_1 : size_t; var pOut_len_0 : size_t?; var flags_4 : int) : uint64 {
    var decomp : tinfl_decompressor_tag = tinfl_decompressor_tag()
    var pBuf_1 : uint64 = uint64(0)
    var pNew_buf_0 : uint64 = uint64(0)
    var src_buf_ofs : size_t = unsafe(reinterpret<size_t>(0))
    var out_buf_capacity : size_t = unsafe(reinterpret<size_t>(0))
    pBuf_1 = uint64(0)
    src_buf_ofs = unsafe(reinterpret<size_t>(0))
    out_buf_capacity = unsafe(reinterpret<size_t>(0))
    *pOut_len_0 = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
    while (true) {
        unsafe(addr(decomp)).m_state = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
}
[export]
def tinfl_decompress_mem_to_mem(var pOut_buf_1 : uint64; var out_buf_len_0 : size_t; var pSrc_buf_2 : uint64; var src_buf_len_2 : size_t; var flags_5 : int) : size_t {
    var decomp_0 : tinfl_decompressor_tag = tinfl_decompressor_tag()
    var status_4 : tinfl_status = unsafe(reinterpret<tinfl_status>(0))
    while (true) {
        unsafe(addr(decomp_0)).m_state = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    status_4 = tinfl_decompress(unsafe(addr(decomp_0)), pSrc_buf_2, unsafe(addr(src_buf_len_2)), pOut_buf_1, pOut_buf_1, unsafe(addr(out_buf_len_0)), uint(int(flags_5) & ~TINFL_FLAG_HAS_MORE_INPUT | int(TINFL_FLAG_USING_NON_WRAPPING_OUTPUT_BUF)))
    var c2da_fresh49 : size_t = unsafe(reinterpret<size_t>(0))
    if (int(status_4) != int(TINFL_STATUS_DONE)) {
        c2da_fresh49 = unsafe(reinterpret<size_t>(-1))
    } else {
        c2da_fresh49 = out_buf_len_0
    }
    return c2da_fresh49
}
[export]
def tinfl_decompress_mem_to_callback(var pIn_buf_1 : uint64; var pIn_buf_size_1 : size_t?; var pPut_buf_func_1 : tinfl_put_buf_func_ptr; var pPut_buf_user_1 : uint64; var flags_6 : int) : int {
    var result_2 : int = int(0)
    var decomp_1 : tinfl_decompressor_tag = tinfl_decompressor_tag()
    var pDict : uint8? = null
    var in_buf_ofs : size_t = unsafe(reinterpret<size_t>(0))
    var dict_ofs : size_t = unsafe(reinterpret<size_t>(0))
    result_2 = 0
    pDict = unsafe(malloc(uint64(32768) == uint64(0)))
    in_buf_ofs = unsafe(reinterpret<size_t>(0))
    dict_ofs = unsafe(reinterpret<size_t>(0))
    if (pDict == null) {
        return TINFL_STATUS_FAILED
    } else {
        memset(unsafe(unsafe(reinterpret<uint64>(pDict))), 0, uint64((uint64(32768) == uint64(0)) ? 1 : 0))
        while (true) {
            unsafe(addr(decomp_1)).m_state = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
            if (!(uint64(0) != uint64(0))) {
                if (false) {
                }
            }
        }
    }
}
[export]
def tinfl_decompressor_alloc() : tinfl_decompressor_tag? {
    var pDecomp_1 : tinfl_decompressor_tag? = null
    pDecomp_1 = unsafe(malloc(uint64(4) == uint64(0)))
    if (pDecomp_1 != null) {
        while (true) {
            pDecomp_1.m_state = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
            if (!(uint64(0) != uint64(0))) {
                if (false) {
                }
            }
        }
    }
    return unsafe(unsafe(reinterpret<tinfl_decompressor_tag?>(pDecomp_1)))
}
[export]
def tinfl_decompressor_free(var pDecomp_2 : tinfl_decompressor_tag?) {
    unsafe(free(unsafe(unsafe(reinterpret<uint64>(pDecomp_2)))))
    return
}
[export]
def mz_zip_reader_init(var pZip : mz_zip_archive?; var size_1 : uint64; var flags_7 : uint) : int {
    if (pZip == null || pZip.m_pRead == null) {
        return mz_zip_set_error(pZip, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
    } elif (uint64((mz_zip_reader_init_internal(pZip, flags_7) == uint64(0)) ? 1 : 0) == uint64(0)) {
        return 0
    } else {
        pZip.m_zip_type = unsafe(reinterpret<mz_zip_type>(MZ_ZIP_TYPE_USER))
        pZip.m_archive_size = uint64(size_1)
        if (uint64((mz_zip_reader_read_central_dir(pZip, flags_7) == uint64(0)) ? 1 : 0) == uint64(0)) {
            mz_zip_reader_end_internal(pZip, 0)
            return 0
        } else {
            return 1
        }
    }
}
[export]
def mz_zip_reader_end_internal(var pZip_0 : mz_zip_archive?; var set_last_error : int) : int {
    var status_6 : int = int(0)
    var pState_0 : mz_zip_internal_state_tag? = null
    status_6 = 1
    if (pZip_0 == null) {
        return 0
    } elif (pZip_0.m_pState == null || pZip_0.m_pAlloc == null || pZip_0.m_pFree == null || uint(pZip_0.m_zip_mode) != uint(MZ_ZIP_MODE_READING)) {
        if (uint64(set_last_error) != uint64(0)) {
            pZip_0.m_last_error = unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER))
        }
        return 0
    } else {
        if (pZip_0.m_pState != null) {
            pState_0 = pZip_0.m_pState
            pZip_0.m_pState = null
            mz_zip_array_clear(pZip_0, unsafe(addr(pState_0.m_central_dir)))
            mz_zip_array_clear(pZip_0, unsafe(addr(pState_0.m_central_dir_offsets)))
            mz_zip_array_clear(pZip_0, unsafe(addr(pState_0.m_sorted_central_dir_offsets)))
            pZip_0.m_pFree(pZip_0.m_pAlloc_opaque, unsafe(unsafe(reinterpret<uint64>(pState_0))))
        }
        pZip_0.m_zip_mode = unsafe(reinterpret<mz_zip_mode>(MZ_ZIP_MODE_INVALID))
        return status_6
    }
}
[export]
def mz_zip_array_clear(var pZip_1 : mz_zip_archive?; var pArray : mz_zip_array?) {
    pZip_1.m_pFree(pZip_1.m_pAlloc_opaque, pArray.m_p)
    memset(unsafe(unsafe(reinterpret<uint64>(pArray))), 0, uint64(4))
    return
}
[export]
def mz_zip_reader_read_central_dir(var pZip_2 : mz_zip_archive?; var flags_8 : uint) : int {
    var cdir_size : uint = uint(0)
    var cdir_entries_on_this_disk : uint = uint(0)
    var num_this_disk : uint = uint(0)
    var cdir_disk_index : uint = uint(0)
    var cdir_ofs : uint64 = uint64(0)
    var eocd_ofs : uint64 = uint64(0)
    var archive_ofs : uint64 = uint64(0)
    var cur_file_ofs : int64 = int64(0)
    var p_4 : uint8 const? = null
    var buf_u32 : array<uint> = []
    var pBuf_2 : uint8? = null
    var sort_central_dir : int = int(0)
    var zip64_end_of_central_dir_locator_u32 : array<uint> = []
    var pZip64_locator : uint8? = null
    var zip64_end_of_central_dir_header_u32 : array<uint> = []
    var pZip64_end_of_central_dir : uint8? = null
    var zip64_end_of_central_dir_ofs : uint64 = uint64(0)
    var zip64_total_num_of_disks : uint = uint(0)
    var zip64_cdir_total_entries : uint64 = uint64(0)
    var zip64_cdir_total_entries_on_this_disk : uint64 = uint64(0)
    var zip64_size_of_end_of_central_dir_record : uint64 = uint64(0)
    var zip64_size_of_central_directory : uint64 = uint64(0)
    var i_18 : uint = uint(0)
    var n_5 : uint = uint(0)
    var total_header_size : uint = uint(0)
    var disk_index : uint = uint(0)
    var bit_flags : uint = uint(0)
    var filename_size : uint = uint(0)
    var ext_data_size : uint = uint(0)
    var comp_size : uint64 = uint64(0)
    var decomp_size : uint64 = uint64(0)
    var local_header_ofs : uint64 = uint64(0)
    var extra_size_remaining : uint = uint(0)
    var pExtra_data : uint8 const? = null
    var buf : uint64 = uint64(0)
    var field_id : uint = uint(0)
    var field_data_size : uint = uint(0)
    cdir_size = uint(0)
    cdir_entries_on_this_disk = uint(0)
    num_this_disk = uint(0)
    cdir_disk_index = uint(0)
    cdir_ofs = uint64(0)
    eocd_ofs = uint64(0)
    archive_ofs = uint64(0)
    cur_file_ofs = int64(0)
    pBuf_2 = unsafe(addr(buf_u32[0]))
    sort_central_dir = uint64(uint(flags_8) & uint(MZ_ZIP_FLAG_DO_NOT_SORT_CENTRAL_DIRECTORY)) == uint64(0)
    pZip64_locator = unsafe(addr(zip64_end_of_central_dir_locator_u32[0]))
    pZip64_end_of_central_dir = unsafe(addr(zip64_end_of_central_dir_header_u32[0]))
    zip64_end_of_central_dir_ofs = uint64(0)
    if (uint64(pZip_2.m_archive_size) < uint64(MZ_ZIP_END_OF_CENTRAL_DIR_HEADER_SIZE)) {
        return mz_zip_set_error(pZip_2, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_NOT_AN_ARCHIVE)))
    } elif (uint64(mz_zip_reader_locate_header_sig(pZip_2, uint(MZ_ZIP_END_OF_CENTRAL_DIR_HEADER_SIG), uint(MZ_ZIP_END_OF_CENTRAL_DIR_HEADER_SIZE), unsafe(addr(cur_file_ofs)))) == uint64(0)) {
        return mz_zip_set_error(pZip_2, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FAILED_FINDING_CENTRAL_DIR)))
    } else {
        eocd_ofs = uint64((uint64(cur_file_ofs) == uint64(0)) ? 1 : 0)
        if (pZip_2.m_pRead(pZip_2.m_pIO_opaque, uint64(cur_file_ofs), unsafe(unsafe(reinterpret<uint64>(pBuf_2))), unsafe(reinterpret<size_t>(MZ_ZIP_END_OF_CENTRAL_DIR_HEADER_SIZE))) != unsafe(reinterpret<size_t>(MZ_ZIP_END_OF_CENTRAL_DIR_HEADER_SIZE))) {
            return mz_zip_set_error(pZip_2, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_READ_FAILED)))
        } elif ((uint(((unsafe(unsafe(pBuf_2 + int(MZ_ZIP_ECDH_SIG_OFS) == uint(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pBuf_2 + int(MZ_ZIP_ECDH_SIG_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(pBuf_2 + int(MZ_ZIP_ECDH_SIG_OFS) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(pBuf_2 + int(MZ_ZIP_ECDH_SIG_OFS) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)) != uint(MZ_ZIP_END_OF_CENTRAL_DIR_HEADER_SIG)) {
            return mz_zip_set_error(pZip_2, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_NOT_AN_ARCHIVE)))
        } else {
            if (int64(cur_file_ofs) >= int64(int(MZ_ZIP64_END_OF_CENTRAL_DIR_LOCATOR_SIZE) + int(MZ_ZIP64_END_OF_CENTRAL_DIR_HEADER_SIZE))) {
                if (pZip_2.m_pRead(pZip_2.m_pIO_opaque, uint64(int64(cur_file_ofs) - int64(MZ_ZIP64_END_OF_CENTRAL_DIR_LOCATOR_SIZE)), unsafe(unsafe(reinterpret<uint64>(pZip64_locator))), unsafe(reinterpret<size_t>(MZ_ZIP64_END_OF_CENTRAL_DIR_LOCATOR_SIZE))) == unsafe(reinterpret<size_t>(MZ_ZIP64_END_OF_CENTRAL_DIR_LOCATOR_SIZE))) {
                    if ((uint(((unsafe(unsafe(pZip64_locator + int(MZ_ZIP64_ECDL_SIG_OFS) == uint(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pZip64_locator + int(MZ_ZIP64_ECDL_SIG_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(pZip64_locator + int(MZ_ZIP64_ECDL_SIG_OFS) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(pZip64_locator + int(MZ_ZIP64_ECDL_SIG_OFS) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)) == uint(MZ_ZIP64_END_OF_CENTRAL_DIR_LOCATOR_SIG)) {
                        pZip_2.m_pState.m_zip64 = 1
                    }
                }
            }
            if (uint64(pZip_2.m_pState.m_zip64) != uint64(0)) {
                if (int64(cur_file_ofs) < int64(int(MZ_ZIP64_END_OF_CENTRAL_DIR_LOCATOR_SIZE) + int(MZ_ZIP64_END_OF_CENTRAL_DIR_HEADER_SIZE))) {
                    return mz_zip_set_error(pZip_2, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_NOT_AN_ARCHIVE)))
                } else {
                    zip64_end_of_central_dir_ofs = uint64(uint64(int64(cur_file_ofs) - int64(MZ_ZIP64_END_OF_CENTRAL_DIR_LOCATOR_SIZE) - int64(MZ_ZIP64_END_OF_CENTRAL_DIR_HEADER_SIZE)))
                    if (uint64((mz_zip_reader_eocd64_valid(pZip_2, zip64_end_of_central_dir_ofs, pZip64_end_of_central_dir) == uint64(0)) ? 1 : 0) == uint64(0)) {
                        zip64_end_of_central_dir_ofs = uint64((uint64(uint(((unsafe(unsafe(pZip64_locator + int(MZ_ZIP64_ECDL_REL_OFS_TO_ZIP64_ECDR_OFS) == uint64(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pZip64_locator + int(MZ_ZIP64_ECDL_REL_OFS_TO_ZIP64_ECDR_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(pZip64_locator + int(MZ_ZIP64_ECDL_REL_OFS_TO_ZIP64_ECDR_OFS) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(pZip64_locator + int(MZ_ZIP64_ECDL_REL_OFS_TO_ZIP64_ECDR_OFS) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)) | uint64(uint64(uint(unsafe(unsafe(pZip64_locator + (int(MZ_ZIP64_ECDL_REL_OFS_TO_ZIP64_ECDR_OFS) + 4))[0])) | uint(uint(unsafe(unsafe(pZip64_locator + (int(MZ_ZIP64_ECDL_REL_OFS_TO_ZIP64_ECDR_OFS) + 4))[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(pZip64_locator + (int(MZ_ZIP64_ECDL_REL_OFS_TO_ZIP64_ECDR_OFS) + 4))[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(pZip64_locator + (int(MZ_ZIP64_ECDL_REL_OFS_TO_ZIP64_ECDR_OFS) + 4))[3]))) << uint(0x18))) << uint64(uint64(0x20) == uint64(0))) ? 1 : 0)
                        if (uint64(zip64_end_of_central_dir_ofs) > uint64(pZip_2.m_archive_size) - uint64(MZ_ZIP64_END_OF_CENTRAL_DIR_HEADER_SIZE)) {
                            return mz_zip_set_error(pZip_2, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_NOT_AN_ARCHIVE)))
                        } elif (uint64((mz_zip_reader_eocd64_valid(pZip_2, zip64_end_of_central_dir_ofs, pZip64_end_of_central_dir) == uint64(0)) ? 1 : 0) == uint64(0)) {
                            return mz_zip_set_error(pZip_2, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_NOT_AN_ARCHIVE)))
                        }
                    }
                }
            }
            pZip_2.m_total_files = uint(((uint(unsafe(unsafe(pBuf_2 + int(MZ_ZIP_ECDH_CDIR_TOTAL_ENTRIES_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(pBuf_2 + int(MZ_ZIP_ECDH_CDIR_TOTAL_ENTRIES_OFS) == uint(0))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
            cdir_entries_on_this_disk = uint(((uint(unsafe(unsafe(pBuf_2 + int(MZ_ZIP_ECDH_CDIR_NUM_ENTRIES_ON_DISK_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(pBuf_2 + int(MZ_ZIP_ECDH_CDIR_NUM_ENTRIES_ON_DISK_OFS) == uint(0))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
            num_this_disk = uint(((uint(unsafe(unsafe(pBuf_2 + int(MZ_ZIP_ECDH_NUM_THIS_DISK_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(pBuf_2 + int(MZ_ZIP_ECDH_NUM_THIS_DISK_OFS) == uint(0))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
            cdir_disk_index = uint(((uint(unsafe(unsafe(pBuf_2 + int(MZ_ZIP_ECDH_NUM_DISK_CDIR_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(pBuf_2 + int(MZ_ZIP_ECDH_NUM_DISK_CDIR_OFS) == uint(0))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
            cdir_size = uint(((uint(unsafe(unsafe(pBuf_2 + int(MZ_ZIP_ECDH_CDIR_SIZE_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(pBuf_2 + int(MZ_ZIP_ECDH_CDIR_SIZE_OFS) == uint(0))[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(pBuf_2 + int(MZ_ZIP_ECDH_CDIR_SIZE_OFS) == uint(0))[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(pBuf_2 + int(MZ_ZIP_ECDH_CDIR_SIZE_OFS) == uint(0))[3]))) << uint(0x18)) ? 1 : 0) ? 1 : 0)
            cdir_ofs = uint64((uint64(uint(((unsafe(unsafe(pBuf_2 + int(MZ_ZIP_ECDH_CDIR_OFS_OFS) == uint64(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pBuf_2 + int(MZ_ZIP_ECDH_CDIR_OFS_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(pBuf_2 + int(MZ_ZIP_ECDH_CDIR_OFS_OFS) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(pBuf_2 + int(MZ_ZIP_ECDH_CDIR_OFS_OFS) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18))) ? 1 : 0)
            if (uint64(pZip_2.m_pState.m_zip64) != uint64(0)) {
                zip64_total_num_of_disks = uint(unsafe(unsafe(pZip64_locator + int(MZ_ZIP64_ECDL_TOTAL_NUMBER_OF_DISKS_OFS))[0])) | uint(((uint(unsafe(unsafe(pZip64_locator + int(MZ_ZIP64_ECDL_TOTAL_NUMBER_OF_DISKS_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(pZip64_locator + int(MZ_ZIP64_ECDL_TOTAL_NUMBER_OF_DISKS_OFS) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(pZip64_locator + int(MZ_ZIP64_ECDL_TOTAL_NUMBER_OF_DISKS_OFS) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)
                zip64_cdir_total_entries = uint64((uint(((unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_CDIR_TOTAL_ENTRIES_OFS) == uint(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_CDIR_TOTAL_ENTRIES_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_CDIR_TOTAL_ENTRIES_OFS) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_CDIR_TOTAL_ENTRIES_OFS) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)) ? 1 : 0) | uint64(uint64(uint(unsafe(unsafe(pZip64_end_of_central_dir + (int(MZ_ZIP64_ECDH_CDIR_TOTAL_ENTRIES_OFS) + 4))[0])) | uint(uint(unsafe(unsafe(pZip64_end_of_central_dir + (int(MZ_ZIP64_ECDH_CDIR_TOTAL_ENTRIES_OFS) + 4))[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(pZip64_end_of_central_dir + (int(MZ_ZIP64_ECDH_CDIR_TOTAL_ENTRIES_OFS) + 4))[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(pZip64_end_of_central_dir + (int(MZ_ZIP64_ECDH_CDIR_TOTAL_ENTRIES_OFS) + 4))[3]))) << uint(0x18))) << uint64((uint64(0x20) == uint64(0)) ? 1 : 0)
                zip64_cdir_total_entries_on_this_disk = uint64((uint(((unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_CDIR_NUM_ENTRIES_ON_DISK_OFS) == uint(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_CDIR_NUM_ENTRIES_ON_DISK_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_CDIR_NUM_ENTRIES_ON_DISK_OFS) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_CDIR_NUM_ENTRIES_ON_DISK_OFS) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)) ? 1 : 0) | uint64(uint64(uint(unsafe(unsafe(pZip64_end_of_central_dir + (int(MZ_ZIP64_ECDH_CDIR_NUM_ENTRIES_ON_DISK_OFS) + 4))[0])) | uint(uint(unsafe(unsafe(pZip64_end_of_central_dir + (int(MZ_ZIP64_ECDH_CDIR_NUM_ENTRIES_ON_DISK_OFS) + 4))[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(pZip64_end_of_central_dir + (int(MZ_ZIP64_ECDH_CDIR_NUM_ENTRIES_ON_DISK_OFS) + 4))[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(pZip64_end_of_central_dir + (int(MZ_ZIP64_ECDH_CDIR_NUM_ENTRIES_ON_DISK_OFS) + 4))[3]))) << uint(0x18))) << uint64((uint64(0x20) == uint64(0)) ? 1 : 0)
                zip64_size_of_end_of_central_dir_record = uint64((uint(((unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_SIZE_OF_RECORD_OFS) == uint(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_SIZE_OF_RECORD_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_SIZE_OF_RECORD_OFS) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_SIZE_OF_RECORD_OFS) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)) ? 1 : 0) | uint64(uint64(uint(unsafe(unsafe(pZip64_end_of_central_dir + (int(MZ_ZIP64_ECDH_SIZE_OF_RECORD_OFS) + 4))[0])) | uint(uint(unsafe(unsafe(pZip64_end_of_central_dir + (int(MZ_ZIP64_ECDH_SIZE_OF_RECORD_OFS) + 4))[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(pZip64_end_of_central_dir + (int(MZ_ZIP64_ECDH_SIZE_OF_RECORD_OFS) + 4))[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(pZip64_end_of_central_dir + (int(MZ_ZIP64_ECDH_SIZE_OF_RECORD_OFS) + 4))[3]))) << uint(0x18))) << uint64((uint64(0x20) == uint64(0)) ? 1 : 0)
                zip64_size_of_central_directory = uint64((uint(((unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_CDIR_SIZE_OFS) == uint(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_CDIR_SIZE_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_CDIR_SIZE_OFS) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_CDIR_SIZE_OFS) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)) ? 1 : 0) | uint64(uint64(uint(unsafe(unsafe(pZip64_end_of_central_dir + (int(MZ_ZIP64_ECDH_CDIR_SIZE_OFS) + 4))[0])) | uint(uint(unsafe(unsafe(pZip64_end_of_central_dir + (int(MZ_ZIP64_ECDH_CDIR_SIZE_OFS) + 4))[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(pZip64_end_of_central_dir + (int(MZ_ZIP64_ECDH_CDIR_SIZE_OFS) + 4))[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(pZip64_end_of_central_dir + (int(MZ_ZIP64_ECDH_CDIR_SIZE_OFS) + 4))[3]))) << uint(0x18))) << uint64((uint64(0x20) == uint64(0)) ? 1 : 0)
                if (uint64(zip64_size_of_end_of_central_dir_record) < uint64(int(MZ_ZIP64_END_OF_CENTRAL_DIR_HEADER_SIZE) - 12)) {
                    return mz_zip_set_error(pZip_2, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
                } elif (uint(zip64_total_num_of_disks) != 0x1) {
                    return mz_zip_set_error(pZip_2, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNSUPPORTED_MULTIDISK)))
                } elif (uint64(zip64_cdir_total_entries) > uint64(0xffffffff)) {
                    return mz_zip_set_error(pZip_2, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_TOO_MANY_FILES)))
                } else {
                    pZip_2.m_total_files = uint(((uint(zip64_cdir_total_entries) == uint(0)) ? 1 : 0) ? 1 : 0)
                    if (uint64(zip64_cdir_total_entries_on_this_disk) > uint64(0xffffffff)) {
                        return mz_zip_set_error(pZip_2, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_TOO_MANY_FILES)))
                    } else {
                        cdir_entries_on_this_disk = uint(((uint(zip64_cdir_total_entries_on_this_disk) == uint(0)) ? 1 : 0) ? 1 : 0)
                        if (uint64(zip64_size_of_central_directory) > uint64(0xffffffff)) {
                            return mz_zip_set_error(pZip_2, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNSUPPORTED_CDIR_SIZE)))
                        } else {
                            cdir_size = uint(((uint(zip64_size_of_central_directory) == uint(0)) ? 1 : 0) ? 1 : 0)
                            num_this_disk = uint(((uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_NUM_THIS_DISK_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_NUM_THIS_DISK_OFS) == uint(0))[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_NUM_THIS_DISK_OFS) == uint(0))[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_NUM_THIS_DISK_OFS) == uint(0))[3]))) << uint(0x18)) ? 1 : 0) ? 1 : 0)
                            cdir_disk_index = uint(((uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_NUM_DISK_CDIR_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_NUM_DISK_CDIR_OFS) == uint(0))[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_NUM_DISK_CDIR_OFS) == uint(0))[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_NUM_DISK_CDIR_OFS) == uint(0))[3]))) << uint(0x18)) ? 1 : 0) ? 1 : 0)
                            cdir_ofs = uint64((uint64(uint(((unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_CDIR_OFS_OFS) == uint64(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_CDIR_OFS_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_CDIR_OFS_OFS) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(pZip64_end_of_central_dir + int(MZ_ZIP64_ECDH_CDIR_OFS_OFS) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)) | uint64(uint64(uint(unsafe(unsafe(pZip64_end_of_central_dir + (int(MZ_ZIP64_ECDH_CDIR_OFS_OFS) + 4))[0])) | uint(uint(unsafe(unsafe(pZip64_end_of_central_dir + (int(MZ_ZIP64_ECDH_CDIR_OFS_OFS) + 4))[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(pZip64_end_of_central_dir + (int(MZ_ZIP64_ECDH_CDIR_OFS_OFS) + 4))[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(pZip64_end_of_central_dir + (int(MZ_ZIP64_ECDH_CDIR_OFS_OFS) + 4))[3]))) << uint(0x18))) << uint64(uint64(0x20) == uint64(0))) ? 1 : 0)
                        }
                    }
                }
            }
            if (uint(pZip_2.m_total_files) != uint(cdir_entries_on_this_disk)) {
                return mz_zip_set_error(pZip_2, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNSUPPORTED_MULTIDISK)))
            } elif (uint64(uint(num_this_disk) | uint(cdir_disk_index)) != uint64(0) && uint(num_this_disk) != uint(1) || uint(cdir_disk_index) != uint(1)) {
                return mz_zip_set_error(pZip_2, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNSUPPORTED_MULTIDISK)))
            } elif (uint64(cdir_size) < uint64(pZip_2.m_total_files) * uint64(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE)) {
                return mz_zip_set_error(pZip_2, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
            } elif (uint64(cdir_ofs) + uint64(cdir_size) > uint64(pZip_2.m_archive_size)) {
                return mz_zip_set_error(pZip_2, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
            } elif (uint64(eocd_ofs) < uint64(cdir_ofs) + uint64(cdir_size)) {
                return mz_zip_set_error(pZip_2, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
            } else {
                archive_ofs = uint64(uint64(eocd_ofs) - (uint64(cdir_ofs) + uint64(cdir_size)))
                if (uint64(pZip_2.m_pState.m_zip64) != uint64(0)) {
                    if (uint64(archive_ofs) < uint64(int(MZ_ZIP64_END_OF_CENTRAL_DIR_HEADER_SIZE) + int(MZ_ZIP64_END_OF_CENTRAL_DIR_LOCATOR_SIZE))) {
                        return mz_zip_set_error(pZip_2, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
                    } else {
                        archive_ofs = uint64(archive_ofs - uint64(int(MZ_ZIP64_END_OF_CENTRAL_DIR_HEADER_SIZE) + int(MZ_ZIP64_END_OF_CENTRAL_DIR_LOCATOR_SIZE)))
                    }
                }
                if (uint(pZip_2.m_zip_type) == uint(MZ_ZIP_TYPE_FILE) || uint(pZip_2.m_zip_type) == uint(MZ_ZIP_TYPE_CFILE) || uint(pZip_2.m_zip_type) == uint(MZ_ZIP_TYPE_USER) && uint64((uint64(pZip_2.m_pState.m_file_archive_start_ofs) == uint64(0)) ? 1 : 0) == uint64(0)) {
                    pZip_2.m_pState.m_file_archive_start_ofs = uint64(archive_ofs)
                    pZip_2.m_archive_size = uint64(pZip_2.m_archive_size - archive_ofs)
                }
                pZip_2.m_central_directory_file_ofs = uint64(cdir_ofs)
                if (uint64(pZip_2.m_total_files) != uint64(0)) {
                    if (uint64((mz_zip_array_resize(pZip_2, unsafe(addr(pZip_2.m_pState.m_central_dir) == uint64(0)), unsafe(reinterpret<size_t>(cdir_size)), uint(0))) ? 1 : 0) == uint64(0) || uint64(mz_zip_array_resize(pZip_2, unsafe(addr(pZip_2.m_pState.m_central_dir_offsets)), unsafe(reinterpret<size_t>(pZip_2.m_total_files)), uint(0))) == uint64(0)) {
                        return mz_zip_set_error(pZip_2, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                    } else {
                        if (uint64(sort_central_dir) != uint64(0)) {
                            if (uint64((mz_zip_array_resize(pZip_2, unsafe(addr(pZip_2.m_pState.m_sorted_central_dir_offsets) == uint64(0)), unsafe(reinterpret<size_t>(pZip_2.m_total_files)), uint(0))) ? 1 : 0) == uint64(0)) {
                                return mz_zip_set_error(pZip_2, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                            }
                        }
                        if (pZip_2.m_pRead(pZip_2.m_pIO_opaque, cdir_ofs, pZip_2.m_pState.m_central_dir.m_p, unsafe(reinterpret<size_t>(cdir_size))) != unsafe(reinterpret<size_t>(cdir_size))) {
                            return mz_zip_set_error(pZip_2, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_READ_FAILED)))
                        } else {
                            p_4 = unsafe(unsafe(reinterpret<uint8 const?>(pZip_2.m_pState.m_central_dir.m_p)))
                            if (false) {
                            }
                        }
                    }
                } else {
                    if (uint64(sort_central_dir) != uint64(0)) {
                        mz_zip_reader_sort_central_dir_offsets_by_filename(pZip_2)
                    }
                    return 1
                }
            }
        }
    }
}
[export]
def mz_zip_reader_sort_central_dir_offsets_by_filename(var pZip_3 : mz_zip_archive?) {
    var pState_1 : mz_zip_internal_state_tag? = null
    var pCentral_dir_offsets : mz_zip_array const? = null
    var pCentral_dir : mz_zip_array const? = null
    var pIndices : uint? = null
    var start : uint = uint(0)
    var end : uint = uint(0)
    var size_2 : uint const = uint(0)
    pState_1 = pZip_3.m_pState
    pCentral_dir_offsets = unsafe(addr(pState_1.m_central_dir_offsets))
    pCentral_dir = unsafe(addr(pState_1.m_central_dir))
    size_2 = pZip_3.m_total_files
    if (uint(size_2) <= 0x1) {
        return
    } else {
        pIndices = unsafe(unsafe(reinterpret<uint?>(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<uint?>(unsafe(addr(pState_1.m_sorted_central_dir_offsets)).m_p)))[0]))))))
        start = uint(uint(uint(size_2) - 0x2) >> uint(0x1))
        if (false) {
        }
    }
}
[export]
def mz_zip_reader_filename_less(var pCentral_dir_array : mz_zip_array const?; var pCentral_dir_offsets_0 : mz_zip_array const?; var l_index : uint; var r_index : uint) : int {
    var pL : uint8 const? = null
    var pE : uint8 const? = null
    var pR : uint8 const? = null
    var l_len : uint = uint(0)
    var r_len : uint = uint(0)
    var l_1 : uint8 = uint8(0)
    var r_1 : uint8 = uint8(0)
    pL = unsafe(addr(unsafe(unsafe(unsafe(reinterpret<uint8?>(pCentral_dir_array.m_p)))[uint(unsafe(unsafe(unsafe(reinterpret<uint?>(pCentral_dir_offsets_0.m_p)))[uint(l_index)]))])))
    pR = unsafe(addr(unsafe(unsafe(unsafe(reinterpret<uint8?>(pCentral_dir_array.m_p)))[uint(unsafe(unsafe(unsafe(reinterpret<uint?>(pCentral_dir_offsets_0.m_p)))[uint(r_index)]))])))
    l_len = uint(unsafe(unsafe(pL + int(MZ_ZIP_CDH_FILENAME_LEN_OFS))[0])) | uint(((uint(unsafe(unsafe(pL + int(MZ_ZIP_CDH_FILENAME_LEN_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8)
    r_len = uint(unsafe(unsafe(pR + int(MZ_ZIP_CDH_FILENAME_LEN_OFS))[0])) | uint(((uint(unsafe(unsafe(pR + int(MZ_ZIP_CDH_FILENAME_LEN_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8)
    l_1 = uint8(0)
    r_1 = uint8(0)
    pL = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(pL + MZ_ZIP_CENTRAL_DIR_HEADER_SIZE))))
    pR = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(pR + MZ_ZIP_CENTRAL_DIR_HEADER_SIZE))))
    var c2da_fresh53 : uint = uint(0)
    if (uint(l_len) < uint(r_len)) {
        c2da_fresh53 = l_len
    } else {
        c2da_fresh53 = r_len
    }
    pE = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(pL + uint(c2da_fresh53)))))
    while (true) {
        if (!unsafe(unsafe(reinterpret<uint64>(pL)) < unsafe(reinterpret<uint64>(pE)))) {
            if (false) {
            }
        }
        var c2da_fresh54 : int = int(0)
        if (int(*pL) >= 65 && int(*pL) <= 90) {
            c2da_fresh54 = int(*pL) - 65 + 97
        } else {
            c2da_fresh54 = int(*pL)
        }
        l_1 = uint8(uint8(c2da_fresh54))
        var c2da_fresh55 : int = int(0)
        if (int(*pR) >= 65 && int(*pR) <= 90) {
            c2da_fresh55 = int(*pR) - 65 + 97
        } else {
            c2da_fresh55 = int(*pR)
        }
        r_1 = uint8(uint8(c2da_fresh55))
        if (int(l_1) != int(r_1)) {
            if (false) {
            }
            if (false) {
            }
        } else {
            pL = unsafe(pL + uint64(1))
            pL
            pR = unsafe(pR + uint64(1))
            pR
        }
    }
    var c2da_fresh56 : int = int(0)
    if (unsafe(unsafe(reinterpret<uint64>(pL)) == unsafe(reinterpret<uint64>(pE)))) {
        c2da_fresh56 = uint(l_len) < uint(r_len)
    } else {
        c2da_fresh56 = int(l_1) < int(r_1)
    }
    return c2da_fresh56
}
[export]
def mz_zip_set_error(var pZip_4 : mz_zip_archive?; var err_num : mz_zip_error) : int {
    if (pZip_4 != null) {
        pZip_4.m_last_error = err_num
    }
    return 0
}
[export]
def mz_zip_array_resize(var pZip_5 : mz_zip_archive?; var pArray_0 : mz_zip_array?; var new_size_0 : size_t; var growing : uint) : int {
    if (unsafe(reinterpret<size_t>(new_size_0)) > unsafe(reinterpret<size_t>(pArray_0.m_capacity))) {
        if (uint64((mz_zip_array_ensure_capacity(pZip_5, pArray_0, new_size_0, growing) == uint64(0)) ? 1 : 0) == uint64(0)) {
            return 0
        }
    }
    pArray_0.m_size = unsafe(reinterpret<size_t>(new_size_0))
    return 1
}
[export]
def mz_zip_array_ensure_capacity(var pZip_6 : mz_zip_archive?; var pArray_1 : mz_zip_array?; var min_new_capacity : size_t; var growing_0 : uint) : int {
    var pNew_p : uint64 = uint64(0)
    var new_capacity_0 : size_t = unsafe(reinterpret<size_t>(0))
    new_capacity_0 = min_new_capacity
    {
        if (uint64(pArray_1.m_element_size) != uint64(0)) {
        } else {
            c2da___assert_fail(null, null, uint(0), null)
        }
    }
    if (unsafe(reinterpret<size_t>(pArray_1.m_capacity)) >= unsafe(reinterpret<size_t>(min_new_capacity))) {
        return 1
    } else {
        if (uint64(growing_0) != uint64(0)) {
            var c2da_fresh57 : size_t = unsafe(reinterpret<size_t>(0))
            if (unsafe(reinterpret<size_t>(1)) > unsafe(reinterpret<size_t>(pArray_1.m_capacity))) {
                c2da_fresh57 = unsafe(reinterpret<size_t>(1))
            } else {
                c2da_fresh57 = pArray_1.m_capacity
            }
            new_capacity_0 = unsafe(reinterpret<size_t>(c2da_fresh57))
            while (true) {
                if (!unsafe(reinterpret<size_t>(new_capacity_0)) < unsafe(reinterpret<size_t>(min_new_capacity))) {
                    if (false) {
                    }
                }
                new_capacity_0 = unsafe(reinterpret<size_t>(new_capacity_0 * unsafe(reinterpret<size_t>(2))))
            }
        }
        pNew_p = pZip_6.m_pRealloc(pZip_6.m_pAlloc_opaque, pArray_1.m_p, unsafe(reinterpret<size_t>(pArray_1.m_element_size)), new_capacity_0)
        if (unsafe(unsafe(reinterpret<uint64>(uint64(0) == uint64(0))) == unsafe(reinterpret<uint64>(uint64(pNew_p) == uint64(0))))) {
            return 0
        } else {
            pArray_1.m_p = pNew_p
            pArray_1.m_capacity = unsafe(reinterpret<size_t>(new_capacity_0))
            return 1
        }
    }
}
[export]
def mz_zip_reader_eocd64_valid(var pZip_7 : mz_zip_archive?; var offset : uint64; var buf_0 : uint8?) : int {
    if (pZip_7.m_pRead(pZip_7.m_pIO_opaque, offset, unsafe(unsafe(reinterpret<uint64>(buf_0))), unsafe(reinterpret<size_t>(MZ_ZIP64_END_OF_CENTRAL_DIR_HEADER_SIZE))) == unsafe(reinterpret<size_t>(MZ_ZIP64_END_OF_CENTRAL_DIR_HEADER_SIZE))) {
        if ((uint(((unsafe(unsafe(buf_0 + int(MZ_ZIP64_ECDH_SIG_OFS) == uint(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(buf_0 + int(MZ_ZIP64_ECDH_SIG_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(buf_0 + int(MZ_ZIP64_ECDH_SIG_OFS) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(buf_0 + int(MZ_ZIP64_ECDH_SIG_OFS) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)) == uint(MZ_ZIP64_END_OF_CENTRAL_DIR_HEADER_SIG)) {
            return 1
        }
    }
    return 0
}
[export]
def mz_zip_reader_locate_header_sig(var pZip_8 : mz_zip_archive?; var record_sig : uint; var record_size : uint; var pOfs : int64?) : int {
    var cur_file_ofs_0 : int64 = int64(0)
    var buf_u32_0 : array<uint> = []
    var pBuf_3 : uint8? = null
    pBuf_3 = unsafe(addr(buf_u32_0[0]))
    if (uint64(pZip_8.m_archive_size) < uint64(record_size)) {
        return 0
    } else {
        cur_file_ofs_0 = int64(c2da_max_int64(int64(int64(pZip_8.m_archive_size) - int64(4)), int64(int64(0))))
        if (false) {
        }
    }
}
[export]
def mz_zip_reader_init_internal(var pZip_9 : mz_zip_archive?; var flags_9 : uint) : int {
    flags_9
    if (pZip_9 == null || pZip_9.m_pState != null || uint(pZip_9.m_zip_mode) != uint(MZ_ZIP_MODE_INVALID)) {
        return mz_zip_set_error(pZip_9, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
    } else {
        if (pZip_9.m_pAlloc == null) {
            pZip_9.m_pAlloc = miniz_def_alloc_func
        }
        if (pZip_9.m_pFree == null) {
            pZip_9.m_pFree = miniz_def_free_func
        }
        if (pZip_9.m_pRealloc == null) {
            pZip_9.m_pRealloc = miniz_def_realloc_func
        }
        pZip_9.m_archive_size = uint64((uint64(0) == uint64(0)) ? 1 : 0)
        pZip_9.m_central_directory_file_ofs = uint64((uint64(0) == uint64(0)) ? 1 : 0)
        pZip_9.m_total_files = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
        pZip_9.m_last_error = unsafe(reinterpret<mz_zip_error>(MZ_ZIP_NO_ERROR))
        pZip_9.m_pState = unsafe(unsafe(reinterpret<mz_zip_internal_state_tag?>(pZip_9.m_pAlloc(pZip_9.m_pAlloc_opaque, unsafe(reinterpret<size_t>(1)), 4))))
        if (unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(reinterpret<mz_zip_internal_state_tag?>(uint64(0) == uint64(0)))))) == unsafe(reinterpret<uint64>(pZip_9.m_pState)))) {
            return mz_zip_set_error(pZip_9, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
        } else {
            memset(unsafe(unsafe(reinterpret<uint64>(pZip_9.m_pState))), 0, uint64(4))
            unsafe(addr(pZip_9.m_pState.m_central_dir)).m_element_size = uint(((uint(4) == uint(0)) ? 1 : 0) ? 1 : 0)
            unsafe(addr(pZip_9.m_pState.m_central_dir_offsets)).m_element_size = uint(((uint(4) == uint(0)) ? 1 : 0) ? 1 : 0)
            unsafe(addr(pZip_9.m_pState.m_sorted_central_dir_offsets)).m_element_size = uint(((uint(4) == uint(0)) ? 1 : 0) ? 1 : 0)
            pZip_9.m_pState.m_init_flags = uint(flags_9)
            pZip_9.m_pState.m_zip64 = 0
            pZip_9.m_pState.m_zip64_has_extended_info_fields = 0
            pZip_9.m_zip_mode = unsafe(reinterpret<mz_zip_mode>(MZ_ZIP_MODE_READING))
            return 1
        }
    }
}
[export]
def mz_zip_reader_init_mem(var pZip_10 : mz_zip_archive?; var pMem : uint64; var size_3 : size_t; var flags_10 : uint) : int {
    if (uint64(pMem) == uint64(0)) {
        return mz_zip_set_error(pZip_10, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
    } elif (unsafe(reinterpret<size_t>(size_3)) < unsafe(reinterpret<size_t>(MZ_ZIP_END_OF_CENTRAL_DIR_HEADER_SIZE))) {
        return mz_zip_set_error(pZip_10, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_NOT_AN_ARCHIVE)))
    } elif (uint64((mz_zip_reader_init_internal(pZip_10, flags_10) == uint64(0)) ? 1 : 0) == uint64(0)) {
        return 0
    } else {
        pZip_10.m_zip_type = unsafe(reinterpret<mz_zip_type>(MZ_ZIP_TYPE_MEMORY))
        pZip_10.m_archive_size = uint64(size_3)
        pZip_10.m_pRead = mz_zip_mem_read_func
        pZip_10.m_pIO_opaque = unsafe(unsafe(reinterpret<uint64>(pZip_10)))
        pZip_10.m_pNeeds_keepalive = null
        pZip_10.m_pState.m_pMem = pMem
        pZip_10.m_pState.m_mem_size = unsafe(reinterpret<size_t>(size_3))
        if (uint64((mz_zip_reader_read_central_dir(pZip_10, flags_10) == uint64(0)) ? 1 : 0) == uint64(0)) {
            mz_zip_reader_end_internal(pZip_10, 0)
            return 0
        } else {
            return 1
        }
    }
}
[export]
def mz_zip_mem_read_func(var pOpaque : uint64; var file_ofs : uint64; var pBuf_4 : uint64; var n_7 : size_t) : size_t {
    var pZip_11 : mz_zip_archive? = null
    var s_4 : size_t = unsafe(reinterpret<size_t>(0))
    pZip_11 = pOpaque
    var c2da_fresh59 : uint64 = uint64(0)
    if (uint64(pZip_11.m_archive_size) - uint64(file_ofs) < uint64(unsafe(reinterpret<size_t>(n_7)))) {
        c2da_fresh59 = uint64(pZip_11.m_archive_size) - uint64(file_ofs)
    } else {
        c2da_fresh59 = n_7
    }
    var c2da_fresh60 : size_t = unsafe(reinterpret<size_t>(0))
    if (uint64(file_ofs) >= uint64(pZip_11.m_archive_size)) {
        c2da_fresh60 = unsafe(reinterpret<size_t>(0))
    } else {
        c2da_fresh60 = c2da_fresh59
    }
    s_4 = c2da_fresh60
    memcpy(pBuf_4, unsafe(unsafe(reinterpret<uint64>(unsafe(pZip_11.m_pState.m_pMem + uint64(file_ofs))))), uint64(s_4))
    return s_4
}
[export]
def mz_zip_reader_end(var pZip_12 : mz_zip_archive?) : int {
    return mz_zip_reader_end_internal(pZip_12, 1)
}
[export]
def mz_zip_zero_struct(var pZip_13 : mz_zip_archive?) {
    if (pZip_13 != null) {
        memset(unsafe(unsafe(reinterpret<uint64>(pZip_13))), 0, uint64(4))
    }
    return
}
[export]
def mz_zip_get_mode(var pZip_14 : mz_zip_archive?) : mz_zip_mode {
    var c2da_fresh61 : uint = uint(0)
    if (uint64(pZip_14) != uint64(0)) {
        c2da_fresh61 = uint(pZip_14.m_zip_mode)
    } else {
        c2da_fresh61 = uint(MZ_ZIP_MODE_INVALID)
    }
    return unsafe(reinterpret<mz_zip_mode>(c2da_fresh61))
}
[export]
def mz_zip_get_type(var pZip_15 : mz_zip_archive?) : mz_zip_type {
    var c2da_fresh62 : uint = uint(0)
    if (uint64(pZip_15) != uint64(0)) {
        c2da_fresh62 = uint(pZip_15.m_zip_type)
    } else {
        c2da_fresh62 = uint(MZ_ZIP_TYPE_INVALID)
    }
    return unsafe(reinterpret<mz_zip_type>(c2da_fresh62))
}
[export]
def mz_zip_reader_get_num_files(var pZip_16 : mz_zip_archive?) : uint {
    var c2da_fresh63 : uint = uint(0)
    if (uint64(pZip_16) != uint64(0)) {
        c2da_fresh63 = pZip_16.m_total_files
    } else {
        c2da_fresh63 = uint(0)
    }
    return c2da_fresh63
}
[export]
def mz_zip_get_archive_size(var pZip_17 : mz_zip_archive?) : uint64 {
    if (pZip_17 == null) {
        return uint64(0)
    } else {
        return pZip_17.m_archive_size
    }
}
[export]
def mz_zip_get_archive_file_start_offset(var pZip_18 : mz_zip_archive?) : uint64 {
    if (pZip_18 == null || pZip_18.m_pState == null) {
        return uint64(0)
    } else {
        return pZip_18.m_pState.m_file_archive_start_ofs
    }
}
[export]
def mz_zip_get_cfile(var pZip_19 : mz_zip_archive?) : uint64? {
    if (pZip_19 == null || pZip_19.m_pState == null) {
        return unsafe(unsafe(reinterpret<uint64?>(null)))
    } else {
        return unsafe(unsafe(reinterpret<uint64?>(pZip_19.m_pState.m_pFile)))
    }
}
[export]
def mz_zip_read_archive_data(var pZip_20 : mz_zip_archive?; var file_ofs_0 : uint64; var pBuf_5 : uint64; var n_8 : size_t) : size_t {
    if (pZip_20 == null || pZip_20.m_pState == null || uint64(pBuf_5) == uint64(0) || pZip_20.m_pRead == null) {
        return unsafe(reinterpret<size_t>(mz_zip_set_error(pZip_20, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))))
    } else {
        return pZip_20.m_pRead(pZip_20.m_pIO_opaque, file_ofs_0, pBuf_5, n_8)
    }
}
[export]
def mz_zip_set_last_error(var pZip_21 : mz_zip_archive?; var err_num_0 : mz_zip_error) : mz_zip_error {
    var prev_err : mz_zip_error = unsafe(reinterpret<mz_zip_error>(0))
    if (pZip_21 == null) {
        return unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER))
    } else {
        prev_err = pZip_21.m_last_error
        pZip_21.m_last_error = err_num_0
        return prev_err
    }
}
[export]
def mz_zip_peek_last_error(var pZip_22 : mz_zip_archive?) : mz_zip_error {
    if (pZip_22 == null) {
        return unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER))
    } else {
        return pZip_22.m_last_error
    }
}
[export]
def mz_zip_clear_last_error(var pZip_23 : mz_zip_archive?) : mz_zip_error {
    return mz_zip_set_last_error(pZip_23, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_NO_ERROR)))
}
[export]
def mz_zip_get_last_error(var pZip_24 : mz_zip_archive?) : mz_zip_error {
    var prev_err_0 : mz_zip_error = unsafe(reinterpret<mz_zip_error>(0))
    if (pZip_24 == null) {
        return unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER))
    } else {
        prev_err_0 = pZip_24.m_last_error
        pZip_24.m_last_error = unsafe(reinterpret<mz_zip_error>(MZ_ZIP_NO_ERROR))
        return prev_err_0
    }
}
[export]
def mz_zip_get_error_string(var mz_err : mz_zip_error) : int8 const? {
    uint(mz_err)
    return unsafe(unsafe(reinterpret<int8 const?>(unsafe(addr(uint8(110))))))
}
[export]
def mz_zip_reader_is_file_a_directory(var pZip_25 : mz_zip_archive?; var file_index : uint) : int {
    var filename_len : uint = uint(0)
    var attribute_mapping_id : uint = uint(0)
    var external_attr : uint = uint(0)
    var p_5 : uint8 const? = null
    p_5 = mz_zip_get_cdh(pZip_25, file_index)
    if (p_5 == null) {
        mz_zip_set_error(pZip_25, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
        return 0
    } else {
        filename_len = uint(((uint(unsafe(unsafe(p_5 + int(MZ_ZIP_CDH_FILENAME_LEN_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(p_5 + int(MZ_ZIP_CDH_FILENAME_LEN_OFS) == uint(0))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
        if (uint64(filename_len) != uint64(0)) {
            if (int(*unsafe(p_5 + (int(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE) + (uint(filename_len) - 1)))) == 47) {
                return 1
            }
        }
        attribute_mapping_id = uint(((uint(uint(unsafe(unsafe(p_5 + int(MZ_ZIP_CDH_VERSION_MADE_BY_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(p_5 + int(MZ_ZIP_CDH_VERSION_MADE_BY_OFS) == uint(0))[1]))) << uint(0x8)) >> uint(uint(8) == uint(0))) ? 1 : 0) ? 1 : 0)
        attribute_mapping_id
        external_attr = uint(((uint(unsafe(unsafe(p_5 + int(MZ_ZIP_CDH_EXTERNAL_ATTR_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(p_5 + int(MZ_ZIP_CDH_EXTERNAL_ATTR_OFS) == uint(0))[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(p_5 + int(MZ_ZIP_CDH_EXTERNAL_ATTR_OFS) == uint(0))[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(p_5 + int(MZ_ZIP_CDH_EXTERNAL_ATTR_OFS) == uint(0))[3]))) << uint(0x18)) ? 1 : 0) ? 1 : 0)
        if (uint64(uint(external_attr) & uint(MZ_ZIP_DOS_DIR_ATTRIBUTE_BITFLAG)) != uint64(0)) {
            return 1
        } else {
            return 0
        }
    }
}
[export]
def mz_zip_get_cdh(var pZip_26 : mz_zip_archive?; var file_index_0 : uint) : uint8 const? {
    if (pZip_26 == null || pZip_26.m_pState == null || uint(file_index_0) >= uint(pZip_26.m_total_files)) {
        return unsafe(unsafe(reinterpret<uint8 const?>(null)))
    } else {
        return unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(pZip_26.m_pState.m_central_dir)).m_p)))[uint(unsafe(unsafe(unsafe(reinterpret<uint?>(unsafe(addr(pZip_26.m_pState.m_central_dir_offsets)).m_p)))[uint(file_index_0)]))]))))))
    }
}
[export]
def mz_zip_reader_is_file_encrypted(var pZip_27 : mz_zip_archive?; var file_index_1 : uint) : int {
    var m_bit_flag : uint = uint(0)
    var p_6 : uint8 const? = null
    p_6 = mz_zip_get_cdh(pZip_27, file_index_1)
    if (p_6 == null) {
        mz_zip_set_error(pZip_27, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
        return 0
    } else {
        m_bit_flag = uint(((uint(unsafe(unsafe(p_6 + int(MZ_ZIP_CDH_BIT_FLAG_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(p_6 + int(MZ_ZIP_CDH_BIT_FLAG_OFS) == uint(0))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
        return uint64(uint(m_bit_flag) & uint(int(MZ_ZIP_GENERAL_PURPOSE_BIT_FLAG_IS_ENCRYPTED) | int(MZ_ZIP_GENERAL_PURPOSE_BIT_FLAG_USES_STRONG_ENCRYPTION))) != uint64(0)
    }
}
[export]
def mz_zip_reader_is_file_supported(var pZip_28 : mz_zip_archive?; var file_index_2 : uint) : int {
    var bit_flag : uint = uint(0)
    var method_1 : uint = uint(0)
    var p_7 : uint8 const? = null
    p_7 = mz_zip_get_cdh(pZip_28, file_index_2)
    if (p_7 == null) {
        mz_zip_set_error(pZip_28, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
        return 0
    } else {
        method_1 = uint(((uint(unsafe(unsafe(p_7 + int(MZ_ZIP_CDH_METHOD_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(p_7 + int(MZ_ZIP_CDH_METHOD_OFS) == uint(0))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
        bit_flag = uint(((uint(unsafe(unsafe(p_7 + int(MZ_ZIP_CDH_BIT_FLAG_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(p_7 + int(MZ_ZIP_CDH_BIT_FLAG_OFS) == uint(0))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
        if (uint64((uint(method_1) == uint(0)) ? 1 : 0) != uint64(0) && uint(method_1) != uint(8)) {
            mz_zip_set_error(pZip_28, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNSUPPORTED_METHOD)))
            return 0
        } elif (uint64(uint(bit_flag) & uint(int(MZ_ZIP_GENERAL_PURPOSE_BIT_FLAG_IS_ENCRYPTED) | int(MZ_ZIP_GENERAL_PURPOSE_BIT_FLAG_USES_STRONG_ENCRYPTION))) != uint64(0)) {
            mz_zip_set_error(pZip_28, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNSUPPORTED_ENCRYPTION)))
            return 0
        } elif (uint64(uint(bit_flag) & uint(MZ_ZIP_GENERAL_PURPOSE_BIT_FLAG_COMPRESSED_PATCH_FLAG)) != uint64(0)) {
            mz_zip_set_error(pZip_28, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNSUPPORTED_FEATURE)))
            return 0
        } else {
            return 1
        }
    }
}
[export]
def mz_zip_reader_get_filename(var pZip_29 : mz_zip_archive?; var file_index_3 : uint; var pFilename : int8?; var filename_buf_size : uint) : uint {
    var n_9 : uint = uint(0)
    var p_8 : uint8 const? = null
    p_8 = mz_zip_get_cdh(pZip_29, file_index_3)
    if (p_8 == null) {
        if (uint64(filename_buf_size) != uint64(0)) {
            unsafe(unsafe(unsafe(reinterpret<int8?>(pFilename)))[0]) = int8(0)
        }
        mz_zip_set_error(pZip_29, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
        return uint(0)
    } else {
        n_9 = uint(((uint(unsafe(unsafe(p_8 + int(MZ_ZIP_CDH_FILENAME_LEN_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(p_8 + int(MZ_ZIP_CDH_FILENAME_LEN_OFS) == uint(0))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
        if (uint64(filename_buf_size) != uint64(0)) {
            var c2da_fresh64 : uint = uint(0)
            if (uint(n_9) < uint(filename_buf_size) - uint(1)) {
                c2da_fresh64 = n_9
            } else {
                c2da_fresh64 = uint(filename_buf_size) - uint(1)
            }
            n_9 = uint(c2da_fresh64)
            memcpy(unsafe(unsafe(reinterpret<uint64>(pFilename))), unsafe(unsafe(reinterpret<uint64>(unsafe(p_8 + int(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE))))), uint64((uint64(n_9) == uint64(0)) ? 1 : 0))
            unsafe(unsafe(unsafe(reinterpret<int8?>(pFilename)))[uint(n_9)]) = int8(0)
        }
        return uint(n_9) + uint(1)
    }
}
[export]
def mz_zip_reader_locate_file(var pZip_30 : mz_zip_archive?; var pName : int8 const?; var pComment : int8 const?; var flags_11 : uint) : int {
    var index : uint = uint(0)
    if (uint64((mz_zip_reader_locate_file_v2(pZip_30, pName, pComment, flags_11, unsafe(addr(index) == uint64(0)))) ? 1 : 0) == uint64(0)) {
        return -1
    } else {
        return int(index)
    }
}
[export]
def mz_zip_reader_locate_file_v2(var pZip_31 : mz_zip_archive?; var pName_0 : int8 const?; var pComment_0 : int8 const?; var flags_12 : uint; var pIndex : uint?) : int {
    var file_index_4 : uint = uint(0)
    var name_len : size_t = unsafe(reinterpret<size_t>(0))
    var comment_len : size_t = unsafe(reinterpret<size_t>(0))
    if (pIndex != null) {
        *pIndex = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
    }
    if (pZip_31 == null || pZip_31.m_pState == null || pName_0 == null) {
        return mz_zip_set_error(pZip_31, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
    } elif (uint64(uint(pZip_31.m_pState.m_init_flags) & uint(MZ_ZIP_FLAG_DO_NOT_SORT_CENTRAL_DIRECTORY)) == uint64(0) && uint(pZip_31.m_zip_mode) == uint(MZ_ZIP_MODE_READING) && uint64(uint(flags_12) & uint(int(MZ_ZIP_FLAG_IGNORE_PATH) | int(MZ_ZIP_FLAG_CASE_SENSITIVE))) == uint64(0) && pComment_0 == null && uint64(pZip_31.m_pState.m_sorted_central_dir_offsets.m_size) != uint64(0)) {
        return mz_zip_locate_file_binary_search(pZip_31, pName_0, pIndex)
    } else {
        name_len = unsafe(reinterpret<size_t>(strlen(pName_0)))
        if (unsafe(reinterpret<size_t>(name_len)) > unsafe(reinterpret<size_t>(0xffff))) {
            return mz_zip_set_error(pZip_31, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
        } else {
            var c2da_fresh65 : size_t = unsafe(reinterpret<size_t>(0))
            if (uint64(pComment_0) != uint64(0)) {
                c2da_fresh65 = strlen(pComment_0)
            } else {
                c2da_fresh65 = unsafe(reinterpret<size_t>(0))
            }
            comment_len = unsafe(reinterpret<size_t>(c2da_fresh65))
            if (unsafe(reinterpret<size_t>(comment_len)) > unsafe(reinterpret<size_t>(0xffff))) {
                return mz_zip_set_error(pZip_31, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
            } else {
                if (false) {
                }
            }
        }
    }
}
[export]
def mz_zip_string_equal(var pA : int8 const?; var pB : int8 const?; var len_26 : uint; var flags_13 : uint) : int {
    var i_20 : uint = uint(0)
    if (uint64(uint(flags_13) & uint(MZ_ZIP_FLAG_CASE_SENSITIVE)) != uint64(0)) {
        return 0 == memcmp(unsafe(unsafe(reinterpret<uint64>(pA))), unsafe(unsafe(reinterpret<uint64>(pB))), uint64(len_26))
    } else {
        if (false) {
        }
    }
}
[export]
def mz_zip_locate_file_binary_search(var pZip_32 : mz_zip_archive?; var pFilename_1 : int8 const?; var pIndex_0 : uint?) : int {
    var pState_2 : mz_zip_internal_state_tag? = null
    var pCentral_dir_offsets_1 : mz_zip_array const? = null
    var pCentral_dir_0 : mz_zip_array const? = null
    var pIndices_0 : uint? = null
    var size_4 : uint const = uint(0)
    var filename_len_1 : uint const = uint(0)
    var l_2 : int64 = int64(0)
    var h_1 : int64 = int64(0)
    var m : int64 = int64(0)
    var file_index_5 : uint = uint(0)
    var comp : int = int(0)
    pState_2 = pZip_32.m_pState
    pCentral_dir_offsets_1 = unsafe(addr(pState_2.m_central_dir_offsets))
    pCentral_dir_0 = unsafe(addr(pState_2.m_central_dir))
    pIndices_0 = unsafe(addr(unsafe(unsafe(unsafe(reinterpret<uint?>(unsafe(addr(pState_2.m_sorted_central_dir_offsets)).m_p)))[0])))
    size_4 = pZip_32.m_total_files
    filename_len_1 = uint(strlen(pFilename_1))
    if (pIndex_0 != null) {
        *pIndex_0 = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
    }
    while (true) {
        if (uint64(size_4) != uint64(0)) {
            l_2 = int64(0)
            h_1 = int64(size_4) - int64(1)
            while (true) {
                if (int64(l_2) <= int64(h_1)) {
                    m = int64(l_2) + (int64(int64(h_1) - int64(l_2)) >> int64(int64(1)))
                    file_index_5 = unsafe(unsafe(unsafe(reinterpret<uint?>(pIndices_0)))[uint(m)])
                    comp = mz_zip_filename_compare(pCentral_dir_0, pCentral_dir_offsets_1, file_index_5, pFilename_1, filename_len_1)
                    if (uint64(comp) == uint64(0)) {
                        if (pIndex_0 != null) {
                            *pIndex_0 = uint(file_index_5)
                        }
                        return 1
                    } elif (int(comp) < 0) {
                        l_2 = int64(int64(m) + int64(1))
                    } else {
                        h_1 = int64(int64(m) - int64(1))
                    }
                } else {
                    if (false) {
                    }
                }
            }
        }
    }
    return mz_zip_set_error(pZip_32, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_NOT_FOUND)))
}
[export]
def mz_zip_filename_compare(var pCentral_dir_array_0 : mz_zip_array const?; var pCentral_dir_offsets_2 : mz_zip_array const?; var l_index_0 : uint; var pR_0 : int8 const?; var r_len_0 : uint) : int {
    var pL_0 : uint8 const? = null
    var pE_0 : uint8 const? = null
    var l_len_0 : uint = uint(0)
    var l_3 : uint8 = uint8(0)
    var r_2 : uint8 = uint8(0)
    pL_0 = unsafe(addr(unsafe(unsafe(unsafe(reinterpret<uint8?>(pCentral_dir_array_0.m_p)))[uint(unsafe(unsafe(unsafe(reinterpret<uint?>(pCentral_dir_offsets_2.m_p)))[uint(l_index_0)]))])))
    l_len_0 = uint(unsafe(unsafe(pL_0 + int(MZ_ZIP_CDH_FILENAME_LEN_OFS))[0])) | uint(((uint(unsafe(unsafe(pL_0 + int(MZ_ZIP_CDH_FILENAME_LEN_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8)
    l_3 = uint8(0)
    r_2 = uint8(0)
    pL_0 = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(pL_0 + MZ_ZIP_CENTRAL_DIR_HEADER_SIZE))))
    var c2da_fresh68 : uint = uint(0)
    if (uint(l_len_0) < uint(r_len_0)) {
        c2da_fresh68 = l_len_0
    } else {
        c2da_fresh68 = r_len_0
    }
    pE_0 = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(pL_0 + uint(c2da_fresh68)))))
    while (true) {
        if (!unsafe(unsafe(reinterpret<uint64>(pL_0)) < unsafe(reinterpret<uint64>(pE_0)))) {
            if (false) {
            }
        }
        var c2da_fresh69 : int = int(0)
        if (int(*pL_0) >= 65 && int(*pL_0) <= 90) {
            c2da_fresh69 = int(*pL_0) - 65 + 97
        } else {
            c2da_fresh69 = int(*pL_0)
        }
        l_3 = uint8(uint8(c2da_fresh69))
        var c2da_fresh70 : int = int(0)
        if (int(*pR_0) >= 65 && int(*pR_0) <= 90) {
            c2da_fresh70 = int(*pR_0) - 65 + 97
        } else {
            c2da_fresh70 = int(*pR_0)
        }
        r_2 = uint8(uint8(c2da_fresh70))
        if (int(l_3) != int(r_2)) {
            if (false) {
            }
            if (false) {
            }
        } else {
            pL_0 = unsafe(pL_0 + uint64(1))
            pL_0
            pR_0 = unsafe(pR_0 + uint64(1))
            pR_0
        }
    }
    var c2da_fresh71 : int = int(0)
    if (unsafe(unsafe(reinterpret<uint64>(pL_0)) == unsafe(reinterpret<uint64>(pE_0)))) {
        c2da_fresh71 = int(uint(l_len_0) - uint(r_len_0))
    } else {
        c2da_fresh71 = int(l_3) - int(r_2)
    }
    return c2da_fresh71
}
[export]
def mz_zip_reader_file_stat(var pZip_33 : mz_zip_archive?; var file_index_6 : uint; var pStat : mz_zip_archive_file_stat?) : int {
    return mz_zip_file_stat_internal(pZip_33, file_index_6, mz_zip_get_cdh(pZip_33, file_index_6), pStat, null)
}
[export]
def mz_zip_file_stat_internal(var pZip_34 : mz_zip_archive?; var file_index_7 : uint; var pCentral_dir_header : uint8 const?; var pStat_0 : mz_zip_archive_file_stat?; var pFound_zip64_extra_data : int?) : int {
    var n_10 : uint = uint(0)
    var p_9 : uint8 const? = null
    var extra_size_remaining_0 : uint = uint(0)
    var pExtra_data_0 : uint8 const? = null
    var field_id_0 : uint = uint(0)
    var field_data_size_0 : uint = uint(0)
    var pField_data : uint8 const? = null
    var field_data_remaining : uint = uint(0)
    p_9 = pCentral_dir_header
    if (pFound_zip64_extra_data != null) {
        *pFound_zip64_extra_data = 0
    }
    if (p_9 == null || pStat_0 == null) {
        return mz_zip_set_error(pZip_34, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
    } else {
        pStat_0.m_file_index = uint(file_index_7)
        pStat_0.m_central_dir_ofs = uint64((uint64(unsafe(unsafe(unsafe(reinterpret<uint?>(unsafe(addr(pZip_34.m_pState.m_central_dir_offsets) == uint64(0)).m_p)))[uint(file_index_7)]))) ? 1 : 0)
        pStat_0.m_version_made_by = uint16(uint16(uint(((unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_VERSION_MADE_BY_OFS) == uint(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_VERSION_MADE_BY_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8)))
        pStat_0.m_version_needed = uint16(uint16(uint(((unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_VERSION_NEEDED_OFS) == uint(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_VERSION_NEEDED_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8)))
        pStat_0.m_bit_flag = uint16(uint16(uint(((unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_BIT_FLAG_OFS) == uint(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_BIT_FLAG_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8)))
        pStat_0.m_method = uint16(uint16(uint(((unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_METHOD_OFS) == uint(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_METHOD_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8)))
        pStat_0.m_crc32 = uint(((uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_CRC32_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_CRC32_OFS) == uint(0))[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_CRC32_OFS) == uint(0))[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_CRC32_OFS) == uint(0))[3]))) << uint(0x18)) ? 1 : 0) ? 1 : 0)
        pStat_0.m_comp_size = uint64((uint64(uint(((unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_COMPRESSED_SIZE_OFS) == uint64(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_COMPRESSED_SIZE_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_COMPRESSED_SIZE_OFS) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_COMPRESSED_SIZE_OFS) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18))) ? 1 : 0)
        pStat_0.m_uncomp_size = uint64((uint64(uint(((unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_DECOMPRESSED_SIZE_OFS) == uint64(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_DECOMPRESSED_SIZE_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_DECOMPRESSED_SIZE_OFS) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_DECOMPRESSED_SIZE_OFS) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18))) ? 1 : 0)
        pStat_0.m_internal_attr = uint16(uint16(uint(((unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_INTERNAL_ATTR_OFS) == uint(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_INTERNAL_ATTR_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8)))
        pStat_0.m_external_attr = uint(((uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_EXTERNAL_ATTR_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_EXTERNAL_ATTR_OFS) == uint(0))[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_EXTERNAL_ATTR_OFS) == uint(0))[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_EXTERNAL_ATTR_OFS) == uint(0))[3]))) << uint(0x18)) ? 1 : 0) ? 1 : 0)
        pStat_0.m_local_header_ofs = uint64((uint64(uint(((unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_LOCAL_HEADER_OFS) == uint64(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_LOCAL_HEADER_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_LOCAL_HEADER_OFS) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_LOCAL_HEADER_OFS) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18))) ? 1 : 0)
        n_10 = uint(((uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_FILENAME_LEN_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_FILENAME_LEN_OFS) == uint(0))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
        var c2da_fresh72 : uint = uint(0)
        if (uint(n_10) < uint(int(MZ_ZIP_MAX_ARCHIVE_FILENAME_SIZE) - 1)) {
            c2da_fresh72 = n_10
        } else {
            c2da_fresh72 = uint(int(MZ_ZIP_MAX_ARCHIVE_FILENAME_SIZE) - 1)
        }
        n_10 = uint(c2da_fresh72)
        memcpy(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(pStat_0.m_filename[0]))))), unsafe(unsafe(reinterpret<uint64>(unsafe(p_9 + int(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE))))), uint64((uint64(n_10) == uint64(0)) ? 1 : 0))
        unsafe(unsafe(addr(pStat_0.m_filename[0]))[uint(n_10)]) = int8(0)
        n_10 = uint(((uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_COMMENT_LEN_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_COMMENT_LEN_OFS) == uint(0))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
        var c2da_fresh73 : uint = uint(0)
        if (uint(n_10) < uint(int(MZ_ZIP_MAX_ARCHIVE_FILE_COMMENT_SIZE) - 1)) {
            c2da_fresh73 = n_10
        } else {
            c2da_fresh73 = uint(int(MZ_ZIP_MAX_ARCHIVE_FILE_COMMENT_SIZE) - 1)
        }
        n_10 = uint(c2da_fresh73)
        pStat_0.m_comment_size = uint(n_10)
        memcpy(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(pStat_0.m_comment[0]))))), unsafe(unsafe(reinterpret<uint64>(unsafe(p_9 + (int(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE) + ((uint(((unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_FILENAME_LEN_OFS) == uint(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_FILENAME_LEN_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8)) + (uint(((unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_EXTRA_LEN_OFS) == uint(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_EXTRA_LEN_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8)))))))), uint64((uint64(n_10) == uint64(0)) ? 1 : 0))
        unsafe(unsafe(addr(pStat_0.m_comment[0]))[uint(n_10)]) = int8(0)
        pStat_0.m_is_directory = mz_zip_reader_is_file_a_directory(pZip_34, file_index_7)
        pStat_0.m_is_encrypted = mz_zip_reader_is_file_encrypted(pZip_34, file_index_7)
        pStat_0.m_is_supported = mz_zip_reader_is_file_supported(pZip_34, file_index_7)
        var c2da_fresh74 : uint64 = uint64(0)
        if (uint64(pStat_0.m_comp_size) > uint64(pStat_0.m_uncomp_size)) {
            c2da_fresh74 = pStat_0.m_comp_size
        } else {
            c2da_fresh74 = pStat_0.m_uncomp_size
        }
        var c2da_fresh75 : uint64 = uint64(0)
        if (uint64(pStat_0.m_comp_size) > uint64(pStat_0.m_uncomp_size)) {
            c2da_fresh75 = pStat_0.m_comp_size
        } else {
            c2da_fresh75 = pStat_0.m_uncomp_size
        }
        var c2da_fresh76 : uint64 = uint64(0)
        if (uint64(c2da_fresh74) > uint64(pStat_0.m_local_header_ofs)) {
            c2da_fresh76 = c2da_fresh75
        } else {
            c2da_fresh76 = pStat_0.m_local_header_ofs
        }
        if (uint64(c2da_fresh76) == uint64(0xffffffff)) {
            extra_size_remaining_0 = uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_EXTRA_LEN_OFS))[0])) | uint(((uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_EXTRA_LEN_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8)
            if (uint64(extra_size_remaining_0) != uint64(0)) {
                pExtra_data_0 = unsafe(p_9 + (int(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE) + int(((uint((unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_FILENAME_LEN_OFS) == uint(0))[0])) ? 1 : 0) | uint((uint(unsafe(unsafe(p_9 + int(MZ_ZIP_CDH_FILENAME_LEN_OFS) == uint(0))[1]))) ? 1 : 0) << uint(0x8))) ? 1 : 0)))
                while (true) {
                    if (uint64(extra_size_remaining_0) < uint64((4 * int((uint64(2) == uint64(0)) ? 1 : 0)) ? 1 : 0)) {
                        return mz_zip_set_error(pZip_34, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
                    } else {
                        field_id_0 = uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pExtra_data_0) == uint(0)))[0])) | uint(uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pExtra_data_0) == uint(0)))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
                        field_data_size_0 = uint(uint(unsafe(unsafe(pExtra_data_0 + 4)[0])) | uint(uint(unsafe(unsafe(pExtra_data_0 + 4)[1]))) << uint(0x8))
                        if (uint64(field_data_size_0) + uint64((uint64(4 * int((uint64(2) == uint64(0)) ? 1 : 0))) ? 1 : 0) > uint64(extra_size_remaining_0)) {
                            return mz_zip_set_error(pZip_34, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
                        } elif (uint(field_id_0) == uint(MZ_ZIP64_EXTENDED_INFORMATION_FIELD_HEADER_ID)) {
                            pField_data = unsafe(pExtra_data_0 + 4 * int((uint64(2) == uint64(0)) ? 1 : 0))
                            field_data_remaining = field_data_size_0
                            if (pFound_zip64_extra_data != null) {
                                *pFound_zip64_extra_data = 1
                            }
                            if (uint64(pStat_0.m_uncomp_size) == uint64(0xffffffff)) {
                                if (uint64(field_data_remaining) < uint64(4)) {
                                    return mz_zip_set_error(pZip_34, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
                                } else {
                                    pStat_0.m_uncomp_size = uint64((uint64(uint(((unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pField_data) == uint64(0)))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pField_data) == uint(0)))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pField_data) == uint(0)))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pField_data) == uint(0)))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)) | uint64(uint64(uint(unsafe(unsafe(pField_data + 4)[0])) | uint(uint(unsafe(unsafe(pField_data + 4)[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(pField_data + 4)[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(pField_data + 4)[3]))) << uint(0x18))) << uint64(uint64(0x20) == uint64(0))) ? 1 : 0)
                                    pField_data = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(pField_data + 4))))
                                    field_data_remaining = uint64(field_data_remaining - 4)
                                }
                            }
                            if (uint64(pStat_0.m_comp_size) == uint64(0xffffffff)) {
                                if (uint64(field_data_remaining) < uint64(4)) {
                                    return mz_zip_set_error(pZip_34, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
                                } else {
                                    pStat_0.m_comp_size = uint64((uint64(uint(((unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pField_data) == uint64(0)))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pField_data) == uint(0)))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pField_data) == uint(0)))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pField_data) == uint(0)))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)) | uint64(uint64(uint(unsafe(unsafe(pField_data + 4)[0])) | uint(uint(unsafe(unsafe(pField_data + 4)[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(pField_data + 4)[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(pField_data + 4)[3]))) << uint(0x18))) << uint64(uint64(0x20) == uint64(0))) ? 1 : 0)
                                    pField_data = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(pField_data + 4))))
                                    field_data_remaining = uint64(field_data_remaining - 4)
                                }
                            }
                            if (uint64(pStat_0.m_local_header_ofs) == uint64(0xffffffff)) {
                                if (uint64(field_data_remaining) < uint64(4)) {
                                    return mz_zip_set_error(pZip_34, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
                                } else {
                                    pStat_0.m_local_header_ofs = uint64((uint64(uint(((unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pField_data) == uint64(0)))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pField_data) == uint(0)))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pField_data) == uint(0)))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pField_data) == uint(0)))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)) | uint64(uint64(uint(unsafe(unsafe(pField_data + 4)[0])) | uint(uint(unsafe(unsafe(pField_data + 4)[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(pField_data + 4)[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(pField_data + 4)[3]))) << uint(0x18))) << uint64(uint64(0x20) == uint64(0))) ? 1 : 0)
                                    pField_data = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(pField_data + 4))))
                                    field_data_remaining = uint64(field_data_remaining - 4)
                                }
                            }
                            if (false) {
                            }
                            if (false) {
                            }
                        } else {
                            pExtra_data_0 = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(pExtra_data_0 + (4 * int((uint64(2) == uint64(0)) ? 1 : 0) + int((int(uint64(field_data_size_0) == uint64(0))) ? 1 : 0))))))
                            extra_size_remaining_0 = uint(((uint(uint64(extra_size_remaining_0) - uint64((uint64(4 * int(uint64(2) == uint64(0)))) ? 1 : 0) - uint64(field_data_size_0))) ? 1 : 0) ? 1 : 0)
                            if (!(uint64(extra_size_remaining_0) != uint64(0))) {
                                if (false) {
                                }
                            }
                        }
                    }
                }
            }
        }
        return 1
    }
}
[export]
def mz_zip_is_zip64(var pZip_35 : mz_zip_archive?) : int {
    if (pZip_35 == null || pZip_35.m_pState == null) {
        return 0
    } else {
        return pZip_35.m_pState.m_zip64
    }
}
[export]
def mz_zip_get_central_dir_size(var pZip_36 : mz_zip_archive?) : size_t {
    if (pZip_36 == null || pZip_36.m_pState == null) {
        return unsafe(reinterpret<size_t>(0))
    } else {
        return pZip_36.m_pState.m_central_dir.m_size
    }
}
[export]
def mz_zip_reader_extract_to_mem_no_alloc(var pZip_37 : mz_zip_archive?; var file_index_8 : uint; var pBuf_6 : uint64; var buf_size : size_t; var flags_14 : uint; var pUser_read_buf : uint64; var user_read_buf_size : size_t) : int {
    return mz_zip_reader_extract_to_mem_no_alloc1(pZip_37, file_index_8, pBuf_6, buf_size, flags_14, pUser_read_buf, user_read_buf_size, null)
}
[export]
def mz_zip_reader_extract_to_mem_no_alloc1(var pZip_38 : mz_zip_archive?; var file_index_9 : uint; var pBuf_7 : uint64; var buf_size_0 : size_t; var flags_15 : uint; var pUser_read_buf_0 : uint64; var user_read_buf_size_0 : size_t; var st : mz_zip_archive_file_stat const?) : int {
    var status_7 : int = int(0)
    var needed_size : uint64 = uint64(0)
    var cur_file_ofs_1 : uint64 = uint64(0)
    var comp_remaining : uint64 = uint64(0)
    var out_buf_ofs : uint64 = uint64(0)
    var read_buf_size : uint64 = uint64(0)
    var read_buf_ofs : uint64 = uint64(0)
    var read_buf_avail : uint64 = uint64(0)
    var file_stat : mz_zip_archive_file_stat = mz_zip_archive_file_stat()
    var pRead_buf : uint64 = uint64(0)
    var local_header_u32 : array<uint> = []
    var pLocal_header : uint8? = null
    var inflator : tinfl_decompressor_tag = tinfl_decompressor_tag()
    var in_buf_size_1 : size_t = unsafe(reinterpret<size_t>(0))
    var out_buf_size : size_t = unsafe(reinterpret<size_t>(0))
    status_7 = TINFL_STATUS_DONE
    out_buf_ofs = uint64(0)
    read_buf_ofs = uint64(0)
    pLocal_header = unsafe(addr(local_header_u32[0]))
    if (pZip_38 == null || pZip_38.m_pState == null || uint64(buf_size_0) != uint64(0) && uint64(pBuf_7) == uint64(0) || uint64(user_read_buf_size_0) != uint64(0) && uint64(pUser_read_buf_0) == uint64(0) || pZip_38.m_pRead == null) {
        return mz_zip_set_error(pZip_38, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
    } else {
        if (st != null) {
            file_stat = unsafe(*unsafe(unsafe(reinterpret<mz_zip_archive_file_stat?>(st))))
        } elif (uint64((mz_zip_reader_file_stat(pZip_38, file_index_9, unsafe(addr(file_stat) == uint64(0)))) ? 1 : 0) == uint64(0)) {
            return 0
        }
        if (uint64(file_stat.m_is_directory) != uint64(0) || uint64(file_stat.m_comp_size) == uint64(0)) {
            return 1
        } elif (uint64(int(file_stat.m_bit_flag) & (int(MZ_ZIP_GENERAL_PURPOSE_BIT_FLAG_IS_ENCRYPTED) | int(MZ_ZIP_GENERAL_PURPOSE_BIT_FLAG_USES_STRONG_ENCRYPTION) | int(MZ_ZIP_GENERAL_PURPOSE_BIT_FLAG_COMPRESSED_PATCH_FLAG))) != uint64(0)) {
            return mz_zip_set_error(pZip_38, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNSUPPORTED_ENCRYPTION)))
        } elif (uint64(uint(flags_15) & uint(MZ_ZIP_FLAG_COMPRESSED_DATA)) == uint64(0) && uint64((int(file_stat.m_method) == int(0)) ? 1 : 0) != uint64(0) && int(file_stat.m_method) != 8) {
            return mz_zip_set_error(pZip_38, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNSUPPORTED_METHOD)))
        } else {
            var c2da_fresh77 : uint64 = uint64(0)
            if (uint64(uint(flags_15) & uint(MZ_ZIP_FLAG_COMPRESSED_DATA)) != uint64(0)) {
                c2da_fresh77 = file_stat.m_comp_size
            } else {
                c2da_fresh77 = file_stat.m_uncomp_size
            }
            needed_size = uint64(c2da_fresh77)
            if (unsafe(reinterpret<size_t>(buf_size_0)) < unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(uint64(needed_size) == uint64(0)))))) {
                return mz_zip_set_error(pZip_38, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_BUF_TOO_SMALL)))
            } else {
                cur_file_ofs_1 = uint64(file_stat.m_local_header_ofs)
                if (pZip_38.m_pRead(pZip_38.m_pIO_opaque, cur_file_ofs_1, unsafe(unsafe(reinterpret<uint64>(pLocal_header))), unsafe(reinterpret<size_t>(MZ_ZIP_LOCAL_DIR_HEADER_SIZE))) != unsafe(reinterpret<size_t>(MZ_ZIP_LOCAL_DIR_HEADER_SIZE))) {
                    return mz_zip_set_error(pZip_38, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_READ_FAILED)))
                } elif ((uint(((unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pLocal_header) == uint(0)))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pLocal_header) == uint(0)))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pLocal_header) == uint(0)))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pLocal_header) == uint(0)))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)) != uint(MZ_ZIP_LOCAL_DIR_HEADER_SIG)) {
                    return mz_zip_set_error(pZip_38, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
                } else {
                    cur_file_ofs_1 = uint64((cur_file_ofs_1 + (uint64(MZ_ZIP_LOCAL_DIR_HEADER_SIZE) + (uint64(uint(((unsafe(unsafe(pLocal_header + int(MZ_ZIP_LDH_FILENAME_LEN_OFS) == uint64(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pLocal_header + int(MZ_ZIP_LDH_FILENAME_LEN_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8)) + uint64(uint(((unsafe(unsafe(pLocal_header + int(MZ_ZIP_LDH_EXTRA_LEN_OFS) == uint(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pLocal_header + int(MZ_ZIP_LDH_EXTRA_LEN_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8))))) ? 1 : 0)
                    if (uint64(cur_file_ofs_1) + uint64(file_stat.m_comp_size) > uint64(pZip_38.m_archive_size)) {
                        return mz_zip_set_error(pZip_38, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
                    } elif (uint64(uint(flags_15) & uint(MZ_ZIP_FLAG_COMPRESSED_DATA)) != uint64(0) || uint64(file_stat.m_method) == uint64(0)) {
                        if (pZip_38.m_pRead(pZip_38.m_pIO_opaque, cur_file_ofs_1, pBuf_7, needed_size) != unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(uint64(needed_size) == uint64(0)))))) {
                            return mz_zip_set_error(pZip_38, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_READ_FAILED)))
                        } else {
                            if (uint64(uint(flags_15) & uint(MZ_ZIP_FLAG_COMPRESSED_DATA)) == uint64(0)) {
                                if (mz_crc32(uint64(0), pBuf_7, file_stat.m_uncomp_size) != uint64(file_stat.m_crc32)) {
                                    return mz_zip_set_error(pZip_38, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_CRC_CHECK_FAILED)))
                                }
                            }
                            return 1
                        }
                    } else {
                        while (true) {
                            unsafe(addr(inflator)).m_state = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
                            if (!(uint64(0) != uint64(0))) {
                                if (false) {
                                }
                            }
                        }
                        if (uint64(pZip_38.m_pState.m_pMem) != uint64(0)) {
                            pRead_buf = unsafe(unsafe(reinterpret<uint64>(unsafe(pZip_38.m_pState.m_pMem + uint64(cur_file_ofs_1)))))
                            read_buf_avail = uint64(file_stat.m_comp_size)
                            read_buf_size = read_buf_avail
                            comp_remaining = uint64((uint64(0) == uint64(0)) ? 1 : 0)
                        } elif (uint64(pUser_read_buf_0) != uint64(0)) {
                            if (uint64(user_read_buf_size_0) == uint64(0)) {
                                return 0
                            } else {
                                pRead_buf = unsafe(unsafe(reinterpret<uint64>(pUser_read_buf_0)))
                                read_buf_size = uint64(user_read_buf_size_0)
                                read_buf_avail = uint64((uint64(0) == uint64(0)) ? 1 : 0)
                                comp_remaining = uint64(file_stat.m_comp_size)
                            }
                        } else {
                            var c2da_fresh78 : uint64 = uint64(0)
                            if (uint64(file_stat.m_comp_size) < uint64(MZ_ZIP_MAX_IO_BUF_SIZE)) {
                                c2da_fresh78 = file_stat.m_comp_size
                            } else {
                                c2da_fresh78 = uint64(MZ_ZIP_MAX_IO_BUF_SIZE)
                            }
                            read_buf_size = uint64(c2da_fresh78)
                            if (4 == 4 && uint64(read_buf_size) > uint64(2147483647)) {
                                return mz_zip_set_error(pZip_38, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INTERNAL_ERROR)))
                            } else {
                                pRead_buf = pZip_38.m_pAlloc(pZip_38.m_pAlloc_opaque, unsafe(reinterpret<size_t>(1)), read_buf_size)
                                if (unsafe(unsafe(reinterpret<uint64>(uint64(0) == uint64(0))) == unsafe(reinterpret<uint64>(uint64(pRead_buf) == uint64(0))))) {
                                    return mz_zip_set_error(pZip_38, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                                } else {
                                    read_buf_avail = uint64((uint64(0) == uint64(0)) ? 1 : 0)
                                    comp_remaining = uint64(file_stat.m_comp_size)
                                }
                            }
                        }
                        while (true) {
                            out_buf_size = uint64(file_stat.m_uncomp_size) - uint64(out_buf_ofs)
                            if (uint64(read_buf_avail) == uint64(0) && uint64(pZip_38.m_pState.m_pMem) == uint64(0)) {
                                var c2da_fresh79 : uint64 = uint64(0)
                                if (uint64(read_buf_size) < uint64(comp_remaining)) {
                                    c2da_fresh79 = read_buf_size
                                } else {
                                    c2da_fresh79 = comp_remaining
                                }
                                read_buf_avail = uint64(c2da_fresh79)
                                if (pZip_38.m_pRead(pZip_38.m_pIO_opaque, cur_file_ofs_1, pRead_buf, read_buf_avail) != unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(uint64(read_buf_avail) == uint64(0)))))) {
                                    status_7 = TINFL_STATUS_FAILED
                                    mz_zip_set_error(pZip_38, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_DECOMPRESSION_FAILED)))
                                    if (false) {
                                    }
                                    if (false) {
                                    }
                                } else {
                                    cur_file_ofs_1 = uint64(cur_file_ofs_1 + read_buf_avail)
                                    comp_remaining = uint64(comp_remaining - read_buf_avail)
                                    read_buf_ofs = uint64((uint64(0) == uint64(0)) ? 1 : 0)
                                }
                            }
                            in_buf_size_1 = unsafe(reinterpret<size_t>(read_buf_avail))
                            var c2da_fresh80 : int = int(0)
                            if (uint64(comp_remaining) != uint64(0)) {
                                c2da_fresh80 = TINFL_FLAG_HAS_MORE_INPUT
                            } else {
                                c2da_fresh80 = 0
                            }
                            status_7 = int(tinfl_decompress(unsafe(addr(inflator)), unsafe(pRead_buf + uint64(read_buf_ofs)), unsafe(addr(in_buf_size_1)), pBuf_7, unsafe(pBuf_7 + uint64(out_buf_ofs)), unsafe(addr(out_buf_size)), uint(int(TINFL_FLAG_USING_NON_WRAPPING_OUTPUT_BUF) | int(c2da_fresh80))))
                            read_buf_avail = uint64(read_buf_avail - in_buf_size_1)
                            read_buf_ofs = uint64(read_buf_ofs + in_buf_size_1)
                            out_buf_ofs = uint64(out_buf_ofs + out_buf_size)
                            if (int(status_7) == int(TINFL_STATUS_NEEDS_MORE_INPUT)) {
                                if (false) {
                                }
                            }
                        }
                        if (int(status_7) == int(TINFL_STATUS_DONE)) {
                            if (uint64(out_buf_ofs) != uint64(file_stat.m_uncomp_size)) {
                                mz_zip_set_error(pZip_38, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNEXPECTED_DECOMPRESSED_SIZE)))
                                status_7 = TINFL_STATUS_FAILED
                            } elif (mz_crc32(uint64(0), pBuf_7, file_stat.m_uncomp_size) != uint64(file_stat.m_crc32)) {
                                mz_zip_set_error(pZip_38, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_CRC_CHECK_FAILED)))
                                status_7 = TINFL_STATUS_FAILED
                            }
                        }
                        if (uint64(pZip_38.m_pState.m_pMem) == uint64(0) && uint64(pUser_read_buf_0) == uint64(0)) {
                            pZip_38.m_pFree(pZip_38.m_pAlloc_opaque, pRead_buf)
                        }
                        return int(status_7) == int(TINFL_STATUS_DONE)
                    }
                }
            }
        }
    }
}
[export]
def mz_zip_reader_extract_file_to_mem_no_alloc(var pZip_39 : mz_zip_archive?; var pFilename_2 : int8 const?; var pBuf_8 : uint64; var buf_size_1 : size_t; var flags_16 : uint; var pUser_read_buf_1 : uint64; var user_read_buf_size_1 : size_t) : int {
    var file_index_10 : uint = uint(0)
    if (uint64((mz_zip_reader_locate_file_v2(pZip_39, pFilename_2, null, flags_16, unsafe(addr(file_index_10) == uint64(0)))) ? 1 : 0) == uint64(0)) {
        return 0
    } else {
        return mz_zip_reader_extract_to_mem_no_alloc1(pZip_39, file_index_10, pBuf_8, buf_size_1, flags_16, pUser_read_buf_1, user_read_buf_size_1, null)
    }
}
[export]
def mz_zip_reader_extract_to_mem(var pZip_40 : mz_zip_archive?; var file_index_11 : uint; var pBuf_9 : uint64; var buf_size_2 : size_t; var flags_17 : uint) : int {
    return mz_zip_reader_extract_to_mem_no_alloc1(pZip_40, file_index_11, pBuf_9, buf_size_2, flags_17, uint64(0), unsafe(reinterpret<size_t>(0)), null)
}
[export]
def mz_zip_reader_extract_file_to_mem(var pZip_41 : mz_zip_archive?; var pFilename_3 : int8 const?; var pBuf_10 : uint64; var buf_size_3 : size_t; var flags_18 : uint) : int {
    return mz_zip_reader_extract_file_to_mem_no_alloc(pZip_41, pFilename_3, pBuf_10, buf_size_3, flags_18, uint64(0), unsafe(reinterpret<size_t>(0)))
}
[export]
def mz_zip_reader_extract_to_heap(var pZip_42 : mz_zip_archive?; var file_index_12 : uint; var pSize : size_t?; var flags_19 : uint) : uint64 {
    var file_stat_0 : mz_zip_archive_file_stat = mz_zip_archive_file_stat()
    var alloc_size : uint64 = uint64(0)
    var pBuf_11 : uint64 = uint64(0)
    if (pSize != null) {
        *pSize = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
    }
    if (uint64((mz_zip_reader_file_stat(pZip_42, file_index_12, unsafe(addr(file_stat_0) == uint64(0)))) ? 1 : 0) == uint64(0)) {
        return unsafe(unsafe(reinterpret<uint64>(uint64(0) == uint64(0))))
    } else {
        var c2da_fresh81 : uint64 = uint64(0)
        if (uint64(uint(flags_19) & uint(MZ_ZIP_FLAG_COMPRESSED_DATA)) != uint64(0)) {
            c2da_fresh81 = file_stat_0.m_comp_size
        } else {
            c2da_fresh81 = file_stat_0.m_uncomp_size
        }
        alloc_size = uint64(c2da_fresh81)
        if (4 == 4 && uint64(alloc_size) > uint64(2147483647)) {
            mz_zip_set_error(pZip_42, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INTERNAL_ERROR)))
            return unsafe(unsafe(reinterpret<uint64>(uint64(0) == uint64(0))))
        } else {
            pBuf_11 = pZip_42.m_pAlloc(pZip_42.m_pAlloc_opaque, unsafe(reinterpret<size_t>(1)), alloc_size)
            if (unsafe(unsafe(reinterpret<uint64>(uint64(0) == uint64(0))) == unsafe(reinterpret<uint64>(uint64(pBuf_11) == uint64(0))))) {
                mz_zip_set_error(pZip_42, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                return unsafe(unsafe(reinterpret<uint64>(uint64(0) == uint64(0))))
            } elif (uint64(mz_zip_reader_extract_to_mem_no_alloc1(pZip_42, file_index_12, pBuf_11, alloc_size, flags_19, uint64(0), unsafe(reinterpret<size_t>(0)), unsafe(addr(file_stat_0)))) == uint64(0)) {
                pZip_42.m_pFree(pZip_42.m_pAlloc_opaque, pBuf_11)
                return unsafe(unsafe(reinterpret<uint64>(uint64(0) == uint64(0))))
            } else {
                if (pSize != null) {
                    *pSize = unsafe(reinterpret<size_t>(alloc_size))
                }
                return unsafe(unsafe(reinterpret<uint64>(pBuf_11)))
            }
        }
    }
}
[export]
def mz_zip_reader_extract_file_to_heap(var pZip_43 : mz_zip_archive?; var pFilename_4 : int8 const?; var pSize_0 : size_t?; var flags_20 : uint) : uint64 {
    var file_index_13 : uint = uint(0)
    if (uint64((mz_zip_reader_locate_file_v2(pZip_43, pFilename_4, null, flags_20, unsafe(addr(file_index_13) == uint64(0)))) ? 1 : 0) == uint64(0)) {
        if (pSize_0 != null) {
            *pSize_0 = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
        }
        return unsafe(unsafe(reinterpret<uint64>(uint64(0x0) == uint64(0))))
    } else {
        return unsafe(unsafe(reinterpret<uint64>(mz_zip_reader_extract_to_heap(pZip_43, file_index_13, pSize_0, flags_20))))
    }
}
[export]
def mz_zip_reader_extract_to_callback(var pZip_44 : mz_zip_archive?; var file_index_14 : uint; var pCallback : mz_file_write_func; var pOpaque_0 : uint64; var flags_21 : uint) : int {
    var status_8 : int = int(0)
    var file_crc32 : uint = uint(0)
    var read_buf_size_0 : uint64 = uint64(0)
    var read_buf_ofs_0 : uint64 = uint64(0)
    var read_buf_avail_0 : uint64 = uint64(0)
    var comp_remaining_0 : uint64 = uint64(0)
    var out_buf_ofs_0 : uint64 = uint64(0)
    var cur_file_ofs_2 : uint64 = uint64(0)
    var file_stat_1 : mz_zip_archive_file_stat = mz_zip_archive_file_stat()
    var pRead_buf_0 : uint64 = uint64(0)
    var pWrite_buf : uint64 = uint64(0)
    var local_header_u32_0 : array<uint> = []
    var pLocal_header_0 : uint8? = null
    var inflator_0 : tinfl_decompressor_tag = tinfl_decompressor_tag()
    var pWrite_buf_cur : uint8? = null
    var in_buf_size_2 : size_t = unsafe(reinterpret<size_t>(0))
    var out_buf_size_0 : size_t = unsafe(reinterpret<size_t>(0))
    status_8 = TINFL_STATUS_DONE
    file_crc32 = uint(0)
    read_buf_ofs_0 = uint64(0)
    out_buf_ofs_0 = uint64(0)
    pRead_buf_0 = uint64(0)
    pWrite_buf = uint64(0)
    pLocal_header_0 = unsafe(addr(local_header_u32_0[0]))
    if (pZip_44 == null || pZip_44.m_pState == null || pCallback == null || pZip_44.m_pRead == null) {
        return mz_zip_set_error(pZip_44, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
    } elif (uint64((mz_zip_reader_file_stat(pZip_44, file_index_14, unsafe(addr(file_stat_1) == uint64(0)))) ? 1 : 0) == uint64(0)) {
        return 0
    } elif (uint64(file_stat_1.m_is_directory) != uint64(0) || uint64(file_stat_1.m_comp_size) == uint64(0)) {
        return 1
    } elif (uint64(int(file_stat_1.m_bit_flag) & (int(MZ_ZIP_GENERAL_PURPOSE_BIT_FLAG_IS_ENCRYPTED) | int(MZ_ZIP_GENERAL_PURPOSE_BIT_FLAG_USES_STRONG_ENCRYPTION) | int(MZ_ZIP_GENERAL_PURPOSE_BIT_FLAG_COMPRESSED_PATCH_FLAG))) != uint64(0)) {
        return mz_zip_set_error(pZip_44, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNSUPPORTED_ENCRYPTION)))
    } elif (uint64(uint(flags_21) & uint(MZ_ZIP_FLAG_COMPRESSED_DATA)) == uint64(0) && uint64((int(file_stat_1.m_method) == int(0)) ? 1 : 0) != uint64(0) && int(file_stat_1.m_method) != 8) {
        return mz_zip_set_error(pZip_44, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNSUPPORTED_METHOD)))
    } else {
        cur_file_ofs_2 = uint64(file_stat_1.m_local_header_ofs)
        if (pZip_44.m_pRead(pZip_44.m_pIO_opaque, cur_file_ofs_2, unsafe(unsafe(reinterpret<uint64>(pLocal_header_0))), unsafe(reinterpret<size_t>(MZ_ZIP_LOCAL_DIR_HEADER_SIZE))) != unsafe(reinterpret<size_t>(MZ_ZIP_LOCAL_DIR_HEADER_SIZE))) {
            return mz_zip_set_error(pZip_44, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_READ_FAILED)))
        } elif ((uint(((unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pLocal_header_0) == uint(0)))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pLocal_header_0) == uint(0)))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pLocal_header_0) == uint(0)))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pLocal_header_0) == uint(0)))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)) != uint(MZ_ZIP_LOCAL_DIR_HEADER_SIG)) {
            return mz_zip_set_error(pZip_44, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
        } else {
            cur_file_ofs_2 = uint64((cur_file_ofs_2 + (uint64(MZ_ZIP_LOCAL_DIR_HEADER_SIZE) + (uint64(uint(((unsafe(unsafe(pLocal_header_0 + int(MZ_ZIP_LDH_FILENAME_LEN_OFS) == uint64(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pLocal_header_0 + int(MZ_ZIP_LDH_FILENAME_LEN_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8)) + uint64(uint(((unsafe(unsafe(pLocal_header_0 + int(MZ_ZIP_LDH_EXTRA_LEN_OFS) == uint(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pLocal_header_0 + int(MZ_ZIP_LDH_EXTRA_LEN_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8))))) ? 1 : 0)
            if (uint64(cur_file_ofs_2) + uint64(file_stat_1.m_comp_size) > uint64(pZip_44.m_archive_size)) {
                return mz_zip_set_error(pZip_44, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
            } else {
                if (uint64(pZip_44.m_pState.m_pMem) != uint64(0)) {
                    pRead_buf_0 = unsafe(unsafe(reinterpret<uint64>(unsafe(pZip_44.m_pState.m_pMem + uint64(cur_file_ofs_2)))))
                    read_buf_avail_0 = uint64(file_stat_1.m_comp_size)
                    read_buf_size_0 = read_buf_avail_0
                    comp_remaining_0 = uint64((uint64(0) == uint64(0)) ? 1 : 0)
                } else {
                    var c2da_fresh82 : uint64 = uint64(0)
                    if (uint64(file_stat_1.m_comp_size) < uint64(MZ_ZIP_MAX_IO_BUF_SIZE)) {
                        c2da_fresh82 = file_stat_1.m_comp_size
                    } else {
                        c2da_fresh82 = uint64(MZ_ZIP_MAX_IO_BUF_SIZE)
                    }
                    read_buf_size_0 = uint64(c2da_fresh82)
                    pRead_buf_0 = pZip_44.m_pAlloc(pZip_44.m_pAlloc_opaque, unsafe(reinterpret<size_t>(1)), read_buf_size_0)
                    if (unsafe(unsafe(reinterpret<uint64>(uint64(0) == uint64(0))) == unsafe(reinterpret<uint64>(uint64(pRead_buf_0) == uint64(0))))) {
                        return mz_zip_set_error(pZip_44, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                    } else {
                        read_buf_avail_0 = uint64((uint64(0) == uint64(0)) ? 1 : 0)
                        comp_remaining_0 = uint64(file_stat_1.m_comp_size)
                    }
                }
                if (uint64(uint(flags_21) & uint(MZ_ZIP_FLAG_COMPRESSED_DATA)) != uint64(0) || uint64(file_stat_1.m_method) == uint64(0)) {
                    if (uint64(pZip_44.m_pState.m_pMem) != uint64(0)) {
                        if (4 == 4 && uint64(file_stat_1.m_comp_size) > uint64(0xffffffff)) {
                            return mz_zip_set_error(pZip_44, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INTERNAL_ERROR)))
                        } else {
                            if (pCallback(pOpaque_0, out_buf_ofs_0, pRead_buf_0, file_stat_1.m_comp_size) != unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(uint64(file_stat_1.m_comp_size) == uint64(0)))))) {
                                mz_zip_set_error(pZip_44, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_WRITE_CALLBACK_FAILED)))
                                status_8 = TINFL_STATUS_FAILED
                            } elif (uint64(uint(flags_21) & uint(MZ_ZIP_FLAG_COMPRESSED_DATA)) == uint64(0)) {
                                file_crc32 = uint(uint(mz_crc32(uint64(file_crc32), pRead_buf_0, file_stat_1.m_comp_size)))
                            }
                            cur_file_ofs_2 = uint64(cur_file_ofs_2 + file_stat_1.m_comp_size)
                            out_buf_ofs_0 = uint64(out_buf_ofs_0 + file_stat_1.m_comp_size)
                            comp_remaining_0 = uint64((uint64(0) == uint64(0)) ? 1 : 0)
                        }
                    } else {
                        while (true) {
                            if (!(uint64(comp_remaining_0) != uint64(0))) {
                                if (false) {
                                }
                            }
                            var c2da_fresh83 : uint64 = uint64(0)
                            if (uint64(read_buf_size_0) < uint64(comp_remaining_0)) {
                                c2da_fresh83 = read_buf_size_0
                            } else {
                                c2da_fresh83 = comp_remaining_0
                            }
                            read_buf_avail_0 = uint64(c2da_fresh83)
                            if (pZip_44.m_pRead(pZip_44.m_pIO_opaque, cur_file_ofs_2, pRead_buf_0, read_buf_avail_0) != unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(uint64(read_buf_avail_0) == uint64(0)))))) {
                                mz_zip_set_error(pZip_44, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_READ_FAILED)))
                                status_8 = TINFL_STATUS_FAILED
                                if (false) {
                                }
                                if (false) {
                                }
                            } else {
                                if (uint64(uint(flags_21) & uint(MZ_ZIP_FLAG_COMPRESSED_DATA)) == uint64(0)) {
                                    file_crc32 = uint(uint(mz_crc32(uint64(file_crc32), pRead_buf_0, read_buf_avail_0)))
                                }
                                if (pCallback(pOpaque_0, out_buf_ofs_0, pRead_buf_0, read_buf_avail_0) != unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(uint64(read_buf_avail_0) == uint64(0)))))) {
                                    mz_zip_set_error(pZip_44, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_WRITE_CALLBACK_FAILED)))
                                    status_8 = TINFL_STATUS_FAILED
                                    if (false) {
                                    }
                                    if (false) {
                                    }
                                } else {
                                    cur_file_ofs_2 = uint64(cur_file_ofs_2 + read_buf_avail_0)
                                    out_buf_ofs_0 = uint64(out_buf_ofs_0 + read_buf_avail_0)
                                    comp_remaining_0 = uint64(comp_remaining_0 - read_buf_avail_0)
                                }
                            }
                        }
                    }
                } else {
                    while (true) {
                        unsafe(addr(inflator_0)).m_state = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
                        if (!(uint64(0) != uint64(0))) {
                            if (false) {
                            }
                        }
                    }
                    pWrite_buf = pZip_44.m_pAlloc(pZip_44.m_pAlloc_opaque, unsafe(reinterpret<size_t>(1)), unsafe(reinterpret<size_t>(32768)))
                    if (unsafe(unsafe(reinterpret<uint64>(uint64(0) == uint64(0))) == unsafe(reinterpret<uint64>(uint64(pWrite_buf) == uint64(0))))) {
                        mz_zip_set_error(pZip_44, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                        status_8 = TINFL_STATUS_FAILED
                    } else {
                        while (true) {
                            pWrite_buf_cur = unsafe(pWrite_buf + (uint64(out_buf_ofs_0) & uint64(32768 - 1)))
                            out_buf_size_0 = uint64(32768) - (uint64(out_buf_ofs_0) & uint64(32768 - 1))
                            if (uint64(read_buf_avail_0) == uint64(0) && uint64(pZip_44.m_pState.m_pMem) == uint64(0)) {
                                var c2da_fresh84 : uint64 = uint64(0)
                                if (uint64(read_buf_size_0) < uint64(comp_remaining_0)) {
                                    c2da_fresh84 = read_buf_size_0
                                } else {
                                    c2da_fresh84 = comp_remaining_0
                                }
                                read_buf_avail_0 = uint64(c2da_fresh84)
                                if (pZip_44.m_pRead(pZip_44.m_pIO_opaque, cur_file_ofs_2, pRead_buf_0, read_buf_avail_0) != unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(uint64(read_buf_avail_0) == uint64(0)))))) {
                                    mz_zip_set_error(pZip_44, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_READ_FAILED)))
                                    status_8 = TINFL_STATUS_FAILED
                                    if (false) {
                                    }
                                    if (false) {
                                    }
                                } else {
                                    cur_file_ofs_2 = uint64(cur_file_ofs_2 + read_buf_avail_0)
                                    comp_remaining_0 = uint64(comp_remaining_0 - read_buf_avail_0)
                                    read_buf_ofs_0 = uint64((uint64(0) == uint64(0)) ? 1 : 0)
                                }
                            }
                            in_buf_size_2 = unsafe(reinterpret<size_t>(read_buf_avail_0))
                            var c2da_fresh85 : int = int(0)
                            if (uint64(comp_remaining_0) != uint64(0)) {
                                c2da_fresh85 = TINFL_FLAG_HAS_MORE_INPUT
                            } else {
                                c2da_fresh85 = 0
                            }
                            status_8 = int(tinfl_decompress(unsafe(addr(inflator_0)), unsafe(pRead_buf_0 + uint64(read_buf_ofs_0)), unsafe(addr(in_buf_size_2)), pWrite_buf, pWrite_buf_cur, unsafe(addr(out_buf_size_0)), uint(c2da_fresh85)))
                            read_buf_avail_0 = uint64(read_buf_avail_0 - in_buf_size_2)
                            read_buf_ofs_0 = uint64(read_buf_ofs_0 + in_buf_size_2)
                            if (uint64(out_buf_size_0) != uint64(0)) {
                                if (pCallback(pOpaque_0, out_buf_ofs_0, unsafe(unsafe(reinterpret<uint64>(pWrite_buf_cur))), out_buf_size_0) != unsafe(reinterpret<size_t>(out_buf_size_0))) {
                                    mz_zip_set_error(pZip_44, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_WRITE_CALLBACK_FAILED)))
                                    status_8 = TINFL_STATUS_FAILED
                                    if (false) {
                                    }
                                    if (false) {
                                    }
                                } else {
                                    file_crc32 = uint(uint(mz_crc32(uint64(file_crc32), pWrite_buf_cur, out_buf_size_0)))
                                    out_buf_ofs_0 = uint64(out_buf_ofs_0 + out_buf_size_0)
                                    if (uint64(out_buf_ofs_0) > uint64(file_stat_1.m_uncomp_size)) {
                                        mz_zip_set_error(pZip_44, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_DECOMPRESSION_FAILED)))
                                        status_8 = TINFL_STATUS_FAILED
                                        if (false) {
                                        }
                                        if (false) {
                                        }
                                    }
                                }
                            }
                            if (int(status_8) == int(TINFL_STATUS_NEEDS_MORE_INPUT) || int(status_8) == int(TINFL_STATUS_HAS_MORE_OUTPUT)) {
                                if (false) {
                                }
                            }
                        }
                    }
                }
                if (int(status_8) == int(TINFL_STATUS_DONE) && uint64(uint(flags_21) & uint(MZ_ZIP_FLAG_COMPRESSED_DATA)) == uint64(0)) {
                    if (uint64(out_buf_ofs_0) != uint64(file_stat_1.m_uncomp_size)) {
                        mz_zip_set_error(pZip_44, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNEXPECTED_DECOMPRESSED_SIZE)))
                        status_8 = TINFL_STATUS_FAILED
                    } elif (uint(file_crc32) != uint(file_stat_1.m_crc32)) {
                        mz_zip_set_error(pZip_44, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_DECOMPRESSION_FAILED)))
                        status_8 = TINFL_STATUS_FAILED
                    }
                }
                if (uint64(pZip_44.m_pState.m_pMem) == uint64(0)) {
                    pZip_44.m_pFree(pZip_44.m_pAlloc_opaque, pRead_buf_0)
                }
                if (uint64(pWrite_buf) != uint64(0)) {
                    pZip_44.m_pFree(pZip_44.m_pAlloc_opaque, pWrite_buf)
                }
                return int(status_8) == int(TINFL_STATUS_DONE)
            }
        }
    }
}
[export]
def mz_zip_reader_extract_file_to_callback(var pZip_45 : mz_zip_archive?; var pFilename_5 : int8 const?; var pCallback_0 : mz_file_write_func; var pOpaque_1 : uint64; var flags_22 : uint) : int {
    var file_index_15 : uint = uint(0)
    if (uint64((mz_zip_reader_locate_file_v2(pZip_45, pFilename_5, null, flags_22, unsafe(addr(file_index_15) == uint64(0)))) ? 1 : 0) == uint64(0)) {
        return 0
    } else {
        return mz_zip_reader_extract_to_callback(pZip_45, file_index_15, pCallback_0, pOpaque_1, flags_22)
    }
}
[export]
def mz_zip_reader_extract_iter_new(var pZip_46 : mz_zip_archive?; var file_index_16 : uint; var flags_23 : uint) : mz_zip_reader_extract_iter_state? {
    var pState_3 : mz_zip_reader_extract_iter_state? = null
    var local_header_u32_1 : array<uint> = []
    var pLocal_header_1 : uint8? = null
    pLocal_header_1 = unsafe(addr(local_header_u32_1[0]))
    if (pZip_46 == null || pZip_46.m_pState == null) {
        return unsafe(unsafe(reinterpret<mz_zip_reader_extract_iter_state?>(null)))
    } else {
        pState_3 = unsafe(unsafe(reinterpret<mz_zip_reader_extract_iter_state?>(pZip_46.m_pAlloc(pZip_46.m_pAlloc_opaque, unsafe(reinterpret<size_t>(1)), 4))))
        if (pState_3 == null) {
            mz_zip_set_error(pZip_46, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
            return unsafe(unsafe(reinterpret<mz_zip_reader_extract_iter_state?>(null)))
        } elif (uint64((mz_zip_reader_file_stat(pZip_46, file_index_16, unsafe(addr(pState_3.file_stat) == uint64(0)))) ? 1 : 0) == uint64(0)) {
            pZip_46.m_pFree(pZip_46.m_pAlloc_opaque, unsafe(unsafe(reinterpret<uint64>(pState_3))))
            return unsafe(unsafe(reinterpret<mz_zip_reader_extract_iter_state?>(null)))
        } elif (uint64(int(pState_3.file_stat.m_bit_flag) & (int(MZ_ZIP_GENERAL_PURPOSE_BIT_FLAG_IS_ENCRYPTED) | int(MZ_ZIP_GENERAL_PURPOSE_BIT_FLAG_USES_STRONG_ENCRYPTION) | int(MZ_ZIP_GENERAL_PURPOSE_BIT_FLAG_COMPRESSED_PATCH_FLAG))) != uint64(0)) {
            mz_zip_set_error(pZip_46, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNSUPPORTED_ENCRYPTION)))
            pZip_46.m_pFree(pZip_46.m_pAlloc_opaque, unsafe(unsafe(reinterpret<uint64>(pState_3))))
            return unsafe(unsafe(reinterpret<mz_zip_reader_extract_iter_state?>(null)))
        } elif (uint64(uint(flags_23) & uint(MZ_ZIP_FLAG_COMPRESSED_DATA)) == uint64(0) && uint64((int(pState_3.file_stat.m_method) == int(0)) ? 1 : 0) != uint64(0) && int(pState_3.file_stat.m_method) != 8) {
            mz_zip_set_error(pZip_46, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNSUPPORTED_METHOD)))
            pZip_46.m_pFree(pZip_46.m_pAlloc_opaque, unsafe(unsafe(reinterpret<uint64>(pState_3))))
            return unsafe(unsafe(reinterpret<mz_zip_reader_extract_iter_state?>(null)))
        } else {
            pState_3.pZip = unsafe(unsafe(reinterpret<mz_zip_archive?>(pZip_46)))
            pState_3.flags = uint(flags_23)
            pState_3.status = TINFL_STATUS_DONE
            pState_3.file_crc32 = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
            pState_3.read_buf_ofs = uint64((uint64(0) == uint64(0)) ? 1 : 0)
            pState_3.out_buf_ofs = uint64((uint64(0) == uint64(0)) ? 1 : 0)
            pState_3.pRead_buf = uint64(0)
            pState_3.pWrite_buf = uint64(0)
            pState_3.out_blk_remain = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
            pState_3.cur_file_ofs = uint64(pState_3.file_stat.m_local_header_ofs)
            if (pZip_46.m_pRead(pZip_46.m_pIO_opaque, pState_3.cur_file_ofs, unsafe(unsafe(reinterpret<uint64>(pLocal_header_1))), unsafe(reinterpret<size_t>(MZ_ZIP_LOCAL_DIR_HEADER_SIZE))) != unsafe(reinterpret<size_t>(MZ_ZIP_LOCAL_DIR_HEADER_SIZE))) {
                mz_zip_set_error(pZip_46, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_READ_FAILED)))
                pZip_46.m_pFree(pZip_46.m_pAlloc_opaque, unsafe(unsafe(reinterpret<uint64>(pState_3))))
                return unsafe(unsafe(reinterpret<mz_zip_reader_extract_iter_state?>(null)))
            } elif ((uint(((unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pLocal_header_1) == uint(0)))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pLocal_header_1) == uint(0)))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pLocal_header_1) == uint(0)))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pLocal_header_1) == uint(0)))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)) != uint(MZ_ZIP_LOCAL_DIR_HEADER_SIG)) {
                mz_zip_set_error(pZip_46, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
                pZip_46.m_pFree(pZip_46.m_pAlloc_opaque, unsafe(unsafe(reinterpret<uint64>(pState_3))))
                return unsafe(unsafe(reinterpret<mz_zip_reader_extract_iter_state?>(null)))
            } else {
                pState_3.cur_file_ofs = uint64((pState_3.cur_file_ofs + (uint64(MZ_ZIP_LOCAL_DIR_HEADER_SIZE) + (uint64(uint(((unsafe(unsafe(pLocal_header_1 + int(MZ_ZIP_LDH_FILENAME_LEN_OFS) == uint64(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pLocal_header_1 + int(MZ_ZIP_LDH_FILENAME_LEN_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8)) + uint64(uint(((unsafe(unsafe(pLocal_header_1 + int(MZ_ZIP_LDH_EXTRA_LEN_OFS) == uint(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pLocal_header_1 + int(MZ_ZIP_LDH_EXTRA_LEN_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8))))) ? 1 : 0)
                if (uint64(pState_3.cur_file_ofs) + uint64(pState_3.file_stat.m_comp_size) > uint64(pZip_46.m_archive_size)) {
                    mz_zip_set_error(pZip_46, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
                    pZip_46.m_pFree(pZip_46.m_pAlloc_opaque, unsafe(unsafe(reinterpret<uint64>(pState_3))))
                    return unsafe(unsafe(reinterpret<mz_zip_reader_extract_iter_state?>(null)))
                } else {
                    if (uint64(pZip_46.m_pState.m_pMem) != uint64(0)) {
                        pState_3.pRead_buf = unsafe(unsafe(reinterpret<uint64>(unsafe(pZip_46.m_pState.m_pMem + uint64(pState_3.cur_file_ofs)))))
                        pState_3.read_buf_avail = uint64(pState_3.file_stat.m_comp_size)
                        pState_3.read_buf_size = pState_3.read_buf_avail
                        pState_3.comp_remaining = uint64(pState_3.file_stat.m_comp_size)
                    } else {
                        if (!(uint64(uint(flags_23) & uint(MZ_ZIP_FLAG_COMPRESSED_DATA)) != uint64(0) || uint64(pState_3.file_stat.m_method) == uint64(0))) {
                            var c2da_fresh86 : uint64 = uint64(0)
                            if (uint64(pState_3.file_stat.m_comp_size) < uint64(MZ_ZIP_MAX_IO_BUF_SIZE)) {
                                c2da_fresh86 = pState_3.file_stat.m_comp_size
                            } else {
                                c2da_fresh86 = uint64(MZ_ZIP_MAX_IO_BUF_SIZE)
                            }
                            pState_3.read_buf_size = uint64(c2da_fresh86)
                            pState_3.pRead_buf = pZip_46.m_pAlloc(pZip_46.m_pAlloc_opaque, unsafe(reinterpret<size_t>(1)), pState_3.read_buf_size)
                            if (unsafe(unsafe(reinterpret<uint64>(uint64(0) == uint64(0))) == unsafe(reinterpret<uint64>(uint64(pState_3.pRead_buf) == uint64(0))))) {
                                mz_zip_set_error(pZip_46, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                                pZip_46.m_pFree(pZip_46.m_pAlloc_opaque, unsafe(unsafe(reinterpret<uint64>(pState_3))))
                                return unsafe(unsafe(reinterpret<mz_zip_reader_extract_iter_state?>(null)))
                            }
                        } else {
                            pState_3.read_buf_size = uint64((uint64(0) == uint64(0)) ? 1 : 0)
                        }
                        pState_3.read_buf_avail = uint64((uint64(0) == uint64(0)) ? 1 : 0)
                        pState_3.comp_remaining = uint64(pState_3.file_stat.m_comp_size)
                    }
                    if (!(uint64(uint(flags_23) & uint(MZ_ZIP_FLAG_COMPRESSED_DATA)) != uint64(0) || uint64(pState_3.file_stat.m_method) == uint64(0))) {
                        while (true) {
                            unsafe(addr(pState_3.inflator)).m_state = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
                            if (!(uint64(0) != uint64(0))) {
                                if (false) {
                                }
                            }
                        }
                        pState_3.pWrite_buf = pZip_46.m_pAlloc(pZip_46.m_pAlloc_opaque, unsafe(reinterpret<size_t>(1)), unsafe(reinterpret<size_t>(32768)))
                        if (unsafe(unsafe(reinterpret<uint64>(uint64(0) == uint64(0))) == unsafe(reinterpret<uint64>(uint64(pState_3.pWrite_buf) == uint64(0))))) {
                            mz_zip_set_error(pZip_46, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                            if (uint64(pState_3.pRead_buf) != uint64(0)) {
                                pZip_46.m_pFree(pZip_46.m_pAlloc_opaque, pState_3.pRead_buf)
                            }
                            pZip_46.m_pFree(pZip_46.m_pAlloc_opaque, unsafe(unsafe(reinterpret<uint64>(pState_3))))
                            return unsafe(unsafe(reinterpret<mz_zip_reader_extract_iter_state?>(null)))
                        }
                    }
                    return unsafe(unsafe(reinterpret<mz_zip_reader_extract_iter_state?>(pState_3)))
                }
            }
        }
    }
}
[export]
def mz_zip_reader_extract_file_iter_new(var pZip_47 : mz_zip_archive?; var pFilename_6 : int8 const?; var flags_24 : uint) : mz_zip_reader_extract_iter_state? {
    var file_index_17 : uint = uint(0)
    if (uint64((mz_zip_reader_locate_file_v2(pZip_47, pFilename_6, null, flags_24, unsafe(addr(file_index_17) == uint64(0)))) ? 1 : 0) == uint64(0)) {
        return unsafe(unsafe(reinterpret<mz_zip_reader_extract_iter_state?>(null)))
    } else {
        return unsafe(unsafe(reinterpret<mz_zip_reader_extract_iter_state?>(mz_zip_reader_extract_iter_new(pZip_47, file_index_17, flags_24))))
    }
}
[export]
def mz_zip_reader_extract_iter_read(var pState_4 : mz_zip_reader_extract_iter_state?; var pvBuf : uint64; var buf_size_4 : size_t) : size_t {
    var copied_to_caller : size_t = unsafe(reinterpret<size_t>(0))
    var pWrite_buf_cur_0 : uint8? = null
    var in_buf_size_3 : size_t = unsafe(reinterpret<size_t>(0))
    var out_buf_size_1 : size_t = unsafe(reinterpret<size_t>(0))
    var to_copy : size_t = unsafe(reinterpret<size_t>(0))
    copied_to_caller = unsafe(reinterpret<size_t>(0))
    if (pState_4 == null || pState_4.pZip == null || pState_4.pZip.m_pState == null || uint64(pvBuf) == uint64(0)) {
        return unsafe(reinterpret<size_t>(0))
    } else {
        if (uint64(uint(pState_4.flags) & uint(MZ_ZIP_FLAG_COMPRESSED_DATA)) != uint64(0) || uint64(pState_4.file_stat.m_method) == uint64(0)) {
            var c2da_fresh87 : uint64 = uint64(0)
            if (unsafe(reinterpret<size_t>(buf_size_4)) < unsafe(reinterpret<size_t>(uint64(pState_4.comp_remaining) == uint64(0)))) {
                c2da_fresh87 = buf_size_4
            } else {
                c2da_fresh87 = pState_4.comp_remaining
            }
            copied_to_caller = unsafe(reinterpret<size_t>(c2da_fresh87))
            if (uint64(pState_4.pZip.m_pState.m_pMem) != uint64(0)) {
                memcpy(pvBuf, pState_4.pRead_buf, uint64(copied_to_caller))
                pState_4.pRead_buf = unsafe(unsafe(reinterpret<uint64>(unsafe(pState_4.pRead_buf + unsafe(reinterpret<size_t>(copied_to_caller))))))
            } elif (pState_4.pZip.m_pRead(pState_4.pZip.m_pIO_opaque, pState_4.cur_file_ofs, pvBuf, copied_to_caller) != unsafe(reinterpret<size_t>(copied_to_caller))) {
                mz_zip_set_error(pState_4.pZip, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_READ_FAILED)))
                pState_4.status = TINFL_STATUS_FAILED
                copied_to_caller = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
            }
            if (uint64(uint(pState_4.flags) & uint(MZ_ZIP_FLAG_COMPRESSED_DATA)) == uint64(0)) {
                pState_4.file_crc32 = uint(uint(mz_crc32(uint64(pState_4.file_crc32), pvBuf, copied_to_caller)))
            }
            pState_4.cur_file_ofs = uint64(pState_4.cur_file_ofs + copied_to_caller)
            pState_4.out_buf_ofs = uint64(pState_4.out_buf_ofs + copied_to_caller)
            pState_4.comp_remaining = uint64(pState_4.comp_remaining - copied_to_caller)
        } else {
            while (true) {
                pWrite_buf_cur_0 = unsafe(pState_4.pWrite_buf + (uint64(pState_4.out_buf_ofs) & uint64(32768 - 1)))
                out_buf_size_1 = uint64(32768) - (uint64(pState_4.out_buf_ofs) & uint64(32768 - 1))
                if (uint64(pState_4.out_blk_remain) == uint64(0)) {
                    if (uint64(pState_4.read_buf_avail) == uint64(0) && uint64(pState_4.pZip.m_pState.m_pMem) == uint64(0)) {
                        var c2da_fresh88 : uint64 = uint64(0)
                        if (uint64(pState_4.read_buf_size) < uint64(pState_4.comp_remaining)) {
                            c2da_fresh88 = pState_4.read_buf_size
                        } else {
                            c2da_fresh88 = pState_4.comp_remaining
                        }
                        pState_4.read_buf_avail = uint64(c2da_fresh88)
                        if (pState_4.pZip.m_pRead(pState_4.pZip.m_pIO_opaque, pState_4.cur_file_ofs, pState_4.pRead_buf, pState_4.read_buf_avail) != unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(uint64(pState_4.read_buf_avail) == uint64(0)))))) {
                            mz_zip_set_error(pState_4.pZip, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_READ_FAILED)))
                            pState_4.status = TINFL_STATUS_FAILED
                            if (false) {
                            }
                            if (false) {
                            }
                        } else {
                            pState_4.cur_file_ofs = uint64(pState_4.cur_file_ofs + pState_4.read_buf_avail)
                            pState_4.comp_remaining = uint64(pState_4.comp_remaining - pState_4.read_buf_avail)
                            pState_4.read_buf_ofs = uint64((uint64(0) == uint64(0)) ? 1 : 0)
                        }
                    }
                    in_buf_size_3 = unsafe(reinterpret<size_t>(pState_4.read_buf_avail))
                    var c2da_fresh89 : int = int(0)
                    if (uint64(pState_4.comp_remaining) != uint64(0)) {
                        c2da_fresh89 = TINFL_FLAG_HAS_MORE_INPUT
                    } else {
                        c2da_fresh89 = 0
                    }
                    pState_4.status = int(tinfl_decompress(unsafe(addr(pState_4.inflator)), unsafe(pState_4.pRead_buf + uint64(pState_4.read_buf_ofs)), unsafe(addr(in_buf_size_3)), pState_4.pWrite_buf, pWrite_buf_cur_0, unsafe(addr(out_buf_size_1)), uint(c2da_fresh89)))
                    pState_4.read_buf_avail = uint64(pState_4.read_buf_avail - in_buf_size_3)
                    pState_4.read_buf_ofs = uint64(pState_4.read_buf_ofs + in_buf_size_3)
                    pState_4.out_blk_remain = unsafe(reinterpret<size_t>(out_buf_size_1))
                }
                if (uint64(pState_4.out_blk_remain) != uint64(0)) {
                    var c2da_fresh90 : size_t = unsafe(reinterpret<size_t>(0))
                    if (unsafe(reinterpret<size_t>(buf_size_4)) - unsafe(reinterpret<size_t>(copied_to_caller)) < unsafe(reinterpret<size_t>(pState_4.out_blk_remain))) {
                        c2da_fresh90 = unsafe(reinterpret<size_t>(buf_size_4)) - unsafe(reinterpret<size_t>(copied_to_caller))
                    } else {
                        c2da_fresh90 = pState_4.out_blk_remain
                    }
                    to_copy = c2da_fresh90
                    memcpy(unsafe(unsafe(reinterpret<uint64>(unsafe(pvBuf + unsafe(reinterpret<size_t>(copied_to_caller)))))), unsafe(unsafe(reinterpret<uint64>(pWrite_buf_cur_0))), uint64(to_copy))
                    pState_4.file_crc32 = uint(uint(mz_crc32(uint64(pState_4.file_crc32), pWrite_buf_cur_0, to_copy)))
                    pState_4.out_blk_remain = unsafe(reinterpret<size_t>(pState_4.out_blk_remain - to_copy))
                    pState_4.out_buf_ofs = uint64(pState_4.out_buf_ofs + to_copy)
                    if (uint64(pState_4.out_buf_ofs) > uint64(pState_4.file_stat.m_uncomp_size)) {
                        mz_zip_set_error(pState_4.pZip, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_DECOMPRESSION_FAILED)))
                        pState_4.status = TINFL_STATUS_FAILED
                        if (false) {
                        }
                        if (false) {
                        }
                    } else {
                        copied_to_caller = unsafe(reinterpret<size_t>(copied_to_caller + to_copy))
                    }
                }
                if (!unsafe(reinterpret<size_t>(copied_to_caller)) < unsafe(reinterpret<size_t>(buf_size_4)) && (int(pState_4.status) == int(TINFL_STATUS_NEEDS_MORE_INPUT) || int(pState_4.status) == int(TINFL_STATUS_HAS_MORE_OUTPUT)) ){
                    if (false) {
                    }
                }
            }
        }
        return copied_to_caller
    }
}
[export]
def mz_zip_reader_extract_iter_free(var pState_5 : mz_zip_reader_extract_iter_state?) : int {
    var status_9 : int = int(0)
    if (pState_5 == null || pState_5.pZip == null || pState_5.pZip.m_pState == null) {
        return 0
    } else {
        if (int(pState_5.status) == int(TINFL_STATUS_DONE) && uint64(uint(pState_5.flags) & uint(MZ_ZIP_FLAG_COMPRESSED_DATA)) == uint64(0)) {
            if (uint64(pState_5.out_buf_ofs) != uint64(pState_5.file_stat.m_uncomp_size)) {
                mz_zip_set_error(pState_5.pZip, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNEXPECTED_DECOMPRESSED_SIZE)))
                pState_5.status = TINFL_STATUS_FAILED
            } elif (uint(pState_5.file_crc32) != uint(pState_5.file_stat.m_crc32)) {
                mz_zip_set_error(pState_5.pZip, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_DECOMPRESSION_FAILED)))
                pState_5.status = TINFL_STATUS_FAILED
            }
        }
        if (uint64(pState_5.pZip.m_pState.m_pMem) == uint64(0)) {
            pState_5.pZip.m_pFree(pState_5.pZip.m_pAlloc_opaque, pState_5.pRead_buf)
        }
        if (uint64(pState_5.pWrite_buf) != uint64(0)) {
            pState_5.pZip.m_pFree(pState_5.pZip.m_pAlloc_opaque, pState_5.pWrite_buf)
        }
        status_9 = pState_5.status
        pState_5.pZip.m_pFree(pState_5.pZip.m_pAlloc_opaque, unsafe(unsafe(reinterpret<uint64>(pState_5))))
        return int(status_9) == int(TINFL_STATUS_DONE)
    }
}
[export]
def mz_zip_validate_file(var pZip_48 : mz_zip_archive?; var file_index_18 : uint; var flags_25 : uint) : int {
    var file_stat_2 : mz_zip_archive_file_stat = mz_zip_archive_file_stat()
    var pState_6 : mz_zip_internal_state_tag? = null
    var pCentral_dir_header_0 : uint8 const? = null
    var found_zip64_ext_data_in_cdir : int = int(0)
    var found_zip64_ext_data_in_ldir : int = int(0)
    var local_header_u32_2 : array<uint> = []
    var pLocal_header_2 : uint8? = null
    var local_header_ofs_0 : uint64 = uint64(0)
    var local_header_filename_len : uint = uint(0)
    var local_header_extra_len : uint = uint(0)
    var local_header_crc32 : uint = uint(0)
    var local_header_comp_size : uint64 = uint64(0)
    var local_header_uncomp_size : uint64 = uint64(0)
    var uncomp_crc32 : uint = uint(0)
    var has_data_descriptor : int = int(0)
    var local_header_bit_flags : uint = uint(0)
    var file_data_array : mz_zip_array = mz_zip_array()
    var extra_size_remaining_1 : uint = uint(0)
    var pExtra_data_1 : uint8 const? = null
    var field_id_1 : uint = uint(0)
    var field_data_size_1 : uint = uint(0)
    var field_total_size : uint = uint(0)
    var pSrc_field_data : uint8 const? = null
    var descriptor_buf : array<uint8> = []
    var has_id : int = int(0)
    var pSrc_1 : uint8 const? = null
    var file_crc32_0 : uint = uint(0)
    var comp_size_0 : uint64 = uint64(0)
    var uncomp_size : uint64 = uint64(0)
    var num_descriptor_uint32s : uint = uint(0)
    found_zip64_ext_data_in_cdir = 0
    found_zip64_ext_data_in_ldir = 0
    pLocal_header_2 = unsafe(addr(local_header_u32_2[0]))
    local_header_ofs_0 = uint64(0)
    uncomp_crc32 = uint(0)
    mz_zip_array_init(unsafe(addr(file_data_array)), uint(1))
    if (pZip_48 == null || pZip_48.m_pState == null || pZip_48.m_pAlloc == null || pZip_48.m_pFree == null || pZip_48.m_pRead == null) {
        return mz_zip_set_error(pZip_48, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
    } elif (uint(file_index_18) > uint(pZip_48.m_total_files)) {
        return mz_zip_set_error(pZip_48, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
    } else {
        pState_6 = unsafe(unsafe(reinterpret<mz_zip_internal_state_tag?>(pZip_48.m_pState)))
        pCentral_dir_header_0 = unsafe(unsafe(reinterpret<uint8 const?>(mz_zip_get_cdh(pZip_48, file_index_18))))
        if (uint64((mz_zip_file_stat_internal(pZip_48, file_index_18, pCentral_dir_header_0, unsafe(addr(file_stat_2) == uint64(0)), unsafe(addr(found_zip64_ext_data_in_cdir)))) ? 1 : 0) == uint64(0)) {
            return 0
        } elif (uint64(file_stat_2.m_is_directory) != uint64(0) || uint64(file_stat_2.m_uncomp_size) == uint64(0)) {
            return 1
        } elif (uint64(file_stat_2.m_is_encrypted) != uint64(0)) {
            return mz_zip_set_error(pZip_48, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNSUPPORTED_ENCRYPTION)))
        } elif (uint64((int(file_stat_2.m_method) == int(0)) ? 1 : 0) != uint64(0) && int(file_stat_2.m_method) != 8) {
            return mz_zip_set_error(pZip_48, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNSUPPORTED_METHOD)))
        } elif (uint64(file_stat_2.m_is_supported) == uint64(0)) {
            return mz_zip_set_error(pZip_48, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNSUPPORTED_FEATURE)))
        } else {
            local_header_ofs_0 = uint64(file_stat_2.m_local_header_ofs)
            if (pZip_48.m_pRead(pZip_48.m_pIO_opaque, local_header_ofs_0, unsafe(unsafe(reinterpret<uint64>(pLocal_header_2))), unsafe(reinterpret<size_t>(MZ_ZIP_LOCAL_DIR_HEADER_SIZE))) != unsafe(reinterpret<size_t>(MZ_ZIP_LOCAL_DIR_HEADER_SIZE))) {
                return mz_zip_set_error(pZip_48, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_READ_FAILED)))
            } elif ((uint(((unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pLocal_header_2) == uint(0)))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pLocal_header_2) == uint(0)))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pLocal_header_2) == uint(0)))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pLocal_header_2) == uint(0)))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)) != uint(MZ_ZIP_LOCAL_DIR_HEADER_SIG)) {
                return mz_zip_set_error(pZip_48, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
            } else {
                local_header_filename_len = uint(((uint(unsafe(unsafe(pLocal_header_2 + int(MZ_ZIP_LDH_FILENAME_LEN_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(pLocal_header_2 + int(MZ_ZIP_LDH_FILENAME_LEN_OFS) == uint(0))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
                local_header_extra_len = uint(((uint(unsafe(unsafe(pLocal_header_2 + int(MZ_ZIP_LDH_EXTRA_LEN_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(pLocal_header_2 + int(MZ_ZIP_LDH_EXTRA_LEN_OFS) == uint(0))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
                local_header_comp_size = uint64((uint64(uint(((unsafe(unsafe(pLocal_header_2 + int(MZ_ZIP_LDH_COMPRESSED_SIZE_OFS) == uint64(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pLocal_header_2 + int(MZ_ZIP_LDH_COMPRESSED_SIZE_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(pLocal_header_2 + int(MZ_ZIP_LDH_COMPRESSED_SIZE_OFS) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(pLocal_header_2 + int(MZ_ZIP_LDH_COMPRESSED_SIZE_OFS) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18))) ? 1 : 0)
                local_header_uncomp_size = uint64((uint64(uint(((unsafe(unsafe(pLocal_header_2 + int(MZ_ZIP_LDH_DECOMPRESSED_SIZE_OFS) == uint64(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pLocal_header_2 + int(MZ_ZIP_LDH_DECOMPRESSED_SIZE_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(pLocal_header_2 + int(MZ_ZIP_LDH_DECOMPRESSED_SIZE_OFS) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(pLocal_header_2 + int(MZ_ZIP_LDH_DECOMPRESSED_SIZE_OFS) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18))) ? 1 : 0)
                local_header_crc32 = uint(((uint(unsafe(unsafe(pLocal_header_2 + int(MZ_ZIP_LDH_CRC32_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(pLocal_header_2 + int(MZ_ZIP_LDH_CRC32_OFS) == uint(0))[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(pLocal_header_2 + int(MZ_ZIP_LDH_CRC32_OFS) == uint(0))[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(pLocal_header_2 + int(MZ_ZIP_LDH_CRC32_OFS) == uint(0))[3]))) << uint(0x18)) ? 1 : 0) ? 1 : 0)
                local_header_bit_flags = uint(((uint(unsafe(unsafe(pLocal_header_2 + int(MZ_ZIP_LDH_BIT_FLAG_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(pLocal_header_2 + int(MZ_ZIP_LDH_BIT_FLAG_OFS) == uint(0))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
                has_data_descriptor = int((uint64(uint(local_header_bit_flags) & uint(8)) != uint64(0)) ? 1 : 0)
                if (unsafe(reinterpret<size_t>(local_header_filename_len)) != strlen(unsafe(addr(file_stat_2.m_filename[0])))) {
                    return mz_zip_set_error(pZip_48, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
                } elif (uint64(local_header_ofs_0) + (uint64(MZ_ZIP_LOCAL_DIR_HEADER_SIZE) + uint64(local_header_filename_len)) + uint64(local_header_extra_len) + uint64(file_stat_2.m_comp_size) > uint64(pZip_48.m_archive_size)) {
                    return mz_zip_set_error(pZip_48, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
                } else {
                    var c2da_fresh91 : uint = uint(0)
                    if (uint(local_header_filename_len) > uint(local_header_extra_len)) {
                        c2da_fresh91 = local_header_filename_len
                    } else {
                        c2da_fresh91 = local_header_extra_len
                    }
                    if (uint64((mz_zip_array_resize(pZip_48, unsafe(addr(file_data_array) == uint64(0)), unsafe(reinterpret<size_t>(c2da_fresh91)), uint(0))) ? 1 : 0) == uint64(0)) {
                        mz_zip_set_error(pZip_48, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                        goto _handle_failure
                    } else {
                        if (uint64(local_header_filename_len) != uint64(0)) {
                            if (pZip_48.m_pRead(pZip_48.m_pIO_opaque, uint64(local_header_ofs_0) + uint64(MZ_ZIP_LOCAL_DIR_HEADER_SIZE), file_data_array.m_p, unsafe(reinterpret<size_t>(local_header_filename_len))) != unsafe(reinterpret<size_t>(local_header_filename_len))) {
                                mz_zip_set_error(pZip_48, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_READ_FAILED)))
                                goto _handle_failure
                            } elif (uint64((memcmp(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(file_stat_2.m_filename[0]) == uint64(0))))), file_data_array.m_p, uint64(local_header_filename_len))) ? 1 : 0) != uint64(0)) {
                                mz_zip_set_error(pZip_48, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_VALIDATION_FAILED)))
                                goto _handle_failure
                            }
                        }
                        if (uint64(local_header_extra_len) != uint64(0) && uint64(local_header_comp_size) == uint64(0xffffffff) || uint64(local_header_uncomp_size) == uint64(0xffffffff)) {
                            extra_size_remaining_1 = local_header_extra_len
                            pExtra_data_1 = file_data_array.m_p
                            if (pZip_48.m_pRead(pZip_48.m_pIO_opaque, uint64(local_header_ofs_0) + (uint64(MZ_ZIP_LOCAL_DIR_HEADER_SIZE) + uint64(local_header_filename_len)), file_data_array.m_p, unsafe(reinterpret<size_t>(local_header_extra_len))) != unsafe(reinterpret<size_t>(local_header_extra_len))) {
                                mz_zip_set_error(pZip_48, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_READ_FAILED)))
                                goto _handle_failure
                            } else {
                                while (true) {
                                    if (uint64(extra_size_remaining_1) < uint64((4 * int((uint64(2) == uint64(0)) ? 1 : 0)) ? 1 : 0)) {
                                        mz_zip_set_error(pZip_48, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
                                        goto _handle_failure
                                    } else {
                                        field_id_1 = uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pExtra_data_1) == uint(0)))[0])) | uint(uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pExtra_data_1) == uint(0)))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
                                        field_data_size_1 = uint(uint(unsafe(unsafe(pExtra_data_1 + 4)[0])) | uint(uint(unsafe(unsafe(pExtra_data_1 + 4)[1]))) << uint(0x8))
                                        field_total_size = uint(((uint(uint64(field_data_size_1) + uint64((uint64(4 * int(uint64(2) == uint64(0)))) ? 1 : 0))) ? 1 : 0) ? 1 : 0)
                                        if (uint(field_total_size) > uint(extra_size_remaining_1)) {
                                            mz_zip_set_error(pZip_48, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
                                            goto _handle_failure
                                        } elif (uint(field_id_1) == uint(MZ_ZIP64_EXTENDED_INFORMATION_FIELD_HEADER_ID)) {
                                            pSrc_field_data = unsafe(pExtra_data_1 + 4)
                                            if (uint64(field_data_size_1) < uint64((4 * int((uint64(2) == uint64(0)) ? 1 : 0)) ? 1 : 0)) {
                                                mz_zip_set_error(pZip_48, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
                                                goto _handle_failure
                                            } else {
                                                local_header_uncomp_size = uint64((uint64(uint(((unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pSrc_field_data) == uint64(0)))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pSrc_field_data) == uint(0)))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pSrc_field_data) == uint(0)))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pSrc_field_data) == uint(0)))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)) | uint64(uint64(uint(unsafe(unsafe(pSrc_field_data + 4)[0])) | uint(uint(unsafe(unsafe(pSrc_field_data + 4)[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(pSrc_field_data + 4)[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(pSrc_field_data + 4)[3]))) << uint(0x18))) << uint64(uint64(0x20) == uint64(0))) ? 1 : 0)
                                                local_header_comp_size = uint64((uint64(uint(unsafe(unsafe(pSrc_field_data + 4)[0])) | uint(uint(unsafe(unsafe(pSrc_field_data + 4)[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(pSrc_field_data + 4)[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(pSrc_field_data + 4)[3]))) << uint(0x18)) | uint64(uint64(uint(((unsafe(unsafe(pSrc_field_data + (4 + 4) == uint64(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pSrc_field_data + (4 + 4) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(pSrc_field_data + (4 + 4) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(pSrc_field_data + (4 + 4) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18))) << uint64(uint64(0x20) == uint64(0))) ? 1 : 0)
                                                found_zip64_ext_data_in_ldir = 1
                                                if (false) {
                                                }
                                                if (false) {
                                                }
                                            }
                                        } else {
                                            pExtra_data_1 = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(pExtra_data_1 + field_total_size))))
                                            extra_size_remaining_1 = uint(extra_size_remaining_1 - field_total_size)
                                            if (!(uint64(extra_size_remaining_1) != uint64(0))) {
                                                if (false) {
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if (uint64(has_data_descriptor) != uint64(0) && uint64(local_header_comp_size) == uint64(0) && uint64(local_header_crc32) == uint64(0)) {
                            comp_size_0 = uint64(0)
                            uncomp_size = uint64(0)
                            var c2da_fresh92 : int = int(0)
                            if (uint64(pState_6.m_zip64) != uint64(0) || uint64(found_zip64_ext_data_in_ldir) != uint64(0)) {
                                c2da_fresh92 = 6
                            } else {
                                c2da_fresh92 = 4
                            }
                            num_descriptor_uint32s = uint(c2da_fresh92)
                            if (pZip_48.m_pRead(pZip_48.m_pIO_opaque, uint64(local_header_ofs_0) + (uint64(MZ_ZIP_LOCAL_DIR_HEADER_SIZE) + uint64(local_header_filename_len)) + uint64(local_header_extra_len) + uint64(file_stat_2.m_comp_size), unsafe(unsafe(reinterpret<uint64>(unsafe(addr(descriptor_buf[0]))))), 4 * int((uint64(num_descriptor_uint32s) == uint64(0)) ? 1 : 0)) != unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(4 * int((uint64(num_descriptor_uint32s) == uint64(0)) ? 1 : 0)))))) {
                                mz_zip_set_error(pZip_48, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_READ_FAILED)))
                                goto _handle_failure
                            } else {
                                has_id = int(((uint((unsafe(unsafe(addr(descriptor_buf[0]) == uint(0))[0])) ? 1 : 0) | uint((uint(unsafe(unsafe(addr(descriptor_buf[0]) == uint(0))[1]))) ? 1 : 0) << uint(0x8) | uint((uint(unsafe(unsafe(addr(descriptor_buf[0]) == uint(0))[2]))) ? 1 : 0) << uint(0x10) | uint((uint(unsafe(unsafe(addr(descriptor_buf[0]) == uint(0))[3]))) ? 1 : 0) << uint(0x18)) == uint(MZ_ZIP_DATA_DESCRIPTOR_ID)) ? 1 : 0)
                                var c2da_fresh93 : uint8? = null
                                if (uint64(has_id) != uint64(0)) {
                                    c2da_fresh93 = unsafe(unsafe(addr(descriptor_buf[0])) + 4)
                                } else {
                                    c2da_fresh93 = unsafe(addr(descriptor_buf[0]))
                                }
                                pSrc_1 = unsafe(unsafe(reinterpret<uint8 const?>(c2da_fresh93)))
                                file_crc32_0 = uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pSrc_1) == uint(0)))[0])) | uint(uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pSrc_1) == uint(0)))[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pSrc_1) == uint(0)))[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pSrc_1) == uint(0)))[3]))) << uint(0x18)) ? 1 : 0) ? 1 : 0)
                                if (uint64(pState_6.m_zip64) != uint64(0) || uint64(found_zip64_ext_data_in_ldir) != uint64(0)) {
                                    comp_size_0 = uint64((uint64(uint(unsafe(unsafe(pSrc_1 + 4)[0])) | uint(uint(unsafe(unsafe(pSrc_1 + 4)[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(pSrc_1 + 4)[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(pSrc_1 + 4)[3]))) << uint(0x18)) | uint64(uint64(uint(((unsafe(unsafe(pSrc_1 + (4 + 4) == uint64(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pSrc_1 + (4 + 4) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(pSrc_1 + (4 + 4) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(pSrc_1 + (4 + 4) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18))) << uint64(uint64(0x20) == uint64(0))) ? 1 : 0)
                                    uncomp_size = uint64((uint64(uint(((unsafe(unsafe(pSrc_1 + (4 + 4) == uint64(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pSrc_1 + (4 + 4) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(pSrc_1 + (4 + 4) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(pSrc_1 + (4 + 4) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)) | uint64(uint64(uint(((unsafe(unsafe(pSrc_1 + (4 + 4 + 4) == uint64(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pSrc_1 + (4 + 4 + 4) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(pSrc_1 + (4 + 4 + 4) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(pSrc_1 + (4 + 4 + 4) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18))) << uint64(uint64(0x20) == uint64(0))) ? 1 : 0)
                                } else {
                                    comp_size_0 = uint64(uint64(uint(unsafe(unsafe(pSrc_1 + 4)[0])) | uint(uint(unsafe(unsafe(pSrc_1 + 4)[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(pSrc_1 + 4)[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(pSrc_1 + 4)[3]))) << uint(0x18)))
                                    uncomp_size = uint64((uint64(uint(((unsafe(unsafe(pSrc_1 + (4 + 4) == uint64(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pSrc_1 + (4 + 4) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(pSrc_1 + (4 + 4) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(pSrc_1 + (4 + 4) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18))) ? 1 : 0)
                                }
                                if (uint(file_crc32_0) != uint(file_stat_2.m_crc32) || uint64(comp_size_0) != uint64(file_stat_2.m_comp_size) || uint64(uncomp_size) != uint64(file_stat_2.m_uncomp_size)) {
                                    mz_zip_set_error(pZip_48, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_VALIDATION_FAILED)))
                                    goto _handle_failure
                                }
                            }
                        } elif (uint(local_header_crc32) != uint(file_stat_2.m_crc32) || uint64(local_header_comp_size) != uint64(file_stat_2.m_comp_size) || uint64(local_header_uncomp_size) != uint64(file_stat_2.m_uncomp_size)) {
                            mz_zip_set_error(pZip_48, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_VALIDATION_FAILED)))
                            goto _handle_failure
                        }
                        mz_zip_array_clear(pZip_48, unsafe(addr(file_data_array)))
                        if (uint64(uint(flags_25) & uint(MZ_ZIP_FLAG_VALIDATE_HEADERS_ONLY)) == uint64(0)) {
                            if (uint64((mz_zip_reader_extract_to_callback(pZip_48, file_index_18, mz_zip_compute_crc32_callback, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(uncomp_crc32) == uint64(0))))), uint(0))) ? 1 : 0) == uint64(0)) {
                                return 0
                            } elif (uint(uncomp_crc32) != uint(file_stat_2.m_crc32)) {
                                mz_zip_set_error(pZip_48, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_VALIDATION_FAILED)))
                                return 0
                            }
                        }
                        return 1
                    }
                }
            }
        }
    }
}
[export]
def mz_zip_compute_crc32_callback(var pOpaque_2 : uint64; var file_ofs_1 : uint64; var pBuf_12 : uint64; var n_11 : size_t) : size_t {
    var p_10 : uint? = null
    p_10 = pOpaque_2
    file_ofs_1
    *p_10 = uint(uint(mz_crc32(uint64(*p_10), pBuf_12, n_11)))
    return n_11
}
[export]
def mz_zip_array_init(var pArray_2 : mz_zip_array?; var element_size : uint) {
    memset(unsafe(unsafe(reinterpret<uint64>(pArray_2))), 0, uint64(4))
    pArray_2.m_element_size = uint(element_size)
    return
}
[export]
def mz_zip_validate_archive(var pZip_49 : mz_zip_archive?; var flags_26 : uint) : int {
    var pState_7 : mz_zip_internal_state_tag? = null
    var i_21 : uint = uint(0)
    if (pZip_49 == null || pZip_49.m_pState == null || pZip_49.m_pAlloc == null || pZip_49.m_pFree == null || pZip_49.m_pRead == null) {
        return mz_zip_set_error(pZip_49, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
    } else {
        pState_7 = unsafe(unsafe(reinterpret<mz_zip_internal_state_tag?>(pZip_49.m_pState)))
        if (uint64(pState_7.m_zip64) == uint64(0)) {
            if (uint(pZip_49.m_total_files) > 0xffff) {
                return mz_zip_set_error(pZip_49, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ARCHIVE_TOO_LARGE)))
            } elif (uint64(pZip_49.m_archive_size) > uint64(0xffffffff)) {
                return mz_zip_set_error(pZip_49, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ARCHIVE_TOO_LARGE)))
            } else {
                if (false) {
                }
            }
        } elif (unsafe(reinterpret<size_t>(pState_7.m_central_dir.m_size)) >= unsafe(reinterpret<size_t>(0xffffffff))) {
            return mz_zip_set_error(pZip_49, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ARCHIVE_TOO_LARGE)))
        } else {
            if (false) {
            }
        }
    }
}
[export]
def mz_zip_validate_mem_archive(var pMem_0 : uint64; var size_5 : size_t; var flags_27 : uint; var pErr : mz_zip_error?) : int {
    var success : int = int(0)
    var zip : mz_zip_archive = mz_zip_archive()
    var actual_err : mz_zip_error = unsafe(reinterpret<mz_zip_error>(0))
    success = 1
    actual_err = unsafe(reinterpret<mz_zip_error>(MZ_ZIP_NO_ERROR))
    if (uint64(pMem_0) == uint64(0) || uint64(size_5) == uint64(0)) {
        if (pErr != null) {
            *pErr = unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER))
        }
        return 0
    } else {
        mz_zip_zero_struct(unsafe(addr(zip)))
        if (uint64((mz_zip_reader_init_mem(unsafe(addr(zip) == uint64(0)), pMem_0, size_5, flags_27)) ? 1 : 0) == uint64(0)) {
            if (pErr != null) {
                *pErr = zip.m_last_error
            }
            return 0
        } else {
            if (uint64((mz_zip_validate_archive(unsafe(addr(zip) == uint64(0)), flags_27)) ? 1 : 0) == uint64(0)) {
                actual_err = zip.m_last_error
                success = 0
            }
            if (uint64((mz_zip_reader_end_internal(unsafe(addr(zip) == uint64(0)), success)) ? 1 : 0) == uint64(0)) {
                if (uint64((uint(actual_err) == uint64(0)) ? 1 : 0) == uint64(0)) {
                    actual_err = zip.m_last_error
                }
                success = 0
            }
            if (pErr != null) {
                *pErr = actual_err
            }
            return success
        }
    }
}
[export]
def mz_zip_end(var pZip_50 : mz_zip_archive?) : int {
    if (pZip_50 == null) {
        return 0
    } elif (uint(pZip_50.m_zip_mode) == uint(MZ_ZIP_MODE_READING)) {
        return mz_zip_reader_end(pZip_50)
    } elif (uint(pZip_50.m_zip_mode) == uint(MZ_ZIP_MODE_WRITING) || uint(pZip_50.m_zip_mode) == uint(MZ_ZIP_MODE_WRITING_HAS_BEEN_FINALIZED)) {
        return mz_zip_writer_end(pZip_50)
    } else {
        return 0
    }
}
[export]
def mz_zip_writer_end(var pZip_51 : mz_zip_archive?) : int {
    return mz_zip_writer_end_internal(pZip_51, 1)
}
[export]
def mz_zip_writer_end_internal(var pZip_52 : mz_zip_archive?; var set_last_error_0 : int) : int {
    var pState_8 : mz_zip_internal_state_tag? = null
    var status_10 : int = int(0)
    status_10 = 1
    if (pZip_52 == null || pZip_52.m_pState == null || pZip_52.m_pAlloc == null || pZip_52.m_pFree == null || uint(pZip_52.m_zip_mode) != uint(MZ_ZIP_MODE_WRITING) && uint(pZip_52.m_zip_mode) != uint(MZ_ZIP_MODE_WRITING_HAS_BEEN_FINALIZED)) {
        if (uint64(set_last_error_0) != uint64(0)) {
            mz_zip_set_error(pZip_52, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
        }
        return 0
    } else {
        pState_8 = unsafe(unsafe(reinterpret<mz_zip_internal_state_tag?>(pZip_52.m_pState)))
        pZip_52.m_pState = null
        mz_zip_array_clear(pZip_52, unsafe(addr(pState_8.m_central_dir)))
        mz_zip_array_clear(pZip_52, unsafe(addr(pState_8.m_central_dir_offsets)))
        mz_zip_array_clear(pZip_52, unsafe(addr(pState_8.m_sorted_central_dir_offsets)))
        if (unsafe(unsafe(reinterpret<uint64>(pZip_52.m_pWrite)) == unsafe(reinterpret<uint64>(mz_zip_heap_write_func))) && uint64(pState_8.m_pMem) != uint64(0)) {
            pZip_52.m_pFree(pZip_52.m_pAlloc_opaque, pState_8.m_pMem)
            pState_8.m_pMem = uint64(0)
        }
        pZip_52.m_pFree(pZip_52.m_pAlloc_opaque, unsafe(unsafe(reinterpret<uint64>(pState_8))))
        pZip_52.m_zip_mode = unsafe(reinterpret<mz_zip_mode>(MZ_ZIP_MODE_INVALID))
        return status_10
    }
}
[export]
def mz_zip_heap_write_func(var pOpaque_3 : uint64; var file_ofs_2 : uint64; var pBuf_13 : uint64; var n_12 : size_t) : size_t {
    var pZip_53 : mz_zip_archive? = null
    var pState_9 : mz_zip_internal_state_tag? = null
    var new_size_1 : uint64 = uint64(0)
    var pNew_block : uint64 = uint64(0)
    var new_capacity_1 : size_t = unsafe(reinterpret<size_t>(0))
    pZip_53 = pOpaque_3
    pState_9 = pZip_53.m_pState
    var c2da_fresh94 : uint64 = uint64(0)
    if (uint64(file_ofs_2) + uint64((uint64(unsafe(reinterpret<size_t>(n_12) == uint64(0)))) ? 1 : 0) > uint64(unsafe(reinterpret<size_t>(pState_9.m_mem_size)))) {
        c2da_fresh94 = uint64(file_ofs_2) + uint64((uint64(unsafe(reinterpret<size_t>(n_12) == uint64(0)))) ? 1 : 0)
    } else {
        c2da_fresh94 = pState_9.m_mem_size
    }
    new_size_1 = c2da_fresh94
    if (uint64(n_12) == uint64(0)) {
        return unsafe(reinterpret<size_t>(0))
    } elif (4 == 4 && uint64(new_size_1) > uint64(2147483647)) {
        mz_zip_set_error(pZip_53, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_TOO_LARGE)))
        return unsafe(reinterpret<size_t>(0))
    } else {
        if (uint64(new_size_1) > uint64((uint64(unsafe(reinterpret<size_t>(pState_9.m_mem_capacity) == uint64(0)))) ? 1 : 0)) {
            var c2da_fresh95 : size_t = unsafe(reinterpret<size_t>(0))
            if (unsafe(reinterpret<size_t>(64)) > unsafe(reinterpret<size_t>(pState_9.m_mem_capacity))) {
                c2da_fresh95 = unsafe(reinterpret<size_t>(64))
            } else {
                c2da_fresh95 = pState_9.m_mem_capacity
            }
            new_capacity_1 = c2da_fresh95
            while (true) {
                if (!unsafe(reinterpret<size_t>(new_capacity_1)) < unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(uint64(new_size_1) == uint64(0)))))) {
                    if (false) {
                    }
                }
                new_capacity_1 = unsafe(reinterpret<size_t>(new_capacity_1 * unsafe(reinterpret<size_t>(2))))
            }
            pNew_block = pZip_53.m_pRealloc(pZip_53.m_pAlloc_opaque, pState_9.m_pMem, unsafe(reinterpret<size_t>(1)), new_capacity_1)
            if (unsafe(unsafe(reinterpret<uint64>(uint64(0) == uint64(0))) == unsafe(reinterpret<uint64>(uint64(pNew_block) == uint64(0))))) {
                mz_zip_set_error(pZip_53, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                return unsafe(reinterpret<size_t>(0))
            } else {
                pState_9.m_pMem = pNew_block
                pState_9.m_mem_capacity = unsafe(reinterpret<size_t>(new_capacity_1))
            }
        }
        memcpy(unsafe(unsafe(reinterpret<uint64>(unsafe(pState_9.m_pMem + uint64(file_ofs_2))))), pBuf_13, uint64(n_12))
        pState_9.m_mem_size = unsafe(reinterpret<size_t>(new_size_1))
        return n_12
    }
}
[export]
def mz_zip_writer_init(var pZip_54 : mz_zip_archive?; var existing_size : uint64) : int {
    return mz_zip_writer_init_v2(pZip_54, existing_size, uint(0))
}
[export]
def mz_zip_writer_init_v2(var pZip_55 : mz_zip_archive?; var existing_size_0 : uint64; var flags_28 : uint) : int {
    var zip64 : int = int(0)
    zip64 = uint64(uint(flags_28) & uint(MZ_ZIP_FLAG_WRITE_ZIP64)) != uint64(0)
    if (pZip_55 == null || pZip_55.m_pState != null || pZip_55.m_pWrite == null || uint(pZip_55.m_zip_mode) != uint(MZ_ZIP_MODE_INVALID)) {
        return mz_zip_set_error(pZip_55, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
    } else {
        if (uint64(uint(flags_28) & uint(MZ_ZIP_FLAG_WRITE_ALLOW_READING)) != uint64(0)) {
            if (pZip_55.m_pRead == null) {
                return mz_zip_set_error(pZip_55, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
            }
        }
        if (uint64(pZip_55.m_file_offset_alignment) != uint64(0)) {
            if (uint64(uint64(pZip_55.m_file_offset_alignment) & uint64(pZip_55.m_file_offset_alignment) - uint64(1)) != uint64(0)) {
                return mz_zip_set_error(pZip_55, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
            }
        }
        if (pZip_55.m_pAlloc == null) {
            pZip_55.m_pAlloc = miniz_def_alloc_func
        }
        if (pZip_55.m_pFree == null) {
            pZip_55.m_pFree = miniz_def_free_func
        }
        if (pZip_55.m_pRealloc == null) {
            pZip_55.m_pRealloc = miniz_def_realloc_func
        }
        pZip_55.m_archive_size = uint64(existing_size_0)
        pZip_55.m_central_directory_file_ofs = uint64((uint64(0) == uint64(0)) ? 1 : 0)
        pZip_55.m_total_files = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
        pZip_55.m_pState = unsafe(unsafe(reinterpret<mz_zip_internal_state_tag?>(pZip_55.m_pAlloc(pZip_55.m_pAlloc_opaque, unsafe(reinterpret<size_t>(1)), 4))))
        if (unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(reinterpret<mz_zip_internal_state_tag?>(uint64(0) == uint64(0)))))) == unsafe(reinterpret<uint64>(pZip_55.m_pState)))) {
            return mz_zip_set_error(pZip_55, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
        } else {
            memset(unsafe(unsafe(reinterpret<uint64>(pZip_55.m_pState))), 0, uint64(4))
            unsafe(addr(pZip_55.m_pState.m_central_dir)).m_element_size = uint(((uint(4) == uint(0)) ? 1 : 0) ? 1 : 0)
            unsafe(addr(pZip_55.m_pState.m_central_dir_offsets)).m_element_size = uint(((uint(4) == uint(0)) ? 1 : 0) ? 1 : 0)
            unsafe(addr(pZip_55.m_pState.m_sorted_central_dir_offsets)).m_element_size = uint(((uint(4) == uint(0)) ? 1 : 0) ? 1 : 0)
            pZip_55.m_pState.m_zip64 = zip64
            pZip_55.m_pState.m_zip64_has_extended_info_fields = zip64
            pZip_55.m_zip_type = unsafe(reinterpret<mz_zip_type>(MZ_ZIP_TYPE_USER))
            pZip_55.m_zip_mode = unsafe(reinterpret<mz_zip_mode>(MZ_ZIP_MODE_WRITING))
            return 1
        }
    }
}
[export]
def mz_zip_writer_init_heap(var pZip_56 : mz_zip_archive?; var size_to_reserve_at_beginning : size_t; var initial_allocation_size : size_t) : int {
    return mz_zip_writer_init_heap_v2(pZip_56, size_to_reserve_at_beginning, initial_allocation_size, uint(0))
}
[export]
def mz_zip_writer_init_heap_v2(var pZip_57 : mz_zip_archive?; var size_to_reserve_at_beginning_0 : size_t; var initial_allocation_size_0 : size_t; var flags_29 : uint) : int {
    pZip_57.m_pWrite = mz_zip_heap_write_func
    pZip_57.m_pNeeds_keepalive = null
    if (uint64(uint(flags_29) & uint(MZ_ZIP_FLAG_WRITE_ALLOW_READING)) != uint64(0)) {
        pZip_57.m_pRead = mz_zip_mem_read_func
    }
    pZip_57.m_pIO_opaque = unsafe(unsafe(reinterpret<uint64>(pZip_57)))
    if (uint64((mz_zip_writer_init_v2(pZip_57, size_to_reserve_at_beginning_0, flags_29) == uint64(0)) ? 1 : 0) == uint64(0)) {
        return 0
    } else {
        pZip_57.m_zip_type = unsafe(reinterpret<mz_zip_type>(MZ_ZIP_TYPE_HEAP))
        var c2da_fresh96 : size_t = unsafe(reinterpret<size_t>(0))
        if (unsafe(reinterpret<size_t>(initial_allocation_size_0)) > unsafe(reinterpret<size_t>(size_to_reserve_at_beginning_0))) {
            c2da_fresh96 = initial_allocation_size_0
        } else {
            c2da_fresh96 = size_to_reserve_at_beginning_0
        }
        initial_allocation_size_0 = unsafe(reinterpret<size_t>(c2da_fresh96))
        if (unsafe(reinterpret<size_t>(0)) != unsafe(reinterpret<size_t>(initial_allocation_size_0))) {
            pZip_57.m_pState.m_pMem = pZip_57.m_pAlloc(pZip_57.m_pAlloc_opaque, unsafe(reinterpret<size_t>(1)), initial_allocation_size_0)
            if (unsafe(unsafe(reinterpret<uint64>(uint64(0) == uint64(0))) == unsafe(reinterpret<uint64>(uint64(pZip_57.m_pState.m_pMem) == uint64(0))))) {
                mz_zip_writer_end_internal(pZip_57, 0)
                return mz_zip_set_error(pZip_57, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
            } else {
                pZip_57.m_pState.m_mem_capacity = unsafe(reinterpret<size_t>(initial_allocation_size_0))
            }
        }
        return 1
    }
}
[export]
def mz_zip_writer_init_from_reader(var pZip_58 : mz_zip_archive?; var pFilename_7 : int8 const?) : int {
    return mz_zip_writer_init_from_reader_v2(pZip_58, pFilename_7, uint(0))
}
[export]
def mz_zip_writer_init_from_reader_v2(var pZip_59 : mz_zip_archive?; var pFilename_8 : int8 const?; var flags_30 : uint) : int {
    var pState_10 : mz_zip_internal_state_tag? = null
    if (pZip_59 == null || pZip_59.m_pState == null || uint(pZip_59.m_zip_mode) != uint(MZ_ZIP_MODE_READING)) {
        return mz_zip_set_error(pZip_59, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
    } else {
        if (uint64(uint(flags_30) & uint(MZ_ZIP_FLAG_WRITE_ZIP64)) != uint64(0)) {
            if (uint64(pZip_59.m_pState.m_zip64) == uint64(0)) {
                return mz_zip_set_error(pZip_59, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
            }
        }
        if (uint64(pZip_59.m_pState.m_zip64) != uint64(0)) {
            if (uint(pZip_59.m_total_files) == 0xffffffff) {
                return mz_zip_set_error(pZip_59, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_TOO_MANY_FILES)))
            }
        } elif (uint(pZip_59.m_total_files) == 0xffff) {
            return mz_zip_set_error(pZip_59, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_TOO_MANY_FILES)))
        } elif (uint64(pZip_59.m_archive_size) + (uint64(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE) + uint64(MZ_ZIP_LOCAL_DIR_HEADER_SIZE)) > uint64(0xffffffff)) {
            return mz_zip_set_error(pZip_59, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_TOO_LARGE)))
        }
        pState_10 = unsafe(unsafe(reinterpret<mz_zip_internal_state_tag?>(pZip_59.m_pState)))
        if (pState_10.m_pFile != null) {
            pFilename_8
            return mz_zip_set_error(pZip_59, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
        } else {
            if (uint64(pState_10.m_pMem) != uint64(0)) {
                if (unsafe(unsafe(reinterpret<uint64>(uint64(pZip_59.m_pIO_opaque) == uint64(0))) != unsafe(reinterpret<uint64>(unsafe(unsafe(reinterpret<uint64>(pZip_59))))))) {
                    return mz_zip_set_error(pZip_59, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
                } else {
                    pState_10.m_mem_capacity = unsafe(reinterpret<size_t>(pState_10.m_mem_size))
                    pZip_59.m_pWrite = mz_zip_heap_write_func
                    pZip_59.m_pNeeds_keepalive = null
                }
            } elif (pZip_59.m_pWrite == null) {
                return mz_zip_set_error(pZip_59, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
            }
            pZip_59.m_archive_size = uint64(pZip_59.m_central_directory_file_ofs)
            pZip_59.m_central_directory_file_ofs = uint64((uint64(0) == uint64(0)) ? 1 : 0)
            mz_zip_array_clear(pZip_59, unsafe(addr(pZip_59.m_pState.m_sorted_central_dir_offsets)))
            pZip_59.m_zip_mode = unsafe(reinterpret<mz_zip_mode>(MZ_ZIP_MODE_WRITING))
            return 1
        }
    }
}
[export]
def mz_zip_writer_add_mem(var pZip_60 : mz_zip_archive?; var pArchive_name : int8 const?; var pBuf_14 : uint64; var buf_size_5 : size_t; var level_and_flags : uint) : int {
    return mz_zip_writer_add_mem_ex(pZip_60, pArchive_name, pBuf_14, buf_size_5, uint64(0x0), uint16(0), level_and_flags, uint64(0), uint(0))
}
[export]
def mz_zip_writer_add_mem_ex(var pZip_61 : mz_zip_archive?; var pArchive_name_0 : int8 const?; var pBuf_15 : uint64; var buf_size_6 : size_t; var pComment_1 : uint64; var comment_size : uint16; var level_and_flags_0 : uint; var uncomp_size_0 : uint64; var uncomp_crc32_0 : uint) : int {
    return mz_zip_writer_add_mem_ex_v2(pZip_61, pArchive_name_0, pBuf_15, buf_size_6, pComment_1, comment_size, level_and_flags_0, uncomp_size_0, uncomp_crc32_0, null, null, uint(0), null, uint(0))
}
[export]
def mz_zip_writer_add_mem_ex_v2(var pZip_62 : mz_zip_archive?; var pArchive_name_1 : int8 const?; var pBuf_16 : uint64; var buf_size_7 : size_t; var pComment_2 : uint64; var comment_size_0 : uint16; var level_and_flags_1 : uint; var uncomp_size_1 : uint64; var uncomp_crc32_1 : uint; var last_modified : mz_dummy_time_t_tag?; var user_extra_data : int8 const?; var user_extra_data_len : uint; var user_extra_data_central : int8 const?; var user_extra_data_central_len : uint) : int {
    var method_2 : uint16 = uint16(0)
    var dos_time : uint16 = uint16(0)
    var dos_date : uint16 = uint16(0)
    var level_7 : uint = uint(0)
    var ext_attributes : uint = uint(0)
    var num_alignment_padding_bytes : uint = uint(0)
    var local_dir_header_ofs : uint64 = uint64(0)
    var cur_archive_file_ofs : uint64 = uint64(0)
    var comp_size_1 : uint64 = uint64(0)
    var archive_name_size : size_t = unsafe(reinterpret<size_t>(0))
    var local_dir_header : array<uint8> = []
    var pComp_3 : tdefl_compressor? = null
    var store_data_uncompressed : int = int(0)
    var pState_11 : mz_zip_internal_state_tag? = null
    var pExtra_data_2 : uint8? = null
    var extra_size : uint = uint(0)
    var extra_data : array<uint8> = []
    var bit_flags_0 : uint16 = uint16(0)
    var state : mz_zip_writer_add_state = mz_zip_writer_add_state()
    var local_dir_footer : array<uint8> = []
    var local_dir_footer_size : uint = uint(0)
    method_2 = uint16(0)
    dos_time = uint16(0)
    dos_date = uint16(0)
    ext_attributes = uint(0)
    local_dir_header_ofs = pZip_62.m_archive_size
    cur_archive_file_ofs = pZip_62.m_archive_size
    comp_size_1 = uint64(0)
    pComp_3 = null
    pExtra_data_2 = null
    extra_size = uint(0)
    bit_flags_0 = uint16(0)
    if (int(level_and_flags_1) < 0) {
        level_and_flags_1 = uint(((uint(MZ_DEFAULT_LEVEL) == uint(0)) ? 1 : 0) ? 1 : 0)
    }
    if (uint64(uncomp_size_1) != uint64(0) || uint64(buf_size_7) != uint64(0) && uint64(uint(level_and_flags_1) & uint(MZ_ZIP_FLAG_COMPRESSED_DATA)) == uint64(0)) {
        bit_flags_0 = bit_flags_0 | MZ_ZIP_LDH_BIT_FLAG_HAS_LOCATOR
    }
    if (uint64(uint(level_and_flags_1) & uint(MZ_ZIP_FLAG_ASCII_FILENAME)) == uint64(0)) {
        bit_flags_0 = bit_flags_0 | MZ_ZIP_GENERAL_PURPOSE_BIT_FLAG_UTF8
    }
    level_7 = uint(uint(level_and_flags_1) & uint(15))
    store_data_uncompressed = int((uint64(level_7) == uint64(0) || uint64(uint(level_and_flags_1) & uint(MZ_ZIP_FLAG_COMPRESSED_DATA)) != uint64(0)) ? 1 : 0)
    if (pZip_62 == null || pZip_62.m_pState == null || uint(pZip_62.m_zip_mode) != uint(MZ_ZIP_MODE_WRITING) || uint64(buf_size_7) != uint64(0) && uint64(pBuf_16) == uint64(0) || pArchive_name_1 == null || uint64((int(comment_size_0) == int(0)) ? 1 : 0) != uint64(0) && uint64(pComment_2) == uint64(0) || uint(level_7) > uint(MZ_UBER_COMPRESSION)) {
        return mz_zip_set_error(pZip_62, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
    } else {
        pState_11 = unsafe(unsafe(reinterpret<mz_zip_internal_state_tag?>(pZip_62.m_pState)))
        if (uint64(pState_11.m_zip64) != uint64(0)) {
            if (uint(pZip_62.m_total_files) == 0xffffffff) {
                return mz_zip_set_error(pZip_62, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_TOO_MANY_FILES)))
            }
        } else {
            if (uint(pZip_62.m_total_files) == 0xffff) {
                pState_11.m_zip64 = 1
            }
            if (uint64(buf_size_7) > uint64(0xffffffff) || uint64(uncomp_size_1) > uint64(0xffffffff)) {
                pState_11.m_zip64 = 1
            }
        }
        if (uint64(uint(level_and_flags_1) & uint(MZ_ZIP_FLAG_COMPRESSED_DATA)) == uint64(0) && uint64(uncomp_size_1) != uint64(0)) {
            return mz_zip_set_error(pZip_62, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
        } elif (uint64((mz_zip_writer_validate_archive_name(pArchive_name_1) == uint64(0)) ? 1 : 0) == uint64(0)) {
            return mz_zip_set_error(pZip_62, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_FILENAME)))
        } else {
            last_modified
            if (uint64(uint(level_and_flags_1) & uint(MZ_ZIP_FLAG_COMPRESSED_DATA)) == uint64(0)) {
                uncomp_crc32_1 = uint(uint(mz_crc32(uint64(0), pBuf_16, buf_size_7)))
                uncomp_size_1 = uint64(buf_size_7)
                if (uint64(uncomp_size_1) <= uint64(3)) {
                    level_7 = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
                    store_data_uncompressed = 1
                }
            }
            archive_name_size = unsafe(reinterpret<size_t>(strlen(pArchive_name_1)))
            if (unsafe(reinterpret<size_t>(archive_name_size)) > unsafe(reinterpret<size_t>(0xffff))) {
                return mz_zip_set_error(pZip_62, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_FILENAME)))
            } else {
                num_alignment_padding_bytes = uint(mz_zip_writer_compute_padding_needed_for_file_alignment(pZip_62))
                if (uint64(pState_11.m_central_dir.m_size) + (uint64(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE) + uint64((uint64(unsafe(reinterpret<size_t>(archive_name_size) == uint64(0)))) ? 1 : 0)) + uint64((uint64(4 * int((uint64(2) == uint64(0)) ? 1 : 0) + 4 * int((uint64(3) == uint64(0)) ? 1 : 0))) ? 1 : 0) + uint64(comment_size_0) >= uint64(0xffffffff)) {
                    return mz_zip_set_error(pZip_62, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNSUPPORTED_CDIR_SIZE)))
                } else {
                    if (uint64(pState_11.m_zip64) == uint64(0)) {
                        if (uint64(pZip_62.m_archive_size) + (uint64(num_alignment_padding_bytes) + uint64(MZ_ZIP_LOCAL_DIR_HEADER_SIZE)) + uint64((uint64(unsafe(reinterpret<size_t>(archive_name_size) == uint64(0)))) ? 1 : 0) + uint64(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE) + uint64((uint64(unsafe(reinterpret<size_t>(archive_name_size) == uint64(0)))) ? 1 : 0) + uint64(comment_size_0) + uint64(user_extra_data_len) + uint64((uint64(unsafe(reinterpret<size_t>(pState_11.m_central_dir.m_size) == uint64(0)))) ? 1 : 0) + uint64(MZ_ZIP_END_OF_CENTRAL_DIR_HEADER_SIZE) + uint64(user_extra_data_central_len) + uint64(MZ_ZIP_DATA_DESCRIPTER_SIZE32) > uint64(0xffffffff)) {
                            pState_11.m_zip64 = 1
                        }
                    }
                    if (uint64(archive_name_size) != uint64(0) && int(unsafe(unsafe(unsafe(reinterpret<int8 const?>(pArchive_name_1)))[uint(unsafe(reinterpret<size_t>(archive_name_size)) - unsafe(reinterpret<size_t>(1)))])) == 47) {
                        ext_attributes = uint(ext_attributes | uint(MZ_ZIP_DOS_DIR_ATTRIBUTE_BITFLAG))
                        if (uint64(buf_size_7) != uint64(0) || uint64(uncomp_size_1) != uint64(0)) {
                            return mz_zip_set_error(pZip_62, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
                        }
                    }
                    var c2da_fresh97 : uint64 = uint64(0)
                    if (uint64(pState_11.m_zip64) != uint64(0)) {
                        c2da_fresh97 = 4 * int((uint64(2) == uint64(0)) ? 1 : 0) + 4 * int((uint64(3) == uint64(0)) ? 1 : 0)
                    } else {
                        c2da_fresh97 = uint64(0)
                    }
                    if (uint64((mz_zip_array_ensure_room(pZip_62, unsafe(addr(pState_11.m_central_dir) == uint64(0)), unsafe(reinterpret<size_t>(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE)) + (unsafe(reinterpret<size_t>(archive_name_size)) + unsafe(reinterpret<size_t>(comment_size_0))) + unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(uint64(c2da_fresh97) == uint64(0))))))) ? 1 : 0) == uint64(0) || uint64(mz_zip_array_ensure_room(pZip_62, unsafe(addr(pState_11.m_central_dir_offsets)), unsafe(reinterpret<size_t>(1)))) == uint64(0)) {
                        return mz_zip_set_error(pZip_62, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                    } else {
                        if (uint64(store_data_uncompressed) == uint64(0) && uint64(buf_size_7) != uint64(0)) {
                            pComp_3 = unsafe(unsafe(reinterpret<tdefl_compressor?>(pZip_62.m_pAlloc(pZip_62.m_pAlloc_opaque, unsafe(reinterpret<size_t>(1)), 4))))
                            if (unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(reinterpret<tdefl_compressor?>(uint64(0) == uint64(0)))))) == unsafe(reinterpret<uint64>(pComp_3)))) {
                                return mz_zip_set_error(pZip_62, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                            }
                        }
                        if (uint64((mz_zip_writer_write_zeros(pZip_62, cur_archive_file_ofs, num_alignment_padding_bytes) == uint64(0)) ? 1 : 0) == uint64(0)) {
                            pZip_62.m_pFree(pZip_62.m_pAlloc_opaque, unsafe(unsafe(reinterpret<uint64>(pComp_3))))
                            return 0
                        } else {
                            local_dir_header_ofs = uint64(local_dir_header_ofs + uint64(num_alignment_padding_bytes))
                            if (uint64(pZip_62.m_file_offset_alignment) != uint64(0)) {
                                {
                                    if (uint64(uint64(local_dir_header_ofs) & uint64(pZip_62.m_file_offset_alignment) - uint64(1)) == uint64(0)) {
                                    } else {
                                        c2da___assert_fail(null, null, uint(0), null)
                                    }
                                }
                            }
                            cur_archive_file_ofs = uint64(cur_archive_file_ofs + uint64(num_alignment_padding_bytes))
                            memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(local_dir_header[0]))))), 0, uint64(4))
                            if (uint64(store_data_uncompressed) == uint64(0) || uint64(uint(level_and_flags_1) & uint(MZ_ZIP_FLAG_COMPRESSED_DATA)) != uint64(0)) {
                                method_2 = uint16(uint16(8))
                            }
                            if (uint64(pState_11.m_zip64) != uint64(0)) {
                                if (uint64(uncomp_size_1) >= uint64(0xffffffff) || uint64(local_dir_header_ofs) >= uint64(0xffffffff)) {
                                    pExtra_data_2 = unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(extra_data[0])))))
                                    var c2da_fresh98 : uint64? = null
                                    if (uint64(uncomp_size_1) >= uint64(0xffffffff)) {
                                        c2da_fresh98 = unsafe(addr(uncomp_size_1))
                                    } else {
                                        c2da_fresh98 = null
                                    }
                                    var c2da_fresh99 : uint64? = null
                                    if (uint64(uncomp_size_1) >= uint64(0xffffffff)) {
                                        c2da_fresh99 = unsafe(addr(comp_size_1))
                                    } else {
                                        c2da_fresh99 = null
                                    }
                                    var c2da_fresh100 : uint64? = null
                                    if (uint64(local_dir_header_ofs) >= uint64(0xffffffff)) {
                                        c2da_fresh100 = unsafe(addr(local_dir_header_ofs))
                                    } else {
                                        c2da_fresh100 = null
                                    }
                                    extra_size = uint(mz_zip_writer_create_zip64_extra_data(unsafe(addr(extra_data[0])), c2da_fresh98, c2da_fresh99, c2da_fresh100))
                                }
                                if (uint64((mz_zip_writer_create_local_dir_header(pZip_62, unsafe(addr(local_dir_header[0]) == uint64(0)), uint16(archive_name_size), uint16(uint(extra_size) + uint(user_extra_data_len)), uint64(0), uint64(0), uint(0), method_2, bit_flags_0, dos_time, dos_date)) ? 1 : 0) == uint64(0)) {
                                    return mz_zip_set_error(pZip_62, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INTERNAL_ERROR)))
                                } elif (pZip_62.m_pWrite(pZip_62.m_pIO_opaque, local_dir_header_ofs, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(local_dir_header[0]))))), 4) != unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(4))))) {
                                    return mz_zip_set_error(pZip_62, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
                                } else {
                                    cur_archive_file_ofs = uint64(cur_archive_file_ofs + 4)
                                    if (pZip_62.m_pWrite(pZip_62.m_pIO_opaque, cur_archive_file_ofs, unsafe(unsafe(reinterpret<uint64>(pArchive_name_1))), archive_name_size) != unsafe(reinterpret<size_t>(archive_name_size))) {
                                        pZip_62.m_pFree(pZip_62.m_pAlloc_opaque, unsafe(unsafe(reinterpret<uint64>(pComp_3))))
                                        return mz_zip_set_error(pZip_62, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
                                    } else {
                                        cur_archive_file_ofs = uint64(cur_archive_file_ofs + archive_name_size)
                                        if (unsafe(unsafe(reinterpret<uint64>(pExtra_data_2)) != unsafe(reinterpret<uint64>(null)))) {
                                            if (pZip_62.m_pWrite(pZip_62.m_pIO_opaque, cur_archive_file_ofs, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(extra_data[0]))))), unsafe(reinterpret<size_t>(extra_size))) != unsafe(reinterpret<size_t>(extra_size))) {
                                                return mz_zip_set_error(pZip_62, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
                                            } else {
                                                cur_archive_file_ofs = uint64(cur_archive_file_ofs + uint64(extra_size))
                                            }
                                        }
                                    }
                                }
                            } elif (uint64(comp_size_1) > uint64(0xffffffff) || uint64(cur_archive_file_ofs) > uint64(0xffffffff)) {
                                return mz_zip_set_error(pZip_62, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ARCHIVE_TOO_LARGE)))
                            } elif (uint64((mz_zip_writer_create_local_dir_header(pZip_62, unsafe(addr(local_dir_header[0]) == uint64(0)), uint16(archive_name_size), uint16(user_extra_data_len), uint64(0), uint64(0), uint(0), method_2, bit_flags_0, dos_time, dos_date)) ? 1 : 0) == uint64(0)) {
                                return mz_zip_set_error(pZip_62, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INTERNAL_ERROR)))
                            } elif (pZip_62.m_pWrite(pZip_62.m_pIO_opaque, local_dir_header_ofs, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(local_dir_header[0]))))), 4) != unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(4))))) {
                                return mz_zip_set_error(pZip_62, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
                            } else {
                                cur_archive_file_ofs = uint64(cur_archive_file_ofs + 4)
                                if (pZip_62.m_pWrite(pZip_62.m_pIO_opaque, cur_archive_file_ofs, unsafe(unsafe(reinterpret<uint64>(pArchive_name_1))), archive_name_size) != unsafe(reinterpret<size_t>(archive_name_size))) {
                                    pZip_62.m_pFree(pZip_62.m_pAlloc_opaque, unsafe(unsafe(reinterpret<uint64>(pComp_3))))
                                    return mz_zip_set_error(pZip_62, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
                                } else {
                                    cur_archive_file_ofs = uint64(cur_archive_file_ofs + archive_name_size)
                                }
                            }
                            if (uint(user_extra_data_len) > uint(0)) {
                                if (pZip_62.m_pWrite(pZip_62.m_pIO_opaque, cur_archive_file_ofs, unsafe(unsafe(reinterpret<uint64>(user_extra_data))), unsafe(reinterpret<size_t>(user_extra_data_len))) != unsafe(reinterpret<size_t>(user_extra_data_len))) {
                                    return mz_zip_set_error(pZip_62, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
                                } else {
                                    cur_archive_file_ofs = uint64(cur_archive_file_ofs + uint64(user_extra_data_len))
                                }
                            }
                            if (uint64(store_data_uncompressed) != uint64(0)) {
                                if (pZip_62.m_pWrite(pZip_62.m_pIO_opaque, cur_archive_file_ofs, pBuf_16, buf_size_7) != unsafe(reinterpret<size_t>(buf_size_7))) {
                                    pZip_62.m_pFree(pZip_62.m_pAlloc_opaque, unsafe(unsafe(reinterpret<uint64>(pComp_3))))
                                    return mz_zip_set_error(pZip_62, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
                                } else {
                                    cur_archive_file_ofs = uint64(cur_archive_file_ofs + buf_size_7)
                                    comp_size_1 = uint64(buf_size_7)
                                }
                            } elif (uint64(buf_size_7) != uint64(0)) {
                                state.m_pZip = unsafe(unsafe(reinterpret<mz_zip_archive?>(pZip_62)))
                                state.m_cur_archive_file_ofs = uint64(cur_archive_file_ofs)
                                state.m_comp_size = uint64((uint64(0) == uint64(0)) ? 1 : 0)
                                if (int((tdefl_init(pComp_3, mz_zip_writer_add_put_buf_callback, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(state) == int(0))))), int(tdefl_create_comp_flags_from_zip_params(int(level_7), -15, MZ_DEFAULT_STRATEGY)))) ? 1 : 0) != int(TDEFL_STATUS_OKAY) || int(tdefl_compress_buffer(pComp_3, pBuf_16, buf_size_7, unsafe(reinterpret<tdefl_flush>(TDEFL_FINISH)))) != int(TDEFL_STATUS_DONE)) {
                                    pZip_62.m_pFree(pZip_62.m_pAlloc_opaque, unsafe(unsafe(reinterpret<uint64>(pComp_3))))
                                    return mz_zip_set_error(pZip_62, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_COMPRESSION_FAILED)))
                                } else {
                                    comp_size_1 = uint64(state.m_comp_size)
                                    cur_archive_file_ofs = uint64(state.m_cur_archive_file_ofs)
                                }
                            }
                            pZip_62.m_pFree(pZip_62.m_pAlloc_opaque, unsafe(unsafe(reinterpret<uint64>(pComp_3))))
                            pComp_3 = null
                            if (uint64(uncomp_size_1) != uint64(0)) {
                                local_dir_footer_size = uint(MZ_ZIP_DATA_DESCRIPTER_SIZE32)
                                {
                                    if (uint64(int(bit_flags_0) & int(MZ_ZIP_LDH_BIT_FLAG_HAS_LOCATOR)) != uint64(0)) {
                                    } else {
                                        c2da___assert_fail(null, null, uint(0), null)
                                    }
                                }
                                mz_write_le32(unsafe(unsafe(addr(local_dir_footer[0])) + 0), uint(MZ_ZIP_DATA_DESCRIPTOR_ID))
                                mz_write_le32(unsafe(unsafe(addr(local_dir_footer[0])) + 4), uncomp_crc32_1)
                                if (unsafe(unsafe(reinterpret<uint64>(pExtra_data_2)) == unsafe(reinterpret<uint64>(null)))) {
                                    if (uint64(comp_size_1) > uint64(0xffffffff)) {
                                        return mz_zip_set_error(pZip_62, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ARCHIVE_TOO_LARGE)))
                                    } else {
                                        mz_write_le32(unsafe(unsafe(addr(local_dir_footer[0])) + 8), uint(comp_size_1))
                                        mz_write_le32(unsafe(unsafe(addr(local_dir_footer[0])) + 12), uint(uncomp_size_1))
                                    }
                                } else {
                                    mz_write_le64(unsafe(unsafe(addr(local_dir_footer[0])) + 8), comp_size_1)
                                    mz_write_le64(unsafe(unsafe(addr(local_dir_footer[0])) + 16), uncomp_size_1)
                                    local_dir_footer_size = uint(((uint(MZ_ZIP_DATA_DESCRIPTER_SIZE64) == uint(0)) ? 1 : 0) ? 1 : 0)
                                }
                                if (pZip_62.m_pWrite(pZip_62.m_pIO_opaque, cur_archive_file_ofs, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(local_dir_footer[0]))))), unsafe(reinterpret<size_t>(local_dir_footer_size))) != unsafe(reinterpret<size_t>(local_dir_footer_size))) {
                                    return 0
                                } else {
                                    cur_archive_file_ofs = uint64(cur_archive_file_ofs + uint64(local_dir_footer_size))
                                }
                            }
                            if (unsafe(unsafe(reinterpret<uint64>(pExtra_data_2)) != unsafe(reinterpret<uint64>(null)))) {
                                var c2da_fresh101 : uint64? = null
                                if (uint64(uncomp_size_1) >= uint64(0xffffffff)) {
                                    c2da_fresh101 = unsafe(addr(uncomp_size_1))
                                } else {
                                    c2da_fresh101 = null
                                }
                                var c2da_fresh102 : uint64? = null
                                if (uint64(uncomp_size_1) >= uint64(0xffffffff)) {
                                    c2da_fresh102 = unsafe(addr(comp_size_1))
                                } else {
                                    c2da_fresh102 = null
                                }
                                var c2da_fresh103 : uint64? = null
                                if (uint64(local_dir_header_ofs) >= uint64(0xffffffff)) {
                                    c2da_fresh103 = unsafe(addr(local_dir_header_ofs))
                                } else {
                                    c2da_fresh103 = null
                                }
                                extra_size = uint(mz_zip_writer_create_zip64_extra_data(unsafe(addr(extra_data[0])), c2da_fresh101, c2da_fresh102, c2da_fresh103))
                            }
                            if (uint64(mz_zip_writer_add_to_central_dir(pZip_62, pArchive_name_1, uint16(archive_name_size), unsafe(unsafe(reinterpret<uint64>(pExtra_data_2))), uint16(extra_size), pComment_2, comment_size_0, uncomp_size_1, comp_size_1, uncomp_crc32_1, method_2, bit_flags_0, dos_time, dos_date, local_dir_header_ofs, ext_attributes, user_extra_data_central, user_extra_data_central_len)) == uint64(0)) {
                                return 0
                            } else {
                                pZip_62.m_total_files = pZip_62.m_total_files + uint(1)
                                pZip_62.m_total_files
                                pZip_62.m_archive_size = uint64(cur_archive_file_ofs)
                                return 1
                            }
                        }
                    }
                }
            }
        }
    }
}
[export]
def mz_zip_writer_add_to_central_dir(var pZip_63 : mz_zip_archive?; var pFilename_9 : int8 const?; var filename_size_0 : uint16; var pExtra : uint64; var extra_size_0 : uint16; var pComment_3 : uint64; var comment_size_1 : uint16; var uncomp_size_2 : uint64; var comp_size_2 : uint64; var uncomp_crc32_2 : uint; var method_3 : uint16; var bit_flags_1 : uint16; var dos_time_0 : uint16; var dos_date_0 : uint16; var local_header_ofs_1 : uint64; var ext_attributes_0 : uint; var user_extra_data_0 : int8 const?; var user_extra_data_len_0 : uint) : int {
    var pState_12 : mz_zip_internal_state_tag? = null
    var central_dir_ofs : uint = uint(0)
    var orig_central_dir_size : size_t = unsafe(reinterpret<size_t>(0))
    var central_dir_header : array<uint8> = []
    pState_12 = pZip_63.m_pState
    central_dir_ofs = uint(pState_12.m_central_dir.m_size)
    orig_central_dir_size = pState_12.m_central_dir.m_size
    if (uint64(pZip_63.m_pState.m_zip64) == uint64(0)) {
        if (uint64(local_header_ofs_1) > uint64(0xffffffff)) {
            return mz_zip_set_error(pZip_63, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_TOO_LARGE)))
        }
    }
    if (uint64(pState_12.m_central_dir.m_size) + (uint64(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE) + uint64(filename_size_0)) + uint64(extra_size_0) + uint64(user_extra_data_len_0) + uint64(comment_size_1) >= uint64(0xffffffff)) {
        return mz_zip_set_error(pZip_63, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNSUPPORTED_CDIR_SIZE)))
    } elif (uint64((mz_zip_writer_create_central_dir_header(pZip_63, unsafe(addr(central_dir_header[0]) == uint64(0)), filename_size_0, uint16(uint(extra_size_0) + uint(user_extra_data_len_0)), comment_size_1, uncomp_size_2, comp_size_2, uncomp_crc32_2, method_3, bit_flags_1, dos_time_0, dos_date_0, local_header_ofs_1, ext_attributes_0)) ? 1 : 0) == uint64(0)) {
        return mz_zip_set_error(pZip_63, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INTERNAL_ERROR)))
    } elif (uint64((mz_zip_array_push_back(pZip_63, unsafe(addr(pState_12.m_central_dir) == uint64(0)), unsafe(unsafe(reinterpret<uint64>(unsafe(addr(central_dir_header[0]))))), unsafe(reinterpret<size_t>(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE)))) ? 1 : 0) == uint64(0) || uint64(mz_zip_array_push_back(pZip_63, unsafe(addr(pState_12.m_central_dir)), unsafe(unsafe(reinterpret<uint64>(pFilename_9))), unsafe(reinterpret<size_t>(filename_size_0)))) == uint64(0) || uint64(mz_zip_array_push_back(pZip_63, unsafe(addr(pState_12.m_central_dir)), pExtra, unsafe(reinterpret<size_t>(extra_size_0)))) == uint64(0) || uint64(mz_zip_array_push_back(pZip_63, unsafe(addr(pState_12.m_central_dir)), unsafe(unsafe(reinterpret<uint64>(user_extra_data_0))), unsafe(reinterpret<size_t>(user_extra_data_len_0)))) == uint64(0) || uint64(mz_zip_array_push_back(pZip_63, unsafe(addr(pState_12.m_central_dir)), pComment_3, unsafe(reinterpret<size_t>(comment_size_1)))) == uint64(0) || uint64(mz_zip_array_push_back(pZip_63, unsafe(addr(pState_12.m_central_dir_offsets)), unsafe(unsafe(reinterpret<uint64>(unsafe(addr(central_dir_ofs))))), unsafe(reinterpret<size_t>(1)))) == uint64(0)) {
        mz_zip_array_resize(pZip_63, unsafe(addr(pState_12.m_central_dir)), orig_central_dir_size, uint(0))
        return mz_zip_set_error(pZip_63, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
    } else {
        return 1
    }
}
[export]
def mz_zip_array_push_back(var pZip_64 : mz_zip_archive?; var pArray_3 : mz_zip_array?; var pElements : uint64; var n_13 : size_t) : int {
    var orig_size : size_t = unsafe(reinterpret<size_t>(0))
    orig_size = pArray_3.m_size
    if (uint64((mz_zip_array_resize(pZip_64, pArray_3, unsafe(reinterpret<size_t>(orig_size) == uint64(0)) + unsafe(reinterpret<size_t>(n_13)), uint(1))) ? 1 : 0) == uint64(0)) {
        return 0
    } else {
        if (unsafe(reinterpret<size_t>(n_13)) > unsafe(reinterpret<size_t>(0))) {
            memcpy(unsafe(unsafe(reinterpret<uint64>(unsafe(pArray_3.m_p + unsafe(reinterpret<size_t>(orig_size)) * unsafe(reinterpret<size_t>(pArray_3.m_element_size)))))), pElements, uint64(unsafe(reinterpret<size_t>(n_13)) * unsafe(reinterpret<size_t>(pArray_3.m_element_size))))
        }
        return 1
    }
}
[export]
def mz_zip_writer_create_central_dir_header(var pZip_65 : mz_zip_archive?; var pDst : uint8?; var filename_size_1 : uint16; var extra_size_1 : uint16; var comment_size_2 : uint16; var uncomp_size_3 : uint64; var comp_size_3 : uint64; var uncomp_crc32_3 : uint; var method_4 : uint16; var bit_flags_2 : uint16; var dos_time_1 : uint16; var dos_date_1 : uint16; var local_header_ofs_2 : uint64; var ext_attributes_1 : uint) : int {
    pZip_65
    memset(unsafe(unsafe(reinterpret<uint64>(pDst))), 0, uint64((uint64(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE) == uint64(0)) ? 1 : 0))
    mz_write_le32(unsafe(pDst + int(MZ_ZIP_CDH_SIG_OFS)), uint(MZ_ZIP_CENTRAL_DIR_HEADER_SIG))
    var c2da_fresh104 : int = int(0)
    if (uint64((int(method_4) == int(0)) ? 1 : 0) != uint64(0)) {
        c2da_fresh104 = 20
    } else {
        c2da_fresh104 = 0
    }
    mz_write_le16(unsafe(pDst + int(MZ_ZIP_CDH_VERSION_NEEDED_OFS)), uint16(c2da_fresh104))
    mz_write_le16(unsafe(pDst + int(MZ_ZIP_CDH_BIT_FLAG_OFS)), bit_flags_2)
    mz_write_le16(unsafe(pDst + int(MZ_ZIP_CDH_METHOD_OFS)), method_4)
    mz_write_le16(unsafe(pDst + int(MZ_ZIP_CDH_FILE_TIME_OFS)), dos_time_1)
    mz_write_le16(unsafe(pDst + int(MZ_ZIP_CDH_FILE_DATE_OFS)), dos_date_1)
    mz_write_le32(unsafe(pDst + int(MZ_ZIP_CDH_CRC32_OFS)), uncomp_crc32_3)
    var c2da_fresh105 : uint64 = uint64(0)
    if (uint64(comp_size_3) < uint64(0xffffffff)) {
        c2da_fresh105 = comp_size_3
    } else {
        c2da_fresh105 = uint64(0xffffffff)
    }
    mz_write_le32(unsafe(pDst + int(MZ_ZIP_CDH_COMPRESSED_SIZE_OFS)), uint(c2da_fresh105))
    var c2da_fresh106 : uint64 = uint64(0)
    if (uint64(uncomp_size_3) < uint64(0xffffffff)) {
        c2da_fresh106 = uncomp_size_3
    } else {
        c2da_fresh106 = uint64(0xffffffff)
    }
    mz_write_le32(unsafe(pDst + int(MZ_ZIP_CDH_DECOMPRESSED_SIZE_OFS)), uint(c2da_fresh106))
    mz_write_le16(unsafe(pDst + int(MZ_ZIP_CDH_FILENAME_LEN_OFS)), filename_size_1)
    mz_write_le16(unsafe(pDst + int(MZ_ZIP_CDH_EXTRA_LEN_OFS)), extra_size_1)
    mz_write_le16(unsafe(pDst + int(MZ_ZIP_CDH_COMMENT_LEN_OFS)), comment_size_2)
    mz_write_le32(unsafe(pDst + int(MZ_ZIP_CDH_EXTERNAL_ATTR_OFS)), ext_attributes_1)
    var c2da_fresh107 : uint64 = uint64(0)
    if (uint64(local_header_ofs_2) < uint64(0xffffffff)) {
        c2da_fresh107 = local_header_ofs_2
    } else {
        c2da_fresh107 = uint64(0xffffffff)
    }
    mz_write_le32(unsafe(pDst + int(MZ_ZIP_CDH_LOCAL_HEADER_OFS)), uint(c2da_fresh107))
    return 1
}
[export]
def mz_write_le32(var p_11 : uint8?; var v : uint) {
    unsafe(unsafe(unsafe(reinterpret<uint8?>(p_11)))[0]) = uint8(uint8(v))
    unsafe(unsafe(unsafe(reinterpret<uint8?>(p_11)))[1]) = uint8(uint8(uint(((uint(v) == uint(0)) ? 1 : 0) ? 1 : 0) >> uint(((uint(8) == uint(0)) ? 1 : 0) ? 1 : 0)))
    unsafe(unsafe(unsafe(reinterpret<uint8?>(p_11)))[2]) = uint8(uint8(uint(((uint(v) == uint(0)) ? 1 : 0) ? 1 : 0) >> uint(((uint(16) == uint(0)) ? 1 : 0) ? 1 : 0)))
    unsafe(unsafe(unsafe(reinterpret<uint8?>(p_11)))[3]) = uint8(uint8(uint(((uint(v) == uint(0)) ? 1 : 0) ? 1 : 0) >> uint(((uint(24) == uint(0)) ? 1 : 0) ? 1 : 0)))
    return
}
[export]
def mz_write_le16(var p_12 : uint8?; var v_0 : uint16) {
    unsafe(unsafe(unsafe(reinterpret<uint8?>(p_12)))[0]) = uint8(uint8(v_0))
    unsafe(unsafe(unsafe(reinterpret<uint8?>(p_12)))[1]) = uint8(uint8(uint(((int(v_0) == int(0)) ? 1 : 0) ? 1 : 0) >> uint(8)))
    return
}
[export]
def mz_zip_writer_create_zip64_extra_data(var pBuf_17 : uint8?; var pUncomp_size : uint64?; var pComp_size : uint64?; var pLocal_header_ofs : uint64?) : uint {
    var pDst_0 : uint8? = null
    var field_size : uint = uint(0)
    pDst_0 = pBuf_17
    field_size = uint(0)
    mz_write_le16(unsafe(pDst_0 + 0), uint16(MZ_ZIP64_EXTENDED_INFORMATION_FIELD_HEADER_ID))
    mz_write_le16(unsafe(pDst_0 + 2), uint16(0))
    pDst_0 = unsafe(unsafe(reinterpret<uint8?>(unsafe(pDst_0 + 4 * int((uint64(2) == uint64(0)) ? 1 : 0)))))
    if (pUncomp_size != null) {
        mz_write_le64(pDst_0, *pUncomp_size)
        pDst_0 = unsafe(unsafe(reinterpret<uint8?>(unsafe(pDst_0 + 4))))
        field_size = uint64(field_size + 4)
    }
    if (pComp_size != null) {
        mz_write_le64(pDst_0, *pComp_size)
        pDst_0 = unsafe(unsafe(reinterpret<uint8?>(unsafe(pDst_0 + 4))))
        field_size = uint64(field_size + 4)
    }
    if (pLocal_header_ofs != null) {
        mz_write_le64(pDst_0, *pLocal_header_ofs)
        pDst_0 = unsafe(unsafe(reinterpret<uint8?>(unsafe(pDst_0 + 4))))
        field_size = uint64(field_size + 4)
    }
    mz_write_le16(unsafe(pBuf_17 + 2), uint16(field_size))
    return uint(unsafe(pDst_0 - pBuf_17))
}
[export]
def mz_write_le64(var p_13 : uint8?; var v_1 : uint64) {
    mz_write_le32(p_13, uint(v_1))
    mz_write_le32(unsafe(p_13 + 4), uint(((uint64((uint64(v_1) == uint64(0)) ? 1 : 0) >> uint64((uint64(32) == uint64(0)) ? 1 : 0)) ? 1 : 0) ? 1 : 0))
    return
}
[export]
def mz_zip_writer_add_put_buf_callback(var pBuf_18 : uint64; var len_27 : int; var pUser_0 : uint64) : int {
    var pState_13 : mz_zip_writer_add_state? = null
    pState_13 = pUser_0
    if (int((pState_13.m_pZip.m_pWrite(pState_13.m_pZip.m_pIO_opaque, pState_13.m_cur_archive_file_ofs, pBuf_18, unsafe(reinterpret<size_t>(len_27) == int(0)))) ? 1 : 0) != int(len_27)) {
        return 0
    } else {
        pState_13.m_cur_archive_file_ofs = uint64(pState_13.m_cur_archive_file_ofs + uint64(len_27))
        pState_13.m_comp_size = uint64(pState_13.m_comp_size + uint64(len_27))
        return 1
    }
}
[export]
def mz_zip_writer_create_local_dir_header(var pZip_66 : mz_zip_archive?; var pDst_1 : uint8?; var filename_size_2 : uint16; var extra_size_2 : uint16; var uncomp_size_4 : uint64; var comp_size_4 : uint64; var uncomp_crc32_4 : uint; var method_5 : uint16; var bit_flags_3 : uint16; var dos_time_2 : uint16; var dos_date_2 : uint16) : int {
    pZip_66
    memset(unsafe(unsafe(reinterpret<uint64>(pDst_1))), 0, uint64((uint64(MZ_ZIP_LOCAL_DIR_HEADER_SIZE) == uint64(0)) ? 1 : 0))
    mz_write_le32(unsafe(pDst_1 + int(MZ_ZIP_LDH_SIG_OFS)), uint(MZ_ZIP_LOCAL_DIR_HEADER_SIG))
    var c2da_fresh108 : int = int(0)
    if (uint64((int(method_5) == int(0)) ? 1 : 0) != uint64(0)) {
        c2da_fresh108 = 20
    } else {
        c2da_fresh108 = 0
    }
    mz_write_le16(unsafe(pDst_1 + int(MZ_ZIP_LDH_VERSION_NEEDED_OFS)), uint16(c2da_fresh108))
    mz_write_le16(unsafe(pDst_1 + int(MZ_ZIP_LDH_BIT_FLAG_OFS)), bit_flags_3)
    mz_write_le16(unsafe(pDst_1 + int(MZ_ZIP_LDH_METHOD_OFS)), method_5)
    mz_write_le16(unsafe(pDst_1 + int(MZ_ZIP_LDH_FILE_TIME_OFS)), dos_time_2)
    mz_write_le16(unsafe(pDst_1 + int(MZ_ZIP_LDH_FILE_DATE_OFS)), dos_date_2)
    mz_write_le32(unsafe(pDst_1 + int(MZ_ZIP_LDH_CRC32_OFS)), uncomp_crc32_4)
    var c2da_fresh109 : uint64 = uint64(0)
    if (uint64(comp_size_4) < uint64(0xffffffff)) {
        c2da_fresh109 = comp_size_4
    } else {
        c2da_fresh109 = uint64(0xffffffff)
    }
    mz_write_le32(unsafe(pDst_1 + int(MZ_ZIP_LDH_COMPRESSED_SIZE_OFS)), uint(c2da_fresh109))
    var c2da_fresh110 : uint64 = uint64(0)
    if (uint64(uncomp_size_4) < uint64(0xffffffff)) {
        c2da_fresh110 = uncomp_size_4
    } else {
        c2da_fresh110 = uint64(0xffffffff)
    }
    mz_write_le32(unsafe(pDst_1 + int(MZ_ZIP_LDH_DECOMPRESSED_SIZE_OFS)), uint(c2da_fresh110))
    mz_write_le16(unsafe(pDst_1 + int(MZ_ZIP_LDH_FILENAME_LEN_OFS)), filename_size_2)
    mz_write_le16(unsafe(pDst_1 + int(MZ_ZIP_LDH_EXTRA_LEN_OFS)), extra_size_2)
    return 1
}
[export]
def mz_zip_writer_write_zeros(var pZip_67 : mz_zip_archive?; var cur_file_ofs_3 : uint64; var n_14 : uint) : int {
    var buf_1 : array<int8> = []
    var s_5 : uint = uint(0)
    var c2da_fresh111 : uint64 = uint64(0)
    if (4 < int((uint64(n_14) == uint64(0)) ? 1 : 0)) {
        c2da_fresh111 = 4
    } else {
        c2da_fresh111 = uint64(n_14)
    }
    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(buf_1[0]))))), 0, uint64(c2da_fresh111))
    while (true) {
        if (uint64(n_14) != uint64(0)) {
            var c2da_fresh112 : uint64 = uint64(0)
            if (4 < int((uint64(n_14) == uint64(0)) ? 1 : 0)) {
                c2da_fresh112 = 4
            } else {
                c2da_fresh112 = uint64(n_14)
            }
            s_5 = uint(c2da_fresh112)
            if (pZip_67.m_pWrite(pZip_67.m_pIO_opaque, cur_file_ofs_3, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(buf_1[0]))))), unsafe(reinterpret<size_t>(s_5))) != unsafe(reinterpret<size_t>(s_5))) {
                return mz_zip_set_error(pZip_67, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
            } else {
                cur_file_ofs_3 = uint64(cur_file_ofs_3 + uint64(s_5))
                n_14 = uint(n_14 - s_5)
            }
        } else {
            return 1
        }
    }
}
[export]
def mz_zip_array_ensure_room(var pZip_68 : mz_zip_archive?; var pArray_4 : mz_zip_array?; var n_15 : size_t) : int {
    return mz_zip_array_reserve(pZip_68, pArray_4, unsafe(reinterpret<size_t>(pArray_4.m_size)) + unsafe(reinterpret<size_t>(n_15)), uint(1))
}
[export]
def mz_zip_array_reserve(var pZip_69 : mz_zip_archive?; var pArray_5 : mz_zip_array?; var new_capacity_2 : size_t; var growing_1 : uint) : int {
    if (unsafe(reinterpret<size_t>(new_capacity_2)) > unsafe(reinterpret<size_t>(pArray_5.m_capacity))) {
        if (uint64((mz_zip_array_ensure_capacity(pZip_69, pArray_5, new_capacity_2, growing_1) == uint64(0)) ? 1 : 0) == uint64(0)) {
            return 0
        }
    }
    return 1
}
[export]
def mz_zip_writer_compute_padding_needed_for_file_alignment(var pZip_70 : mz_zip_archive?) : uint {
    var n_16 : uint = uint(0)
    if (uint64(pZip_70.m_file_offset_alignment) == uint64(0)) {
        return uint(0)
    } else {
        n_16 = uint(uint(uint64(pZip_70.m_archive_size) & uint64(pZip_70.m_file_offset_alignment) - uint64(1)))
        return uint(uint64(pZip_70.m_file_offset_alignment) - uint64(n_16) & uint64(pZip_70.m_file_offset_alignment) - uint64(1))
    }
}
[export]
def mz_zip_writer_validate_archive_name(var pArchive_name_2 : int8 const?) : int {
    if (int(*pArchive_name_2) == 47) {
        return 0
    } else {
        return 1
    }
}
[export]
def mz_zip_writer_add_read_buf_callback(var pZip_71 : mz_zip_archive?; var pArchive_name_3 : int8 const?; var read_callback : mz_file_read_func; var callback_opaque : uint64; var max_size : uint64; var pFile_time : mz_dummy_time_t_tag const?; var pComment_4 : uint64; var comment_size_3 : uint16; var level_and_flags_2 : uint; var user_extra_data_1 : int8 const?; var user_extra_data_len_1 : uint; var user_extra_data_central_0 : int8 const?; var user_extra_data_central_len_0 : uint) : int {
    var gen_flags : uint16 = uint16(0)
    var uncomp_crc32_5 : uint = uint(0)
    var level_8 : uint = uint(0)
    var num_alignment_padding_bytes_0 : uint = uint(0)
    var method_6 : uint16 = uint16(0)
    var dos_time_3 : uint16 = uint16(0)
    var dos_date_3 : uint16 = uint16(0)
    var ext_attributes_2 : uint16 = uint16(0)
    var local_dir_header_ofs_0 : uint64 = uint64(0)
    var cur_archive_file_ofs_0 : uint64 = uint64(0)
    var uncomp_size_5 : uint64 = uint64(0)
    var comp_size_5 : uint64 = uint64(0)
    var archive_name_size_0 : size_t = unsafe(reinterpret<size_t>(0))
    var local_dir_header_0 : array<uint8> = []
    var pExtra_data_3 : uint8? = null
    var extra_size_3 : uint = uint(0)
    var extra_data_0 : array<uint8> = []
    var pState_14 : mz_zip_internal_state_tag? = null
    var file_ofs_3 : uint64 = uint64(0)
    var cur_archive_header_file_ofs : uint64 = uint64(0)
    var pRead_buf_1 : uint64 = uint64(0)
    var result_3 : int = int(0)
    var state_0 : mz_zip_writer_add_state = mz_zip_writer_add_state()
    var pComp_4 : tdefl_compressor? = null
    var n_17 : size_t = unsafe(reinterpret<size_t>(0))
    var status_11 : tdefl_status = unsafe(reinterpret<tdefl_status>(0))
    var flush_7 : tdefl_flush = unsafe(reinterpret<tdefl_flush>(0))
    var n_18 : size_t = unsafe(reinterpret<size_t>(0))
    var local_dir_footer_0 : array<uint8> = []
    var local_dir_footer_size_0 : uint = uint(0)
    uncomp_crc32_5 = uint(0)
    method_6 = uint16(0)
    dos_time_3 = uint16(0)
    dos_date_3 = uint16(0)
    ext_attributes_2 = uint16(0)
    cur_archive_file_ofs_0 = pZip_71.m_archive_size
    uncomp_size_5 = uint64(0)
    comp_size_5 = uint64(0)
    pExtra_data_3 = null
    extra_size_3 = uint(0)
    file_ofs_3 = uint64(0)
    if (int(level_and_flags_2) < 0) {
        level_and_flags_2 = uint(((uint(MZ_DEFAULT_LEVEL) == uint(0)) ? 1 : 0) ? 1 : 0)
    }
    level_8 = uint(uint(level_and_flags_2) & uint(15))
    var c2da_fresh113 : int = int(0)
    if (uint64(uint(level_and_flags_2) & uint(MZ_ZIP_FLAG_WRITE_HEADER_SET_SIZE)) != uint64(0)) {
        c2da_fresh113 = 0
    } else {
        c2da_fresh113 = MZ_ZIP_LDH_BIT_FLAG_HAS_LOCATOR
    }
    gen_flags = uint16(uint16(c2da_fresh113))
    if (uint64(uint(level_and_flags_2) & uint(MZ_ZIP_FLAG_ASCII_FILENAME)) == uint64(0)) {
        gen_flags = gen_flags | MZ_ZIP_GENERAL_PURPOSE_BIT_FLAG_UTF8
    }
    if (pZip_71 == null || pZip_71.m_pState == null || uint(pZip_71.m_zip_mode) != uint(MZ_ZIP_MODE_WRITING) || pArchive_name_3 == null || uint64((int(comment_size_3) == int(0)) ? 1 : 0) != uint64(0) && uint64(pComment_4) == uint64(0) || uint(level_8) > uint(MZ_UBER_COMPRESSION)) {
        return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
    } else {
        pState_14 = unsafe(unsafe(reinterpret<mz_zip_internal_state_tag?>(pZip_71.m_pState)))
        if (uint64(pState_14.m_zip64) == uint64(0) && uint64(max_size) > uint64(0xffffffff)) {
            pState_14.m_zip64 = 1
        }
        if (uint64(uint(level_and_flags_2) & uint(MZ_ZIP_FLAG_COMPRESSED_DATA)) != uint64(0)) {
            return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
        } elif (uint64((mz_zip_writer_validate_archive_name(pArchive_name_3) == uint64(0)) ? 1 : 0) == uint64(0)) {
            return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_FILENAME)))
        } else {
            if (uint64(pState_14.m_zip64) != uint64(0)) {
                if (uint(pZip_71.m_total_files) == 0xffffffff) {
                    return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_TOO_MANY_FILES)))
                }
            } elif (uint(pZip_71.m_total_files) == 0xffff) {
                pState_14.m_zip64 = 1
            }
            archive_name_size_0 = unsafe(reinterpret<size_t>(strlen(pArchive_name_3)))
            if (unsafe(reinterpret<size_t>(archive_name_size_0)) > unsafe(reinterpret<size_t>(0xffff))) {
                return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_FILENAME)))
            } else {
                num_alignment_padding_bytes_0 = uint(mz_zip_writer_compute_padding_needed_for_file_alignment(pZip_71))
                if (uint64(pState_14.m_central_dir.m_size) + (uint64(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE) + uint64((uint64(unsafe(reinterpret<size_t>(archive_name_size_0) == uint64(0)))) ? 1 : 0)) + uint64((uint64(4 * int((uint64(2) == uint64(0)) ? 1 : 0) + 4 * int((uint64(3) == uint64(0)) ? 1 : 0))) ? 1 : 0) + uint64(comment_size_3) >= uint64(0xffffffff)) {
                    return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNSUPPORTED_CDIR_SIZE)))
                } else {
                    if (uint64(pState_14.m_zip64) == uint64(0)) {
                        if (uint64(pZip_71.m_archive_size) + (uint64(num_alignment_padding_bytes_0) + uint64(MZ_ZIP_LOCAL_DIR_HEADER_SIZE)) + uint64((uint64(unsafe(reinterpret<size_t>(archive_name_size_0) == uint64(0)))) ? 1 : 0) + uint64(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE) + uint64((uint64(unsafe(reinterpret<size_t>(archive_name_size_0) == uint64(0)))) ? 1 : 0) + uint64(comment_size_3) + uint64(user_extra_data_len_1) + uint64((uint64(unsafe(reinterpret<size_t>(pState_14.m_central_dir.m_size) == uint64(0)))) ? 1 : 0) + uint64(MZ_ZIP_END_OF_CENTRAL_DIR_HEADER_SIZE) + uint64(1024) + uint64(MZ_ZIP_DATA_DESCRIPTER_SIZE32) + uint64(user_extra_data_central_len_0) > uint64(0xffffffff)) {
                            pState_14.m_zip64 = 1
                        }
                    }
                    pFile_time
                    if (uint64(max_size) <= uint64(3)) {
                        level_8 = uint(((uint(0) == uint(0)) ? 1 : 0) ? 1 : 0)
                    }
                    if (uint64((mz_zip_writer_write_zeros(pZip_71, cur_archive_file_ofs_0, num_alignment_padding_bytes_0) == uint64(0)) ? 1 : 0) == uint64(0)) {
                        return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
                    } else {
                        cur_archive_file_ofs_0 = uint64(cur_archive_file_ofs_0 + uint64(num_alignment_padding_bytes_0))
                        local_dir_header_ofs_0 = uint64(cur_archive_file_ofs_0)
                        if (uint64(pZip_71.m_file_offset_alignment) != uint64(0)) {
                            {
                                if (uint64(uint64(cur_archive_file_ofs_0) & uint64(pZip_71.m_file_offset_alignment) - uint64(1)) == uint64(0)) {
                                } else {
                                    c2da___assert_fail(null, null, uint(0), null)
                                }
                            }
                        }
                        if (uint64(max_size) != uint64(0) && uint64(level_8) != uint64(0)) {
                            method_6 = uint16(uint16(8))
                        }
                        memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(local_dir_header_0[0]))))), 0, uint64(4))
                        if (uint64(pState_14.m_zip64) != uint64(0)) {
                            if (uint64(max_size) >= uint64(0xffffffff) || uint64(local_dir_header_ofs_0) >= uint64(0xffffffff)) {
                                pExtra_data_3 = unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(extra_data_0[0])))))
                                if (uint64(uint(level_and_flags_2) & uint(MZ_ZIP_FLAG_WRITE_HEADER_SET_SIZE)) != uint64(0)) {
                                    var c2da_fresh114 : uint64? = null
                                    if (uint64(max_size) >= uint64(0xffffffff)) {
                                        c2da_fresh114 = unsafe(addr(uncomp_size_5))
                                    } else {
                                        c2da_fresh114 = null
                                    }
                                    var c2da_fresh115 : uint64? = null
                                    if (uint64(max_size) >= uint64(0xffffffff)) {
                                        c2da_fresh115 = unsafe(addr(comp_size_5))
                                    } else {
                                        c2da_fresh115 = null
                                    }
                                    var c2da_fresh116 : uint64? = null
                                    if (uint64(local_dir_header_ofs_0) >= uint64(0xffffffff)) {
                                        c2da_fresh116 = unsafe(addr(local_dir_header_ofs_0))
                                    } else {
                                        c2da_fresh116 = null
                                    }
                                    extra_size_3 = uint(mz_zip_writer_create_zip64_extra_data(unsafe(addr(extra_data_0[0])), c2da_fresh114, c2da_fresh115, c2da_fresh116))
                                } else {
                                    var c2da_fresh117 : uint64? = null
                                    if (uint64(local_dir_header_ofs_0) >= uint64(0xffffffff)) {
                                        c2da_fresh117 = unsafe(addr(local_dir_header_ofs_0))
                                    } else {
                                        c2da_fresh117 = null
                                    }
                                    extra_size_3 = uint(mz_zip_writer_create_zip64_extra_data(unsafe(addr(extra_data_0[0])), null, null, c2da_fresh117))
                                }
                            }
                            if (uint64((mz_zip_writer_create_local_dir_header(pZip_71, unsafe(addr(local_dir_header_0[0]) == uint64(0)), uint16(archive_name_size_0), uint16(uint(extra_size_3) + uint(user_extra_data_len_1)), uint64(0), uint64(0), uint(0), method_6, gen_flags, dos_time_3, dos_date_3)) ? 1 : 0) == uint64(0)) {
                                return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INTERNAL_ERROR)))
                            } elif (pZip_71.m_pWrite(pZip_71.m_pIO_opaque, cur_archive_file_ofs_0, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(local_dir_header_0[0]))))), 4) != unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(4))))) {
                                return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
                            } else {
                                cur_archive_file_ofs_0 = uint64(cur_archive_file_ofs_0 + 4)
                                if (pZip_71.m_pWrite(pZip_71.m_pIO_opaque, cur_archive_file_ofs_0, unsafe(unsafe(reinterpret<uint64>(pArchive_name_3))), archive_name_size_0) != unsafe(reinterpret<size_t>(archive_name_size_0))) {
                                    return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
                                } else {
                                    cur_archive_file_ofs_0 = uint64(cur_archive_file_ofs_0 + archive_name_size_0)
                                    if (pZip_71.m_pWrite(pZip_71.m_pIO_opaque, cur_archive_file_ofs_0, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(extra_data_0[0]))))), unsafe(reinterpret<size_t>(extra_size_3))) != unsafe(reinterpret<size_t>(extra_size_3))) {
                                        return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
                                    } else {
                                        cur_archive_file_ofs_0 = uint64(cur_archive_file_ofs_0 + uint64(extra_size_3))
                                    }
                                }
                            }
                        } elif (uint64(comp_size_5) > uint64(0xffffffff) || uint64(cur_archive_file_ofs_0) > uint64(0xffffffff)) {
                            return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ARCHIVE_TOO_LARGE)))
                        } elif (uint64((mz_zip_writer_create_local_dir_header(pZip_71, unsafe(addr(local_dir_header_0[0]) == uint64(0)), uint16(archive_name_size_0), uint16(user_extra_data_len_1), uint64(0), uint64(0), uint(0), method_6, gen_flags, dos_time_3, dos_date_3)) ? 1 : 0) == uint64(0)) {
                            return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INTERNAL_ERROR)))
                        } elif (pZip_71.m_pWrite(pZip_71.m_pIO_opaque, cur_archive_file_ofs_0, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(local_dir_header_0[0]))))), 4) != unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(4))))) {
                            return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
                        } else {
                            cur_archive_file_ofs_0 = uint64(cur_archive_file_ofs_0 + 4)
                            if (pZip_71.m_pWrite(pZip_71.m_pIO_opaque, cur_archive_file_ofs_0, unsafe(unsafe(reinterpret<uint64>(pArchive_name_3))), archive_name_size_0) != unsafe(reinterpret<size_t>(archive_name_size_0))) {
                                return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
                            } else {
                                cur_archive_file_ofs_0 = uint64(cur_archive_file_ofs_0 + archive_name_size_0)
                            }
                        }
                        if (uint(user_extra_data_len_1) > uint(0)) {
                            if (pZip_71.m_pWrite(pZip_71.m_pIO_opaque, cur_archive_file_ofs_0, unsafe(unsafe(reinterpret<uint64>(user_extra_data_1))), unsafe(reinterpret<size_t>(user_extra_data_len_1))) != unsafe(reinterpret<size_t>(user_extra_data_len_1))) {
                                return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
                            } else {
                                cur_archive_file_ofs_0 = uint64(cur_archive_file_ofs_0 + uint64(user_extra_data_len_1))
                            }
                        }
                        if (uint64(max_size) != uint64(0)) {
                            pRead_buf_1 = pZip_71.m_pAlloc(pZip_71.m_pAlloc_opaque, unsafe(reinterpret<size_t>(1)), unsafe(reinterpret<size_t>(MZ_ZIP_MAX_IO_BUF_SIZE)))
                            if (uint64(pRead_buf_1) == uint64(0)) {
                                return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                            } elif (uint64(level_8) == uint64(0)) {
                                while (true) {
                                    if (!(uint64(1) != uint64(0))) {
                                        if (false) {
                                        }
                                    }
                                    n_17 = read_callback(callback_opaque, file_ofs_3, pRead_buf_1, unsafe(reinterpret<size_t>(MZ_ZIP_MAX_IO_BUF_SIZE)))
                                    if (uint64((unsafe(reinterpret<size_t>(n_17) == uint64(0))) ? 1 : 0) == uint64(0)) {
                                        if (false) {
                                        }
                                        if (false) {
                                        }
                                    } elif (unsafe(reinterpret<size_t>(n_17)) > unsafe(reinterpret<size_t>(MZ_ZIP_MAX_IO_BUF_SIZE)) || uint64(file_ofs_3) + uint64((uint64(unsafe(reinterpret<size_t>(n_17) == uint64(0)))) ? 1 : 0) > uint64(max_size)) {
                                        pZip_71.m_pFree(pZip_71.m_pAlloc_opaque, pRead_buf_1)
                                        return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_READ_FAILED)))
                                    } elif (pZip_71.m_pWrite(pZip_71.m_pIO_opaque, cur_archive_file_ofs_0, pRead_buf_1, n_17) != unsafe(reinterpret<size_t>(n_17))) {
                                        pZip_71.m_pFree(pZip_71.m_pAlloc_opaque, pRead_buf_1)
                                        return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
                                    } else {
                                        file_ofs_3 = uint64(file_ofs_3 + n_17)
                                        uncomp_crc32_5 = uint(uint(mz_crc32(uint64(uncomp_crc32_5), pRead_buf_1, n_17)))
                                        cur_archive_file_ofs_0 = uint64(cur_archive_file_ofs_0 + n_17)
                                    }
                                }
                                uncomp_size_5 = uint64(file_ofs_3)
                                comp_size_5 = uint64(uncomp_size_5)
                                pZip_71.m_pFree(pZip_71.m_pAlloc_opaque, pRead_buf_1)
                            } else {
                                result_3 = 0
                                pComp_4 = pZip_71.m_pAlloc(pZip_71.m_pAlloc_opaque, unsafe(reinterpret<size_t>(1)), 4)
                                if (pComp_4 == null) {
                                    pZip_71.m_pFree(pZip_71.m_pAlloc_opaque, pRead_buf_1)
                                    return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                                } else {
                                    state_0.m_pZip = unsafe(unsafe(reinterpret<mz_zip_archive?>(pZip_71)))
                                    state_0.m_cur_archive_file_ofs = uint64(cur_archive_file_ofs_0)
                                    state_0.m_comp_size = uint64((uint64(0) == uint64(0)) ? 1 : 0)
                                    if (int((tdefl_init(pComp_4, mz_zip_writer_add_put_buf_callback, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(state_0) == int(0))))), int(tdefl_create_comp_flags_from_zip_params(int(level_8), -15, MZ_DEFAULT_STRATEGY)))) ? 1 : 0) != int(TDEFL_STATUS_OKAY)) {
                                        pZip_71.m_pFree(pZip_71.m_pAlloc_opaque, unsafe(unsafe(reinterpret<uint64>(pComp_4))))
                                        pZip_71.m_pFree(pZip_71.m_pAlloc_opaque, pRead_buf_1)
                                        return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INTERNAL_ERROR)))
                                    } else {
                                        if (false) {
                                        }
                                    }
                                }
                            }
                        }
                        if (uint64(uint(level_and_flags_2) & uint(MZ_ZIP_FLAG_WRITE_HEADER_SET_SIZE)) == uint64(0)) {
                            local_dir_footer_size_0 = uint(MZ_ZIP_DATA_DESCRIPTER_SIZE32)
                            mz_write_le32(unsafe(unsafe(addr(local_dir_footer_0[0])) + 0), uint(MZ_ZIP_DATA_DESCRIPTOR_ID))
                            mz_write_le32(unsafe(unsafe(addr(local_dir_footer_0[0])) + 4), uncomp_crc32_5)
                            if (unsafe(unsafe(reinterpret<uint64>(pExtra_data_3)) == unsafe(reinterpret<uint64>(null)))) {
                                if (uint64(comp_size_5) > uint64(0xffffffff)) {
                                    return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ARCHIVE_TOO_LARGE)))
                                } else {
                                    mz_write_le32(unsafe(unsafe(addr(local_dir_footer_0[0])) + 8), uint(comp_size_5))
                                    mz_write_le32(unsafe(unsafe(addr(local_dir_footer_0[0])) + 12), uint(uncomp_size_5))
                                }
                            } else {
                                mz_write_le64(unsafe(unsafe(addr(local_dir_footer_0[0])) + 8), comp_size_5)
                                mz_write_le64(unsafe(unsafe(addr(local_dir_footer_0[0])) + 16), uncomp_size_5)
                                local_dir_footer_size_0 = uint(((uint(MZ_ZIP_DATA_DESCRIPTER_SIZE64) == uint(0)) ? 1 : 0) ? 1 : 0)
                            }
                            if (pZip_71.m_pWrite(pZip_71.m_pIO_opaque, cur_archive_file_ofs_0, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(local_dir_footer_0[0]))))), unsafe(reinterpret<size_t>(local_dir_footer_size_0))) != unsafe(reinterpret<size_t>(local_dir_footer_size_0))) {
                                return 0
                            } else {
                                cur_archive_file_ofs_0 = uint64(cur_archive_file_ofs_0 + uint64(local_dir_footer_size_0))
                            }
                        }
                        if (uint64(uint(level_and_flags_2) & uint(MZ_ZIP_FLAG_WRITE_HEADER_SET_SIZE)) != uint64(0)) {
                            if (unsafe(unsafe(reinterpret<uint64>(pExtra_data_3)) != unsafe(reinterpret<uint64>(null)))) {
                                var c2da_fresh118 : uint64? = null
                                if (uint64(max_size) >= uint64(0xffffffff)) {
                                    c2da_fresh118 = unsafe(addr(uncomp_size_5))
                                } else {
                                    c2da_fresh118 = null
                                }
                                var c2da_fresh119 : uint64? = null
                                if (uint64(max_size) >= uint64(0xffffffff)) {
                                    c2da_fresh119 = unsafe(addr(comp_size_5))
                                } else {
                                    c2da_fresh119 = null
                                }
                                var c2da_fresh120 : uint64? = null
                                if (uint64(local_dir_header_ofs_0) >= uint64(0xffffffff)) {
                                    c2da_fresh120 = unsafe(addr(local_dir_header_ofs_0))
                                } else {
                                    c2da_fresh120 = null
                                }
                                extra_size_3 = uint(mz_zip_writer_create_zip64_extra_data(unsafe(addr(extra_data_0[0])), c2da_fresh118, c2da_fresh119, c2da_fresh120))
                            }
                            var c2da_fresh121 : uint64 = uint64(0)
                            if (uint64(max_size) >= uint64(0xffffffff)) {
                                c2da_fresh121 = uint64(0xffffffff)
                            } else {
                                c2da_fresh121 = uncomp_size_5
                            }
                            var c2da_fresh122 : uint64 = uint64(0)
                            if (uint64(max_size) >= uint64(0xffffffff)) {
                                c2da_fresh122 = uint64(0xffffffff)
                            } else {
                                c2da_fresh122 = comp_size_5
                            }
                            if (uint64((mz_zip_writer_create_local_dir_header(pZip_71, unsafe(addr(local_dir_header_0[0]) == uint64(0)), uint16(archive_name_size_0), uint16(uint(extra_size_3) + uint(user_extra_data_len_1)), c2da_fresh121, c2da_fresh122, uncomp_crc32_5, method_6, gen_flags, dos_time_3, dos_date_3)) ? 1 : 0) == uint64(0)) {
                                return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INTERNAL_ERROR)))
                            } else {
                                cur_archive_header_file_ofs = uint64(local_dir_header_ofs_0)
                                if (pZip_71.m_pWrite(pZip_71.m_pIO_opaque, cur_archive_header_file_ofs, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(local_dir_header_0[0]))))), 4) != unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(4))))) {
                                    return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
                                } elif (unsafe(unsafe(reinterpret<uint64>(pExtra_data_3)) != unsafe(reinterpret<uint64>(null)))) {
                                    cur_archive_header_file_ofs = uint64(cur_archive_header_file_ofs + 4)
                                    if (pZip_71.m_pWrite(pZip_71.m_pIO_opaque, cur_archive_header_file_ofs, unsafe(unsafe(reinterpret<uint64>(pArchive_name_3))), archive_name_size_0) != unsafe(reinterpret<size_t>(archive_name_size_0))) {
                                        return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
                                    } else {
                                        cur_archive_header_file_ofs = uint64(cur_archive_header_file_ofs + archive_name_size_0)
                                        if (pZip_71.m_pWrite(pZip_71.m_pIO_opaque, cur_archive_header_file_ofs, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(extra_data_0[0]))))), unsafe(reinterpret<size_t>(extra_size_3))) != unsafe(reinterpret<size_t>(extra_size_3))) {
                                            return mz_zip_set_error(pZip_71, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
                                        } else {
                                            cur_archive_header_file_ofs = uint64(cur_archive_header_file_ofs + uint64(extra_size_3))
                                        }
                                    }
                                }
                            }
                        }
                        if (unsafe(unsafe(reinterpret<uint64>(pExtra_data_3)) != unsafe(reinterpret<uint64>(null)))) {
                            var c2da_fresh123 : uint64? = null
                            if (uint64(uncomp_size_5) >= uint64(0xffffffff)) {
                                c2da_fresh123 = unsafe(addr(uncomp_size_5))
                            } else {
                                c2da_fresh123 = null
                            }
                            var c2da_fresh124 : uint64? = null
                            if (uint64(uncomp_size_5) >= uint64(0xffffffff)) {
                                c2da_fresh124 = unsafe(addr(comp_size_5))
                            } else {
                                c2da_fresh124 = null
                            }
                            var c2da_fresh125 : uint64? = null
                            if (uint64(local_dir_header_ofs_0) >= uint64(0xffffffff)) {
                                c2da_fresh125 = unsafe(addr(local_dir_header_ofs_0))
                            } else {
                                c2da_fresh125 = null
                            }
                            extra_size_3 = uint(mz_zip_writer_create_zip64_extra_data(unsafe(addr(extra_data_0[0])), c2da_fresh123, c2da_fresh124, c2da_fresh125))
                        }
                        if (uint64(mz_zip_writer_add_to_central_dir(pZip_71, pArchive_name_3, uint16(archive_name_size_0), unsafe(unsafe(reinterpret<uint64>(pExtra_data_3))), uint16(extra_size_3), pComment_4, comment_size_3, uncomp_size_5, comp_size_5, uncomp_crc32_5, method_6, gen_flags, dos_time_3, dos_date_3, local_dir_header_ofs_0, uint(ext_attributes_2), user_extra_data_central_0, user_extra_data_central_len_0)) == uint64(0)) {
                            return 0
                        } else {
                            pZip_71.m_total_files = pZip_71.m_total_files + uint(1)
                            pZip_71.m_total_files
                            pZip_71.m_archive_size = uint64(cur_archive_file_ofs_0)
                            return 1
                        }
                    }
                }
            }
        }
    }
}
[export]
def mz_zip_writer_add_from_zip_reader(var pZip_72 : mz_zip_archive?; var pSource_zip : mz_zip_archive?; var src_file_index : uint) : int {
    var n_19 : uint = uint(0)
    var bit_flags_4 : uint = uint(0)
    var num_alignment_padding_bytes_1 : uint = uint(0)
    var src_central_dir_following_data_size : uint = uint(0)
    var src_archive_bytes_remaining : uint64 = uint64(0)
    var local_dir_header_ofs_1 : uint64 = uint64(0)
    var cur_src_file_ofs : uint64 = uint64(0)
    var cur_dst_file_ofs : uint64 = uint64(0)
    var local_header_u32_3 : array<uint> = []
    var pLocal_header_3 : uint8? = null
    var new_central_header : array<uint8> = []
    var orig_central_dir_size_0 : size_t = unsafe(reinterpret<size_t>(0))
    var pState_15 : mz_zip_internal_state_tag? = null
    var pBuf_19 : uint64 = uint64(0)
    var pSrc_central_header : uint8 const? = null
    var src_file_stat : mz_zip_archive_file_stat = mz_zip_archive_file_stat()
    var src_filename_len : uint = uint(0)
    var src_comment_len : uint = uint(0)
    var src_ext_len : uint = uint(0)
    var local_header_filename_size : uint = uint(0)
    var local_header_extra_len_0 : uint = uint(0)
    var local_header_comp_size_0 : uint64 = uint64(0)
    var local_header_uncomp_size_0 : uint64 = uint64(0)
    var found_zip64_ext_data_in_ldir_0 : int = int(0)
    var file_data_array_0 : mz_zip_array = mz_zip_array()
    var pExtra_data_4 : uint8 const? = null
    var extra_size_remaining_2 : uint = uint(0)
    var field_id_2 : uint = uint(0)
    var field_data_size_2 : uint = uint(0)
    var field_total_size_0 : uint = uint(0)
    var pSrc_field_data_0 : uint8 const? = null
    var approx_new_archive_size : uint64 = uint64(0)
    var has_id_0 : int = int(0)
    var pSrc_descriptor : uint8 const? = null
    var src_crc32 : uint const = uint(0)
    var src_comp_size : uint64 const = uint64(0)
    var src_uncomp_size : uint64 const = uint64(0)
    var pSrc_ext : uint8 const? = null
    var new_ext_block : mz_zip_array = mz_zip_array()
    pLocal_header_3 = unsafe(addr(local_header_u32_3[0]))
    found_zip64_ext_data_in_ldir_0 = 0
    if (pZip_72 == null || pZip_72.m_pState == null || uint(pZip_72.m_zip_mode) != uint(MZ_ZIP_MODE_WRITING) || pSource_zip.m_pRead == null) {
        return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
    } else {
        pState_15 = unsafe(unsafe(reinterpret<mz_zip_internal_state_tag?>(pZip_72.m_pState)))
        if (uint64(pSource_zip.m_pState.m_zip64) != uint64(0) && uint64(pZip_72.m_pState.m_zip64) == uint64(0)) {
            return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
        } else {
            pSrc_central_header = unsafe(unsafe(reinterpret<uint8 const?>(mz_zip_get_cdh(pSource_zip, src_file_index))))
            if (unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(reinterpret<uint8 const?>(uint64(0) == uint64(0)))))) == unsafe(reinterpret<uint64>(pSrc_central_header)))) {
                return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
            } elif ((uint(((unsafe(unsafe(pSrc_central_header + int(MZ_ZIP_CDH_SIG_OFS) == uint(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pSrc_central_header + int(MZ_ZIP_CDH_SIG_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(pSrc_central_header + int(MZ_ZIP_CDH_SIG_OFS) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(pSrc_central_header + int(MZ_ZIP_CDH_SIG_OFS) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)) != uint(MZ_ZIP_CENTRAL_DIR_HEADER_SIG)) {
                return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
            } else {
                src_filename_len = uint(((uint(unsafe(unsafe(pSrc_central_header + int(MZ_ZIP_CDH_FILENAME_LEN_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(pSrc_central_header + int(MZ_ZIP_CDH_FILENAME_LEN_OFS) == uint(0))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
                src_comment_len = uint(((uint(unsafe(unsafe(pSrc_central_header + int(MZ_ZIP_CDH_COMMENT_LEN_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(pSrc_central_header + int(MZ_ZIP_CDH_COMMENT_LEN_OFS) == uint(0))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
                src_ext_len = uint(((uint(unsafe(unsafe(pSrc_central_header + int(MZ_ZIP_CDH_EXTRA_LEN_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(pSrc_central_header + int(MZ_ZIP_CDH_EXTRA_LEN_OFS) == uint(0))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
                src_central_dir_following_data_size = uint(uint(src_filename_len) + (uint(src_ext_len) + uint(src_comment_len)))
                if (unsafe(reinterpret<size_t>(pState_15.m_central_dir.m_size)) + (unsafe(reinterpret<size_t>(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE)) + unsafe(reinterpret<size_t>(src_central_dir_following_data_size))) + unsafe(reinterpret<size_t>(32)) >= unsafe(reinterpret<size_t>(0xffffffff))) {
                    return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNSUPPORTED_CDIR_SIZE)))
                } else {
                    num_alignment_padding_bytes_1 = uint(mz_zip_writer_compute_padding_needed_for_file_alignment(pZip_72))
                    if (uint64(pState_15.m_zip64) == uint64(0)) {
                        if (uint(pZip_72.m_total_files) == 0xffff) {
                            return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_TOO_MANY_FILES)))
                        }
                    } elif (uint(pZip_72.m_total_files) == 0xffffffff) {
                        return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_TOO_MANY_FILES)))
                    }
                    if (uint64((mz_zip_file_stat_internal(pSource_zip, src_file_index, pSrc_central_header, unsafe(addr(src_file_stat) == uint64(0)), null)) ? 1 : 0) == uint64(0)) {
                        return 0
                    } else {
                        cur_src_file_ofs = uint64(src_file_stat.m_local_header_ofs)
                        cur_dst_file_ofs = uint64(pZip_72.m_archive_size)
                        if (pSource_zip.m_pRead(pSource_zip.m_pIO_opaque, cur_src_file_ofs, unsafe(unsafe(reinterpret<uint64>(pLocal_header_3))), unsafe(reinterpret<size_t>(MZ_ZIP_LOCAL_DIR_HEADER_SIZE))) != unsafe(reinterpret<size_t>(MZ_ZIP_LOCAL_DIR_HEADER_SIZE))) {
                            return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_READ_FAILED)))
                        } elif ((uint(((unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pLocal_header_3) == uint(0)))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pLocal_header_3) == uint(0)))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pLocal_header_3) == uint(0)))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pLocal_header_3) == uint(0)))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)) != uint(MZ_ZIP_LOCAL_DIR_HEADER_SIG)) {
                            return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
                        } else {
                            cur_src_file_ofs = uint64(cur_src_file_ofs + uint64(MZ_ZIP_LOCAL_DIR_HEADER_SIZE))
                            local_header_filename_size = uint(((uint(unsafe(unsafe(pLocal_header_3 + int(MZ_ZIP_LDH_FILENAME_LEN_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(pLocal_header_3 + int(MZ_ZIP_LDH_FILENAME_LEN_OFS) == uint(0))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
                            local_header_extra_len_0 = uint(((uint(unsafe(unsafe(pLocal_header_3 + int(MZ_ZIP_LDH_EXTRA_LEN_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(pLocal_header_3 + int(MZ_ZIP_LDH_EXTRA_LEN_OFS) == uint(0))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
                            local_header_comp_size_0 = uint64((uint64(uint(((unsafe(unsafe(pLocal_header_3 + int(MZ_ZIP_LDH_COMPRESSED_SIZE_OFS) == uint64(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pLocal_header_3 + int(MZ_ZIP_LDH_COMPRESSED_SIZE_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(pLocal_header_3 + int(MZ_ZIP_LDH_COMPRESSED_SIZE_OFS) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(pLocal_header_3 + int(MZ_ZIP_LDH_COMPRESSED_SIZE_OFS) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18))) ? 1 : 0)
                            local_header_uncomp_size_0 = uint64((uint64(uint(((unsafe(unsafe(pLocal_header_3 + int(MZ_ZIP_LDH_DECOMPRESSED_SIZE_OFS) == uint64(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pLocal_header_3 + int(MZ_ZIP_LDH_DECOMPRESSED_SIZE_OFS) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(pLocal_header_3 + int(MZ_ZIP_LDH_DECOMPRESSED_SIZE_OFS) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(pLocal_header_3 + int(MZ_ZIP_LDH_DECOMPRESSED_SIZE_OFS) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18))) ? 1 : 0)
                            src_archive_bytes_remaining = uint64(uint64(src_file_stat.m_comp_size) + (uint64(local_header_filename_size) + uint64(local_header_extra_len_0)))
                            if (uint64(local_header_extra_len_0) != uint64(0) && uint64(local_header_comp_size_0) == uint64(0xffffffff) || uint64(local_header_uncomp_size_0) == uint64(0xffffffff)) {
                                extra_size_remaining_2 = local_header_extra_len_0
                                mz_zip_array_init(unsafe(addr(file_data_array_0)), uint(1))
                                if (uint64((mz_zip_array_resize(pZip_72, unsafe(addr(file_data_array_0) == uint64(0)), unsafe(reinterpret<size_t>(local_header_extra_len_0)), uint(0))) ? 1 : 0) == uint64(0)) {
                                    return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                                } elif (pSource_zip.m_pRead(pSource_zip.m_pIO_opaque, uint64(src_file_stat.m_local_header_ofs) + (uint64(MZ_ZIP_LOCAL_DIR_HEADER_SIZE) + uint64(local_header_filename_size)), file_data_array_0.m_p, unsafe(reinterpret<size_t>(local_header_extra_len_0))) != unsafe(reinterpret<size_t>(local_header_extra_len_0))) {
                                    mz_zip_array_clear(pZip_72, unsafe(addr(file_data_array_0)))
                                    return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_READ_FAILED)))
                                } else {
                                    pExtra_data_4 = unsafe(unsafe(reinterpret<uint8 const?>(file_data_array_0.m_p)))
                                    while (true) {
                                        if (uint64(extra_size_remaining_2) < uint64((4 * int((uint64(2) == uint64(0)) ? 1 : 0)) ? 1 : 0)) {
                                            mz_zip_array_clear(pZip_72, unsafe(addr(file_data_array_0)))
                                            return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
                                        } else {
                                            field_id_2 = uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pExtra_data_4) == uint(0)))[0])) | uint(uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pExtra_data_4) == uint(0)))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
                                            field_data_size_2 = uint(uint(unsafe(unsafe(pExtra_data_4 + 4)[0])) | uint(uint(unsafe(unsafe(pExtra_data_4 + 4)[1]))) << uint(0x8))
                                            field_total_size_0 = uint(((uint(uint64(field_data_size_2) + uint64((uint64(4 * int(uint64(2) == uint64(0)))) ? 1 : 0))) ? 1 : 0) ? 1 : 0)
                                            if (uint(field_total_size_0) > uint(extra_size_remaining_2)) {
                                                mz_zip_array_clear(pZip_72, unsafe(addr(file_data_array_0)))
                                                return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
                                            } elif (uint(field_id_2) == uint(MZ_ZIP64_EXTENDED_INFORMATION_FIELD_HEADER_ID)) {
                                                pSrc_field_data_0 = unsafe(pExtra_data_4 + 4)
                                                if (uint64(field_data_size_2) < uint64((4 * int((uint64(2) == uint64(0)) ? 1 : 0)) ? 1 : 0)) {
                                                    mz_zip_array_clear(pZip_72, unsafe(addr(file_data_array_0)))
                                                    return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
                                                } else {
                                                    local_header_uncomp_size_0 = uint64((uint64(uint(((unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pSrc_field_data_0) == uint64(0)))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pSrc_field_data_0) == uint(0)))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pSrc_field_data_0) == uint(0)))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pSrc_field_data_0) == uint(0)))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)) | uint64(uint64(uint(unsafe(unsafe(pSrc_field_data_0 + 4)[0])) | uint(uint(unsafe(unsafe(pSrc_field_data_0 + 4)[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(pSrc_field_data_0 + 4)[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(pSrc_field_data_0 + 4)[3]))) << uint(0x18))) << uint64(uint64(0x20) == uint64(0))) ? 1 : 0)
                                                    local_header_comp_size_0 = uint64((uint64(uint(unsafe(unsafe(pSrc_field_data_0 + 4)[0])) | uint(uint(unsafe(unsafe(pSrc_field_data_0 + 4)[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(pSrc_field_data_0 + 4)[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(pSrc_field_data_0 + 4)[3]))) << uint(0x18)) | uint64(uint64(uint(((unsafe(unsafe(pSrc_field_data_0 + (4 + 4) == uint64(0))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(pSrc_field_data_0 + (4 + 4) == uint(0))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(pSrc_field_data_0 + (4 + 4) == uint(0))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(pSrc_field_data_0 + (4 + 4) == uint(0))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18))) << uint64(uint64(0x20) == uint64(0))) ? 1 : 0)
                                                    found_zip64_ext_data_in_ldir_0 = 1
                                                    if (false) {
                                                    }
                                                    if (false) {
                                                    }
                                                }
                                            } else {
                                                pExtra_data_4 = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(pExtra_data_4 + field_total_size_0))))
                                                extra_size_remaining_2 = uint(extra_size_remaining_2 - field_total_size_0)
                                                if (!(uint64(extra_size_remaining_2) != uint64(0))) {
                                                    if (false) {
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    mz_zip_array_clear(pZip_72, unsafe(addr(file_data_array_0)))
                                }
                            }
                            if (uint64(pState_15.m_zip64) == uint64(0)) {
                                approx_new_archive_size = uint64(cur_dst_file_ofs) + (uint64(num_alignment_padding_bytes_1) + uint64(MZ_ZIP_LOCAL_DIR_HEADER_SIZE)) + uint64(src_archive_bytes_remaining) + uint64((uint64(4 * int((uint64(4) == uint64(0)) ? 1 : 0))) ? 1 : 0) + uint64((uint64(unsafe(reinterpret<size_t>(pState_15.m_central_dir.m_size) == uint64(0)))) ? 1 : 0) + uint64(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE) + uint64(src_central_dir_following_data_size) + uint64(MZ_ZIP_END_OF_CENTRAL_DIR_HEADER_SIZE) + uint64(64)
                                if (uint64(approx_new_archive_size) >= uint64(0xffffffff)) {
                                    return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ARCHIVE_TOO_LARGE)))
                                }
                            }
                            if (uint64((mz_zip_writer_write_zeros(pZip_72, cur_dst_file_ofs, num_alignment_padding_bytes_1) == uint64(0)) ? 1 : 0) == uint64(0)) {
                                return 0
                            } else {
                                cur_dst_file_ofs = uint64(cur_dst_file_ofs + uint64(num_alignment_padding_bytes_1))
                                local_dir_header_ofs_1 = uint64(cur_dst_file_ofs)
                                if (uint64(pZip_72.m_file_offset_alignment) != uint64(0)) {
                                    {
                                        if (uint64(uint64(local_dir_header_ofs_1) & uint64(pZip_72.m_file_offset_alignment) - uint64(1)) == uint64(0)) {
                                        } else {
                                            c2da___assert_fail(null, null, uint(0), null)
                                        }
                                    }
                                }
                                if (pZip_72.m_pWrite(pZip_72.m_pIO_opaque, cur_dst_file_ofs, unsafe(unsafe(reinterpret<uint64>(pLocal_header_3))), unsafe(reinterpret<size_t>(MZ_ZIP_LOCAL_DIR_HEADER_SIZE))) != unsafe(reinterpret<size_t>(MZ_ZIP_LOCAL_DIR_HEADER_SIZE))) {
                                    return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
                                } else {
                                    cur_dst_file_ofs = uint64(cur_dst_file_ofs + uint64(MZ_ZIP_LOCAL_DIR_HEADER_SIZE))
                                    var c2da_fresh126 : uint64 = uint64(0)
                                    if (uint64(MZ_ZIP_MAX_IO_BUF_SIZE) < uint64(src_archive_bytes_remaining)) {
                                        c2da_fresh126 = uint64(MZ_ZIP_MAX_IO_BUF_SIZE)
                                    } else {
                                        c2da_fresh126 = src_archive_bytes_remaining
                                    }
                                    var c2da_fresh127 : uint64 = uint64(0)
                                    if (uint64(MZ_ZIP_MAX_IO_BUF_SIZE) < uint64(src_archive_bytes_remaining)) {
                                        c2da_fresh127 = uint64(MZ_ZIP_MAX_IO_BUF_SIZE)
                                    } else {
                                        c2da_fresh127 = src_archive_bytes_remaining
                                    }
                                    var c2da_fresh128 : uint64 = uint64(0)
                                    if (uint64(0x20) > uint64(c2da_fresh126)) {
                                        c2da_fresh128 = uint64(0x20)
                                    } else {
                                        c2da_fresh128 = c2da_fresh127
                                    }
                                    pBuf_19 = pZip_72.m_pAlloc(pZip_72.m_pAlloc_opaque, unsafe(reinterpret<size_t>(1)), c2da_fresh128)
                                    if (unsafe(unsafe(reinterpret<uint64>(uint64(0) == uint64(0))) == unsafe(reinterpret<uint64>(uint64(pBuf_19) == uint64(0))))) {
                                        return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                                    } else {
                                        while (true) {
                                            if (uint64(src_archive_bytes_remaining) != uint64(0)) {
                                                var c2da_fresh129 : uint64 = uint64(0)
                                                if (uint64(MZ_ZIP_MAX_IO_BUF_SIZE) < uint64(src_archive_bytes_remaining)) {
                                                    c2da_fresh129 = uint64(MZ_ZIP_MAX_IO_BUF_SIZE)
                                                } else {
                                                    c2da_fresh129 = src_archive_bytes_remaining
                                                }
                                                n_19 = uint(((uint(c2da_fresh129) == uint(0)) ? 1 : 0) ? 1 : 0)
                                                if (pSource_zip.m_pRead(pSource_zip.m_pIO_opaque, cur_src_file_ofs, pBuf_19, unsafe(reinterpret<size_t>(n_19))) != unsafe(reinterpret<size_t>(n_19))) {
                                                    pZip_72.m_pFree(pZip_72.m_pAlloc_opaque, pBuf_19)
                                                    return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_READ_FAILED)))
                                                } else {
                                                    cur_src_file_ofs = uint64(cur_src_file_ofs + uint64(n_19))
                                                    if (pZip_72.m_pWrite(pZip_72.m_pIO_opaque, cur_dst_file_ofs, pBuf_19, unsafe(reinterpret<size_t>(n_19))) != unsafe(reinterpret<size_t>(n_19))) {
                                                        pZip_72.m_pFree(pZip_72.m_pAlloc_opaque, pBuf_19)
                                                        return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
                                                    } else {
                                                        cur_dst_file_ofs = uint64(cur_dst_file_ofs + uint64(n_19))
                                                        src_archive_bytes_remaining = uint64(src_archive_bytes_remaining - uint64(n_19))
                                                    }
                                                }
                                            } else {
                                                bit_flags_4 = uint(((uint(unsafe(unsafe(pLocal_header_3 + int(MZ_ZIP_LDH_BIT_FLAG_OFS) == uint(0))[0])) | uint(uint(unsafe(unsafe(pLocal_header_3 + int(MZ_ZIP_LDH_BIT_FLAG_OFS) == uint(0))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
                                                if (uint64(uint(bit_flags_4) & uint(8)) != uint64(0)) {
                                                    if (uint64(pSource_zip.m_pState.m_zip64) != uint64(0) || uint64(found_zip64_ext_data_in_ldir_0) != uint64(0)) {
                                                        if (pSource_zip.m_pRead(pSource_zip.m_pIO_opaque, cur_src_file_ofs, pBuf_19, 4 * int((uint64(6) == uint64(0)) ? 1 : 0)) != unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(4 * int((uint64(6) == uint64(0)) ? 1 : 0)))))) {
                                                            pZip_72.m_pFree(pZip_72.m_pAlloc_opaque, pBuf_19)
                                                            return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_READ_FAILED)))
                                                        } else {
                                                            var c2da_fresh130 : int = int(0)
                                                            if ((uint(((unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pBuf_19) == uint(0)))[0])) ? 1 : 0) ? 1 : 0) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pBuf_19) == uint(0)))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pBuf_19) == uint(0)))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pBuf_19) == uint(0)))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)) == uint(MZ_ZIP_DATA_DESCRIPTOR_ID)) {
                                                                c2da_fresh130 = 6
                                                            } else {
                                                                c2da_fresh130 = 5
                                                            }
                                                            n_19 = uint(((uint(4 * int(uint64(c2da_fresh130) == uint64(0)))) ? 1 : 0) ? 1 : 0)
                                                        }
                                                    } elif (pSource_zip.m_pRead(pSource_zip.m_pIO_opaque, cur_src_file_ofs, pBuf_19, 4 * int((uint64(4) == uint64(0)) ? 1 : 0)) != unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(4 * int((uint64(4) == uint64(0)) ? 1 : 0)))))) {
                                                        pZip_72.m_pFree(pZip_72.m_pAlloc_opaque, pBuf_19)
                                                        return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_READ_FAILED)))
                                                    } else {
                                                        has_id_0 = int(((uint((unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pBuf_19) == uint(0)))[0])) ? 1 : 0) | uint((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pBuf_19) == uint(0)))[1]))) ? 1 : 0) << uint(0x8) | uint((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pBuf_19) == uint(0)))[2]))) ? 1 : 0) << uint(0x10) | uint((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pBuf_19) == uint(0)))[3]))) ? 1 : 0) << uint(0x18)) == uint(MZ_ZIP_DATA_DESCRIPTOR_ID)) ? 1 : 0)
                                                        if (uint64(pZip_72.m_pState.m_zip64) != uint64(0)) {
                                                            var c2da_fresh131 : uint64 = uint64(0)
                                                            if (uint64(has_id_0) != uint64(0)) {
                                                                c2da_fresh131 = 4
                                                            } else {
                                                                c2da_fresh131 = uint64(0)
                                                            }
                                                            pSrc_descriptor = unsafe(pBuf_19 + uint64(c2da_fresh131))
                                                            src_crc32 = uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pSrc_descriptor)))[0])) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pSrc_descriptor) == uint(0)))[1]))) ? 1 : 0) ? 1 : 0) << uint(0x8) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pSrc_descriptor) == uint(0)))[2]))) ? 1 : 0) ? 1 : 0) << uint(0x10) | uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pSrc_descriptor) == uint(0)))[3]))) ? 1 : 0) ? 1 : 0) << uint(0x18)
                                                            src_comp_size = uint64(uint(unsafe(unsafe(pSrc_descriptor + 4)[0])) | uint(uint(unsafe(unsafe(pSrc_descriptor + 4)[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(pSrc_descriptor + 4)[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(pSrc_descriptor + 4)[3]))) << uint(0x18))
                                                            src_uncomp_size = uint64(uint(unsafe(unsafe(pSrc_descriptor + uint64(2) * uint64(4))[0])) | uint(uint(unsafe(unsafe(pSrc_descriptor + uint64(2) * uint64(4))[1]))) << uint(0x8) | uint(uint(unsafe(unsafe(pSrc_descriptor + uint64(2) * uint64(4))[2]))) << uint(0x10) | uint(uint(unsafe(unsafe(pSrc_descriptor + uint64(2) * uint64(4))[3]))) << uint(0x18))
                                                            mz_write_le32(pBuf_19, uint(MZ_ZIP_DATA_DESCRIPTOR_ID))
                                                            mz_write_le32(unsafe(pBuf_19 + 4 * int((uint64(1) == uint64(0)) ? 1 : 0)), src_crc32)
                                                            mz_write_le64(unsafe(pBuf_19 + 4 * int((uint64(2) == uint64(0)) ? 1 : 0)), src_comp_size)
                                                            mz_write_le64(unsafe(pBuf_19 + 4 * int((uint64(4) == uint64(0)) ? 1 : 0)), src_uncomp_size)
                                                            n_19 = uint(((uint(4 * int(uint64(6) == uint64(0)))) ? 1 : 0) ? 1 : 0)
                                                        } else {
                                                            var c2da_fresh132 : int = int(0)
                                                            if (uint64(has_id_0) != uint64(0)) {
                                                                c2da_fresh132 = 4
                                                            } else {
                                                                c2da_fresh132 = 3
                                                            }
                                                            n_19 = uint(((uint(4 * int(uint64(c2da_fresh132) == uint64(0)))) ? 1 : 0) ? 1 : 0)
                                                        }
                                                    }
                                                    if (pZip_72.m_pWrite(pZip_72.m_pIO_opaque, cur_dst_file_ofs, pBuf_19, unsafe(reinterpret<size_t>(n_19))) != unsafe(reinterpret<size_t>(n_19))) {
                                                        pZip_72.m_pFree(pZip_72.m_pAlloc_opaque, pBuf_19)
                                                        return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
                                                    } else {
                                                        cur_src_file_ofs = uint64(cur_src_file_ofs + uint64(n_19))
                                                        cur_dst_file_ofs = uint64(cur_dst_file_ofs + uint64(n_19))
                                                    }
                                                }
                                                pZip_72.m_pFree(pZip_72.m_pAlloc_opaque, pBuf_19)
                                                orig_central_dir_size_0 = unsafe(reinterpret<size_t>(pState_15.m_central_dir.m_size))
                                                memcpy(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(new_central_header[0]))))), unsafe(unsafe(reinterpret<uint64>(pSrc_central_header))), uint64((uint64(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE) == uint64(0)) ? 1 : 0))
                                                if (uint64(pState_15.m_zip64) != uint64(0)) {
                                                    pSrc_ext = unsafe(pSrc_central_header + (int(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE) + int((uint(src_filename_len) == uint(0)) ? 1 : 0)))
                                                    mz_zip_array_init(unsafe(addr(new_ext_block)), uint(4))
                                                    mz_write_le32(unsafe(unsafe(addr(new_central_header[0])) + int(MZ_ZIP_CDH_COMPRESSED_SIZE_OFS)), 0xffffffff)
                                                    mz_write_le32(unsafe(unsafe(addr(new_central_header[0])) + int(MZ_ZIP_CDH_DECOMPRESSED_SIZE_OFS)), 0xffffffff)
                                                    mz_write_le32(unsafe(unsafe(addr(new_central_header[0])) + int(MZ_ZIP_CDH_LOCAL_HEADER_OFS)), 0xffffffff)
                                                    if (uint64((mz_zip_writer_update_zip64_extension_block(unsafe(addr(new_ext_block) == uint64(0)), pZip_72, pSrc_ext, src_ext_len, unsafe(addr(src_file_stat.m_comp_size)), unsafe(addr(src_file_stat.m_uncomp_size)), unsafe(addr(local_dir_header_ofs_1)), null)) ? 1 : 0) == uint64(0)) {
                                                        mz_zip_array_clear(pZip_72, unsafe(addr(new_ext_block)))
                                                        return 0
                                                    } else {
                                                        mz_write_le16(unsafe(unsafe(addr(new_central_header[0])) + int(MZ_ZIP_CDH_EXTRA_LEN_OFS)), uint16(new_ext_block.m_size))
                                                        if (uint64((mz_zip_array_push_back(pZip_72, unsafe(addr(pState_15.m_central_dir) == uint64(0)), unsafe(unsafe(reinterpret<uint64>(unsafe(addr(new_central_header[0]))))), unsafe(reinterpret<size_t>(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE)))) ? 1 : 0) == uint64(0)) {
                                                            mz_zip_array_clear(pZip_72, unsafe(addr(new_ext_block)))
                                                            return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                                                        } elif (uint64((mz_zip_array_push_back(pZip_72, unsafe(addr(pState_15.m_central_dir) == uint64(0)), unsafe(unsafe(reinterpret<uint64>(unsafe(pSrc_central_header + int(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE))))), unsafe(reinterpret<size_t>(src_filename_len)))) ? 1 : 0) == uint64(0)) {
                                                            mz_zip_array_clear(pZip_72, unsafe(addr(new_ext_block)))
                                                            mz_zip_array_resize(pZip_72, unsafe(addr(pState_15.m_central_dir)), orig_central_dir_size_0, uint(0))
                                                            return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                                                        } elif (uint64((mz_zip_array_push_back(pZip_72, unsafe(addr(pState_15.m_central_dir) == uint64(0)), new_ext_block.m_p, new_ext_block.m_size)) ? 1 : 0) == uint64(0)) {
                                                            mz_zip_array_clear(pZip_72, unsafe(addr(new_ext_block)))
                                                            mz_zip_array_resize(pZip_72, unsafe(addr(pState_15.m_central_dir)), orig_central_dir_size_0, uint(0))
                                                            return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                                                        } elif (uint64((mz_zip_array_push_back(pZip_72, unsafe(addr(pState_15.m_central_dir) == uint64(0)), unsafe(unsafe(reinterpret<uint64>(unsafe(pSrc_central_header + (int(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE) + (uint(src_filename_len) + uint(src_ext_len))))))), unsafe(reinterpret<size_t>(src_comment_len)))) ? 1 : 0) == uint64(0)) {
                                                            mz_zip_array_clear(pZip_72, unsafe(addr(new_ext_block)))
                                                            mz_zip_array_resize(pZip_72, unsafe(addr(pState_15.m_central_dir)), orig_central_dir_size_0, uint(0))
                                                            return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                                                        } else {
                                                            mz_zip_array_clear(pZip_72, unsafe(addr(new_ext_block)))
                                                        }
                                                    }
                                                } elif (uint64(cur_dst_file_ofs) > uint64(0xffffffff)) {
                                                    return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ARCHIVE_TOO_LARGE)))
                                                } elif (uint64(local_dir_header_ofs_1) >= uint64(0xffffffff)) {
                                                    return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ARCHIVE_TOO_LARGE)))
                                                } else {
                                                    mz_write_le32(unsafe(unsafe(addr(new_central_header[0])) + int(MZ_ZIP_CDH_LOCAL_HEADER_OFS)), uint(local_dir_header_ofs_1))
                                                    if (uint64((mz_zip_array_push_back(pZip_72, unsafe(addr(pState_15.m_central_dir) == uint64(0)), unsafe(unsafe(reinterpret<uint64>(unsafe(addr(new_central_header[0]))))), unsafe(reinterpret<size_t>(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE)))) ? 1 : 0) == uint64(0)) {
                                                        return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                                                    } elif (uint64((mz_zip_array_push_back(pZip_72, unsafe(addr(pState_15.m_central_dir) == uint64(0)), unsafe(unsafe(reinterpret<uint64>(unsafe(pSrc_central_header + int(MZ_ZIP_CENTRAL_DIR_HEADER_SIZE))))), unsafe(reinterpret<size_t>(src_central_dir_following_data_size)))) ? 1 : 0) == uint64(0)) {
                                                        mz_zip_array_resize(pZip_72, unsafe(addr(pState_15.m_central_dir)), orig_central_dir_size_0, uint(0))
                                                        return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                                                    }
                                                }
                                                if (unsafe(reinterpret<size_t>(pState_15.m_central_dir.m_size)) >= unsafe(reinterpret<size_t>(0xffffffff))) {
                                                    mz_zip_array_resize(pZip_72, unsafe(addr(pState_15.m_central_dir)), orig_central_dir_size_0, uint(0))
                                                    return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_UNSUPPORTED_CDIR_SIZE)))
                                                } else {
                                                    n_19 = uint(((uint(orig_central_dir_size_0) == uint(0)) ? 1 : 0) ? 1 : 0)
                                                    if (uint64((mz_zip_array_push_back(pZip_72, unsafe(addr(pState_15.m_central_dir_offsets) == uint64(0)), unsafe(unsafe(reinterpret<uint64>(unsafe(addr(n_19))))), unsafe(reinterpret<size_t>(1)))) ? 1 : 0) == uint64(0)) {
                                                        mz_zip_array_resize(pZip_72, unsafe(addr(pState_15.m_central_dir)), orig_central_dir_size_0, uint(0))
                                                        return mz_zip_set_error(pZip_72, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                                                    } else {
                                                        pZip_72.m_total_files = pZip_72.m_total_files + uint(1)
                                                        pZip_72.m_total_files
                                                        pZip_72.m_archive_size = uint64(cur_dst_file_ofs)
                                                        return 1
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
[export]
def mz_zip_writer_update_zip64_extension_block(var pNew_ext : mz_zip_array?; var pZip_73 : mz_zip_archive?; var pExt : uint8 const?; var ext_len : uint; var pComp_size_0 : uint64?; var pUncomp_size_0 : uint64?; var pLocal_header_ofs_0 : uint64?; var pDisk_start : uint?) : int {
    var new_ext_block_0 : array<uint8> = []
    var pDst_2 : uint8? = null
    var extra_size_remaining_3 : uint = uint(0)
    var pExtra_data_5 : uint8 const? = null
    var field_id_3 : uint = uint(0)
    var field_data_size_3 : uint = uint(0)
    var field_total_size_1 : uint = uint(0)
    if (uint64(mz_zip_array_reserve(pZip_73, pNew_ext, unsafe(reinterpret<size_t>(uint(ext_len) + uint(64))), uint(0))) == uint64(0)) {
        return mz_zip_set_error(pZip_73, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
    } else {
        mz_zip_array_resize(pZip_73, pNew_ext, unsafe(reinterpret<size_t>(0)), uint(0))
        if (pUncomp_size_0 != null || pComp_size_0 != null || pLocal_header_ofs_0 != null || pDisk_start != null) {
            pDst_2 = unsafe(addr(new_ext_block_0[0]))
            mz_write_le16(pDst_2, uint16(MZ_ZIP64_EXTENDED_INFORMATION_FIELD_HEADER_ID))
            mz_write_le16(unsafe(pDst_2 + 4), uint16(0))
            pDst_2 = unsafe(unsafe(reinterpret<uint8?>(unsafe(pDst_2 + 4 * int((uint64(2) == uint64(0)) ? 1 : 0)))))
            if (pUncomp_size_0 != null) {
                mz_write_le64(pDst_2, *pUncomp_size_0)
                pDst_2 = unsafe(unsafe(reinterpret<uint8?>(unsafe(pDst_2 + 4))))
            }
            if (pComp_size_0 != null) {
                mz_write_le64(pDst_2, *pComp_size_0)
                pDst_2 = unsafe(unsafe(reinterpret<uint8?>(unsafe(pDst_2 + 4))))
            }
            if (pLocal_header_ofs_0 != null) {
                mz_write_le64(pDst_2, *pLocal_header_ofs_0)
                pDst_2 = unsafe(unsafe(reinterpret<uint8?>(unsafe(pDst_2 + 4))))
            }
            if (pDisk_start != null) {
                mz_write_le32(pDst_2, *pDisk_start)
                pDst_2 = unsafe(unsafe(reinterpret<uint8?>(unsafe(pDst_2 + 4))))
            }
            mz_write_le16(unsafe(unsafe(addr(new_ext_block_0[0])) + 4), uint16(uint64((unsafe(pDst_2 - unsafe(addr(new_ext_block_0[0]) == uint64(0)))) ? 1 : 0) - uint64((uint64(4 * int((uint64(2) == uint64(0)) ? 1 : 0))) ? 1 : 0)))
            if (uint64((mz_zip_array_push_back(pZip_73, pNew_ext, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(new_ext_block_0[0]) == uint64(0))))), unsafe(reinterpret<size_t>(unsafe(pDst_2 - unsafe(addr(new_ext_block_0[0]))))))) ? 1 : 0) == uint64(0)) {
                return mz_zip_set_error(pZip_73, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
            }
        }
        while (true) {
            if (pExt != null && uint64(ext_len) != uint64(0)) {
                extra_size_remaining_3 = ext_len
                pExtra_data_5 = pExt
                while (true) {
                    if (uint64(extra_size_remaining_3) < uint64((4 * int((uint64(2) == uint64(0)) ? 1 : 0)) ? 1 : 0)) {
                        return mz_zip_set_error(pZip_73, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
                    } else {
                        field_id_3 = uint(((uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pExtra_data_5) == uint(0)))[0])) | uint(uint(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(pExtra_data_5) == uint(0)))[1]))) << uint(0x8)) ? 1 : 0) ? 1 : 0)
                        field_data_size_3 = uint(uint(unsafe(unsafe(pExtra_data_5 + 4)[0])) | uint(uint(unsafe(unsafe(pExtra_data_5 + 4)[1]))) << uint(0x8))
                        field_total_size_1 = uint(((uint(uint64(field_data_size_3) + uint64((uint64(4 * int(uint64(2) == uint64(0)))) ? 1 : 0))) ? 1 : 0) ? 1 : 0)
                        if (uint(field_total_size_1) > uint(extra_size_remaining_3)) {
                            return mz_zip_set_error(pZip_73, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_HEADER_OR_CORRUPTED)))
                        } else {
                            if (uint(field_id_3) != uint(MZ_ZIP64_EXTENDED_INFORMATION_FIELD_HEADER_ID)) {
                                if (uint64((mz_zip_array_push_back(pZip_73, pNew_ext, unsafe(unsafe(reinterpret<uint64>(pExtra_data_5) == uint64(0))), unsafe(reinterpret<size_t>(field_total_size_1)))) ? 1 : 0) == uint64(0)) {
                                    return mz_zip_set_error(pZip_73, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_ALLOC_FAILED)))
                                }
                            }
                            pExtra_data_5 = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(pExtra_data_5 + field_total_size_1))))
                            extra_size_remaining_3 = uint(extra_size_remaining_3 - field_total_size_1)
                            if (uint64(extra_size_remaining_3) != uint64(0)) {
                                continue
                            }
                            if (false) {
                            }
                        }
                    }
                }
            }
        }
        return 1
    }
}
[export]
def mz_zip_writer_finalize_archive(var pZip_74 : mz_zip_archive?) : int {
    var pState_16 : mz_zip_internal_state_tag? = null
    var central_dir_ofs_0 : uint64 = uint64(0)
    var central_dir_size : uint64 = uint64(0)
    var hdr : array<uint8> = []
    var rel_ofs_to_zip64_ecdr : uint64 = uint64(0)
    if (pZip_74 == null || pZip_74.m_pState == null || uint(pZip_74.m_zip_mode) != uint(MZ_ZIP_MODE_WRITING)) {
        return mz_zip_set_error(pZip_74, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
    } else {
        pState_16 = unsafe(unsafe(reinterpret<mz_zip_internal_state_tag?>(pZip_74.m_pState)))
        if (uint64(pState_16.m_zip64) != uint64(0)) {
            if (uint64(pState_16.m_central_dir.m_size) >= uint64(0xffffffff)) {
                return mz_zip_set_error(pZip_74, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_TOO_MANY_FILES)))
            }
        } elif (uint(pZip_74.m_total_files) > 0xffff || uint64(pZip_74.m_archive_size) + (uint64((uint64(unsafe(reinterpret<size_t>(pState_16.m_central_dir.m_size) == uint64(0)))) ? 1 : 0) + uint64(MZ_ZIP_END_OF_CENTRAL_DIR_HEADER_SIZE)) > uint64(0xffffffff)) {
            return mz_zip_set_error(pZip_74, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_TOO_MANY_FILES)))
        }
        central_dir_ofs_0 = uint64((uint64(0) == uint64(0)) ? 1 : 0)
        central_dir_size = uint64((uint64(0) == uint64(0)) ? 1 : 0)
        if (uint64(pZip_74.m_total_files) != uint64(0)) {
            central_dir_ofs_0 = uint64(pZip_74.m_archive_size)
            central_dir_size = uint64(pState_16.m_central_dir.m_size)
            pZip_74.m_central_directory_file_ofs = uint64(central_dir_ofs_0)
            if (pZip_74.m_pWrite(pZip_74.m_pIO_opaque, central_dir_ofs_0, pState_16.m_central_dir.m_p, central_dir_size) != unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(uint64(central_dir_size) == uint64(0)))))) {
                return mz_zip_set_error(pZip_74, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
            } else {
                pZip_74.m_archive_size = uint64(pZip_74.m_archive_size + central_dir_size)
            }
        }
        if (uint64(pState_16.m_zip64) != uint64(0)) {
            rel_ofs_to_zip64_ecdr = pZip_74.m_archive_size
            memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(hdr[0]))))), 0, uint64(4))
            mz_write_le32(unsafe(unsafe(addr(hdr[0])) + int(MZ_ZIP64_ECDH_SIG_OFS)), uint(MZ_ZIP64_END_OF_CENTRAL_DIR_HEADER_SIG))
            mz_write_le64(unsafe(unsafe(addr(hdr[0])) + int(MZ_ZIP64_ECDH_SIZE_OF_RECORD_OFS)), uint64(MZ_ZIP64_END_OF_CENTRAL_DIR_HEADER_SIZE) - uint64((uint64(4) == uint64(0)) ? 1 : 0) - uint64((uint64(4) == uint64(0)) ? 1 : 0))
            mz_write_le16(unsafe(unsafe(addr(hdr[0])) + int(MZ_ZIP64_ECDH_VERSION_MADE_BY_OFS)), uint16(798))
            mz_write_le16(unsafe(unsafe(addr(hdr[0])) + int(MZ_ZIP64_ECDH_VERSION_NEEDED_OFS)), uint16(45))
            mz_write_le64(unsafe(unsafe(addr(hdr[0])) + int(MZ_ZIP64_ECDH_CDIR_NUM_ENTRIES_ON_DISK_OFS)), uint64(pZip_74.m_total_files))
            mz_write_le64(unsafe(unsafe(addr(hdr[0])) + int(MZ_ZIP64_ECDH_CDIR_TOTAL_ENTRIES_OFS)), uint64(pZip_74.m_total_files))
            mz_write_le64(unsafe(unsafe(addr(hdr[0])) + int(MZ_ZIP64_ECDH_CDIR_SIZE_OFS)), central_dir_size)
            mz_write_le64(unsafe(unsafe(addr(hdr[0])) + int(MZ_ZIP64_ECDH_CDIR_OFS_OFS)), central_dir_ofs_0)
            if (pZip_74.m_pWrite(pZip_74.m_pIO_opaque, pZip_74.m_archive_size, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(hdr[0]))))), unsafe(reinterpret<size_t>(MZ_ZIP64_END_OF_CENTRAL_DIR_HEADER_SIZE))) != unsafe(reinterpret<size_t>(MZ_ZIP64_END_OF_CENTRAL_DIR_HEADER_SIZE))) {
                return mz_zip_set_error(pZip_74, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
            } else {
                pZip_74.m_archive_size = uint64(pZip_74.m_archive_size + uint64(MZ_ZIP64_END_OF_CENTRAL_DIR_HEADER_SIZE))
                memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(hdr[0]))))), 0, uint64(4))
                mz_write_le32(unsafe(unsafe(addr(hdr[0])) + int(MZ_ZIP64_ECDL_SIG_OFS)), uint(MZ_ZIP64_END_OF_CENTRAL_DIR_LOCATOR_SIG))
                mz_write_le64(unsafe(unsafe(addr(hdr[0])) + int(MZ_ZIP64_ECDL_REL_OFS_TO_ZIP64_ECDR_OFS)), rel_ofs_to_zip64_ecdr)
                mz_write_le32(unsafe(unsafe(addr(hdr[0])) + int(MZ_ZIP64_ECDL_TOTAL_NUMBER_OF_DISKS_OFS)), uint(1))
                if (pZip_74.m_pWrite(pZip_74.m_pIO_opaque, pZip_74.m_archive_size, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(hdr[0]))))), unsafe(reinterpret<size_t>(MZ_ZIP64_END_OF_CENTRAL_DIR_LOCATOR_SIZE))) != unsafe(reinterpret<size_t>(MZ_ZIP64_END_OF_CENTRAL_DIR_LOCATOR_SIZE))) {
                    return mz_zip_set_error(pZip_74, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
                } else {
                    pZip_74.m_archive_size = uint64(pZip_74.m_archive_size + uint64(MZ_ZIP64_END_OF_CENTRAL_DIR_LOCATOR_SIZE))
                }
            }
        }
        memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(hdr[0]))))), 0, uint64(4))
        mz_write_le32(unsafe(unsafe(addr(hdr[0])) + int(MZ_ZIP_ECDH_SIG_OFS)), uint(MZ_ZIP_END_OF_CENTRAL_DIR_HEADER_SIG))
        var c2da_fresh133 : uint = uint(0)
        if (0xffff < uint(pZip_74.m_total_files)) {
            c2da_fresh133 = 0xffff
        } else {
            c2da_fresh133 = pZip_74.m_total_files
        }
        mz_write_le16(unsafe(unsafe(addr(hdr[0])) + int(MZ_ZIP_ECDH_CDIR_NUM_ENTRIES_ON_DISK_OFS)), uint16(c2da_fresh133))
        var c2da_fresh134 : uint = uint(0)
        if (0xffff < uint(pZip_74.m_total_files)) {
            c2da_fresh134 = 0xffff
        } else {
            c2da_fresh134 = pZip_74.m_total_files
        }
        mz_write_le16(unsafe(unsafe(addr(hdr[0])) + int(MZ_ZIP_ECDH_CDIR_TOTAL_ENTRIES_OFS)), uint16(c2da_fresh134))
        var c2da_fresh135 : uint64 = uint64(0)
        if (uint64(0xffffffff) < uint64(central_dir_size)) {
            c2da_fresh135 = uint64(0xffffffff)
        } else {
            c2da_fresh135 = central_dir_size
        }
        mz_write_le32(unsafe(unsafe(addr(hdr[0])) + int(MZ_ZIP_ECDH_CDIR_SIZE_OFS)), uint(c2da_fresh135))
        var c2da_fresh136 : uint64 = uint64(0)
        if (uint64(0xffffffff) < uint64(central_dir_ofs_0)) {
            c2da_fresh136 = uint64(0xffffffff)
        } else {
            c2da_fresh136 = central_dir_ofs_0
        }
        mz_write_le32(unsafe(unsafe(addr(hdr[0])) + int(MZ_ZIP_ECDH_CDIR_OFS_OFS)), uint(c2da_fresh136))
        if (pZip_74.m_pWrite(pZip_74.m_pIO_opaque, pZip_74.m_archive_size, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(hdr[0]))))), unsafe(reinterpret<size_t>(MZ_ZIP_END_OF_CENTRAL_DIR_HEADER_SIZE))) != unsafe(reinterpret<size_t>(MZ_ZIP_END_OF_CENTRAL_DIR_HEADER_SIZE))) {
            return mz_zip_set_error(pZip_74, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_FILE_WRITE_FAILED)))
        } else {
            pZip_74.m_archive_size = uint64(pZip_74.m_archive_size + uint64(MZ_ZIP_END_OF_CENTRAL_DIR_HEADER_SIZE))
            pZip_74.m_zip_mode = unsafe(reinterpret<mz_zip_mode>(MZ_ZIP_MODE_WRITING_HAS_BEEN_FINALIZED))
            return 1
        }
    }
}
[export]
def mz_zip_writer_finalize_heap_archive(var pZip_75 : mz_zip_archive?; var ppBuf : uint64?; var pSize_1 : size_t?) : int {
    if (ppBuf == null || pSize_1 == null) {
        return mz_zip_set_error(pZip_75, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
    } else {
        *ppBuf = uint64(0)
        *pSize_1 = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
        if (pZip_75 == null || pZip_75.m_pState == null) {
            return mz_zip_set_error(pZip_75, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
        } elif (unsafe(unsafe(reinterpret<uint64>(pZip_75.m_pWrite)) != unsafe(reinterpret<uint64>(mz_zip_heap_write_func)))) {
            return mz_zip_set_error(pZip_75, unsafe(reinterpret<mz_zip_error>(MZ_ZIP_INVALID_PARAMETER)))
        } elif (uint64((mz_zip_writer_finalize_archive(pZip_75) == uint64(0)) ? 1 : 0) == uint64(0)) {
            return 0
        } else {
            *ppBuf = pZip_75.m_pState.m_pMem
            *pSize_1 = unsafe(reinterpret<size_t>(pZip_75.m_pState.m_mem_size))
            pZip_75.m_pState.m_pMem = uint64(0)
            pZip_75.m_pState.m_mem_capacity = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
            pZip_75.m_pState.m_mem_size = pZip_75.m_pState.m_mem_capacity
            return 1
        }
    }
}
var secret_name : array<int8> const = "secretik.txt"

var expected_text : array<int8> const = "Hi Bebra 2026!"

[export]
def miniz_secret_alloc(var size_6 : int) : int {
    var ptr_4 : uint64 = uint64(0)
    ptr_4 = uint64(0x0)
    if (int(size_6) < 0) {
        return 0
    } else {
        ptr_4 = unsafe(malloc(unsafe(reinterpret<size_t>(size_6))))
        return int(ptr_4)
    }
}
[export]
def miniz_secret_expected_length() : int {
    return int((4 - int(int(uint64(0x1) == uint64(0)))) ? 1 : 0)
}
[export]
def miniz_secret_extract_message(var archive_ptr : int; var archive_size : int; var out_ptr : int; var out_capacity : int) : int {
    var archive : mz_zip_archive = mz_zip_archive()
    var file_index_19 : uint = uint(0)
    var heap_result : uint64 = uint64(0)
    var heap_size : size_t = unsafe(reinterpret<size_t>(0))
    var ok : int = int(0)
    file_index_19 = uint(0)
    heap_result = uint64(0x0)
    heap_size = unsafe(reinterpret<size_t>(0))
    ok = 0
    if (uint64((int(archive_ptr) == uint64(0)) ? 1 : 0) == uint64(0) || int(archive_size) <= 0 || uint64((int(out_ptr) == int(0)) ? 1 : 0) == uint64(0) || int(out_capacity) <= 0) {
        return -1001
    } else {
        mz_zip_zero_struct(unsafe(addr(archive)))
        ok = mz_zip_reader_init_mem(unsafe(addr(archive)), unsafe(reinterpret<uintptr_t>(archive_ptr)), unsafe(reinterpret<size_t>(archive_size)), uint(0))
        if (uint64(ok) == uint64(0)) {
            return -1002 - int(mz_zip_get_last_error(unsafe(addr(archive))))
        } else {
            ok = mz_zip_reader_locate_file_v2(unsafe(addr(archive)), unsafe(addr(secret_name[0])), null, uint(0), unsafe(addr(file_index_19)))
            if (uint64(ok) == uint64(0)) {
                mz_zip_reader_end(unsafe(addr(archive)))
                return -1003 - int(mz_zip_get_last_error(unsafe(addr(archive))))
            } else {
                heap_result = mz_zip_reader_extract_to_heap(unsafe(addr(archive)), file_index_19, unsafe(addr(heap_size)), uint(0))
                if (uint64(heap_result) == uint64(0)) {
                    mz_zip_reader_end(unsafe(addr(archive)))
                    return -1004 - int(mz_zip_get_last_error(unsafe(addr(archive))))
                } elif (int(heap_size) > int(out_capacity)) {
                    mz_free(heap_result)
                    mz_zip_reader_end(unsafe(addr(archive)))
                    return -1005 - int(heap_size)
                } else {
                    memcpy(unsafe(reinterpret<void?>(out_ptr)), unsafe(reinterpret<void?>(heap_result)), int(uint64(heap_size)))
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
    var file_index_20 : uint = uint(0)
    var state_1 : mz_zip_reader_extract_iter_state? = null
    var total_3 : size_t = unsafe(reinterpret<size_t>(0))
    var ok_0 : int = int(0)
    var chunk : size_t = unsafe(reinterpret<size_t>(0))
    file_index_20 = uint(0)
    state_1 = null
    total_3 = unsafe(reinterpret<size_t>(0))
    ok_0 = 0
    if (uint64((int(archive_ptr_0) == uint64(0)) ? 1 : 0) == uint64(0) || int(archive_size_0) <= 0 || uint64((int(out_ptr_0) == int(0)) ? 1 : 0) == uint64(0) || int(out_capacity_0) <= 0) {
        return -1101
    } else {
        mz_zip_zero_struct(unsafe(addr(archive_0)))
        ok_0 = mz_zip_reader_init_mem(unsafe(addr(archive_0)), unsafe(reinterpret<uintptr_t>(archive_ptr_0)), unsafe(reinterpret<size_t>(archive_size_0)), uint(0))
        if (uint64(ok_0) == uint64(0)) {
            return -1102 - int(mz_zip_get_last_error(unsafe(addr(archive_0))))
        } else {
            ok_0 = mz_zip_reader_locate_file_v2(unsafe(addr(archive_0)), unsafe(addr(secret_name[0])), null, uint(0), unsafe(addr(file_index_20)))
            if (uint64(ok_0) == uint64(0)) {
                mz_zip_reader_end(unsafe(addr(archive_0)))
                return -1103 - int(mz_zip_get_last_error(unsafe(addr(archive_0))))
            } else {
                state_1 = unsafe(unsafe(reinterpret<mz_zip_reader_extract_iter_state?>(mz_zip_reader_extract_iter_new(unsafe(addr(archive_0)), file_index_20, uint(0)))))
                if (state_1 == null) {
                    mz_zip_reader_end(unsafe(addr(archive_0)))
                    return -1104 - int(mz_zip_get_last_error(unsafe(addr(archive_0))))
                } else {
                    while (true) {
                        if (!unsafe(reinterpret<size_t>(total_3)) < unsafe(reinterpret<size_t>(out_capacity_0))) {
                            if (false) {
                            }
                        }
                        chunk = mz_zip_reader_extract_iter_read(state_1, unsafe(reinterpret<uintptr_t>(out_ptr_0)) + unsafe(reinterpret<uintptr_t>(unsafe(reinterpret<uintptr_t>(unsafe(reinterpret<size_t>(total_3)))))), unsafe(reinterpret<size_t>(out_capacity_0)) - unsafe(reinterpret<size_t>(total_3)))
                        if (uint64((unsafe(reinterpret<size_t>(chunk) == uint64(0))) ? 1 : 0) == uint64(0)) {
                            if (false) {
                            }
                            if (false) {
                            }
                        } else {
                            total_3 = unsafe(reinterpret<size_t>(total_3 + chunk))
                        }
                    }
                    ok_0 = mz_zip_reader_extract_iter_free(state_1)
                    if (uint64(ok_0) == uint64(0)) {
                        mz_zip_reader_end(unsafe(addr(archive_0)))
                        return -1105 - int(mz_zip_get_last_error(unsafe(addr(archive_0))))
                    } else {
                        mz_zip_reader_end(unsafe(addr(archive_0)))
                        return int(total_3)
                    }
                }
            }
        }
    }
}
[export]
def miniz_secret_probe_expected_crc32() : int {
    return int((mz_crc32(uint64(0), unsafe(addr(expected_text[0])), 4 - int(int(uint64(0x1) == uint64(0))))) ? 1 : 0)
}
[export]
def miniz_secret_probe_buffer_crc32(var ptr_5 : int; var len_28 : int) : int {
    if (uint64((int(ptr_5) == uint64(0)) ? 1 : 0) == uint64(0) || int(len_28) < 0) {
        return 0
    } else {
        return int(mz_crc32(uint64(0), unsafe(reinterpret<uintptr_t>(ptr_5)), unsafe(reinterpret<size_t>(len_28))))
    }
}
[export]
def miniz_secret_probe_file_crc32(var archive_ptr_1 : int; var archive_size_1 : int) : int {
    var archive_1 : mz_zip_archive = mz_zip_archive()
    var file_index_21 : uint = uint(0)
    var file_stat_3 : mz_zip_archive_file_stat = mz_zip_archive_file_stat()
    var ok_1 : int = int(0)
    file_index_21 = uint(0)
    ok_1 = 0
    if (uint64((int(archive_ptr_1) == uint64(0)) ? 1 : 0) == uint64(0) || int(archive_size_1) <= 0) {
        return -1201
    } else {
        mz_zip_zero_struct(unsafe(addr(archive_1)))
        ok_1 = mz_zip_reader_init_mem(unsafe(addr(archive_1)), unsafe(reinterpret<uintptr_t>(archive_ptr_1)), unsafe(reinterpret<size_t>(archive_size_1)), uint(0))
        if (uint64(ok_1) == uint64(0)) {
            return -1202 - int(mz_zip_get_last_error(unsafe(addr(archive_1))))
        } else {
            ok_1 = mz_zip_reader_locate_file_v2(unsafe(addr(archive_1)), unsafe(addr(secret_name[0])), null, uint(0), unsafe(addr(file_index_21)))
            if (uint64(ok_1) == uint64(0)) {
                mz_zip_reader_end(unsafe(addr(archive_1)))
                return -1203 - int(mz_zip_get_last_error(unsafe(addr(archive_1))))
            } else {
                ok_1 = mz_zip_reader_file_stat(unsafe(addr(archive_1)), file_index_21, unsafe(addr(file_stat_3)))
                if (uint64(ok_1) == uint64(0)) {
                    mz_zip_reader_end(unsafe(addr(archive_1)))
                    return -1204 - int(mz_zip_get_last_error(unsafe(addr(archive_1))))
                } else {
                    mz_zip_reader_end(unsafe(addr(archive_1)))
                    return int(file_stat_3.m_crc32)
                }
            }
        }
    }
}
[export]
def miniz_secret_extract_message_direct(var archive_ptr_2 : int; var archive_size_2 : int; var out_ptr_1 : int; var out_capacity_1 : int) : int {
    var archive_2 : mz_zip_archive = mz_zip_archive()
    var file_index_22 : uint = uint(0)
    var file_stat_4 : mz_zip_archive_file_stat = mz_zip_archive_file_stat()
    var ok_2 : int = int(0)
    file_index_22 = uint(0)
    ok_2 = 0
    if (uint64((int(archive_ptr_2) == uint64(0)) ? 1 : 0) == uint64(0) || int(archive_size_2) <= 0 || uint64((int(out_ptr_1) == int(0)) ? 1 : 0) == uint64(0) || int(out_capacity_1) <= 0) {
        return -1301
    } else {
        mz_zip_zero_struct(unsafe(addr(archive_2)))
        ok_2 = mz_zip_reader_init_mem(unsafe(addr(archive_2)), unsafe(reinterpret<uintptr_t>(archive_ptr_2)), unsafe(reinterpret<size_t>(archive_size_2)), uint(0))
        if (uint64(ok_2) == uint64(0)) {
            return -1302 - int(mz_zip_get_last_error(unsafe(addr(archive_2))))
        } else {
            ok_2 = mz_zip_reader_locate_file_v2(unsafe(addr(archive_2)), unsafe(addr(secret_name[0])), null, uint(0), unsafe(addr(file_index_22)))
            if (uint64(ok_2) == uint64(0)) {
                mz_zip_reader_end(unsafe(addr(archive_2)))
                return -1303 - int(mz_zip_get_last_error(unsafe(addr(archive_2))))
            } else {
                ok_2 = mz_zip_reader_file_stat(unsafe(addr(archive_2)), file_index_22, unsafe(addr(file_stat_4)))
                if (uint64(ok_2) == uint64(0)) {
                    mz_zip_reader_end(unsafe(addr(archive_2)))
                    return -1304 - int(mz_zip_get_last_error(unsafe(addr(archive_2))))
                } elif (int(file_stat_4.m_uncomp_size) > int(out_capacity_1)) {
                    mz_zip_reader_end(unsafe(addr(archive_2)))
                    return -1305 - int(file_stat_4.m_uncomp_size)
                } else {
                    ok_2 = mz_zip_reader_extract_to_mem(unsafe(addr(archive_2)), file_index_22, unsafe(reinterpret<uintptr_t>(out_ptr_1)), unsafe(reinterpret<size_t>(out_capacity_1)), uint(0))
                    if (uint64(ok_2) == uint64(0)) {
                        mz_zip_reader_end(unsafe(addr(archive_2)))
                        return -1306 - int(mz_zip_get_last_error(unsafe(addr(archive_2))))
                    } else {
                        mz_zip_reader_end(unsafe(addr(archive_2)))
                        return int(file_stat_4.m_uncomp_size)
                    }
                }
            }
        }
    }
}
[export]
def miniz_secret_matches_expected(var message_ptr : int; var message_len : int) : int {
    if (int(message_len) != int((4 - int(int(uint64(0x1) == uint64(0)))) ? 1 : 0)) {
        return 0
    } elif (uint64((memcmp(unsafe(reinterpret<uintptr_t>(message_ptr) == uint64(0)), unsafe(unsafe(reinterpret<uint64>(unsafe(addr(expected_text[0]))))), unsafe(reinterpret<size_t>(message_len)))) ? 1 : 0) != uint64(0)) {
        return 0
    } else {
        return 1
    }
}
var MZ_FIXED : int = 4

var MZ_RLE : int = 3

var MZ_HUFFMAN_ONLY : int = 2

var MZ_FILTERED : int = 1

var MZ_DEFAULT_STRATEGY : int = 0

var MZ_DEFAULT_COMPRESSION : int = -1

var MZ_DEFAULT_LEVEL : int = 6

var MZ_UBER_COMPRESSION : int = 10

var MZ_BEST_COMPRESSION : int = 9

var MZ_BEST_SPEED : int = 1

var MZ_NO_COMPRESSION : int = 0

var MZ_BLOCK : int = 5

var MZ_FINISH : int = 4

var MZ_FULL_FLUSH : int = 3

var MZ_SYNC_FLUSH : int = 2

var MZ_PARTIAL_FLUSH : int = 1

var MZ_NO_FLUSH : int = 0

var MZ_PARAM_ERROR : int = -10000

var MZ_VERSION_ERROR : int = -6

var MZ_BUF_ERROR : int = -5

var MZ_MEM_ERROR : int = -4

var MZ_DATA_ERROR : int = -3

var MZ_STREAM_ERROR : int = -2

var MZ_ERRNO : int = -1

var MZ_NEED_DICT : int = 2

var MZ_STREAM_END : int = 1

var MZ_OK : int = 0

var TDEFL_STATUS_OKAY : int = 0

var TDEFL_STATUS_DONE : int = 1

var TDEFL_STATUS_PUT_BUF_FAILED : int = -1

var TDEFL_STATUS_BAD_PARAM : int = -2

var TDEFL_GREEDY_PARSING_FLAG : int = 16384

var TDEFL_RLE_MATCHES : int = 65536

var TDEFL_FORCE_ALL_STATIC_BLOCKS : int = 262144

var TDEFL_MAX_PROBES_MASK : int = 4095

var TDEFL_FILTER_MATCHES : int = 131072

var TDEFL_FORCE_ALL_RAW_BLOCKS : int = 524288

var TDEFL_WRITE_ZLIB_HEADER : int = 4096

var TDEFL_COMPUTE_ADLER32 : int = 8192

var TDEFL_FINISH : int = 4

var TDEFL_FULL_FLUSH : int = 3

var TDEFL_SYNC_FLUSH : int = 2

var TDEFL_NO_FLUSH : int = 0

var TDEFL_MAX_HUFF_SYMBOLS_1 : int = 32

var TDEFL_MAX_HUFF_SYMBOLS_0 : int = 288

var TDEFL_NONDETERMINISTIC_PARSING_FLAG : int = 32768

var TDEFL_OUT_BUF_SIZE : int = 85196

var TDEFL_MAX_HUFF_SYMBOLS_2 : int = 19

var TDEFL_MAX_SUPPORTED_HUFF_CODESIZE : int = 32

var TDEFL_LZ_DICT_SIZE_MASK : int = 32767

var TDEFL_LZ_CODE_BUF_SIZE : int = 65536

var TDEFL_LZ_DICT_SIZE : int = 32768

var TDEFL_MIN_MATCH_LEN : int = 3

var TDEFL_MAX_MATCH_LEN : int = 258

var TDEFL_LZ_HASH_SIZE : int = 32768

var TDEFL_LZ_HASH_SHIFT : int = 5

var TINFL_STATUS_HAS_MORE_OUTPUT : int = 2

var TINFL_STATUS_NEEDS_MORE_INPUT : int = 1

var TINFL_STATUS_DONE : int = 0

var TINFL_STATUS_FAILED : int = -1

var TINFL_STATUS_ADLER32_MISMATCH : int = -2

var TINFL_STATUS_BAD_PARAM : int = -3

var TINFL_STATUS_FAILED_CANNOT_MAKE_PROGRESS : int = -4

var TINFL_FLAG_COMPUTE_ADLER32 : int = 8

var TINFL_FLAG_PARSE_ZLIB_HEADER : int = 1

var TINFL_FLAG_HAS_MORE_INPUT : int = 2

var TINFL_FLAG_USING_NON_WRAPPING_OUTPUT_BUF : int = 4

var TINFL_FAST_LOOKUP_BITS : int = 10

var TINFL_FAST_LOOKUP_SIZE : int = 1024

var TDEFL_DEFAULT_MAX_PROBES : int = 128

var TDEFL_HUFFMAN_ONLY : int = 0

var TDEFL_MAX_HUFF_TABLES : int = 3

var TDEFL_LEVEL1_HASH_SIZE_MASK : int = 4095

var TDEFL_LZ_HASH_BITS : int = 15

var TDEFL_MAX_HUFF_SYMBOLS : int = 288

var TINFL_MAX_HUFF_SYMBOLS_2 : int = 19

var TINFL_MAX_HUFF_SYMBOLS_1 : int = 32

var TINFL_MAX_HUFF_SYMBOLS_0 : int = 288

var TINFL_MAX_HUFF_TABLES : int = 3

var MZ_ZIP_MAX_ARCHIVE_FILE_COMMENT_SIZE : int = 512

var MZ_ZIP_MAX_ARCHIVE_FILENAME_SIZE : int = 512

var MZ_ZIP_MAX_IO_BUF_SIZE : int = 65536

var MZ_ZIP_MODE_WRITING_HAS_BEEN_FINALIZED : int = 3

var MZ_ZIP_MODE_WRITING : int = 2

var MZ_ZIP_MODE_READING : int = 1

var MZ_ZIP_MODE_INVALID : int = 0

var MZ_ZIP_FLAG_READ_ALLOW_WRITING : int = 262144

var MZ_ZIP_FLAG_WRITE_HEADER_SET_SIZE : int = 131072

var MZ_ZIP_FLAG_ASCII_FILENAME : int = 65536

var MZ_ZIP_FLAG_WRITE_ALLOW_READING : int = 32768

var MZ_ZIP_FLAG_WRITE_ZIP64 : int = 16384

var MZ_ZIP_FLAG_VALIDATE_HEADERS_ONLY : int = 8192

var MZ_ZIP_FLAG_VALIDATE_LOCATE_FILE_FLAG : int = 4096

var MZ_ZIP_FLAG_DO_NOT_SORT_CENTRAL_DIRECTORY : int = 2048

var MZ_ZIP_FLAG_COMPRESSED_DATA : int = 1024

var MZ_ZIP_FLAG_IGNORE_PATH : int = 512

var MZ_ZIP_FLAG_CASE_SENSITIVE : int = 256

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

var MZ_ZIP_CDH_FILENAME_LEN_OFS : int = 28

var MZ_ZIP_CENTRAL_DIR_HEADER_SIZE : int = 46

var MZ_ZIP_CDH_COMMENT_LEN_OFS : int = 32

var MZ_ZIP_CDH_EXTRA_LEN_OFS : int = 30

var MZ_ZIP_GENERAL_PURPOSE_BIT_FLAG_LOCAL_DIR_IS_MASKED : int = 8192

var MZ_ZIP_CDH_BIT_FLAG_OFS : int = 8

var MZ_ZIP_LOCAL_DIR_HEADER_SIZE : int = 30

var MZ_ZIP_CDH_LOCAL_HEADER_OFS : int = 42

var MZ_ZIP_CDH_DISK_START_OFS : int = 34

var MZ_ZIP_CDH_METHOD_OFS : int = 10

var MZ_ZIP64_EXTENDED_INFORMATION_FIELD_HEADER_ID : int = 1

var MZ_ZIP_CDH_DECOMPRESSED_SIZE_OFS : int = 24

var MZ_ZIP_CDH_COMPRESSED_SIZE_OFS : int = 20

var MZ_ZIP_CENTRAL_DIR_HEADER_SIG : int = 33639248

var MZ_ZIP64_END_OF_CENTRAL_DIR_LOCATOR_SIZE : int = 20

var MZ_ZIP64_END_OF_CENTRAL_DIR_HEADER_SIZE : int = 56

var MZ_ZIP64_ECDH_CDIR_OFS_OFS : int = 48

var MZ_ZIP64_ECDH_NUM_DISK_CDIR_OFS : int = 20

var MZ_ZIP64_ECDH_NUM_THIS_DISK_OFS : int = 16

var MZ_ZIP64_ECDH_CDIR_SIZE_OFS : int = 40

var MZ_ZIP64_ECDH_CDIR_NUM_ENTRIES_ON_DISK_OFS : int = 24

var MZ_ZIP64_ECDH_CDIR_TOTAL_ENTRIES_OFS : int = 32

var MZ_ZIP64_ECDL_TOTAL_NUMBER_OF_DISKS_OFS : int = 16

var MZ_ZIP64_ECDH_SIZE_OF_RECORD_OFS : int = 4

var MZ_ZIP_ECDH_CDIR_OFS_OFS : int = 16

var MZ_ZIP_ECDH_CDIR_SIZE_OFS : int = 12

var MZ_ZIP_ECDH_NUM_DISK_CDIR_OFS : int = 6

var MZ_ZIP_ECDH_NUM_THIS_DISK_OFS : int = 4

var MZ_ZIP_ECDH_CDIR_NUM_ENTRIES_ON_DISK_OFS : int = 8

var MZ_ZIP_ECDH_CDIR_TOTAL_ENTRIES_OFS : int = 10

var MZ_ZIP64_END_OF_CENTRAL_DIR_HEADER_SIG : int = 101075792

var MZ_ZIP64_ECDH_SIG_OFS : int = 0

var MZ_ZIP64_ECDL_REL_OFS_TO_ZIP64_ECDR_OFS : int = 8

var MZ_ZIP64_END_OF_CENTRAL_DIR_LOCATOR_SIG : int = 117853008

var MZ_ZIP64_ECDL_SIG_OFS : int = 0

var MZ_ZIP_END_OF_CENTRAL_DIR_HEADER_SIG : int = 101010256

var MZ_ZIP_ECDH_SIG_OFS : int = 0

var MZ_ZIP_END_OF_CENTRAL_DIR_HEADER_SIZE : int = 22

var MZ_ZIP_DOS_DIR_ATTRIBUTE_BITFLAG : int = 16

var MZ_ZIP_CDH_EXTERNAL_ATTR_OFS : int = 38

var MZ_ZIP_CDH_VERSION_MADE_BY_OFS : int = 4

var MZ_ZIP_GENERAL_PURPOSE_BIT_FLAG_USES_STRONG_ENCRYPTION : int = 64

var MZ_ZIP_GENERAL_PURPOSE_BIT_FLAG_IS_ENCRYPTED : int = 1

var MZ_ZIP_GENERAL_PURPOSE_BIT_FLAG_COMPRESSED_PATCH_FLAG : int = 32

var MZ_ZIP_CDH_INTERNAL_ATTR_OFS : int = 36

var MZ_ZIP_CDH_CRC32_OFS : int = 16

var MZ_ZIP_CDH_VERSION_NEEDED_OFS : int = 6

var MZ_ZIP_LDH_EXTRA_LEN_OFS : int = 28

var MZ_ZIP_LDH_FILENAME_LEN_OFS : int = 26

var MZ_ZIP_LOCAL_DIR_HEADER_SIG : int = 67324752

var MZ_ZIP_DATA_DESCRIPTOR_ID : int = 134695760

var MZ_ZIP_LDH_BIT_FLAG_OFS : int = 6

var MZ_ZIP_LDH_CRC32_OFS : int = 14

var MZ_ZIP_LDH_DECOMPRESSED_SIZE_OFS : int = 22

var MZ_ZIP_LDH_COMPRESSED_SIZE_OFS : int = 18

var MZ_ZIP_CDH_FILE_DATE_OFS : int = 14

var MZ_ZIP_CDH_FILE_TIME_OFS : int = 12

var MZ_ZIP_CDH_SIG_OFS : int = 0

var MZ_ZIP_DATA_DESCRIPTER_SIZE32 : int = 16

var MZ_ZIP_DATA_DESCRIPTER_SIZE64 : int = 24

var MZ_ZIP_LDH_BIT_FLAG_HAS_LOCATOR : int = 8

var MZ_ZIP_LDH_FILE_DATE_OFS : int = 12

var MZ_ZIP_LDH_FILE_TIME_OFS : int = 10

var MZ_ZIP_LDH_METHOD_OFS : int = 8

var MZ_ZIP_LDH_VERSION_NEEDED_OFS : int = 4

var MZ_ZIP_LDH_SIG_OFS : int = 0

var MZ_ZIP_GENERAL_PURPOSE_BIT_FLAG_UTF8 : int = 2048

var MZ_ZIP64_ECDH_VERSION_NEEDED_OFS : int = 14

var MZ_ZIP64_ECDH_VERSION_MADE_BY_OFS : int = 12

var MZ_ZIP_VERSION_MADE_BY_DOS_FILESYSTEM_ID : int = 0

var MZ_ZIP64_ECDL_NUM_DISK_CDIR_OFS : int = 4

var MZ_ZIP_ECDH_COMMENT_SIZE_OFS : int = 20
[export] def main() : int {
    return 0
}

