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
def constant_arguments(x : int const) : int {
    var y : int const = int(0)
    y = int(x) + 2
    return y
}
[export]
def constant_pointer(var x_0 : int?) {
    *x_0 = *x_0 + 1
    return
}
[export]
def pointer_to_constant(var x_1 : int const?) : int {
    return unsafe(unsafe(unsafe(reinterpret<int const?>(x_1)))[1]) + 1
}
[export]
def entry4(buffer_size : uint const; var buffer : int?) {
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[0]) = constant_arguments(1)
    constant_pointer(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[1]))))
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[1]) = pointer_to_constant(buffer)
    return
}
[export]
def addr_of_const() {
    var ci : int const = int(0)
    var i : int = int(0)
    var p1 : int const? = null
    var p2 : int const? = null
    var p3 : int? = null
    ci = 0
    i = 0
    p1 = unsafe(addr(ci))
    p2 = unsafe(addr(i))
    p3 = unsafe(addr(i))
    return
}
[export] def main() : int {
    return 0
}
