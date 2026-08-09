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
def side_effect(var x : int?) : int {
    *x = 1
    return 0
}
[export]
def exprs(n : uint const; var buffer : int?) {
    var i : uint64 = uint64(0)
    var arr : array<int8> = []
    i = uint64(0)
    arr = [int8(0)]
    side_effect(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[0]))))
    -side_effect(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[1]))))
    unsafe(addr(unsafe(unsafe(addr(""[0]))[uint(side_effect(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[2])))))])))
    unsafe(unsafe(addr(arr[0]))[uint(side_effect(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[3])))))]) = unsafe(unsafe(addr(arr[0]))[uint(side_effect(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[3])))))]) + 1
    unsafe(unsafe(addr(arr[0]))[uint(side_effect(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[3])))))])
    return
}
[export] def main() : int {
    return 0
}
