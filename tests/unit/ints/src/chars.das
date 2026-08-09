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
def multibyte_chars(sz : uint const; var buffer : int?) : int {
    var i : int = int(0)
    i = 0
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 10003
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = int(128561)
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 128561
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 0
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 1
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 0xffffffff
    return i
}
[export] def main() : int {
    return 0
}
