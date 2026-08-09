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
def entry(sz : uint const; var buf : int?) {
    var x : int? = null
    var y : int? = null
    x = unsafe(addr(unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[0])))
    y = unsafe(addr(unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[1])))
    var c2da_fresh0 : int?? = null
    if (uint64(0) != uint64(0)) {
        c2da_fresh0 = unsafe(addr(y))
    } else {
        c2da_fresh0 = unsafe(addr(x))
    }
    *c2da_fresh0 = unsafe(unsafe(reinterpret<int?>(unsafe(unsafe(reinterpret<int?>(10))))))
    var c2da_fresh1 : int = int(0)
    if (uint64(1) != uint64(0)) {
        c2da_fresh1 = 2
    } else {
        c2da_fresh1 = 3
    }
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[2]) = c2da_fresh1
    var c2da_fresh2 : int = int(0)
    if (uint64(0) != uint64(0)) {
        c2da_fresh2 = 2
    } else {
        c2da_fresh2 = 3
    }
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[3]) = c2da_fresh2
    return
}
[export] def main() : int {
    return 0
}
