options gen2

// ── libc shim ──
def malloc(size : uint64) : uint64 {
    return 0
}
def free(ptr : uint64) {
}
def realloc(ptr : uint64; size : uint64) : uint64 {
    return 0
}
def calloc(count : uint64; size : uint64) : uint64 {
    return 0
}
def memset(dest : uint64; value : int; count : uint64) : uint64 {
    return dest
}
def memcpy(dest : uint64; src : uint64; count : uint64) : uint64 {
    return dest
}
def memmove(dest : uint64; src : uint64; count : uint64) : uint64 {
    return dest
}
def memcmp(lhs : uint64; rhs : uint64; count : uint64) : int {
    return 0
}
def strlen(text : uint64) : uint64 {
    return 0
}

// ── miniz zip stubs ──
def mz_zip_zero_struct(pZip : mz_zip_archive?) {
}
def mz_zip_reader_init_mem(pZip : mz_zip_archive?; pBuf : uint64; bufSize : uint64; flags : uint) : int {
    return 0
}
def mz_zip_get_last_error(pZip : mz_zip_archive?) : int {
    return 0
}
def mz_zip_reader_locate_file_v2(pZip : mz_zip_archive?; pName : uint8?; pComment : uint8?; flags : uint; pIndex : uint?) : int {
    return 0
}
def mz_zip_reader_end(pZip : mz_zip_archive?) : int {
    return 0
}
def mz_zip_reader_extract_to_heap(pZip : mz_zip_archive?; file_index : uint; pSize : uint64?; flags : uint) : uint64 {
    return 0
}
def mz_free(ptr : uint64) {
}
def mz_zip_reader_extract_iter_new(pZip : mz_zip_archive?; file_index : uint; flags : uint) : uint64 {
    return 0
}
def mz_zip_reader_extract_iter_read(state : mz_zip_reader_extract_iter_state?; pBuf : uint64; bufSize : uint64) : uint64 {
    return 0
}
def mz_zip_reader_extract_iter_free(state : mz_zip_reader_extract_iter_state?) : int {
    return 0
}
def mz_zip_reader_file_stat(pZip : mz_zip_archive?; file_index : uint; pStat : mz_zip_archive_file_stat?) : int {
    return 0
}
def mz_zip_reader_extract_to_mem(pZip : mz_zip_archive?; file_index : uint; pBuf : uint64; bufSize : uint64; flags : uint) : int {
    return 0
}

// ── miniz crc / adler ──
def mz_crc32(crc : uint64; ptr : uint8?; buf_len : uint64) : uint64 {
    return 0
}
def mz_adler32(adler : uint64; ptr : uint8?; buf_len : uint64) : uint64 {
    return 0
}
def mz_error(err : int) : int8? {
    return null
}

// ── miniz zlib-compat stubs ──
def mz_deflateInit(pStream : mz_streamp; level : int) : int {
    return 0
}
def mz_deflateInit2(pStream : mz_streamp; level : int; method : int; window_bits : int; mem_level : int; strategy : int) : int {
    return 0
}
def mz_deflateReset(pStream : mz_streamp) : int {
    return 0
}
def mz_deflate(pStream : mz_streamp; flush : int) : int {
    return 0
}
def mz_deflateEnd(pStream : mz_streamp) : int {
    return 0
}
def mz_deflateBound(pStream : mz_streamp; source_len : uint64) : uint64 {
    return 0
}
def mz_inflateInit(pStream : mz_streamp) : int {
    return 0
}
def mz_inflateInit2(pStream : mz_streamp; window_bits : int) : int {
    return 0
}
def mz_inflateReset(pStream : mz_streamp) : int {
    return 0
}
def mz_inflate(pStream : mz_streamp; flush : int) : int {
    return 0
}
def mz_inflateEnd(pStream : mz_streamp) : int {
    return 0
}
def mz_compress(pDest : uint8?; pDest_len : uint64?; pSource : uint8?; source_len : uint64) : int {
    return 0
}
def mz_compress2(pDest : uint8?; pDest_len : uint64?; pSource : uint8?; source_len : uint64; level : int) : int {
    return 0
}
def mz_compressBound(source_len : uint64) : uint64 {
    return 0
}
def mz_uncompress(pDest : uint8?; pDest_len : uint64?; pSource : uint8?; source_len : uint64) : int {
    return 0
}
def mz_uncompress2(pDest : uint8?; pDest_len : uint64?; pSource : uint8?; pSource_len : uint64?) : int {
    return 0
}
