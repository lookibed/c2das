options gen2

module p16_post_increment_write_lvalue
var c2da_heap : array<uint8>

var c2da_heap_offset : uint64 = uint64(uint64(uint64(0x8)))

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
def c2da_bool_to_int(v : bool) : int {
    if (v) {
        return 1
    } else {
        return 0
    }
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
def c2da_reset_heap() {
    c2da_heap_offset = uint64(0x8)
}
def c2da_malloc(size : uint64) : uint64 {
    if (uint64(length(c2da_heap)) == uint64(0)) {
        resize(c2da_heap, 33554432)
    }
    var aligned_size : uint64 = uint64(uint64(uint64(size) + uint64(0x7) & uint64(0xfffffffffffffff8uL)))
    var new_offset : uint64 = uint64(uint64(uint64(c2da_heap_offset) + uint64(0x8) + uint64(aligned_size)))
    if (new_offset >= uint64(length(c2da_heap))) {
        return uint64(0x0)
    }
    var result : uint64 = uint64(uint64(c2da_heap_offset))
    unsafe(*unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(c2da_heap[uint(result)])))))) = size
    c2da_heap_offset = new_offset
    return intptr(unsafe(addr(c2da_heap[uint(uint(result) + uint(uint64(0x8)))])))
}
def c2da_free(ptr : uint64) {
}
def realloc(ptr : uint64; size : uint64) : uint64 {
    var old_size : uint64 = uint64(uint64(uint64(0x0)))
    var copy_size : uint64 = uint64(uint64(uint64(0x0)))
    var new_ptr : uint64 = uint64(uint64(c2da_malloc(size)))
    if (uint64(new_ptr) != uint64(0) && uint64(ptr) != uint64(0)) {
        old_size = uint64(uint64(unsafe(*unsafe(unsafe(reinterpret<uint64?>(ptr - uint64(0x8)))))))
        copy_size = uint64(uint64(c2da_min_uint64(old_size, size)))
        unsafe(memcpy(unsafe(unsafe(reinterpret<void?>(new_ptr))), unsafe(unsafe(reinterpret<void?>(ptr))), int(copy_size)))
    }
    return new_ptr
}
def c2da_memset(dst : void?; value : int; size : int) : void? {
    var bytes : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(dst)))))))))
    var i : int = 0
    while (i < size) {
        unsafe(bytes[uint(i)]) = uint8(value)
        i = int(i) + 1
    }
    return dst
}
def c2da_memchr(ptr : void?; value : int; size : int) : uint64 {
    return uint64(0x0)
}
def c2da_strdup(src : void?) : int8? {
    return unsafe(unsafe(reinterpret<int8?>(src)))
}
def c2da_strlen(src : int8 const?) : int {
    return 0
}
[export]
def fill(var dst : uint8?) {
    var c2da_fresh0 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(dst))))))
    dst = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(dst))), 1, 1)))))))))))
    *c2da_fresh0 = uint8(uint8(uint8(1)))
    var c2da_fresh1 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(dst))))))
    dst = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(dst))), 1, 1)))))))))))
    *c2da_fresh1 = uint8(uint8(uint8(2)))
}