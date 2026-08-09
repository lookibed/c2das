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
struct reader {
    buf : uint?
    origin : uint?
}
[export]
def main_0() : int {
    var data : array<uint> = []
    var bs_0 : reader = reader()
    data = [uint(0), uint(1), uint(2), uint(3)]
    bs_0 = reader(buf = unsafe(unsafe(addr(data[0])) + 3), origin = unsafe(addr(data[0])))
    return int(pointer_to_uint_cast(unsafe(unsafe(reinterpret<reader?>(unsafe(addr(bs_0)))))))
}
[export]
def pointer_to_uint_cast(var bs : reader?) : uint {
    var pos : uint = uint(0)
    pos = uint(uint(0))
    pos = uint(uint(unsafe(int64(unsafe(uint(unsafe(reinterpret<uint64>(bs.buf))) - uint(unsafe(reinterpret<uint64>(bs.origin))))))))
    return pos
}
[export] def main() : int {
    return 0
}
