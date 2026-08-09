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
struct ThreeFields {
    a : int?
    b : int const?
    c : uint64
}
struct OneInt {
    i : int
}
struct Page {
    idx : uint8?
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
def f(var a : int?; var b : int const?) {
    return
}
[export]
def bar(var a_0 : int const?) {
    var arr : array<int> = []
    var p_arr : array<int>? = null
    arr = [1, 2, 3]
    p_arr = unsafe(unsafe(reinterpret<array<int>?>(unsafe(addr(arr)))))
    f(unsafe(addr(unsafe(unsafe(addr(arr[0]))[0]))), a_0)
    return
}
[export]
def bitcast(var a_1 : uint64) {
    return
}
[export]
def foobar(var a_2 : uint?) {
    return
}
[export]
def address_cast(var a_3 : uint64) {
    return
}
[export]
def cmp_ref(var a_4 : int; var b_0 : int??) : int {
    return unsafe(unsafe(reinterpret<uint64>(unsafe(addr(a_4)))) != unsafe(reinterpret<uint64>(*b_0)))
}
[export]
def takesPtr(var p : uint8 const?) {
    return
}
[export]
def calls_all() {
    var i : int = int(0)
    var j : int const = int(0)
    var k : int? = null
    var m : uint64 = uint64(0)
    var tf : ThreeFields = ThreeFields()
    var l : array<int> = []
    var ul : uint64 = uint64(0)
    var oi : OneInt? = null
    var n : int? = null
    var o : int = int(0)
    var p_0 : int = int(0)
    var q : int? = null
    var r : Page? = null
    i = 1
    j = 2
    f(unsafe(addr(i)), unsafe(addr(i)))
    bar(unsafe(addr(j)))
    foobar(unsafe(unsafe(reinterpret<uint?>(unsafe(addr(i))))))
    bitcast(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(i))))))
    k = unsafe(addr(i))
    m = unsafe(unsafe(reinterpret<uint64>(unsafe(addr(i)))))
    tf = ThreeFields(a = unsafe(addr(i)), b = unsafe(addr(i)), c = unsafe(unsafe(reinterpret<uint64>(unsafe(addr(i))))))
    sscanf(unsafe(unsafe(reinterpret<int8 const?>(k))), unsafe(addr("%u,%u"[0])), unsafe(addr(unsafe(unsafe(addr(l[0]))[0]))), unsafe(addr(unsafe(unsafe(addr(l[0]))[1]))))
    ul = uint64(0)
    address_cast(unsafe(addr(ul)))
    n = unsafe(addr(oi.i))
    unsafe(unsafe(reinterpret<uint64>(unsafe(addr(i)))) == unsafe(reinterpret<uint64>(k)))
    cmp_ref(i, unsafe(addr(n)))
    o = 1
    p_0 = int(unsafe(addr(o) - unsafe(addr(i))))
    q = unsafe(unsafe(addr(o)) + 0)
    q = unsafe(unsafe(reinterpret<int?>(unsafe(addr(o) - 0))))
    takesPtr(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<uint8?>(r.idx)))[0])))[0])))))
    return
}
[export] def main() : int {
    return 0
}
