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
def c2da_memset(dst : void?; value : int; size : int) : void? {
    return dst
}
def c2da_memchr(ptr : void?; value : int; size : int) : uint64 {
    return uint64(0x0)
}
def c2da_strdup(src : void?) : int8? {
    return unsafe(unsafe(reinterpret<int8?>(src)))
}
def c2da_strlen(src : int8 const?) : int {
    return 0
}
[export]
def main_0() : int {
    var buf_0 : array<int8> = []
    buf_0 = [int8(1), int8(2), int8(3), int8(0)]
    return libc_runtime_calls(unsafe(unsafe(reinterpret<int8?>(unsafe(addr(buf_0[0]))))))
}
[export]
def libc_runtime_calls(var buf : int8?) : int {
    var found : uint64 = uint64(0)
    var dup : int8? = null
    found = unsafe(c2da_memchr(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint64>(buf)))))), 0, int(uint64(4))))
    unsafe(c2da_memset(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint64>(buf)))))), 0, int(uint64(4))))
    dup = unsafe(unsafe(reinterpret<int8?>(c2da_strdup(unsafe(unsafe(reinterpret<void?>(buf)))))))
    if (unsafe(uint64(unsafe(reinterpret<uint64>(uint64(found)))) != uint64(0))) {
        return 1
    } elif (unsafe(uint64(unsafe(reinterpret<uint64>(dup))) != uint64(0))) {
        return 2
    } else {
        return int(c2da_strlen(unsafe(unsafe(reinterpret<int8 const?>(buf)))))
    }
}
[export] def main() : int {
    return 0
}
