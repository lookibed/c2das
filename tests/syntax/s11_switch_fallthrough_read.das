options gen2

module s11_switch_fallthrough_read
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
def c2da_bool_to_int(v : bool) : int {
    if (v) {
        return 1
    } else {
        return 0
    }
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
def c2da_malloc(size : uint64) : uint64 {
    return uint64(0x0)
}
def c2da_free(ptr : uint64) {
}
def realloc(ptr : uint64; size : uint64) : uint64 {
    return ptr
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
def switch_fallthrough_read(var nb : int) : int {
    label 0:
    var v : int = 0
    goto label 2
    label 2:
    if (nb == 4) {
        goto label 119
    }
    if (nb == 3) {
        goto label 121
    }
    if (nb == 2) {
        goto label 123
    }
    if (nb == 1) {
        goto label 127
    }
    goto label 125
    label 119:
    v = int(int(int(int(v) << 8 | 1)))
    goto label 8
    label 8:
    goto label 121
    label 121:
    v = int(int(int(int(v) << 8 | 2)))
    goto label 10
    label 10:
    goto label 123
    label 123:
    v = int(int(int(int(v) << 8 | 3)))
    goto label 12
    label 12:
    goto label 125
    label 125:
    goto label 127
    label 127:
    v = int(int(int(int(v) << 8 | 4)))
    goto label 14
    label 14:
    goto label 4
    label 4:
    return v
    return int(0)
}
