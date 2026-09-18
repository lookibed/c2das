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
def c2da_malloc(size : uint64) : uint64 {
    return uint64(0x0)
}
def c2da_free(ptr : uint64) {
}
def realloc(ptr : uint64; size : uint64) : uint64 {
    return ptr
}
def c2da_memset(dst : void?; value : int; size : int) : void? {
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
struct HeapHeader {
    size : uint64
}
var heap : array<uint8>

var heap_offset : uint64 = uint64(uint64(uint64(8)))

[export]
def free(var ptr : uint64) {
    return
}
[export]
def realloc(var ptr_0 : uint64; var size_0 : uint64) : uint64 {
    return uint64(0)
}
[export]
def memcmp(var c2da___s1 : uint64; var c2da___s2 : uint64; var c2da___n_0 : uint64) : int {
    return 0
}
[export]
def abs(var value_0 : int) : int {
    var c2da_fresh1 : int = int(0)
    if (int(value_0) < 0) {
        c2da_fresh1 = -value_0
    } else {
        c2da_fresh1 = value_0
    }
    return c2da_fresh1
    return int(0)
}
[export]
def malloc(var size : uint64) : uint64 {
    return uint64(0)
}
[export]
def memcpy(var dest_0 : uint64; var src_0 : uint64; var count_0 : uint64) : uint64 {
    return dest_0
}
[export]
def calloc(var c2da___nmemb : uint64; var c2da___size : uint64) : uint64 {
    return uint64(0)
}
[export]
def shim_reset_heap() {
    heap_offset = uint64(uint64(8))
    return
}
[export]
def memset(var dest : uint64; var value : int; var count : uint64) : uint64 {
    return dest
}
[export]
def memmove(var c2da___dest : uint64; var c2da___src : uint64; var c2da___n : uint64) : uint64 {
    return c2da___dest
}
[export] def main() : int {
    return 0
}
