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
typedef write_cb = function?
struct writer {
    write : write_cb
    token : uint64
}
[export]
def main_0() : int {
    var w_0 : writer = writer()
    w_0 = writer(write = null, token = uint64(0))
    return call_writer(unsafe(unsafe(reinterpret<writer?>(unsafe(addr(w_0))))), uint64(0x0))
}
[export]
def call_writer(var w : writer?; var data : uint64) : int {
    var rc : int = int(0)
    rc = int(0)
    return rc
}
[export] def main() : int {
    return 0
}
