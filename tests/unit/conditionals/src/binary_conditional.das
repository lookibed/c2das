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
def id(var i : int) : int {
    return i
}
[export]
def add(var p : int?; var i_0 : int; var r : int) : int {
    *p = *p + i_0
    return r
}
[export]
def entry3(sz : uint const; var buf : int?) {
    var c2da_fresh0 : int = int(0)
    if (uint64(id(0)) != uint64(0)) {
        c2da_fresh0 = id(0)
    } else {
        c2da_fresh0 = id(1)
    }
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[0]) = c2da_fresh0
    var c2da_fresh1 : int = int(0)
    if (uint64(id(2)) != uint64(0)) {
        c2da_fresh1 = id(2)
    } else {
        c2da_fresh1 = id(3)
    }
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[1]) = c2da_fresh1
    var c2da_fresh2 : int = int(0)
    if (uint64(add(unsafe(buf + 2), 2, 0)) != uint64(0)) {
        c2da_fresh2 = add(unsafe(buf + 2), 2, 0)
    } else {
        c2da_fresh2 = add(unsafe(buf + 3), 3, 0)
    }
    c2da_fresh2
    var c2da_fresh3 : int = int(0)
    if (uint64(add(unsafe(buf + 4), 4, 1)) != uint64(0)) {
        c2da_fresh3 = add(unsafe(buf + 4), 4, 1)
    } else {
        c2da_fresh3 = add(unsafe(buf + 5), 5, 0)
    }
    c2da_fresh3
    return
}
[export] def main() : int {
    return 0
}
