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
def inc(var n : int?) : int {
    n = unsafe(n + uint64(1))
    *n
    return 1
}
[export]
def unused_conditional1() : int {
    var i : int = int(0)
    i = 2
    0 < inc(unsafe(addr(i)))
    return i
}
[export]
def unused_conditional2() : int {
    var i_0 : int = int(0)
    i_0 = 2
    uint64(0) != uint64(0) || uint64(inc(unsafe(addr(i_0)))) != uint64(0)
    return i_0
}
[export]
def unused_conditional3() : int {
    var i_1 : int = int(0)
    i_1 = 2
    uint64(0) != uint64(0) && uint64(inc(unsafe(addr(i_1)))) != uint64(0)
    return i_1
}
[export] def main() : int {
    return 0
}
