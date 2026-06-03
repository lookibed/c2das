options gen2

typedef uint32_t = __uint32_t
struct sized_array {
    n : size_t
    elts : array<uint>
}
def _bswap_16(var _bsx : __uint16_t) : __uint16_t {
    return cast<__uint16_t>(__bsx >> 8 & 255 | __bsx & 255 << 8)
}
def _bswap_32(var _bsx : __uint32_t) : __uint32_t {
    return __bsx & 4278190080 >> 24 | __bsx & 16711680 >> 8 | __bsx & 65280 << 8 | __bsx & 255 << 24
}
def _bswap_64(var _bsx : __uint64_t) : __uint64_t {
    return __bsx & -72057594037927936 >> 56 | __bsx & 71776119061217280 >> 40 | __bsx & 280375465082880 >> 24 | __bsx & 1095216660480 >> 8 | __bsx & 4278190080 << 8 | __bsx & 16711680 << 24 | __bsx & 65280 << 40 | __bsx & 255 << 56
}
def _uint16_identity(var _x : __uint16_t) : __uint16_t {
    return __x
}
def _uint32_identity(var _x : __uint32_t) : __uint32_t {
    return __x
}
def _uint64_identity(var _x : __uint64_t) : __uint64_t {
    return __x
}
var SOME_INTS : array<uint32_t>

def check_some_ints() : bool {
    unsafe {
        return unsafe(addr(SOME_INTS[0]))[0] == 2 && unsafe(addr(SOME_INTS[0]))[1] == 0 && unsafe(addr(SOME_INTS[0]))[2] == 1 && unsafe(addr(SOME_INTS[0]))[3] == 8
    }
}
def new_sized_array(n : size_t) : sized_array? {
    var sz : size_t const = 4 + n * 4
    var res : sized_array? = malloc(sz)
    res.n = n
    return res
}
def entry2(buffer_size : uint const; var buffer : int?) {
    unsafe {
        var arr : array<int> = [1, 2, 3]
        var p_arr : array<int>? = unsafe(addr(arr))
        var x : int = unsafe(addr(*p_arr[0]))[0]
        buffer[0] = x
        var carr : array<int> const = [1, 2, 3]
        var p_carr : array<int> const? = unsafe(addr(carr))
        var cx : int = unsafe(addr(*p_carr[0]))[0]
        buffer[1] = cx
    }
}
