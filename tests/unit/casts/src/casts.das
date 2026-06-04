options gen2

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
def cast_stuff() {
    var inta : array<int> = [0]
    var intp : int? = null
    var cintp : int const? = null
    var x1 : int8? = reinterpret<int8?>(intp)
    var x2 : int? = cast<int?>(intp)
    var f : function? = reinterpret<function?>(cast_stuff)
    var g : function? = reinterpret<function?>(unsafe(addr(cast_stuff)))
    var x3 : int? = cast<int?>(unsafe(addr(inta[0])))
    var x4 : int? = cast<int?>(0)
    var x5 : int? = reinterpret<int?>(1)
    var x6 : int = reinterpret<int>(intp)
    intp
    var x7 : int64 = cast<int64>(10)
    var x8 : float = cast<float>(10)
    var x9 : int = cast<int>(double(10.0))
    var x10 : bool = cast<bool>(10)
    var x11 : bool = cast<bool>(double(10.5))
    var x12 : bool = cast<uint64>(0)
    var x13 : double = cast<double>(double(10.5))
    var const_i : int const = -1
    var x14 : int? = cast<int?>(unsafe(addr(const_i)))
    var b : bool = 1
    var x15 : float = cast<float>(b)
    var x16 : uint64 = reinterpret<uint64>(b)
    var x : int? = unsafe(addr([0]))
}
