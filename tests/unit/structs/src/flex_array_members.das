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
struct gnu_flex {
    x : int
    flex : array<int>
}
struct c99_flex {
    x : int
    flex : array<int>
}
struct c89_flex {
    x : int
    flex : array<int>
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
[export]
def exercise_flex_arrays(sz : uint const; var buf : int?) {
    var i : int = int(0)
    var s : gnu_flex? = null
    var t : c99_flex? = null
    var u : c89_flex? = null
    i = 0
    s = unsafe(calloc(4, uint64(11)))
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[uint(i)]) = unsafe(unsafe(addr(s.flex[0]))[0])
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[uint(i)]) = unsafe(unsafe(addr(s.flex[0]))[1])
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[uint(i)]) = unsafe(unsafe(addr(s.flex[0]))[2])
    unsafe(unsafe(addr(s.flex[0]))[5]) = 10
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[uint(i)]) = unsafe(unsafe(addr(s.flex[0]))[5])
    t = unsafe(calloc(4, uint64(11)))
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[uint(i)]) = unsafe(unsafe(addr(t.flex[0]))[0])
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[uint(i)]) = unsafe(unsafe(addr(t.flex[0]))[1])
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[uint(i)]) = unsafe(unsafe(addr(t.flex[0]))[2])
    unsafe(unsafe(addr(t.flex[0]))[5]) = 10
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[uint(i)]) = unsafe(unsafe(addr(t.flex[0]))[5])
    u = unsafe(calloc(4, uint64(11)))
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[uint(i)]) = unsafe(unsafe(addr(u.flex[0]))[0])
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[uint(i)]) = unsafe(unsafe(addr(u.flex[0]))[1])
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[uint(i)]) = unsafe(unsafe(addr(u.flex[0]))[2])
    unsafe(unsafe(addr(u.flex[0]))[0]) = 10
    unsafe(unsafe(addr(u.flex[0]))[5]) = 15
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[uint(i)]) = unsafe(unsafe(addr(u.flex[0]))[5])
    return
}
[export] def main() : int {
    return 0
}
