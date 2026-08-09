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
enum E1 : int64 {
    A = -1
    B = 0xb2d05e00
}
enum E2 : uint {
    C = 0xb2d05e00
}
enum E3 : uint64 {
    D = 0x6fc23ac00uL
}
[export]
def entry5(sz : uint const; var buffer : int?) {
    var e1 : array<E1> = []
    var e2 : array<E2> = []
    var e3 : array<E3> = []
    var i : int = int(0)
    e1 = [unsafe(reinterpret<E1>(1))]
    e2 = [unsafe(reinterpret<E2>(1))]
    e3 = [unsafe(reinterpret<E3>(1))]
    i = 0
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = int(unsafe(unsafe(addr(e1[0]))[0]))
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = int(unsafe(unsafe(addr(e1[0]))[1]))
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = int(unsafe(unsafe(addr(e2[0]))[0]))
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = int(unsafe(unsafe(addr(e2[0]))[1]))
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = int(unsafe(unsafe(addr(e3[0]))[0]))
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = int(unsafe(unsafe(addr(e3[0]))[1]))
    return
}
var B : int = 0xb2d05e00

var A : int = -1

var C : int = int(0xb2d05e00)

var D : int = int(0x6fc23ac00uL)
[export] def main() : int {
    return 0
}
