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
def cast_stuff() {
    var inta : array<int> = []
    var intp : int? = null
    var cintp : int const? = null
    var x1 : int8? = null
    var x2 : int? = null
    var f : function? = null
    var g : function? = null
    var x3 : int? = null
    var x4 : int? = null
    var x5 : int? = null
    var x6 : int = int(0)
    var x7 : int64 = int64(0)
    var x8 : float = float(0)
    var x9 : int = int(0)
    var x10 : bool = bool(0)
    var x11 : bool = bool(0)
    var x12 : bool = bool(0)
    var x13 : double = double(0)
    var const_i : int const = int(0)
    var x14 : int? = null
    var b : bool = bool(0)
    var x15 : float = float(0)
    var x16 : uint64 = uint64(0)
    var x : int? = null
    inta = [int(0)]
    intp = null
    cintp = null
    x1 = intp
    x2 = intp
    f = cast_stuff
    g = unsafe(addr(cast_stuff))
    x3 = unsafe(addr(inta[0]))
    x4 = unsafe(unsafe(reinterpret<int?>(0)))
    x5 = unsafe(unsafe(reinterpret<int?>(1)))
    x6 = unsafe(reinterpret<int>(intp))
    intp
    x7 = int64(10)
    x8 = float(10)
    x9 = int(double(10.0))
    x10 = bool(10)
    x11 = bool(double(10.5))
    x12 = uint64(0)
    x13 = double(double(10.5))
    const_i = -1
    x14 = unsafe(addr(const_i))
    b = 1
    x15 = float(b)
    x16 = unsafe(reinterpret<uint64>(b))
    x = unsafe(addr([0]))
    return
}
[export] def main() : int {
    return 0
}
