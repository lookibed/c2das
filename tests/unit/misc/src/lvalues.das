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
def foo(var j : int?) : int? {
    j = unsafe(j + uint64(1))
    return unsafe(unsafe(reinterpret<int?>(j)))
}
[export]
def bar(var k : int) : int {
    k = k + 1
    return k
}
[export]
def lvalue(var buffer : int?) {
    var n : int = int(0)
    var p : int? = null
    var arr : array<array<int>> = []
    n = 5
    n = 6
    p = buffer
    *p = 8
    *unsafe(p + 1) = 9
    *foo(unsafe(p + 1)) = 3
    arr = [[3]]
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[3]) = n
    n = n + 1
    unsafe(unsafe(addr(unsafe(unsafe(addr(arr[0]))[0])[0]))[0]) = n
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[4]) = unsafe(unsafe(addr(unsafe(unsafe(addr(arr[0]))[0])[0]))[0])
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(bar(4))]) = -8
    return
}
[export] def main() : int {
    return 0
}
