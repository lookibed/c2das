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
typedef uint32_t = uint
struct sized_array {
    n : size_t
    elts : array<uint>
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
var SOME_INTS : array<uint>

[export]
def check_some_ints() : bool {
    return unsafe(unsafe(addr(SOME_INTS[0]))[0]) == uint(2) && uint64(unsafe(unsafe(addr(SOME_INTS[0]))[1])) == uint64(0) && unsafe(unsafe(addr(SOME_INTS[0]))[2]) == uint(1) && unsafe(unsafe(addr(SOME_INTS[0]))[3]) == uint(8)
}
[export]
def new_sized_array(var n : size_t) : sized_array? {
    var sz : size_t const = unsafe(reinterpret<size_t>(0))
    var res : sized_array? = null
    sz = 4 + int(int(unsafe(reinterpret<size_t>(n)) * unsafe(reinterpret<size_t>(4))))
    res = unsafe(unsafe(reinterpret<sized_array?>(unsafe(malloc(sz)))))
    res.n = unsafe(reinterpret<size_t>(n))
    return unsafe(unsafe(reinterpret<sized_array?>(res)))
}
[export]
def sized_array_sum_last_n(var a : sized_array?; var n_0 : size_t) : uint {
    var acc : uint = uint(0)
    acc = uint(0)
    if (false) {
    }
}
[export]
def test_sized_array() : uint {
    var a_0 : sized_array? = null
    a_0 = new_sized_array(unsafe(reinterpret<size_t>(10)))
    if (false) {
    }
}
[export]
def entry2(buffer_size : uint const; var buffer : int?) {
    var arr : array<int> = []
    var p_arr : array<int>? = null
    var x : int = int(0)
    var carr : array<int> const = []
    var p_carr : array<int> const? = null
    var cx : int = int(0)
    arr = [1, 2, 3]
    p_arr = unsafe(unsafe(reinterpret<array<int>?>(unsafe(addr(arr)))))
    x = unsafe(unsafe(addr(*p_arr[0]))[0])
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[0]) = x
    carr = [1, 2, 3]
    p_carr = unsafe(unsafe(reinterpret<array<int> const?>(unsafe(addr(carr)))))
    cx = unsafe(unsafe(addr(*p_carr[0]))[0])
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[1]) = cx
    return
}
[export] def main() : int {
    return 0
}
