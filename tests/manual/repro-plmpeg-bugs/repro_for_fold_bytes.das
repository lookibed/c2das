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
def fold_bytes(var bytes : uint8 const?; var length : int) : uint {
    var hash : uint = uint(0)
    var index : int = int(0)
    hash = uint(0x811c9dc5)
    index = 0
    index = 0
    while (true) {
        if (!(int(index) < int(length))) {
            break
        }
        hash = uint(hash ^ uint(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(bytes)))[uint(index)]))))
        hash = uint(hash * 0x1000193)
        index = index + 1
        index
    }
    return hash
}
[export]
def main_0() : int {
    var data : array<uint8> const = [uint8(1), uint8(2), uint8(3)]
    return int(fold_bytes(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(data[0]))))), 3))
}
[export] def main() : int {
    return 0
}
