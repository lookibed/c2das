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
typedef ulp = uint64?
[export]
def foo() : ulp {
    return null
}
[export]
def simple(var x : int const??; var y : int??) : int {
    return unsafe(unsafe(reinterpret<uint64>(*x)) == unsafe(reinterpret<uint64>(unsafe(unsafe(reinterpret<int const?>(*y))))))
}
[export]
def entry(buffer_size : uint const; var buffer : int?) {
    var test : int8? = null
    test = [unsafe(addr("string"[0]))]
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[0]) = int(unsafe(unsafe(unsafe(reinterpret<int8?>(test)))[0]))
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[1]) = int(unsafe(unsafe(unsafe(reinterpret<int8?>(test)))[1]))
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[2]) = int(unsafe(unsafe(unsafe(reinterpret<int8?>(test)))[2]))
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[3]) = int(unsafe(unsafe(unsafe(reinterpret<int8?>(test)))[3]))
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[4]) = int(unsafe(unsafe(unsafe(reinterpret<int8?>(test)))[4]))
    foo()
    return
}
[export] def main() : int {
    return 0
}
